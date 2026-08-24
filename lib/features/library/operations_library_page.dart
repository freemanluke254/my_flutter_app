import 'package:flutter/material.dart';

import 'north_atlantic_review_page.dart';

part 'models/library_models.dart';
part 'data/library_catalog.dart';
part 'widgets/library_widgets.dart';

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

  Widget build(BuildContext context) {
    final needle = _query.trim().toLowerCase();
    final entries = _libraryEntries.where((entry) {
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
            '${_libraryDocuments.length} unique source documents indexed',
          ),
          children: _libraryDocuments
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
