class LugaresModel {
  final int id;
  final String nome;
  final String? categoria;
  final double latitude;
  final double longitude;
  final String? descricao;
  final int categoriaId;

  LugaresModel({
    required this.id,
    required this.nome,
    this.categoria = '',
    required this.latitude,
    required this.longitude,
    this.descricao = '',
    required this.categoriaId,
  });

  // Converter dados json (da api) para Map com validação segura
  factory LugaresModel.fromJson(Map json) {
    return LugaresModel(
      id: json['id'] ?? 0,
      nome: json['nome'] ?? 'Sem nome',
      // Converte int, double ou String com segurança, usando 0.0 se vier null
      latitude: double.tryParse(json['latitude']?.toString() ?? '') ?? 0.0,
      longitude: double.tryParse(json['longitude']?.toString() ?? '') ?? 0.0,
      descricao: json['descricao'] ?? '',
      // Verifica se 'categoria' não é nulo antes de tentar acessar o 'nome'
      categoria: json['categoria'] != null ? json['categoria']['nome'] : '',
      categoriaId: json['categoriaId'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'latitude': latitude,
      'longitude': longitude,
      'categoria': categoria,
      'descricao': descricao,
      'categoriaId': categoriaId,
    };
  }
}
