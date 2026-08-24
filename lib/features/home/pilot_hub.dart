import 'package:flutter/material.dart';

import '../../flight_logbook_page.dart';

class PilotHub extends StatefulWidget {
  const PilotHub({super.key});

  @override
  State<PilotHub> createState() => _PilotHubState();
}

class _PilotHubState extends State<PilotHub> {
  int _index = 0;
  final List<FlightEntry> _generatedEntries = [];

  static const flight = _FlightDay(
    flightNumber: 'BA275',
    aircraft: 'Boeing 787-9',
    registration: 'G-ZBKM',
    departure: 'LHR',
    departureName: 'London Heathrow',
    departureTime: '16:05',
    arrival: 'LAS',
    arrivalName: 'Harry Reid International',
    arrivalTime: '18:45',
    blockTime: '10h 40m',
    reportTime: '14:20',
    gate: 'T5 · B36',
  );

  @override
  Widget build(BuildContext context) {
    final pages = [
      _TodayFlightPage(
        flight: flight,
        onOpenBriefing: () => setState(() => _index = 1),
        onCompleteFlight: _completeFlight,
      ),
      const _BriefingPage(flight: flight),
      FlightLogbookPage(initialEntries: _generatedEntries),
      const _LearningCentrePage(),
      const _MorePage(),
    ];

    return Scaffold(
      body: SafeArea(
        child: IndexedStack(index: _index, children: pages),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        backgroundColor: const Color(0xFFFBFAF6),
        indicatorColor: const Color(0xFFDCEADD),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.today_outlined),
            selectedIcon: Icon(Icons.today_rounded),
            label: 'Today',
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
            icon: Icon(Icons.school_outlined),
            selectedIcon: Icon(Icons.school_rounded),
            label: 'Learn',
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

  void _completeFlight() {
    final source =
        'Roster ${flight.flightNumber} ${DateTime.now().toIso8601String()}';
    setState(() {
      _generatedEntries.add(
        FlightEntry(
          date: DateTime.now(),
          aircraftType: 'B787-9',
          registration: flight.registration,
          departurePlace: flight.departure,
          departureTime: flight.departureTime,
          arrivalPlace: flight.arrival,
          arrivalTime: flight.arrivalTime,
          totalTime: const Duration(hours: 10, minutes: 40),
          picName: 'Review required',
          pilotFunction: 'Co-pilot',
          singleMultiEngine: 'Multi-engine',
          dayLandings: 0,
          nightLandings: 0,
          nightTime: Duration.zero,
          ifrTime: const Duration(hours: 10, minutes: 40),
          remarks:
              'Prefilled from roster and operational flight plan. Review before signing.',
          source: source,
        ),
      );
      _index = 2;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Draft log entry created — review the operational details.',
        ),
      ),
    );
  }
}

class _TodayFlightPage extends StatelessWidget {
  const _TodayFlightPage({
    required this.flight,
    required this.onOpenBriefing,
    required this.onCompleteFlight,
  });
  final _FlightDay flight;
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
  final _FlightDay flight;
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

class _BriefingPage extends StatelessWidget {
  const _BriefingPage({required this.flight});
  final _FlightDay flight;
  @override
  Widget build(BuildContext context) => DefaultTabController(
    length: 4,
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
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w700),
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
              Tab(text: 'Tools'),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            children: [
              _BriefingOverview(flight: flight),
              const _WeatherBriefing(),
              const _NotamBriefing(),
              const _ToolsGrid(),
            ],
          ),
        ),
      ],
    ),
  );
}

class _BriefingOverview extends StatelessWidget {
  const _BriefingOverview({required this.flight});
  final _FlightDay flight;
  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.fromLTRB(20, 18, 20, 110),
    children: [
      const _OperationalWarning(),
      const SizedBox(height: 14),
      _BriefingSection(
        title: 'Operational flight plan',
        icon: Icons.route_outlined,
        status: 'Not uploaded',
        children: [
          const Text(
            'Upload the company OFP to populate route, alternates, fuel figures and planned times.',
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: null,
            icon: Icon(Icons.upload_file_rounded),
            label: Text('Connect document import'),
          ),
        ],
      ),
      const _BriefingSection(
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
      const _BriefingSection(
        title: 'Fuel plan',
        icon: Icons.local_gas_station_outlined,
        status: 'Review',
        children: [
          _DataRow(label: 'Trip fuel', value: '48.2 t'),
          _DataRow(label: 'Contingency', value: '2.4 t'),
          _DataRow(label: 'Alternate', value: '3.1 t'),
          _DataRow(label: 'Final reserve', value: '2.7 t'),
          _DataRow(label: 'Block fuel', value: '58.9 t'),
        ],
      ),
    ],
  );
}

