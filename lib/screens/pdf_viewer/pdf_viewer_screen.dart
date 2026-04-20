import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../../app/theme.dart';
import '../../data/models/book.dart';
import '../../providers/core_providers.dart';
import '../../providers/reading_provider.dart';

class PdfViewerScreen extends ConsumerStatefulWidget {
  final Book book;

  const PdfViewerScreen({super.key, required this.book});

  @override
  ConsumerState<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends ConsumerState<PdfViewerScreen> {
  // PDF state
  String? _localPath;
  bool _isLoading = true;
  String? _error;
  double _downloadProgress = 0;
  int _currentPage = 0;
  int _totalPages = 0;
  PDFViewController? _pdfController;

  // Reader settings
  String _viewMode = 'paginated'; // 'paginated' | 'scroll'
  String _colorFilter = 'none';   // 'none' | 'dark' | 'sepia'
  double _brightness = 1.0;
  bool _showControls = false;
  bool _showBookmarks = false;
  List<int> _bookmarks = [];

  // For "go to page" input
  final _pageInputController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPreferences();
    _loadPdf();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(readingProvider.notifier).setLastRead(widget.book);
    });
  }

  @override
  void dispose() {
    _pageInputController.dispose();
    // Save current page on exit
    _saveCurrentPage();
    super.dispose();
  }

  void _loadPreferences() {
    final repo = ref.read(userPrefsRepositoryProvider);
    _viewMode = repo.getReaderViewMode();
    _colorFilter = repo.getReaderFilter();
    _bookmarks = repo.getBookmarks(widget.book.id);
  }

  void _saveCurrentPage() {
    final repo = ref.read(userPrefsRepositoryProvider);
    repo.setLastReadPage(widget.book.id, _currentPage);
  }

  int _getLastReadPage() {
    final repo = ref.read(userPrefsRepositoryProvider);
    return repo.getLastReadPage(widget.book.id);
  }

  void _toggleBookmark() {
    final repo = ref.read(userPrefsRepositoryProvider);
    repo.toggleBookmark(widget.book.id, _currentPage);
    setState(() {
      _bookmarks = repo.getBookmarks(widget.book.id);
    });

    final isNowBookmarked = _bookmarks.contains(_currentPage);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isNowBookmarked
              ? 'Page ${_currentPage + 1} bookmarked'
              : 'Bookmark removed',
        ),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 80),
      ),
    );
  }

  void _goToPage(int page) {
    if (page >= 0 && page < _totalPages && _pdfController != null) {
      _pdfController!.setPage(page);
    }
  }

  void _setColorFilter(String filter) {
    setState(() => _colorFilter = filter);
    ref.read(userPrefsRepositoryProvider).setReaderFilter(filter);
  }

  void _setViewMode(String mode) {
    setState(() => _viewMode = mode);
    ref.read(userPrefsRepositoryProvider).setReaderViewMode(mode);
  }

  // ─── PDF Download ───────────────────────────────────────────────────────

  Future<void> _loadPdf() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
        _downloadProgress = 0;
      });

      final dir = await getApplicationDocumentsDirectory();
      final booksDir = Directory('${dir.path}/books');
      if (!booksDir.existsSync()) {
        booksDir.createSync(recursive: true);
      }

      final filePath = '${booksDir.path}/${widget.book.id}.pdf';
      final file = File(filePath);

      if (file.existsSync() && file.lengthSync() > 0) {
        if (mounted) {
          setState(() {
            _localPath = filePath;
            _isLoading = false;
          });
        }
        return;
      }

      final request = http.Request('GET', Uri.parse(widget.book.pdfUrl));
      final response = await http.Client().send(request);

      if (response.statusCode != 200) {
        throw Exception('Failed to download: HTTP ${response.statusCode}');
      }

      final contentLength = response.contentLength ?? 0;
      final bytes = <int>[];

      await for (final chunk in response.stream) {
        bytes.addAll(chunk);
        if (contentLength > 0 && mounted) {
          setState(() {
            _downloadProgress = bytes.length / contentLength;
          });
        }
      }

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

  // ─── Build ──────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _colorFilter == 'dark' ? Colors.black : null,
      appBar: _isLoading || _error != null
          ? AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).pop(),
              ),
              title: Text(widget.book.title,
                  style: Theme.of(context).textTheme.titleLarge),
            )
          : null,
      body: _isLoading
          ? _buildLoadingView()
          : _error != null
              ? _buildErrorView()
              : _buildReaderView(),
    );
  }

  // ─── Reader View (main) ─────────────────────────────────────────────────

  Widget _buildReaderView() {
    final isBookmarked = _bookmarks.contains(_currentPage);
    final progress = _totalPages > 0 ? (_currentPage + 1) / _totalPages : 0.0;

    return Column(
      children: [
        // ── Top bar ──────────────────────────────────────────────
        _buildTopBar(isBookmarked),

        // ── Reading progress bar ─────────────────────────────────
        SizedBox(
          height: 3,
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey.withValues(alpha: 0.15),
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.teal),
          ),
        ),

        // ── PDF content ──────────────────────────────────────────
        Expanded(
          child: Stack(
            children: [
              // Color filter wrapper
              _wrapWithFilter(
                PDFView(
                  key: ValueKey('${_localPath}_$_viewMode'),
                  filePath: _localPath!,
                  enableSwipe: true,
                  swipeHorizontal: false,
                  autoSpacing: _viewMode == 'paginated',
                  pageFling: _viewMode == 'paginated',
                  pageSnap: _viewMode == 'paginated',
                  defaultPage: _getLastReadPage(),
                  onRender: (pages) {
                    if (mounted) {
                      setState(() => _totalPages = pages ?? 0);
                    }
                  },
                  onViewCreated: (controller) {
                    _pdfController = controller;
                  },
                  onPageChanged: (page, total) {
                    if (mounted) {
                      setState(() {
                        _currentPage = page ?? 0;
                        _totalPages = total ?? 0;
                      });
                      _saveCurrentPage();
                    }
                  },
                  onError: (error) {
                    if (mounted) {
                      setState(() => _error = error.toString());
                    }
                  },
                ),
              ),

              // Brightness overlay
              if (_brightness < 1.0)
                Positioned.fill(
                  child: IgnorePointer(
                    child: Container(
                      color: Colors.black.withValues(alpha: 1.0 - _brightness),
                    ),
                  ),
                ),

              // Bottom controls overlay
              if (_showControls) _buildControlsOverlay(),

              // Bookmarks panel
              if (_showBookmarks) _buildBookmarksPanel(),
            ],
          ),
        ),

        // ── Bottom bar ───────────────────────────────────────────
        _buildBottomBar(),
      ],
    );
  }

  // ─── Top Bar ────────────────────────────────────────────────────────────

  Widget _buildTopBar(bool isBookmarked) {
    return SafeArea(
      bottom: false,
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: _colorFilter == 'dark'
              ? Colors.grey.shade900
              : Theme.of(context).scaffoldBackgroundColor,
          border: Border(
            bottom: BorderSide(
              color: _colorFilter == 'dark'
                  ? Colors.white12
                  : AppColors.border,
            ),
          ),
        ),
        child: Row(
          children: [
            IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: _colorFilter == 'dark' ? Colors.white70 : null,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.book.title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: _colorFilter == 'dark'
                          ? Colors.white
                          : AppColors.navy,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (_totalPages > 0)
                    Text(
                      'Page ${_currentPage + 1} of $_totalPages',
                      style: TextStyle(
                        fontSize: 11,
                        color: _colorFilter == 'dark'
                            ? Colors.white54
                            : AppColors.textMuted,
                      ),
                    ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(
                isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                color: isBookmarked
                    ? AppColors.teal
                    : (_colorFilter == 'dark' ? Colors.white54 : AppColors.textMuted),
              ),
              tooltip: 'Bookmark page',
              onPressed: _toggleBookmark,
            ),
            IconButton(
              icon: Icon(
                Icons.list,
                color: _showBookmarks
                    ? AppColors.teal
                    : (_colorFilter == 'dark' ? Colors.white54 : AppColors.textMuted),
              ),
              tooltip: 'View bookmarks',
              onPressed: () => setState(() {
                _showBookmarks = !_showBookmarks;
                if (_showBookmarks) _showControls = false;
              }),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Bottom Bar ─────────────────────────────────────────────────────────

  Widget _buildBottomBar() {
    final isDark = _colorFilter == 'dark';
    final bgColor = isDark ? Colors.grey.shade900 : Colors.white;
    final iconColor = isDark ? Colors.white54 : AppColors.textMuted;
    final activeColor = AppColors.teal;

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(
          top: BorderSide(color: isDark ? Colors.white12 : AppColors.border),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            children: [
              // Page slider
              Expanded(
                child: SliderTheme(
                  data: SliderThemeData(
                    trackHeight: 3,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
                    activeTrackColor: activeColor,
                    inactiveTrackColor: isDark ? Colors.white12 : Colors.grey.shade200,
                    thumbColor: activeColor,
                    overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                  ),
                  child: Slider(
                    value: _totalPages > 0 ? _currentPage.toDouble() : 0,
                    min: 0,
                    max: _totalPages > 0 ? (_totalPages - 1).toDouble() : 1,
                    onChanged: (val) => _goToPage(val.toInt()),
                  ),
                ),
              ),

              // Go to page button
              GestureDetector(
                onTap: _showGoToPageDialog,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white10 : AppColors.surface,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${_currentPage + 1}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white70 : AppColors.navy,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 4),

              // Settings toggle
              IconButton(
                icon: Icon(
                  Icons.tune_rounded,
                  size: 22,
                  color: _showControls ? activeColor : iconColor,
                ),
                tooltip: 'Reader settings',
                onPressed: () => setState(() {
                  _showControls = !_showControls;
                  if (_showControls) _showBookmarks = false;
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Controls Overlay (settings panel) ──────────────────────────────────

  Widget _buildControlsOverlay() {
    final isDark = _colorFilter == 'dark';
    final panelBg = isDark ? Colors.grey.shade900 : Colors.white;
    final textColor = isDark ? Colors.white : AppColors.navy;
    final mutedColor = isDark ? Colors.white54 : AppColors.textMuted;

    return Positioned(
      left: 16,
      right: 16,
      bottom: 16,
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(16),
        color: panelBg,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ───────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Reader Settings',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => setState(() => _showControls = false),
                    child: Icon(Icons.close, size: 20, color: mutedColor),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ── Color Mode ───────────────────────────────
              Text('Display', style: TextStyle(fontSize: 12, color: mutedColor, fontWeight: FontWeight.w500)),
              const SizedBox(height: 10),
              Row(
                children: [
                  _buildFilterOption('none', 'Normal', Icons.wb_sunny_outlined, textColor, mutedColor),
                  const SizedBox(width: 8),
                  _buildFilterOption('dark', 'Dark', Icons.dark_mode_outlined, textColor, mutedColor),
                  const SizedBox(width: 8),
                  _buildFilterOption('sepia', 'Sepia', Icons.auto_awesome, textColor, mutedColor),
                ],
              ),
              const SizedBox(height: 20),

              // ── Brightness ───────────────────────────────
              Row(
                children: [
                  Icon(Icons.brightness_low, size: 18, color: mutedColor),
                  Expanded(
                    child: SliderTheme(
                      data: SliderThemeData(
                        trackHeight: 3,
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
                        activeTrackColor: AppColors.teal,
                        inactiveTrackColor: isDark ? Colors.white12 : Colors.grey.shade200,
                        thumbColor: AppColors.teal,
                        overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                      ),
                      child: Slider(
                        value: _brightness,
                        min: 0.2,
                        max: 1.0,
                        onChanged: (v) => setState(() => _brightness = v),
                      ),
                    ),
                  ),
                  Icon(Icons.brightness_high, size: 18, color: mutedColor),
                ],
              ),
              const SizedBox(height: 16),

              // ── View Mode ────────────────────────────────
              Text('View Mode', style: TextStyle(fontSize: 12, color: mutedColor, fontWeight: FontWeight.w500)),
              const SizedBox(height: 10),
              Row(
                children: [
                  _buildViewModeOption('paginated', 'Page', Icons.insert_drive_file_outlined, textColor, mutedColor),
                  const SizedBox(width: 8),
                  _buildViewModeOption('scroll', 'Scroll', Icons.view_day_outlined, textColor, mutedColor),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterOption(String value, String label, IconData icon, Color textColor, Color mutedColor) {
    final isActive = _colorFilter == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => _setColorFilter(value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.teal.withValues(alpha: 0.12)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isActive ? AppColors.teal.withValues(alpha: 0.4) : Colors.grey.withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            children: [
              Icon(icon, size: 20, color: isActive ? AppColors.teal : mutedColor),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                  color: isActive ? AppColors.teal : mutedColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildViewModeOption(String value, String label, IconData icon, Color textColor, Color mutedColor) {
    final isActive = _viewMode == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => _setViewMode(value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.teal.withValues(alpha: 0.12)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isActive ? AppColors.teal.withValues(alpha: 0.4) : Colors.grey.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: isActive ? AppColors.teal : mutedColor),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                  color: isActive ? AppColors.teal : mutedColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Bookmarks Panel ────────────────────────────────────────────────────

  Widget _buildBookmarksPanel() {
    final isDark = _colorFilter == 'dark';
    final panelBg = isDark ? Colors.grey.shade900 : Colors.white;
    final textColor = isDark ? Colors.white : AppColors.navy;
    final mutedColor = isDark ? Colors.white54 : AppColors.textMuted;

    return Positioned(
      right: 0,
      top: 0,
      bottom: 0,
      width: 220,
      child: Material(
        elevation: 8,
        color: panelBg,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Bookmarks',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => setState(() => _showBookmarks = false),
                    child: Icon(Icons.close, size: 18, color: mutedColor),
                  ),
                ],
              ),
            ),
            Divider(color: isDark ? Colors.white12 : AppColors.border, height: 1),
            Expanded(
              child: _bookmarks.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.bookmark_border, size: 32, color: mutedColor),
                            const SizedBox(height: 8),
                            Text(
                              'No bookmarks yet',
                              style: TextStyle(fontSize: 13, color: mutedColor),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Tap the bookmark icon to save a page',
                              style: TextStyle(fontSize: 11, color: mutedColor),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: _bookmarks.length,
                      separatorBuilder: (_, _) => Divider(
                        color: isDark ? Colors.white10 : AppColors.border,
                        height: 1,
                        indent: 16,
                        endIndent: 16,
                      ),
                      itemBuilder: (context, index) {
                        final page = _bookmarks[index];
                        final isCurrent = page == _currentPage;
                        return ListTile(
                          dense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 0,
                          ),
                          leading: Icon(
                            Icons.bookmark,
                            size: 18,
                            color: isCurrent ? AppColors.teal : mutedColor,
                          ),
                          title: Text(
                            'Page ${page + 1}',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w400,
                              color: isCurrent ? AppColors.teal : textColor,
                            ),
                          ),
                          onTap: () {
                            _goToPage(page);
                            setState(() => _showBookmarks = false);
                          },
                          trailing: GestureDetector(
                            onTap: () {
                              final repo = ref.read(userPrefsRepositoryProvider);
                              repo.toggleBookmark(widget.book.id, page);
                              setState(() {
                                _bookmarks = repo.getBookmarks(widget.book.id);
                              });
                            },
                            child: Icon(Icons.close, size: 14, color: mutedColor),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Go to Page Dialog ──────────────────────────────────────────────────

  void _showGoToPageDialog() {
    _pageInputController.text = '${_currentPage + 1}';
    _pageInputController.selection = TextSelection(
      baseOffset: 0,
      extentOffset: _pageInputController.text.length,
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Go to Page'),
        content: TextField(
          controller: _pageInputController,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          autofocus: true,
          decoration: InputDecoration(
            hintText: '1 - $_totalPages',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onSubmitted: (val) {
            final page = int.tryParse(val);
            if (page != null && page >= 1 && page <= _totalPages) {
              _goToPage(page - 1);
            }
            Navigator.of(ctx).pop();
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final page = int.tryParse(_pageInputController.text);
              if (page != null && page >= 1 && page <= _totalPages) {
                _goToPage(page - 1);
              }
              Navigator.of(ctx).pop();
            },
            child: const Text('Go'),
          ),
        ],
      ),
    );
  }

  // ─── Color Filter Wrapper ───────────────────────────────────────────────

  Widget _wrapWithFilter(Widget child) {
    switch (_colorFilter) {
      case 'dark':
        return ColorFiltered(
          colorFilter: const ColorFilter.matrix([
            -1, 0, 0, 0, 255,
             0, -1, 0, 0, 255,
             0, 0, -1, 0, 255,
             0, 0, 0, 1, 0,
          ]),
          child: child,
        );
      case 'sepia':
        return ColorFiltered(
          colorFilter: const ColorFilter.matrix([
            0.393, 0.769, 0.189, 0, 0,
            0.349, 0.686, 0.168, 0, 0,
            0.272, 0.534, 0.131, 0, 0,
            0, 0, 0, 1, 0,
          ]),
          child: child,
        );
      default:
        return child;
    }
  }

  // ─── Loading View ───────────────────────────────────────────────────────

  Widget _buildLoadingView() {
    final cs = Theme.of(context).colorScheme;

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
                    color: Theme.of(context).textTheme.bodySmall?.color,
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
                      backgroundColor: cs.surface,
                      valueColor: AlwaysStoppedAnimation<Color>(cs.primary),
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

  // ─── Error View ─────────────────────────────────────────────────────────

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
                    color: Theme.of(context).textTheme.bodySmall?.color,
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
}
