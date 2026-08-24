import 'package:flutter/material.dart';

class OperationsLibraryPage extends StatefulWidget {
  const OperationsLibraryPage({super.key});

  @override
  State<OperationsLibraryPage> createState() => _OperationsLibraryPageState();
}

class _OperationsLibraryPageState extends State<OperationsLibraryPage> {
  String _query = '';
  String _category = 'All';

  static const _categories = [
    'All',
    'Airports',
    'Aircraft',
    'Flight operations',
    'Navigation',
    'ATC',
    'Contingencies',
    'Training',
  ];

  static const _documents = <_LibraryDocument>[
    _LibraryDocument('B787 FCOM', 'Aircraft', '2,074 pages', 'FCOM'),
    _LibraryDocument(
      'B787-9 Operations Manual Part B',
      'Aircraft',
      'Rev 20 · 2 Apr 2026',
      'OMB',
    ),
    _LibraryDocument(
      'Operations Manual Part A — General',
      'Flight operations',
      '632 pages',
      'OMA',
    ),
    _LibraryDocument(
      'Part C — Area & Aerodrome Self-Briefing',
      'Airports',
      '2020 file · currency check required',
      'OMC Area',
    ),
    _LibraryDocument(
      'Part C — Navigation',
      'Navigation',
      '2024 file · duplicate copy removed from index',
      'OMC Nav',
    ),
    _LibraryDocument(
      'North Atlantic Operations and Airspace Manual',
      'Navigation',
      '149 pages',
      'NAT Doc',
    ),
    _LibraryDocument(
      'NAT HLA OMC Revisions',
      'Navigation',
      'Revision supplement',
      'NAT Rev',
    ),
    _LibraryDocument(
      'ICAO Doc 4444 — PANS-ATM',
      'ATC',
      '464 pages · edition currency check required',
      'ICAO 4444',
    ),
    _LibraryDocument(
      'Baghdad FIR disruption — contingency planning',
      'Contingencies',
      'Dated 27 Jan 2026 · verify still active',
      'BAG FIR',
    ),
    _LibraryDocument(
      'Operations Manual Part D — Training',
      'Training',
      '344 pages',
      'OMD',
    ),
  ];

