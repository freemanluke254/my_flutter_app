import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PdfPreviewThumbnail extends StatefulWidget {
  const PdfPreviewThumbnail({required this.path, super.key});
  final String? path;

  @override
  State<PdfPreviewThumbnail> createState() => _PdfPreviewThumbnailState();
}

class _PdfPreviewThumbnailState extends State<PdfPreviewThumbnail> {
  static const _channel = MethodChannel('pilot_app/pdf_text');
  late Future<Uint8List?> _preview;

  @override
  void initState() {
    super.initState();
    _preview = _load();
  }

  @override
  void didUpdateWidget(covariant PdfPreviewThumbnail oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.path != widget.path) {
      _preview = _load();
    }
  }

  Future<Uint8List?> _load() async {
    final path = widget.path;
    if (path == null || path.isEmpty) return null;
    try {
      return await _channel.invokeMethod<Uint8List>('renderFirstPage', path);
    } on Object {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<Uint8List?>(
    future: _preview,
    builder: (context, snapshot) {
      final bytes = snapshot.data;
      if (bytes != null) {
        return Image.memory(
          bytes,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        );
      }
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator(strokeWidth: 2));
      }
      return const Center(
        child: Icon(
          Icons.picture_as_pdf_rounded,
          color: Color(0xFFB93B3B),
          size: 42,
        ),
      );
    },
  );
}
