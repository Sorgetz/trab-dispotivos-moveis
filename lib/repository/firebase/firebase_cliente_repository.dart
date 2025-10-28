import 'package:cloud_firestore/cloud_firestore.dart';
import '../../model/cliente.dart';
import '../cliente_repository_interface.dart';

class FirebaseClienteRepository implements IClienteRepository {
  final CollectionReference _collection =
      FirebaseFirestore.instance.collection('clientes');

  @override
  Future<int> inserir(Cliente cliente) async {
    final doc = await _collection.add(cliente.toMap());
    await doc.update({'codigo': doc.id.hashCode});
    return doc.id.hashCode;
  }

  @override
  Future<int> atualizar(Cliente cliente) async {
    if (cliente.codigo == null) return 0;
    final query = await _collection
        .where('codigo', isEqualTo: cliente.codigo)
        .get();

    if (query.docs.isNotEmpty) {
      await query.docs.first.reference.update(cliente.toMap());
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
  Future<List<Cliente>> buscar({String filtro = ''}) async {
    QuerySnapshot snapshot;
    if (filtro.isEmpty) {
      snapshot = await _collection.orderBy('nome').get();
    } else {
      snapshot = await _collection
          .where('nome', isGreaterThanOrEqualTo: filtro)
          .where('nome', isLessThanOrEqualTo: '$filtro\uf8ff')
          .get();
    }

    for (var doc in snapshot.docs) {
      var map = doc.data() as Map<String, dynamic>;
      if (map['codigo'] == null) {
        await doc.reference.update({'codigo': doc.id.hashCode});
      }
    }

    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      data.addAll({'id': doc.id.hashCode});
      return Cliente.fromMap(data);
    }).toList();
  }
}
