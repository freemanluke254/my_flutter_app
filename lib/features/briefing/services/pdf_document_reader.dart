import 'dart:io';

import 'package:flutter/services.dart';

class PdfDocumentReader {
  const PdfDocumentReader();
  static const _channel = MethodChannel('pilot_app/pdf_text');

  Future<String> extractText(String path) async {
    final bytes = await File(path).readAsBytes();
    final text = await _channel.invokeMethod<String>('extractText', bytes);
    if (text == null || text.trim().isEmpty) {
      throw const FormatException('No readable text was found in this PDF.');
    }
    return text.trim();
  }
}
