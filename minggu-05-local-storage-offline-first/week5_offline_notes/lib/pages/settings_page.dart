import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/offline_providers.dart';
import '../providers/prefs_providers.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final darkAsync = ref.watch(darkModeProvider);
    final lastOpenedAsync = ref.watch(lastOpenedProvider);
    final offline = ref.watch(forceOfflineProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan')),
      body: ListView(
        children: [
          darkAsync.when(
            loading: () => const ListTile(
              title: Text('Memuat preferensi...'),
              trailing: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
            error: (error, _) => ListTile(
              leading: const Icon(Icons.error_outline),
              title: const Text('Gagal memuat preferensi'),
              subtitle: Text('$error'),
            ),
            data: (isDark) => SwitchListTile(
              secondary: const Icon(Icons.dark_mode_outlined),
              title: const Text('Tema gelap'),
              subtitle: const Text('Disimpan di SharedPreferences'),
              value: isDark,
              onChanged: (_) => ref.read(darkModeProvider.notifier).toggle(),
            ),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.airplanemode_active_outlined),
            title: const Text('Paksa mode offline'),
            subtitle: const Text('Untuk demo dan pengujian tanpa jaringan'),
            value: offline,
            onChanged: (value) =>
                ref.read(forceOfflineProvider.notifier).setOffline(value),
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Terakhir dibuka'),
            subtitle: Text(
              lastOpenedAsync.when(
                data: (value) => value ?? 'Baru pertama kali dibuka',
                loading: () => 'Memuat...',
                error: (error, _) => 'Error: $error',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
