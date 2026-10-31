class PredictSettings {
  static const pipelines = ['B0', 'B1', 'B2', 'P1'];
  static const classifiers = [
    'KNN',
    'SVM',
    'RandomForest',
    'ExtraTrees',
    'Ensemble_Voting',
  ];

  final String pipelineMode;
  final String classifier;
  final double brightnessShift; // -0.20 s.d. +0.20
  final double saturationShift; // -0.15 s.d. +0.15
  final bool applyBlur;

  const PredictSettings({
    this.pipelineMode = 'P1',
    this.classifier = 'SVM',
    this.brightnessShift = 0.0,
    this.saturationShift = 0.0,
    this.applyBlur = false,
  });

  PredictSettings copyWith({
    String? pipelineMode,
    String? classifier,
    double? brightnessShift,
    double? saturationShift,
    bool? applyBlur,
  }) {
    return PredictSettings(
      pipelineMode: pipelineMode ?? this.pipelineMode,
      classifier: classifier ?? this.classifier,
      brightnessShift: brightnessShift ?? this.brightnessShift,
      saturationShift: saturationShift ?? this.saturationShift,
      applyBlur: applyBlur ?? this.applyBlur,
    );
  }
}
