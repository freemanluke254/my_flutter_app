part of '../operational_calculations_page.dart';

class _CalculatorCard extends StatelessWidget {
  const _CalculatorCard({
    required this.title,
    required this.subtitle,
    required this.fields,
    required this.result,
    this.note,
  });
  final String title, subtitle;
  final List<Widget> fields;
  final String? Function() result;
  final String? note;

  @override
  Widget build(BuildContext context) {
    final value = result();
    return Card(
      elevation: 0,
      color: const Color(0xFFFBFAF6),
      margin: const EdgeInsets.only(bottom: 10),
      child: ExpansionTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(subtitle),
        childrenPadding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
        children: [
          ...fields,
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: const Color(0xFFE4EEE7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              value ?? 'Enter values to calculate',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          if (note != null) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                note!,
                style: const TextStyle(
                  color: Color(0xFF6C756F),
                  fontSize: 11,
                  height: 1.35,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(4, 10, 4, 7),
    child: Text(
      text,
      style: const TextStyle(
        color: Color(0xFF28634A),
        fontSize: 10,
        letterSpacing: 1.1,
        fontWeight: FontWeight.w800,
      ),
    ),
  );
}

class _CalculationWarning extends StatelessWidget {
  const _CalculationWarning();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(13),
    decoration: BoxDecoration(
      color: const Color(0xFFFFE9D2),
      borderRadius: BorderRadius.circular(13),
    ),
    child: const Text(
      'Convenience arithmetic only. Do not use these results for certified take-off/landing performance, terrain clearance, fuel-policy compliance or operational decision limits. Cross-check against the approved OFP, FMC, OPT/EFB and company procedures.',
      style: TextStyle(
        color: Color(0xFF6E451B),
        fontWeight: FontWeight.w600,
        fontSize: 11,
        height: 1.4,
      ),
    ),
  );
}
