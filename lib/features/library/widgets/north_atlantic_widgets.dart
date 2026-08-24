part of '../north_atlantic_review_page.dart';

class _ModuleCard extends StatelessWidget {
  const _ModuleCard({
    required this.number,
    required this.module,
    required this.reviewed,
    required this.onReviewed,
  });
  final int number;
  final _NatModule module;
  final bool reviewed;
  final ValueChanged<bool> onReviewed;

  @override
  Widget build(BuildContext context) => Card(
    elevation: 0,
    color: const Color(0xFFFBFAF6),
    margin: const EdgeInsets.only(bottom: 9),
    child: ExpansionTile(
      leading: CircleAvatar(
        backgroundColor: reviewed
            ? const Color(0xFF28634A)
            : const Color(0xFFDCEADD),
        foregroundColor: reviewed ? Colors.white : const Color(0xFF28634A),
        child: reviewed ? const Icon(Icons.check_rounded) : Text('$number'),
      ),
      title: Text(
        module.title,
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
      subtitle: Text(module.purpose),
      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      children: [
        ...module.points.map(
          (point) => Padding(
            padding: const EdgeInsets.only(bottom: 9),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 3),
                  child: Icon(Icons.arrow_right_rounded, size: 18),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(point, style: const TextStyle(height: 1.4)),
                ),
              ],
            ),
          ),
        ),
        const Divider(height: 24),
        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Combined notes by source',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
        const SizedBox(height: 8),
        ...module.sourceNotes.map(
          (note) => Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 7),
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: const Color(0xFFF1EFE8),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  note.$1,
                  style: const TextStyle(
                    color: Color(0xFF28634A),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(note.$2, style: const TextStyle(height: 1.4)),
              ],
            ),
          ),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(11),
          decoration: BoxDecoration(
            color: const Color(0xFFE4EEE7),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Text(
            'Review question: ${module.question}',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Source trail: ${module.source}',
            style: const TextStyle(color: Color(0xFF6C756F), fontSize: 11),
          ),
        ),
        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          value: reviewed,
          title: const Text('Reviewed against current controlled material'),
          onChanged: (value) => onReviewed(value ?? false),
        ),
      ],
    ),
  );
}

class _Progress extends StatelessWidget {
  const _Progress({required this.reviewed, required this.total});
  final int reviewed, total;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: const Color(0xFF173D31),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Row(
      children: [
        const Icon(Icons.public_rounded, color: Colors.white),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            '$reviewed of $total modules reviewed',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        SizedBox(
          width: 70,
          child: LinearProgressIndicator(
            value: total == 0 ? 0 : reviewed / total,
            color: const Color(0xFFE2B878),
            backgroundColor: const Color(0xFF46675C),
          ),
        ),
      ],
    ),
  );
}

class _NatSafetyNotice extends StatelessWidget {
  const _NatSafetyNotice();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(13),
    decoration: BoxDecoration(
      color: const Color(0xFFFFE9D2),
      borderRadius: BorderRadius.circular(13),
    ),
    child: const Text(
      'Study aid only. NAT procedures, contingency values, offsets, frequencies and datalink requirements change. For a flight, use the current NAT manual, company OMC/OMB, OFP, NOTAMs, clearance and approved EFB procedures.',
      style: TextStyle(
        color: Color(0xFF6E451B),
        fontWeight: FontWeight.w600,
        fontSize: 11,
        height: 1.4,
      ),
    ),
  );
}

class _SourceCoverage extends StatelessWidget {
  const _SourceCoverage();

  @override
  Widget build(BuildContext context) => ExpansionTile(
    tilePadding: const EdgeInsets.symmetric(horizontal: 12),
    collapsedBackgroundColor: const Color(0xFFE4EEE7),
    backgroundColor: const Color(0xFFE4EEE7),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
    collapsedShape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(13),
    ),
    title: const Text(
      'Sources combined in this guide',
      style: TextStyle(fontWeight: FontWeight.w700),
    ),
    subtitle: const Text('Tap to view coverage and precedence'),
    childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
    children: const [
      _CoverageRow(
        source: 'NAT Operations and Airspace Manual',
        role: 'Regional operating framework and procedures',
      ),
      _CoverageRow(
        source: 'OMC Navigation + NAT HLA revisions',
        role: 'Company route, equipment and operating application',
      ),
      _CoverageRow(
        source: 'B787 FCOM',
        role: 'Aircraft-specific FMC, navigation and communication operation',
      ),
      _CoverageRow(
        source: 'OMA and B787 OMB',
        role:
            'Company policy, fuel, ETOPS, briefing and type-specific procedures',
      ),
      _CoverageRow(
        source: 'ICAO Doc 4444',
        role: 'ATC framework, clearances and applicable contingency context',
      ),
      SizedBox(height: 8),
      Text(
        'Apply the current company manual hierarchy and the latest operational instruction. A newer revision or flight-specific instruction can supersede this study summary.',
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
      ),
    ],
  );
}

class _CoverageRow extends StatelessWidget {
  const _CoverageRow({required this.source, required this.role});
  final String source, role;

  @override
  Widget build(BuildContext context) => ListTile(
    dense: true,
    contentPadding: EdgeInsets.zero,
    leading: const Icon(Icons.check_circle_outline_rounded, size: 18),
    title: Text(source, style: const TextStyle(fontWeight: FontWeight.w700)),
    subtitle: Text(role),
  );
}
