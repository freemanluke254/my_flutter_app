import 'package:flutter/material.dart';

import '../models/flight_briefing.dart';
import 'pdf_full_page_viewer.dart';

class RouteChartFile {
  const RouteChartFile({required this.name, required this.path});
  final String name;
  final String? path;
}

List<RouteChartFile> orderedRouteChartFiles(BriefingDocument document) {
  final charts = List.generate(
    document.fileCount,
    (index) => RouteChartFile(
      name: index < document.fileNames.length
          ? document.fileNames[index]
          : 'Route chart ${index + 1}',
      path: index < document.filePaths.length
          ? document.filePaths[index]
          : null,
    ),
  );
  charts.sort((a, b) {
    final aOrder = _chartOrder(a.name);
    final bOrder = _chartOrder(b.name);
    final numberComparison = aOrder.$1.compareTo(bOrder.$1);
    if (numberComparison != 0) return numberComparison;
    if (aOrder.$2 != bOrder.$2) return aOrder.$2 ? 1 : -1;
    return a.name.toLowerCase().compareTo(b.name.toLowerCase());
  });
  return charts;
}

(int, bool) _chartOrder(String name) {
  final match = RegExp(
    r'route\s*chart\s*(\d+)',
    caseSensitive: false,
  ).firstMatch(name);
  return (int.tryParse(match?.group(1) ?? '') ?? 1, match != null);
}

class RouteChartsDialog extends StatefulWidget {
  const RouteChartsDialog({required this.document, super.key});
  final BriefingDocument document;

  @override
  State<RouteChartsDialog> createState() => _RouteChartsDialogState();
}

class _RouteChartsDialogState extends State<RouteChartsDialog> {
  var _index = 0;

  List<RouteChartFile> get _charts => orderedRouteChartFiles(widget.document);

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
