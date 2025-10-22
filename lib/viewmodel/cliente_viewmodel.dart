import 'package:flutter/material.dart';
import '../model/cliente.dart';
import '../repository/cliente_repository.dart';

// DTO (Data Transfer Object) para expor dados formatados à View
// A View NÃO deve acessar o Model diretamente
class ClienteDTO {
  final int? codigo;
  final String cpf;
  final String nome;
  final String idade;
  final String dataNascimento;
  final String cidadeNascimento;
  final String subtitulo; // Dado formatado para exibição

  ClienteDTO({
    required this.codigo,
    required this.cpf,
    required this.nome,
    required this.idade,
    required this.dataNascimento,
    required this.cidadeNascimento,
    required this.subtitulo,
  });

  // Converte Model para DTO
  factory ClienteDTO.fromModel(Cliente cliente) {
    return ClienteDTO(
      codigo: cliente.codigo,
      cpf: cliente.cpf,
      nome: cliente.nome,
      idade: cliente.idade.toString(),
      dataNascimento: cliente.dataNascimento,
      cidadeNascimento: cliente.cidadeNascimento,
      subtitulo: 'CPF: ${cliente.cpf} · ${cliente.cidadeNascimento}',
    );
  }

  // Converte DTO para Model
  Cliente toModel() {
    return Cliente(
      codigo: codigo,
      cpf: cpf,
      nome: nome,
      idade: int.tryParse(idade) ?? 0,
      dataNascimento: dataNascimento,
      cidadeNascimento: cidadeNascimento,
    );
  }
}

// ViewModel que expõe dados e ações para as Views (usa ChangeNotifier para MVVM reativo)
class ClienteViewModel extends ChangeNotifier {
  // Repositório de dados (injeção simples via construtor)
  final ClienteRepository _repository;

  // Lista interna de clientes (Model) - privada
  List<Cliente> _clientes = [];

  // Lista pública de DTOs que a View irá observar
  List<ClienteDTO> get clientes =>
      _clientes.map((c) => ClienteDTO.fromModel(c)).toList();

  // Último filtro usado (para manter a lista consistente ao voltar da tela de edição)
  String _ultimoFiltro = '';

  // Construtor recebe o repositório
  ClienteViewModel(this._repository) {
    // Ao construir o ViewModel, carregamos a lista inicial
    loadClientes();
  }

  // Carrega clientes do repositório com filtro opcional
  Future<void> loadClientes([String filtro = '']) async {
    // Guarda o filtro atual
    _ultimoFiltro = filtro;
    // Busca no repositório
    _clientes = await _repository.buscar(filtro: filtro);
    // Notifica listeners (Views que usam Provider/Consumer serão atualizadas)
    notifyListeners();
  }

  // Adiciona um cliente (recebe dados primitivos da View)
  Future<void> adicionarCliente({
    required String cpf,
    required String nome,
    required String idade,
    required String dataNascimento,
    required String cidadeNascimento,
  }) async {
    final cliente = Cliente(
      cpf: cpf,
      nome: nome,
      idade: int.tryParse(idade) ?? 0,
      dataNascimento: dataNascimento,
      cidadeNascimento: cidadeNascimento,
    );
    await _repository.inserir(cliente);
    // Recarrega a lista com o último filtro aplicado
    await loadClientes(_ultimoFiltro);
  }

  // Atualiza um cliente (recebe dados primitivos da View)
  Future<void> editarCliente({
    required int codigo,
    required String cpf,
    required String nome,
    required String idade,
    required String dataNascimento,
    required String cidadeNascimento,
  }) async {
    final cliente = Cliente(
      codigo: codigo,
      cpf: cpf,
      nome: nome,
      idade: int.tryParse(idade) ?? 0,
      dataNascimento: dataNascimento,
      cidadeNascimento: cidadeNascimento,
    );
    await _repository.atualizar(cliente);
    await loadClientes(_ultimoFiltro);
  }

  // Remove um cliente pelo código
  Future<void> removerCliente(int codigo) async {
    await _repository.excluir(codigo);
    await loadClientes(_ultimoFiltro);
  }
}
