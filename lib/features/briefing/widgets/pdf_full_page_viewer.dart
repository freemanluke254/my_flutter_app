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
  late final Future<Uint8List?> _page = _load();

  Future<Uint8List?> _load() async {
    try {
      return await _channel.invokeMethod<Uint8List>('renderPdfPage', {
        'path': widget.path,
        'page': 0,
        'width': 2400.0,
        'height': 1800.0,
      });
    } on Object {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<Uint8List?>(
    future: _page,
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }
      final bytes = snapshot.data;
      if (bytes == null) {
        return const Center(
          child: Text('The full PDF page could not be opened.'),
        );
      }
      return InteractiveViewer(
        minScale: 0.5,
        maxScale: 6,
        boundaryMargin: const EdgeInsets.all(80),
        child: Center(child: Image.memory(bytes, fit: BoxFit.contain)),
      );
    },
  );
}
