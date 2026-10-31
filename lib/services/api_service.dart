import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config.dart';
import '../models/predict_settings.dart';
import '../models/rice_disease_model.dart';

class RiceLeafApiService {
  final String baseUrl = AppConfig.baseUrl;

  /// GET /health
  Future<bool> checkHealth() async {
    try {
      final res = await http
          .get(Uri.parse('$baseUrl/health'))
          .timeout(const Duration(seconds: 5));
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  /// POST /predict
  Future<PredictResponse> predictLeafDisease({
    required File imageFile,
    PredictSettings settings = const PredictSettings(),
  }) async {
    final request =
        http.MultipartRequest('POST', Uri.parse('$baseUrl/predict'));

    request.files
        .add(await http.MultipartFile.fromPath('image', imageFile.path));
    request.fields['pipeline_mode'] = settings.pipelineMode;
    request.fields['classifier'] = settings.classifier;
    request.fields['brightness_shift'] = settings.brightnessShift.toString();
    request.fields['saturation_shift'] = settings.saturationShift.toString();
    request.fields['apply_blur'] = settings.applyBlur.toString();

    final streamed = await request.send().timeout(const Duration(seconds: 20));
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode == 200) {
      return PredictResponse.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 422) {
      final err = jsonDecode(response.body);
      throw NonLeafException(
        err['message'] ?? 'Objek bukan daun padi.',
        (err['leaf_area_ratio'] as num?)?.toDouble() ?? 0.0,
      );
    } else {
      throw Exception(
          'Gagal melakukan diagnosis: ${response.statusCode} - ${response.body}');
    }
  }

  /// POST /compare-pipelines
  Future<Map<String, dynamic>> comparePipelines({
    required File imageFile,
    String classifier = 'SVM',
    double brightnessShift = -0.20,
  }) async {
    final request =
        http.MultipartRequest('POST', Uri.parse('$baseUrl/compare-pipelines'));
    request.files
        .add(await http.MultipartFile.fromPath('image', imageFile.path));
    request.fields['classifier'] = classifier;
    request.fields['brightness_shift'] = brightnessShift.toString();

    final streamed = await request.send().timeout(const Duration(seconds: 25));
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Gagal komparasi pipeline: ${response.statusCode}');
  }

  /// GET /experiment-metrics
  Future<Map<String, dynamic>> getExperimentMetrics() async {
    final response = await http.get(Uri.parse('$baseUrl/experiment-metrics'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Gagal memuat metrik');
  }
}
