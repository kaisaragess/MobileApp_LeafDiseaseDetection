class HistoryEntry {
  final String id;
  final DateTime createdAt;
  final String predictedClass;
  final double confidencePct;
  final String pipeline;
  final String classifier;
  final Map<String, double> probabilitiesPct;
  final String imagePath;

  const HistoryEntry({
    required this.id,
    required this.createdAt,
    required this.predictedClass,
    required this.confidencePct,
    required this.pipeline,
    required this.classifier,
    required this.probabilitiesPct,
    required this.imagePath,
  });

  factory HistoryEntry.fromJson(Map<String, dynamic> j) {
    return HistoryEntry(
      id: j['id'] as String,
      createdAt: DateTime.parse(j['createdAt'] as String),
      predictedClass: j['predictedClass'] as String,
      confidencePct: (j['confidencePct'] as num).toDouble(),
      pipeline: j['pipeline'] as String,
      classifier: j['classifier'] as String,
      probabilitiesPct: (j['probabilitiesPct'] as Map<String, dynamic>)
          .map((k, v) => MapEntry(k, (v as num).toDouble())),
      imagePath: j['imagePath'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'createdAt': createdAt.toIso8601String(),
        'predictedClass': predictedClass,
        'confidencePct': confidencePct,
        'pipeline': pipeline,
        'classifier': classifier,
        'probabilitiesPct': probabilitiesPct,
        'imagePath': imagePath,
      };

  String get shareText =>
      'Hasil diagnosis LeafScan\n'
      'Kelas: $predictedClass\n'
      'Confidence: ${confidencePct.toStringAsFixed(1)}%\n'
      'Pipeline: $pipeline | Model: $classifier\n'
      'Tanggal: ${formatDate(createdAt)}\n\n'
      'Catatan: purwarupa akademik, bukan alat diagnosis lapangan.';
}

String formatDate(DateTime d) {
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(d.day)}/${two(d.month)}/${d.year} ${two(d.hour)}:${two(d.minute)}';
}
