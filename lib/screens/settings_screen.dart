import 'package:flutter/material.dart';
import '../models/predict_settings.dart';
import '../theme.dart';

class SettingsScreen extends StatefulWidget {
  final PredictSettings settings;
  const SettingsScreen({super.key, required this.settings});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late PredictSettings _s;

  @override
  void initState() {
    super.initState();
    _s = widget.settings;
  }

  String _signed(double v) =>
      '${v > 0 ? '+' : ''}${(v * 100).round()}%';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionTitle('Model'),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  key: ValueKey(_s.pipelineMode),
                  initialValue: _s.pipelineMode,
                  decoration: const InputDecoration(labelText: 'Pipeline'),
                  items: PredictSettings.pipelines
                      .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                      .toList(),
                  onChanged: (v) =>
                      setState(() => _s = _s.copyWith(pipelineMode: v)),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  key: ValueKey(_s.classifier),
                  initialValue: _s.classifier,
                  decoration: const InputDecoration(
                    labelText: 'Model Klasifikasi',
                  ),
                  items: PredictSettings.classifiers
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (v) =>
                      setState(() => _s = _s.copyWith(classifier: v)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionTitle('Pra-pemrosesan'),
                const SizedBox(height: 8),
                Text('Kecerahan: ${_signed(_s.brightnessShift)}'),
                Slider(
                  value: _s.brightnessShift,
                  min: -0.20,
                  max: 0.20,
                  divisions: 40,
                  onChanged: (v) =>
                      setState(() => _s = _s.copyWith(brightnessShift: v)),
                ),
                const SizedBox(height: 4),
                Text('Saturasi: ${_signed(_s.saturationShift)}'),
                Slider(
                  value: _s.saturationShift,
                  min: -0.15,
                  max: 0.15,
                  divisions: 30,
                  onChanged: (v) =>
                      setState(() => _s = _s.copyWith(saturationShift: v)),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Terapkan blur'),
                  value: _s.applyBlur,
                  onChanged: (v) =>
                      setState(() => _s = _s.copyWith(applyBlur: v)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => setState(() => _s = const PredictSettings()),
                  child: const Text('Reset'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: () => Navigator.pop(context, _s),
                  child: const Text('Simpan'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
