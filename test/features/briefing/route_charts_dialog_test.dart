import 'package:flutter_test/flutter_test.dart';
import 'package:trying_flutter/features/briefing/models/flight_briefing.dart';
import 'package:trying_flutter/features/briefing/widgets/route_charts_dialog.dart';

void main() {
  test('orders the first route chart before numbered continuation charts', () {
    const document = BriefingDocument(
      type: BriefingDocumentType.routeChart,
      title: 'Route charts',
      fileCount: 3,
      fileNames: [
        'VS358_Route Chart 2.pdf',
        'VS358_Route Chart.pdf',
        'VS358_Route Chart 3.pdf',
      ],
      filePaths: ['/chart-2.pdf', '/chart-1.pdf', '/chart-3.pdf'],
    );

    final charts = orderedRouteChartFiles(document);

    expect(charts.map((chart) => chart.path), [
      '/chart-1.pdf',
      '/chart-2.pdf',
      '/chart-3.pdf',
    ]);
  });
}
