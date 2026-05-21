class UserModel {
  final String id;
  final String name;
  final String email;
  final String? image;
  final String tipoUsuario; // 'artista' | 'contratante'
  final String? descricao;
  final String? telefone;
  final String? cidade;
  final String? estado;
  final String? generoMusical;
  final double? precoMinimo;
  final double? precoMaximo;
  final List<String>? portfolio;
  final String? spotifyUrl;
  final String? instagramUrl;
  final String? youtubeUrl;
  final double? mediaAvaliacoes;
  final int? totalAvaliacoes;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.image,
    required this.tipoUsuario,
    this.descricao,
    this.telefone,
    this.cidade,
    this.estado,
    this.generoMusical,
    this.precoMinimo,
    this.precoMaximo,
    this.portfolio,
    this.spotifyUrl,
    this.instagramUrl,
    this.youtubeUrl,
    this.mediaAvaliacoes,
    this.totalAvaliacoes,
  });

  bool get isArtist => tipoUsuario == 'artista';

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      image: json['image'] as String?,
      tipoUsuario: json['tipo_usuario'] as String? ?? '',
      descricao: json['descricao'] as String?,
      telefone: json['telefone'] as String?,
      cidade: json['cidade'] as String?,
      estado: json['estado'] as String?,
      generoMusical: json['genero_musical'] as String?,
      precoMinimo: (json['preco_minimo'] as num?)?.toDouble(),
      precoMaximo: (json['preco_maximo'] as num?)?.toDouble(),
      portfolio: (json['portfolio'] as List<dynamic>?)?.cast<String>(),
      spotifyUrl: json['spotify_url'] as String?,
      instagramUrl: json['instagram_url'] as String?,
      youtubeUrl: json['youtube_url'] as String?,
      mediaAvaliacoes: (json['media_avaliacoes'] as num?)?.toDouble(),
      totalAvaliacoes: json['total_avaliacoes'] as int?,
    );
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      if (name.isNotEmpty) 'name': name,
      if (descricao != null) 'descricao': descricao,
      if (telefone != null) 'telefone': telefone,
      if (cidade != null) 'cidade': cidade,
      if (estado != null) 'estado': estado,
      if (generoMusical != null) 'genero_musical': generoMusical,
      if (precoMinimo != null) 'preco_minimo': precoMinimo,
      if (precoMaximo != null) 'preco_maximo': precoMaximo,
    };
  }

  UserModel copyWith({
    String? name,
    String? image,
    String? descricao,
    String? telefone,
    String? cidade,
    String? estado,
    String? generoMusical,
    double? precoMinimo,
    double? precoMaximo,
    String? spotifyUrl,
    String? instagramUrl,
    String? youtubeUrl,
  }) {
    return UserModel(
      id: id,
      name: name ?? this.name,
      email: email,
      image: image ?? this.image,
      tipoUsuario: tipoUsuario,
      descricao: descricao ?? this.descricao,
      telefone: telefone ?? this.telefone,
      cidade: cidade ?? this.cidade,
      estado: estado ?? this.estado,
      generoMusical: generoMusical ?? this.generoMusical,
      precoMinimo: precoMinimo ?? this.precoMinimo,
      precoMaximo: precoMaximo ?? this.precoMaximo,
      portfolio: portfolio,
      spotifyUrl: spotifyUrl ?? this.spotifyUrl,
      instagramUrl: instagramUrl ?? this.instagramUrl,
      youtubeUrl: youtubeUrl ?? this.youtubeUrl,
      mediaAvaliacoes: mediaAvaliacoes,
      totalAvaliacoes: totalAvaliacoes,
    );
  }
}
