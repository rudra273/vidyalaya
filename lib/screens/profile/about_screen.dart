import 'package:flutter/material.dart';

import '../../app/theme.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'About Vidya AI',
          style: theme.textTheme.headlineSmall,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Vidya AI',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: cs.primary,
                fontWeight: AppFontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Version 1.0.3',
              style: theme.textTheme.bodySmall?.copyWith(
                color: cs.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 32),

            _buildSection(
              theme,
              title: 'What is Vidya AI?',
              content: 'Vidya AI is an AI-powered learning assistant for Indian school students. At its heart is a smart study companion that answers your questions and explains concepts in a way that fits your class, board, and syllabus — so help is always one question away.\n\nAround that, Vidya AI gives you a set of interactive tools to explore subjects hands-on, plus a built-in library of books for whenever you need them.',
            ),

            _buildSection(
              theme,
              title: 'Your AI Learning Assistant',
              content: 'This is what Vidya AI is built around.\n\n'
                       '• Ask Anything: Type a question in your own words and get a clear, syllabus-aware explanation tailored to your class and subject.\n'
                       '• Snap & Ask: Stuck on a problem? Attach a photo of your notes, an assignment, or a page from a book and let the assistant help you work through it.\n'
                       '• Saved Conversations: Your chats are saved to your account, so you can return and pick up where you left off.\n'
                       '• AI Tutor (preview): A demo of guided, step-by-step lessons. Live tutoring is on the way.',
            ),

            _buildSection(
              theme,
              title: 'Explore Tools',
              content: 'In the Explore tab, learn Maths, Science, History and more through hands-on tools:\n\n'
                       '• Math — formulas with a built-in calculator, plus multiplication tables, Flash Math, quizzes, speed drills, number sense and a fractions lab.\n'
                       '• Diagrams — interactive science and concept diagrams.\n'
                       '• Periodic Table — explore every element interactively.\n'
                       '• Vocabulary — build your word power with meanings in your language.\n'
                       '• Python — learn to code with bite-sized lessons, quizzes and a playground.\n'
                       '• Science Lab — run virtual experiments and test your predictions.\n'
                       '• Timeline — walk through major events in history.\n'
                       '• Cosmulator — view the solar system in 3D.',
            ),

            _buildSection(
              theme,
              title: 'Library',
              content: 'Vidya AI also includes a library of books you can download and read offline, with comfortable reading modes (including Sepia and Dark Mode), bookmarks, highlights, and personal notes for quick revision — there whenever you need a reference.',
            ),

            _buildSection(
              theme,
              title: 'Stay On Track',
              content: '• Progress Analytics: Build streaks and review your learning journey over time.\n'
                       '• Timetable & Notes: Plan your study schedule and keep notes organized by subject.',
            ),

            _buildSection(
              theme,
              title: 'Your Account & Privacy',
              content: 'You sign in securely with Google to use the AI assistant. Your student profile — name, class, board, language, and optional school — helps tailor answers to your studies.\n\n'
                       'We keep things minimal: profile photo uploads are not supported, and students are represented by friendly preset avatars instead. For full details on what we collect and why, see our Privacy Policy.',
            ),

            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 24.0),
              decoration: BoxDecoration(
                color: cs.errorContainer.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: cs.error.withValues(alpha: 0.5)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, color: cs.error, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Disclaimer',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: cs.error,
                          fontWeight: AppFontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Vidya AI is a private, independent platform and is NOT an official government application. While all the textbooks provided within the app are official, board-approved materials sourced directly from public government websites, our application itself is not affiliated with, endorsed by, or connected to any government entity.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      height: 1.5,
                      color: cs.onSurface.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            Center(
              child: Text(
                 '© 2026 Vidya AI.',
                 style: theme.textTheme.labelMedium?.copyWith(
                   color: cs.onSurface.withValues(alpha: 0.5),
                 ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(ThemeData theme, {required String title, required String content}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: AppFontWeight.semibold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: theme.textTheme.bodyMedium?.copyWith(
              height: 1.6,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}
