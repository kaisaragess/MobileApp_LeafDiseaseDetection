import 'dart:io';
import 'package:flutter/material.dart';
import '../models/rice_disease_model.dart';
import '../theme.dart';
import '../widgets/base64_image.dart';
import '../widgets/disease_info_card.dart';

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
    final textTheme = Theme.of(context).textTheme;

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
              borderRadius: BorderRadius.circular(16),
              child: Image.file(image, height: 200, fit: BoxFit.cover),
            ),
            const SizedBox(height: 16),

            // Hasil utama
            _heroCard(pred.predictedClass, _pct(pred.confidenceScore)),
            const SizedBox(height: 16),

            // Probabilitas tiap kelas
            SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionTitle('Probabilitas Tiap Kelas'),
                  const SizedBox(height: 12),
                  ...List.generate(
                    probs.length,
                    (i) => _probRow(
                      probs[i].key,
                      _pct(probs[i].value),
                      i == 0,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Ringkasan fitur
            SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionTitle('Ringkasan Fitur'),
                  const SizedBox(height: 12),
                  _pair(
                    _statTile(
                      'Rasio luas daun',
                      feat.leafAreaRatio.toStringAsFixed(3),
                    ),
                    _statTile(
                      'Rasio luas bercak',
                      feat.lesionAreaRatio.toStringAsFixed(3),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _pair(
                    _statTile(
                      'Kepadatan bercak /1k px',
                      feat.lesionDensityPer1kPx.toStringAsFixed(3),
                    ),
                    _statTile(
                      'Perkiraan jumlah bercak',
                      '${feat.estimatedLesionBlobs}',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Visualisasi tahap pemrosesan
            if (stages.isNotEmpty) ...[
              SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionTitle('Tahapan Pemrosesan Citra'),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 180,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: stages.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 12),
                        itemBuilder: (_, i) {
                          final s = stages[i];
                          return SizedBox(
                            width: 260,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                buildBase64Image(s.value, width: 260),
                                const SizedBox(height: 6),
                                Text(
                                  _stageTitles[s.key] ?? s.key,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primaryDark,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Keterangan dan saran penanganan
            DiseaseInfoCard(label: pred.predictedClass),
            const SizedBox(height: 16),

            // Info proses
            SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionTitle('Info Proses'),
                  const SizedBox(height: 4),
                  _row('Pipeline', meta.pipelineUsed),
                  _row('Model', meta.classifierUsed),
                  _row(
                    'Waktu preprocessing',
                    '${meta.preprocessingTimeMs.toStringAsFixed(1)} ms',
                  ),
                  _row(
                    'Waktu prediksi',
                    '${meta.predictionTimeMs.toStringAsFixed(1)} ms',
                  ),
                  _row('CV Macro F1', meta.modelCvMacroF1.toStringAsFixed(3)),
                ],
              ),
            ),

            if (result.disclaimer.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8E1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.info_outline,
                      size: 18,
                      color: Color(0xFF8D6E00),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        result.disclaimer,
                        style: textTheme.bodySmall?.copyWith(
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _heroCard(String predictedClass, double confidence) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Hasil Prediksi',
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 4),
          Text(
            predictedClass,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Confidence ${confidence.toStringAsFixed(1)}%',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: (confidence / 100).clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: Colors.white24,
              color: AppColors.accent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _probRow(String label, double p, bool isTop) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontWeight: isTop ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
              Text(
                '${p.toStringAsFixed(1)}%',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: (p / 100).clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: AppColors.background,
              color: isTop ? AppColors.primary : AppColors.accent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statTile(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _pair(Widget a, Widget b) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: a),
          const SizedBox(width: 12),
          Expanded(child: b),
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: AppColors.textMuted),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
