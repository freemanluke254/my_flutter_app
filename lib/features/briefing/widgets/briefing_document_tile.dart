import 'package:flutter/material.dart';

import '../models/flight_briefing.dart';

class BriefingDocumentTile extends StatelessWidget {
  const BriefingDocumentTile({
    required this.document,
    required this.onTap,
    super.key,
  });
  final BriefingDocument document;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
    elevation: 0,
    color: Colors.white,
    margin: const EdgeInsets.only(bottom: 10),
    child: ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: const Color(0xFFDCEADD),
        foregroundColor: const Color(0xFF173D31),
        child: Icon(document.icon),
      ),
      title: Text(
        document.title,
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
      subtitle: Text(
        document.fileCount == 1
            ? '1 document'
            : '${document.fileCount} documents',
      ),
      trailing: const Icon(Icons.chevron_right_rounded),
    ),
  );
}
