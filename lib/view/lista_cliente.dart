import 'package:exdb/view/cadastro_cidade_page.dart';
import 'package:exdb/viewmodel/cidade_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/cliente_viewmodel.dart';
import 'cadastro_cliente_page.dart';

// Tela que exibe a lista e o campo de pesquisa (View)
// NÃO importa Model - usa apenas DTO do ViewModel
class ListaClientesPage extends StatefulWidget {
  const ListaClientesPage({super.key});

  @override
  State<ListaClientesPage> createState() => _ListaClientesPageState();
}

class _ListaClientesPageState extends State<ListaClientesPage> {
  // Controller do campo de pesquisa
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Opcional: poderia carregar aqui, mas o ViewModel já carrega na construção
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Obtém o ViewModel via Provider
    final vm = Provider.of<ClienteViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Clientes (MVVM + SQLite)'),
        actions: [
          // Botão para criar novo cliente
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              // Navega para a tela de cadastro sem passar cliente (novo)
              await showDialog<String>(
                context: context,
                useRootNavigator: true,
                builder: (context) => AlertDialog(
                  title: Text('O que você deseja adicionar?'),
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
              // Ao voltar, recarrega a lista com o filtro atual
              await vm.loadClientes(_searchController.text);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Campo de pesquisa por nome
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
                // Chama o ViewModel para atualizar a lista com o filtro
                await vm.loadClientes(value);
              },
            ),
          ),
          // Lista observando o ViewModel (neste caso, Provider reconstrói o widget)
          Expanded(
            child: vm.clientes.isEmpty
                ? const Center(child: Text('Nenhum cliente encontrado'))
                : ListView.builder(
                    itemCount: vm.clientes.length,
                    itemBuilder: (context, index) {
                      // Usa DTO ao invés de Model
                      final ClienteDTO dto = vm.clientes[index];
                      return ListTile(
                        title: Text(dto.nome),
                        subtitle: Text(
                          dto.subtitulo,
                        ), // Dado formatado pelo ViewModel
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Botão editar
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () async {
                                // Navega para edição passando o DTO
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        CadastroClientePage(clienteDTO: dto),
                                  ),
                                );
                                // Recarrega a lista
                                await vm.loadClientes(_searchController.text);
                              },
                            ),
                            // Botão excluir
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                // Chama o ViewModel para excluir e atualiza a lista
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
