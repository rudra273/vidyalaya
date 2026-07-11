import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Privacy Policy',
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
              'Effective Date: June 17, 2026',
              style: theme.textTheme.bodySmall?.copyWith(
                color: cs.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 32),

            _buildSection(
              theme,
              title: '1. Introduction',
              content: 'Welcome to Vidyālaya ("we," "our," or "us"). We are committed to protecting your privacy and ensuring you have a positive experience on our mobile application. Vidyālaya is an educational platform for Indian school students that combines offline textbook reading with AI-assisted learning tools.\n\nThis Privacy Policy explains what information we collect, how we use it, and the choices you have when you use the Vidyālaya app. Please read it carefully. If you are under 18, please review this policy together with a parent or guardian.',
            ),

            _buildSection(
              theme,
              title: '2. What You Can Use Without an Account',
              content: 'Core reading and study features work without signing in. When you use Vidyālaya without an account:\n\n'
                       '• Local Storage Only: Your class selection, board, preferred language, chosen avatar, theme (light/sepia/dark), bookmarks, highlights, notes, timetable, and reading progress are stored entirely on your device.\n'
                       '• Downloaded Books: The textbooks and study materials you download are saved directly to your device for offline viewing.\n'
                       '• No Sign-In Required for Reading: You are not required to provide any identifying information to read books, take notes, or use the offline Learn modules.',
            ),

            _buildSection(
              theme,
              title: '3. Accounts & Google Sign-In',
              content: 'To use AI-powered features (such as Learn Assist), you sign in with Google. We use Google Sign-In and Firebase Authentication to verify your identity. When you sign in, we receive and store on our servers:\n\n'
                       '• Your name and email address from your Google account.\n'
                       '• A unique account identifier (Firebase UID) used to associate your data with your account.\n\n'
                       'We do not collect or store your Google profile photo. Profile pictures cannot be uploaded in the app — students are represented only by preset illustrated avatars or an initial, by design. We also do not request access to your contacts, Google Drive, or other Google data.',
            ),

            _buildSection(
              theme,
              title: '4. Student Profile Information',
              content: 'When you are signed in, you can create a student profile so we can tailor content to your studies. This profile is stored on our servers and may include:\n\n'
                       '• Your name (you can edit this; it does not have to be your real or full name).\n'
                       '• Your class / grade and education board.\n'
                       '• Your preferred language (a copy is also kept on your device so the app works offline and before you sign in).\n'
                       '• Your school name (optional — you may leave this blank).\n\n'
                       'You can view and edit this information at any time from the Profile screen. Providing a school name is entirely optional.',
            ),

            _buildSection(
              theme,
              title: '5. AI Learning Features (Learn Assist)',
              content: 'When you ask a question using our AI features, the following is sent to our servers and our AI service provider to generate an answer:\n\n'
                       '• The text of your question or note.\n'
                       '• Any photo you choose to attach (for example, a photo of your notes, an assignment, or a textbook page).\n'
                       '• Your class, board, subject, and language, so answers match your syllabus.\n\n'
                       'Your conversations are saved to your account so you can return to them. Photos are processed to answer your question and should only show study material — please do not include faces or other personal information in the images you send. AI-generated answers can occasionally be inaccurate, so always check important information against your textbook.',
            ),

            _buildSection(
              theme,
              title: '6. Permissions We Request',
              content: 'Vidyālaya requests only the permissions needed for its features:\n\n'
                       '• Internet: To download textbooks, sign in, and use AI features.\n'
                       '• Camera & Photos: Used only when you choose to attach a photo to an AI question. We do not access your camera or gallery in the background, and we do not browse or upload your photo library.',
            ),

            _buildSection(
              theme,
              title: '7. How We Use Your Information',
              content: 'We use the information described above only to:\n\n'
                       '• Provide, secure, and operate your account.\n'
                       '• Deliver AI answers tailored to your class and syllabus.\n'
                       '• Save your conversations, profile, and usage so the app works across sessions.\n'
                       '• Apply fair-use limits on AI requests.\n\n'
                       'We do not sell your personal information, and we do not use it for advertising. The app contains no third-party ads.',
            ),

            _buildSection(
              theme,
              title: '8. Third-Party Services',
              content: 'We rely on a small number of trusted service providers to operate Vidyālaya:\n\n'
                       '• Google / Firebase: for sign-in and authentication.\n'
                       '• Our AI backend and AI model provider: to process and answer your questions.\n\n'
                       'These providers process data only to deliver these services on our behalf and are subject to their own privacy and security commitments. We do not integrate advertising networks or data brokers.',
            ),

            _buildSection(
              theme,
              title: '9. Cookies and Tracking Technologies',
              content: 'Vidyālaya is a native mobile application and does not use cookies, web beacons, or third-party advertising or analytics trackers to follow you across apps or websites. The app is ad-free.',
            ),

            _buildSection(
              theme,
              title: '10. Children\'s Privacy',
              content: 'Vidyālaya is intended for school students, and some users may be under the age of 13. We collect only the limited information needed to provide the service, as described above. Because signing in and AI features involve collecting personal information (such as name and email), we ask that a parent or guardian set up and supervise the use of these features for younger children, and provide consent where required by law (including COPPA and applicable Indian data protection rules).\n\nIf you believe a child has provided us personal information without appropriate consent, please contact us and we will delete it.',
            ),

            _buildSection(
              theme,
              title: '11. Data Retention & Your Choices',
              content: 'We keep your account, profile, and conversation history for as long as your account is active. You can:\n\n'
                       '• Edit your profile details at any time from the Profile screen.\n'
                       '• Sign out to stop syncing data to your account.\n'
                       '• Request deletion of your account and associated data by contacting us at the email below.',
            ),

            _buildSection(
              theme,
              title: '12. Changes to This Policy',
              content: 'As Vidyālaya evolves, we may update this Privacy Policy to reflect new features or legal requirements. When we make material changes, we will update the effective date above. You are advised to review this page periodically.',
            ),

            _buildSection(
              theme,
              title: '13. Contact Us',
              content: 'If you have any questions, requests, or suggestions about this Privacy Policy or your data, please contact the developer team at rosmoxx@gmail.com.',
            ),

            const SizedBox(height: 24),
            Center(
              child: Text(
                 '© 2026 Vidyālaya. All rights reserved.',
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
