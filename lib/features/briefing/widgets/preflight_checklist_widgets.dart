part of '../b787_preflight_checklist.dart';

class _StageCard extends StatelessWidget {
  const _StageCard({
    required this.stage,
    required this.completed,
    required this.onChanged,
    required this.input,
  });
  final _ProcedureStage stage;
  final Set<String> completed;
  final void Function(String, bool) onChanged;
  final Widget? input;
  @override
  Widget build(BuildContext context) {
    final done = stage.items
        .where((item) => completed.contains(item.id))
        .length;
    return Card(
      elevation: 0,
      color: const Color(0xFFFBFAF6),
      margin: const EdgeInsets.only(bottom: 10),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        childrenPadding: const EdgeInsets.fromLTRB(8, 0, 8, 14),
        leading: CircleAvatar(
          backgroundColor: done == stage.items.length
              ? const Color(0xFF28634A)
              : const Color(0xFFE9E7DE),
          foregroundColor: done == stage.items.length
              ? Colors.white
              : const Color(0xFF17211B),
          child: done == stage.items.length
              ? const Icon(Icons.check_rounded)
              : Text('$done'),
        ),
        title: Text(
          stage.title,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Text('${stage.reference} · $done/${stage.items.length}'),
        children: [
          ...stage.items.map(
            (item) => CheckboxListTile(
              dense: true,
              value: completed.contains(item.id),
              onChanged: (value) => onChanged(item.id, value ?? false),
              title: Text(
                item.label,
                style: TextStyle(
                  decoration: completed.contains(item.id)
                      ? TextDecoration.lineThrough
                      : null,
                ),
              ),
              subtitle: Text(
                '${item.owner} · ${item.source}',
                style: const TextStyle(fontSize: 11),
              ),
              controlAffinity: ListTileControlAffinity.leading,
            ),
          ),
          ?input,
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
            child: Row(
              children: [
                const Icon(
                  Icons.menu_book_outlined,
                  size: 15,
                  color: Color(0xFF6C756F),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Verify in ${stage.reference} and current company SOP',
                    style: const TextStyle(
                      color: Color(0xFF6C756F),
                      fontSize: 11,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: null,
                  icon: const Icon(Icons.play_circle_outline_rounded, size: 17),
                  label: const Text('Video later'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DataCapture extends StatelessWidget {
  const _DataCapture({required this.children});
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.fromLTRB(12, 6, 12, 0),
    padding: const EdgeInsets.all(13),
    decoration: BoxDecoration(
      color: const Color(0xFFF1EFE8),
      borderRadius: BorderRadius.circular(13),
    ),
    child: Column(children: children),
  );
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({required this.done, required this.total});
  final int done, total;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: const Color(0xFF173D31),
      borderRadius: BorderRadius.circular(18),
    ),
    child: Row(
      children: [
        SizedBox(
          width: 52,
          height: 52,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: total == 0 ? 0 : done / total,
                backgroundColor: const Color(0xFF46675C),
                color: const Color(0xFFE2B878),
                strokeWidth: 6,
              ),
              Text(
                '$done',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'PREFLIGHT PROGRESS',
                style: TextStyle(
                  color: Color(0xFFBFD8C8),
                  fontSize: 10,
                  letterSpacing: 1,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$done of $total checks complete',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _ManualNotice extends StatelessWidget {
  const _ManualNotice();
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(13),
    decoration: BoxDecoration(
      color: const Color(0xFFFFE9D2),
      borderRadius: BorderRadius.circular(13),
    ),
    child: const Text(
      'Study and workflow aid cross-referenced to the attached FCOM and B787-9 Operations Manual Part B, Rev 20 (2 Apr 2026). FCOM and OMB prompts are labelled separately. This is not an approved electronic checklist: verify current revisions and use the AFM, FCOM, QRH, EFB, MEL and company procedures in their prescribed hierarchy.',
      style: TextStyle(
        color: Color(0xFF6E451B),
        fontWeight: FontWeight.w600,
        fontSize: 11,
        height: 1.4,
      ),
    ),
  );
}
