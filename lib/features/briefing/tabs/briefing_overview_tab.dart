import 'package:flutter/material.dart';

import '../models/briefing_flight.dart';
import '../office_briefing_panel.dart';
import '../widgets/briefing_tab_widgets.dart';

class BriefingOverviewTab extends StatelessWidget {
  const BriefingOverviewTab({super.key, required this.flight});
  final BriefingFlight flight;

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.fromLTRB(20, 18, 20, 110),
    children: [
      OfficeBriefingPanel(reportTime: flight.reportTime),
      const BriefingOperationalWarning(),
      const SizedBox(height: 14),
      const BriefingSectionCard(
        title: 'Operational flight plan',
        icon: Icons.route_outlined,
        status: 'Not uploaded',
        children: [
          Text(
            'Upload the company OFP to populate route, alternates, fuel figures and planned times.',
          ),
          SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: null,
            icon: Icon(Icons.upload_file_rounded),
            label: Text('Connect document import'),
          ),
        ],
      ),
      const BriefingSectionCard(
        title: 'Route snapshot',
        icon: Icons.public_rounded,
        status: 'Planned',
        children: [
          Text('LHR · CPT · DOGAL · 55N020W · 54N030W · 52N040W · NICSO · LAS'),
          SizedBox(height: 8),
          Text(
            'Tracks and oceanic clearance must be checked against the current operational briefing.',
            style: TextStyle(color: Color(0xFF6C756F), fontSize: 12),
          ),
        ],
      ),
      const BriefingSectionCard(
        title: 'Fuel plan',
        icon: Icons.local_gas_station_outlined,
        status: 'Review',
        children: [
          BriefingDataRow(label: 'Trip fuel', value: '48.2 t'),
          BriefingDataRow(label: 'Contingency', value: '2.4 t'),
          BriefingDataRow(label: 'Alternate', value: '3.1 t'),
          BriefingDataRow(label: 'Final reserve', value: '2.7 t'),
          BriefingDataRow(label: 'Block fuel', value: '58.9 t'),
        ],
      ),
    ],
  );
}
