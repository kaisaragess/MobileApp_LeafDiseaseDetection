class PipelineComparison {
  final String pipeline;
  final String cleanClass;
  final double cleanConfidence;
  final String perturbedClass;
  final double perturbedConfidence;
  final bool isConsistent;
  final double confidenceDrop;

  const PipelineComparison({
    required this.pipeline,
    required this.cleanClass,
    required this.cleanConfidence,
    required this.perturbedClass,
    required this.perturbedConfidence,
    required this.isConsistent,
    required this.confidenceDrop,
  });

  factory PipelineComparison.fromJson(String pipeline, Map<String, dynamic> j) {
    return PipelineComparison(
      pipeline: pipeline,
      cleanClass: j['clean_class'] ?? '-',
      cleanConfidence: (j['clean_confidence'] as num?)?.toDouble() ?? 0.0,
      perturbedClass: j['perturbed_class'] ?? '-',
      perturbedConfidence:
          (j['perturbed_confidence'] as num?)?.toDouble() ?? 0.0,
      isConsistent: j['is_consistent'] == true,
      confidenceDrop: (j['confidence_drop'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class ComparisonResult {
  static const pipelineOrder = ['B0', 'B1', 'B2', 'P1'];

  final String classifier;
  final String condition;
  final String insight;
  final List<PipelineComparison> items;

  const ComparisonResult({
    required this.classifier,
    required this.condition,
    required this.insight,
    required this.items,
  });

  factory ComparisonResult.fromJson(Map<String, dynamic> json) {
    final comps = (json['comparisons'] as Map<String, dynamic>?) ?? {};
    final items = [
      for (final key in pipelineOrder)
        if (comps[key] is Map<String, dynamic>)
          PipelineComparison.fromJson(key, comps[key] as Map<String, dynamic>),
    ];
    return ComparisonResult(
      classifier: json['classifier_tested'] ?? '-',
      condition: json['perturbation_condition'] ?? '-',
      insight: json['scientific_insight'] ?? '',
      items: items,
    );
  }
}
