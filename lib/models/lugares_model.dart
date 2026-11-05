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
    required this.categoriaId
  });

    // Converter dados json (da api) para Map com validação de nulos
  factory LugaresModel.fromJson(Map json) {
    return LugaresModel(
      id: json['id'],
      nome: json['nome'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      descricao: json['descricao'],
      // Verifica se 'categoria' não é nulo antes de tentar acessar o 'nome'
      categoria: json['categoria'] != null ? json['categoria']['nome'] : '',
      categoriaId: json['categoriaId']
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
      'categoriaId': categoriaId
    };
  }
}
