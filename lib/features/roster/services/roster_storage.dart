import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/imported_roster.dart';

class RosterStorage {
  RosterStorage({SharedPreferencesAsync? preferences})
    : _providedPreferences = preferences;

  static const _storageKey = 'imported_rosters_v1';
  final SharedPreferencesAsync? _providedPreferences;

  SharedPreferencesAsync get _preferences =>
      _providedPreferences ?? SharedPreferencesAsync();

  Future<List<ImportedRoster>> load() async {
    final source = await _preferences.getString(_storageKey);
    if (source == null || source.isEmpty) return [];
    final decoded = jsonDecode(source) as List<Object?>;
    return decoded
        .map(
          (value) => ImportedRoster.fromJson(
            (value! as Map<Object?, Object?>).cast<String, Object?>(),
          ),
        )
        .toList();
  }

  Future<void> save(List<ImportedRoster> rosters) => _preferences.setString(
    _storageKey,
    jsonEncode(rosters.map((roster) => roster.toJson()).toList()),
  );

  Future<void> delete(String rosterId) async {
    final rosters = await load();
    rosters.removeWhere((roster) => roster.id == rosterId);
    await save(rosters);
  }
}
