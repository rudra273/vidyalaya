import 'package:flutter/material.dart';

// ─── Chapter icons ────────────────────────────────────────────────────────────
//
// UI chrome uses Material icons rather than emoji. Mapped by chapter id so the
// content model stays free of Flutter types; an unknown id falls back to a
// generic book icon.

const Map<String, IconData> _chapterIcons = {
  'b1_hello': Icons.waving_hand_rounded,
  'b2_variables': Icons.tag_rounded,
  'b3_text': Icons.text_fields_rounded,
  'b4_input': Icons.chat_bubble_outline_rounded,
  'i1_decisions': Icons.alt_route_rounded,
  'i2_for_loops': Icons.repeat_rounded,
  'i3_while_loops': Icons.loop_rounded,
  'a1_lists': Icons.list_alt_rounded,
  'a2_functions': Icons.functions_rounded,
  'a3_projects': Icons.construction_rounded,
};

IconData chapterIcon(String chapterId) =>
    _chapterIcons[chapterId] ?? Icons.menu_book_rounded;
