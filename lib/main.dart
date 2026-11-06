import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'theme.dart';

void main() => runApp(const LeafDiseaseApp());

class LeafDiseaseApp extends StatelessWidget {
  const LeafDiseaseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LeafScan',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: const HomeScreen(),
    );
  }
}
