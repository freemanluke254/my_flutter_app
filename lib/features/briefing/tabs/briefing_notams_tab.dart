import 'package:flutter/material.dart';

import '../widgets/briefing_tab_widgets.dart';

class BriefingNotamsTab extends StatelessWidget {
  const BriefingNotamsTab({super.key});

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.fromLTRB(20, 18, 20, 110),
    children: const [
      BriefingOperationalWarning(),
      SizedBox(height: 14),
      BriefingSectionCard(
        title: 'NOTAM briefing',
        icon: Icons.warning_amber_rounded,
        status: 'Provider required',
        children: [
          Text(
            'Connect an approved briefing source to retrieve, filter and acknowledge current NOTAMs for departure, destination, alternates and route.',
          ),
          SizedBox(height: 12),
          BriefingCheckRow(text: 'Departure and SID'),
          BriefingCheckRow(text: 'Destination and STAR'),
          BriefingCheckRow(text: 'Alternates'),
          BriefingCheckRow(text: 'En-route and oceanic'),
        ],
      ),
    ],
  );
}
