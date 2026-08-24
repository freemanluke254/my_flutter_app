part of '../planning_compliance_page.dart';

class _ItemForm extends StatefulWidget {
  const _ItemForm({
    required this.item,
    required this.title,
    required this.category,
    required this.amberAt,
    required this.redAt,
  });
  final ComplianceItem? item;
  final String? title, category;
  final int amberAt, redAt;
  @override
  State<_ItemForm> createState() => _ItemFormState();
}

class _ItemFormState extends State<_ItemForm> {
  final _key = GlobalKey<FormState>();
  late final TextEditingController _title = TextEditingController(
    text: widget.item?.title ?? widget.title ?? '',
  );
  late final TextEditingController _link = TextEditingController(
    text: widget.item?.link ?? '',
  );
  late final TextEditingController _notes = TextEditingController(
    text: widget.item?.notes ?? '',
  );
  late DateTime _date =
      widget.item?.date ?? DateTime.now().add(const Duration(days: 365));
  late String _category = widget.item?.category ?? widget.category ?? 'Medical';
  late int _amber = widget.item?.amberDays ?? widget.amberAt;
  late int _red = widget.item?.redDays ?? widget.redAt;
  late final Set<int> _reminders = {
    ...?widget.item?.reminders,
    if (widget.item == null) ...[90, 30, 14],
  };
  static const categories = [
    'Medical',
    'Licence',
    'Rating',
    'Passport',
    'Visa',
    'Training',
    'Trip request',
    'Custom',
  ];

  @override
  void dispose() {
    _title.dispose();
    _link.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.fromLTRB(
      20,
      0,
      20,
      MediaQuery.viewInsetsOf(context).bottom + 24,
    ),
    child: Form(
      key: _key,
      child: ListView(
        shrinkWrap: true,
        children: [
          Text(
            widget.item == null
                ? 'Add date or deadline'
                : 'Edit date or deadline',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 18),
          TextFormField(
            controller: _title,
            decoration: const InputDecoration(
              labelText: 'Title',
              hintText: 'Class 1 medical',
              border: OutlineInputBorder(),
            ),
            validator: (value) =>
                value == null || value.trim().isEmpty ? 'Enter a title' : null,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _category,
            decoration: const InputDecoration(
              labelText: 'Category',
              border: OutlineInputBorder(),
            ),
            items: categories
                .map(
                  (value) => DropdownMenuItem(value: value, child: Text(value)),
                )
                .toList(),
            onChanged: (value) => setState(() => _category = value!),
          ),
          const SizedBox(height: 12),
          ListTile(
            onTap: _pickDate,
            shape: RoundedRectangleBorder(
              side: const BorderSide(color: Color(0xFF777777)),
              borderRadius: BorderRadius.circular(4),
            ),
            leading: const Icon(Icons.event_outlined),
            title: const Text('Expiry or deadline'),
            subtitle: Text(_dateText(_date)),
            trailing: const Icon(Icons.edit_calendar_outlined),
          ),
          const SizedBox(height: 16),
          const Text(
            'Status colours',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  initialValue: '$_amber',
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Amber at days',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) => _amber = int.tryParse(value) ?? _amber,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextFormField(
                  initialValue: '$_red',
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Red at days',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) => _red = int.tryParse(value) ?? _red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Remind me before',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 7),
          Wrap(
            spacing: 7,
            children: [180, 90, 30, 14, 7, 1]
                .map(
                  (days) => FilterChip(
                    label: Text('$days days'),
                    selected: _reminders.contains(days),
                    onSelected: (selected) => setState(
                      () => selected
                          ? _reminders.add(days)
                          : _reminders.remove(days),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _link,
            keyboardType: TextInputType.url,
            decoration: const InputDecoration(
              labelText: 'Website or booking link',
              hintText: 'https://…',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _notes,
            minLines: 2,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Notes',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 22),
          SizedBox(
            height: 52,
            child: FilledButton(
              onPressed: _save,
              child: Text(
                widget.item == null ? 'Add reminder' : 'Save changes',
              ),
            ),
          ),
        ],
      ),
    ),
  );

  Future<void> _pickDate() async {
    final value = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (value != null) setState(() => _date = value);
  }

  void _save() {
    if (!(_key.currentState?.validate() ?? false)) return;
    if (_red >= _amber) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Red days must be lower than amber days.'),
        ),
      );
      return;
    }
    Navigator.pop(
      context,
      ComplianceItem(
        id: widget.item?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
        title: _title.text.trim(),
        category: _category,
        date: _date,
        amberDays: _amber,
        redDays: _red,
        reminders: _reminders.toList()..sort((a, b) => b.compareTo(a)),
        link: _link.text.trim(),
        notes: _notes.text.trim(),
      ),
    );
  }
}
