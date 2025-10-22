import 'package:exdb/repository/cidade_repository_interface.dart';
import 'package:exdb/repository/firebase/firebase_cidade_repository.dart';
import 'package:exdb/repository/firebase/firebase_cliente_repository.dart';
import 'package:exdb/repository/local/local_cidade_repository.dart';
import 'package:exdb/repository/local/local_cliente_repository.dart';
import 'package:exdb/utils/preferences_helper.dart';
import 'cliente_repository_interface.dart';

class RepositoryFactory {
  static Future<IClienteRepository> createClienteRepository() async {
    final useFirebase = await PreferencesHelper.isUsingFirebase();
    return useFirebase
        ? FirebaseClienteRepository()
        : LocalClienteRepository();
  }

  static Future<ICidadeRepository> createCidadeRepository() async {
    final useFirebase = await PreferencesHelper.isUsingFirebase();
    return useFirebase
        ? FirebaseCidadeRepository()
        : LocalCidadeRepository();
  }
}
