import 'dart:io';
import 'package:flutter/material.dart';
import '../models/comparison_model.dart';
import '../services/api_service.dart';
import '../theme.dart';

class ComparisonScreen extends StatefulWidget {
  final File image;
  final String classifier;

  const ComparisonScreen({
    super.key,
    required this.image,
    required this.classifier,
  });

  @override
  State<ComparisonScreen> createState() => _ComparisonScreenState();
}

class _ComparisonScreenState extends State<ComparisonScreen> {
  final _api = RiceLeafApiService();
  late Future<ComparisonResult> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<ComparisonResult> _load() async {
    final json = await _api.comparePipelines(
      imageFile: widget.image,
      classifier: widget.classifier,
      brightnessShift: -0.20, // uji penurunan cahaya 20%, sesuai spesifikasi
    );
    return ComparisonResult.fromJson(json);
  }

  void _retry() => setState(() => _future = _load());

  // Skor bisa 0-1 atau persen. Nilai negatif (penurunan) ikut dinormalisasi.
  double _pct(double v) => v.abs() <= 1.0 ? v * 100 : v;

  String _signed(double v) =>
      '${v >= 0 ? '+' : ''}${v.toStringAsFixed(1)}%';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Komparasi Pipeline')),
      body: SafeArea(
        child: FutureBuilder<ComparisonResult>(
          future: _future,
          builder: (context, snap) {
            if (snap.connectionState != ConnectionState.done) {
              return const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 12),
                    Text('Menjalankan 4 pipeline...'),
                  ],
                ),
              );
            }
            if (snap.hasError) {
              debugPrint('Komparasi gagal: ${snap.error}');
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Gagal memuat komparasi. Periksa koneksi ke server.',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: _retry,
                        child: const Text('Coba lagi'),
                      ),
                    ],
                  ),
                ),
              );
            }

            final r = snap.data!;
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                SectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Kondisi uji: ${r.condition}',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Model: ${r.classifier}',
                        style: const TextStyle(color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                if (r.insight.isNotEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      r.insight,
                      style: const TextStyle(color: AppColors.primaryDark),
                    ),
                  ),
                const SizedBox(height: 12),
                for (final item in r.items) ...[
                  _pipelineCard(item),
                  const SizedBox(height: 12),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _pipelineCard(PipelineComparison item) {
    final isP1 = item.pipeline == 'P1';
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: isP1 ? Border.all(color: AppColors.primary, width: 2) : null,
      ),
      child: SectionCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Pipeline ${item.pipeline}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: AppColors.primaryDark,
                  ),
                ),
                if (isP1) ...[
                  const SizedBox(width: 8),
                  const Text(
                    '(usulan)',
                    style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                  ),
                ],
                const Spacer(),
                Icon(
                  item.isConsistent
                      ? Icons.check_circle
                      : Icons.warning_amber_rounded,
                  color: item.isConsistent
                      ? AppColors.primary
                      : Colors.orange.shade800,
                  size: 20,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _side(
                    'Citra bersih',
                    item.cleanClass,
                    _pct(item.cleanConfidence),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _side(
                    'Citra terganggu',
                    item.perturbedClass,
                    _pct(item.perturbedConfidence),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Perubahan keyakinan: ${_signed(_pct(item.confidenceDrop))}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _side(String title, String cls, double pct) {
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
            title,
            style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
          ),
          const SizedBox(height: 4),
          Text(cls, style: const TextStyle(fontWeight: FontWeight.w700)),
          Text('${pct.toStringAsFixed(1)}%'),
        ],
      ),
    );
  }
}
