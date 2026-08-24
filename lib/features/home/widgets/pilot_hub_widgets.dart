part of '../pilot_hub.dart';

class _AirportTime extends StatelessWidget {
  const _AirportTime({
    required this.code,
    required this.time,
    this.alignEnd = false,
  });
  final String code, time;
  final bool alignEnd;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: alignEnd
        ? CrossAxisAlignment.end
        : CrossAxisAlignment.start,
    children: [
      Text(
        code,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 30,
          fontWeight: FontWeight.w800,
        ),
      ),
      Text(
        time,
        style: const TextStyle(color: Color(0xFFE2ECE5), fontSize: 15),
      ),
    ],
  );
}

class _WeatherCard extends StatelessWidget {
  const _WeatherCard({
    required this.airport,
    required this.icon,
    required this.temperature,
    required this.wind,
    required this.detail,
  });
  final String airport, temperature, wind, detail;
  final IconData icon;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(
      color: const Color(0xFFFBFAF6),
      borderRadius: BorderRadius.circular(18),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          airport,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Icon(icon, color: const Color(0xFF28634A)),
            const Spacer(),
            Text(
              temperature,
              style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(wind, style: const TextStyle(fontSize: 12)),
        Text(
          detail,
          style: const TextStyle(color: Color(0xFF6C756F), fontSize: 12),
        ),
      ],
    ),
  );
}

class _TimelineItem extends StatelessWidget {
  const _TimelineItem({
    required this.time,
    required this.title,
    required this.subtitle,
    required this.complete,
  });
  final String time, title, subtitle;
  final bool complete;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(
      children: [
        SizedBox(
          width: 48,
          child: Text(
            time,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        Icon(
          complete ? Icons.check_circle_rounded : Icons.circle_outlined,
          color: complete ? const Color(0xFF28634A) : const Color(0xFFA4AAA5),
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
              Text(
                subtitle,
                style: const TextStyle(color: Color(0xFF6C756F), fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label, required this.color});
  final String label;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: color.withValues(alpha: .12),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      label,
      style: TextStyle(
        color: color,
        fontSize: 10,
        fontWeight: FontWeight.w800,
        letterSpacing: .8,
      ),
    ),
  );
}

class _AdvisoryNote extends StatelessWidget {
  const _AdvisoryNote();
  @override
  Widget build(BuildContext context) => const Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(Icons.info_outline_rounded, size: 15, color: Color(0xFF7B827D)),
      SizedBox(width: 6),
      Expanded(
        child: Text(
          'Forecast preview only · confirm with an approved operational source.',
          style: TextStyle(color: Color(0xFF7B827D), fontSize: 11),
        ),
      ),
    ],
  );
}

class _ControlledContentNotice extends StatelessWidget {
  const _ControlledContentNotice();
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: const Color(0xFFECE1CD),
      borderRadius: BorderRadius.circular(14),
    ),
    child: const Text(
      'Training aid only. Aircraft procedures and airport content must show source, operator applicability and revision status before operational use.',
      style: TextStyle(color: Color(0xFF654C31), fontSize: 12, height: 1.4),
    ),
  );
}

class _BriefingSection extends StatelessWidget {
  const _BriefingSection({
    required this.title,
    required this.icon,
    required this.status,
    required this.children,
  });
  final String title, status;
  final IconData icon;
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => Card(
    elevation: 0,
    color: const Color(0xFFFBFAF6),
    margin: const EdgeInsets.only(bottom: 12),
    child: Padding(
      padding: const EdgeInsets.all(17),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF28634A)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
              _StatusPill(
                label: status.toUpperCase(),
                color: const Color(0xFF28634A),
              ),
            ],
          ),
          const Divider(height: 25),
          ...children,
        ],
      ),
    ),
  );
}

class _FeatureTile extends StatelessWidget {
  const _FeatureTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
  final IconData icon;
  final String title, subtitle;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Card(
    elevation: 0,
    color: const Color(0xFFFBFAF6),
    margin: const EdgeInsets.only(bottom: 10),
    child: ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: const Color(0xFFDCEADD),
          borderRadius: BorderRadius.circular(13),
        ),
        child: Icon(icon, color: const Color(0xFF28634A)),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right_rounded),
    ),
  );
}

class _Recommendation extends StatelessWidget {
  const _Recommendation({
    required this.title,
    required this.category,
    required this.detail,
  });
  final String title, category, detail;
  @override
  Widget build(BuildContext context) => Card(
    elevation: 0,
    child: ListTile(
      contentPadding: const EdgeInsets.all(14),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 5),
        child: Text('$category\n$detail'),
      ),
      isThreeLine: true,
      trailing: const Icon(Icons.bookmark_border_rounded),
    ),
  );
}
