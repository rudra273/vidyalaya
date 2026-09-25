import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../data/models/virtual_lab.dart';
import '../../providers/core_providers.dart';
import '../../providers/regional_language_provider.dart';
import '../../widgets/calm_widgets.dart';
import '../../widgets/regional_language_switch.dart';

class VirtualLabScreen extends ConsumerStatefulWidget {
  const VirtualLabScreen({super.key});

  @override
  ConsumerState<VirtualLabScreen> createState() => _VirtualLabScreenState();
}

class _VirtualLabScreenState extends ConsumerState<VirtualLabScreen> {
  String _labId = 'circuit';
  int _cells = 1;
  int _resistance = 6;
  bool _closed = false;
  String _sample = 'water';
  String? _prediction;
  LabAttempt? _result;
  List<LabAttempt> _history = [];
  bool _saving = false;
  late String _sessionId;

  @override
  void initState() {
    super.initState();
    _history = ref.read(userPrefsRepositoryProvider).getLabAttempts();
    _sessionId = newLabSessionId();
    ref.listenManual(userPrefsRepositoryProvider, (previous, next) {
      setState(() {
        _clearExperiment();
        _sessionId = newLabSessionId();
        _history = next.getLabAttempts();
        _saving = false;
      });
    });
  }

  void _clearExperiment() {
    _prediction = null;
    _result = null;
    _cells = 1;
    _resistance = 6;
    _closed = false;
    _sample = 'water';
  }

  void _reset() {
    if (_saving) return;
    setState(() {
      _clearExperiment();
      _sessionId = newLabSessionId();
    });
  }

  void _selectLab(String labId) {
    if (_labId == labId || _saving) return;
    setState(() {
      _clearExperiment();
      _labId = labId;
      _sessionId = newLabSessionId();
    });
  }

