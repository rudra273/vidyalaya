import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/theme.dart';
import '../providers/regional_language_provider.dart';

/// A compact language switcher for the Explore tools' app bars.
///
/// English is always shown in those screens; this toggles the *second*
/// language between Odia and Hindi. Place it in [AppBar.actions]. The choice
/// is read from and written to [regionalLanguageProvider] (persisted).
class RegionalLanguageSwitch extends ConsumerWidget {
  const RegionalLanguageSwitch({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(regionalLanguageProvider);
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: PopupMenuButton<RegionalLanguage>(
        tooltip: 'Change language',
        position: PopupMenuPosition.under,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        onSelected: (lang) =>
            ref.read(regionalLanguageProvider.notifier).set(lang),
        itemBuilder: (context) => RegionalLanguage.values.map((lang) {
          final selected = lang == current;
          return PopupMenuItem<RegionalLanguage>(
            value: lang,
            child: Row(
              children: [
                Icon(
                  selected ? Icons.check_rounded : Icons.translate_rounded,
                  size: 18,
                  color: selected ? cs.primary : AppColors.textMuted,
                ),
                const SizedBox(width: 12),
                Text(
                  '${lang.labelNative}  (${lang.labelEn})',
                  style: TextStyle(
                    fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                    color: selected ? cs.primary : null,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: isDark ? AppColors.hairlineDark : AppColors.hairline,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.translate_rounded, size: 16, color: cs.primary),
              const SizedBox(width: 6),
              Text(
                current.labelNative,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(width: 2),
              Icon(Icons.arrow_drop_down_rounded,
                  size: 18, color: AppColors.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}
