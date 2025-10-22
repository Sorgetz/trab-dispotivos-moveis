import 'package:flutter/material.dart';
import '../model/cidade.dart';
import '../repository/cidade_repository.dart';

// DTO (Data Transfer Object) para expor dados formatados à View
// A View NÃO deve acessar o Model diretamente
class CidadeDTO {
  final int? codigo;
  final String nome;
  final String estado;

  CidadeDTO({required this.codigo, required this.nome, required this.estado});

  // Converte Model para DTO
  factory CidadeDTO.fromModel(Cidade cidade) {
    return CidadeDTO(
      codigo: cidade.codigo,
      nome: cidade.nome,
      estado: cidade.estado,
    );
  }

  // Converte DTO para Model
  Cidade toModel() {
    return Cidade(codigo: codigo, nome: nome, estado: estado);
  }
}

// ViewModel que expõe dados e ações para as Views (usa ChangeNotifier para MVVM reativo)
class CidadeViewModel extends ChangeNotifier {
  // Repositório de dados (injeção simples via construtor)
  final CidadeRepository _repository;

  // Lista interna de cidades (Model) - privada
  List<Cidade> _cidades = [];

  // Lista pública de DTOs que a View irá observar
  List<CidadeDTO> get cidades =>
      _cidades.map((c) => CidadeDTO.fromModel(c)).toList();

  // Último filtro usado (para manter a lista consistente ao voltar da tela de edição)
  String _ultimoFiltro = '';

  // Construtor recebe o repositório
  CidadeViewModel(this._repository) {
    // Ao construir o ViewModel, carregamos a lista inicial
    loadCidades();
  }

  // Carrega cidades do repositório com filtro opcional
  Future<void> loadCidades([String filtro = '', bool notify = true]) async {
    // Guarda o filtro atual
    _ultimoFiltro = filtro;
    // Busca no repositório
    _cidades = await _repository.buscar(filtro: filtro);
    // Notifica listeners (Views que usam Provider/Consumer serão atualizadas)
    if (notify) {
      notifyListeners();
    }
  }

  // Adiciona uma cidade (recebe dados primitivos da View)
  Future<void> adicionarCidade({
    required String nome,
    required String estado,
  }) async {
    final cidade = Cidade(nome: nome, estado: estado);
    await _repository.inserir(cidade);
    // Recarrega a lista com o último filtro aplicado
    await loadCidades(_ultimoFiltro);
  }

  // Atualiza um cidade (recebe dados primitivos da View)
  Future<void> editarCidade({
    required int codigo,
    required String nome,
    required String estado,
  }) async {
    final cidade = Cidade(codigo: codigo, nome: nome, estado: estado);
    await _repository.atualizar(cidade);
    await loadCidades(_ultimoFiltro);
  }

  // Remove um cidade pelo código
  Future<void> removerCidade(int codigo) async {
    await _repository.excluir(codigo);
    await loadCidades(_ultimoFiltro);
  }
}
