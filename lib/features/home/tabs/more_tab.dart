part of '../pilot_hub.dart';

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
        icon: Icons.verified_user_outlined,
        title: 'Planning & compliance',
        subtitle: 'Expiry dates, deadlines and personal reminder rules',
        onTap: () => _open(context, const PlanningCompliancePage()),
      ),
      _FeatureTile(
        icon: Icons.commute_rounded,
        title: 'Commute assistant',
        subtitle: 'Leave-time calculations and optional duty reminders',
        onTap: () => _open(context, const CommuteReminderPage()),
      ),
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
