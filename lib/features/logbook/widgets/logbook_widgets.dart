part of '../../../flight_logbook_page.dart';

class _ComplianceBanner extends StatelessWidget {
  const _ComplianceBanner({required this.onTap});
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Material(
    color: const Color(0xFFECE1CD),
    borderRadius: BorderRadius.circular(18),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: const Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.verified_user_outlined, color: Color(0xFF79562E)),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CAA record fields included',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'Review logging rules and required countersignatures',
                    style: TextStyle(color: Color(0xFF6F5A40), fontSize: 12),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded),
          ],
        ),
      ),
    ),
  );
}

class _ComplianceSheet extends StatelessWidget {
  const _ComplianceSheet();
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(24, 4, 24, 32),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'UK CAA record checklist',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 14),
        const Text(
          'The entry form and PDF include the standard FCL.050 / AMC1 FCL.050 flight particulars, totals, operational conditions, pilot function, remarks and endorsements.',
        ),
        const SizedBox(height: 12),
        const Text(
          'SPIC, PICUS, tests, checks and certain revalidation flights require names, signatures or countersignatures in remarks. The pilot remains responsible for correct classification and supporting evidence.',
        ),
        const SizedBox(height: 12),
        const Text(
          'This pilot build has not been approved or certified by the UK CAA. Have the workflow and generated PDF reviewed before relying on it as your sole statutory record.',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('I understand'),
          ),
        ),
      ],
    ),
  );
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label,
    required this.value,
    required this.icon,
  });
  final String label;
  final String value;
  final IconData icon;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: const Color(0xFFFBFAF6),
      borderRadius: BorderRadius.circular(18),
    ),
    child: Row(
      children: [
        Icon(icon, color: const Color(0xFF28634A)),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF6C756F),
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: .7,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _EmptyLogbook extends StatelessWidget {
  const _EmptyLogbook({required this.hasSearch, required this.onAdd});
  final bool hasSearch;
  final VoidCallback onAdd;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 38),
    decoration: BoxDecoration(
      color: const Color(0xFFFBFAF6),
      borderRadius: BorderRadius.circular(22),
    ),
    child: Column(
      children: [
        const Icon(
          Icons.flight_takeoff_rounded,
          size: 42,
          color: Color(0xFF28634A),
        ),
        const SizedBox(height: 12),
        Text(
          hasSearch ? 'No matching flights' : 'Your logbook is ready',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 7),
        Text(
          hasSearch
              ? 'Try another aircraft or airfield.'
              : 'Import an existing CSV or add your first flight.',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Color(0xFF6C756F)),
        ),
        if (!hasSearch) ...[
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add first flight'),
          ),
        ],
      ],
    ),
  );
}

class _FlightEntryCard extends StatelessWidget {
  const _FlightEntryCard({required this.entry, required this.onTap});
  final FlightEntry entry;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Card(
    elevation: 0,
    color: const Color(0xFFFBFAF6),
    margin: const EdgeInsets.only(bottom: 10),
    child: ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        width: 44,
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFFDCEADD),
          borderRadius: BorderRadius.circular(13),
        ),
        child: const Icon(Icons.flight_rounded, color: Color(0xFF28634A)),
      ),
      title: Text(
        '${entry.departurePlace} → ${entry.arrivalPlace}',
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
      subtitle: Text(
        '${_formatDate(entry.date)} · ${entry.aircraftType} · ${entry.registration}',
      ),
      trailing: Text(
        _formatDuration(entry.totalTime),
        style: const TextStyle(fontWeight: FontWeight.w800),
      ),
    ),
  );
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, this.action});
  final String title;
  final Widget? action;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
          ),
        ),
        ?action,
      ],
    ),
  );
}

Duration _parseDuration(String value, {bool allowEmpty = false}) {
  final text = value.trim();
  if (text.isEmpty && allowEmpty) return Duration.zero;
  final parts = text.split(':');
  if (parts.length != 2) throw const FormatException('Time must use HH:MM.');
  final hours = int.tryParse(parts[0]);
  final minutes = int.tryParse(parts[1]);
  if (hours == null ||
      minutes == null ||
      hours < 0 ||
      minutes < 0 ||
      minutes > 59) {
    throw const FormatException('Time must use HH:MM.');
  }
  return Duration(hours: hours, minutes: minutes);
}

String _formatDuration(Duration value) {
  final hours = value.inHours.toString().padLeft(2, '0');
  final minutes = value.inMinutes.remainder(60).toString().padLeft(2, '0');
  return '$hours:$minutes';
}

String _formatDate(DateTime value) {
  final day = value.day.toString().padLeft(2, '0');
  final month = value.month.toString().padLeft(2, '0');
  return '$day/$month/${value.year}';
}
