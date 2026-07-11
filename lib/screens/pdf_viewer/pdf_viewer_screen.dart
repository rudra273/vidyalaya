import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../../app/theme.dart';
import '../../utils/haptics.dart';
import '../../data/models/book.dart';
import '../../data/models/highlight.dart';
import '../../providers/core_providers.dart';
import '../../providers/reading_provider.dart';
import '../../providers/progress_provider.dart';
import 'widgets/highlight_overlay.dart';

class PdfViewerScreen extends ConsumerStatefulWidget {
  final Book book;
  final int? initialPage;

  const PdfViewerScreen({super.key, required this.book, this.initialPage});

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
  String _viewMode = 'paginated';
  String _colorFilter = 'none';
  double _brightness = 1.0;
  bool _showControls = false;
  bool _showBookmarks = false;
  List<int> _bookmarks = [];

  // Highlight state
  bool _highlightMode = false;
  List<Highlight> _pageHighlights = [];

  final _pageInputController = TextEditingController();
  final _noteController = TextEditingController();

  // Progress Tracking
  DateTime? _sessionStartTime;
  final Set<int> _viewedPages = {};

  @override
  void initState() {
    super.initState();
    _sessionStartTime = DateTime.now();
    _loadPreferences();
    _loadPdf();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(readingProvider.notifier).setLastRead(widget.book);
    });
  }

  @override
  void dispose() {
    _pageInputController.dispose();
    _noteController.dispose();
    _saveCurrentPage();
    
    // Log progress
    final repo = ref.read(userPrefsRepositoryProvider);
    if (_sessionStartTime != null) {
      final seconds = DateTime.now().difference(_sessionStartTime!).inSeconds;
      if (seconds > 0) repo.addStudySeconds(seconds);
    }
    if (_viewedPages.isNotEmpty) {
      repo.addPagesRead(_viewedPages.length, widget.book.subject);
    }
    
    // Invalidate progress provider so dashboard updates
    ref.invalidate(progressProvider);
    
    super.dispose();
  }

  void _loadPreferences() {
    final repo = ref.read(userPrefsRepositoryProvider);
    _viewMode = repo.getReaderViewMode();
    _colorFilter = repo.getReaderFilter();
    _bookmarks = repo.getBookmarks(widget.book.id);
  }

  void _saveCurrentPage() {
    ref.read(userPrefsRepositoryProvider).setLastReadPage(widget.book.id, _currentPage);
  }

  int _getStartPage() {
    if (widget.initialPage != null) return widget.initialPage!;
    return ref.read(userPrefsRepositoryProvider).getLastReadPage(widget.book.id);
  }

  void _loadPageHighlights() {
    final repo = ref.read(userPrefsRepositoryProvider);
    setState(() {
      _pageHighlights = repo.getHighlightsForPage(widget.book.id, _currentPage);
    });
  }

  // ─── Bookmark ───────────────────────────────────────────────────────────

  void _toggleBookmark() {
    final repo = ref.read(userPrefsRepositoryProvider);
    repo.toggleBookmark(widget.book.id, _currentPage);
    Haptics.medium(ref);
    setState(() {
      _bookmarks = repo.getBookmarks(widget.book.id);
    });
    final isNow = _bookmarks.contains(_currentPage);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(isNow ? 'Page ${_currentPage + 1} bookmarked' : 'Bookmark removed'),
      duration: const Duration(seconds: 1),
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 80),
    ));
  }

  // ─── Highlight ──────────────────────────────────────────────────────────

  void _onHighlightCreated(Rect rect) {
    // Exit highlight mode after one draw
    setState(() => _highlightMode = false);

    final highlight = Highlight(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      bookId: widget.book.id,
      pageNumber: _currentPage,
      left: rect.left,
      top: rect.top,
      right: rect.right,
      bottom: rect.bottom,
      createdAt: DateTime.now(),
    );

    // Show note dialog
    _showAddNoteSheet(highlight);
  }

  void _showAddNoteSheet(Highlight highlight) {
    _noteController.clear();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Add a note',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 4),
              Text(
                'Optional — you can just save the highlight',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _noteController,
                maxLines: 3,
                autofocus: false,
                decoration: InputDecoration(
                  hintText: 'Write your note here...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.teal),
                  ),
                  contentPadding: const EdgeInsets.all(14),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        _saveHighlight(highlight, null);
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Skip'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        final note = _noteController.text.trim();
                        _saveHighlight(highlight, note.isEmpty ? null : note);
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Save'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveHighlight(Highlight highlight, String? note) {
    final h = Highlight(
      id: highlight.id,
      bookId: highlight.bookId,
      pageNumber: highlight.pageNumber,
      left: highlight.left,
      top: highlight.top,
      right: highlight.right,
      bottom: highlight.bottom,
      note: note,
      createdAt: highlight.createdAt,
    );
    ref.read(userPrefsRepositoryProvider).addHighlight(h);
    _loadPageHighlights();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Highlight saved'),
      duration: Duration(seconds: 1),
      behavior: SnackBarBehavior.floating,
    ));
  }

  void _onHighlightTapped(Highlight hl) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Page ${hl.pageNumber + 1}',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    ref.read(userPrefsRepositoryProvider).removeHighlight(widget.book.id, hl.id);
                    _loadPageHighlights();
                  },
                ),
              ],
            ),
            if (hl.note != null && hl.note!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(hl.note!, style: Theme.of(context).textTheme.bodyMedium),
              ),
            ],
            if (hl.note == null || hl.note!.isEmpty) ...[
              const SizedBox(height: 8),
              Text('No note attached', style: Theme.of(context).textTheme.bodySmall),
            ],
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  _showEditNoteSheet(hl);
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Text(hl.note != null ? 'Edit Note' : 'Add Note'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditNoteSheet(Highlight hl) {
    _noteController.text = hl.note ?? '';
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Edit Note', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              TextField(
                controller: _noteController,
                maxLines: 3,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Write your note...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.teal),
                  ),
                  contentPadding: const EdgeInsets.all(14),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    final note = _noteController.text.trim();
                    ref.read(userPrefsRepositoryProvider).updateHighlightNote(
                          widget.book.id, hl.id, note.isEmpty ? null : note);
                    _loadPageHighlights();
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Save'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Page navigation ────────────────────────────────────────────────────

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
      setState(() { _isLoading = true; _error = null; _downloadProgress = 0; });

      final dir = await getApplicationDocumentsDirectory();
      final booksDir = Directory('${dir.path}/books');
      if (!booksDir.existsSync()) booksDir.createSync(recursive: true);

      final filePath = '${booksDir.path}/${widget.book.id}.pdf';
      final file = File(filePath);

      if (file.existsSync() && file.lengthSync() > 0) {
        if (mounted) setState(() { _localPath = filePath; _isLoading = false; });
        return;
      }

      // Stream to a temp file and rename on success, so an interrupted
      // download never leaves a half-written .pdf that later reads as valid.
      final tmpFile = File('$filePath.part');
      final client = http.Client();
      try {
        final request = http.Request('GET', Uri.parse(widget.book.pdfUrl));
        final response = await client.send(request);
        if (response.statusCode != 200) {
          throw Exception('Failed to download: HTTP ${response.statusCode}');
        }

        final contentLength = response.contentLength ?? 0;
        final sink = tmpFile.openWrite();
        var received = 0;
        // Throttle progress rebuilds: only setState when the whole-percent
        // ticks up, not on every network chunk.
        var lastPercent = -1;
        try {
          await for (final chunk in response.stream) {
            sink.add(chunk);
            received += chunk.length;
            if (contentLength > 0 && mounted) {
              final percent = (received * 100) ~/ contentLength;
              if (percent != lastPercent) {
                lastPercent = percent;
                setState(() => _downloadProgress = percent / 100);
              }
            }
          }
          await sink.flush();
        } finally {
          await sink.close();
        }

        await tmpFile.rename(filePath);
      } finally {
        client.close();
        if (tmpFile.existsSync()) {
          try {
            tmpFile.deleteSync();
          } catch (_) {}
        }
      }

      if (mounted) setState(() { _localPath = filePath; _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _isLoading = false; });
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
              title: Text(widget.book.title, style: Theme.of(context).textTheme.titleLarge),
            )
          : null,
      body: _isLoading
          ? _buildLoadingView()
          : _error != null
              ? _buildErrorView()
              : _buildReaderView(),
    );
  }

  // ─── Reader View ────────────────────────────────────────────────────────

  Widget _buildReaderView() {
    final isBookmarked = _bookmarks.contains(_currentPage);
    final progress = _totalPages > 0 ? (_currentPage + 1) / _totalPages : 0.0;

    return Column(
      children: [
        _buildTopBar(isBookmarked),

        // Reading progress
        SizedBox(
          height: 3,
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey.withValues(alpha: 0.15),
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.teal),
          ),
        ),

        // PDF + overlays
        Expanded(
          child: Stack(
            children: [
              _wrapWithFilter(
                PDFView(
                  key: ValueKey('${_localPath}_$_viewMode'),
                  filePath: _localPath!,
                  enableSwipe: !_highlightMode,
                  swipeHorizontal: false,
                  autoSpacing: _viewMode == 'paginated',
                  pageFling: _viewMode == 'paginated',
                  pageSnap: _viewMode == 'paginated',
                  defaultPage: _getStartPage(),
                  onRender: (pages) {
                    if (mounted) {
                      setState(() => _totalPages = pages ?? 0);
                      _loadPageHighlights();
                    }
                  },
                  onViewCreated: (controller) => _pdfController = controller,
                  onPageChanged: (page, total) {
                    if (mounted) {
                      setState(() {
                        _currentPage = page ?? 0;
                        _totalPages = total ?? 0;
                      });
                      _viewedPages.add(_currentPage);
                      _saveCurrentPage();
                      _loadPageHighlights();
                    }
                  },
                  onError: (error) {
                    if (mounted) setState(() => _error = error.toString());
                  },
                ),
              ),

              // Highlight overlay (renders saved highlights + drawing canvas)
              Positioned.fill(
                child: HighlightOverlay(
                  highlights: _pageHighlights,
                  isDrawMode: _highlightMode,
                  onHighlightCreated: _onHighlightCreated,
                  onHighlightTapped: _onHighlightTapped,
                ),
              ),

              // Brightness
              if (_brightness < 1.0)
                Positioned.fill(
                  child: IgnorePointer(
                    child: Container(color: Colors.black.withValues(alpha: 1.0 - _brightness)),
                  ),
                ),

              if (_showControls) _buildControlsOverlay(),
              if (_showBookmarks) _buildBookmarksPanel(),
            ],
          ),
        ),

        _buildBottomBar(),
      ],
    );
  }

  // ─── Top Bar ────────────────────────────────────────────────────────────

  Widget _buildTopBar(bool isBookmarked) {
    final isDark = _colorFilter == 'dark';
    final bgColor = isDark ? Colors.grey.shade900 : Theme.of(context).scaffoldBackgroundColor;
    final iconDefault = isDark ? Colors.white54 : AppColors.textMuted;

    return SafeArea(
      bottom: false,
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: bgColor,
          border: Border(bottom: BorderSide(color: isDark ? Colors.white12 : AppColors.border)),
        ),
        child: Row(
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back, color: isDark ? Colors.white70 : null),
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
                      fontSize: 15, fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : AppColors.navy,
                    ),
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                  ),
                  if (_totalPages > 0)
                    Text(
                      'Page ${_currentPage + 1} of $_totalPages',
                      style: TextStyle(fontSize: 11, color: isDark ? Colors.white54 : AppColors.textMuted),
                    ),
                ],
              ),
            ),
            // Highlighter button
            _buildTopBarBtn(
              icon: Icons.edit,
              isActive: _highlightMode,
              activeColor: Colors.amber.shade700,
              defaultColor: iconDefault,
              tooltip: 'Highlight',
              onTap: () => setState(() {
                _highlightMode = !_highlightMode;
                if (_highlightMode) { _showControls = false; _showBookmarks = false; }
              }),
            ),
            _buildTopBarBtn(
              icon: isBookmarked ? Icons.bookmark : Icons.bookmark_border,
              isActive: isBookmarked,
              activeColor: AppColors.teal,
              defaultColor: iconDefault,
              tooltip: 'Bookmark',
              onTap: _toggleBookmark,
            ),
            _buildTopBarBtn(
              icon: Icons.list,
              isActive: _showBookmarks,
              activeColor: AppColors.teal,
              defaultColor: iconDefault,
              tooltip: 'Bookmarks',
              onTap: () => setState(() {
                _showBookmarks = !_showBookmarks;
                if (_showBookmarks) { _showControls = false; _highlightMode = false; }
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBarBtn({
    required IconData icon,
    required bool isActive,
    required Color activeColor,
    required Color defaultColor,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return IconButton(
      icon: Icon(icon, size: 21, color: isActive ? activeColor : defaultColor),
      tooltip: tooltip,
      onPressed: onTap,
      visualDensity: VisualDensity.compact,
    );
  }

  // ─── Bottom Bar ─────────────────────────────────────────────────────────

  Widget _buildBottomBar() {
    final isDark = _colorFilter == 'dark';
    final bgColor = isDark ? Colors.grey.shade900 : Colors.white;
    final iconColor = isDark ? Colors.white54 : AppColors.textMuted;

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(top: BorderSide(color: isDark ? Colors.white12 : AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            children: [
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
                    value: _totalPages > 0 ? _currentPage.toDouble() : 0,
                    min: 0,
                    max: _totalPages > 0 ? (_totalPages - 1).toDouble() : 1,
                    onChanged: (val) => _goToPage(val.toInt()),
                  ),
                ),
              ),
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
                      fontSize: 13, fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white70 : AppColors.navy,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              IconButton(
                icon: Icon(Icons.tune_rounded, size: 22,
                    color: _showControls ? AppColors.teal : iconColor),
                tooltip: 'Reader settings',
                onPressed: () => setState(() {
                  _showControls = !_showControls;
                  if (_showControls) { _showBookmarks = false; _highlightMode = false; }
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Controls Overlay ───────────────────────────────────────────────────

  Widget _buildControlsOverlay() {
    final isDark = _colorFilter == 'dark';
    final panelBg = isDark ? Colors.grey.shade900 : Colors.white;
    final textColor = isDark ? Colors.white : AppColors.navy;
    final mutedColor = isDark ? Colors.white54 : AppColors.textMuted;

    return Positioned(
      left: 16, right: 16, bottom: 16,
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Reader Settings', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: textColor)),
                  GestureDetector(
                    onTap: () => setState(() => _showControls = false),
                    child: Icon(Icons.close, size: 20, color: mutedColor),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text('Display', style: TextStyle(fontSize: 12, color: mutedColor, fontWeight: FontWeight.w500)),
              const SizedBox(height: 10),
              Row(children: [
                _filterOpt('none', 'Normal', Icons.wb_sunny_outlined, mutedColor),
                const SizedBox(width: 8),
                _filterOpt('dark', 'Dark', Icons.dark_mode_outlined, mutedColor),
                const SizedBox(width: 8),
                _filterOpt('sepia', 'Sepia', Icons.auto_awesome, mutedColor),
              ]),
              const SizedBox(height: 20),
              Row(children: [
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
                    child: Slider(value: _brightness, min: 0.2, max: 1.0, onChanged: (v) => setState(() => _brightness = v)),
                  ),
                ),
                Icon(Icons.brightness_high, size: 18, color: mutedColor),
              ]),
              const SizedBox(height: 16),
              Text('View Mode', style: TextStyle(fontSize: 12, color: mutedColor, fontWeight: FontWeight.w500)),
              const SizedBox(height: 10),
              Row(children: [
                _viewOpt('paginated', 'Page', Icons.insert_drive_file_outlined, mutedColor),
                const SizedBox(width: 8),
                _viewOpt('scroll', 'Scroll', Icons.view_day_outlined, mutedColor),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _filterOpt(String value, String label, IconData icon, Color mutedColor) {
    final isActive = _colorFilter == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => _setColorFilter(value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? AppColors.teal.withValues(alpha: 0.12) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: isActive ? AppColors.teal.withValues(alpha: 0.4) : Colors.grey.withValues(alpha: 0.2)),
          ),
          child: Column(children: [
            Icon(icon, size: 20, color: isActive ? AppColors.teal : mutedColor),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(fontSize: 11, fontWeight: isActive ? FontWeight.w600 : FontWeight.w400, color: isActive ? AppColors.teal : mutedColor)),
          ]),
        ),
      ),
    );
  }

  Widget _viewOpt(String value, String label, IconData icon, Color mutedColor) {
    final isActive = _viewMode == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => _setViewMode(value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? AppColors.teal.withValues(alpha: 0.12) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: isActive ? AppColors.teal.withValues(alpha: 0.4) : Colors.grey.withValues(alpha: 0.2)),
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(icon, size: 18, color: isActive ? AppColors.teal : mutedColor),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(fontSize: 12, fontWeight: isActive ? FontWeight.w600 : FontWeight.w400, color: isActive ? AppColors.teal : mutedColor)),
          ]),
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
      right: 0, top: 0, bottom: 0, width: 220,
      child: Material(
        elevation: 8, color: panelBg,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Bookmarks', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: textColor)),
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
                        child: Column(mainAxisSize: MainAxisSize.min, children: [
                          Icon(Icons.bookmark_border, size: 32, color: mutedColor),
                          const SizedBox(height: 8),
                          Text('No bookmarks yet', style: TextStyle(fontSize: 13, color: mutedColor)),
                          const SizedBox(height: 4),
                          Text('Tap the bookmark icon to\nsave a page', style: TextStyle(fontSize: 11, color: mutedColor), textAlign: TextAlign.center),
                        ]),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: _bookmarks.length,
                      separatorBuilder: (_, _) => Divider(color: isDark ? Colors.white10 : AppColors.border, height: 1, indent: 16, endIndent: 16),
                      itemBuilder: (context, index) {
                        final page = _bookmarks[index];
                        final isCurrent = page == _currentPage;
                        return ListTile(
                          dense: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                          leading: Icon(Icons.bookmark, size: 18, color: isCurrent ? AppColors.teal : mutedColor),
                          title: Text('Page ${page + 1}', style: TextStyle(fontSize: 13, fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w400, color: isCurrent ? AppColors.teal : textColor)),
                          onTap: () { _goToPage(page); setState(() => _showBookmarks = false); },
                          trailing: GestureDetector(
                            onTap: () {
                              ref.read(userPrefsRepositoryProvider).toggleBookmark(widget.book.id, page);
                              setState(() => _bookmarks = ref.read(userPrefsRepositoryProvider).getBookmarks(widget.book.id));
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

  // ─── Go To Page Dialog ──────────────────────────────────────────────────

  void _showGoToPageDialog() {
    _pageInputController.text = '${_currentPage + 1}';
    _pageInputController.selection = TextSelection(baseOffset: 0, extentOffset: _pageInputController.text.length);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Go to Page'),
        content: TextField(
          controller: _pageInputController,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          autofocus: true,
          decoration: InputDecoration(hintText: '1 - $_totalPages', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
          onSubmitted: (val) {
            final p = int.tryParse(val);
            if (p != null && p >= 1 && p <= _totalPages) _goToPage(p - 1);
            Navigator.of(ctx).pop();
          },
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final p = int.tryParse(_pageInputController.text);
              if (p != null && p >= 1 && p <= _totalPages) _goToPage(p - 1);
              Navigator.of(ctx).pop();
            },
            child: const Text('Go'),
          ),
        ],
      ),
    );
  }

  // ─── Color Filter ───────────────────────────────────────────────────────

  Widget _wrapWithFilter(Widget child) {
    switch (_colorFilter) {
      case 'dark':
        return ColorFiltered(
          colorFilter: const ColorFilter.matrix([-1,0,0,0,255, 0,-1,0,0,255, 0,0,-1,0,255, 0,0,0,1,0]),
          child: child,
        );
      case 'sepia':
        return ColorFiltered(
          colorFilter: const ColorFilter.matrix([0.393,0.769,0.189,0,0, 0.349,0.686,0.168,0,0, 0.272,0.534,0.131,0,0, 0,0,0,1,0]),
          child: child,
        );
      default:
        return child;
    }
  }

  // ─── Loading & Error Views ──────────────────────────────────────────────

  Widget _buildLoadingView() {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(widget.book.coverEmoji, style: const TextStyle(fontSize: 48)),
          const SizedBox(height: 24),
          Text(_downloadProgress > 0 ? 'Downloading...' : 'Connecting...', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text(widget.book.title, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).textTheme.bodySmall?.color), textAlign: TextAlign.center),
          const SizedBox(height: 32),
          SizedBox(
            width: 200,
            child: Column(children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(value: _downloadProgress > 0 ? _downloadProgress : null, minHeight: 6, backgroundColor: cs.surface, valueColor: AlwaysStoppedAnimation<Color>(cs.primary)),
              ),
              if (_downloadProgress > 0) ...[const SizedBox(height: 8), Text('${(_downloadProgress * 100).toInt()}%', style: Theme.of(context).textTheme.bodySmall)],
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('⚠️', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 24),
          Text('Failed to load PDF', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text('Please check your internet connection and try again.', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).textTheme.bodySmall?.color), textAlign: TextAlign.center),
          const SizedBox(height: 24),
          ElevatedButton.icon(onPressed: _loadPdf, icon: const Icon(Icons.refresh), label: const Text('Retry')),
        ]),
      ),
    );
  }
}
