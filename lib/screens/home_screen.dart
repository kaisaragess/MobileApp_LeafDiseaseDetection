import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/predict_settings.dart';
import '../models/rice_disease_model.dart';
import '../services/api_service.dart';
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

  Future<void> _checkServer() async {
    setState(() => _serverOk = null);
    final ok = await _api.checkHealth();
    if (!mounted) return;
    setState(() => _serverOk = ok);
  }

  Future<void> _pick(ImageSource source) async {
    final picked = await _picker.pickImage(source: source, imageQuality: 90);
    if (picked == null) return;
    setState(() => _image = File(picked.path));
  }

  Future<void> _openSettings() async {
    final result = await Navigator.push<PredictSettings>(
      context,
      MaterialPageRoute(builder: (_) => SettingsScreen(settings: _settings)),
    );
    if (result != null) setState(() => _settings = result);
  }

  Future<void> _diagnose() async {
    if (_image == null) return;
    setState(() => _loading = true);
    try {
      final result = await _api.predictLeafDisease(
        imageFile: _image!,
        settings: _settings,
      );
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ResultScreen(image: _image!, result: result),
        ),
      );
    } on NonLeafException catch (e) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
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
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Widget _statusChip() {
    final Color color;
    final String label;
    final IconData icon;
    if (_serverOk == null) {
      color = Colors.orange;
      label = 'Mengecek server...';
      icon = Icons.sync;
    } else if (_serverOk!) {
      color = Colors.green;
      label = 'Server terhubung';
      icon = Icons.check_circle;
    } else {
      color = Colors.red;
      label = 'Server tidak terjangkau (ketuk untuk coba lagi)';
      icon = Icons.error;
    }
    return ActionChip(
      avatar: Icon(icon, size: 18, color: color),
      label: Text(label),
      onPressed: _checkServer,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Deteksi Penyakit Daun Padi'),
        actions: [
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
            Align(alignment: Alignment.centerLeft, child: _statusChip()),
            const SizedBox(height: 16),
            AspectRatio(
              aspectRatio: 4 / 3,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
                clipBehavior: Clip.antiAlias,
                child: _image == null
                    ? const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.eco, size: 48, color: Colors.grey),
                            SizedBox(height: 8),
                            Text('Belum ada foto daun'),
                          ],
                        ),
                      )
                    : Image.file(_image!, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _loading ? null : () => _pick(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Kamera'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed:
                        _loading ? null : () => _pick(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Galeri'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: (_image == null || _loading) ? null : _diagnose,
              icon: _loading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.search),
              label: Text(_loading ? 'Menganalisis...' : 'Diagnosis'),
            ),
            const SizedBox(height: 16),
            Text(
              'Pipeline ${_settings.pipelineMode} | Model ${_settings.classifier}',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
