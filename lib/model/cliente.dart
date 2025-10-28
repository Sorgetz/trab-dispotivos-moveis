// Classe que representa o modelo de dados 'Cliente'.
class Cliente {
  // A propriedade 'codigo' é a chave primária (autoincrement)
  int? codigo; // pode ser null ao criar um novo cliente

  // CPF do cliente (string para manter zeros à esquerda, separadores, etc.)
  String cpf;

  // Nome do cliente
  String nome;

  // Idade do cliente (inteiro)
  int idade;

  // Data de nascimento em formato String (poderia ser DateTime, aqui usamos String para simplicidade)
  String dataNascimento;

  // Cidade de nascimento
  String cidadeNascimento;

  // Construtor com campos obrigatórios (exceto codigo)
  Cliente({
    this.codigo,
    required this.cpf,
    required this.nome,
    required this.idade,
    required this.dataNascimento,
    required this.cidadeNascimento,
  });

  // Converte o objeto Cliente em Map<String, dynamic> para inserir/atualizar no SQLite
  Map<String, dynamic> toMap() {
    return {
      'codigo': codigo, // pode ser null (SQLite atribuirá autoincrement)
      'cpf': cpf,
      'nome': nome,
      'idade': idade,
      'dataNascimento': dataNascimento,
      'cidadeNascimento': cidadeNascimento,
    };
  }

  // Cria um objeto Cliente a partir de um Map (resultado de uma query no SQLite)
  factory Cliente.fromMap(Map<String, dynamic> map) {
    return Cliente(
      codigo: map.containsKey('id') ? map['id'] : map['codigo'],
      cpf: map['cpf'],
      nome: map['nome'],
      idade: map['idade'],
      dataNascimento: map['dataNascimento'],
      cidadeNascimento: map['cidadeNascimento'],
    );
  }
}
