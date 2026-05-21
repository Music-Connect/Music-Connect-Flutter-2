import 'package:flutter/foundation.dart';

// URL base do backend — detecta a plataforma automaticamente:
// • Web / Windows desktop → localhost:3001
// • Android emulator      → 10.0.2.2:3001
// • Device físico         → troque pelo seu IP local (ex: 192.168.1.100:3001)
String get kApiBaseUrl {
  if (kIsWeb) return 'http://localhost:3001';
  if (defaultTargetPlatform == TargetPlatform.windows ||
      defaultTargetPlatform == TargetPlatform.linux ||
      defaultTargetPlatform == TargetPlatform.macOS) {
    return 'http://localhost:3001';
  }
  return 'http://10.0.2.2:3001'; // Android emulator
}

// Rotas da aplicação
const String kRouteLogin = '/login';
const String kRouteDashboard = '/dashboard';
const String kRouteProfile = '/profile';
const String kRouteProposals = '/proposals';

// Status das propostas
const Map<String, String> kStatusLabels = {
  'pendente': 'Pendente',
  'aceita': 'Aceita',
  'recusada': 'Recusada',
  'cancelada': 'Cancelada',
};
