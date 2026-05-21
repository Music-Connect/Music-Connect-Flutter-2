import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http/browser_client.dart' if (dart.library.io) 'package:http/http.dart';

/// Retorna um cliente HTTP padrão.
/// Na web (Chrome), configuramos withCredentials = true para enviar cookies.
http.Client createHttpClient() {
  if (kIsWeb) {
    final client = http.Client();
    if (client is BrowserClient) {
      client.withCredentials = true;
    }
    return client;
  }
  return http.Client();
}
