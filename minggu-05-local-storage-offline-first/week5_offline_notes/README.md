# Week 5 - Local Storage & Offline First

Project ini adalah aplikasi **Offline Notes** untuk praktikum Pemrograman Mobile Minggu 5. Aplikasi dapat menyimpan catatan di perangkat, tetap digunakan tanpa internet, dan menyinkronkan catatan yang berubah saat koneksi tersedia.

## Fitur

- Tema gelap/terang dan waktu terakhir dibuka dengan SharedPreferences.
- CRUD catatan persisten dengan SQLite melalui `NoteRepository`.
- Riverpod untuk provider, empat state UI, dan pemisahan aksi data.
- Badge `dirty` untuk catatan yang belum tersinkron.
- Sinkronisasi simulasi dengan penolakan saat mode offline aktif.
- Cache-first posts dari JSONPlaceholder menggunakan Dio dan SQLite.
- Detail catatan dengan GoRouter.
- Unit test model, provider palsu, sync, dan aturan konflik.

## Teknologi

Flutter, Dart, flutter_riverpod, shared_preferences, sqflite, path, dio, dan go_router.

## Menjalankan

```powershell
flutter pub get
flutter run -d 33a40574
```

Project harus dijalankan di emulator Android atau perangkat fisik. `sqflite` tidak didukung untuk Chrome/Web.

## Pengujian

```powershell
flutter analyze
flutter test
```

## Skenario Offline-First

1. Buka menu Posts saat online agar 100 posts tersimpan ke cache.
2. Aktifkan `Paksa mode offline` di Pengaturan.
3. Buka Posts lagi. Data dibaca dari cache lokal.
4. Tambah atau ubah catatan. Badge menunjukkan jumlah catatan dirty.
5. Tekan sinkron saat offline. Aplikasi menolak sync dan badge tetap ada.
6. Matikan mode offline lalu tekan sinkron. Badge berkurang atau hilang setelah proses berhasil.

## Aturan Konflik

Project memakai aturan last-write-wins. Versi dengan `updatedAt` paling baru dipilih. Pada aplikasi nyata, pengiriman ditandai bersih hanya untuk id dan timestamp yang benar-benar berhasil dikirim; cara ini mencegah perubahan baru ikut tertandai bersih saat proses sync lama masih berjalan.

## Struktur

Provider berada di `lib/providers`, UI berada di `lib/pages` dan `lib/widgets`, sedangkan akses storage berada di `lib/data`. Halaman tidak mengakses SQLite atau SharedPreferences langsung.

## Hasil

Hasil screenshot praktikum disimpan di `screenshots/`. Dokumentasi AI dan hasil verifikasi disimpan di `docs/`.
