part of '../commute_reminder_page.dart';

class CommuteSettings {
  const CommuteSettings({
    required this.enabled,
    required this.homeAddress,
    required this.workAddress,
    required this.mode,
    required this.arrivalBufferMinutes,
    required this.reminderLeadMinutes,
    required this.fallbackTravelMinutes,
  });

  final bool enabled;
  final String homeAddress;
  final String workAddress;
  final String mode;
  final int arrivalBufferMinutes;
  final int reminderLeadMinutes;
  final int fallbackTravelMinutes;

  static const defaults = CommuteSettings(
    enabled: false,
    homeAddress: '',
    workAddress: '',
    mode: 'Driving',
    arrivalBufferMinutes: 60,
    reminderLeadMinutes: 30,
    fallbackTravelMinutes: 160,
  );

  DateTime leaveTime(DateTime signOn, {int? liveTravelMinutes}) =>
      signOn.subtract(
        Duration(
          minutes:
              arrivalBufferMinutes +
              (liveTravelMinutes ?? fallbackTravelMinutes),
        ),
      );

  DateTime reminderTime(DateTime signOn, {int? liveTravelMinutes}) => leaveTime(
    signOn,
    liveTravelMinutes: liveTravelMinutes,
  ).subtract(Duration(minutes: reminderLeadMinutes));

  Map<String, dynamic> toJson() => {
    'enabled': enabled,
    'homeAddress': homeAddress,
    'workAddress': workAddress,
    'mode': mode,
    'arrivalBufferMinutes': arrivalBufferMinutes,
    'reminderLeadMinutes': reminderLeadMinutes,
    'fallbackTravelMinutes': fallbackTravelMinutes,
  };

  factory CommuteSettings.fromJson(Map<String, dynamic> json) =>
      CommuteSettings(
        enabled: json['enabled'] as bool? ?? false,
        homeAddress: json['homeAddress'] as String? ?? '',
        workAddress: json['workAddress'] as String? ?? '',
        mode: json['mode'] as String? ?? 'Driving',
        arrivalBufferMinutes: json['arrivalBufferMinutes'] as int? ?? 60,
        reminderLeadMinutes: json['reminderLeadMinutes'] as int? ?? 30,
        fallbackTravelMinutes: json['fallbackTravelMinutes'] as int? ?? 160,
      );
}

class CommuteSettingsStore {
  static Future<CommuteSettings> load() async {
    final preferences = await SharedPreferences.getInstance();
    final encoded = preferences.getString(_commuteStorageKey);
    if (encoded == null) return CommuteSettings.defaults;
    return CommuteSettings.fromJson(
      jsonDecode(encoded) as Map<String, dynamic>,
    );
  }

  static Future<void> save(CommuteSettings settings) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      _commuteStorageKey,
      jsonEncode(settings.toJson()),
    );
  }
}
