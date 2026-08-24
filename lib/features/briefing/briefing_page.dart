import 'package:flutter/material.dart';

import 'b787_operational_workflow.dart';
import 'models/briefing_flight.dart';
import 'operational_calculations_page.dart';
import 'tabs/briefing_notams_tab.dart';
import 'tabs/briefing_overview_tab.dart';
import 'tabs/briefing_weather_tab.dart';

class BriefingPage extends StatelessWidget {
  const BriefingPage({super.key, required this.flight});
  final BriefingFlight flight;

  @override
  Widget build(BuildContext context) => DefaultTabController(
    length: 5,
    child: Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 14),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${flight.flightNumber} briefing',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${flight.departure} → ${flight.arrival} · ${flight.registration}',
                      style: const TextStyle(color: Color(0xFF6C756F)),
                    ),
                  ],
                ),
              ),
              IconButton.filledTonal(
                onPressed: () {},
                tooltip: 'Upload flight plan',
                icon: const Icon(Icons.upload_file_rounded),
              ),
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Overview'),
              Tab(text: 'Weather'),
              Tab(text: 'NOTAMs'),
              Tab(text: 'Workflow'),
              Tab(text: 'Calculations'),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            children: [
              BriefingOverviewTab(flight: flight),
              const BriefingWeatherTab(),
              const BriefingNotamsTab(),
              const B787OperationalWorkflow(),
              const OperationalCalculationsPage(),
            ],
          ),
        ),
      ],
    ),
  );
}
