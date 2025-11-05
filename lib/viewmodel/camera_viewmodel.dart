import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../model/midia.dart';

class CameraViewModel {
  late CameraController _controller;

  bool _inicializado = false;

  Midia? _ultimaMidia;

  CameraController get controller => _controller;

  bool get inicializado => _inicializado;

  String? get caminhoMidia => _ultimaMidia?.caminho;

  bool get temMidia => _ultimaMidia != null;

  Future<void> inicializarCamera() async {
    final cameras =
    await availableCameras();
    final primeiraCamera = cameras.first;

    _controller = CameraController(primeiraCamera, ResolutionPreset.medium);

    await _controller.initialize();

    _inicializado = true;
  }

  Future<void> tirarFoto() async {
    final directory = await getTemporaryDirectory();

    final filePath = path.join(
      directory.path,
      '${DateTime.now().millisecondsSinceEpoch}.jpg',
    );

    final foto = await _controller.takePicture();

    await foto.saveTo(filePath);

    _ultimaMidia = Midia(caminho: filePath);
  }

  void dispose() {
    _controller.dispose();
  }
}