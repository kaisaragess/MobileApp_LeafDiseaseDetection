import 'dart:io';

class UploadValidator {
  static const int maxBytes = 10 * 1024 * 1024; // 10 MB, sesuai spesifikasi
  static const List<String> allowedExtensions = ['jpg', 'jpeg', 'png'];

  /// Mengembalikan pesan error untuk pengguna, atau null jika file valid.
  static Future<String?> validate(File file) async {
    final ext = file.path.split('.').last.toLowerCase();
    if (!allowedExtensions.contains(ext)) {
      return 'Format tidak didukung. Gunakan foto JPG atau PNG.';
    }

    final size = await file.length();
    if (size == 0) return 'File kosong.';
    if (size > maxBytes) return 'Ukuran foto melebihi 10 MB.';

    final header = await file
        .openRead(0, 8)
        .fold<List<int>>([], (prev, chunk) => [...prev, ...chunk]);
    if (!_isJpeg(header) && !_isPng(header)) {
      return 'Isi file bukan foto JPG atau PNG yang valid.';
    }
    return null;
  }

  static bool _isJpeg(List<int> b) =>
      b.length >= 3 && b[0] == 0xFF && b[1] == 0xD8 && b[2] == 0xFF;

  static bool _isPng(List<int> b) =>
      b.length >= 4 && b[0] == 0x89 && b[1] == 0x50 && b[2] == 0x4E && b[3] == 0x47;
}
