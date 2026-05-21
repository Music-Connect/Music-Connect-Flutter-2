import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';
import '../models/user_model.dart';
import 'http_client.dart';

class AuthService {
  static const _cookieKey = 'session_cookie';

  // ── Cookie (só mobile) ────────────────────────────────

  static Future<void> _saveCookie(String cookie) async {
    if (kIsWeb) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cookieKey, cookie);
  }

  static Future<String?> getSavedCookie() async {
    if (kIsWeb) return null;
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_cookieKey);
  }

  static Future<void> clearCookie() async {
    if (kIsWeb) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cookieKey);
  }

  static String? _extractSessionCookie(http.Response response) {
    if (kIsWeb) return null;
    final raw = response.headers['set-cookie'];
    if (raw == null) return null;
    return raw
        .split(RegExp(r',(?=[^ ])'))
        .where((c) => c.contains('better-auth'))
        .map((c) => c.split(';').first.trim())
        .join('; ');
  }

  // ── Headers para cada requisição ──────────────────────

  static Future<Map<String, String>> authHeaders() async {
    final h = <String, String>{'Content-Type': 'application/json'};
    if (!kIsWeb) {
      final cookie = await getSavedCookie();
      if (cookie != null) h['Cookie'] = cookie;
    }
    return h;
  }

  // ── Login ──────────────────────────────────────────────

  static Future<({UserModel user, String cookie})> signIn({
    required String email,
    required String password,
  }) async {
    final client = createHttpClient();
    try {
      final response = await client.post(
        Uri.parse('$kApiBaseUrl/api/auth/sign-in/email'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode != 200) {
        final body = _safeJson(response.body);
        throw Exception(
            body['message'] ?? body['error'] ?? 'Credenciais inválidas');
      }

      final cookie = _extractSessionCookie(response) ?? '';
      if (cookie.isNotEmpty) await _saveCookie(cookie);

      final body = _safeJson(response.body);
      final userData =
          (body['user'] ?? body['data']) as Map<String, dynamic>?;
      if (userData == null) throw Exception('Resposta inválida do servidor');

      return (user: UserModel.fromJson(userData), cookie: cookie);
    } finally {
      client.close();
    }
  }

  static Future<({UserModel user, String cookie})> signUp({
    required String name,
    required String email,
    required String password,
    required String tipoUsuario,
  }) async {
    final client = createHttpClient();
    try {
      final response = await client.post(
        Uri.parse('$kApiBaseUrl/api/auth/sign-up/email'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'tipo_usuario': tipoUsuario,
        }),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Erro ao criar conta');
      }

      return await signIn(email: email, password: password);
    } finally {
      client.close();
    }
  }

  // ── Logout ─────────────────────────────────────────────

  static Future<void> signOut() async {
    final client = createHttpClient();
    try {
      final headers = await authHeaders();
      await client.post(
        Uri.parse('$kApiBaseUrl/api/auth/sign-out'),
        headers: headers,
      );
    } finally {
      client.close();
    }
    await clearCookie();
  }

  // ── Sessão atual ───────────────────────────────────────

  static Future<UserModel?> getSession() async {
    if (!kIsWeb) {
      final cookie = await getSavedCookie();
      if (cookie == null) return null;
    }

    final client = createHttpClient();
    try {
      final headers = await authHeaders();
      final response = await client.get(
        Uri.parse('$kApiBaseUrl/api/auth/session'),
        headers: headers,
      );

      if (response.statusCode != 200) return null;

      final body = _safeJson(response.body);
      final userData = body['user'];
      if (userData == null) return null;

      final newCookie = _extractSessionCookie(response);
      if (newCookie != null && newCookie.isNotEmpty) {
        await _saveCookie(newCookie);
      }

      return UserModel.fromJson(userData as Map<String, dynamic>);
    } finally {
      client.close();
    }
  }

  static Map<String, dynamic> _safeJson(String body) {
    try {
      return jsonDecode(body) as Map<String, dynamic>;
    } catch (_) {
      return {};
    }
  }
}
