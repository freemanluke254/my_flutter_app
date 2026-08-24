part of '../commute_reminder_page.dart';

class _MinuteSelector extends StatelessWidget {
  const _MinuteSelector({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.options,
    required this.enabled,
    required this.onChanged,
  });
  final String title, subtitle;
  final int value;
  final List<int> options;
  final bool enabled;
  final ValueChanged<int> onChanged;
  @override
  Widget build(BuildContext context) => Card(
    elevation: 0,
    color: const Color(0xFFFBFAF6),
    margin: const EdgeInsets.only(bottom: 10),
    child: Padding(
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 3),
          Text(
            subtitle,
            style: const TextStyle(color: Color(0xFF6C756F), fontSize: 12),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: options
                .map(
                  (minutes) => ChoiceChip(
                    label: Text('$minutes min'),
                    selected: value == minutes,
                    onSelected: enabled ? (_) => onChanged(minutes) : null,
                  ),
                )
                .toList(),
          ),
        ],
      ),
    ),
  );
}

class _DurationSelector extends StatelessWidget {
  const _DurationSelector({
    required this.value,
    required this.enabled,
    required this.onChanged,
  });
  final int value;
  final bool enabled;
  final ValueChanged<int> onChanged;
  @override
  Widget build(BuildContext context) {
    final hours = value ~/ 60;
    final minutes = value.remainder(60);
    return Card(
      elevation: 0,
      color: const Color(0xFFFBFAF6),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Fallback journey time',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 3),
            const Text(
              'Used when live routing is unavailable',
              style: TextStyle(color: Color(0xFF6C756F), fontSize: 12),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    initialValue: hours,
                    decoration: const InputDecoration(labelText: 'Hours'),
                    items: List.generate(
                      7,
                      (index) =>
                          DropdownMenuItem(value: index, child: Text('$index')),
                    ),
                    onChanged: enabled
                        ? (hours) => onChanged((hours! * 60) + minutes)
                        : null,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    initialValue: minutes,
                    decoration: const InputDecoration(labelText: 'Minutes'),
                    items: [0, 10, 15, 20, 30, 40, 45, 50]
                        .map(
                          (value) => DropdownMenuItem(
                            value: value,
                            child: Text('$value'),
                          ),
                        )
                        .toList(),
                    onChanged: enabled
                        ? (minutes) => onChanged((hours * 60) + minutes!)
                        : null,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CommutePreview extends StatelessWidget {
  const _CommutePreview({required this.signOn, required this.settings});
  final DateTime signOn;
  final CommuteSettings settings;
  @override
  Widget build(BuildContext context) {
    final leave = settings.leaveTime(signOn);
    final reminder = settings.reminderTime(signOn);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF173D31),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'EXAMPLE · 10:00 SIGN-ON',
            style: TextStyle(
              color: Color(0xFFBFD8C8),
              fontSize: 11,
              letterSpacing: 1.1,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Leave at ${_time(leave)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Reminder at ${_time(reminder)} · arrive at ${_time(signOn.subtract(Duration(minutes: settings.arrivalBufferMinutes)))}',
            style: const TextStyle(color: Color(0xFFE2ECE5)),
          ),
          const SizedBox(height: 5),
          Text(
            '${_duration(settings.fallbackTravelMinutes)} travel + ${settings.arrivalBufferMinutes} min arrival buffer',
            style: const TextStyle(color: Color(0xFFBFD8C8), fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _ProviderNote extends StatelessWidget {
  const _ProviderNote();
  @override
  Widget build(BuildContext context) => const Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(Icons.info_outline_rounded, size: 16, color: Color(0xFF6C756F)),
      SizedBox(width: 7),
      Expanded(
        child: Text(
          'Live traffic and transit times require a routing provider. Until one is connected, reminders use your fallback journey time and are labelled as estimates.',
          style: TextStyle(color: Color(0xFF6C756F), fontSize: 11, height: 1.4),
        ),
      ),
    ],
  );
}

String _time(DateTime value) =>
    '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';
String _duration(int minutes) =>
    '${minutes ~/ 60}h ${minutes.remainder(60).toString().padLeft(2, '0')}m';
