class PredictResponse {
  final String status;
  final PredictionMeta meta;
  final PredictionDetail prediction;
  final FeatureSummary featureSummary;
  final Map<String, String> visualizationsBase64;
  final String disclaimer;

  PredictResponse({
    required this.status,
    required this.meta,
    required this.prediction,
    required this.featureSummary,
    required this.visualizationsBase64,
    required this.disclaimer,
  });

  factory PredictResponse.fromJson(Map<String, dynamic> json) {
    return PredictResponse(
      status: json['status'] ?? '',
      meta: PredictionMeta.fromJson(json['meta'] ?? {}),
      prediction: PredictionDetail.fromJson(json['prediction'] ?? {}),
      featureSummary: FeatureSummary.fromJson(json['feature_summary'] ?? {}),
      visualizationsBase64:
          Map<String, String>.from(json['visualizations_base64'] ?? {}),
      disclaimer: json['disclaimer'] ?? '',
    );
  }
}

class PredictionMeta {
  final String pipelineUsed;
  final String classifierUsed;
  final double preprocessingTimeMs;
  final double predictionTimeMs;
  final double modelCvMacroF1;

  PredictionMeta({
    required this.pipelineUsed,
    required this.classifierUsed,
    required this.preprocessingTimeMs,
    required this.predictionTimeMs,
    required this.modelCvMacroF1,
  });

  factory PredictionMeta.fromJson(Map<String, dynamic> json) {
    return PredictionMeta(
      pipelineUsed: json['pipeline_used'] ?? '',
      classifierUsed: json['classifier_used'] ?? '',
      preprocessingTimeMs:
          (json['preprocessing_time_ms'] as num?)?.toDouble() ?? 0.0,
      predictionTimeMs: (json['prediction_time_ms'] as num?)?.toDouble() ?? 0.0,
      modelCvMacroF1: (json['model_cv_macro_f1'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class PredictionDetail {
  final String predictedClass;
  final double confidenceScore;
  final Map<String, double> probabilities;

  PredictionDetail({
    required this.predictedClass,
    required this.confidenceScore,
    required this.probabilities,
  });

  factory PredictionDetail.fromJson(Map<String, dynamic> json) {
    final rawProbs = json['probabilities'] as Map<String, dynamic>? ?? {};
    final probs =
        rawProbs.map((key, value) => MapEntry(key, (value as num).toDouble()));

    return PredictionDetail(
      predictedClass: json['predicted_class'] ?? 'Tidak Diketahui',
      confidenceScore: (json['confidence_score'] as num?)?.toDouble() ?? 0.0,
      probabilities: probs,
    );
  }
}

class FeatureSummary {
  final double leafAreaRatio;
  final double lesionAreaRatio;
  final double lesionDensityPer1kPx;
  final int estimatedLesionBlobs;

  FeatureSummary({
    required this.leafAreaRatio,
    required this.lesionAreaRatio,
    required this.lesionDensityPer1kPx,
    required this.estimatedLesionBlobs,
  });

  factory FeatureSummary.fromJson(Map<String, dynamic> json) {
    return FeatureSummary(
      leafAreaRatio: (json['leaf_area_ratio'] as num?)?.toDouble() ?? 0.0,
      lesionAreaRatio: (json['lesion_area_ratio'] as num?)?.toDouble() ?? 0.0,
      lesionDensityPer1kPx:
          (json['lesion_density_per_1k_px'] as num?)?.toDouble() ?? 0.0,
      estimatedLesionBlobs: json['estimated_lesion_blobs'] ?? 0,
    );
  }
}

/// Error 422: objek yang difoto bukan daun padi.
class NonLeafException implements Exception {
  final String message;
  final double leafAreaRatio;

  NonLeafException(this.message, this.leafAreaRatio);

  @override
  String toString() => message;
}
