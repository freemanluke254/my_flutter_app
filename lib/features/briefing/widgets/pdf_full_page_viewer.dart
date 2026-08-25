import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PdfFullPageViewer extends StatefulWidget {
  const PdfFullPageViewer({required this.path, super.key});
  final String path;

  @override
  State<PdfFullPageViewer> createState() => _PdfFullPageViewerState();
}

class _PdfFullPageViewerState extends State<PdfFullPageViewer> {
  static const _channel = MethodChannel('pilot_app/pdf_text');
  late Future<int> _pageCount = _loadPageCount();
  late Future<Uint8List?> _page = _loadPage(0);
  int _pageIndex = 0;

  @override
  void didUpdateWidget(covariant PdfFullPageViewer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.path != widget.path) {
      _pageIndex = 0;
      _pageCount = _loadPageCount();
      _page = _loadPage(0);
    }
  }

  Future<int> _loadPageCount() async {
    try {
      return await _channel.invokeMethod<int>('pdfPageCount', widget.path) ?? 1;
    } on Object {
      return 1;
    }
  }

  Future<Uint8List?> _loadPage(int index) async {
    try {
      return await _channel.invokeMethod<Uint8List>('renderPdfPage', {
        'path': widget.path,
        'page': index,
        'width': 2400.0,
        'height': 1800.0,
      });
    } on Object {
      return null;
    }
  }

  void _showPage(int index) => setState(() {
    _pageIndex = index;
    _page = _loadPage(index);
  });

  @override
  Widget build(BuildContext context) => FutureBuilder<int>(
    future: _pageCount,
    builder: (context, countSnapshot) {
      final count = countSnapshot.data ?? 1;
      return Column(
        children: [
          Expanded(
            child: FutureBuilder<Uint8List?>(
              future: _page,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final bytes = snapshot.data;
                if (bytes == null) {
                  return const Center(
                    child: Text('This PDF page could not be opened.'),
                  );
                }
                return InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 6,
                  boundaryMargin: const EdgeInsets.all(80),
                  child: Center(
                    child: Image.memory(bytes, fit: BoxFit.contain),
                  ),
                );
              },
            ),
          ),
          if (count > 1)
            Container(
              color: const Color(0xFFF0F2F1),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: _pageIndex == 0
                        ? null
                        : () => _showPage(_pageIndex - 1),
                    icon: const Icon(Icons.chevron_left_rounded),
                  ),
                  Text(
                    'Page ${_pageIndex + 1} of $count',
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  IconButton(
                    onPressed: _pageIndex >= count - 1
                        ? null
                        : () => _showPage(_pageIndex + 1),
                    icon: const Icon(Icons.chevron_right_rounded),
                  ),
                ],
              ),
            ),
        ],
      );
    },
  );
}
