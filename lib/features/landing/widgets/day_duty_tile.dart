import 'package:flutter/material.dart';

import '../../roster/models/day_duty.dart';

class DayDutyTile extends StatelessWidget {
  const DayDutyTile({super.key, required this.duty, this.onTap});

  final DayDuty duty;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isFlight = duty.type == DutyType.flight;
    return Card(
      elevation: 0,
      color: const Color(0xFF173D31),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2B878),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isFlight ? 'FLIGHT DUTY' : 'STANDBY',
                      style: const TextStyle(
                        color: Color(0xFF17211B),
                        fontSize: 10,
                        letterSpacing: 0.7,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.calendar_month_outlined,
                    color: Color(0xFFBFD8C8),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Text(
                duty.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 14),
              if (isFlight)
                _FlightDutyDetails(duty: duty)
              else
                _StandbyDetails(duty: duty),
              const SizedBox(height: 16),
              const Row(
                children: [
                  Icon(Icons.sync_rounded, size: 15, color: Color(0xFFBFD8C8)),
                  SizedBox(width: 6),
                  Text(
                    'Sample data · roster connection to follow',
                    style: TextStyle(color: Color(0xFFBFD8C8), fontSize: 11),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FlightDutyDetails extends StatelessWidget {
  const _FlightDutyDetails({required this.duty});
  final DayDuty duty;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Row(
        children: [
          _Airport(code: duty.departure!, time: duty.startTime),
          const Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                children: [
                  Expanded(child: Divider(color: Color(0xFF6C8B80))),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 7),
                    child: Icon(
                      Icons.flight_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  Expanded(child: Divider(color: Color(0xFF6C8B80))),
                ],
              ),
            ),
          ),
          _Airport(code: duty.arrival!, time: duty.endTime, alignEnd: true),
        ],
      ),
      const SizedBox(height: 15),
      Row(
        children: [
          _DutyFact(label: 'REPORT', value: duty.reportTime!),
          const SizedBox(width: 24),
          _DutyFact(label: 'AIRCRAFT', value: duty.aircraft ?? 'TBC'),
        ],
      ),
    ],
  );
}

class _StandbyDetails extends StatelessWidget {
  const _StandbyDetails({required this.duty});
  final DayDuty duty;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      _DutyFact(label: 'START', value: duty.startTime),
      const SizedBox(width: 28),
      _DutyFact(label: 'FINISH', value: duty.endTime),
      const SizedBox(width: 28),
      Expanded(
        child: _DutyFact(
          label: 'LOCATION',
          value: duty.standbyLocation ?? 'TBC',
        ),
      ),
    ],
  );
}

class _Airport extends StatelessWidget {
  const _Airport({
    required this.code,
    required this.time,
    this.alignEnd = false,
  });
  final String code, time;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: alignEnd
        ? CrossAxisAlignment.end
        : CrossAxisAlignment.start,
    children: [
      Text(
        code,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 26,
          fontWeight: FontWeight.w800,
        ),
      ),
      Text(time, style: const TextStyle(color: Color(0xFFBFD8C8))),
    ],
  );
}

class _DutyFact extends StatelessWidget {
  const _DutyFact({required this.label, required this.value});
  final String label, value;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(
          color: Color(0xFFBFD8C8),
          fontSize: 9,
          letterSpacing: 0.8,
          fontWeight: FontWeight.w700,
        ),
      ),
      const SizedBox(height: 2),
      Text(
        value,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
    ],
  );
}
