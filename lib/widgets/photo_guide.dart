import 'package:flutter/material.dart';
import '../theme.dart';

const _tips = [
  'Dekatkan kamera ke daun, sampai daun memenuhi sebagian besar bingkai.',
  'Pastikan cahaya merata. Hindari bayangan keras dan cahaya yang terlalu terang.',
  'Gunakan latar belakang sederhana, sebaiknya seragam.',
  'Pastikan foto tidak blur. Tahan kamera tetap saat memotret.',
  'Pilih bagian daun yang bercaknya terlihat jelas.',
  'Format yang diterima: JPG atau PNG, maksimal 10 MB. File PDF belum didukung.',
];

Future<void> showPhotoGuide(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (_) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionTitle('Panduan Foto'),
            const SizedBox(height: 12),
            for (final tip in _tips)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.check_circle_outline,
                      size: 18,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: Text(tip)),
                  ],
                ),
              ),
          ],
        ),
      ),
    ),
  );
}
