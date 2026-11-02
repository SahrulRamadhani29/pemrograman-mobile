import '../formatters/display_date.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/failures/app_failure.dart';
import '../providers/app_providers.dart';
import '../routing/app_routes.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});
  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) refresh();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) refresh();
  }

  Future<void> refresh() async {
    try {
      final push = ref.read(pushServiceProvider);
      await push.activate();
      await push.syncInbox();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(failureMessage(error))));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final inbox = ref.watch(inboxProvider);
    final push = ref.watch(pushServiceProvider);
    final count = inbox.value?.length ?? push.unreadCount;
    return Scaffold(
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        backgroundColor: Colors.white,
        onDestinationSelected: (index) {
          if (index == 1) context.go(AppRoutes.settings);
        },
        destinations: [
          NavigationDestination(
            icon: Badge(
              isLabelVisible: count > 0,
              label: Text('$count'),
              child: const Icon(CupertinoIcons.tray),
            ),
            selectedIcon: Badge(
              isLabelVisible: count > 0,
              label: Text('$count'),
              child: const Icon(CupertinoIcons.tray_fill),
            ),
            label: 'Kotak Masuk',
          ),
          const NavigationDestination(
            icon: Icon(CupertinoIcons.slider_horizontal_3),
            label: 'Pengaturan',
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: refresh,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'CAMPUS',
                              style: TextStyle(
                                color: Color(0xFF2369F5),
                                letterSpacing: 2.4,
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          Semantics(
                            label: '$count notifikasi belum dibaca',
                            child: Badge(
                              isLabelVisible: count > 0,
                              label: Text('$count'),
                              child: const Padding(
                                padding: EdgeInsets.all(8),
                                child: Icon(CupertinoIcons.bell, size: 26),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),
                      const Text(
                        'Kotak Masuk',
                        style: TextStyle(
                          fontSize: 34,
                          letterSpacing: -1.1,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF171B27),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        count > 0
                            ? 'Ada $count kabar baru untukmu.'
                            : 'Semua kabar penting, di satu tempat.',
                        style: const TextStyle(
                          color: Color(0xFF7A8091),
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 26),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8EFFD),
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              CupertinoIcons.sparkles,
                              color: Color(0xFF2369F5),
                              size: 25,
                            ),
                            const SizedBox(width: 14),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Tetap terhubung.',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Buka pengumuman untuk membacanya.\nPesan terbaca akan hilang dari daftar.',
                                    style: TextStyle(
                                      color: Color(0xFF6C7893),
                                      fontSize: 12,
                                      height: 1.5,
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
                        'BELUM DIBACA',
                        style: TextStyle(
                          fontSize: 11,
                          letterSpacing: 1.5,
                          color: Color(0xFF8C92A0),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              ...inbox.when(
                loading: () => [
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(60),
                      child: CupertinoActivityIndicator(),
                    ),
                  ),
                ],
                error: (error, _) => [
                  SliverToBoxAdapter(
                    child: _EmptyState(
                      icon: CupertinoIcons.wifi_exclamationmark,
                      title: 'Belum terhubung',
                      subtitle: failureMessage(error),
                      action: TextButton(
                        onPressed: refresh,
                        child: const Text('Coba lagi'),
                      ),
                    ),
                  ),
                ],
                data: (items) => items.isEmpty
                    ? [
                        const SliverToBoxAdapter(
                          child: _EmptyState(
                            icon: CupertinoIcons.check_mark_circled,
                            title: 'Sudah beres.',
                            subtitle: 'Tidak ada pengumuman yang belum dibaca.',
                          ),
                        ),
                      ]
                    : [
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          sliver: SliverList.builder(
                            itemCount: items.length,
                            itemBuilder: (context, index) {
                              final item = items[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Material(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(20),
                                    onTap: () =>
                                        context.push(AppRoutes.detail(item.id)),
                                    child: Padding(
                                      padding: const EdgeInsets.all(18),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFF0F4FE),
                                              borderRadius:
                                                  BorderRadius.circular(14),
                                            ),
                                            child: const Icon(
                                              CupertinoIcons.bell_fill,
                                              color: Color(0xFF2369F5),
                                              size: 20,
                                            ),
                                          ),
                                          const SizedBox(width: 14),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        displayDate(
                                                          item.createdAt,
                                                        ),
                                                        style: const TextStyle(
                                                          fontSize: 11,
                                                          color: Color(
                                                            0xFF969CAB,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    Container(
                                                      width: 7,
                                                      height: 7,
                                                      decoration:
                                                          const BoxDecoration(
                                                            shape:
                                                                BoxShape.circle,
                                                            color: Color(
                                                              0xFF2369F5,
                                                            ),
                                                          ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 7),
                                                Text(
                                                  item.title,
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    height: 1.3,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                const SizedBox(height: 6),
                                                Text(
                                                  item.body,
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                    fontSize: 13,
                                                    color: Color(0xFF858B9A),
                                                    height: 1.5,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const Padding(
                                            padding: EdgeInsets.only(
                                              top: 28,
                                              left: 8,
                                            ),
                                            child: Icon(
                                              CupertinoIcons.chevron_right,
                                              color: Color(0xFFB1B6C2),
                                              size: 15,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 30)),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.action,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? action;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
    child: Column(
      children: [
        Icon(icon, size: 50, color: const Color(0xFF96ABC9)),
        const SizedBox(height: 18),
        Text(
          title,
          style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Color(0xFF858B9A), height: 1.6),
        ),
        ?action,
      ],
    ),
  );
}
