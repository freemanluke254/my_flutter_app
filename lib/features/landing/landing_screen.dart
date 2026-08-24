import 'package:flutter/material.dart';

import '../roster/models/day_duty.dart';
import 'widgets/day_duty_tile.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key, this.pilotName});

  final String? pilotName;

  static const _sampleDuty = DayDuty.flight(
    title: 'BA275',
    reportTime: '14:20',
    startTime: '16:05',
    endTime: '18:45',
    departure: 'LHR',
    arrival: 'LAS',
    aircraft: 'B787-9',
  );

  @override
  Widget build(BuildContext context) {
    final name = pilotName?.trim();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pilot App'),
        actions: [
          IconButton(
            onPressed: () {},
            tooltip: 'Notifications',
            icon: const Icon(Icons.notifications_none_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name == null || name.isEmpty
                      ? 'Welcome aboard'
                      : 'Welcome aboard, $name',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'This is your landing screen. We can build your daily flight overview here next.',
                  style: TextStyle(color: Color(0xFF667069), height: 1.4),
                ),
                const SizedBox(height: 28),
                const Text(
                  'Today’s duty',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 10),
                const DayDutyTile(duty: _sampleDuty),
                const SizedBox(height: 18),
                SizedBox(
                  height: 220,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.flight_takeoff_rounded,
                          size: 72,
                          color: Color(0xFF173D31),
                        ),
                        SizedBox(height: 18),
                        Text(
                          'Ready for your next flight',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
