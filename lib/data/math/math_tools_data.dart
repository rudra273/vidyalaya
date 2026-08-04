import 'package:flutter/material.dart';

// ─── Math hub tool list ───────────────────────────────────────────────────────
//
// The rows rendered by MathHomeScreen. Static const content — adding a tool means
// adding an entry here plus a GoRoute in app/router.dart.

/// One entry in the Math hub list.
class MathTool {
  final String id;
  final String title;
  final String sub;
  final IconData icon;
  final String route;

  /// Whether this tool reports a score worth showing on the hub. Formulas is a
  /// reference tool, so it has nothing to beat.
  final bool scored;

  const MathTool({
    required this.id,
    required this.title,
    required this.sub,
    required this.icon,
    required this.route,
    this.scored = true,
  });
}

const mathTools = <MathTool>[
  MathTool(
    id: 'math-tables',
    title: 'Multiplication Tables',
    sub: 'Browse 1–20, then practise',
    icon: Icons.grid_on_rounded,
    route: '/learn/math/tables',
  ),
  MathTool(
    id: 'math-flash',
    title: 'Flash Math',
    sub: 'Keep the total in your head',
    icon: Icons.bolt_rounded,
    route: '/learn/math/flash',
  ),
  MathTool(
    id: 'math-quiz',
    title: 'Math Quiz',
    sub: '10 questions for your class',
    icon: Icons.help_outline_rounded,
    route: '/learn/math/quiz',
  ),
  MathTool(
    id: 'math-drills',
    title: 'Speed Drills',
    sub: '60-second sprint',
    icon: Icons.timer_outlined,
    route: '/learn/math/drills',
  ),
  MathTool(
    id: 'math-number-sense',
    title: 'Number Sense',
    sub: 'Bigger, smaller, odd, prime',
    icon: Icons.rule_rounded,
    route: '/learn/math/number-sense',
  ),
  MathTool(
    id: 'math-fractions',
    title: 'Fractions Lab',
    sub: 'See fractions, then solve them',
    icon: Icons.pie_chart_outline_rounded,
    route: '/learn/math/fractions',
  ),
  MathTool(
    id: 'math-formulas',
    title: 'Formulas',
    sub: 'Reference & calculator',
    icon: Icons.functions_rounded,
    route: '/learn/math-formulas',
    scored: false,
  ),
];

/// Lookup by id, mirroring `formulaCategoryByName` / `pythonChapterById`.
MathTool? mathToolById(String id) {
  for (final t in mathTools) {
    if (t.id == id) return t;
  }
  return null;
}
