import 'package:exdb/viewmodel/cidade_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/cliente_viewmodel.dart';

class CadastroClientePage extends StatefulWidget {
  final ClienteDTO? clienteDTO;
  const CadastroClientePage({super.key, this.clienteDTO});

  @override
  State<CadastroClientePage> createState() => _CadastroClientePageState();
}

class _CadastroClientePageState extends State<CadastroClientePage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _cpfController;
  late TextEditingController _nomeController;
  late TextEditingController _idadeController;
  late TextEditingController _dataNascimentoController;
  late TextEditingController _cidadeController;

  @override
  void initState() {
    super.initState();
    _cpfController = TextEditingController(text: widget.clienteDTO?.cpf ?? '');
    _nomeController = TextEditingController(
      text: widget.clienteDTO?.nome ?? '',
    );
    _idadeController = TextEditingController(
      text: widget.clienteDTO?.idade ?? '',
    );
    _dataNascimentoController = TextEditingController(
      text: widget.clienteDTO?.dataNascimento ?? '',
    );
    _cidadeController = TextEditingController(
      text: widget.clienteDTO?.cidadeNascimento ?? '',
    );
  }

  @override
  void dispose() {
    _cpfController.dispose();
    _nomeController.dispose();
    _idadeController.dispose();
    _dataNascimentoController.dispose();
    _cidadeController.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    final vm = Provider.of<ClienteViewModel>(context, listen: false);

    if (widget.clienteDTO == null) {
      await vm.adicionarCliente(
        cpf: _cpfController.text.trim(),
        nome: _nomeController.text.trim(),
        idade: _idadeController.text.trim(),
        dataNascimento: _dataNascimentoController.text.trim(),
        cidadeNascimento: _cidadeController.text.trim(),
      );
    } else {
      await vm.editarCliente(
        codigo: widget.clienteDTO!.codigo!,
        cpf: _cpfController.text.trim(),
        nome: _nomeController.text.trim(),
        idade: _idadeController.text.trim(),
        dataNascimento: _dataNascimentoController.text.trim(),
        cidadeNascimento: _cidadeController.text.trim(),
      );
    }

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.clienteDTO == null ? 'Novo Cliente' : 'Editar Cliente',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _cpfController,
                decoration: const InputDecoration(labelText: 'CPF'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Informe o CPF' : null,
              ),

              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(labelText: 'Nome'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Informe o nome' : null,
              ),

              TextFormField(
                controller: _idadeController,
                decoration: const InputDecoration(labelText: 'Idade'),
                keyboardType: TextInputType.number,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Informe a idade' : null,
              ),

              TextFormField(
                controller: _dataNascimentoController,
                decoration: const InputDecoration(
                  labelText: 'Data de Nascimento',
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Informe a data de nascimento'
                    : null,
              ),

              TextFormField(
                readOnly: true,
                controller: _cidadeController,
                decoration: InputDecoration(
                  labelText: 'Cidade de Nascimento',
                  suffixIcon: IconButton(
                    icon: Icon(Icons.location_city),
                    onPressed: () async {
                      final cidadeSelecionada = await _mostrarSeletorCidade(
                        context,
                      );

                      if (cidadeSelecionada != null) {
                        setState(() {
                          _cidadeController.text = cidadeSelecionada;
                        });
                      }
                    },
                  ),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Informe a cidade' : null,
              ),

              const SizedBox(height: 20),

              ElevatedButton(onPressed: _salvar, child: const Text('Salvar')),
            ],
          ),
        ),
      ),
    );
  }
}

Future<String?> _mostrarSeletorCidade(BuildContext context) async {
  final TextEditingController searchController = TextEditingController();

  final cidadeSelecionada = await showDialog<String>(
    context: context,
    builder: (BuildContext dialogContext) {
      final vmCity = Provider.of<CidadeViewModel>(dialogContext, listen: false);
      String? cidadeTemporaria;

      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            if (vmCity.cidades.isEmpty) {
              await vmCity.loadCidades();
              if (context.mounted) setState(() {});
            }
          });

          return AlertDialog(
            title: const Text('Selecione a Cidade'),
            content: SizedBox(
              width: double.maxFinite,
              height: 400,
              child: Column(
                children: [
                  TextField(
                    controller: searchController,
                    decoration: const InputDecoration(
                      labelText: 'Pesquisar por nome',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) async {
                      await vmCity.loadCidades(value);
                      if (context.mounted) setState(() {});
                    },
                  ),
                  const SizedBox(height: 8),

                  Expanded(
                    child: vmCity.cidades.isEmpty
                        ? const Center(child: Text('Nenhuma cidade encontrada'))
                        : ListView.builder(
                            itemCount: vmCity.cidades.length,
                            itemBuilder: (context, index) {
                              final cidadeDTO = vmCity.cidades[index];
                              final isSelected =
                                  cidadeTemporaria == cidadeDTO.nome;

                              return ListTile(
                                tileColor: isSelected
                                    ? Theme.of(
                                        context,
                                      ).primaryColor.withOpacity(0.2)
                                    : null,
                                title: Text(
                                  '${cidadeDTO.nome} - ${cidadeDTO.estado}',
                                ),
                                onTap: () {
                                  cidadeTemporaria = cidadeDTO.nome;
                                  setState(() {});
                                },
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, null),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: cidadeTemporaria == null
                    ? null
                    : () {
                        vmCity.loadCidades();
                        Navigator.pop(context, cidadeTemporaria);
                      },
                child: const Text('Adicionar'),
              ),
            ],
          );
        },
      );
    },
  );

  searchController.dispose();
  return cidadeSelecionada;
}
