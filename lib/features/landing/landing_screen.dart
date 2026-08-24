import 'package:flutter/material.dart';

import '../briefing/briefing_workspace.dart';
import '../calendar/calendar_workspace.dart';
import 'tabs/logbook_tab.dart';
import 'tabs/more_tab.dart';
import 'tabs/today_tab.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key, this.pilotName});
  final String? pilotName;

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final tabs = [
      TodayTab(pilotName: widget.pilotName),
      const CalendarWorkspace(),
      const BriefingWorkspace(),
      const LogbookTab(),
      const MoreTab(),
    ];
    return Scaffold(
      appBar: AppBar(
        leading: _selectedIndex == 1 || _selectedIndex == 2
            ? IconButton(
                onPressed: () => setState(() => _selectedIndex = 0),
                tooltip: 'Back to Pilot App',
                icon: const Icon(Icons.arrow_back_rounded),
              )
            : null,
        title: Text(
          _selectedIndex == 1
              ? 'Calendar'
              : _selectedIndex == 2
              ? 'Flight Briefing'
              : 'Pilot App',
        ),
        actions: [
          IconButton(
            onPressed: () {},
            tooltip: 'Notifications',
            icon: const Icon(Icons.notifications_none_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: IndexedStack(index: _selectedIndex, children: tabs),
      ),
      bottomNavigationBar: _selectedIndex == 1 || _selectedIndex == 2
          ? null
          : NavigationBar(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (index) {
                setState(() => _selectedIndex = index);
              },
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.today_outlined),
                  selectedIcon: Icon(Icons.today_rounded),
                  label: 'Today',
                ),
                NavigationDestination(
                  icon: Icon(Icons.calendar_month_outlined),
                  selectedIcon: Icon(Icons.calendar_month_rounded),
                  label: 'Calendar',
                ),
                NavigationDestination(
                  icon: Icon(Icons.airplane_ticket_outlined),
                  selectedIcon: Icon(Icons.airplane_ticket_rounded),
                  label: 'Briefing',
                ),
                NavigationDestination(
                  icon: Icon(Icons.menu_book_outlined),
                  selectedIcon: Icon(Icons.menu_book_rounded),
                  label: 'Logbook',
                ),
                NavigationDestination(
                  icon: Icon(Icons.grid_view_outlined),
                  selectedIcon: Icon(Icons.grid_view_rounded),
                  label: 'More',
                ),
              ],
            ),
    );
  }
}
