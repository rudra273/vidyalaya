import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme.dart';
import '../../data/seed/diagrams_data.dart';
import '../../providers/regional_language_provider.dart';

class DiagramViewerScreen extends ConsumerWidget {
  final Diagram diagram;

  const DiagramViewerScreen({super.key, required this.diagram});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(regionalLanguageProvider);
    final localizedTitle = switch (lang) {
      RegionalLanguage.english => diagram.titleEn,
      RegionalLanguage.odia => diagram.titleOr,
      RegionalLanguage.hindi => diagram.titleHi,
    };
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          localizedTitle,
          style: const TextStyle(
            color: Colors.white,
            fontSize: AppFontSize.content,
          ),
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
