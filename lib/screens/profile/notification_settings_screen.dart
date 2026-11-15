import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart'
    show openAppSettings;

import '../../app/theme.dart';
import '../../providers/notifications_provider.dart';
import '../../providers/phone_reminders_provider.dart';
import '../../widgets/calm_widgets.dart';
import 'widgets/settings_group.dart';

class NotificationSettingsScreen extends ConsumerWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(phoneRemindersProvider);
    final reminders = ref.read(phoneRemindersProvider.notifier);
    final theme = Theme.of(context);
    final message = switch (status) {
      PhoneReminderStatus.enabled =>
        'Reminders appear in the inbox and as phone alerts.',
      PhoneReminderStatus.blocked =>
        'Phone alerts are off. Reminders can still appear in the inbox.',
      PhoneReminderStatus.unsupported =>
        'Reminders appear in the in-app inbox on this device.',
      PhoneReminderStatus.checking => 'Checking phone notifications…',
      PhoneReminderStatus.unavailable =>
        'Phone alerts could not be scheduled. Try again.',
    };
    return Scaffold(
      body: SafeArea(
        child: ListView(
          children: [
            PageTitle(
              title: 'Notifications',
              onBack: () =>
                  context.canPop() ? context.pop() : context.go('/settings'),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.screenPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(message, style: theme.textTheme.bodyMedium),
                  if (status == PhoneReminderStatus.blocked)
                    Wrap(
                      spacing: 8,
                      children: [
                        FilledButton(
                          onPressed: reminders.requestPermission,
                          child: const Text('Allow phone notifications'),
                        ),
                        TextButton(
                          onPressed: openAppSettings,
                          child: const Text('Device settings'),
                        ),
                      ],
                    ),
                  if (status == PhoneReminderStatus.unavailable)
                    TextButton(
                      onPressed: reminders.refresh,
                      child: const Text('Try again'),
                    ),
                  const SizedBox(height: AppSpacing.sectionGap),
                  SettingsGroup(
                    showBorder: false,
                    children: [
                      for (final type in ReminderType.values)
                        _ReminderRow(type: type),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReminderRow extends ConsumerWidget {
  const _ReminderRow({required this.type});

  final ReminderType type;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = reminderEnabledProvider(type);
    final (title, icon) = switch (type) {
      ReminderType.timetable => (
        'Timetable reminders',
        Icons.calendar_today_outlined,
      ),
      ReminderType.dailyChallenge => (
        'Daily challenge reminders',
        Icons.psychology_outlined,
      ),
    };
    return SettingsRow(
      color: Theme.of(context).colorScheme.primary,
      icon: icon,
      title: title,
      trailing: Semantics(
        label: title,
        child: Switch(
          value: ref.watch(provider),
          onChanged: ref.read(provider.notifier).set,
        ),
      ),
    );
  }
}
