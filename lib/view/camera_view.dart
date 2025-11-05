import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import '../viewmodel/camera_viewmodel.dart';
import 'dart:io';

class CameraView extends StatefulWidget {
  const CameraView({super.key});

  @override
  State<CameraView> createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> {
  final CameraViewModel _viewModel = CameraViewModel();

  @override
  void initState() {
    super.initState();
    _inicializar();
  }

  Future<void> _inicializar() async {
    await _viewModel.inicializarCamera();
    setState(() {});
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_viewModel.inicializado) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Câmera - MVVM'),
        backgroundColor: Colors.teal,
      ),
      body: Column(
        children: [
          AspectRatio(
            aspectRatio: _viewModel.controller.value.aspectRatio,
            child: CameraPreview(_viewModel.controller),
          ),

          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.camera_alt),
                label: const Text("Tirar Foto"),
                onPressed: () async {
                  await _viewModel.tirarFoto();
                  setState(() {});
                },
              ),

            ],
          ),

          const SizedBox(height: 16),

          if (_viewModel.temMidia)
            Expanded(
              child:
                Image.file(File(_viewModel.caminhoMidia!)),
            ),
        ],
      ),
    );
  }
}