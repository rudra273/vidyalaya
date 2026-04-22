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
          style: theme.textTheme.headlineMedium,
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
              'Effective Date: April 20, 2026',
              style: theme.textTheme.bodySmall?.copyWith(
                color: cs.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 32),

            _buildSection(
              theme,
              title: '1. Introduction',
              content: 'Welcome to Vidyālaya ("we," "our," or "us"). We are committed to protecting your privacy and ensuring you have a positive experience on our mobile application. Vidyālaya is designed as a book reading tool for Indian school students, providing offline access to educational materials.\n\nThis Privacy Policy explains our practices regarding the collection, use, and disclosure of information when you use the Vidyālaya app.',
            ),

            _buildSection(
              theme,
              title: '2. Data Collection & Server Usage',
              content: 'Our core principle is simple: We do not collect, transmit, or store your personal data on any external servers. In fact, Vidyālaya currently does not use any backend servers to collect user data.\n\n'
                       '• No Account Required: You can use Vidyālaya without creating an account or providing any identifying information (such as name, email, or phone number).\n'
                       '• Local Storage Only: Any customization you make within the app (such as providing a nickname, selecting your class, choosing light/dark mode themes, or saving bookmarks) is stored entirely locally on your device.\n'
                       '• Downloaded Books: The textbooks and study materials you download are saved directly onto your device\'s internal storage for offline viewing.',
            ),

            _buildSection(
              theme,
              title: '3. Permissions We Request',
              content: 'To function properly, Vidyālaya requires minimal device permissions. These are strictly used for the app\'s core functionality and not for data tracking:\n\n'
                       '• Internet Connectivity: Used solely to download educational PDFs from our trusted sources so you can read them offline. We do not use the internet connection to send your personal usage data anywhere.',
            ),

            _buildSection(
              theme,
              title: '4. Cookies and Tracking Technologies',
              content: 'Vidyālaya is a native mobile application and does not use cookies, web beacons, or similar tracking technologies. We do not integrate with any third-party analytics trackers, advertising networks, or data brokers. The app is completely ad-free and tracking-free.',
            ),

            _buildSection(
              theme,
              title: '5. Children\'s Privacy (COPPA)',
              content: 'Vidyālaya is designed specifically for school students, including children under the age of 13. We are fully compliant with the Children\'s Online Privacy Protection Act (COPPA). Because we do not have a server that collects personal information from any of our users, we inherently do not collect, use, or disclose personal information from children.',
            ),

            _buildSection(
              theme,
              title: '6. Future Updates to This Policy',
              content: 'As Vidyālaya evolves, we may introduce new features (such as cloud synchronization, account creation, or AI-assisted learning). If these future updates require the use of servers to collect or process data, we will thoroughly update this Privacy Policy. Most importantly, we will obtain the necessary user (and verifiable parental) consent before collecting any data. You are advised to review this page periodically for any changes.',
            ),

            _buildSection(
              theme,
              title: '7. Contact Us',
              content: 'If you have any questions or suggestions about our Privacy Policy, do not hesitate to contact the developer team at rosmoxx@gmail.com.',
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
