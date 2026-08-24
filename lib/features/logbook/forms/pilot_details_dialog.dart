part of '../../../flight_logbook_page.dart';

class _PilotDetailsDialog extends StatefulWidget {
  const _PilotDetailsDialog();
  @override
  State<_PilotDetailsDialog> createState() => _PilotDetailsDialogState();
}

class _PilotDetailsDialogState extends State<_PilotDetailsDialog> {
  final _key = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _reference = TextEditingController();
  final _address = TextEditingController();
  bool _certified = false;

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Sign your export'),
    content: Form(
      key: _key,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'UK CAA electronic submissions should identify the owner and be electronically signed. Printed copies may be hand signed.',
            ),
            const SizedBox(height: 16),
            _requiredField(_name, 'Full legal name'),
            const SizedBox(height: 12),
            _requiredField(_reference, 'CAA reference number'),
            const SizedBox(height: 12),
            _requiredField(_address, 'Address'),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: _certified,
              onChanged: (value) => setState(() => _certified = value ?? false),
              title: const Text(
                'I certify this is a true record of my flying experience.',
              ),
            ),
          ],
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      FilledButton(
        onPressed: _certified ? _continue : null,
        child: const Text('Open print preview'),
      ),
    ],
  );

  TextFormField _requiredField(
    TextEditingController controller,
    String label,
  ) => TextFormField(
    controller: controller,
    decoration: InputDecoration(
      labelText: label,
      border: const OutlineInputBorder(),
    ),
    validator: (value) =>
        value == null || value.trim().isEmpty ? 'Required' : null,
  );

  void _continue() {
    if (!(_key.currentState?.validate() ?? false)) return;
    final now = DateTime.now();
    Navigator.pop(
      context,
      _PilotDetails(
        name: _name.text.trim(),
        caaReference: _reference.text.trim(),
        address: _address.text.trim(),
        signatureName: _name.text.trim(),
        signatureDate: _formatDate(now),
      ),
    );
  }
}

class _PilotDetails {
  const _PilotDetails({
    required this.name,
    required this.caaReference,
    required this.address,
    required this.signatureName,
    required this.signatureDate,
  });
  final String name;
  final String caaReference;
  final String address;
  final String signatureName;
  final String signatureDate;
}