class _WeatherBriefing extends StatelessWidget {
  const _WeatherBriefing();
  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.fromLTRB(20, 18, 20, 110),
    children: const [
      _OperationalWarning(),
      SizedBox(height: 14),
      _BriefingSection(
        title: 'EGLL · METAR',
        icon: Icons.cloud_outlined,
        status: 'Sample',
        children: [
          SelectableText(
            'EGLL 241350Z AUTO 24012KT 9999 SCT025 19/11 Q1018 NOSIG',
          ),
          SizedBox(height: 8),
          Text(
            'Observed 13:50Z · planned departure 16:05 local',
            style: TextStyle(color: Color(0xFF6C756F)),
          ),
        ],
      ),
      _BriefingSection(
        title: 'EGLL · TAF',
        icon: Icons.timeline_rounded,
        status: 'Sample',
        children: [
          SelectableText(
            'TAF EGLL 241100Z 2412/2518 24012KT 9999 SCT025 TEMPO 2414/2420 6000 SHRA BKN018',
          ),
        ],
      ),
      _BriefingSection(
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

class _NotamBriefing extends StatelessWidget {
  const _NotamBriefing();
  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.fromLTRB(20, 18, 20, 110),
    children: const [
      _OperationalWarning(),
      SizedBox(height: 14),
      _BriefingSection(
        title: 'NOTAM briefing',
        icon: Icons.warning_amber_rounded,
        status: 'Provider required',
        children: [
          Text(
            'Connect an approved briefing source to retrieve, filter and acknowledge current NOTAMs for departure, destination, alternates and route.',
          ),
          SizedBox(height: 12),
          _CheckRow(text: 'Departure and SID'),
          _CheckRow(text: 'Destination and STAR'),
          _CheckRow(text: 'Alternates'),
          _CheckRow(text: 'En-route and oceanic'),
        ],
      ),
    ],
  );
}

class _ToolsGrid extends StatelessWidget {
  const _ToolsGrid();
  @override
  Widget build(BuildContext context) => GridView.count(
    padding: const EdgeInsets.fromLTRB(20, 18, 20, 110),
    crossAxisCount: MediaQuery.sizeOf(context).width > 700 ? 3 : 2,
    mainAxisSpacing: 10,
    crossAxisSpacing: 10,
    childAspectRatio: 1.15,
    children: const [
      _ToolCard(
        icon: Icons.local_gas_station_outlined,
        title: 'Fuel & uplift',
        subtitle: 'Density and conversion',
      ),
      _ToolCard(
        icon: Icons.speed_rounded,
        title: 'Mach / TAS',
        subtitle: 'Speed conversion',
      ),
      _ToolCard(
        icon: Icons.air_rounded,
        title: 'Crosswind',
        subtitle: 'Wind components',
      ),
      _ToolCard(
        icon: Icons.access_time_rounded,
        title: 'Time & distance',
        subtitle: 'ETA calculations',
      ),
      _ToolCard(
        icon: Icons.swap_vert_rounded,
        title: 'Pressure',
        subtitle: 'hPa / inHg',
      ),
      _ToolCard(
        icon: Icons.calculate_outlined,
        title: 'Cold temperature',
        subtitle: 'Altitude correction',
      ),
    ],
  );
}

class _LearningCentrePage extends StatefulWidget {
  const _LearningCentrePage();
  @override
  State<_LearningCentrePage> createState() => _LearningCentrePageState();
}

class _LearningCentrePageState extends State<_LearningCentrePage> {
  String query = '';
  static const topics = [
    (
      'RCF',
      'Reduced contingency fuel',
      'Fuel & Flight Planning',
      'Explains statistical contingency fuel, eligibility, monitoring and operational considerations.',
    ),
    (
      '787 fuel system',
      'Boeing 787 fuel system',
      'Aircraft Systems',
      'Tank arrangement, pumps, transfer logic, indications and non-normal considerations.',
    ),
    (
      'NAT HLA',
      'North Atlantic operations',
      'Operations',
      'Oceanic clearance, datalink, plotting, navigation checks and contingency procedures.',
    ),
    (
      'Memory items',
      '787 memory items',
      'Procedures',
      'Company-controlled quick reference for immediate action procedures.',
    ),
    (
      'ETOPS',
      'Extended diversion time operations',
      'Operations',
      'Planning, entry conditions, critical fuel scenarios and diversion decision support.',
    ),
  ];
  @override
  Widget build(BuildContext context) {
    final filtered = topics
        .where(
          (topic) => '${topic.$1} ${topic.$2} ${topic.$3} ${topic.$4}'
              .toLowerCase()
              .contains(query.toLowerCase()),
        )
        .toList();
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 110),
      children: [
        Text(
          'Knowledge centre',
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        const Text(
          'Aircraft systems, procedures and operational concepts',
          style: TextStyle(color: Color(0xFF6C756F)),
        ),
        const SizedBox(height: 20),
        TextField(
          onChanged: (value) => setState(() => query = value),
          decoration: InputDecoration(
            hintText: 'Search RCF, fuel system, NAT HLA…',
            prefixIcon: const Icon(Icons.search_rounded),
            filled: true,
            fillColor: const Color(0xFFFBFAF6),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(17),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 18),
        const _ControlledContentNotice(),
        const SizedBox(height: 18),
        ...filtered.map(
          (topic) => Card(
            elevation: 0,
            color: const Color(0xFFFBFAF6),
            child: ExpansionTile(
              leading: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFDCEADD),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.school_outlined,
                  color: Color(0xFF28634A),
                ),
              ),
              title: Text(
                topic.$2,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              subtitle: Text('${topic.$1} · ${topic.$3}'),
              childrenPadding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(topic.$4, style: const TextStyle(height: 1.5)),
                ),
                const SizedBox(height: 10),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Connect approved company manuals to display controlled procedures and revision status.',
                    style: TextStyle(color: Color(0xFF6C756F), fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (filtered.isEmpty)
          const Padding(
            padding: EdgeInsets.all(32),
            child: Center(child: Text('No matching learning topic yet.')),
          ),
      ],
    );
  }
}

class _MorePage extends StatelessWidget {
  const _MorePage();
  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.fromLTRB(20, 22, 20, 110),
    children: [
      Text(
        'Explore',
        style: Theme.of(
          context,
        ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
      ),
      const SizedBox(height: 6),
      const Text(
        'Planning, airport knowledge and life downroute',
        style: TextStyle(color: Color(0xFF6C756F)),
      ),
      const SizedBox(height: 20),
      _FeatureTile(
        icon: Icons.calendar_month_outlined,
        title: 'Roster',
        subtitle: 'Import duties and populate your flight day',
        onTap: () => _open(context, const _RosterPage()),
      ),
      _FeatureTile(
        icon: Icons.location_city_outlined,
        title: 'Airport guides',
        subtitle: 'Operational notes, procedures and crew knowledge',
        onTap: () => _open(context, const _AirportGuidePage()),
      ),
      _FeatureTile(
        icon: Icons.local_activity_outlined,
        title: 'Layover guide',
        subtitle: 'Crew-recommended food, sport, shops and downtime',
        onTap: () => _open(context, const _LayoverPage()),
      ),
      _FeatureTile(
        icon: Icons.settings_outlined,
        title: 'Data & integrations',
        subtitle: 'Company roster, weather, NOTAM and document providers',
        onTap: () {},
      ),
    ],
  );
  static void _open(BuildContext context, Widget page) =>
      Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));
}

class _RosterPage extends StatelessWidget {
  const _RosterPage();
  @override
  Widget build(BuildContext context) => _SimpleFeaturePage(
    title: 'Roster',
    subtitle: 'Import a company roster to drive Today and upcoming flights.',
    icon: Icons.calendar_month_outlined,
    action: 'Import roster',
    children: const [
      _BriefingSection(
        title: 'Mon 24 Aug · BA275',
        icon: Icons.flight_takeoff_rounded,
        status: 'Today',
        children: [
          Text('LHR 16:05 → LAS 18:45 · B787-9'),
          Text('Report 14:20 · Block 10h 40m'),
        ],
      ),
      _BriefingSection(
        title: 'Fri 28 Aug · BA274',
        icon: Icons.flight_land_rounded,
        status: 'Upcoming',
        children: [Text('LAS 20:55 → LHR 14:50+1 · B787-9')],
      ),
    ],
  );
}

class _AirportGuidePage extends StatefulWidget {
  const _AirportGuidePage();
  @override
  State<_AirportGuidePage> createState() => _AirportGuidePageState();
}

class _AirportGuidePageState extends State<_AirportGuidePage> {
  String query = '';
  @override
  Widget build(BuildContext context) {
    final airports = const [
      (
        'EGLL · LHR',
        'London Heathrow',
        'Departure sequencing, low visibility, noise procedures and hot spots.',
      ),
      (
        'KLAS · LAS',
        'Harry Reid International',
        'Desert performance, runway configuration, terrain and arrival considerations.',
      ),
    ].where((a) => '${a.$1} ${a.$2}'.toLowerCase().contains(query.toLowerCase()));
    return Scaffold(
      appBar: AppBar(title: const Text('Airport guides')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(
            onChanged: (value) => setState(() => query = value),
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search_rounded),
              hintText: 'Search ICAO, IATA or airport',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          const _ControlledContentNotice(),
          const SizedBox(height: 16),
          ...airports.map(
            (a) => Card(
              elevation: 0,
              child: ExpansionTile(
                title: Text(
                  a.$2,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: Text(a.$1),
                childrenPadding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
                children: [
                  Text(a.$3),
                  const SizedBox(height: 8),
                  const Text(
                    'Official charts, AIP and company pages must remain the controlling sources.',
                    style: TextStyle(color: Color(0xFF6C756F), fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LayoverPage extends StatelessWidget {
  const _LayoverPage();
  @override
  Widget build(BuildContext context) => _SimpleFeaturePage(
    title: 'Las Vegas layover',
    subtitle: 'Suggestions shared by verified crew',
    icon: Icons.local_activity_outlined,
    action: 'Add recommendation',
    children: const [
      _Recommendation(
        title: 'Red Rock Canyon',
        category: 'Outdoors · 4.8',
        detail: 'Early morning trails and scenic drive. Take plenty of water.',
      ),
      _Recommendation(
        title: 'Esther’s Kitchen',
        category: 'Food · 4.7',
        detail: 'Relaxed Italian in the Arts District. Book ahead.',
      ),
      _Recommendation(
        title: 'Las Vegas Ballpark',
        category: 'Sport · 4.6',
        detail: 'Check the Aviators schedule; easy rideshare from the Strip.',
      ),
      _Recommendation(
        title: 'North Premium Outlets',
        category: 'Shopping · 4.4',
        detail: 'Outdoor centre; best visited outside the hottest hours.',
      ),
    ],
  );
}

class _SimpleFeaturePage extends StatelessWidget {
  const _SimpleFeaturePage({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.action,
    required this.children,
  });
  final String title;
  final String subtitle;
  final IconData icon;
  final String action;
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(),
    body: ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
      children: [
        Icon(icon, size: 42, color: const Color(0xFF28634A)),
        const SizedBox(height: 14),
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        Text(subtitle, style: const TextStyle(color: Color(0xFF6C756F))),
        const SizedBox(height: 20),
        FilledButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.upload_rounded),
          label: Text(action),
        ),
        const SizedBox(height: 20),
        ...children,
      ],
    ),
  );
}

class _FlightDay {
  const _FlightDay({
    required this.flightNumber,
    required this.aircraft,
    required this.registration,
    required this.departure,
    required this.departureName,
    required this.departureTime,
    required this.arrival,
    required this.arrivalName,
    required this.arrivalTime,
    required this.blockTime,
    required this.reportTime,
    required this.gate,
  });
  final String flightNumber,
      aircraft,
      registration,
      departure,
      departureName,
      departureTime,
      arrival,
      arrivalName,
      arrivalTime,
      blockTime,
      reportTime,
      gate;
}

class _AirportTime extends StatelessWidget {
  const _AirportTime({
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
          fontSize: 30,
          fontWeight: FontWeight.w800,
        ),
      ),
      Text(
        time,
        style: const TextStyle(color: Color(0xFFE2ECE5), fontSize: 15),
      ),
    ],
  );
}

class _WeatherCard extends StatelessWidget {
  const _WeatherCard({
    required this.airport,
    required this.icon,
    required this.temperature,
    required this.wind,
    required this.detail,
  });
  final String airport, temperature, wind, detail;
  final IconData icon;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(
      color: const Color(0xFFFBFAF6),
      borderRadius: BorderRadius.circular(18),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          airport,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Icon(icon, color: const Color(0xFF28634A)),
            const Spacer(),
            Text(
              temperature,
              style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(wind, style: const TextStyle(fontSize: 12)),
        Text(
          detail,
          style: const TextStyle(color: Color(0xFF6C756F), fontSize: 12),
        ),
      ],
    ),
  );
}

class _TimelineItem extends StatelessWidget {
  const _TimelineItem({
    required this.time,
    required this.title,
    required this.subtitle,
    required this.complete,
  });
  final String time, title, subtitle;
  final bool complete;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(
      children: [
        SizedBox(
          width: 48,
          child: Text(
            time,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        Icon(
          complete ? Icons.check_circle_rounded : Icons.circle_outlined,
          color: complete ? const Color(0xFF28634A) : const Color(0xFFA4AAA5),
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
              Text(
                subtitle,
                style: const TextStyle(color: Color(0xFF6C756F), fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label, required this.color});
  final String label;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: color.withValues(alpha: .12),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      label,
      style: TextStyle(
        color: color,
        fontSize: 10,
        fontWeight: FontWeight.w800,
        letterSpacing: .8,
      ),
    ),
  );
}

class _AdvisoryNote extends StatelessWidget {
  const _AdvisoryNote();
  @override
  Widget build(BuildContext context) => const Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(Icons.info_outline_rounded, size: 15, color: Color(0xFF7B827D)),
      SizedBox(width: 6),
      Expanded(
        child: Text(
          'Forecast preview only · confirm with an approved operational source.',
          style: TextStyle(color: Color(0xFF7B827D), fontSize: 11),
        ),
      ),
    ],
  );
}

class _OperationalWarning extends StatelessWidget {
  const _OperationalWarning();
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: const Color(0xFFFFE9D2),
      borderRadius: BorderRadius.circular(14),
    ),
    child: const Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.warning_amber_rounded, color: Color(0xFF8A551C)),
        SizedBox(width: 10),
        Expanded(
          child: Text(
            'Prototype data — not for operational decision-making. Use approved company and aeronautical sources.',
            style: TextStyle(
              color: Color(0xFF6E451B),
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),
      ],
    ),
  );
}

class _ControlledContentNotice extends StatelessWidget {
  const _ControlledContentNotice();
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: const Color(0xFFECE1CD),
      borderRadius: BorderRadius.circular(14),
    ),
    child: const Text(
      'Training aid only. Aircraft procedures and airport content must show source, operator applicability and revision status before operational use.',
      style: TextStyle(color: Color(0xFF654C31), fontSize: 12, height: 1.4),
    ),
  );
}

class _BriefingSection extends StatelessWidget {
  const _BriefingSection({
    required this.title,
    required this.icon,
    required this.status,
    required this.children,
  });
  final String title, status;
  final IconData icon;
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => Card(
    elevation: 0,
    color: const Color(0xFFFBFAF6),
    margin: const EdgeInsets.only(bottom: 12),
    child: Padding(
      padding: const EdgeInsets.all(17),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF28634A)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
              _StatusPill(
                label: status.toUpperCase(),
                color: const Color(0xFF28634A),
              ),
            ],
          ),
          const Divider(height: 25),
          ...children,
        ],
      ),
    ),
  );
}

