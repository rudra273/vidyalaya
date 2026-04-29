import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import '../../app/theme.dart';
import '../../data/seed/seed_data.dart';
import '../../data/models/book.dart';

class ManageDownloadsScreen extends ConsumerStatefulWidget {
  const ManageDownloadsScreen({super.key});

  @override
  ConsumerState<ManageDownloadsScreen> createState() => _ManageDownloadsScreenState();
}

class _ManageDownloadsScreenState extends ConsumerState<ManageDownloadsScreen> {
  bool _isLoading = true;
  String? _booksDirPath;
  final Set<String> _downloadedBookIds = {};
  final Map<String, double> _downloadingProgress = {};

  @override
  void initState() {
    super.initState();
    _checkDownloadedBooks();
  }

  Future<void> _checkDownloadedBooks() async {
    setState(() => _isLoading = true);
    final dir = await getApplicationDocumentsDirectory();
    final booksDir = Directory('${dir.path}/books');
    if (!booksDir.existsSync()) {
      booksDir.createSync(recursive: true);
    }
    
    _booksDirPath = booksDir.path;
    _downloadedBookIds.clear();

    for (var book in allBooks) {
      final file = File('$_booksDirPath/${book.id}.pdf');
      if (file.existsSync() && file.lengthSync() > 0) {
        _downloadedBookIds.add(book.id);
      }
    }

    setState(() => _isLoading = false);
  }

  Future<void> _deleteBook(Book book) async {
    if (_booksDirPath == null) return;
    
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Book'),
        content: Text('Are you sure you want to delete "${book.title}" from your device?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final file = File('$_booksDirPath/${book.id}.pdf');
    if (file.existsSync()) {
      await file.delete();
      setState(() {
        _downloadedBookIds.remove(book.id);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('${book.title} deleted.'),
          duration: const Duration(seconds: 2),
        ));
      }
    }
  }

  Future<void> _downloadBook(Book book) async {
    if (_booksDirPath == null) return;

    setState(() {
      _downloadingProgress[book.id] = 0.01; // Indicate start
    });

    try {
      final request = http.Request('GET', Uri.parse(book.pdfUrl));
      final response = await http.Client().send(request);

      if (response.statusCode != 200) {
        throw Exception('Failed to download');
      }

      final contentLength = response.contentLength ?? 0;
      final bytes = <int>[];

      await for (final chunk in response.stream) {
        bytes.addAll(chunk);
        if (contentLength > 0 && mounted) {
          setState(() {
            _downloadingProgress[book.id] = bytes.length / contentLength;
          });
        }
      }

      final file = File('$_booksDirPath/${book.id}.pdf');
      await file.writeAsBytes(bytes);

      if (mounted) {
        setState(() {
          _downloadingProgress.remove(book.id);
          _downloadedBookIds.add(book.id);
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('${book.title} downloaded successfully.'),
          duration: const Duration(seconds: 2),
        ));
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _downloadingProgress.remove(book.id);
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error downloading ${book.title}.'),
          backgroundColor: Colors.red,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Manage Downloads')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final downloadedBooks = allBooks.where((b) => _downloadedBookIds.contains(b.id)).toList();
    final notDownloadedBooks = allBooks.where((b) => !_downloadedBookIds.contains(b.id)).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Downloads', style: Theme.of(context).textTheme.headlineMedium),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          if (downloadedBooks.isNotEmpty) ...[
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              sliver: SliverToBoxAdapter(
                child: Text('Downloaded (${downloadedBooks.length})', 
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              ),
            ),
            ..._buildBookGroups(downloadedBooks, true, isDark, cs),
          ],
          if (notDownloadedBooks.isNotEmpty) ...[
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 32, 16, 0),
              sliver: SliverToBoxAdapter(
                child: Text('Available for Download (${notDownloadedBooks.length})', 
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              ),
            ),
            ..._buildBookGroups(notDownloadedBooks, false, isDark, cs),
          ],
          const SliverPadding(padding: EdgeInsets.only(bottom: 30)),
        ],
      ),
    );
  }

  List<Widget> _buildBookGroups(List<Book> books, bool isDownloaded, bool isDark, ColorScheme cs) {
    if (books.isEmpty) return [];
    
    final grouped = <int, List<Book>>{};
    for (var b in books) {
      grouped.putIfAbsent(b.classNumber, () => []).add(b);
    }
    
    final sortedKeys = grouped.keys.toList()..sort();
    final slivers = <Widget>[];
    
    for (var classNum in sortedKeys) {
      slivers.add(
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
          sliver: SliverToBoxAdapter(
            child: Text('Class $classNum', 
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: cs.onSurface,
                fontWeight: FontWeight.w600,
              )),
          ),
        ),
      );
      slivers.add(
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => _buildBookItem(grouped[classNum]![index], isDownloaded, isDark, cs),
            childCount: grouped[classNum]!.length,
          ),
        ),
      );
    }
    return slivers;
  }

  Widget _buildBookItem(Book book, bool isDownloaded, bool isDark, ColorScheme cs) {
    final progress = _downloadingProgress[book.id];
    final isDownloading = progress != null;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? cs.surface : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outline),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.getSubjectColor(book.subject).$1,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(book.coverEmoji, style: const TextStyle(fontSize: 24)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  book.title,
                  style: Theme.of(context).textTheme.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                if (isDownloading) 
                  LinearProgressIndicator(
                    value: progress > 0 ? progress : null,
                    backgroundColor: cs.outline,
                    color: AppColors.teal,
                  )
                else
                  Text(
                    isDownloaded ? 'Downloaded' : 'Not downloaded',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isDownloaded ? AppColors.teal : AppColors.textMuted,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          if (isDownloading)
            const SizedBox(width: 40, height: 40)
          else if (isDownloaded)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              tooltip: 'Delete',
              onPressed: () => _deleteBook(book),
            )
          else
            IconButton(
              icon: Icon(Icons.download_rounded, color: AppColors.teal),
              tooltip: 'Download',
              onPressed: () => _downloadBook(book),
            ),
        ],
      ),
    );
  }
}
