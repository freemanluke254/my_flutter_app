class AirportUtcOffset {
  const AirportUtcOffset();

  String? offsetFor(String airportCode, DateTime date) {
    final code = airportCode.trim().toUpperCase();
    if (_southAfrica.contains(code)) return '+02:00';
    if (_utc.contains(code)) return '+00:00';
    if (_unitedKingdom.contains(code)) {
      return _isUkSummerTime(date) ? '+01:00' : '+00:00';
    }
    if (_usEastern.contains(code)) {
      return _isUsDaylightTime(date) ? '-04:00' : '-05:00';
    }
    if (_usPacific.contains(code)) {
      return _isUsDaylightTime(date) ? '-07:00' : '-08:00';
    }
    if (_india.contains(code)) return '+05:30';
    if (_uae.contains(code)) return '+04:00';
    return null;
  }

  static const _southAfrica = {'FAOR', 'JNB', 'FACT', 'CPT', 'FALE', 'DUR'};
  static const _utc = {'UTC'};
  static const _unitedKingdom = {
    'EGLL',
    'LHR',
    'EGKK',
    'LGW',
    'EGCC',
    'MAN',
    'EGPH',
    'EDI',
  };
  static const _usEastern = {
    'KJFK',
    'JFK',
    'KBOS',
    'BOS',
    'KMCO',
    'MCO',
    'KIAD',
    'IAD',
    'KATL',
    'ATL',
  };
  static const _usPacific = {
    'KLAS',
    'LAS',
    'KLAX',
    'LAX',
    'KSFO',
    'SFO',
    'KSEA',
    'SEA',
  };
  static const _india = {'VABB', 'BOM', 'VIDP', 'DEL'};
  static const _uae = {'OMDB', 'DXB', 'OMAA', 'AUH'};

  bool _isUkSummerTime(DateTime date) {
    final start = _lastSunday(date.year, DateTime.march);
    final end = _lastSunday(date.year, DateTime.october);
    final day = DateTime(date.year, date.month, date.day);
    return !day.isBefore(start) && day.isBefore(end);
  }

  bool _isUsDaylightTime(DateTime date) {
    final start = _nthSunday(date.year, DateTime.march, 2);
    final end = _nthSunday(date.year, DateTime.november, 1);
    final day = DateTime(date.year, date.month, date.day);
    return !day.isBefore(start) && day.isBefore(end);
  }

  DateTime _lastSunday(int year, int month) {
    final lastDay = DateTime(year, month + 1, 0);
    return lastDay.subtract(Duration(days: lastDay.weekday % 7));
  }

  DateTime _nthSunday(int year, int month, int occurrence) {
    final first = DateTime(year, month);
    final firstSunday = first.add(Duration(days: (7 - first.weekday) % 7));
    return firstSunday.add(Duration(days: 7 * (occurrence - 1)));
  }
}
