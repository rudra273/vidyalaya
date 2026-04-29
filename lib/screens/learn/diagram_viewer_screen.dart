import 'package:flutter/material.dart';
import '../../data/seed/diagrams_data.dart';

class DiagramViewerScreen extends StatelessWidget {
  final Diagram diagram;

  const DiagramViewerScreen({super.key, required this.diagram});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          '${diagram.titleEn} / ${diagram.titleOr}',
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
