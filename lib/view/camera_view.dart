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

  bool _gravando = false;

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

              ElevatedButton.icon(
                icon: Icon(_gravando ? Icons.stop : Icons.videocam),
                label: Text(_gravando ? "Parar" : "Gravar"),
                onPressed: () async {
                  if (_gravando) {
                    await _viewModel.pararGravacao();
                    setState(() => _gravando = false);
                  } else {
                    await _viewModel.iniciarGravacao();
                    setState(() => _gravando = true);
                  }
                },
              ),
            ],
          ),

          const SizedBox(height: 16),

          if (_viewModel.temMidia)
            Expanded(
              child: _viewModel.isVideo
                  ? Center(
                child: Text(
                  "Vídeo salvo em:\n${_viewModel.caminhoMidia}",
                  textAlign: TextAlign.center,
                ),
              )
                  : Image.file(File(_viewModel.caminhoMidia!)),
            ),
        ],
      ),
    );
  }
}