  Future<void> _observe() async {
    final prediction = _prediction;
    if (prediction == null || _saving) return;
    final controls = _labId == 'circuit'
        ? <String, Object>{
            'cells': _cells,
            'resistance_ohms': _resistance,
            'closed': _closed,
          }
        : <String, Object>{'sample': _sample};
    final attempt = LabAttempt.create(
      labId: _labId,
      prediction: prediction,
      controls: controls,
      clientSessionId: _sessionId,
    );
    setState(() => _saving = true);
    final repository = ref.read(userPrefsRepositoryProvider);
    try {
      await repository.saveLabAttempt(attempt);
      if (!mounted || ref.read(userPrefsRepositoryProvider) != repository) {
        return;
      }
      setState(() {
        _result = attempt;
        _history = repository.getLabAttempts();
      });
    } catch (_) {
      if (mounted && ref.read(userPrefsRepositoryProvider) == repository) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not save this attempt. Please try again.'),
          ),
        );
      }
    } finally {
      if (mounted && ref.read(userPrefsRepositoryProvider) == repository) {
        setState(() {
          _history = repository.getLabAttempts();
          _saving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final circuit = _labId == 'circuit';
    final observation = _result?.observation;
    final disabledMotion = MediaQuery.of(context).disableAnimations;
    final colorScheme = Theme.of(context).colorScheme;
    final completed = _history.where((item) => item.labId == _labId).length;
    final lang = ref.watch(regionalLanguageProvider);
    String word(Object? key) => labWord('$key', lang);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Virtual Science Lab'),
        actions: const [RegionalLanguageSwitch()],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go('/explore'),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenPadding,
            12,
            AppSpacing.screenPadding,
            32,
          ),
          children: [
            Text(
              'CLASS 7 · SCIENCE · CHAPTER ${circuit ? 3 : 2} · BETA',
              style: Theme.of(context).textTheme.labelSmall,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('Circuit'),
                  selected: circuit,
                  onSelected: _saving ? null : (_) => _selectLab('circuit'),
                ),
                ChoiceChip(
                  label: const Text('Indicator'),
                  selected: !circuit,
                  onSelected: _saving ? null : (_) => _selectLab('indicator'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              circuit ? 'Build a simple circuit' : 'Test an indicator',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 6),
            Text(
              labInstructions[_labId]!.of(lang),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Semantics(
              label: circuit
                  ? 'Circuit diagram with $_cells battery cell${_cells == 1 ? '' : 's'}, $_resistance ohm resistance, and an ${_closed ? 'closed' : 'open'} switch. ${observation?['brightness'] ?? 'No observation yet'} bulb.'
                  : 'Indicator beaker. ${observation?['color'] ?? 'Clear'} sample.',
              child: AnimatedContainer(
                duration: disabledMotion
                    ? Duration.zero
                    : const Duration(milliseconds: 280),
                height: 180,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: CustomPaint(
                  painter: circuit
                      ? _CircuitPainter(
                          color: colorScheme.primary,
                          closed: _closed,
                          cells: _cells,
                          resistance: _resistance,
                          brightness:
                              observation?['brightness'] as String? ?? 'off',
                        )
                      : _BeakerPainter(
                          color: switch (observation?['color']) {
                            'red' => Colors.red.shade400,
                            'green' => Colors.green.shade400,
                            'blue' => Colors.blue.shade400,
                            _ => colorScheme.primary.withValues(alpha: 0.15),
                          },
                          lineColor: colorScheme.primary,
                        ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SectionHead(
              label: circuit ? 'Set up your circuit' : 'Choose a sample',
            ),
            if (circuit) ...[
              SwitchListTile(
                title: const Text('Switch closed'),
                value: _closed,
                onChanged: _saving
                    ? null
                    : (value) => setState(() {
                        _closed = value;
                        _result = null;
                      }),
              ),
              _ChoiceRow<int>(
                label: 'Battery cells',
                enabled: !_saving,
                values: const [1, 2, 3],
                selected: _cells,
                format: (value) => '$value',
                onSelected: (value) => setState(() {
                  _cells = value;
                  _result = null;
                }),
              ),
              _ChoiceRow<int>(
                label: 'Total resistance',
                enabled: !_saving,
                values: const [3, 6, 9],
                selected: _resistance,
                format: (value) => '$value Ω',
                onSelected: (value) => setState(() {
                  _resistance = value;
                  _result = null;
                }),
              ),
            ] else
              _ChoiceRow<String>(
                label: 'Sample',
                enabled: !_saving,
                values: const ['lemon', 'water', 'soap'],
                selected: _sample,
                format: word,
                onSelected: (value) => setState(() {
                  _sample = value;
                  _result = null;
                }),
              ),
            const SizedBox(height: 18),
            SectionHead(label: 'Make a prediction'),
            Wrap(
              spacing: 8,
              children:
                  (circuit
                          ? const ['off', 'dim', 'bright']
                          : const ['red', 'green', 'blue'])
                      .map(
                        (value) => ChoiceChip(
                          label: Text(word(value)),
                          selected: _prediction == value,
                          onSelected: _saving
                              ? null
                              : (_) => setState(() {
                                  _prediction = value;
                                  _result = null;
                                }),
                        ),
                      )
                      .toList(),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _prediction == null || _saving ? null : _observe,
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: Text(_saving ? 'Saving…' : 'Observe result'),
                  ),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: _saving ? null : _reset,
                  child: const Text('Reset'),
                ),
              ],
            ),
            if (_result != null) ...[
              const SizedBox(height: 20),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _result!.correct
                            ? 'Your prediction was right'
                            : 'See what happened',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        circuit
                            ? 'Bulb: ${word(observation!['brightness'])}\nVoltage: ${observation['voltage_v']} V · Current: ${observation['current_a']} A'
                            : 'Colour: ${word(observation!['color'])} · Approx. pH: ${observation['approx_ph']}\nNature: ${word(observation['nature'])}',
                      ),
                      const SizedBox(height: 8),
                      Text(
                        evaluateLab(
                          _labId,
                          _result!.controls,
                          _result!.prediction,
                        ).explanation.of(lang),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Saved on this device only',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
            ],
            if (completed > 0) ...[
              const SizedBox(height: 20),
              Text(
                '$completed attempt${completed == 1 ? '' : 's'} saved',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ChoiceRow<T> extends StatelessWidget {
  final String label;
  final bool enabled;
  final List<T> values;
  final T selected;
  final String Function(T) format;
  final ValueChanged<T> onSelected;

  const _ChoiceRow({
    required this.label,
    required this.enabled,
    required this.values,
    required this.selected,
    required this.format,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: Theme.of(context).textTheme.bodySmall),
      Wrap(
        spacing: 8,
        children: values
            .map(
              (value) => ChoiceChip(
                label: Text(format(value)),
                selected: value == selected,
                onSelected: enabled ? (_) => onSelected(value) : null,
              ),
            )
            .toList(),
      ),
    ],
  );
}

class _CircuitPainter extends CustomPainter {
  final Color color;
  final bool closed;
  final int cells;
  final int resistance;
  final String brightness;

  const _CircuitPainter({
    required this.color,
    required this.closed,
    required this.cells,
    required this.resistance,
    required this.brightness,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final wire = Paint()
      ..color = color
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;
    final left = size.width * .2;
    final right = size.width * .8;
    final top = size.height * .22;
    final bottom = size.height * .76;
    final middle = (top + bottom) / 2;
    final switchLeft = size.width * .44;
    final switchRight = size.width * .56;
    canvas.drawLine(Offset(left, top), Offset(switchLeft, top), wire);
    canvas.drawLine(Offset(switchRight, top), Offset(right, top), wire);
    canvas.drawLine(
      Offset(switchLeft, top),
      Offset(switchRight, closed ? top : top - 18),
      wire,
    );
    canvas.drawCircle(Offset(switchLeft, top), 3, Paint()..color = color);
    canvas.drawCircle(Offset(switchRight, top), 3, Paint()..color = color);

    // The bulb and resistor interrupt the wire rather than being bypassed.
    canvas.drawLine(Offset(right, top), Offset(right, middle - 25), wire);
    canvas.drawLine(Offset(right, middle + 25), Offset(right, bottom), wire);
    canvas.drawCircle(
      Offset(right, middle),
      25,
      Paint()
        ..color = brightness == 'bright'
            ? Colors.amber.shade300
            : brightness == 'dim'
            ? Colors.amber.shade100
            : Colors.grey.shade300,
    );
    canvas.drawCircle(Offset(right, middle), 25, wire);
    canvas.drawLine(
      Offset(right - 10, middle - 10),
      Offset(right + 10, middle + 10),
      wire,
    );
    canvas.drawLine(
      Offset(right + 10, middle - 10),
      Offset(right - 10, middle + 10),
      wire,
    );

    final resistorLeft = size.width * .42;
    final resistorRight = size.width * .58;
    canvas.drawLine(Offset(left, bottom), Offset(resistorLeft, bottom), wire);
    canvas.drawLine(Offset(resistorRight, bottom), Offset(right, bottom), wire);
    final zigzag = Path()..moveTo(resistorLeft, bottom);
    for (var i = 1; i <= 7; i++) {
      zigzag.lineTo(
        resistorLeft + (resistorRight - resistorLeft) * i / 7,
        i == 7 ? bottom : bottom + (i.isOdd ? -7 : 7),
      );
    }
    canvas.drawPath(zigzag, wire);

    final firstCell = middle - (cells - 1) * 13;
    final lastCell = middle + (cells - 1) * 13;
    canvas.drawLine(Offset(left, top), Offset(left, firstCell - 5), wire);
    canvas.drawLine(Offset(left, lastCell + 5), Offset(left, bottom), wire);
    for (var i = 0; i < cells; i++) {
      final cellCenter = firstCell + i * 26;
      canvas.drawLine(
        Offset(left - 12, cellCenter - 5),
        Offset(left + 12, cellCenter - 5),
        wire,
      );
      canvas.drawLine(
        Offset(left - 7, cellCenter + 5),
        Offset(left + 7, cellCenter + 5),
        wire,
      );
      if (i < cells - 1) {
        canvas.drawLine(
          Offset(left, cellCenter + 5),
          Offset(left, cellCenter + 21),
          wire,
        );
      }
    }

    final label = TextPainter(
      text: TextSpan(
        text: '$resistance Ω',
        style: TextStyle(
          color: color,
          fontSize: AppFontSize.small,
          fontWeight: AppFontWeight.semibold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    label.paint(canvas, Offset((size.width - label.width) / 2, bottom + 8));
  }

  @override
  bool shouldRepaint(_CircuitPainter old) =>
      old.color != color ||
      old.closed != closed ||
      old.cells != cells ||
      old.resistance != resistance ||
      old.brightness != brightness;
}

class _BeakerPainter extends CustomPainter {
  final Color color;
  final Color lineColor;

  const _BeakerPainter({required this.color, required this.lineColor});

  @override
  void paint(Canvas canvas, Size size) {
    final left = size.width * .35;
    final right = size.width * .65;
    final top = size.height * .16;
    final bottom = size.height * .84;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(left + 5, size.height * .5, right - 5, bottom),
        const Radius.circular(8),
      ),
      Paint()..color = color,
    );
    final outline = Paint()
      ..color = lineColor
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;
    final path = Path()
      ..moveTo(left, top)
      ..lineTo(left, bottom - 8)
      ..quadraticBezierTo(left, bottom, left + 8, bottom)
      ..lineTo(right - 8, bottom)
      ..quadraticBezierTo(right, bottom, right, bottom - 8)
      ..lineTo(right, top);
    canvas.drawPath(path, outline);
    canvas.drawLine(Offset(left - 8, top), Offset(right + 8, top), outline);
    canvas.drawCircle(
      Offset(size.width * .5, top - 24),
      7,
      Paint()..color = lineColor,
    );
  }

  @override
  bool shouldRepaint(_BeakerPainter old) =>
      old.color != color || old.lineColor != lineColor;
}
