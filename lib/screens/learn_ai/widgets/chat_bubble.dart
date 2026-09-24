import 'package:flutter/material.dart';

import '../../../widgets/ai_markdown.dart';

/// Student's own message: a compact bubble pinned to the right. Mirrors the look
/// of the live Q&A chat so the Tutor preview feels like the same product.
class UserChatBubble extends StatelessWidget {
  final String text;

  const UserChatBubble({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Align(
      alignment: Alignment.centerRight,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.82,
        ),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: cs.primary,
            borderRadius: BorderRadius.circular(
              16,
            ).copyWith(bottomRight: const Radius.circular(4)),
          ),
          child: Text(
            text,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: cs.onPrimary, height: 1.35),
          ),
        ),
      ),
    );
  }
}

/// The AI's reply: full-width markdown text on the left (no bubble) so long
/// explanations read like a document — matching the live Q&A chat.
class AssistantChatBubble extends StatelessWidget {
  final String text;

  const AssistantChatBubble({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: AiMarkdown(text: text),
    );
  }
}
