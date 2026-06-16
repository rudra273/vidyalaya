import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/seed/diagrams_data.dart';
import '../../providers/regional_language_provider.dart';

class DiagramViewerScreen extends ConsumerWidget {
  final Diagram diagram;

  const DiagramViewerScreen({super.key, required this.diagram});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isHi = ref.watch(regionalLanguageProvider) == RegionalLanguage.hindi;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          '${diagram.titleEn} / ${isHi ? diagram.titleHi : diagram.titleOr}',
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: InteractiveViewer(
          minScale: 1.0,
          maxScale: 5.0,
          child: Center(
            child: Image.asset(
              diagram.imagePath,
              fit: BoxFit.contain,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
        ),
      ),
    );
  }
}
