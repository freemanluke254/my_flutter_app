import 'package:flutter/material.dart';

import '../models/flight_briefing.dart';
import '../widgets/briefing_document_tile.dart';

class DocumentsTab extends StatelessWidget {
  const DocumentsTab({required this.flight, super.key});
  final FlightBriefing? flight;

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(20),
    children: [
      Text(
        'Documents',
        style: Theme.of(
          context,
        ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
      ),
      const SizedBox(height: 6),
      Text(
        flight == null
            ? 'No active flight package.'
            : '${flight!.flightNumber} source documents',
        style: const TextStyle(color: Color(0xFF667069)),
      ),
      const SizedBox(height: 18),
      if (flight == null || flight!.documents.isEmpty)
        const Card(
          elevation: 0,
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text('Upload flight documents from the Briefing tab.'),
          ),
        )
      else
        ...flight!.documents.map(
          (document) => BriefingDocumentTile(
            document: document,
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${document.title} viewer will open here.'),
              ),
            ),
          ),
        ),
    ],
  );
}
