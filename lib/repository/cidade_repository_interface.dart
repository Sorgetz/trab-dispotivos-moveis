import '../model/cidade.dart';

abstract class ICidadeRepository {
  Future<int> inserir(Cidade cidade);
  Future<int> atualizar(Cidade cidade);
  Future<int> excluir(int codigo);
  Future<List<Cidade>> buscar({String filtro = ''});
}
