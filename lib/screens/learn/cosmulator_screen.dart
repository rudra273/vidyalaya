import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../app/theme.dart';

class CosmulatorScreen extends StatefulWidget {
  const CosmulatorScreen({super.key});

  static final Uri url = Uri.parse(
    'https://cosmulator.rudramohanty45.workers.dev/',
  );

  @override
  State<CosmulatorScreen> createState() => _CosmulatorScreenState();
}

class _CosmulatorScreenState extends State<CosmulatorScreen> {
  late final WebViewController _controller;
  var _isLoading = true;
  var _hasError = false;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.black)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (!mounted) return;
            setState(() {
              _isLoading = true;
              _hasError = false;
            });
          },
          onPageFinished: (_) {
            if (!mounted) return;
            setState(() => _isLoading = false);
          },
          onWebResourceError: (error) {
            if (!mounted || error.isForMainFrame != true) return;
            setState(() {
              _isLoading = false;
              _hasError = true;
            });
          },
        ),
      )
      ..loadRequest(CosmulatorScreen.url);
  }

  void _reload() {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    _controller.loadRequest(CosmulatorScreen.url);
  }

  void _close() {
    assert(() {
      debugPrint('CosmulatorScreen: closing route');
      return true;
    }());
    context.pop();
  }

  @override
  void dispose() {
    assert(() {
      debugPrint('CosmulatorScreen: disposed');
      return true;
    }());
    _controller.loadHtmlString('<html><body></body></html>');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return PopScope(
      canPop: true,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Cosmulator'),
          leading: IconButton(
            tooltip: 'Back',
            icon: const Icon(Icons.arrow_back),
            onPressed: _close,
          ),
        ),
        body: Stack(
          children: [
            if (_hasError)
              _CosmulatorErrorState(onRetry: _reload)
            else
              WebViewWidget(controller: _controller),
            if (_isLoading)
              LinearProgressIndicator(
                minHeight: 3,
                color: cs.primary,
                backgroundColor: cs.surfaceContainerHighest,
              ),
          ],
        ),
      ),
    );
  }
}

class _CosmulatorErrorState extends StatelessWidget {
  const _CosmulatorErrorState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.public_off, size: 48, color: AppColors.textMuted),
            const SizedBox(height: 16),
            Text(
              'Cosmulator could not load',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Check your internet connection, then try loading it again.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 12,
              runSpacing: 12,
              children: [
                FilledButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Try again'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
