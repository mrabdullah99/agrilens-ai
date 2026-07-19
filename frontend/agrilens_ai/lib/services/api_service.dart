import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../models/prediction_result.dart';
import '../utils/constants.dart';

class ApiService {
  Future<PredictionResult> predict(File imageFile) async {
    final uri = Uri.parse("$kApiBaseUrl/predict");
    final request = http.MultipartRequest("POST", uri);
    request.files.add(await http.MultipartFile.fromPath(
      "file",
      imageFile.path,
      contentType: MediaType("image", "jpeg"),
    ));

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 200) {
      throw Exception("Prediction failed: ${response.statusCode} ${response.body}");
    }

    return PredictionResult.fromJson(jsonDecode(response.body));
  }
}