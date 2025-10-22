import 'package:exdb/repository/local/local_cidade_repository.dart';
import 'package:exdb/view/lista_cliente.dart';
import 'package:exdb/viewmodel/cidade_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'viewmodel/cliente_viewmodel.dart';
import 'repository/local/local_cliente_repository.dart';
import 'db/db_helper.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await DatabaseHelper.instance.database;
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ClienteViewModel(LocalClienteRepository()),
        ),
        ChangeNotifierProvider(
          create: (_) => CidadeViewModel(LocalCidadeRepository()),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cadastro de Clientes (MVVM + SQLite)',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const ListaClientesPage(),
    );
  }
}
