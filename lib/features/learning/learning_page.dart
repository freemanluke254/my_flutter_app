part of '../../app.dart';

class LearningPage extends StatefulWidget {
  const LearningPage({super.key});

  @override
  State<LearningPage> createState() => _LearningPageState();
}

class _LearningPageState extends State<LearningPage> {
  static const _definitions = [
    _Definition(
      term: 'Neuroplasticity',
      category: 'Mind',
      meaning:
          'The brain’s ability to reorganize itself by forming new neural connections.',
      example: 'Practising a new skill regularly encourages neuroplasticity.',
    ),
    _Definition(
      term: 'Compound interest',
      category: 'Money',
      meaning:
          'Interest calculated on both the initial amount and the interest already accumulated.',
      example:
          'Time makes compound interest especially powerful for long-term saving.',
    ),
    _Definition(
      term: 'Ecosystem',
      category: 'Science',
      meaning:
          'A community of organisms interacting with each other and their environment.',
      example:
          'A pond is an ecosystem containing plants, animals, water, and soil.',
    ),
    _Definition(
      term: 'Opportunity cost',
      category: 'Ideas',
      meaning:
          'The value of the best alternative you give up when making a choice.',
      example:
          'The opportunity cost of studying tonight might be missing a film.',
    ),
  ];

  String _query = '';
  String _category = 'All';

  @override
  Widget build(BuildContext context) {
    final results = _definitions.where((item) {
      final matchesCategory = _category == 'All' || item.category == _category;
      final search = _query.toLowerCase();
      final matchesSearch =
          item.term.toLowerCase().contains(search) ||
          item.meaning.toLowerCase().contains(search);
      return matchesCategory && matchesSearch;
    }).toList();

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 110),
          sliver: SliverList.list(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'LEARN SOMETHING NEW',
                          style: Theme.of(context).textTheme.labelMedium
                              ?.copyWith(
                                letterSpacing: 1.4,
                                color: const Color(0xFF6C756F),
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Your learning library',
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                  IconButton.filledTonal(
                    tooltip: 'Saved definitions',
                    onPressed: () {},
                    icon: const Icon(Icons.bookmark_outline_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              TextField(
                onChanged: (value) => setState(() => _query = value),
                decoration: InputDecoration(
                  hintText: 'Search a word or idea',
                  prefixIcon: const Icon(Icons.search_rounded),
                  filled: true,
                  fillColor: const Color(0xFFFBFAF6),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: ['All', 'Mind', 'Science', 'Money', 'Ideas']
                      .map(
                        (category) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(category),
                            selected: _category == category,
                            onSelected: (_) =>
                                setState(() => _category = category),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: const Color(0xFF28634A),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'WORD OF THE DAY',
                      style: TextStyle(
                        color: Color(0xFFBFD8C8),
                        letterSpacing: 1.3,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Curiosity',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 27,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'A strong desire to know or learn something.',
                      style: TextStyle(
                        color: Color(0xFFE4F0E7),
                        height: 1.45,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Text(
                    'Definitions',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${results.length} topics',
                    style: const TextStyle(color: Color(0xFF6C756F)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (results.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 42),
                  child: Column(
                    children: [
                      Icon(
                        Icons.search_off_rounded,
                        size: 42,
                        color: Color(0xFF8A908B),
                      ),
                      SizedBox(height: 12),
                      Text(
                        'No definitions found',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                )
              else
                ...results.map((item) => _DefinitionCard(definition: item)),
            ],
          ),
        ),
      ],
    );
  }
}

class _Definition {
  const _Definition({
    required this.term,
    required this.category,
    required this.meaning,
    required this.example,
  });
  final String term;
  final String category;
  final String meaning;
  final String example;
}

class _DefinitionCard extends StatelessWidget {
  const _DefinitionCard({required this.definition});
  final _Definition definition;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: const Color(0xFFFBFAF6),
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
        childrenPadding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: const Color(0xFFDCEADD),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.lightbulb_outline_rounded,
            color: Color(0xFF28634A),
          ),
        ),
        title: Text(
          definition.term,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(
          definition.category,
          style: const TextStyle(color: Color(0xFF6C756F)),
        ),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              definition.meaning,
              style: const TextStyle(height: 1.5),
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Example: ${definition.example}',
              style: const TextStyle(
                color: Color(0xFF6C756F),
                height: 1.45,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
