// Classe que representa o modelo de dados 'Cidade'.
class Cidade {
  int? codigo;

  String nome;

  String estado;

  // Construtor com campos obrigatórios (exceto codigo)
  Cidade({this.codigo, required this.nome, required this.estado});

  Map<String, dynamic> toMap() {
    return {'codigo': codigo, 'nome': nome, 'estado': estado};
  }

  factory Cidade.fromMap(Map<String, dynamic> map) {
    return Cidade(
      codigo: map['codigo'],
      nome: map['nome'],
      estado: map['estado'],
    );
  }
}
