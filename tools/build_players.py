import json
import re
import time
from collections import Counter
from pathlib import Path
from urllib.parse import urlencode

import requests

# 1. Base Query: Get 600 players from Top 5 Leagues with basic info
# We use a subquery to LIMIT inside the graph pattern before expensive label services if possible,
# but usually standard LIMIT at end is fine if the graph match is efficient.
# To ensure high quality, we filter for players who have a birthDate, position, and citizenship.
SPARQL_BASE = r"""
SELECT DISTINCT ?player ?playerLabel ?birthDate
       (GROUP_CONCAT(DISTINCT ?citizenshipLabel; separator="|") AS ?citizenships)
       (GROUP_CONCAT(DISTINCT ?positionLabel; separator="|") AS ?positions)
WHERE {
  {
    SELECT DISTINCT ?player WHERE {
       ?player wdt:P106 wd:Q937857 ; # Occupation: Football player
       wdt:P54 ?club .       # Member of sports team
       # ?club wdt:P17 ?clubCountry .
       # VALUES ?clubCountry { wd:Q145 wd:Q29 wd:Q38 wd:Q183 wd:Q142 } # Top 5 leagues  <-- Removed to allow Messi/Ronaldo
       ?player wikibase:sitelinks ?sitelinks .
       FILTER(?sitelinks > 30)
       ?player wdt:P569 ?birthDate .
       FILTER(?birthDate >= "1980-01-01"^^xsd:dateTime)
    }
    ORDER BY DESC(?sitelinks)
    LIMIT 600
  }
  
  ?player wdt:P569 ?birthDate . 
  OPTIONAL { 
    ?player wdt:P27 ?citizenship .
    ?citizenship rdfs:label ?citizenshipLabel . 
    FILTER(lang(?citizenshipLabel) = "en")
  }
  OPTIONAL { ?player wdt:P413 ?position . OPTIONAL { ?position rdfs:label ?positionLabel . FILTER(lang(?positionLabel) = "en") } }

  SERVICE wikibase:label { bd:serviceParam wikibase:language "en". }
}
GROUP BY ?player ?playerLabel ?birthDate
"""

# 2. Career Query Template (to be formatted with VALUES ?player {...})
SPARQL_CAREER = r"""
SELECT ?player (GROUP_CONCAT(DISTINCT CONCAT(
          COALESCE(STR(?start), ""), "…", COALESCE(STR(?end), ""), ";;", ?clubLabel
        ); separator="||") AS ?career)
WHERE {
  VALUES ?player { <IDS> }
  ?player p:P54 ?st .
  ?st ps:P54 ?club .
  OPTIONAL { ?st pq:P580 ?start . }
  OPTIONAL { ?st pq:P582 ?end . }
  
  # Only keep clubs in Top 5 countries to reduce noise? 
  # Or keep all? The original script kept all but only MATCHED players in Top 5.
  # Let's keep all career entries for these players.
  
  # ?club wdt:P17 ?clubCountry .
  
  OPTIONAL { ?club rdfs:label ?clubLabel . FILTER(lang(?clubLabel) = "en") }
}
GROUP BY ?player
"""

# 3. Trophies Query Template
SPARQL_TROPHIES = r"""
SELECT ?player (GROUP_CONCAT(?awardLabel; separator="|") AS ?awards)
WHERE {
  VALUES ?player { <IDS> }
  ?player p:P166 ?stmt .
  ?stmt ps:P166 ?award .
  ?award rdfs:label ?awardLabel .
  FILTER(lang(?awardLabel) = "en")
}
GROUP BY ?player
"""

ENDPOINT = "https://query.wikidata.org/sparql"

def qid_from_uri(uri: str) -> str:
    return uri.rstrip("/").split("/")[-1]

def norm_space(s: str) -> str:
    return re.sub(r"\s+", " ", s).strip()

def make_aliases(name: str) -> list[str]:
    n = norm_space(name)
    tokens = n.split(" ")
    aliases = set()
    aliases.add(n)
    if len(tokens) >= 2:
        aliases.add(tokens[-1]) 
        aliases.add(" ".join(tokens[-2:]))
    aliases.add(re.sub(r"[^\w\s]", "", n))
    return sorted(a for a in aliases if a and len(a) >= 3)

def parse_career(career_blob: str) -> list[dict]:
    out = []
    if not career_blob:
        return out
    for item in career_blob.split("||"):
        if ";;" not in item:
            continue
        years_raw, club = item.split(";;", 1)
        years_raw = years_raw.strip()
        club = norm_space(club)

        # Filter youth teams
        club_lower = club.lower()
        if "under-" in club_lower or "under " in club_lower:
            continue
            
        start, end = "", ""
        if "…" in years_raw:
            start, end = years_raw.split("…", 1)
        start = start.split("T")[0] if start else ""
        end = end.split("T")[0] if end else ""
        
        years = ""
        if start:
            years = start[:4]
        if end:
            years = (years + "–" + end[:4]) if years else ("?–" + end[:4])
        if not start and not end:
            years = "?"
        out.append({"years": years, "club": club})

    seen = set()
    dedup = []
    for e in out:
        key = (e["years"], e["club"])
        if key in seen:
            continue
        seen.add(key)
        dedup.append(e)
    
    # Sort chronologically by start year
    def get_start_year(e):
        val = e["years"][:4]
        if val.isdigit():
            return int(val)
        return 9999
        
    dedup.sort(key=get_start_year)
    return dedup

