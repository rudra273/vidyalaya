import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:in_app_update/in_app_update.dart';

import '../data/services/app_share.dart';

/// Shows a Play Store update only when Google Play offers one to this device.
class AppUpdateBanner extends StatefulWidget {
  const AppUpdateBanner({super.key});

  @override
  State<AppUpdateBanner> createState() => _AppUpdateBannerState();
}

class _AppUpdateBannerState extends State<AppUpdateBanner>
    with WidgetsBindingObserver {
  bool _updateAvailable = false;
  bool _dismissed = false;
  bool _checking = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkForUpdate();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkForUpdate();
    }
  }

  Future<void> _checkForUpdate() async {
    if (kIsWeb ||
        defaultTargetPlatform != TargetPlatform.android ||
        _checking) {
      return;
    }

    _checking = true;
    try {
      final info = await InAppUpdate.checkForUpdate();
      if (!mounted) return;
      setState(() {
        _updateAvailable =
            info.updateAvailability == UpdateAvailability.updateAvailable;
      });
    } catch (_) {
      // Play's update API can be unavailable for local or non-Play installs.
    } finally {
      _checking = false;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_updateAvailable || _dismissed) return const SizedBox.shrink();

    final colors = Theme.of(context).colorScheme;
    return Material(
      color: colors.secondary,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 6, 4, 6),
        child: Row(
          children: [
            Icon(Icons.system_update_rounded, color: colors.onSecondary),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'A new version of Vidya AI is available.',
                style: TextStyle(color: colors.onSecondary),
              ),
            ),
            TextButton(
              onPressed: () async {
                try {
                  await AppShare.openPlayStore();
                } catch (_) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Could not open Play Store.')),
                  );
                }
              },
              child: const Text('Update'),
            ),
            IconButton(
              tooltip: 'Dismiss update banner',
              onPressed: () => setState(() => _dismissed = true),
              icon: const Icon(Icons.close_rounded),
              color: colors.onSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
