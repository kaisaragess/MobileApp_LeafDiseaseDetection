import 'package:flutter/material.dart';
import '../models/predict_settings.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          DropdownButtonFormField<String>(
            key: ValueKey(_s.pipelineMode),
            initialValue: _s.pipelineMode,
            decoration: const InputDecoration(
              labelText: 'Pipeline',
              border: OutlineInputBorder(),
            ),
            items: PredictSettings.pipelines
                .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                .toList(),
            onChanged: (v) => setState(() => _s = _s.copyWith(pipelineMode: v)),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            key: ValueKey(_s.classifier),
            initialValue: _s.classifier,
            decoration: const InputDecoration(
              labelText: 'Model Klasifikasi',
              border: OutlineInputBorder(),
            ),
            items: PredictSettings.classifiers
                .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                .toList(),
            onChanged: (v) => setState(() => _s = _s.copyWith(classifier: v)),
          ),
          const SizedBox(height: 24),
          Text('Brightness: ${(_s.brightnessShift * 100).round()}%'),
          Slider(
            value: _s.brightnessShift,
            min: -0.20,
            max: 0.20,
            divisions: 40,
            onChanged: (v) =>
                setState(() => _s = _s.copyWith(brightnessShift: v)),
          ),
          Text('Saturation: ${(_s.saturationShift * 100).round()}%'),
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
            onChanged: (v) => setState(() => _s = _s.copyWith(applyBlur: v)),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () =>
                      setState(() => _s = const PredictSettings()),
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

