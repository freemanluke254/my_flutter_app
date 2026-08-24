part of '../operations_library_page.dart';

class _EntryCard extends StatelessWidget {
  const _EntryCard({required this.entry});
  final _LibraryEntry entry;

  @override
  Widget build(BuildContext context) => Card(
    elevation: 0,
    color: const Color(0xFFFBFAF6),
    margin: const EdgeInsets.only(bottom: 9),
    child: ExpansionTile(
      leading: CircleAvatar(
        backgroundColor: const Color(0xFFDCEADD),
        foregroundColor: const Color(0xFF28634A),
        child: Icon(_iconFor(entry.category), size: 20),
      ),
      title: Text(
        entry.title,
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
      subtitle: Text('${entry.category} · ${entry.source}'),
      trailing: IconButton.filledTonal(
        tooltip: 'Open full briefing',
        onPressed: () => _openBriefing(context),
        icon: const Icon(Icons.arrow_forward_rounded),
      ),
      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(entry.summary, style: const TextStyle(height: 1.45)),
        ),
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.centerLeft,
          child: Wrap(
            spacing: 6,
            runSpacing: 6,
            children: entry.sourceCoverage
                .map(
                  (source) => Chip(
                    avatar: const Icon(Icons.menu_book_outlined, size: 15),
                    label: Text(source),
                    visualDensity: VisualDensity.compact,
                  ),
                )
                .toList(),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: () => _openBriefing(context),
            icon: const Icon(Icons.menu_book_rounded),
            label: const Text('Open full briefing'),
          ),
        ),
        if (entry.timeSensitive || entry.controlledOnly) ...[
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFFFE9D2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              entry.timeSensitive
                  ? 'Time-sensitive: verify the notice remains active using current company instructions and NOTAMs.'
                  : 'Controlled procedure: open the current approved source, QRH or ECL before operational use.',
              style: const TextStyle(
                color: Color(0xFF6E451B),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ],
    ),
  );

  void _openBriefing(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => entry.title == 'North Atlantic operations'
            ? const NorthAtlanticReviewPage()
            : _ConsolidatedBriefingPage(entry: entry),
      ),
    );
  }

  IconData _iconFor(String category) => switch (category) {
    'Airports' => Icons.flight_land_rounded,
    'Aircraft' => Icons.airplanemode_active_rounded,
    'Navigation' => Icons.explore_outlined,
    'ATC' => Icons.record_voice_over_outlined,
    'Contingencies' => Icons.warning_amber_rounded,
    'Training' => Icons.school_outlined,
    _ => Icons.menu_book_outlined,
  };
}

class _ConsolidatedBriefingPage extends StatelessWidget {
  const _ConsolidatedBriefingPage({required this.entry});
  final _LibraryEntry entry;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(entry.title)),
    body: ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      children: [
        Text(
          entry.title,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 6),
        Text(entry.summary, style: const TextStyle(fontSize: 16, height: 1.45)),
        const SizedBox(height: 14),
        const _BriefingSafetyNotice(),
        const SizedBox(height: 14),
        ...entry.briefingSections.map(
          (section) => Card(
            elevation: 0,
            color: const Color(0xFFFBFAF6),
            margin: const EdgeInsets.only(bottom: 10),
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    section.$1,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 9),
                  ...section.$2.map(
                    (point) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(top: 3),
                            child: Icon(Icons.arrow_right_rounded, size: 18),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              point,
                              style: const TextStyle(height: 1.4),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Card(
          elevation: 0,
          color: const Color(0xFFE4EEE7),
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Source trail',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 7),
                Text(entry.source),
                const SizedBox(height: 9),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: entry.sourceCoverage
                      .map((source) => Chip(label: Text(source)))
                      .toList(),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

class _BriefingSafetyNotice extends StatelessWidget {
  const _BriefingSafetyNotice();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(13),
    decoration: BoxDecoration(
      color: const Color(0xFFFFE9D2),
      borderRadius: BorderRadius.circular(13),
    ),
    child: const Text(
      'Consolidated study briefing—not a live operational clearance or approved checklist. Verify current manuals, charts, NOTAMs, aircraft status and flight-specific instructions before use.',
      style: TextStyle(
        color: Color(0xFF6E451B),
        fontWeight: FontWeight.w600,
        fontSize: 11,
        height: 1.4,
      ),
    ),
  );
}

class _LibraryNotice extends StatelessWidget {
  const _LibraryNotice();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(13),
    decoration: BoxDecoration(
      color: const Color(0xFFFFE9D2),
      borderRadius: BorderRadius.circular(13),
    ),
    child: const Text(
      'This library is an index and plain-language orientation layer. It does not reproduce or replace controlled manuals. Always confirm revision status and open the current approved source for operational decisions.',
      style: TextStyle(
        color: Color(0xFF6E451B),
        fontWeight: FontWeight.w600,
        fontSize: 11,
        height: 1.4,
      ),
    ),
  );
}
