import 'dart:convert';
import '../constants/app_constants.dart';
import '../models/user_model.dart';
import 'auth_service.dart';
import 'http_client.dart';

class UsuarioService {
  static Future<UserModel> getUsuario(String id) async {
    final headers = await AuthService.authHeaders();
    final client = createHttpClient();
    try {
      final response = await client.get(
        Uri.parse('$kApiBaseUrl/api/usuarios/$id'),
        headers: headers,
      );
      if (response.statusCode != 200) {
        throw Exception('Erro ao buscar usuário');
      }
      final body = jsonDecode(response.body);
      return UserModel.fromJson(body['data'] as Map<String, dynamic>);
    } finally {
      client.close();
    }
  }

  static Future<UserModel> updateUsuario(
    String id,
    Map<String, dynamic> data,
  ) async {
    final headers = await AuthService.authHeaders();
    final client = createHttpClient();
    try {
      final response = await client.put(
        Uri.parse('$kApiBaseUrl/api/usuarios/$id'),
        headers: headers,
        body: jsonEncode(data),
      );
      if (response.statusCode != 200) {
        final body = jsonDecode(response.body);
        throw Exception(body['error'] ?? 'Erro ao atualizar perfil');
      }
      final body = jsonDecode(response.body);
      return UserModel.fromJson(body['data'] as Map<String, dynamic>);
    } finally {
      client.close();
    }
  }

  static Future<List<UserModel>> getArtistas({
    String? genero,
    String? local,
  }) async {
    final headers = await AuthService.authHeaders();
    final params = <String, String>{};
    if (genero != null && genero.isNotEmpty) params['genero'] = genero;
    if (local != null && local.isNotEmpty) params['local'] = local;

    final uri = Uri.parse('$kApiBaseUrl/api/artistas').replace(
      queryParameters: params.isNotEmpty ? params : null,
    );

    final client = createHttpClient();
    try {
      final response = await client.get(uri, headers: headers);
      if (response.statusCode != 200) {
        throw Exception('Erro ao buscar artistas');
      }
      final body = jsonDecode(response.body);
      final list = body['data'] as List<dynamic>;
      return list
          .map((e) => UserModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } finally {
      client.close();
    }
  }
}
