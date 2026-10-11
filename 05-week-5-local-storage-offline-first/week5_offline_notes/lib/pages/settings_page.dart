import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/providers.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offline = ref.watch(forceOfflineProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Force Offline'),
            subtitle: Text(
              offline ? 'Mode offline aktif' : 'Mode online aktif',
            ),
            value: offline,
            onChanged: (value) {
              ref
                  .read(forceOfflineProvider.notifier)
                  .setOffline(value);

              ref.invalidate(postsProvider);
            },
          ),
        ],
      ),
    );
  }
}