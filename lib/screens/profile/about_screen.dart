import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'About Vidyālaya',
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
              'Vidyālaya',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: cs.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Version 1.0.0',
              style: theme.textTheme.bodySmall?.copyWith(
                color: cs.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 32),

            _buildSection(
              theme,
              title: 'What is Vidyālaya?',
              content: 'Vidyālaya is a dedicated educational platform built specifically for Indian school students. It pairs a modern, distraction-free textbook reader with an AI study companion, so you can not only read your books but also ask questions and understand them more deeply.\n\nMore than just a book reader, Vidyālaya helps you build positive routines. You can set your study timetable, track your learning habits, take notes, and get instant help with tricky topics — all in one place.',
            ),

            _buildSection(
              theme,
              title: 'AI-Powered Learning',
              content: '• Learn Assist: Ask questions in your own words and get clear, syllabus-aware explanations tailored to your class, board, and subject.\n'
                       '• Snap & Ask: Stuck on a problem? Attach a photo of your notes, an assignment, or a textbook page and let the AI help you work through it.\n'
                       '• Saved Conversations: Your chats are saved to your account, so you can pick up right where you left off.\n'
                       '• AI Tutor (coming soon): Step-by-step guided lessons that teach concepts one small step at a time.',
            ),

            _buildSection(
              theme,
              title: 'Reading & Study Experience',
              content: '• Clean UI/UX: A student-friendly, distraction-free interface designed to make learning intuitive.\n'
                       '• Tailored Reading Modes: Customizable reading including Sepia and Dark Mode to reduce eye strain during night-time reading.\n'
                       '• True Offline Access: Download your books once and read them anytime, anywhere — no active internet connection required for reading.\n'
                       '• Interactive Learning: Explore math formulas, science diagrams, the periodic table, and historical timelines in the dedicated Learn module.\n'
                       '• Notes & Bookmarks: Capture your own notes by subject and bookmark important pages for quick revision.\n'
                       '• Progress Analytics: Monitor your study habits, build streaks, and review your learning journey over time.\n'
                       '• Study Management: Stay on track by setting daily timetables and organizing your schedule.',
            ),

            _buildSection(
              theme,
              title: 'Your Account & Privacy',
              content: 'Reading and your offline study tools work without an account. To use AI features, you sign in securely with Google. Your student profile — name, class, board, language, and optional school — helps tailor content to your studies.\n\n'
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
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Vidyālaya is a private, independent platform and is NOT an official government application. While all the textbooks provided within the app are official, board-approved materials sourced directly from public government websites, our application itself is not affiliated with, endorsed by, or connected to any government entity.',
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
                 '© 2026 Vidyālaya.',
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
              fontWeight: FontWeight.w600,
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
