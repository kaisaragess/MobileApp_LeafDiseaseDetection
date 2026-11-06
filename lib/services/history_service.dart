import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/history_entry.dart';

class HistoryService {
  static const _key = 'riwayat_diagnosis';
  static const _maxEntries = 50;

  /// Naik setiap kali riwayat berubah, supaya layar lain ikut memuat ulang.
  static final ValueNotifier<int> changes = ValueNotifier<int>(0);

  static Future<List<HistoryEntry>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    final list = <HistoryEntry>[];
    for (final s in raw) {
      try {
        list.add(HistoryEntry.fromJson(jsonDecode(s) as Map<String, dynamic>));
      } catch (e) {
        debugPrint('Entri riwayat rusak dilewati: $e');
      }
    }
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  static Future<void> _write(List<HistoryEntry> list) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _key,
      list.map((e) => jsonEncode(e.toJson())).toList(),
    );
    changes.value++;
  }

  static Future<void> add(HistoryEntry entry) async {
    final list = await load();
    list.insert(0, entry);
    while (list.length > _maxEntries) {
      final old = list.removeLast();
      await _deleteImage(old.imagePath);
    }
    await _write(list);
  }

  static Future<void> remove(String id) async {
    final list = await load();
    for (final e in list.where((x) => x.id == id)) {
      await _deleteImage(e.imagePath);
    }
    list.removeWhere((x) => x.id == id);
    await _write(list);
  }

  static Future<void> clear() async {
    final list = await load();
    for (final e in list) {
      await _deleteImage(e.imagePath);
    }
    await _write([]);
  }

  /// Menyalin foto ke folder dokumen privat aplikasi, lalu mengembalikan path-nya.
  static Future<String> saveImageCopy(File src, String id) async {
    final dir = await getApplicationDocumentsDirectory();
    final folder = Directory('${dir.path}/riwayat');
    if (!await folder.exists()) {
      await folder.create(recursive: true);
    }
    final ext = src.path.split('.').last.toLowerCase();
    final dest = await src.copy('${folder.path}/$id.$ext');
    return dest.path;
  }

  static Future<void> _deleteImage(String path) async {
    try {
      final f = File(path);
      if (await f.exists()) await f.delete();
    } catch (e) {
      debugPrint('Gagal menghapus foto riwayat: $e');
    }
  }
}
