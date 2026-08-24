part of '../commute_reminder_page.dart';

class CommuteTodayCard extends StatefulWidget {
  const CommuteTodayCard({super.key, required this.signOn});
  final DateTime signOn;

  @override
  State<CommuteTodayCard> createState() => _CommuteTodayCardState();
}

class _CommuteTodayCardState extends State<CommuteTodayCard> {
  CommuteSettings? _settings;

  @override
  void initState() {
    super.initState();
    CommuteSettingsStore.load().then((value) {
      if (mounted) setState(() => _settings = value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = _settings;
    if (settings == null || !settings.enabled) return const SizedBox.shrink();
    final leave = settings.leaveTime(widget.signOn);
    return Container(
      margin: const EdgeInsets.only(bottom: 22),
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: const Color(0xFFECE1CD),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          const Icon(Icons.directions_car_outlined, color: Color(0xFF79562E)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Leave by ${_time(leave)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${_duration(settings.fallbackTravelMinutes)} estimated · arrive ${settings.arrivalBufferMinutes} min before report',
                  style: const TextStyle(
                    color: Color(0xFF6F5A40),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const Text(
            'ESTIMATE',
            style: TextStyle(
              color: Color(0xFF79562E),
              fontSize: 9,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
