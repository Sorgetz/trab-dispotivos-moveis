import '../model/cliente.dart';

abstract class IClienteRepository {
  Future<int> inserir(Cliente cliente);
  Future<int> atualizar(Cliente cliente);
  Future<int> excluir(int codigo);
  Future<List<Cliente>> buscar({String filtro = ''});
}
