import 'package:flutter/material.dart';

import '../widgets/briefing_tab_widgets.dart';

class BriefingWeatherTab extends StatelessWidget {
  const BriefingWeatherTab({super.key});

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.fromLTRB(20, 18, 20, 110),
    children: const [
      BriefingOperationalWarning(),
      SizedBox(height: 14),
      BriefingSectionCard(
        title: 'EGLL · METAR',
        icon: Icons.cloud_outlined,
        status: 'Sample',
        children: [
          SelectableText('EGLL 241350Z AUTO 24012KT 9999 SCT025 19/11 Q1018 NOSIG'),
          SizedBox(height: 8),
          Text(
            'Observed 13:50Z · planned departure 16:05 local',
            style: TextStyle(color: Color(0xFF6C756F)),
          ),
        ],
      ),
      BriefingSectionCard(
        title: 'EGLL · TAF',
        icon: Icons.timeline_rounded,
        status: 'Sample',
        children: [
          SelectableText(
            'TAF EGLL 241100Z 2412/2518 24012KT 9999 SCT025 TEMPO 2414/2420 6000 SHRA BKN018',
          ),
        ],
      ),
      BriefingSectionCard(
        title: 'KLAS · METAR / TAF',
        icon: Icons.wb_sunny_outlined,
        status: 'Sample',
        children: [
          SelectableText('KLAS 241456Z 19008KT 10SM FEW120 37/06 A2990'),
          SizedBox(height: 8),
          Text(
            'Forecast remains VMC around planned arrival. Confirm with approved source.',
            style: TextStyle(color: Color(0xFF6C756F)),
          ),
        ],
      ),
    ],
  );
}
