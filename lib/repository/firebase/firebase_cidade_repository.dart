import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exdb/model/cidade.dart';
import 'package:exdb/repository/cidade_repository_interface.dart';

class FirebaseCidadeRepository implements ICidadeRepository {
  final CollectionReference _collection =
      FirebaseFirestore.instance.collection('cidades');

  @override
  Future<int> inserir(Cidade cidade) async {
    final doc = await _collection.add(cidade.toMap());
    return doc.id.hashCode;
  }

  @override
  Future<int> atualizar(Cidade cidade) async {
    if (cidade.codigo == null) return 0;
    final query = await _collection
        .where('codigo', isEqualTo: cidade.codigo)
        .get();

    if (query.docs.isNotEmpty) {
      await query.docs.first.reference.update(cidade.toMap());
      return 1;
    }
    return 0;
  }

  @override
  Future<int> excluir(int codigo) async {
    final query =
        await _collection.where('codigo', isEqualTo: codigo).get();

    for (var doc in query.docs) {
      await doc.reference.delete();
    }
    return query.docs.length;
  }

  @override
  Future<List<Cidade>> buscar({String filtro = ''}) async {
    QuerySnapshot snapshot;
    if (filtro.isEmpty) {
      snapshot = await _collection.orderBy('nome').get();
    } else {
      snapshot = await _collection
          .where('nome', isGreaterThanOrEqualTo: filtro)
          .where('nome', isLessThanOrEqualTo: '$filtro\uf8ff')
          .get();
    }

    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return Cidade.fromMap(data);
    }).toList();
  }
}
