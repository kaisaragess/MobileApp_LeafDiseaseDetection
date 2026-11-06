import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/history_entry.dart';
import '../models/predict_settings.dart';
import '../models/rice_disease_model.dart';
import '../services/api_service.dart';
import '../services/history_service.dart';
import '../services/upload_validator.dart';
import '../theme.dart';
import '../widgets/app_logo.dart';
import '../widgets/photo_guide.dart';
import 'comparison_screen.dart';
import 'result_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _api = RiceLeafApiService();
  final _picker = ImagePicker();

  PredictSettings _settings = const PredictSettings();
  File? _image;
  bool? _serverOk; // null = sedang dicek
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _checkServer();
  }

  // Skor bisa 0-1 atau 0-100. Normalisasi ke persen.
  double _pct(double v) => v.abs() <= 1.0 ? v * 100 : v;

  Future<void> _checkServer() async {
    setState(() => _serverOk = null);
    final ok = await _api.checkHealth();
    if (!mounted) return;
    setState(() => _serverOk = ok);
  }

  Future<void> _pick(ImageSource source) async {
    final picked = await _picker.pickImage(source: source, imageQuality: 90);
    if (picked == null) return;
    final file = File(picked.path);
    final error = await UploadValidator.validate(file);
    if (!mounted) return;
    if (error != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    setState(() => _image = file);
  }

  Future<void> _openSettings() async {
    final result = await Navigator.push<PredictSettings>(
      context,
      MaterialPageRoute(builder: (_) => SettingsScreen(settings: _settings)),
    );
    if (result != null) setState(() => _settings = result);
  }

  Future<void> _saveToHistory(File image, PredictResponse r) async {
    try {
      final id = DateTime.now().millisecondsSinceEpoch.toString();
      final path = await HistoryService.saveImageCopy(image, id);
      final probs = r.prediction.probabilities.map(
        (k, v) => MapEntry(k, _pct(v)),
      );
      await HistoryService.add(
        HistoryEntry(
          id: id,
          createdAt: DateTime.now(),
          predictedClass: r.prediction.predictedClass,
          confidencePct: _pct(r.prediction.confidenceScore),
          pipeline: r.meta.pipelineUsed,
          classifier: r.meta.classifierUsed,
          probabilitiesPct: probs,
          imagePath: path,
        ),
      );
    } catch (e) {
      debugPrint('Gagal menyimpan riwayat: $e');
    }
  }

  Future<void> _diagnose() async {
    final image = _image;
    if (image == null) return;
    setState(() => _loading = true);
    try {
      final result = await _api.predictLeafDisease(
        imageFile: image,
        settings: _settings,
      );
      await _saveToHistory(image, result);
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ResultScreen(image: image, result: result),
        ),
      );
    } on NonLeafException catch (e) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          icon: const Icon(
            Icons.eco_outlined,
            color: AppColors.primary,
            size: 36,
          ),
          title: const Text('Objek Bukan Daun Padi'),
          content: Text(e.message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Foto Ulang'),
            ),
          ],
        ),
      );
    } catch (e) {
      // Detail teknis hanya ke log, pengguna melihat pesan umum.
      debugPrint('Diagnosis gagal: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Gagal menghubungi server. Periksa koneksi lalu coba lagi.',
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _openComparison(File image) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            ComparisonScreen(image: image, classifier: _settings.classifier),
      ),
    );
  }

  Widget _statusChip() {
    final Color color;
    final String label;
    final IconData icon;
    if (_serverOk == null) {
      color = Colors.orange.shade800;
      label = 'Mengecek server...';
      icon = Icons.sync;
    } else if (_serverOk!) {
      color = AppColors.primary;
      label = 'Server terhubung';
      icon = Icons.check_circle;
    } else {
      color = Colors.red.shade700;
      label = 'Server tidak terjangkau. Ketuk untuk coba lagi';
      icon = Icons.error;
    }
    return Material(
      color: color.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: _checkServer,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: AppColors.primary.withValues(alpha: 0.08),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.eco, size: 56, color: AppColors.primary),
          SizedBox(height: 8),
          Text(
            'Belum ada foto daun',
            style: TextStyle(
              color: AppColors.textMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 2),
          Text(
            'Ambil foto atau pilih dari galeri',
            style: TextStyle(color: AppColors.textMuted, fontSize: 12),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final busy = _loading;
    final hasImage = _image != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('LeafScan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            tooltip: 'Panduan foto',
            onPressed: () => showPhotoGuide(context),
          ),
          IconButton(
            icon: const Icon(Icons.tune),
            tooltip: 'Pengaturan',
            onPressed: _openSettings,
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Center(child: AppLogo(height: 110)),
            const SizedBox(height: 8),
            Center(child: _statusChip()),
            const SizedBox(height: 20),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: AspectRatio(
                aspectRatio: 4 / 3,
                child: hasImage
                    ? Image.file(_image!, fit: BoxFit.cover)
                    : _placeholder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: busy ? null : () => _pick(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Kamera'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: busy ? null : () => _pick(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Galeri'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: (!hasImage || busy) ? null : _diagnose,
              icon: busy
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.search),
              label: Text(busy ? 'Menganalisis...' : 'Diagnosis'),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: (!hasImage || busy)
                  ? null
                  : () => _openComparison(_image!),
              icon: const Icon(Icons.compare_arrows),
              label: const Text('Bandingkan 4 Pipeline'),
            ),
            const SizedBox(height: 16),
            SectionCard(
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.tune, color: AppColors.primary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Pengaturan analisis',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Pipeline ${_settings.pipelineMode} | Model ${_settings.classifier}',
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: _openSettings,
                    child: const Text('Ubah'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