def fetch_sparql(query: str) -> dict:
    headers = {
        "Accept": "application/sparql-results+json",
        "User-Agent": "career-guess-game/0.2 (split-query-bot)"
    }
    params = {"query": query, "format": "json"}
    # Sometimes queries are too long for GET, use POST if needed, but requests.get usually handles query params well.
    # However, for long VALUES clauses, POST is safer.
    url = ENDPOINT
    
    last_err = None
    for attempt in range(1, 6):
        try:
            r = requests.post(url, data=params, headers=headers, timeout=60)
            r.raise_for_status()
            return r.json()
        except Exception as e:
            last_err = e
            print(f"  Request failed (attempt {attempt}/5): {e}")
            time.sleep(2 * attempt)
    raise last_err

def batch_query(qids: list[str], template: str, label: str) -> dict:
    # returns { qid: result_value }
    results = {}
    chunk_size = 80 # Safe size for VALUES clause
    print(f"Fetching {label} for {len(qids)} players in chunks of {chunk_size}...")
    
    for i in range(0, len(qids), chunk_size):
        chunk = qids[i:i+chunk_size]
        # Format: wd:Q1 wd:Q2 ...
        values_str = " ".join(f"wd:{qid}" for qid in chunk)
        query = template.replace("<IDS>", values_str)
        
        try:
            data = fetch_sparql(query)
            bindings = data["results"]["bindings"]
            for b in bindings:
                p_uri = b["player"]["value"]
                qid = qid_from_uri(p_uri)
                # Helper to extract the main concat field
                # Career query alias: ?career
                # Trophies query alias: ?awards
                val = ""
                if "career" in b:
                    val = b["career"]["value"]
                elif "awards" in b:
                    val = b["awards"]["value"]
                results[qid] = val
        except Exception as e:
             print(f"  Warning: Chunk {i} failed: {e}")

        time.sleep(0.5) # Politeness delay
        
    return results

def main():
    print("Step 1: Fetching base player list (Limit 600)...")
    base_data = fetch_sparql(SPARQL_BASE)
    
    rows = base_data["results"]["bindings"]
    print(f"Got {len(rows)} players.")
    
    players_map = {}
    qids = []
    
    for b in rows:
        player_uri = b["player"]["value"]
        qid = qid_from_uri(player_uri)
        name = b.get("playerLabel", {}).get("value", "").strip()
        birth = b.get("birthDate", {}).get("value", "").split("T")[0]
        citizenships = b.get("citizenships", {}).get("value", "")
        positions = b.get("positions", {}).get("value", "")
        
        players_map[qid] = {
            "id": qid,
            "name": name,
            "birthDate": birth,
            "nationality": [c for c in citizenships.split("|") if c],
            "position": [p for p in positions.split("|") if p],
            "aliases": make_aliases(name),
            "career": [], # To be filled
            "winnedTrophies": [] # To be filled
        }
        qids.append(qid)
        
    # Remove duplicates if any (SPARQL DISTINCT isn't always perfect with GROUP_CONCAT)
    qids = sorted(list(set(qids)))
    
    # Step 2: Fetch Career
    career_map = batch_query(qids, SPARQL_CAREER, "Career")
    for qid, c_blob in career_map.items():
        if qid in players_map:
            players_map[qid]["career"] = parse_career(c_blob)
            
    # Step 3: Fetch Trophies
    trophies_map = batch_query(qids, SPARQL_TROPHIES, "Trophies")
    for qid, t_blob in trophies_map.items():
        if qid in players_map:
            # t_blob is "Award A|Award A|Award B"
            if not t_blob:
                continue
            
            raw_list = [a for a in t_blob.split("|") if a]
            counts = Counter(raw_list)
            
            formatted_awards = []
            # Sort by count desc, then name
            for name, count in sorted(counts.items(), key=lambda x: (-x[1], x[0])):
                if count > 1:
                    formatted_awards.append(f"{count}x {name}")
                else:
                    formatted_awards.append(name)
            
            players_map[qid]["winnedTrophies"] = formatted_awards

    # Final Filter and Save
    final_list = []
    for p in players_map.values():
        # Check minimum requirements
        if p["name"] and len(p["career"]) >= 2:
            final_list.append(p)
            
    out_path = Path("assets/data/players.json")
    out_path.parent.mkdir(parents=True, exist_ok=True)
    out_path.write_text(json.dumps(final_list, ensure_ascii=False, indent=2), encoding="utf-8")
    print(f"Done! Wrote {len(final_list)} players to {out_path}")

if __name__ == "__main__":
    main()
