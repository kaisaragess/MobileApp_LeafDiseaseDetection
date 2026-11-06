import 'dart:io';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../models/history_entry.dart';
import '../services/history_service.dart';
import '../theme.dart';

class ShareScreen extends StatefulWidget {
  const ShareScreen({super.key});

  @override
  State<ShareScreen> createState() => _ShareScreenState();
}

class _ShareScreenState extends State<ShareScreen> {
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

  Future<void> _share(HistoryEntry e) async {
    const subject = 'Hasil diagnosis LeafScan';
    try {
      final hasFile = await File(e.imagePath).exists();
      if (hasFile) {
        await Share.shareXFiles(
          [XFile(e.imagePath)],
          text: e.shareText,
          subject: subject,
        );
      } else {
        await Share.share(e.shareText, subject: subject);
      }
    } catch (err) {
      debugPrint('Gagal membagikan hasil: $err');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal membagikan hasil. Coba lagi.')),
      );
    }
  }

  Widget _tile(HistoryEntry e) {
    return SectionCard(
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.file(
              File(e.imagePath),
              width: 56,
              height: 56,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 56,
                height: 56,
                color: AppColors.background,
                child: const Icon(Icons.eco, color: AppColors.primary),
              ),
            ),
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
                  '${e.confidencePct.toStringAsFixed(1)}% | ${formatDate(e.createdAt)}',
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'Bagikan',
            onPressed: () => _share(e),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bagikan Hasil')),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _items.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'Belum ada hasil untuk dibagikan.\nLakukan diagnosis dulu di tab Diagnosis.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.textMuted),
                      ),
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      const Text(
                        'Pilih hasil yang ingin dibagikan. Foto dan ringkasan akan dikirim lewat aplikasi berbagi di HP kamu.',
                        style: TextStyle(color: AppColors.textMuted),
                      ),
                      const SizedBox(height: 12),
                      for (final e in _items) ...[
                        _tile(e),
                        const SizedBox(height: 10),
                      ],
                    ],
                  ),
      ),
    );
  }
}
