import 'dart:io';
import 'package:flutter/material.dart';
import '../models/rice_disease_model.dart';
import '../widgets/base64_image.dart';

class ResultScreen extends StatelessWidget {
  final File image;
  final PredictResponse result;

  const ResultScreen({super.key, required this.image, required this.result});

  // Backend bisa mengirim skor 0-1 atau 0-100. Normalisasi ke persen.
  // Cek di respons asli, lalu sesuaikan kalau perlu.
  double _pct(double v) => v <= 1.0 ? v * 100 : v;

  static const _stageTitles = {
    '1_resized_input': '1. Resized Input',
    '2_gray_world': '2. Gray World',
    '3_clahe_lab': '3. CLAHE (Lab)',
    '4_leaf_mask_morphology': '4. Masking Daun',
    '5_lesion_mask': '5. Masking Bercak',
    '6_final_segmented': '6. Segmentasi Akhir',
  };

  @override
  Widget build(BuildContext context) {
    final pred = result.prediction;
    final meta = result.meta;
    final feat = result.featureSummary;

    final probs = pred.probabilities.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final stages = result.visualizationsBase64.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return Scaffold(
      appBar: AppBar(title: const Text('Hasil Diagnosis')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(image, height: 200, fit: BoxFit.cover),
            ),
            const SizedBox(height: 16),

            // Hasil utama
            Card(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Hasil Prediksi'),
                    const SizedBox(height: 4),
                    Text(
                      pred.predictedClass,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                        'Confidence: ${_pct(pred.confidenceScore).toStringAsFixed(1)}%'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Probabilitas tiap kelas
            Text('Probabilitas Tiap Kelas',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            ...probs.map((e) {
              final p = _pct(e.value);
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(child: Text(e.key)),
                        Text('${p.toStringAsFixed(1)}%'),
                      ],
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: (p / 100).clamp(0.0, 1.0),
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 8),

            // Ringkasan fitur
            Text('Ringkasan Fitur',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            _row('Rasio luas daun', feat.leafAreaRatio.toStringAsFixed(3)),
            _row('Rasio luas bercak', feat.lesionAreaRatio.toStringAsFixed(3)),
            _row('Kepadatan bercak /1k px',
                feat.lesionDensityPer1kPx.toStringAsFixed(3)),
            _row('Perkiraan jumlah bercak', '${feat.estimatedLesionBlobs}'),
            const SizedBox(height: 16),

            // Visualisasi 6 tahap
            if (stages.isNotEmpty) ...[
              Text('Tahapan Pemrosesan Citra',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              SizedBox(
                height: 150,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: stages.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 12),
                  itemBuilder: (_, i) {
                    final s = stages[i];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildBase64Image(s.value, width: 260),
                        const SizedBox(height: 6),
                        Text(
                          _stageTitles[s.key] ?? s.key,
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Telemetry
            Text('Info Proses', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            _row('Pipeline', meta.pipelineUsed),
            _row('Model', meta.classifierUsed),
            _row('Waktu preprocessing',
                '${meta.preprocessingTimeMs.toStringAsFixed(1)} ms'),
            _row('Waktu prediksi',
                '${meta.predictionTimeMs.toStringAsFixed(1)} ms'),
            _row('CV Macro F1', meta.modelCvMacroF1.toStringAsFixed(3)),
            const SizedBox(height: 16),

            if (result.disclaimer.isNotEmpty)
              Text(
                result.disclaimer,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(fontStyle: FontStyle.italic),
              ),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(child: Text(label)),
          const SizedBox(width: 12),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

