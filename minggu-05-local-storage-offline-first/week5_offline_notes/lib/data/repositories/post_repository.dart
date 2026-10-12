import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:sqflite/sqflite.dart';

import '../local/db.dart';
import '../remote/post.dart';

class PostRepository {
  PostRepository({Dio? dio, Future<Database> Function()? openDb})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: 'https://jsonplaceholder.typicode.com',
              connectTimeout: const Duration(seconds: 5),
              receiveTimeout: const Duration(seconds: 5),
            ),
          ),
      _openDb = openDb ?? openNotesDb;

  final Dio _dio;
  final Future<Database> Function() _openDb;

  Future<List<Post>> readCachedPosts() async {
    final db = await _openDb();
    final rows = await db.query('cached_posts', orderBy: 'id ASC');
    return rows.map((row) {
      final payload = row['payload'] as String?;
      if (payload == null) return Post.fromMap(row);
      return Post.fromJson(jsonDecode(payload) as Map<String, dynamic>);
    }).toList();
  }

  Future<List<Post>> fetchAndCache() async {
    final response = await _dio.get<List<dynamic>>('/posts');
    final posts = (response.data ?? [])
        .whereType<Map<String, dynamic>>()
        .map(Post.fromJson)
        .toList();
    final db = await _openDb();
    await db.transaction((txn) async {
      final batch = txn.batch();
      batch.delete('cached_posts');
      final now = DateTime.now().toIso8601String();
      for (final post in posts) {
        batch.insert('cached_posts', {
          'id': post.id,
          'payload': jsonEncode(post.toJson()),
          'cached_at': now,
        });
      }
      await batch.commit(noResult: true);
    });
    return posts;
  }
}
