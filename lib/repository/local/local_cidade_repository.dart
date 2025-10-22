import '../../model/cidade.dart';
import '../../db/db_helper.dart';
import '../cidade_repository_interface.dart';

class LocalCidadeRepository implements ICidadeRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  @override
  Future<int> inserir(Cidade cidade) async {
    final db = await _dbHelper.database;
    return await db.insert('cidades', cidade.toMap());
  }

  @override
  Future<int> atualizar(Cidade cidade) async {
    final db = await _dbHelper.database;
    return await db.update(
      'cidades',
      cidade.toMap(),
      where: 'codigo = ?',
      whereArgs: [cidade.codigo],
    );
  }

  @override
  Future<int> excluir(int codigo) async {
    final db = await _dbHelper.database;
    return await db.delete('cidades', where: 'codigo = ?', whereArgs: [codigo]);
  }

  @override
  Future<List<Cidade>> buscar({String filtro = ''}) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = filtro.isEmpty
        ? await db.query('cidades', orderBy: 'nome')
        : await db.query(
            'cidades',
            where: 'nome LIKE ?',
            whereArgs: ['%$filtro%'],
            orderBy: 'nome',
          );
    return maps.map((m) => Cidade.fromMap(m)).toList();
  }
}
