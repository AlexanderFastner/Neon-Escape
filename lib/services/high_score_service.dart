import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HighScoreService {
  HighScoreService._();
  static final HighScoreService instance = HighScoreService._();

  static const String _storageKey = 'two_cars_high_scores';
  static const int _maxEntriesPerDifficulty = 10;

  Future<Map<String, List<int>>> _loadScores() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_storageKey);
      if (jsonString == null) {
        return {};
      }

      final Map<String, dynamic> decoded = jsonDecode(jsonString);
      return decoded.map((key, value) {
        final list = (value as List).map((e) => e as int).toList();
        return MapEntry(key, list);
      });
    } on MissingPluginException {
      // SharedPreferences plugin not available (e.g. during hot reload before reinstall).
      // Fall back to empty in-memory data to avoid crashing.
      return {};
    }
  }

  Future<void> recordScore(String difficulty, int score) async {
    if (score <= 0) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final scores = await _loadScores();
      final existing = scores[difficulty] ?? <int>[];

      existing.add(score);
      existing.sort((b, a) => a.compareTo(b)); // Descending
      if (existing.length > _maxEntriesPerDifficulty) {
        existing.removeRange(
          _maxEntriesPerDifficulty,
          existing.length,
        );
      }

      scores[difficulty] = existing;

      final encoded = jsonEncode(scores);
      await prefs.setString(_storageKey, encoded);
    } on MissingPluginException {
      // Ignore if plugin missing; scores simply won't persist this session.
      return;
    }
  }

  Future<List<int>> getScores(String difficulty) async {
    final scores = await _loadScores();
    return scores[difficulty]?.toList() ?? <int>[];
  }

  Future<void> clearAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_storageKey);
    } on MissingPluginException {
      return;
    }
  }
}