  static const _entries = <_LibraryEntry>[
    _LibraryEntry(
      'Normal flight workflow',
      'Aircraft',
      'Preflight through secure: amplified procedures, crew duties, briefings and standard calls.',
      'FCOM NP.11 and NP.21 · OMB Chapter 2',
      [
        'preflight',
        'start',
        'taxi',
        'takeoff',
        'climb',
        'cruise',
        'descent',
        'landing',
        'shutdown',
      ],
    ),
    _LibraryEntry(
      '787 limitations',
      'Aircraft',
      'Certified and operator limitations including weights, speeds, weather, systems and runway conditions.',
      'FCOM Limitations · OMB Chapter 1',
      ['wind limits', 'weight', 'speed', 'contaminated runway'],
    ),
    _LibraryEntry(
      '787 systems',
      'Aircraft',
      'Searchable route into air systems, electrical, engines/APU, fire protection, flight controls, fuel and displays.',
      'FCOM Systems Description, Chapters 1–16',
      [
        'fuel system',
        'hydraulic',
        'electrical',
        'air conditioning',
        'pressurisation',
        'eicas',
        'apu',
      ],
    ),
    _LibraryEntry(
      'FMC, navigation and datalink',
      'Aircraft',
      'FMC preflight, take-off/climb, cruise, descent/approach, ADS-B and company/ATC datalink.',
      'FCOM Chapter 11',
      ['fmc', 'acars', 'ads-b', 'rnp', 'navigation database'],
    ),
    _LibraryEntry(
      'Performance and flight planning',
      'Flight operations',
      'Approved performance application, take-off/en-route/landing performance, OFP format and in-flight replanning.',
      'OMB Chapters 4 and 5',
      ['opt', 'rtow', 'landing distance', 'ofp', 'fuel', 'etops'],
    ),
    _LibraryEntry(
      'Fuel policy and in-flight fuel management',
      'Flight operations',
      'Planning fuel structure, monitoring, checks and the operator’s in-flight planning references.',
      'OMA 8.1/8.3 · OMB 5.2 and 5.8',
      [
        'rcf',
        'contingency fuel',
        'final reserve',
        'alternate fuel',
        'minimum fuel',
      ],
    ),
    _LibraryEntry(
      'ETOPS operations',
      'Flight operations',
      'Planning, OFP presentation, entry considerations, diversion support and aircraft-specific in-flight procedures.',
      'OMA 8.5 · OMB 5.4–5.6 · FCOM SP.20',
      ['edto', 'etops', 'equal time point', 'diversion'],
    ),
    _LibraryEntry(
      'MEL/CDL and defects',
      'Flight operations',
      'Operational use of the MEL/CDL, technical-log review and aircraft acceptance workflow.',
      'OMA 8.6 · OMB 2.2–2.3',
      ['mel', 'cdl', 'defect', 'technical log', 'flight acceptance'],
    ),
    _LibraryEntry(
      'Rules of the air and reporting',
      'Flight operations',
      'Operator rules-of-the-air references, occurrence reporting and operational responsibilities.',
      'OMA Chapters 1, 11 and 12',
      ['mor', 'airprox', 'commander', 'occurrence report'],
    ),
    _LibraryEntry(
      'North Atlantic operations',
      'Navigation',
      'NAT HLA equipment, flight planning, oceanic clearance, entry, communications, monitoring and contingencies.',
      'NAT Operations Manual · OMC Nav Ch 3/App 1–2 · FCOM SP.20',
      ['nat hla', 'oceanic', 'pbc', 'cpdlc', 'ads-c', 'selcal'],
    ),
    _LibraryEntry(
      'Performance-based navigation',
      'Navigation',
      'PBN approvals, equipment considerations, RNP/RNAV procedure preparation and database controls.',
      'OMC Nav Chapters 4–5 · OMB 2.2.2.4',
      ['pbn', 'rnav', 'rnp', 'raim', 'gnss', 'database'],
    ),
    _LibraryEntry(
      'En-route, polar and communications',
      'Navigation',
      'En-route airspace procedures, company communications/datalink and polar-flying references.',
      'OMC Nav Chapters 3, 6 and 7',
      ['polar', 'hf', 'datalink', 'en-route', 'airspace'],
    ),
    _LibraryEntry(
      'ATC procedures',
      'ATC',
      'Index into flight plans, clearances, separation, surveillance, coordination, emergencies and contingencies.',
      'ICAO Doc 4444 — PANS-ATM',
      [
        'clearance',
        'separation',
        'ats',
        'flight plan',
        'radar',
        'surveillance',
      ],
    ),
    _LibraryEntry(
      'Communication failure',
      'ATC',
      'Route to applicable ATC, regional and operator lost-communications material.',
      'ICAO Doc 4444 · OMA/OMC regional procedures',
      ['rcom', 'rcf', 'radio failure', 'lost communications', '7600'],
    ),
    _LibraryEntry(
      'Baghdad FIR disruption',
      'Contingencies',
      'Time-sensitive planning notice for disruption affecting the Baghdad FIR. Confirm validity against current company instructions and NOTAMs.',
      'Baghdad FIR contingency document · 27 Jan 2026',
      ['iraq', 'baghdad', 'fir', 'reroute', 'disruption'],
      timeSensitive: true,
    ),
    _LibraryEntry(
      'Abnormal, emergency and diversion index',
      'Contingencies',
      'Find crew-incapacitation, smoke/fire, depressurisation, engine failure, diversion, GPWS, TCAS and windshear references.',
      'OMB Chapter 3 · current QRH and ECL',
      [
        'fire',
        'smoke',
        'decompression',
        'engine failure',
        'tcas',
        'windshear',
        'diversion',
      ],
      controlledOnly: true,
    ),
    _LibraryEntry(
      'Area briefings',
      'Airports',
      'Africa, Europe/Siberia, Middle/Far East, North Atlantic/North America, Polar/North Pacific and South America/Caribbean.',
      'OMC Area Chapter 1',
      [
        'africa',
        'europe',
        'siberia',
        'middle east',
        'north america',
        'polar',
        'caribbean',
      ],
    ),
    _LibraryEntry(
      'Route briefings',
      'Airports',
      'Indexed briefs for LHR–HKG, PVG, JNB, DEL, LOS, Mumbai, Tel Aviv and São Paulo routes.',
      'OMC Area Chapter 3',
      [
        'hong kong',
        'shanghai',
        'johannesburg',
        'delhi',
        'lagos',
        'mumbai',
        'tel aviv',
        'sao paulo',
      ],
    ),
    _LibraryEntry(
      'London Heathrow',
      'Airports',
      'Open the Heathrow aerodrome brief and cross-check current charts, NOTAMs, weather and company notices.',
      'OMC Area Chapter 6 · search LONDON HEATHROW',
      ['lhr', 'egll', 'heathrow', 'london'],
    ),
    _LibraryEntry(
      'Las Vegas — Harry Reid',
      'Airports',
      'Open the Las Vegas aerodrome brief and cross-check current charts, NOTAMs, weather and company notices.',
      'OMC Area Chapter 6 · search LAS VEGAS',
      ['las', 'klas', 'harry reid', 'mccarran', 'vegas'],
    ),
    _LibraryEntry(
      'Aerodrome briefing catalogue',
      'Airports',
      'Search the manual’s global aerodrome listings by city, airport name, ICAO or IATA code.',
      'OMC Area Chapter 6',
      [
        'atlanta',
        'boston',
        'chicago',
        'delhi',
        'doha',
        'dubai',
        'frankfurt',
        'new york',
        'airport brief',
      ],
    ),
    _LibraryEntry(
      'Weather and climatology',
      'Airports',
      'Regional climatology, high-density-altitude operations, cold-temperature error and weather-report references.',
      'OMC Area Chapter 2',
      ['hda', 'cold temperature', 'metar', 'taf', 'cyclone', 'itcz'],
    ),
    _LibraryEntry(
      'Terrain, engine failure and depressurisation',
      'Airports',
      'Route to terrain resolver guidance and engine-failure/depressurisation planning charts.',
      'OMC Area Chapter 4 · OMB 5.6–5.7',
      ['terrain', 'escape route', 'depressurisation', 'engine out'],
    ),
    _LibraryEntry(
      'Training and checking',
      'Training',
      'Training/checking syllabi, procedures, record retention and qualification/revalidation references.',
      'OMD Chapters 1–4',
      ['lpc', 'opc', 'revalidation', 'checking', 'syllabus'],
    ),
    _LibraryEntry(
      'CRM, command and instructor development',
      'Training',
      'CRM, command assessment/course, instructor, line-training and trainer-refresher annexes.',
      'OMD Annexes 1 and 3–15',
      ['crm', 'command', 'ltc', 'tri', 'instructor', 'second officer'],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final needle = _query.trim().toLowerCase();
    final entries = _entries.where((entry) {
      final categoryMatches = _category == 'All' || entry.category == _category;
      return categoryMatches &&
          (needle.isEmpty || entry.searchText.contains(needle));
    }).toList();
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 110),
      children: [
        Text(
          'Operations library',
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 5),
        const Text(
          'Search aircraft, operational, navigation and airport references',
          style: TextStyle(color: Color(0xFF6C756F)),
        ),
        const SizedBox(height: 16),
        TextField(
          onChanged: (value) => setState(() => _query = value),
          decoration: InputDecoration(
            hintText: 'Search Heathrow, RCF, NAT HLA, fuel system…',
            prefixIcon: const Icon(Icons.search_rounded),
            filled: true,
            fillColor: const Color(0xFFFBFAF6),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(17),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 42,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _categories.length,
            separatorBuilder: (_, _) => const SizedBox(width: 7),
            itemBuilder: (context, index) {
              final category = _categories[index];
              return ChoiceChip(
                selected: category == _category,
                label: Text(category),
                onSelected: (_) => setState(() => _category = category),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        const _LibraryNotice(),
        const SizedBox(height: 12),
        ExpansionTile(
          tilePadding: EdgeInsets.zero,
          title: const Text(
            'Document shelf',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          subtitle: Text(
            '${_documents.length} unique source documents indexed',
          ),
          children: _documents
              .map(
                (document) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.picture_as_pdf_outlined),
                  title: Text(document.title),
                  subtitle: Text('${document.category} · ${document.status}'),
                  trailing: Text(
                    document.code,
                    style: const TextStyle(fontSize: 10),
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 8),
        Text(
          '${entries.length} matching sections',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        ...entries.map((entry) => _EntryCard(entry: entry)),
        if (entries.isEmpty)
          const Padding(
            padding: EdgeInsets.all(32),
            child: Center(
              child: Text('No indexed section matches this search.'),
            ),
          ),
      ],
    );
  }
}

class _EntryCard extends StatelessWidget {
  const _EntryCard({required this.entry});
  final _LibraryEntry entry;

  @override
  Widget build(BuildContext context) => Card(
    elevation: 0,
    color: const Color(0xFFFBFAF6),
    margin: const EdgeInsets.only(bottom: 9),
    child: ExpansionTile(
      leading: CircleAvatar(
        backgroundColor: const Color(0xFFDCEADD),
        foregroundColor: const Color(0xFF28634A),
        child: Icon(_iconFor(entry.category), size: 20),
      ),
      title: Text(
        entry.title,
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
      subtitle: Text('${entry.category} · ${entry.source}'),
      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(entry.summary, style: const TextStyle(height: 1.45)),
        ),
        if (entry.timeSensitive || entry.controlledOnly) ...[
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFFFE9D2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              entry.timeSensitive
                  ? 'Time-sensitive: verify the notice remains active using current company instructions and NOTAMs.'
                  : 'Controlled procedure: open the current approved source, QRH or ECL before operational use.',
              style: const TextStyle(
                color: Color(0xFF6E451B),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ],
    ),
  );

  IconData _iconFor(String category) => switch (category) {
    'Airports' => Icons.flight_land_rounded,
    'Aircraft' => Icons.airplanemode_active_rounded,
    'Navigation' => Icons.explore_outlined,
    'ATC' => Icons.record_voice_over_outlined,
    'Contingencies' => Icons.warning_amber_rounded,
    'Training' => Icons.school_outlined,
    _ => Icons.menu_book_outlined,
  };
}

class _LibraryNotice extends StatelessWidget {
  const _LibraryNotice();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(13),
    decoration: BoxDecoration(
      color: const Color(0xFFFFE9D2),
      borderRadius: BorderRadius.circular(13),
    ),
    child: const Text(
      'This library is an index and plain-language orientation layer. It does not reproduce or replace controlled manuals. Always confirm revision status and open the current approved source for operational decisions.',
      style: TextStyle(
        color: Color(0xFF6E451B),
        fontWeight: FontWeight.w600,
        fontSize: 11,
        height: 1.4,
      ),
    ),
  );
}

class _LibraryDocument {
  const _LibraryDocument(this.title, this.category, this.status, this.code);
  final String title, category, status, code;
}

class _LibraryEntry {
  const _LibraryEntry(
    this.title,
    this.category,
    this.summary,
    this.source,
    this.keywords, {
    this.timeSensitive = false,
    this.controlledOnly = false,
  });
  final String title, category, summary, source;
  final List<String> keywords;
  final bool timeSensitive, controlledOnly;

  String get searchText =>
      '$title $category $summary $source ${keywords.join(' ')}'.toLowerCase();
}
