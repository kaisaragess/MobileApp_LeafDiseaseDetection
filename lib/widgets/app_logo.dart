import 'package:flutter/material.dart';
import '../theme.dart';

class AppLogo extends StatelessWidget {
  final double height;

  const AppLogo({super.key, this.height = 120});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/logo_full.png',
      height: height,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return Icon(Icons.eco, size: height, color: AppColors.primary);
      },
    );
  }
}
