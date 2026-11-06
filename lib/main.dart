import 'package:flutter/material.dart';
import 'screens/main_shell.dart';
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
      home: const MainShell(),
    );
  }
}
