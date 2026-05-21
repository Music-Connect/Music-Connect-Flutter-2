import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/app_constants.dart';
import '../models/proposta_model.dart';
import 'auth_service.dart';
import 'http_client.dart';

class PropostaService {
  // ── GET propostas recebidas (artista) ──────────────────
  static Future<List<PropostaModel>> getRecebidas() async {
    final headers = await AuthService.authHeaders();
    final client = createHttpClient();
    try {
      final response = await client.get(
        Uri.parse('$kApiBaseUrl/api/propostas/recebidas'),
        headers: headers,
      );
      return _parseList(response);
    } finally {
      client.close();
    }
  }

  // ── GET propostas enviadas (contratante) ───────────────
  static Future<List<PropostaModel>> getEnviadas() async {
    final headers = await AuthService.authHeaders();
    final client = createHttpClient();
    try {
      final response = await client.get(
        Uri.parse('$kApiBaseUrl/api/propostas/enviadas'),
        headers: headers,
      );
      return _parseList(response);
    } finally {
      client.close();
    }
  }

  // ── GET proposta por ID ────────────────────────────────
  static Future<PropostaModel> getById(int id) async {
    final headers = await AuthService.authHeaders();
    final client = createHttpClient();
    try {
      final response = await client.get(
        Uri.parse('$kApiBaseUrl/api/propostas/$id'),
        headers: headers,
      );
      if (response.statusCode != 200) {
        throw Exception('Proposta não encontrada');
      }
      final body = jsonDecode(response.body);
      return PropostaModel.fromJson(body['data'] as Map<String, dynamic>);
    } finally {
      client.close();
    }
  }

  // ── POST criar proposta ────────────────────────────────
  static Future<PropostaModel> create(Map<String, dynamic> data) async {
    final headers = await AuthService.authHeaders();
    final client = createHttpClient();
    try {
      final response = await client.post(
        Uri.parse('$kApiBaseUrl/api/propostas'),
        headers: headers,
        body: jsonEncode(data),
      );
      if (response.statusCode != 201) {
        final body = jsonDecode(response.body);
        throw Exception(body['error'] ?? 'Erro ao criar proposta');
      }
      final body = jsonDecode(response.body);
      return PropostaModel.fromJson(body['data'] as Map<String, dynamic>);
    } finally {
      client.close();
    }
  }

  // ── PUT atualizar status ───────────────────────────────
  static Future<PropostaModel> updateStatus(int id, String status) async {
    final headers = await AuthService.authHeaders();
    final client = createHttpClient();
    try {
      final response = await client.put(
        Uri.parse('$kApiBaseUrl/api/propostas/$id/status'),
        headers: headers,
        body: jsonEncode({'status': status}),
      );
      if (response.statusCode != 200) {
        final body = jsonDecode(response.body);
        throw Exception(body['error'] ?? 'Erro ao atualizar status');
      }
      final body = jsonDecode(response.body);
      return PropostaModel.fromJson(body['data'] as Map<String, dynamic>);
    } finally {
      client.close();
    }
  }

  // ── DELETE soft delete ─────────────────────────────────
  static Future<void> delete(int id) async {
    final headers = await AuthService.authHeaders();
    final client = createHttpClient();
    try {
      final response = await client.delete(
        Uri.parse('$kApiBaseUrl/api/propostas/$id'),
        headers: headers,
      );
      if (response.statusCode != 200) {
        final body = jsonDecode(response.body);
        throw Exception(body['error'] ?? 'Erro ao excluir proposta');
      }
    } finally {
      client.close();
    }
  }

  // ── Helper ─────────────────────────────────────────────
  static List<PropostaModel> _parseList(http.Response response) {
    if (response.statusCode != 200) {
      throw Exception('Erro ao buscar propostas (${response.statusCode})');
    }
    final body = jsonDecode(response.body);
    final list = body['data'] as List<dynamic>;
    return list
        .map((e) => PropostaModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
