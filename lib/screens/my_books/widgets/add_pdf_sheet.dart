import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme.dart';
import '../../../providers/books_provider.dart';
import '../../../providers/user_selection_provider.dart';
import '../../../widgets/calm_widgets.dart';

// ─── Add a PDF from the student's own files ──────────────────────────────

const _subjectChoices = [
  'maths',
  'science',
  'social',
  'english',
  'hindi',
  'odia',
  'sanskrit',
  'other',
];

/// Lets the student pick a PDF from their device, name it, and add it to the
/// Library. Official NCERT books cannot be republished, so students bring
/// their own copies.
Future<void> pickAndAddPdf(BuildContext context, WidgetRef ref) async {
  final messenger = ScaffoldMessenger.of(context);
  final FilePickerResult? picked;
  try {
    picked = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf'],
    );
  } catch (_) {
    messenger.showSnackBar(
      const SnackBar(content: Text('Could not open the file picker.')),
    );
    return;
  }
  final path = picked?.files.single.path;
  if (path == null || !context.mounted) return;

  final name = picked!.files.single.name;
  final suggested = name.toLowerCase().endsWith('.pdf')
      ? name.substring(0, name.length - 4)
      : name;

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _AddPdfSheet(sourcePath: path, suggestedTitle: suggested),
  );
}

class _AddPdfSheet extends ConsumerStatefulWidget {
  final String sourcePath;
  final String suggestedTitle;

  const _AddPdfSheet({required this.sourcePath, required this.suggestedTitle});

  @override
  ConsumerState<_AddPdfSheet> createState() => _AddPdfSheetState();
}

class _AddPdfSheetState extends ConsumerState<_AddPdfSheet> {
  late final TextEditingController _title;
  late int _classNumber;
  String _subject = 'other';
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _title = TextEditingController(text: widget.suggestedTitle);
    _classNumber = ref.read(primaryClassProvider);
  }

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final title = _title.text.trim();
    if (title.isEmpty || _saving) return;
    setState(() => _saving = true);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    try {
      await ref
          .read(userBooksProvider.notifier)
          .importPdf(
            sourcePath: widget.sourcePath,
            title: title,
            subject: _subject,
            classNumber: _classNumber,
            boardId: ref.read(userBoardProvider),
          );
      // Make sure the new book is visible in the Library right away.
      final selected = ref.read(libraryClassSelectionProvider);
      if (!selected.contains(_classNumber)) {
        ref.read(libraryClassSelectionProvider.notifier).setClasses({
          ...selected,
          _classNumber,
        });
      }
      ref.read(subjectFilterProvider.notifier).setFilter(null);
      navigator.pop();
      messenger.showSnackBar(
        SnackBar(content: Text('Added "$title" to Class $_classNumber.')),
      );
    } on BookImportException catch (e) {
      if (mounted) setState(() => _saving = false);
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    } on FileSystemException {
      if (mounted) setState(() => _saving = false);
      messenger.showSnackBar(
        const SnackBar(content: Text('Could not save the file.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomInset),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.85,
          ),
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenPadding,
            10,
            AppSpacing.screenPadding,
            AppSpacing.screenPadding,
          ),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 38,
                    height: 4,
                    decoration: BoxDecoration(
                      color: cs.onSurface.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Add to Library',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 3),
                Text(
                  'The PDF stays on this device.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 18),
                TextField(
                  controller: _title,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(labelText: 'Book name'),
                ),
                const SizedBox(height: 18),
                Text('Class', style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (var c = 1; c <= 12; c++)
                      ChoiceChip(
                        label: Text('$c'),
                        selected: _classNumber == c,
                        onSelected: (_) => setState(() => _classNumber = c),
                      ),
                  ],
                ),
                const SizedBox(height: 18),
                Text('Subject', style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final key in _subjectChoices)
                      ChoiceChip(
                        label: Text(
                          key == 'other' ? 'Other' : subjectMeta(key).label,
                        ),
                        selected: _subject == key,
                        onSelected: (_) => setState(() => _subject = key),
                      ),
                  ],
                ),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saving ? null : _save,
                    child: Text(_saving ? 'Adding…' : 'Add book'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
