import 'dart:convert';
import 'dart:typed_data';
import 'package:web/web.dart' as web;
import 'package:flutter/foundation.dart' show immutable;

// La funzione deve corrispondere alla firma usata nel file base.
// La classe fittizia @immutable è solo per coerenza, se necessario.
@immutable
class DownloadServiceWeb {
  const DownloadServiceWeb();
}

void downloadFileWeb(Uint8List bytes, String fileName) {
  final base64Data = base64Encode(bytes);
  final href = 'data:application/json;base64,$base64Data';

  final anchor = web.HTMLAnchorElement()
    ..href = href
    ..download = fileName;

  anchor.click();
}