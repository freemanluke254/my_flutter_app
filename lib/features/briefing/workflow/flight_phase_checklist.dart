part of '../b787_operational_workflow.dart';

class _FlightPhaseChecklist extends StatefulWidget {
  const _FlightPhaseChecklist();

  @override
  State<_FlightPhaseChecklist> createState() => _FlightPhaseChecklistState();
}

class _FlightPhaseChecklistState extends State<_FlightPhaseChecklist> {
  final Set<String> _done = {};
  final Set<int> _notApplicable = {};
  int _activePhase = 0;

  int get _total =>
      _flightPhases.fold(0, (sum, phase) => sum + phase.items.length);

  bool _phaseComplete(int index) =>
      _notApplicable.contains(index) ||
      _flightPhases[index].items.every((item) => _done.contains(item.id));

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.fromLTRB(20, 18, 20, 110),
    children: [
      Row(
        children: [
          Expanded(
            child: Text(
              '787-9 flight workflow',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          Text('${_done.length}/$_total'),
          IconButton(
            tooltip: 'Reset workflow',
            onPressed: () => setState(() {
              _done.clear();
              _notApplicable.clear();
              _activePhase = 0;
            }),
            icon: const Icon(Icons.restart_alt_rounded),
          ),
        ],
      ),
      const SizedBox(height: 8),
      const _WorkflowWarning(),
      const SizedBox(height: 12),
      SizedBox(
        height: 48,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: _flightPhases.length,
          separatorBuilder: (_, _) => const SizedBox(width: 7),
          itemBuilder: (context, index) => ChoiceChip(
            selected: index == _activePhase,
            avatar: Icon(
              _phaseComplete(index)
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked_rounded,
              size: 17,
            ),
            label: Text('${index + 1}. ${_flightPhases[index].shortTitle}'),
            onSelected: (_) => setState(() => _activePhase = index),
          ),
        ),
      ),
      const SizedBox(height: 10),
      _phaseCard(context),
    ],
  );

  Widget _phaseCard(BuildContext context) {
    final phase = _flightPhases[_activePhase];
    final complete = _phaseComplete(_activePhase);
    final checked = phase.items.where((item) => _done.contains(item.id)).length;
    return Card(
      elevation: 0,
      color: const Color(0xFFFBFAF6),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 16, 14, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'PHASE ${_activePhase + 1} OF ${_flightPhases.length}',
              style: const TextStyle(
                color: Color(0xFF28634A),
                fontSize: 10,
                letterSpacing: 1,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              phase.title,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 3),
            Text(
              '${phase.source} · $checked/${phase.items.length}',
              style: const TextStyle(color: Color(0xFF6C756F), fontSize: 12),
            ),
            const Divider(height: 24),
            ...phase.items.map(
              (item) => CheckboxListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                value: _done.contains(item.id),
                title: Text(item.label),
                onChanged: _notApplicable.contains(_activePhase)
                    ? null
                    : (value) => setState(
                        () => value == true
                            ? _done.add(item.id)
                            : _done.remove(item.id),
                      ),
              ),
            ),
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(top: 4, bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFE9D2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                phase.gate,
                style: const TextStyle(
                  color: Color(0xFF6E451B),
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
            if (phase.optional)
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: _notApplicable.contains(_activePhase),
                title: const Text('Not applicable to this sector'),
                onChanged: (value) => setState(() {
                  value == true
                      ? _notApplicable.add(_activePhase)
                      : _notApplicable.remove(_activePhase);
                }),
              ),
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: _activePhase == 0
                      ? null
                      : () => setState(() => _activePhase--),
                  icon: const Icon(Icons.arrow_back_rounded),
                  label: const Text('Previous'),
                ),
                const Spacer(),
                FilledButton.icon(
                  onPressed: complete && _activePhase < _flightPhases.length - 1
                      ? () => setState(() => _activePhase++)
                      : null,
                  icon: Icon(
                    _activePhase == _flightPhases.length - 1
                        ? Icons.flag_rounded
                        : Icons.arrow_forward_rounded,
                  ),
                  label: Text(
                    _activePhase == _flightPhases.length - 1
                        ? 'Workflow complete'
                        : 'Complete & continue',
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

class _WorkflowWarning extends StatelessWidget {
  const _WorkflowWarning();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(13),
    decoration: BoxDecoration(
      color: const Color(0xFFFFE9D2),
      borderRadius: BorderRadius.circular(13),
    ),
    child: const Text(
      'Workflow summary derived from the supplied FCOM and Operations Manual Part B. It is a preparation and progress aid, not an approved checklist. Current controlled manuals, EFB checklists and crew procedures always take precedence.',
      style: TextStyle(
        color: Color(0xFF6E451B),
        fontWeight: FontWeight.w600,
        fontSize: 11,
        height: 1.4,
      ),
    ),
  );
}

class _FlightPhase {
  const _FlightPhase({
    required this.title,
    required this.source,
    required this.gate,
    required this.items,
    this.optional = false,
  });
  final String title, source, gate;
  final List<_FlightCheck> items;
  final bool optional;

  String get shortTitle => title.split(' & ').first;
}

class _FlightCheck {
  const _FlightCheck(this.id, this.label);
  final String id, label;
}
