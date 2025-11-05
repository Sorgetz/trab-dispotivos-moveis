import 'dart:io';

import 'package:exdb/viewmodel/cidade_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../service/foto_service.dart';
import '../viewmodel/cliente_viewmodel.dart';
import '../viewmodel/camera_viewmodel.dart';
import 'package:camera/camera.dart';

class CadastroClientePage extends StatefulWidget {
  final ClienteDTO? clienteDTO;
  const CadastroClientePage({super.key, this.clienteDTO});

  @override
  State<CadastroClientePage> createState() => _CadastroClientePageState();
}

class _CadastroClientePageState extends State<CadastroClientePage> {
  final _formKey = GlobalKey<FormState>();

  final CameraViewModel _cameraViewModel = CameraViewModel();

  late TextEditingController _cpfController;
  late TextEditingController _nomeController;
  late TextEditingController _idadeController;
  late TextEditingController _dataNascimentoController;
  late TextEditingController _cidadeController;

  String? _fotoPath;
  bool _cameraInicializada = false;

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

    _fotoPath = widget.clienteDTO?.fotoUrl;
    _inicializarCamera();
  }

  Future<void> _inicializarCamera() async {
    await _cameraViewModel.inicializarCamera();
    setState(() => _cameraInicializada = true);
  }

  @override
  void dispose() {
    _cpfController.dispose();
    _nomeController.dispose();
    _idadeController.dispose();
    _dataNascimentoController.dispose();
    _cidadeController.dispose();
    _cameraViewModel.dispose();
    super.dispose();
  }

  @override
  void deactivate() {
    _cameraViewModel.dispose();
    super.deactivate();
  }

  Future<void> _tirarFoto() async {
    if (!_cameraInicializada) return;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tirar Foto'),
        content: SizedBox(
          width: 300,
          height: 400,
          child: Column(
            children: [
              Expanded(
                child: AspectRatio(
                  aspectRatio: _cameraViewModel.controller!.value.aspectRatio,
                  child: CameraPreview(_cameraViewModel.controller!),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                icon: const Icon(Icons.camera_alt),
                label: const Text('Capturar'),
                onPressed: () async {
                  await _cameraViewModel.tirarFoto();
                  setState(() {
                    _fotoPath = _cameraViewModel.caminhoMidia;
                  });
                  _cameraViewModel.dispose();
                  if (mounted) Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    final vm = Provider.of<ClienteViewModel>(context, listen: false);
    String? fotoUrlFinal = _fotoPath;

    if (_fotoPath != null && !_fotoPath!.contains('http')) {
      if (vm.isUsingFirebase) {
        fotoUrlFinal = await FotoService.uploadFotoFirebase(_fotoPath!);
      } else {
        fotoUrlFinal = await FotoService.salvarFotoLocal(_fotoPath!);
      }
    }

    if (widget.clienteDTO == null) {
      await vm.adicionarCliente(
        cpf: _cpfController.text.trim(),
        nome: _nomeController.text.trim(),
        idade: _idadeController.text.trim(),
        dataNascimento: _dataNascimentoController.text.trim(),
        cidadeNascimento: _cidadeController.text.trim(),
        fotoUrl: fotoUrlFinal
      );
    } else {
      await vm.editarCliente(
        codigo: widget.clienteDTO!.codigo!,
        cpf: _cpfController.text.trim(),
        nome: _nomeController.text.trim(),
        idade: _idadeController.text.trim(),
        dataNascimento: _dataNascimentoController.text.trim(),
        cidadeNascimento: _cidadeController.text.trim(),
        fotoUrl: fotoUrlFinal
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
              // Foto
              Center(
                child: GestureDetector(
                  onTap: _tirarFoto,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      shape: BoxShape.circle,
                      image: _fotoPath != null
                          ? DecorationImage(
                        image: _fotoPath!.contains('http')
                            ? NetworkImage(_fotoPath!)
                            : FileImage(File(_fotoPath!)) as ImageProvider,
                        fit: BoxFit.cover,
                      )
                          : null,
                    ),
                    child: _fotoPath == null
                        ? const Icon(Icons.camera_alt, size: 50, color: Colors.grey)
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: TextButton.icon(
                  icon: const Icon(Icons.photo_camera),
                  label: Text(_fotoPath == null ? 'Tirar Foto' : 'Alterar Foto'),
                  onPressed: _tirarFoto,
                ),
              ),
              const SizedBox(height: 20),
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
