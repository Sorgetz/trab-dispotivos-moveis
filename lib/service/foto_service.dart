import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class FotoService {
  static Future<String> salvarFotoLocal(String caminhoOrigem) async {
    final directory = await getApplicationDocumentsDirectory();
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    final novoPath = path.join(directory.path, 'fotos', fileName);

    final pastaFotos = Directory(path.join(directory.path, 'fotos'));
    if (!await pastaFotos.exists()) {
      await pastaFotos.create(recursive: true);
    }

    final arquivo = File(caminhoOrigem);
    await arquivo.copy(novoPath);

    return novoPath;
  }

  static Future<String> uploadFotoFirebase(String caminhoLocal) async {
    final arquivo = File(caminhoLocal);
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    final ref = FirebaseStorage.instance.ref().child('clientes/$fileName');

    await ref.putFile(arquivo);
    final url = await ref.getDownloadURL();

    return url;
  }

  static Future<void> excluirFotoLocal(String? caminho) async {
    if (caminho == null || caminho.isEmpty) return;

    try {
      final arquivo = File(caminho);
      if (await arquivo.exists()) {
        await arquivo.delete();
      }
    } catch (e) {
      // Ignora erro se arquivo não existir
    }
  }

  static Future<void> excluirFotoFirebase(String? url) async {
    if (url == null || url.isEmpty || !url.contains('firebase')) return;

    try {
      final ref = FirebaseStorage.instance.refFromURL(url);
      await ref.delete();
    } catch (e) {
      // Ignora erro se arquivo não existir
    }
  }
}
