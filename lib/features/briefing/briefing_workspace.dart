import 'package:flutter/material.dart';

import '../landing/tabs/briefing_tab.dart';
import 'tabs/configuration_tab.dart';
import 'tabs/flight_time_tab.dart';
import 'tabs/interactive_map_tab.dart';

class BriefingWorkspace extends StatefulWidget {
  const BriefingWorkspace({super.key});

  @override
  State<BriefingWorkspace> createState() => _BriefingWorkspaceState();
}

class _BriefingWorkspaceState extends State<BriefingWorkspace> {
  int _selectedIndex = 1;

  static const _tabs = [
    ConfigurationTab(),
    BriefingTab(),
    InteractiveMapTab(),
    FlightTimeTab(),
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.transparent,
    body: IndexedStack(index: _selectedIndex, children: _tabs),
    bottomNavigationBar: NavigationBar(
      selectedIndex: _selectedIndex,
      onDestinationSelected: (index) => setState(() => _selectedIndex = index),
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.tune_outlined),
          selectedIcon: Icon(Icons.tune_rounded),
          label: 'Config',
        ),
        NavigationDestination(
          icon: Icon(Icons.fact_check_outlined),
          selectedIcon: Icon(Icons.fact_check_rounded),
          label: 'Briefing',
        ),
        NavigationDestination(
          icon: Icon(Icons.map_outlined),
          selectedIcon: Icon(Icons.map_rounded),
          label: 'Map',
        ),
        NavigationDestination(
          icon: Icon(Icons.schedule_outlined),
          selectedIcon: Icon(Icons.schedule_rounded),
          label: 'Flight time',
        ),
      ],
    ),
  );
}