class _DataRow extends StatelessWidget {
  const _DataRow({required this.label, required this.value});
  final String label, value;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        Expanded(
          child: Text(label, style: const TextStyle(color: Color(0xFF6C756F))),
        ),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
      ],
    ),
  );
}

class _CheckRow extends StatelessWidget {
  const _CheckRow({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 8),
    child: Row(
      children: [
        const Icon(Icons.circle_outlined, size: 18, color: Color(0xFF6C756F)),
        const SizedBox(width: 9),
        Text(text),
      ],
    ),
  );
}

class _ToolCard extends StatelessWidget {
  const _ToolCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
  final IconData icon;
  final String title, subtitle;
  @override
  Widget build(BuildContext context) => Card(
    elevation: 0,
    color: const Color(0xFFFBFAF6),
    child: InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: const Color(0xFF28634A), size: 28),
            const Spacer(),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 3),
            Text(
              subtitle,
              style: const TextStyle(color: Color(0xFF6C756F), fontSize: 11),
            ),
          ],
        ),
      ),
    ),
  );
}

class _FeatureTile extends StatelessWidget {
  const _FeatureTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
  final IconData icon;
  final String title, subtitle;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Card(
    elevation: 0,
    color: const Color(0xFFFBFAF6),
    margin: const EdgeInsets.only(bottom: 10),
    child: ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: const Color(0xFFDCEADD),
          borderRadius: BorderRadius.circular(13),
        ),
        child: Icon(icon, color: const Color(0xFF28634A)),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right_rounded),
    ),
  );
}

class _Recommendation extends StatelessWidget {
  const _Recommendation({
    required this.title,
    required this.category,
    required this.detail,
  });
  final String title, category, detail;
  @override
  Widget build(BuildContext context) => Card(
    elevation: 0,
    child: ListTile(
      contentPadding: const EdgeInsets.all(14),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 5),
        child: Text('$category\n$detail'),
      ),
      isThreeLine: true,
      trailing: const Icon(Icons.bookmark_border_rounded),
    ),
  );
}
