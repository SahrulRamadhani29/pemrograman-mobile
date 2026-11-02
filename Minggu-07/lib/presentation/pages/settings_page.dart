import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/failures/app_failure.dart';
import '../providers/app_providers.dart';
import '../routing/app_routes.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});
  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  bool busy = false;
  Future<void> logout() async {
    final auth = ref.read(authStateProvider.notifier);
    setState(() => busy = true);
    try {
      await auth.logout();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(failureMessage(error))));
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final push = ref.watch(pushServiceProvider);
    return Scaffold(
      bottomNavigationBar: NavigationBar(
        selectedIndex: 1,
        backgroundColor: Colors.white,
        onDestinationSelected: (index) {
          if (index == 0) context.go(AppRoutes.home);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(CupertinoIcons.tray),
            label: 'Kotak Masuk',
          ),
          NavigationDestination(
            icon: Icon(CupertinoIcons.slider_horizontal_3),
            label: 'Pengaturan',
          ),
        ],
      ),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: push,
          builder: (context, _) => ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const SizedBox(height: 24),
              const Text(
                'Pengaturan',
                style: TextStyle(
                  fontSize: 34,
                  letterSpacing: -1,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 28),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: const Row(
                  children: [
                    CircleAvatar(
                      radius: 25,
                      backgroundColor: Color(0xFFE8EFFD),
                      child: Text(
                        'SR',
                        style: TextStyle(
                          color: Color(0xFF2369F5),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Sahrul Ramadhani',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            '244107020058 · TI-3C',
                            style: TextStyle(
                              color: Color(0xFF8B93A3),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              const Text(
                'NOTIFIKASI',
                style: TextStyle(
                  color: Color(0xFF8B93A3),
                  letterSpacing: 1.5,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 10),
              Card(
                elevation: 0,
                margin: EdgeInsets.zero,
                color: Colors.white,
                child: Column(
                  children: [
                    SwitchListTile.adaptive(
                      title: const Text(
                        'Pengumuman kampus',
                        style: TextStyle(fontSize: 15),
                      ),
                      subtitle: const Text(
                        'Terima kabar untuk seluruh mahasiswa',
                        style: TextStyle(fontSize: 11),
                      ),
                      value: push.topicSubscribed,
                      onChanged: (value) async {
                        try {
                          await push.setTopic(value);
                        } catch (_) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Belum dapat mengubah langganan. Coba lagi.',
                                ),
                              ),
                            );
                          }
                        }
                      },
                    ),
                    const Divider(height: 1, indent: 16),
                    ListTile(
                      leading: const Icon(CupertinoIcons.bell),
                      title: Text(
                        push.status,
                        style: const TextStyle(fontSize: 14),
                      ),
                      subtitle: Text(
                        push.permissionGranted
                            ? 'Banner, suara, dan ikon notifikasi'
                            : 'Periksa izin notifikasi aplikasi',
                        style: const TextStyle(fontSize: 11),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              ExpansionTile(
                tilePadding: EdgeInsets.zero,
                title: const Text(
                  'Detail pengujian',
                  style: TextStyle(fontSize: 14, color: Color(0xFF7B8496)),
                ),
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text(
                      'Token perangkat (dipotong)',
                      style: TextStyle(fontSize: 12),
                    ),
                    subtitle: Text(
                      push.tokenPreview,
                      key: const Key('masked-token'),
                    ),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text(
                      'Registrasi token ke API',
                      style: TextStyle(fontSize: 12),
                    ),
                    subtitle: Text(
                      '${push.tokenUpdates} versi token terdaftar',
                    ),
                  ),
                  if (kDebugMode)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text(
                        'Uji rotasi token',
                        style: TextStyle(fontSize: 12),
                      ),
                      subtitle: Text(
                        '${push.tokenRefreshEvents} event onTokenRefresh diterima',
                      ),
                      trailing: IconButton(
                        tooltip: 'Perbarui token uji',
                        icon: const Icon(CupertinoIcons.arrow_clockwise),
                        onPressed: busy
                            ? null
                            : () async {
                                setState(() => busy = true);
                                try {
                                  await push.rotateRegistrationForTest();
                                } catch (_) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Rotasi belum berhasil. Periksa koneksi.',
                                        ),
                                      ),
                                    );
                                  }
                                } finally {
                                  if (mounted) setState(() => busy = false);
                                }
                              },
                      ),
                    ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text(
                      'Suara perangkat',
                      style: TextStyle(fontSize: 12),
                    ),
                    subtitle: Text(push.soundInfo),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text(
                      'Badge ikon Home',
                      style: TextStyle(fontSize: 12),
                    ),
                    subtitle: Text(
                      push.badgeSupported
                          ? 'Didukung launcher perangkat'
                          : 'Gunakan indikator lonceng di aplikasi',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              OutlinedButton(
                onPressed: busy ? null : logout,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  foregroundColor: const Color(0xFFDC575F),
                  side: const BorderSide(color: Color(0xFFEBDDE0)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: busy
                    ? const CupertinoActivityIndicator()
                    : const Text('Keluar akun'),
              ),
              const SizedBox(height: 30),
              const Center(
                child: Text(
                  'Campus 1.0\nPemrograman Mobile · Polinema',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFFA0A6B2),
                    height: 1.8,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
