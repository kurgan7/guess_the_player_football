import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class CareerEntry {
  final String years;
  final String club;

  CareerEntry({required this.years, required this.club});

  factory CareerEntry.fromJson(Map<String, dynamic> json) {
    return CareerEntry(
      years: json['years'] as String,
      club: json['club'] as String,
    );
  }
}

class PlayerData {
  final String id;
  final String name;
  final List<String> aliases;
  final List<CareerEntry> career;

  PlayerData({
    required this.id,
    required this.name,
    required this.aliases,
    required this.career,
  });

  factory PlayerData.fromJson(Map<String, dynamic> json) {
    final careerList = (json['career'] as List)
        .map((e) => CareerEntry.fromJson(e as Map<String, dynamic>))
        .toList();

    final aliasesRaw = json['aliases'];
    final aliasesList = (aliasesRaw is List)
        ? aliasesRaw.map((e) => e.toString()).toList()
        : <String>[];

    return PlayerData(
      id: json['id'] as String,
      name: json['name'] as String,
      aliases: aliasesList,
      career: careerList,
    );
  }
}


Future<List<PlayerData>> loadPlayersFromAssets() async {
  final raw = await rootBundle.loadString('assets/data/players.json');
  final decoded = jsonDecode(raw) as List;
  return decoded
      .map((e) => PlayerData.fromJson(e as Map<String, dynamic>))
      .toList();
}
