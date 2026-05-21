import 'user_model.dart';

class PropostaModel {
  final int idProposta;
  final String idContratante;
  final String idArtista;
  final String titulo;
  final String descricao;
  final String localEvento;
  final String? enderecoCompleto;
  final String? tipoEvento;
  final double? duracaoHoras;
  final int? publicoEsperado;
  final bool? equipamentoIncluso;
  final String? nomeResponsavel;
  final String? telefoneContato;
  final String? observacoes;
  final String dataEvento;
  final String? horaEvento;
  final double valorOferecido;
  final String status; // 'pendente' | 'aceita' | 'recusada' | 'cancelada'
  final String? mensagemResposta;
  final String createdAt;
  final UserModel? contratante;
  final UserModel? artista;

  const PropostaModel({
    required this.idProposta,
    required this.idContratante,
    required this.idArtista,
    required this.titulo,
    required this.descricao,
    required this.localEvento,
    this.enderecoCompleto,
    this.tipoEvento,
    this.duracaoHoras,
    this.publicoEsperado,
    this.equipamentoIncluso,
    this.nomeResponsavel,
    this.telefoneContato,
    this.observacoes,
    required this.dataEvento,
    this.horaEvento,
    required this.valorOferecido,
    required this.status,
    this.mensagemResposta,
    required this.createdAt,
    this.contratante,
    this.artista,
  });

  factory PropostaModel.fromJson(Map<String, dynamic> json) {
    return PropostaModel(
      idProposta: json['id_proposta'] as int,
      idContratante: json['id_contratante'] as String,
      idArtista: json['id_artista'] as String,
      titulo: json['titulo'] as String,
      descricao: json['descricao'] as String,
      localEvento: json['local_evento'] as String,
      enderecoCompleto: json['endereco_completo'] as String?,
      tipoEvento: json['tipo_evento'] as String?,
      duracaoHoras: json['duracao_horas'] != null 
          ? double.tryParse(json['duracao_horas'].toString()) 
          : null,
      publicoEsperado: json['publico_esperado'] as int?,
      equipamentoIncluso: json['equipamento_incluso'] as bool?,
      nomeResponsavel: json['nome_responsavel'] as String?,
      telefoneContato: json['telefone_contato'] as String?,
      observacoes: json['observacoes'] as String?,
      dataEvento: json['data_evento'] as String,
      horaEvento: json['hora_evento'] as String?,
      valorOferecido: double.tryParse(json['valor_oferecido'].toString()) ?? 0.0,
      status: json['status'] as String,
      mensagemResposta: json['mensagem_resposta'] as String?,
      createdAt: json['created_at'] as String,
      contratante: json['contratante'] != null
          ? _parsePartialUser(json['contratante'] as Map<String, dynamic>)
          : null,
      artista: json['artista'] != null
          ? _parsePartialUser(json['artista'] as Map<String, dynamic>)
          : null,
    );
  }

  static UserModel _parsePartialUser(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: '',
      image: json['image'] as String?,
      tipoUsuario: '',
      generoMusical: json['genero_musical'] as String?,
    );
  }
}
