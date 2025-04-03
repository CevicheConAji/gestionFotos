import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/photo_model.dart';

class UploadService {
  /*static const String _apiUrl =
      'https://eanfotosapi.electricautomationnetwork.com/upload2/';
  static const String _user = 'fotospedido';
  static const String _password = 'pegxup-7wussi-pekdUx';*/

  static const String _apiUrl = 'http://192.168.0.14:5000/upload2/';
  static const String _user = 'test_user';
  static const String _password = 'test_pass';

  static Future<bool> uploadPhotosInOrder(
    List<PhotoModel> photos, {
    required String folderName,
  }) async {
    bool allUploaded = true;

    for (final photo in photos) {
      final success = await _uploadSinglePhoto(photo, folderName);
      if (!success) {
        print('❌ Error subiendo: ${photo.fileName}');
        allUploaded = false;
      } else {
        print('✅ Subido: ${photo.fileName}');
      }
    }

    return allUploaded;
  }

  static Future<bool> _uploadSinglePhoto(
    PhotoModel photo,
    String folderName,
  ) async {
    final uri = Uri.parse(_apiUrl);
    final request = http.MultipartRequest('POST', uri);

    // Autenticación básica
    final String basicAuth =
        'Basic ${base64Encode(utf8.encode('$_user:$_password'))}';
    request.headers['Authorization'] = basicAuth;

    // Campos requeridos por el servidor
    request.fields['folder_name'] = folderName;
    request.files.add(
      await http.MultipartFile.fromPath('files', photo.file.path),
    ); // 👈 field debe ser 'files'

    try {
      final response = await request.send();
      final body = await response.stream.bytesToString();
      print('🔁 SERVER RESPONSE: $body');
      print('🧾 STATUS: ${response.statusCode}');
      return response.statusCode == 200;
    } catch (e) {
      print('❗ Excepción al subir: $e');
      return false;
    }
  }
}
