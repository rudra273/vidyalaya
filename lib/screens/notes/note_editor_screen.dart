import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme.dart';
import '../../data/models/note.dart';
import '../../providers/core_providers.dart';

/// Full-screen editor for a standalone (typed) note.
///
/// Pass an existing [noteId] to edit; omit it to start a new note. The note is
/// saved automatically when the user leaves the screen — an untouched, empty
/// note is discarded rather than cluttering the list.
class NoteEditorScreen extends ConsumerStatefulWidget {
  final String? noteId;

  const NoteEditorScreen({super.key, this.noteId});

  @override
  ConsumerState<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends ConsumerState<NoteEditorScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _bodyController;

  // Identity + timestamps for the note being edited. For a new note these are
  // generated up front so saving is a simple upsert.
  late final String _id;
  late final DateTime _createdAt;
  Note? _original;

  @override
  void initState() {
    super.initState();
    final repo = ref.read(userPrefsRepositoryProvider);
    final existing = widget.noteId != null ? repo.getNote(widget.noteId!) : null;
    _original = existing;
    _id = existing?.id ??
        DateTime.now().microsecondsSinceEpoch.toString();
    _createdAt = existing?.createdAt ?? DateTime.now();
    _titleController = TextEditingController(text: existing?.title ?? '');
    _bodyController = TextEditingController(text: existing?.body ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  /// Persists the current content. Discards (or deletes) the note when it is
  /// empty so the list never fills with blank entries.
  Future<void> _save() async {
    final repo = ref.read(userPrefsRepositoryProvider);
    final title = _titleController.text;
    final body = _bodyController.text;

    final note = Note(
      id: _id,
      title: title,
      body: body,
      createdAt: _createdAt,
      updatedAt: DateTime.now(),
    );

    if (note.isEmpty) {
      // Nothing to keep. Remove any previously-saved version.
      if (_original != null) await repo.deleteNote(_id);
      return;
    }

    // Skip the write if nothing actually changed.
    final unchanged = _original != null &&
        _original!.title == title &&
        _original!.body == body;
    if (unchanged) return;

    await repo.upsertNote(note);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // Autosave on the way out, then let the pop proceed.
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) _save();
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
          actions: [
            if (_original != null)
              IconButton(
                icon: const Icon(Icons.delete_outline),
                tooltip: 'Delete note',
                onPressed: _confirmDelete,
              ),
          ],
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _titleController,
                  textCapitalization: TextCapitalization.sentences,
                  style: Theme.of(context).textTheme.displaySmall,
                  decoration: const InputDecoration(
                    hintText: 'Title',
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 8),
                  ),
                  textInputAction: TextInputAction.next,
                ),
                Expanded(
                  child: TextField(
                    controller: _bodyController,
                    textCapitalization: TextCapitalization.sentences,
                    expands: true,
                    maxLines: null,
                    minLines: null,
                    textAlignVertical: TextAlignVertical.top,
                    style: Theme.of(context).textTheme.bodyLarge,
                    decoration: const InputDecoration(
                      hintText: 'Start typing your note…',
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete note?'),
        content: const Text('This note will be permanently removed.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    await ref.read(userPrefsRepositoryProvider).deleteNote(_id);
    // Mark as gone so the autosave-on-pop doesn't re-create it.
    _original = null;
    _titleController.clear();
    _bodyController.clear();
    if (mounted) Navigator.of(context).pop();
  }
}
