import 'dart:io';
import 'dart:convert';

class FotoService {


  static Future<String> fileToBase64(String filePath) async {
    final bytes = await File(filePath).readAsBytes();
    return base64Encode(bytes);
  }
}
