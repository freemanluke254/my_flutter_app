part of '../../../flight_logbook_page.dart';

class _FlightEntryForm extends StatefulWidget {
  const _FlightEntryForm();
  @override
  State<_FlightEntryForm> createState() => _FlightEntryFormState();
}

class _FlightEntryFormState extends State<_FlightEntryForm> {
  final _formKey = GlobalKey<FormState>();
  final _type = TextEditingController();
  final _registration = TextEditingController();
  final _departure = TextEditingController();
  final _departureTime = TextEditingController();
  final _arrival = TextEditingController();
  final _arrivalTime = TextEditingController();
  final _total = TextEditingController();
  final _pic = TextEditingController();
  final _dayLandings = TextEditingController(text: '1');
  final _nightLandings = TextEditingController(text: '0');
  final _night = TextEditingController(text: '00:00');
  final _ifr = TextEditingController(text: '00:00');
  final _remarks = TextEditingController();
  DateTime _date = DateTime.now();
  String _function = 'PIC';
  String _aircraftClass = 'Single-engine';

  @override
  void dispose() {
    for (final controller in [
      _type,
      _registration,
      _departure,
      _departureTime,
      _arrival,
      _arrivalTime,
      _total,
      _pic,
      _dayLandings,
      _nightLandings,
      _night,
      _ifr,
      _remarks,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        0,
        20,
        MediaQuery.viewInsetsOf(context).bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: ListView(
          shrinkWrap: true,
          children: [
            Text(
              'Add flight entry',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            const Text(
              'Required fields follow UK Part-FCL FCL.050 record structure.',
              style: TextStyle(color: Color(0xFF6C756F)),
            ),
            const SizedBox(height: 22),
            _SectionTitle(
              title: 'Flight',
              action: TextButton.icon(
                onPressed: _pickDate,
                icon: const Icon(Icons.calendar_today_outlined, size: 16),
                label: Text(_formatDate(_date)),
              ),
            ),
            Row(
              children: [
                Expanded(child: _field(_type, 'Aircraft type', 'PA-28')),
                const SizedBox(width: 10),
                Expanded(
                  child: _field(
                    _registration,
                    'Registration',
                    'G-ABCD',
                    capitals: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _field(
                    _departure,
                    'Departure',
                    'EGKB',
                    capitals: true,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(child: _timeField(_departureTime, 'Off blocks')),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _field(_arrival, 'Arrival', 'EGMC', capitals: true),
                ),
                const SizedBox(width: 10),
                Expanded(child: _timeField(_arrivalTime, 'On blocks')),
              ],
            ),
            const SizedBox(height: 12),
            _timeField(_total, 'Total flight time (HH:MM)'),
            const SizedBox(height: 22),
            const _SectionTitle(title: 'Pilot function & conditions'),
            _field(_pic, 'Pilot-in-command name', 'Full name'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _function,
                    decoration: const InputDecoration(
                      labelText: 'Function',
                      border: OutlineInputBorder(),
                    ),
                    items:
                        [
                              'PIC',
                              'Co-pilot',
                              'Dual',
                              'Instructor',
                              'PICUS',
                              'SPIC',
                            ]
                            .map(
                              (value) => DropdownMenuItem(
                                value: value,
                                child: Text(value),
                              ),
                            )
                            .toList(),
                    onChanged: (value) => _function = value!,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _aircraftClass,
                    decoration: const InputDecoration(
                      labelText: 'Class',
                      border: OutlineInputBorder(),
                    ),
                    items: ['Single-engine', 'Multi-engine']
                        .map(
                          (value) => DropdownMenuItem(
                            value: value,
                            child: Text(value),
                          ),
                        )
                        .toList(),
                    onChanged: (value) => _aircraftClass = value!,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _numberField(_dayLandings, 'Landings day')),
                const SizedBox(width: 10),
                Expanded(child: _numberField(_nightLandings, 'Landings night')),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _timeField(_night, 'Night time')),
                const SizedBox(width: 10),
                Expanded(child: _timeField(_ifr, 'IFR time')),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _remarks,
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Remarks and endorsements',
                hintText:
                    'Tests, checks, instructor/PIC countersignature details…',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 52,
              child: FilledButton(
                onPressed: _save,
                child: const Text('Save flight entry'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  TextFormField _field(
    TextEditingController controller,
    String label,
    String hint, {
    bool capitals = false,
  }) => TextFormField(
    controller: controller,
    textCapitalization: capitals
        ? TextCapitalization.characters
        : TextCapitalization.words,
    decoration: InputDecoration(
      labelText: label,
      hintText: hint,
      border: const OutlineInputBorder(),
    ),
    validator: (value) =>
        value == null || value.trim().isEmpty ? 'Required' : null,
  );

  TextFormField _timeField(TextEditingController controller, String label) =>
      TextFormField(
        controller: controller,
        keyboardType: TextInputType.datetime,
        decoration: InputDecoration(
          labelText: label,
          hintText: 'HH:MM',
          border: const OutlineInputBorder(),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) return 'Required';
          try {
            _parseDuration(value);
            return null;
          } catch (_) {
            return 'Use HH:MM';
          }
        },
      );

  TextFormField _numberField(TextEditingController controller, String label) =>
      TextFormField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (value) =>
            int.tryParse(value ?? '') == null ? 'Number' : null,
      );

  Future<void> _pickDate() async {
    final selected = await showDatePicker(
      context: context,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      initialDate: _date,
    );
    if (selected != null) setState(() => _date = selected);
  }

  void _save() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    Navigator.pop(
      context,
      FlightEntry(
        date: _date,
        aircraftType: _type.text.trim(),
        registration: _registration.text.trim().toUpperCase(),
        departurePlace: _departure.text.trim().toUpperCase(),
        departureTime: _departureTime.text.trim(),
        arrivalPlace: _arrival.text.trim().toUpperCase(),
        arrivalTime: _arrivalTime.text.trim(),
        totalTime: _parseDuration(_total.text),
        picName: _pic.text.trim(),
        pilotFunction: _function,
        singleMultiEngine: _aircraftClass,
        dayLandings: int.parse(_dayLandings.text),
        nightLandings: int.parse(_nightLandings.text),
        nightTime: _parseDuration(_night.text),
        ifrTime: _parseDuration(_ifr.text),
        remarks: _remarks.text.trim(),
        source: 'Entered in app · ${DateTime.now().toIso8601String()}',
      ),
    );
  }
}
