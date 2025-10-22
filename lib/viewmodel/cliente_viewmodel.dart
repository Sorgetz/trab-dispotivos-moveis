import 'package:exdb/repository/local/local_cliente_repository.dart';
import 'package:exdb/repository/repository_factory.dart';
import 'package:flutter/material.dart';
import '../model/cliente.dart';
import '../repository/cliente_repository_interface.dart';
import '../utils/preferences_helper.dart';

class ClienteDTO {
  final int? codigo;
  final String cpf;
  final String nome;
  final String idade;
  final String dataNascimento;
  final String cidadeNascimento;
  final String subtitulo;

  ClienteDTO({
    required this.codigo,
    required this.cpf,
    required this.nome,
    required this.idade,
    required this.dataNascimento,
    required this.cidadeNascimento,
    required this.subtitulo,
  });

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

class ClienteViewModel extends ChangeNotifier {
  late IClienteRepository _repository;
  List<Cliente> _clientes = [];
  String _ultimoFiltro = '';

  bool _isUsingFirebase = false;
  bool get isUsingFirebase => _isUsingFirebase;

  List<ClienteDTO> get clientes =>
      _clientes.map((c) => ClienteDTO.fromModel(c)).toList();

  ClienteViewModel() {
    _initRepository();
  }

  Future<void> _initRepository() async {
    _isUsingFirebase = await PreferencesHelper.isUsingFirebase();
    _repository = await RepositoryFactory.createClienteRepository();
    await loadClientes();
  }

  Future<void> reloadRepository() async {
    _isUsingFirebase = await PreferencesHelper.isUsingFirebase();
    _repository = await RepositoryFactory.createClienteRepository();
    await loadClientes();
  }

  Future<void> loadClientes([String filtro = '']) async {
    _ultimoFiltro = filtro;
    _clientes = await _repository.buscar(filtro: filtro);
    notifyListeners();
  }

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
    await loadClientes(_ultimoFiltro);
  }

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

  Future<void> removerCliente(int codigo) async {
    await _repository.excluir(codigo);
    await loadClientes(_ultimoFiltro);
  }
}
