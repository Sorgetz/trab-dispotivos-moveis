class Cliente {
  int? codigo;
  String cpf;
  String nome;
  int idade;
  String dataNascimento;
  String cidadeNascimento;
  String? fotoUrl;

  Cliente({
    this.codigo,
    required this.cpf,
    required this.nome,
    required this.idade,
    required this.dataNascimento,
    required this.cidadeNascimento,
    this.fotoUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'codigo': codigo,
      'cpf': cpf,
      'nome': nome,
      'idade': idade,
      'dataNascimento': dataNascimento,
      'cidadeNascimento': cidadeNascimento,
      'fotoUrl': fotoUrl,
    };
  }

  factory Cliente.fromMap(Map<String, dynamic> map) {
    return Cliente(
      codigo: map.containsKey('id') ? map['id'] : map['codigo'],
      cpf: map['cpf'],
      nome: map['nome'],
      idade: map['idade'],
      dataNascimento: map['dataNascimento'],
      cidadeNascimento: map['cidadeNascimento'],
      fotoUrl: map['fotoUrl'],
    );
  }
}
