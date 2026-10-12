# AI Prompt Challenge

## Prompt

> Aplikasi Flutter Offline Notes: CRUD catatan dan preferensi tema. Bandingkan SharedPreferences, Hive, sqflite (SQLite), dan Drift untuk dua kebutuhan ini. Bandingkan kompleksitas query, relasi, reaktivitas stream, type-safety, boilerplate, dan testing. Berikan rekomendasi final untuk preferensi dan catatan dalam satu tabel. Tunjukkan skema tabel untuk 1000+ catatan dan jelaskan trade-off.

## Ringkasan hasil awal

Rekomendasi awal mengarah pada SharedPreferences untuk preferensi sederhana dan SQLite atau Drift untuk catatan. AI juga menyarankan dirty flag, `updated_at`, repository, serta fake repository untuk testing.

## Verifikasi dan perbaikan

- Daftar catatan tidak diletakkan di SharedPreferences karena format key-value tidak cocok untuk koleksi besar dan query.
- Skema catatan memiliki `dirty` dan `updated_at`, sehingga mendukung antrean sinkronisasi dasar.
- Klaim reaktif hanya dianggap valid jika storage menyediakan stream. sqflite pada project ini memakai invalidasi provider setelah mutasi.
- Rekomendasi disesuaikan dengan jobsheet: SharedPreferences + sqflite.

## Hasil testing

`flutter analyze` dan `flutter test` dijalankan. Test mencakup mapping model yang aman, serialisasi dirty, provider sukses/error dengan fake repository, sync offline, sync berhasil, dan aturan konflik.
