import 'package:exdb/utils/preferences_helper.dart';
import 'package:exdb/view/cadastro_cidade_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/cliente_viewmodel.dart';
import 'cadastro_cliente_page.dart';

class ListaClientesPage extends StatefulWidget {
  const ListaClientesPage({super.key});

  @override
  State<ListaClientesPage> createState() => _ListaClientesPageState();
}

class _ListaClientesPageState extends State<ListaClientesPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<ClienteViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Clientes (${vm.isUsingFirebase ? "Firebase" : "SQLite"})',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              bool useFirebase = await PreferencesHelper.isUsingFirebase();
              await showDialog<String>(
                context: context,
                useRootNavigator: true,
                builder: (context) {
                  bool switchValue = useFirebase;
                  return StatefulBuilder(
                    builder: (context, setState) => AlertDialog(
                      title: Text('O que você deseja adicionar?'),
                      content: Row(
                        children: [
                          const Text('Usar Firebase'),
                          Switch(
                            value: switchValue,
                            onChanged: (value) async {
                              setState(() {
                                switchValue = value;
                              });
                              PreferencesHelper.setUseFirebase(value);
                              await vm.reloadRepository();
                            },
                          ),
                        ],
                      ),
                      actions: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CadastroClientePage(),
                              ),
                            );
                          },
                          child: Text('Cliente'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CadastroCidadePage(),
                              ),
                            );
                          },
                          child: Text('Cidade'),
                        ),
                      ],
                    ),
                  );
                },
              );
              await vm.loadClientes(_searchController.text);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Pesquisar por nome',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) async {
                await vm.loadClientes(value);
              },
            ),
          ),
          Expanded(
            child: vm.clientes.isEmpty
                ? const Center(child: Text('Nenhum cliente encontrado'))
                : ListView.builder(
                    itemCount: vm.clientes.length,
                    itemBuilder: (context, index) {
                      final ClienteDTO dto = vm.clientes[index];
                      return ListTile(
                        title: Text(dto.nome),
                        subtitle: Text(dto.subtitulo),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        CadastroClientePage(clienteDTO: dto),
                                  ),
                                );
                                await vm.loadClientes(_searchController.text);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                await vm.removerCliente(dto.codigo!);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
