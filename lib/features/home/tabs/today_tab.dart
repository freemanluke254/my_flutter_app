part of '../pilot_hub.dart';

class _TodayFlightPage extends StatelessWidget {
  const _TodayFlightPage({
    required this.flight,
    required this.onOpenBriefing,
    required this.onCompleteFlight,
  });
  final BriefingFlight flight;
  final VoidCallback onOpenBriefing;
  final VoidCallback onCompleteFlight;

  @override
  Widget build(BuildContext context) => CustomScrollView(
    slivers: [
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 110),
        sliver: SliverList.list(
          children: [
            Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE2B878),
                    shape: BoxShape.circle,
                  ),
                  child: const Text(
                    'LF',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Good afternoon, Luke',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 17,
                        ),
                      ),
                      Text(
                        'Monday, 24 August',
                        style: TextStyle(
                          color: Color(0xFF6C756F),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton.filledTonal(
                  onPressed: () {},
                  icon: const Icon(Icons.notifications_none_rounded),
                ),
              ],
            ),
            const SizedBox(height: 26),
            Row(
              children: [
                Text(
                  'Today’s operation',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                const _StatusPill(label: 'ON TIME', color: Color(0xFF28634A)),
              ],
            ),
            const SizedBox(height: 14),
            _FlightCard(flight: flight, onBriefing: onOpenBriefing),
            const SizedBox(height: 18),
            CommuteTodayCard(signOn: DateTime(2026, 8, 24, 14, 20)),
            const SizedBox(height: 22),
            Text(
              'Weather at flight time',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            Row(
              children: const [
                Expanded(
                  child: _WeatherCard(
                    airport: 'LHR · 16:00Z',
                    icon: Icons.cloud_outlined,
                    temperature: '19°',
                    wind: '240° / 12 kt',
                    detail: 'SCT 2,500 ft',
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: _WeatherCard(
                    airport: 'LAS · 01:45Z',
                    icon: Icons.wb_sunny_outlined,
                    temperature: '37°',
                    wind: '190° / 8 kt',
                    detail: 'CAVOK',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const _AdvisoryNote(),
            const SizedBox(height: 22),
            Text(
              'Timeline',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            const _TimelineItem(
              time: '14:20',
              title: 'Crew report',
              subtitle: 'Compass Centre · briefing room 4',
              complete: true,
            ),
            const _TimelineItem(
              time: '15:10',
              title: 'Aircraft handover',
              subtitle: 'Stand B36 · G-ZBKM',
              complete: false,
            ),
            const _TimelineItem(
              time: '16:05',
              title: 'Scheduled departure',
              subtitle: 'London Heathrow',
              complete: false,
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: onCompleteFlight,
              icon: const Icon(Icons.task_alt_rounded),
              label: const Text('Flight complete · prepare log entry'),
            ),
          ],
        ),
      ),
    ],
  );
}

class _FlightCard extends StatelessWidget {
  const _FlightCard({required this.flight, required this.onBriefing});
  final BriefingFlight flight;
  final VoidCallback onBriefing;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(22),
    decoration: BoxDecoration(
      color: const Color(0xFF173D31),
      borderRadius: BorderRadius.circular(26),
      boxShadow: const [
        BoxShadow(
          color: Color(0x24173D31),
          blurRadius: 18,
          offset: Offset(0, 10),
        ),
      ],
    ),
    child: Column(
      children: [
        Row(
          children: [
            Text(
              flight.flightNumber,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              flight.aircraft,
              style: const TextStyle(color: Color(0xFFBFD8C8)),
            ),
            const Spacer(),
            Text(
              flight.registration,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            _AirportTime(code: flight.departure, time: flight.departureTime),
            Expanded(
              child: Column(
                children: [
                  const Icon(
                    Icons.flight_takeoff_rounded,
                    color: Color(0xFFE2B878),
                  ),
                  const SizedBox(height: 5),
                  Container(height: 1, color: const Color(0xFF668278)),
                  const SizedBox(height: 5),
                  Text(
                    flight.blockTime,
                    style: const TextStyle(
                      color: Color(0xFFBFD8C8),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            _AirportTime(
              code: flight.arrival,
              time: flight.arrivalTime,
              alignEnd: true,
            ),
          ],
        ),
        const SizedBox(height: 20),
        const Divider(color: Color(0xFF426458)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Text(
                'Report ${flight.reportTime}  ·  ${flight.gate}',
                style: const TextStyle(color: Color(0xFFE2ECE5), fontSize: 13),
              ),
            ),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFE2B878),
                foregroundColor: const Color(0xFF3F2B11),
              ),
              onPressed: onBriefing,
              icon: const Icon(Icons.arrow_forward_rounded, size: 17),
              label: const Text('Briefing'),
            ),
          ],
        ),
      ],
    ),
  );
}
