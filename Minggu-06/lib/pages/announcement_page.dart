import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/api_errors.dart';
import '../data/inbox_repository.dart';
import '../messaging/push_service.dart';
import '../providers/auth_provider.dart';
import '../routes.dart';

class AnnouncementPage extends ConsumerStatefulWidget {
  const AnnouncementPage({super.key, required this.id});
  final int id;
  @override
  ConsumerState<AnnouncementPage> createState() => _AnnouncementPageState();
}

class _AnnouncementPageState extends ConsumerState<AnnouncementPage> {
  late Future<Announcement> item;
  @override
  void initState() {
    super.initState();
    item = load();
  }

  Future<Announcement> load() async {
    final result = await ref.read(inboxRepositoryProvider).detail(widget.id);
    if (mounted) await ref.read(pushServiceProvider).markRead(widget.id);
    return result;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text(
        'Pengumuman',
        style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
      ),
      leading: IconButton(
        tooltip: 'Kembali ke Kotak Masuk',
        icon: const Icon(CupertinoIcons.chevron_left),
        onPressed: () => context.go(AppRoutes.home),
      ),
    ),
    body: FutureBuilder<Announcement>(
      future: item,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CupertinoActivityIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    friendlyApiError(snapshot.error!),
                    textAlign: TextAlign.center,
                  ),
                  TextButton(
                    onPressed: () => setState(() => item = load()),
                    child: const Text('Coba lagi'),
                  ),
                ],
              ),
            ),
          );
        }
        final value = snapshot.data!;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8EFFD),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  CupertinoIcons.bell_fill,
                  color: Color(0xFF2369F5),
                  size: 28,
                ),
              ),
              const SizedBox(height: 28),
              Text(
                'PENGUMUMAN #${value.id}',
                style: const TextStyle(
                  fontSize: 11,
                  letterSpacing: 1.6,
                  color: Color(0xFF818A9F),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                value.title,
                style: const TextStyle(
                  fontSize: 30,
                  height: 1.2,
                  letterSpacing: -0.8,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                '${value.createdAt.day}/${value.createdAt.month}/${value.createdAt.year} · Kampus Polinema',
                style: const TextStyle(color: Color(0xFF9299A8), fontSize: 13),
              ),
              const SizedBox(height: 28),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Text(
                  value.body,
                  style: const TextStyle(
                    fontSize: 17,
                    height: 1.8,
                    color: Color(0xFF515A6D),
                  ),
                ),
              ),
              const SizedBox(height: 22),
              const Row(
                children: [
                  Icon(
                    CupertinoIcons.check_mark_circled_solid,
                    color: Color(0xFF3BA479),
                    size: 16,
                  ),
                  SizedBox(width: 7),
                  Text(
                    'Sudah dibaca',
                    style: TextStyle(color: Color(0xFF7D8797), fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    ),
  );
}
