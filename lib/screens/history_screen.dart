import 'dart:io';
import 'package:flutter/material.dart';
import '../models/history_entry.dart';
import '../services/history_service.dart';
import '../theme.dart';
import '../widgets/disease_info_card.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<HistoryEntry> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    HistoryService.changes.addListener(_reload);
    _reload();
  }

  @override
  void dispose() {
    HistoryService.changes.removeListener(_reload);
    super.dispose();
  }

  Future<void> _reload() async {
    final items = await HistoryService.load();
    if (!mounted) return;
    setState(() {
      _items = items;
      _loading = false;
    });
  }

  Future<void> _confirmClear() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus semua riwayat?'),
        content: const Text(
          'Semua hasil dan foto yang tersimpan di perangkat ini akan dihapus.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await HistoryService.clear();
    }
  }

  void _dismiss(HistoryEntry e) {
    // Hapus dari daftar lokal dulu agar Dismissible tidak error.
    setState(() => _items.removeWhere((x) => x.id == e.id));
    HistoryService.remove(e.id);
  }

  void _showDetail(HistoryEntry e) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _photo(e.imagePath, width: double.infinity, height: 180),
              ),
              const SizedBox(height: 12),
              Text(
                e.predictedClass,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryDark,
                ),
              ),
              Text(
                'Confidence ${e.confidencePct.toStringAsFixed(1)}% | ${formatDate(e.createdAt)}',
                style: const TextStyle(color: AppColors.textMuted),
              ),
              Text(
                'Pipeline ${e.pipeline} | Model ${e.classifier}',
                style: const TextStyle(color: AppColors.textMuted),
              ),
              const SizedBox(height: 12),
              for (final entry in e.probabilitiesPct.entries)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(entry.key),
                      Text('${entry.value.toStringAsFixed(1)}%'),
                    ],
                  ),
                ),
              const SizedBox(height: 12),
              DiseaseInfoCard(label: e.predictedClass),
            ],
          ),
        ),
      ),
    );
  }

  Widget _photo(String path, {double? width, double? height}) {
    return Image.file(
      File(path),
      width: width,
      height: height,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Container(
        width: width,
        height: height,
        color: AppColors.primary.withValues(alpha: 0.08),
        child: const Icon(Icons.eco, color: AppColors.primary),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat'),
        actions: [
          if (_items.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined),
              tooltip: 'Hapus semua',
              onPressed: _confirmClear,
            ),
        ],
      ),
      body: SafeArea(child: _body()),
    );
  }

  Widget _body() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_items.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.history, size: 56, color: AppColors.textMuted),
              SizedBox(height: 12),
              Text(
                'Belum ada riwayat diagnosis.\nHasil diagnosis akan tersimpan di sini.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textMuted),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _items.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, i) {
        final e = _items[i];
        return Dismissible(
          key: ValueKey(e.id),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            decoration: BoxDecoration(
              color: Colors.red.shade700,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          onDismissed: (_) => _dismiss(e),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => _showDetail(e),
            child: SectionCard(
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: _photo(e.imagePath, width: 64, height: 64),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          e.predictedClass,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        Text(
                          '${e.confidencePct.toStringAsFixed(1)}% | ${e.classifier}',
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          formatDate(e.createdAt),
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: AppColors.textMuted),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
