import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:math';
import 'player_data.dart';

class PlayerFromCareerGamePage extends StatefulWidget {
  const PlayerFromCareerGamePage({super.key});

  @override
  State<PlayerFromCareerGamePage> createState() =>
      _PlayerFromCareerGamePageState();
}

class _PlayerFromCareerGamePageState extends State<PlayerFromCareerGamePage> {
  static const int totalSeconds = 60;
  int remaining = totalSeconds;

  Timer? _timer;
  final _controller = TextEditingController();

  // MVP mock data (sonra dataset’ten beslenecek)
  final _rand = Random();
  List<PlayerData> _players = [];
  PlayerData? _current;
  bool _loading = true;
  String? _loadError;

  bool solved = false;
  int? earnedPoints;

  @override
  void initState() {
    super.initState();
    _initGame();
  }

  Future<void> _initGame() async {
    setState(() {
      _loading = true;
      _loadError = null;
      solved = false;
      earnedPoints = null;
      remaining = totalSeconds;
      _controller.clear();
    });

    try {
      _players = await loadPlayersFromAssets();
      _current = _players[_rand.nextInt(_players.length)];
      _loading = false;
      _startTimer();
      setState(() {});
    } catch (e) {
      setState(() {
        _loading = false;
        _loadError = e.toString();
      });
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        remaining--;
        if (remaining <= 0) {
          remaining = 0;
          _timer?.cancel();
        }
      });
    });
  }

  int _scoreForRemaining(int r) {
    final elapsed = totalSeconds - r;
    if (elapsed <= 20) return 1000;
    if (elapsed <= 40) return 600;
    return 300;
  }

  String _normalizeName(String input) {
    var s = input.trim().toLowerCase();

    // Türkçe karakterleri sadeleştir
    const map = {
      'ç': 'c',
      'ğ': 'g',
      'ı': 'i',
      'İ': 'i',
      'ö': 'o',
      'ş': 's',
      'ü': 'u',
    };
    map.forEach((k, v) => s = s.replaceAll(k, v));

    // noktalama/çoklu boşluk temizliği
    s = s.replaceAll(RegExp(r"[^a-z0-9\s]"), " ");
    s = s.replaceAll(RegExp(r"\s+"), " ").trim();

    return s;
  }

  String _norm(String s) => s.trim().toLowerCase();

  void _submit() {
    if (remaining == 0 || solved) return;

    final guess = _norm(_controller.text);
    if (guess.isEmpty) return;

    if (guess.isEmpty) return;

    final player = _current;
    final candidates = <String>[
      if (player != null) player.name,
      if (player != null) ...player.aliases,
    ];

    // Hepsini normalize edip set yap
    final normalizedCandidates = candidates
        .map(_normalizeName)
        .where((e) => e.isNotEmpty)
        .toSet();

    // Kullanıcı tam eşleşti mi?
    final exactMatch = normalizedCandidates.contains(guess);

    // Ek: kullanıcı sadece soyadı gibi kısa yazarsa (örn "ronaldo")
    // Basit kural: herhangi bir aday token'larından biri guess ile eşleşiyorsa kabul
    final tokenMatch = normalizedCandidates.any((cand) {
      final tokens = cand.split(' ');
      return tokens.contains(guess);
    });

    final isCorrect = exactMatch || tokenMatch;

    if (isCorrect) {
      final pts = _scoreForRemaining(remaining);
      setState(() {
        solved = true;
        earnedPoints = pts;
      });
      _timer?.cancel();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Doğru! +$pts puan')));
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Yanlış! Tekrar dene.')));
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = remaining / totalSeconds;
    final entries = _current?.career ?? const <CareerEntry>[];
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_loadError != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Kariyerden Futbolcu Tahmini')),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Veri yüklenemedi:\n$_loadError'),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _initGame,
                child: const Text('Tekrar dene'),
              ),
              if (solved) ...[
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: _initGame,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Yeni Oyuncu'),
                ),
              ],
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Kariyerden Futbolcu Tahmini')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Timer + score
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Süre: $remaining sn', style: theme.textTheme.titleMedium),
                if (solved && earnedPoints != null)
                  Text(
                    '+${earnedPoints!} puan',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(value: progress, minHeight: 10),
            ),

            const SizedBox(height: 16),

            // Career card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Kariyer',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Kariyer satırları
                    ...entries.map(
                      (e) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          children: [
                            SizedBox(width: 92, child: Text(e.years)),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                e.club,
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const Spacer(),

            // Input
            TextField(
              controller: _controller,
              enabled: remaining > 0 && !solved,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _submit(),
              decoration: const InputDecoration(
                labelText: 'Futbolcunun adını yaz',
                hintText: 'Örn: Cristiano Ronaldo',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),

            ElevatedButton.icon(
              onPressed: (remaining > 0 && !solved) ? _submit : null,
              icon: const Icon(Icons.check),
              label: Text(solved ? 'Çözüldü' : 'Tahmin Et'),
            ),

            if (remaining == 0 && !solved) ...[
              const SizedBox(height: 10),
              const Text('Süre bitti! (MVP) Bonus hakla tekrar dene.'),
            ],
          ],
        ),
      ),
    );
  }
}
