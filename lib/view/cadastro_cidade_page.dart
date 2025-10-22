import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/cidade_viewmodel.dart';

class CadastroCidadePage extends StatefulWidget {
  final CidadeDTO? cidadeDTO;
  const CadastroCidadePage({super.key, this.cidadeDTO});

  @override
  State<CadastroCidadePage> createState() => _CadastroCidadePageState();
}

class _CadastroCidadePageState extends State<CadastroCidadePage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nomeController;
  late TextEditingController _estadoController;

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController(text: widget.cidadeDTO?.nome ?? '');
    _estadoController = TextEditingController(
      text: widget.cidadeDTO?.estado ?? '',
    );
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _estadoController.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    final vm = Provider.of<CidadeViewModel>(context, listen: false);

    if (widget.cidadeDTO == null) {
      await vm.adicionarCidade(
        nome: _nomeController.text.trim(),
        estado: _estadoController.text.trim(),
      );
    } else {
      await vm.editarCidade(
        codigo: widget.cidadeDTO!.codigo!,
        nome: _nomeController.text.trim(),
        estado: _estadoController.text.trim(),
      );
    }

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.cidadeDTO == null ? 'Nova Cidade' : 'Editar Cidade'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(labelText: 'Nome'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Informe o nome' : null,
              ),

              TextFormField(
                controller: _estadoController,
                decoration: const InputDecoration(labelText: 'Estado'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Informe o estado' : null,
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
