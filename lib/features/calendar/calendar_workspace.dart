import 'package:flutter/material.dart';

import '../landing/tabs/calendar_tab.dart';
import 'tabs/expiry_dates_tab.dart';
import 'tabs/calendar_settings_tab.dart';
import 'tabs/roster_history_tab.dart';
import 'tabs/roster_upload_tab.dart';

class CalendarWorkspace extends StatefulWidget {
  const CalendarWorkspace({super.key});

  @override
  State<CalendarWorkspace> createState() => _CalendarWorkspaceState();
}

class _CalendarWorkspaceState extends State<CalendarWorkspace> {
  int _selectedIndex = 0;
  int _refreshVersion = 0;

  void _dataChanged() => setState(() => _refreshVersion++);

  @override
  Widget build(BuildContext context) {
    final tabs = [
      CalendarTab(
        refreshVersion: _refreshVersion,
        onUploadRequested: () => setState(() => _selectedIndex = 2),
      ),
      ExpiryDatesTab(onExpiryChanged: _dataChanged),
      RosterUploadTab(onRosterChanged: _dataChanged),
      RosterHistoryTab(
        refreshVersion: _refreshVersion,
        onRosterChanged: _dataChanged,
      ),
      CalendarSettingsTab(onSettingsChanged: _dataChanged),
    ];
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: IndexedStack(index: _selectedIndex, children: tabs),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) =>
            setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.calendar_today_outlined),
            selectedIcon: Icon(Icons.calendar_today_rounded),
            label: 'Current',
          ),
          NavigationDestination(
            icon: Icon(Icons.verified_outlined),
            selectedIcon: Icon(Icons.verified_rounded),
            label: 'Expiry dates',
          ),
          NavigationDestination(
            icon: Icon(Icons.upload_file_outlined),
            selectedIcon: Icon(Icons.upload_file_rounded),
            label: 'Upload',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history_rounded),
            label: 'History',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings_rounded),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
