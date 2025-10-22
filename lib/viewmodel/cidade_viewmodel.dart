import 'package:exdb/repository/cidade_repository_interface.dart';
import 'package:exdb/repository/repository_factory.dart';
import 'package:flutter/material.dart';
import '../model/cidade.dart';

class CidadeDTO {
  final int? codigo;
  final String nome;
  final String estado;

  CidadeDTO({required this.codigo, required this.nome, required this.estado});

  factory CidadeDTO.fromModel(Cidade cidade) {
    return CidadeDTO(
      codigo: cidade.codigo,
      nome: cidade.nome,
      estado: cidade.estado,
    );
  }

  Cidade toModel() {
    return Cidade(codigo: codigo, nome: nome, estado: estado);
  }
}

class CidadeViewModel extends ChangeNotifier {
  late ICidadeRepository _repository;
  List<Cidade> _cidades = [];
  String _ultimoFiltro = '';

  List<CidadeDTO> get cidades =>
      _cidades.map((c) => CidadeDTO.fromModel(c)).toList();

  CidadeViewModel(this._repository) {
    _initRepository();
  }

  Future<void> _initRepository() async {
    _repository = await RepositoryFactory.createCidadeRepository();
    await loadCidades();
  }

  Future<void> loadCidades([String filtro = '']) async {
    _ultimoFiltro = filtro;
    _cidades = await _repository.buscar(filtro: filtro);
    notifyListeners();
  }

  Future<void> adicionarCidade({
    required String nome,
    required String estado,
  }) async {
    final cidade = Cidade(nome: nome, estado: estado);
    await _repository.inserir(cidade);
    await loadCidades(_ultimoFiltro);
  }

  Future<void> editarCidade({
    required int codigo,
    required String nome,
    required String estado,
  }) async {
    final cidade = Cidade(codigo: codigo, nome: nome, estado: estado);
    await _repository.atualizar(cidade);
    await loadCidades(_ultimoFiltro);
  }

  Future<void> removerCidade(int codigo) async {
    await _repository.excluir(codigo);
    await loadCidades(_ultimoFiltro);
  }
}
