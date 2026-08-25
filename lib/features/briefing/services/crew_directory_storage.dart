import 'package:shared_preferences/shared_preferences.dart';

class CrewDirectoryStorage {
  static const _key = 'shared_crew_name_directory_v1';

  Future<List<String>> load() async {
    final names =
        (await SharedPreferences.getInstance()).getStringList(_key) ?? [];
    names.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return names;
  }

  Future<List<String>> addAll(Iterable<String> values) async {
    final names = await load();
    for (final value in values) {
      final name = value.trim();
      if (name.isEmpty ||
          names.any((item) => item.toLowerCase() == name.toLowerCase())) {
        continue;
      }
      names.add(name);
    }
    names.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    await (await SharedPreferences.getInstance()).setStringList(_key, names);
    return names;
  }
}
