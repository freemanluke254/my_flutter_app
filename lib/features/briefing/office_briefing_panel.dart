import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OfficeBriefingPanel extends StatefulWidget {
  const OfficeBriefingPanel({super.key, required this.reportTime});
  final String reportTime;

  @override
  State<OfficeBriefingPanel> createState() => _OfficeBriefingPanelState();
}

class _OfficeBriefingPanelState extends State<OfficeBriefingPanel> {
  static const _settingsKey = 'office_briefing_settings_v1';
  final List<_PackageDocument> _documents = [];
  final _defects = TextEditingController();
  final _mel = TextEditingController();
  final _crewNotes = TextEditingController();
  bool _eCrewEnabled = true;
  int _eCrewLeadMinutes = 5;
  String _eCrewLink = '';
  bool _signedOn = false;
  bool _packageVerified = false;
  bool _technicalReviewed = false;
  bool _cabinBriefed = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _defects.dispose();
    _mel.dispose();
    _crewNotes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final completed = [
      _signedOn,
      _packageVerified,
      _technicalReviewed,
      _cabinBriefed,
    ].where((value) => value).length;
    return Card(
      elevation: 0,
      color: const Color(0xFFFBFAF6),
      margin: const EdgeInsets.only(bottom: 14),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        initiallyExpanded: true,
        tilePadding: const EdgeInsets.symmetric(horizontal: 17, vertical: 7),
        childrenPadding: const EdgeInsets.fromLTRB(17, 0, 17, 18),
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: const Color(0xFFDCEADD),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.assignment_turned_in_outlined,
            color: Color(0xFF28634A),
          ),
        ),
        title: const Text(
          'Report & brief',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Text('$completed of 4 stages complete'),
        children: [
          const _SafetyNote(),
          const SizedBox(height: 14),
          _StageHeader(
            number: 1,
            title: 'Sign on to eCrew',
            complete: _signedOn,
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Sign-on reminder'),
            subtitle: Text(
              'Alert $_eCrewLeadMinutes min before report at ${widget.reportTime}',
            ),
            value: _eCrewEnabled,
            onChanged: (value) {
              setState(() => _eCrewEnabled = value);
              _saveSettings();
            },
          ),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _configureECrew,
                  icon: const Icon(Icons.tune_rounded),
                  label: const Text('Reminder settings'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => setState(() => _signedOn = true),
                  icon: Icon(
                    _signedOn ? Icons.check_rounded : Icons.login_rounded,
                  ),
                  label: Text(_signedOn ? 'Signed on' : 'Open eCrew'),
                ),
              ),
            ],
          ),
          const Divider(height: 32),
          _StageHeader(
            number: 2,
            title: 'Flight package',
            complete: _packageVerified,
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _uploadPackage,
              icon: const Icon(Icons.upload_file_rounded),
              label: Text(
                _documents.isEmpty
                    ? 'Upload flight package'
                    : 'Add more documents',
              ),
            ),
          ),
          if (_documents.isNotEmpty) ...[
            const SizedBox(height: 10),
            ..._documents.map((document) => _DocumentRow(document: document)),
            const SizedBox(height: 8),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: _packageVerified,
              onChanged: (value) =>
                  setState(() => _packageVerified = value ?? false),
              title: const Text(
                'I checked the extracted sections against the original package',
              ),
              subtitle: const Text(
                'Required before briefing data is treated as reviewed',
              ),
            ),
          ],
          const Divider(height: 32),
          _StageHeader(
            number: 3,
            title: 'Aircraft defects & MEL',
            complete: _technicalReviewed,
          ),
          const SizedBox(height: 9),
          TextField(
            controller: _defects,
            minLines: 2,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Open defects',
              hintText: 'Record defect references and operational effects',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _mel,
            minLines: 2,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'MEL/CDL restrictions',
              hintText: 'Reference, restrictions, procedures and expiry',
              border: OutlineInputBorder(),
            ),
          ),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            value: _technicalReviewed,
            onChanged: (value) =>
                setState(() => _technicalReviewed = value ?? false),
            title: const Text('Technical log and current MEL source reviewed'),
          ),
          const Divider(height: 32),
          _StageHeader(
            number: 4,
            title: 'Cabin crew brief',
            complete: _cabinBriefed,
          ),
          const SizedBox(height: 9),
          const _BriefPrompt(
            icon: Icons.schedule_rounded,
            text: 'Expected flight time · 10h 40m',
          ),
          const _BriefPrompt(
            icon: Icons.cloud_outlined,
            text: 'En-route weather and turbulence',
          ),
          const _BriefPrompt(
            icon: Icons.flight_land_rounded,
            text: 'Arrival weather · LAS 37°C · VMC sample',
          ),
          const _BriefPrompt(
            icon: Icons.location_on_outlined,
            text: 'Aircraft location · Terminal 5, stand B36',
          ),
          const _BriefPrompt(
            icon: Icons.build_outlined,
            text: 'Cabin-impacting defects · toilets, Wi-Fi, galley or seats',
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _crewNotes,
            minLines: 2,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Additional cabin brief notes',
              border: OutlineInputBorder(),
            ),
          ),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            value: _cabinBriefed,
            onChanged: (value) =>
                setState(() => _cabinBriefed = value ?? false),
            title: const Text('Cabin crew briefing completed'),
          ),
        ],
      ),
    );
  }

  Future<void> _uploadPackage() async {
    try {
      final files = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['pdf', 'txt', 'csv', 'jpg', 'jpeg', 'png'],
      );
      if (files.isEmpty || !mounted) return;
      final documents = await Future.wait(
        files.map(
          (file) async => _PackageDocument(
            name: file.name,
            category: _categoryFor(file.name),
            size: await file.length(),
          ),
        ),
      );
      if (!mounted) return;
      setState(() {
        _documents.addAll(documents);
        _packageVerified = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${files.length} documents classified. Content extraction provider still required.',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Package upload failed: $error')));
    }
  }

  String _categoryFor(String name) {
    final value = name.toLowerCase();
    if (value.contains('ofp') ||
        value.contains('flightplan') ||
        value.contains('flight_plan')) {
      return 'OFP';
    }
    if (value.contains('notam')) return 'NOTAM';
    if (value.contains('weather') ||
        value.contains('wx') ||
        value.contains('metar') ||
        value.contains('taf')) {
      return 'Weather';
    }
    if (value.contains('mel') ||
        value.contains('defect') ||
        value.contains('tech')) {
      return 'Technical';
    }
    return 'Other';
  }

  Future<void> _loadSettings() async {
    final preferences = await SharedPreferences.getInstance();
    final encoded = preferences.getString(_settingsKey);
    if (encoded == null || !mounted) return;
    final value = jsonDecode(encoded) as Map<String, dynamic>;
    setState(() {
      _eCrewEnabled = value['enabled'] as bool? ?? true;
      _eCrewLeadMinutes = value['leadMinutes'] as int? ?? 5;
      _eCrewLink = value['link'] as String? ?? '';
    });
  }

  Future<void> _saveSettings() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      _settingsKey,
      jsonEncode({
        'enabled': _eCrewEnabled,
        'leadMinutes': _eCrewLeadMinutes,
        'link': _eCrewLink,
      }),
    );
  }

  Future<void> _configureECrew() async {
    final link = TextEditingController(text: _eCrewLink);
    var lead = _eCrewLeadMinutes;
    final save = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (_, update) => AlertDialog(
          title: const Text('eCrew sign-on reminder'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<int>(
                initialValue: lead,
                decoration: const InputDecoration(
                  labelText: 'Remind before report',
                ),
                items: const [0, 5, 10, 15, 20, 30]
                    .map(
                      (value) => DropdownMenuItem(
                        value: value,
                        child: Text('$value minutes'),
                      ),
                    )
                    .toList(),
                onChanged: (value) => update(() => lead = value!),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: link,
                decoration: const InputDecoration(
                  labelText: 'eCrew app or web link',
                  hintText: 'https://…',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
    if (save != true || !mounted) {
      link.dispose();
      return;
    }
    setState(() {
      _eCrewLeadMinutes = lead;
      _eCrewLink = link.text.trim();
    });
    link.dispose();
    await _saveSettings();
  }
}

class _PackageDocument {
  const _PackageDocument({
    required this.name,
    required this.category,
    required this.size,
  });
  final String name, category;
  final int size;
}

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
