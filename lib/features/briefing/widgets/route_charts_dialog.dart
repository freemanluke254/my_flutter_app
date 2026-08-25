import 'package:flutter/material.dart';

import '../models/flight_briefing.dart';
import 'pdf_full_page_viewer.dart';

class RouteChartsDialog extends StatefulWidget {
  const RouteChartsDialog({required this.document, super.key});
  final BriefingDocument document;

  @override
  State<RouteChartsDialog> createState() => _RouteChartsDialogState();
}

class _RouteChartsDialogState extends State<RouteChartsDialog> {
  var _index = 0;

  List<({String name, String? path})> get _charts => List.generate(
    widget.document.fileCount,
    (index) => (
      name: index < widget.document.fileNames.length
          ? widget.document.fileNames[index]
          : 'Route chart ${index + 1}',
      path: index < widget.document.filePaths.length
          ? widget.document.filePaths[index]
          : null,
    ),
  );

  @override
  Widget build(BuildContext context) {
    final charts = _charts;
    final chart = charts[_index];
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1100, maxHeight: 820),
        child: Column(
          children: [
            ListTile(
              leading: const Icon(Icons.route_rounded),
              title: Text('Route chart ${_index + 1} of ${charts.length}'),
              subtitle: Text(chart.name),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: 'Previous route chart',
                    onPressed: _index == 0
                        ? null
                        : () => setState(() => _index--),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  ),
                  IconButton(
                    tooltip: 'Next route chart',
                    onPressed: _index == charts.length - 1
                        ? null
                        : () => setState(() => _index++),
                    icon: const Icon(Icons.arrow_forward_ios_rounded),
                  ),
                  IconButton(
                    tooltip: 'Close',
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: chart.path == null
                  ? const Center(
                      child: Text('Reupload this route chart to open it.'),
                    )
                  : PdfFullPageViewer(
                      key: ValueKey(chart.path),
                      path: chart.path!,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
