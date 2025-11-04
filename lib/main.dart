import 'package:exdb/service/auth_service.dart';
import 'package:exdb/view/lista_cliente.dart';
import 'package:exdb/view/login_view.dart';
import 'package:exdb/viewmodel/cidade_viewmodel.dart';
import 'package:exdb/viewmodel/login_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'viewmodel/cliente_viewmodel.dart';
import 'db/db_helper.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await DatabaseHelper.instance.database;
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ClienteViewModel()),
        ChangeNotifierProvider(create: (_) => CidadeViewModel()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => LoginViewModel(authService: AuthService()),
      child: MaterialApp(
        title: 'Cadastro de Clientes (MVVM + SQLite)',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<LoginViewModel>();

    if (viewModel.isAuthenticated) {
      return const ListaClientesPage();
    } else {
      return const LoginPage();
    }
  }
}
