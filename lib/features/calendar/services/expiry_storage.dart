import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/expiry_record.dart';

class ExpiryStorage {
  static const _key = 'expiry_records_v1';

  SharedPreferencesAsync get _preferences => SharedPreferencesAsync();

  Future<List<ExpiryRecord>> load() async {
    final source = await _preferences.getString(_key);
    if (source == null || source.isEmpty) return [];
    return (jsonDecode(source) as List<Object?>)
        .map(
          (value) => ExpiryRecord.fromJson(
            (value! as Map<Object?, Object?>).cast<String, Object?>(),
          ),
        )
        .toList();
  }

  Future<void> save(List<ExpiryRecord> records) => _preferences.setString(
    _key,
    jsonEncode(records.map((record) => record.toJson()).toList()),
  );
}
