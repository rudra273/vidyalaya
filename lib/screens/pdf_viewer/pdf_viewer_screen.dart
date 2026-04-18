import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../../app/theme.dart';
import '../../data/models/book.dart';
import '../../providers/reading_provider.dart';

class PdfViewerScreen extends ConsumerStatefulWidget {
  final Book book;

  const PdfViewerScreen({super.key, required this.book});

  @override
  ConsumerState<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends ConsumerState<PdfViewerScreen> {
  String? _localPath;
  bool _isLoading = true;
  String? _error;
  double _downloadProgress = 0;
  int _currentPage = 0;
  int _totalPages = 0;

  @override
  void initState() {
    super.initState();
    _loadPdf();
    // Track this book as last read
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(readingProvider.notifier).setLastRead(widget.book);
    });
  }

  Future<void> _loadPdf() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
        _downloadProgress = 0;
      });

      // Get the app documents directory (persists across cache clears)
      final dir = await getApplicationDocumentsDirectory();
      final booksDir = Directory('${dir.path}/books');
      if (!booksDir.existsSync()) {
        booksDir.createSync(recursive: true);
      }

      final filePath = '${booksDir.path}/${widget.book.id}.pdf';
      final file = File(filePath);

      // If already downloaded, use local file
      if (file.existsSync() && file.lengthSync() > 0) {
        setState(() {
          _localPath = filePath;
          _isLoading = false;
        });
        return;
      }

      // Download the PDF
      final request = http.Request('GET', Uri.parse(widget.book.pdfUrl));
      final response = await http.Client().send(request);

      if (response.statusCode != 200) {
        throw Exception('Failed to download: HTTP ${response.statusCode}');
      }

      final contentLength = response.contentLength ?? 0;
      final bytes = <int>[];

      await for (final chunk in response.stream) {
        bytes.addAll(chunk);
        if (contentLength > 0) {
          setState(() {
            _downloadProgress = bytes.length / contentLength;
          });
        }
      }

      // Save to documents directory
      await file.writeAsBytes(bytes);

      if (mounted) {
        setState(() {
          _localPath = filePath;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.book.title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            if (_totalPages > 0)
              Text(
                'Page ${_currentPage + 1} of $_totalPages',
                style: Theme.of(context).textTheme.bodySmall,
              ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _isLoading
          ? _buildLoadingView()
          : _error != null
              ? _buildErrorView()
              : _buildPdfView(),
    );
  }

  Widget _buildLoadingView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.book.coverEmoji,
              style: const TextStyle(fontSize: 48),
            ),
            const SizedBox(height: 24),
            Text(
              _downloadProgress > 0 ? 'Downloading...' : 'Connecting...',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              widget.book.title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textMuted,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: 200,
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: _downloadProgress > 0 ? _downloadProgress : null,
                      minHeight: 6,
                      backgroundColor: AppColors.surface,
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(AppColors.teal),
                    ),
                  ),
                  if (_downloadProgress > 0) ...[
                    const SizedBox(height: 8),
                    Text(
                      '${(_downloadProgress * 100).toInt()}%',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('⚠️', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 24),
            Text(
              'Failed to load PDF',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Please check your internet connection and try again.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textMuted,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadPdf,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPdfView() {
    return PDFView(
      filePath: _localPath!,
      enableSwipe: true,
      swipeHorizontal: false,
      autoSpacing: true,
      pageFling: true,
      onRender: (pages) {
        setState(() {
          _totalPages = pages ?? 0;
        });
      },
      onViewCreated: (controller) {},
      onPageChanged: (page, total) {
        setState(() {
          _currentPage = page ?? 0;
          _totalPages = total ?? 0;
        });
      },
      onError: (error) {
        setState(() {
          _error = error.toString();
        });
      },
    );
  }
}
