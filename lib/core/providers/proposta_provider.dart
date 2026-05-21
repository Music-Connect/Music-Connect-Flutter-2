import 'package:flutter/foundation.dart';
import '../models/proposta_model.dart';
import '../models/user_model.dart';
import '../services/proposta_service.dart';

class PropostaProvider extends ChangeNotifier {
  List<PropostaModel> _propostas = [];
  bool _loading = false;
  String? _error;

  List<PropostaModel> get propostas => _propostas;
  bool get loading => _loading;
  String? get error => _error;

  // ── Stats computados ───────────────────────────────────
  int get total => _propostas.length;
  int get pendentes => _propostas.where((p) => p.status == 'pendente').length;
  int get aceitas => _propostas.where((p) => p.status == 'aceita').length;
  int get recusadas => _propostas.where((p) => p.status == 'recusada').length;
  int get canceladas => _propostas.where((p) => p.status == 'cancelada').length;

  double get valorTotalAceitas => _propostas
      .where((p) => p.status == 'aceita')
      .fold(0.0, (sum, p) => sum + p.valorOferecido);

  List<PropostaModel> get recentes =>
      _propostas.take(8).toList();

  List<PropostaModel> filtradas(String filtro) {
    if (filtro == 'todas') return _propostas;
    return _propostas.where((p) => p.status == filtro).toList();
  }

  // ── Atividade mensal (últimos 6 meses) ────────────────
  List<MapEntry<String, int>> get atividadeMensal {
    final months = <String, int>{};
    final now = DateTime.now();
    final meses = ['jan', 'fev', 'mar', 'abr', 'mai', 'jun',
                   'jul', 'ago', 'set', 'out', 'nov', 'dez'];

    for (var i = 5; i >= 0; i--) {
      final d = DateTime(now.year, now.month - i, 1);
      final key = meses[d.month - 1];
      months[key] = 0;
    }

    for (final p in _propostas) {
      final d = DateTime.tryParse(p.createdAt);
      if (d == null) continue;
      final diff = (now.year - d.year) * 12 + (now.month - d.month);
      if (diff >= 0 && diff < 6) {
        final key = meses[d.month - 1];
        if (months.containsKey(key)) months[key] = months[key]! + 1;
      }
    }

    return months.entries.toList();
  }

  // ── Carregar propostas ─────────────────────────────────
  Future<void> load(UserModel user) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      if (user.isArtist) {
        _propostas = await PropostaService.getRecebidas();
      } else {
        _propostas = await PropostaService.getEnviadas();
      }
      // Ordenar por mais recente
      _propostas.sort((a, b) =>
          DateTime.parse(b.createdAt).compareTo(DateTime.parse(a.createdAt)));
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // ── Atualizar status localmente ────────────────────────
  Future<void> updateStatus(int id, String status) async {
    try {
      final updated = await PropostaService.updateStatus(id, status);
      final idx = _propostas.indexWhere((p) => p.idProposta == id);
      if (idx != -1) {
        _propostas = List.from(_propostas)..[idx] = updated;
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      rethrow;
    }
  }

  // ── Criar proposta ─────────────────────────────────────
  Future<void> create(Map<String, dynamic> data) async {
    final nova = await PropostaService.create(data);
    _propostas = [nova, ..._propostas];
    notifyListeners();
  }

  // ── Deletar proposta ───────────────────────────────────
  Future<void> deleteProposta(int id) async {
    try {
      await PropostaService.delete(id);
      _propostas.removeWhere((p) => p.idProposta == id);
      notifyListeners();
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      rethrow;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
