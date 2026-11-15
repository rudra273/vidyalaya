import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../data/models/app_notice.dart';
import '../../providers/auth_provider.dart';
import '../../providers/notifications_provider.dart';
import '../../providers/plus_provider.dart';
import '../../utils/ai_labels.dart';
import '../../widgets/ai_robot_mark.dart';
import '../../widgets/calm_widgets.dart';

/// **Notifications** — the in-app inbox. Notices are derived from app state
/// (see [notificationsProvider]); opening this screen marks them all read.
class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  /// Seen ids as they were when the screen opened, so notices stay styled as
  /// unread for this visit even though they are marked read straight away.
  late final Set<String> _seenAtOpen;
  late final SeenNoticeIds _seen;

  @override
  void initState() {
    super.initState();
    _seenAtOpen = ref.read(seenNoticeIdsProvider);
    _seen = ref.read(seenNoticeIdsProvider.notifier);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      // Bring the sources up to date, then mark what is listed as read.
      ref.read(noticeClockProvider.notifier).tick();
      unawaited(ref.read(plusProvider.notifier).refresh());
      unawaited(ref.read(backendAccountCacheProvider.notifier).ensureUsage());
      unawaited(_seen.markAllRead());
    });
  }

  @override
  void dispose() {
    // Anything that arrived while the screen was open has been seen too.
    unawaited(_seen.markAllRead());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notices = ref.watch(notificationsProvider);
    final now = ref.watch(noticeClockProvider);
    final today = DateTime(now.year, now.month, now.day);
    final todays = notices
        .where((n) => !n.time.toLocal().isBefore(today))
        .toList();
    final earlier = notices
        .where((n) => n.time.toLocal().isBefore(today))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Notifications',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Back',
          onPressed: () =>
              context.canPop() ? context.pop() : context.go('/'),
        ),
      ),
      body: SafeArea(
        top: false,
        child: notices.isEmpty
            ? const Column(
                children: [
                  Expanded(child: _CaughtUp()),
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      AppSpacing.screenPadding,
                      0,
                      AppSpacing.screenPadding,
                      24,
                    ),
                    child: _QuietHoursNote(),
                  ),
                ],
              )
            : ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenPadding,
                  8,
                  AppSpacing.screenPadding,
                  24,
                ),
                children: [
                  if (todays.isNotEmpty)
                    _NoticeGroup(
                      label: 'Today',
                      notices: todays,
                      now: now,
                      isUnread: _isUnread,
                    ),
                  if (todays.isNotEmpty && earlier.isNotEmpty)
                    const SizedBox(height: 20),
                  if (earlier.isNotEmpty)
                    _NoticeGroup(
                      label: 'Earlier',
                      notices: earlier,
                      now: now,
                      isUnread: _isUnread,
                    ),
                  const SizedBox(height: 24),
                  const _QuietHoursNote(),
                ],
              ),
      ),
    );
  }

  bool _isUnread(AppNotice notice) => !_seenAtOpen.contains(notice.id);
}

// ─── Group: section head + card of rows ──────────────────────────────────

class _NoticeGroup extends StatelessWidget {
  final String label;
  final List<AppNotice> notices;
  final DateTime now;
  final bool Function(AppNotice) isUnread;

  const _NoticeGroup({
    required this.label,
    required this.notices,
    required this.now,
    required this.isUnread,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHead(label: label),
        Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: cs.surface,
            border: Border.all(color: cs.outline),
            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          ),
          child: Column(
            children: [
              for (var i = 0; i < notices.length; i++)
                _NoticeRow(
                  notice: notices[i],
                  now: now,
                  unread: isUnread(notices[i]),
                  last: i == notices.length - 1,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Row ─────────────────────────────────────────────────────────────────

class _NoticeRow extends StatelessWidget {
  final AppNotice notice;
  final DateTime now;
  final bool unread;
  final bool last;

  const _NoticeRow({
    required this.notice,
    required this.now,
    required this.unread,
    required this.last,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final hair = isDark ? AppColors.hairline2Dark : AppColors.hairline2;
    final ink2 = isDark ? AppColors.ink2Dark : AppColors.ink2;
    final (icon, color) = _look(notice.kind, isDark);
    final route = notice.route;
    final time = _relativeTime(notice.time, now);

    return Semantics(
      button: route != null,
      label: unread ? 'Unread' : null,
      child: InkWell(
        onTap: route == null ? null : () => context.push(route),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            decoration: last
                ? null
                : BoxDecoration(
                    border: Border(bottom: BorderSide(color: hair)),
                  ),
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Tile(color: color, icon: icon, size: 40, radius: 13),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notice.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontSize: AppFontSize.content,
                          height: 1.3,
                          fontWeight: unread
                              ? AppFontWeight.bold
                              : AppFontWeight.semibold,
                          color: cs.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        notice.body,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontSize: AppFontSize.body,
                          height: 1.4,
                          color: ink2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        time,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: AppFontSize.small,
                          color: ink2,
                        ),
                      ),
                    ],
                  ),
                ),
                if (unread)
                  Padding(
                    padding: const EdgeInsets.only(left: 10, top: 6),
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: cs.primary,
                        shape: BoxShape.circle,
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

  static (IconData, Color) _look(AppNoticeKind kind, bool isDark) {
    return switch (kind) {
      AppNoticeKind.plus => (
        Icons.star_rounded,
        isDark ? AppColors.cAiDark : AppColors.cAi,
      ),
      AppNoticeKind.aiQuestions => (
        Icons.auto_awesome_rounded,
        isDark ? AppColors.cMathHubDark : AppColors.cMathHub,
      ),
      AppNoticeKind.timetable => (
        Icons.calendar_today_rounded,
        isDark ? AppColors.cScienceDark : AppColors.cScience,
      ),
      AppNoticeKind.challenge => (
        Icons.extension_rounded,
        isDark ? AppColors.cMathsDark : AppColors.cMaths,
      ),
    };
  }
}

/// "Just now", "5 min ago", "2 hours ago", "Yesterday", "Mon", or "12 Dec".
String _relativeTime(DateTime time, DateTime now) {
  final local = time.toLocal();
  final diff = now.difference(local);
  if (diff.inMinutes < 1) return 'Just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
  final today = DateTime(now.year, now.month, now.day);
  final day = DateTime(local.year, local.month, local.day);
  final days = today.difference(day).inDays;
  if (days == 0) {
    final hours = diff.inHours;
    return hours == 1 ? '1 hour ago' : '$hours hours ago';
  }
  if (days == 1) return 'Yesterday';
  if (days < 7) {
    const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return names[local.weekday - 1];
  }
  return shortDate(local);
}

// ─── Empty state ─────────────────────────────────────────────────────────

class _CaughtUp extends StatelessWidget {
  const _CaughtUp();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const AiBot(size: 72, mood: BotMood.resting),
            const SizedBox(height: 18),
            Text(
              "You're all caught up",
              style: theme.textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Nothing new right now. Updates about your timetable, '
              'AI questions and Plus will show up here.',
              style: theme.textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Quiet hours footer ──────────────────────────────────────────────────

class _QuietHoursNote extends StatelessWidget {
  const _QuietHoursNote();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surface2Dark : AppColors.surface3,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(
            Icons.bedtime_outlined,
            size: 22,
            color: theme.colorScheme.onSurface,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Quiet hours: nothing is sent between 9 pm and 7 am.',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: AppFontSize.body,
                height: 1.4,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
