import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';


class DriveUploadService {
  Future<String?> uploadToDrive({
    required String accessToken,
    required Uint8List fileBytes,
    required String filename,
  }) async {
    final metadata = {
      'name': filename,
      'mimeType': 'video/mp4',
    };

    final uri = Uri.parse(
        'https://www.googleapis.com/upload/drive/v3/files?uploadType=multipart');

    final request = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'Bearer $accessToken';

    request.fields['metadata'] = jsonEncode(metadata);
    request.files.add(
      http.MultipartFile.fromBytes(
        'file',
        fileBytes,
        filename: filename,
        contentType: MediaType('video', 'mp4'),
      ),
    );

    final response = await request.send();
    final body = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      final json = jsonDecode(body);
      return "https://drive.google.com/file/d/${json['id']}/view";
    } else {
      print("Drive upload failed: $body");
      return null;
    }
  }
}
