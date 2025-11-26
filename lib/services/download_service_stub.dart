import 'dart:typed_data';
import 'package:flutter/foundation.dart' show immutable;

// La funzione stub ha la stessa firma ma non fa nulla, 
// o lancia un errore se viene chiamata accidentalmente.
// La funzione non verrà mai chiamata se si usa correttamente kIsWeb.

// La classe fittizia @immutable è solo per coerenza, se necessario.
@immutable
class DownloadServiceNative {
  const DownloadServiceNative();
}

void downloadFileWeb(Uint8List bytes, String fileName) {
  // Non fa nulla o solleva un errore, 
  // perché questa funzione non dovrebbe essere raggiunta su piattaforme non-web.
}