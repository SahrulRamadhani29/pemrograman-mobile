# Cuplikan output awal AI

Berikut bagian draf pertama sebelum pengujian launcher Vivo. Ini disimpan agar perubahan setelah pengujian dapat dibandingkan.

```dart
badgeSupported = await AppBadgePlus.isSupported();

_subscriptions.add(FirebaseMessaging.instance.onTokenRefresh.listen((token) {
  unawaited(_register(token).catchError((Object _) {
    status = 'Token baru menunggu koneksi API';
    notifyListeners();
  }));
}));
```

Bagian pembaruan badge awal:

```dart
Future<void> updateBadge(int count) async {
  unreadCount = count;
  if (badgeSupported) {
    try {
      await AppBadgePlus.updateBadge(count);
    } catch (_) {
      /* Ikon lonceng tetap tersedia. */
    }
  }
  notifyListeners();
}
```

Bagian pembacaan awal:

```dart
Future<void> markRead(int id) async {
  await inbox.markRead(id);
  await local.cancel(id: id, tag: 'announcement-$id');
  await syncInbox();
}
```

Pengujian menunjukkan badge lonceng sudah bekerja, tetapi plugin tidak mengenali com.bbk.launcher2. Versi akhir menambahkan plugin lokal untuk launcher Vivo lama, memperbarui badge dari background handler, dan membersihkan notifikasi aplikasi ketika tidak ada pesan belum dibaca.

Token lifecycle juga diberi penghitung event agar bukti onTokenRefresh dapat dicocokkan dengan token_updates pada backend. Token lengkap tetap tidak ditampilkan.
