import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';

/// Menampilkan gambar Data URI Base64 (data:image/jpeg;base64,...).
/// Tinggi mengikuti rasio asli gambar (BoxFit.contain, tidak terpotong).
Widget buildBase64Image(String dataUri, {double width = 260}) {
  try {
    final clean = dataUri.contains(',') ? dataUri.split(',')[1] : dataUri;
    final Uint8List bytes = base64Decode(clean);
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.memory(bytes, width: width, fit: BoxFit.contain),
    );
  } catch (_) {
    return Container(
      width: width,
      height: width / 3,
      color: Colors.grey[300],
      child: const Icon(Icons.broken_image, color: Colors.grey),
    );
  }
}
