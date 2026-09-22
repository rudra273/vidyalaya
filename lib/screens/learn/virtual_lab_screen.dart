import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../data/models/virtual_lab.dart';
import '../../data/repositories/user_prefs_repository.dart';
import '../../providers/auth_provider.dart';
import '../../providers/core_providers.dart';
import '../../providers/lab_provider.dart';
import '../../widgets/calm_widgets.dart';

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

  @override
  void initState() {
    super.initState();
    _history = ref.read(userPrefsRepositoryProvider).getLabAttempts();
  }

  void _reset() {
    setState(() {
      _prediction = null;
      _result = null;
      _cells = 1;
      _resistance = 6;
      _closed = false;
      _sample = 'water';
    });
  }

  void _selectLab(String labId) {
    if (_labId == labId) return;
    _reset();
    setState(() => _labId = labId);
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
      final user = ref.read(firebaseAuthProvider).currentUser;
      if (user != null) await _submitAttempt(attempt, user, repository);
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

  Future<void> _submitAttempt(
    LabAttempt attempt,
    User user,
    UserPrefsRepository repository,
  ) async {
    try {
      await ref
          .read(labServiceProvider)
          .submitAttempt(
            attempt,
            tokenProvider: ({required forceRefresh}) =>
                user.getIdToken(forceRefresh),
          );
      if (ref.read(firebaseAuthProvider).currentUser?.uid != user.uid) return;
      await repository.saveLabAttempt(attempt.copyWith(synced: true));
    } catch (_) {
      // The device keeps the attempt as a local result; it is not queued for a
      // later account or device.
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(userPrefsRepositoryProvider, (previous, next) {
      _reset();
      setState(() {
        _history = next.getLabAttempts();
        _saving = false;
      });
    });
    final circuit = _labId == 'circuit';
    final observation = _result?.observation;
    final disabledMotion = MediaQuery.of(context).disableAnimations;
    final colorScheme = Theme.of(context).colorScheme;
    final completed = _history.where((item) => item.labId == _labId).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Virtual Science Lab'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
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
              'CLASS 7 · SCIENCE BETA',
              style: Theme.of(context).textTheme.labelSmall,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('Circuit'),
                  selected: circuit,
                  onSelected: (_) => _selectLab('circuit'),
                ),
                ChoiceChip(
                  label: const Text('Indicator'),
                  selected: !circuit,
                  onSelected: (_) => _selectLab('indicator'),
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
              circuit
                  ? 'Predict how a switch, cells, and resistance affect a bulb.'
                  : 'Predict the colour of universal indicator in each sample.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Semantics(
              label: circuit
                  ? 'Circuit diagram. The switch is ${_closed ? 'closed' : 'open'}. ${observation?['brightness'] ?? 'No observation yet'} bulb.'
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
                onChanged: (value) => setState(() {
                  _closed = value;
                  _result = null;
                }),
              ),
              _ChoiceRow<int>(
                label: 'Battery cells',
                values: const [1, 2, 3],
                selected: _cells,
                format: (value) => '$value',
                onSelected: (value) => setState(() {
                  _cells = value;
                  _result = null;
                }),
              ),
              _ChoiceRow<int>(
                label: 'Resistance',
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
                values: const ['lemon', 'water', 'soap'],
                selected: _sample,
                format: (value) => switch (value) {
                  'lemon' => 'Lemon juice',
                  'water' => 'Water',
                  _ => 'Soap solution',
                },
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
                          label: Text(
                            value[0].toUpperCase() + value.substring(1),
                          ),
                          selected: _prediction == value,
                          onSelected: (_) => setState(() {
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
                TextButton(onPressed: _reset, child: const Text('Reset')),
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
                            ? 'Bulb: ${observation!['brightness']} · Current: ${observation['current_a']} A'
                            : 'Colour: ${observation!['color']} · Approx. pH: ${observation['approx_ph']}',
                      ),
                      const SizedBox(height: 8),
                      Text(
                        evaluateLab(
                          _labId,
                          _result!.controls,
                          _result!.prediction,
                        ).explanation,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _history.any(
                              (item) =>
                                  item.clientAttemptId ==
                                      _result!.clientAttemptId &&
                                  item.synced,
                            )
                            ? 'Synced to your account'
                            : 'Saved on this device; will sync when signed in and online',
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
  final List<T> values;
  final T selected;
  final String Function(T) format;
  final ValueChanged<T> onSelected;

  const _ChoiceRow({
    required this.label,
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
                onSelected: (_) => onSelected(value),
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
  final String brightness;

  const _CircuitPainter({
    required this.color,
    required this.closed,
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
    final top = size.height * .25;
    final bottom = size.height * .75;
    canvas.drawLine(Offset(left, top), Offset(size.width * .45, top), wire);
    canvas.drawLine(Offset(size.width * .55, top), Offset(right, top), wire);
    canvas.drawLine(Offset(right, top), Offset(right, bottom), wire);
    canvas.drawLine(Offset(right, bottom), Offset(left, bottom), wire);
    canvas.drawLine(Offset(left, bottom), Offset(left, top), wire);
    canvas.drawLine(
      Offset(size.width * .45, top),
      Offset(size.width * .55, closed ? top : top - 20),
      wire,
    );
    canvas.drawCircle(
      Offset(right, size.height * .5),
      25,
      Paint()
        ..color = brightness == 'bright'
            ? Colors.amber.shade300
            : brightness == 'dim'
            ? Colors.amber.shade100
            : Colors.grey.shade300,
    );
    canvas.drawCircle(Offset(right, size.height * .5), 25, wire);
    canvas.drawLine(
      Offset(left - 12, bottom - 18),
      Offset(left + 12, bottom - 18),
      wire,
    );
    canvas.drawLine(
      Offset(left - 7, bottom - 8),
      Offset(left + 7, bottom - 8),
      wire,
    );
  }

  @override
  bool shouldRepaint(_CircuitPainter old) =>
      old.color != color ||
      old.closed != closed ||
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
