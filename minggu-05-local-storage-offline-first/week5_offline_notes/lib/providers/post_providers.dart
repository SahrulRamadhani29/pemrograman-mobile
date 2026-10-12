import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/remote/post.dart';
import '../data/repositories/post_repository.dart';
import 'offline_providers.dart';

final postRepositoryProvider = Provider<PostRepository>(
  (ref) => PostRepository(),
);

final postsProvider = AsyncNotifierProvider<PostsNotifier, List<Post>>(
  PostsNotifier.new,
);

class PostsNotifier extends AsyncNotifier<List<Post>> {
  @override
  Future<List<Post>> build() async {
    final repo = ref.watch(postRepositoryProvider);
    final cached = await repo.readCachedPosts();
    if (ref.watch(forceOfflineProvider)) return cached;
    if (cached.isEmpty) return repo.fetchAndCache();
    unawaited(_refreshInBackground(repo));
    return cached;
  }

  Future<void> _refreshInBackground(PostRepository repo) async {
    try {
      final fresh = await repo.fetchAndCache();
      state = AsyncData(fresh);
    } catch (_) {
      // Cache tetap ditampilkan ketika refresh jaringan gagal.
    }
  }

  Future<bool> refresh() async {
    if (ref.read(forceOfflineProvider)) return false;
    try {
      final fresh = await ref.read(postRepositoryProvider).fetchAndCache();
      state = AsyncData(fresh);
      return true;
    } catch (_) {
      return false;
    }
  }
}
