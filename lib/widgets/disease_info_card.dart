import 'package:flutter/material.dart';
import '../data/disease_info.dart';
import '../theme.dart';

class DiseaseInfoCard extends StatelessWidget {
  final String label;

  const DiseaseInfoCard({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    final info = DiseaseInfo.forClass(label);
    if (info == null) return const SizedBox.shrink();

    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionTitle(info.nama),
          const SizedBox(height: 10),
          const _Label('Penyebab'),
          Text(info.penyebab),
          const SizedBox(height: 8),
          const _Label('Gejala'),
          Text(info.gejala),
          const SizedBox(height: 12),
          const _Label('Saran penanganan'),
          const SizedBox(height: 4),
          for (final s in info.saran)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.check_circle_outline,
                    size: 18,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Text(s)),
                ],
              ),
            ),
          const SizedBox(height: 4),
          Text(
            DiseaseInfo.disclaimer,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textMuted,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;

  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: AppColors.textMuted,
          fontSize: 12,
        ),
      ),
    );
  }
}
