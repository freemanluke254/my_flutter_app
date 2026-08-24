part of '../planning_compliance_page.dart';

enum _Status { green, amber, red, expired }

_Status _status(ComplianceItem item) {
  if (item.daysRemaining < 0) return _Status.expired;
  if (item.daysRemaining <= item.redDays) return _Status.red;
  if (item.daysRemaining <= item.amberDays) return _Status.amber;
  return _Status.green;
}

extension on _Status {
  Color get color => switch (this) {
    _Status.green => const Color(0xFF287A50),
    _Status.amber => const Color(0xFFC17A10),
    _Status.red => const Color(0xFFC33C36),
    _Status.expired => const Color(0xFF691F1C),
  };
  String get label => switch (this) {
    _Status.green => 'VALID',
    _Status.amber => 'PLAN RENEWAL',
    _Status.red => 'ACTION NEEDED',
    _Status.expired => 'EXPIRED',
  };
}

class _ExpiryCard extends StatelessWidget {
  const _ExpiryCard({
    required this.item,
    required this.onEdit,
    required this.onDelete,
  });
  final ComplianceItem item;
  final VoidCallback onEdit, onDelete;
  @override
  Widget build(BuildContext context) {
    final state = _status(item);
    final days = item.daysRemaining;
    final countdown = days < 0
        ? '${days.abs()} days overdue'
        : days == 0
        ? 'Expires today'
        : '$days days remaining';
    return Card(
      elevation: 0,
      color: const Color(0xFFFBFAF6),
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onEdit,
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Row(
            children: [
              Container(
                width: 5,
                height: 58,
                decoration: BoxDecoration(
                  color: state.color,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Text(
                          state.label,
                          style: TextStyle(
                            color: state.color,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      countdown,
                      style: TextStyle(
                        color: state.color,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '${item.category} · ${_dateText(item.date)}',
                      style: const TextStyle(
                        color: Color(0xFF6C756F),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) =>
                    value == 'delete' ? onDelete() : onEdit(),
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'edit', child: Text('Edit')),
                  PopupMenuItem(value: 'delete', child: Text('Delete')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Overview extends StatelessWidget {
  const _Overview({
    required this.count,
    required this.amberAt,
    required this.redAt,
  });
  final int count, amberAt, redAt;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: const Color(0xFF173D31),
      borderRadius: BorderRadius.circular(24),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'COMPLIANCE OVERVIEW',
          style: TextStyle(
            color: Color(0xFFBFD8C8),
            letterSpacing: 1.2,
            fontWeight: FontWeight.w700,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          count == 0
              ? 'Add your first important date'
              : '$count dates being monitored',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 21,
          ),
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 7,
          children: [
            _Legend(color: const Color(0xFF4FC184), text: '>$amberAt days'),
            _Legend(
              color: const Color(0xFFE2B878),
              text: '${redAt + 1}–$amberAt days',
            ),
            _Legend(color: const Color(0xFFFF7B70), text: '0–$redAt days'),
          ],
        ),
      ],
    ),
  );
}

class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.text});
  final Color color;
  final String text;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: .1),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(text, style: const TextStyle(color: Colors.white, fontSize: 10)),
      ],
    ),
  );
}

class _RoutineTile extends StatelessWidget {
  const _RoutineTile({
    required this.icon,
    required this.title,
    required this.detail,
    required this.onTap,
  });
  final IconData icon;
  final String title, detail;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Card(
    elevation: 0,
    color: const Color(0xFFFBFAF6),
    margin: const EdgeInsets.only(bottom: 9),
    child: ListTile(
      onTap: onTap,
      leading: Icon(icon, color: const Color(0xFF28634A)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: Text(detail),
      trailing: const Icon(Icons.chevron_right_rounded),
    ),
  );
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAdd});
  final VoidCallback onAdd;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(28),
    decoration: BoxDecoration(
      color: const Color(0xFFFBFAF6),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Column(
      children: [
        const Icon(
          Icons.event_available_outlined,
          size: 40,
          color: Color(0xFF28634A),
        ),
        const SizedBox(height: 10),
        const Text(
          'Nothing to monitor yet',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
        ),
        const SizedBox(height: 6),
        const Text(
          'Add medicals, licences, ratings, passports, visas or any personal deadline.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Color(0xFF6C756F)),
        ),
        TextButton.icon(
          onPressed: onAdd,
          icon: const Icon(Icons.add_rounded),
          label: const Text('Add important date'),
        ),
      ],
    ),
  );
}

String _dateText(DateTime value) =>
    '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year}';
String _hour(int value) => '${value.toString().padLeft(2, '0')}:00';
