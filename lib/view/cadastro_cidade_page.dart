import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/cidade_viewmodel.dart';

// Tela de cadastro/edição (View)
// NÃO importa Model - usa apenas DTO do ViewModel
class CadastroCidadePage extends StatefulWidget {
  // Recebe um DTO opcional: se for null => criação; senão => edição
  final CidadeDTO? cidadeDTO;
  const CadastroCidadePage({super.key, this.cidadeDTO});

  @override
  State<CadastroCidadePage> createState() => _CadastroCidadePageState();
}

class _CadastroCidadePageState extends State<CadastroCidadePage> {
  // Form key para validação
  final _formKey = GlobalKey<FormState>();

  // Controllers para os campos do formulário
  late TextEditingController _nomeController;
  late TextEditingController _estadoController;

  @override
  void initState() {
    super.initState();
    // Inicializa os controllers com os valores do DTO (se existir) ou vazios
    _nomeController = TextEditingController(text: widget.cidadeDTO?.nome ?? '');
    _estadoController = TextEditingController(
      text: widget.cidadeDTO?.estado ?? '',
    );
  }

  @override
  void dispose() {
    // Libera os controllers
    _nomeController.dispose();
    _estadoController.dispose();
    super.dispose();
  }

  // Função chamada ao salvar (adicionar ou editar)
  Future<void> _salvar() async {
    // Valida o formulário
    if (!_formKey.currentState!.validate()) return;

    // Obtém o ViewModel (não escuta mudanças aqui)
    final vm = Provider.of<CidadeViewModel>(context, listen: false);

    // Passa dados primitivos para o ViewModel (NÃO cria objetos Model aqui)
    if (widget.cidadeDTO == null) {
      // Novo cliente
      await vm.adicionarCidade(
        nome: _nomeController.text.trim(),
        estado: _estadoController.text.trim(),
      );
    } else {
      // Atualiza cliente existente
      await vm.editarCidade(
        codigo: widget.cidadeDTO!.codigo!,
        nome: _nomeController.text.trim(),
        estado: _estadoController.text.trim(),
      );
    }

    // Volta para a tela anterior
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
              // Campo Nome
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(labelText: 'Nome'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Informe o nome' : null,
              ),

              // Campo Estado
              TextFormField(
                controller: _estadoController,
                decoration: const InputDecoration(labelText: 'Estado'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Informe o estado' : null,
              ),

              const SizedBox(height: 20),

              // Botão de salvar
              ElevatedButton(onPressed: _salvar, child: const Text('Salvar')),
            ],
          ),
        ),
      ),
    );
  }
}
