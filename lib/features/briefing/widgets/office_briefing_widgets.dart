part of '../office_briefing_panel.dart';

class _StageHeader extends StatelessWidget {
  const _StageHeader({
    required this.number,
    required this.title,
    required this.complete,
  });
  final int number;
  final String title;
  final bool complete;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      CircleAvatar(
        radius: 13,
        backgroundColor: complete
            ? const Color(0xFF28634A)
            : const Color(0xFFE9E7DE),
        foregroundColor: complete ? Colors.white : const Color(0xFF17211B),
        child: complete
            ? const Icon(Icons.check_rounded, size: 15)
            : Text(
                '$number',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
      const SizedBox(width: 9),
      Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
      ),
    ],
  );
}

class _DocumentRow extends StatelessWidget {
  const _DocumentRow({required this.document});
  final _PackageDocument document;
  @override
  Widget build(BuildContext context) => ListTile(
    dense: true,
    contentPadding: EdgeInsets.zero,
    leading: const Icon(Icons.description_outlined, color: Color(0xFF28634A)),
    title: Text(document.name, maxLines: 1, overflow: TextOverflow.ellipsis),
    subtitle: Text(
      '${document.category} · ${(document.size / 1024).ceil()} KB',
    ),
    trailing: const Chip(label: Text('CLASSIFIED')),
  );
}

class _BriefPrompt extends StatelessWidget {
  const _BriefPrompt({required this.icon, required this.text});
  final IconData icon;
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF28634A)),
        const SizedBox(width: 9),
        Expanded(child: Text(text)),
      ],
    ),
  );
}

class _SafetyNote extends StatelessWidget {
  const _SafetyNote();
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: const Color(0xFFFFE9D2),
      borderRadius: BorderRadius.circular(12),
    ),
    child: const Text(
      'Verification required: original OFP, weather, NOTAM, technical log and MEL sources remain controlling. Never rely solely on extracted or summarised data.',
      style: TextStyle(
        color: Color(0xFF6E451B),
        fontSize: 11,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}
