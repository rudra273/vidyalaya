import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../data/seed/interactive_diagrams_data.dart';
import '../../providers/regional_language_provider.dart';
import '../../widgets/regional_language_switch.dart';

class InteractiveDiagramViewerScreen extends ConsumerStatefulWidget {
  final InteractiveDiagram diagram;

  const InteractiveDiagramViewerScreen({super.key, required this.diagram});

  @override
  ConsumerState<InteractiveDiagramViewerScreen> createState() =>
      _InteractiveDiagramViewerScreenState();
}

class _InteractiveDiagramViewerScreenState
    extends ConsumerState<InteractiveDiagramViewerScreen> {
  final _printKey = GlobalKey();
  final _transform = TransformationController();
  final _labelsScrollController = ScrollController();
  bool _showLabels = true;
  bool _blackAndWhite = false;
  bool _printing = false;
  bool _imageReady = false;
  bool _imageFailed = false;
  int _selectedLabelIndex = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_imageReady && !_imageFailed) _loadImage();
  }

  Future<void> _loadImage() async {
    var failed = false;
    await precacheImage(
      AssetImage(widget.diagram.imagePath),
      context,
      onError: (_, _) => failed = true,
    );
    if (!mounted) return;
    setState(() {
      _imageReady = !failed;
      _imageFailed = failed;
    });
  }

  @override
  void dispose() {
    _transform.dispose();
    _labelsScrollController.dispose();
    super.dispose();
  }

  Future<void> _printDiagram() async {
    if (_printing || !_imageReady) return;
    setState(() => _printing = true);
    try {
      // Capture the complete sheet inside the zoom transform, including native
      // script shaping. Printing therefore preserves the on-screen labels.
      await WidgetsBinding.instance.endOfFrame;
      if (!mounted) return;
      final boundary =
          _printKey.currentContext!.findRenderObject()!
              as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3);
      late final pw.MemoryImage printable;
      try {
        final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
        if (bytes == null) throw StateError('Unable to prepare diagram');
        printable = pw.MemoryImage(bytes.buffer.asUint8List());
      } finally {
        image.dispose();
      }
      await Printing.layoutPdf(
        name: 'Vidya AI - ${widget.diagram.id}',
        onLayout: (format) async {
          final document = pw.Document();
          document.addPage(
            pw.Page(
              pageFormat: format,
              margin: const pw.EdgeInsets.all(24),
              build: (_) =>
                  pw.Center(child: pw.Image(printable, fit: pw.BoxFit.contain)),
            ),
          );
          return document.save();
        },
        format: PdfPageFormat.a4,
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not prepare the print. Please try again.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _printing = false);
    }
  }

  void _explain(InteractiveDiagramLabel label) {
    setState(() => _selectedLabelIndex = widget.diagram.labels.indexOf(label));
  }

  @override
  Widget build(BuildContext context) {
    final diagram = widget.diagram;
    final selectedLanguage = ref.watch(regionalLanguageProvider);
    final language = selectedLanguage == RegionalLanguage.english
        ? DiagramLanguage.english
        : selectedLanguage == RegionalLanguage.hindi
        ? DiagramLanguage.hindi
        : DiagramLanguage.odia;
    return Scaffold(
      appBar: AppBar(
        title: Text(diagram.title.inLanguage(language)),
        actions: const [RegionalLanguageSwitch()],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, bodyConstraints) => Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 4, 12, 5),
                child: Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    FilterChip(
                      label: const Text('Labels'),
                      selected: _showLabels,
                      visualDensity: VisualDensity.compact,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      labelPadding: const EdgeInsets.symmetric(horizontal: 2),
                      onSelected: _printing
                          ? null
                          : (value) => setState(() => _showLabels = value),
                    ),
                    FilterChip(
                      label: const Text('B&W'),
                      selected: _blackAndWhite,
                      visualDensity: VisualDensity.compact,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      labelPadding: const EdgeInsets.symmetric(horizontal: 2),
                      onSelected: _printing
                          ? null
                          : (value) => setState(() => _blackAndWhite = value),
                    ),
                    FilledButton.icon(
                      style: FilledButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 7,
                        ),
                      ),
                      onPressed: _printing || !_imageReady
                          ? null
                          : _printDiagram,
                      icon: const Icon(Icons.print_outlined, size: 17),
                      label: Text(_printing ? 'Preparing…' : 'Print / PDF'),
                    ),
                    Text(
                      'Pinch to zoom',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: bodyConstraints.maxHeight * .62,
                child: _imageFailed
                    ? const Center(child: Text('Could not load this diagram.'))
                    : !_imageReady
                    ? const Center(child: CircularProgressIndicator())
                    : InteractiveViewer(
                        transformationController: _transform,
                        minScale: 1,
                        maxScale: 6,
                        child: Center(
                          child: FittedBox(
                            child: RepaintBoundary(
                              key: _printKey,
                              child: DiagramLabelSheet(
                                diagram: diagram,
                                language: language,
                                showLabels: _showLabels,
                                blackAndWhite: _blackAndWhite,
                                onLabelTap: _explain,
                              ),
                            ),
                          ),
                        ),
                      ),
              ),
              const Divider(height: 1),
              Expanded(
                child: Scrollbar(
                  controller: _labelsScrollController,
                  thumbVisibility: true,
                  trackVisibility: true,
                  interactive: true,
                  scrollbarOrientation: ScrollbarOrientation.left,
                  child: ListView.separated(
                    controller: _labelsScrollController,
                    padding: const EdgeInsets.fromLTRB(24, 8, 12, 16),
                    itemCount: diagram.labels.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final label = diagram.labels[index];
                      final selected = index == _selectedLabelIndex;
                      return Material(
                        color: selected
                            ? Theme.of(context).colorScheme.primaryContainer
                                  .withValues(alpha: 0.45)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(10),
                          onTap: () =>
                              setState(() => _selectedLabelIndex = index),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 9,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  radius: 13,
                                  backgroundColor: Theme.of(
                                    context,
                                  ).colorScheme.primary,
                                  foregroundColor: Theme.of(
                                    context,
                                  ).colorScheme.onPrimary,
                                  child: Text(
                                    '${index + 1}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        label.title.inLanguage(language),
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall
                                            ?.copyWith(
                                              fontWeight: FontWeight.w700,
                                            ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        label.explanation.inLanguage(language),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(height: 1.35),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A fixed-size, white sheet shared by the zoomable view and print output.
/// All callouts sit outside the image; only thin leaders cross the artwork.
class DiagramLabelSheet extends StatelessWidget {
  final InteractiveDiagram diagram;
  final DiagramLanguage language;
  final bool showLabels;
  final bool blackAndWhite;
  final ValueChanged<InteractiveDiagramLabel>? onLabelTap;

  const DiagramLabelSheet({
    super.key,
    required this.diagram,
    required this.language,
    this.showLabels = true,
    this.blackAndWhite = false,
    this.onLabelTap,
  });

  @override
  Widget build(BuildContext context) {
    final imageHeight = 600 / diagram.aspectRatio;
    final imageRect = Rect.fromLTWH(200, 230, 600, imageHeight);
    final size = Size(1000, imageHeight + 440);
    final callouts = diagramCallouts(diagram, imageRect);
    Widget image = Image.asset(diagram.imagePath, fit: BoxFit.contain);
    if (blackAndWhite) {
      image = ColorFiltered(
        colorFilter: const ColorFilter.matrix([
          .2126,
          .7152,
          .0722,
          0,
          0,
          .2126,
          .7152,
          .0722,
          0,
          0,
          .2126,
          .7152,
          .0722,
          0,
          0,
          0,
          0,
          0,
          1,
          0,
        ]),
        child: image,
      );
    }
    return SizedBox(
      width: size.width,
      height: size.height,
      child: ColoredBox(
        color: Colors.white,
        child: DefaultTextStyle(
          style: const TextStyle(
            color: Colors.black,
            fontSize: 24,
            height: 1.25,
          ),
          child: Stack(
            children: [
              Positioned(
                left: 24,
                right: 24,
                top: 24,
                child: Text(
                  diagram.title.inLanguage(language),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 38,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Positioned.fromRect(rect: imageRect, child: image),
              if (showLabels) ...[
                Positioned.fill(
                  child: CustomPaint(painter: _LeaderPainter(callouts)),
                ),
                for (final callout in callouts)
                  Positioned.fromRect(
                    rect: callout.bounds,
                    child: Semantics(
                      button: true,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => onLabelTap?.call(callout.label),
                        child: Center(
                          child: Text(
                            callout.label.title.inLanguage(language),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
              const Positioned(
                bottom: 18,
                left: 24,
                right: 24,
                child: Text(
                  'Vidya AI',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DiagramCallout {
  final InteractiveDiagramLabel label;
  final Rect bounds;
  final Offset start;
  final Offset elbow;
  final Offset target;

  const DiagramCallout(
    this.label,
    this.bounds,
    this.start,
    this.elbow,
    this.target,
  );
}

/// Spread callouts around the image edges, keeping text outside the artwork.
List<DiagramCallout> diagramCallouts(InteractiveDiagram diagram, Rect image) {
  final groups = List.generate(4, (_) => <InteractiveDiagramLabel>[]);
  for (final label in diagram.labels) {
    final p = label.position;
    final distances = [p.dx, 1 - p.dx, p.dy, 1 - p.dy];
    var side = 0;
    for (var i = 1; i < 4; i++) {
      if (distances[i] < distances[side]) side = i;
    }
    groups[side].add(label);
  }
  final result = <DiagramCallout>[];
  for (var side = 0; side < 4; side++) {
    final vertical = side < 2;
    final labels = groups[side]
      ..sort(
        (a, b) => vertical
            ? a.position.dy.compareTo(b.position.dy)
            : a.position.dx.compareTo(b.position.dx),
      );
    for (var i = 0; i < labels.length; i++) {
      final label = labels[i];
      final t = (i + .5) / labels.length;
      final target = Offset(
        image.left + label.position.dx * image.width,
        image.top + label.position.dy * image.height,
      );
      late Rect bounds;
      late Offset start;
      late Offset elbow;
      if (vertical) {
        final extent = math.max(image.height, labels.length * 132.0);
        final y = image.center.dy + extent * (t - .5);
        bounds = Rect.fromLTWH(side == 0 ? 8 : 852, y - 60, 140, 120);
        start = Offset(side == 0 ? bounds.right : bounds.left, y);
        elbow = Offset(side == 0 ? image.left - 10 : image.right + 10, y);
      } else {
        final slotWidth = image.width / labels.length;
        final x = image.left + image.width * t;
        bounds = Rect.fromLTWH(
          x - slotWidth / 2 + 6,
          side == 2 ? 95 : image.bottom + 55,
          slotWidth - 12,
          120,
        );
        start = Offset(x, side == 2 ? bounds.bottom : bounds.top);
        elbow = Offset(x, side == 2 ? image.top - 10 : image.bottom + 20);
      }
      result.add(DiagramCallout(label, bounds, start, elbow, target));
    }
  }
  return result;
}

class _LeaderPainter extends CustomPainter {
  final List<DiagramCallout> callouts;
  _LeaderPainter(this.callouts);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xff334155)
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke;
    for (final callout in callouts) {
      canvas.drawPath(
        Path()
          ..moveTo(callout.start.dx, callout.start.dy)
          ..lineTo(callout.elbow.dx, callout.elbow.dy)
          ..lineTo(callout.target.dx, callout.target.dy),
        paint,
      );
      final angle = (callout.target - callout.elbow).direction;
      for (final offset in [-.45, .45]) {
        canvas.drawLine(
          callout.target,
          callout.target -
              Offset(math.cos(angle + offset), math.sin(angle + offset)) * 9,
          paint,
        );
      }
      canvas.drawCircle(
        callout.target,
        2,
        Paint()..color = const Color(0xff334155),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _LeaderPainter oldDelegate) => true;
}
