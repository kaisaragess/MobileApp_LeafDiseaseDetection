import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';

/// Menampilkan gambar Data URI Base64 (data:image/jpeg;base64,...).
/// Tinggi dibuat tetap (default 140 px), lebar mengikuti rasio asli gambar.
Widget buildBase64Image(String dataUri, {double height = 140}) {
  try {
    final clean = dataUri.contains(',') ? dataUri.split(',')[1] : dataUri;
    final Uint8List bytes = base64Decode(clean);
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.memory(bytes, height: height, fit: BoxFit.contain),
    );
  } catch (_) {
    return Container(
      width: height,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Icon(Icons.broken_image, color: Colors.grey),
    );
  }
}
