# AI Challenge

## Prompt

Buat Campus Notification App sesuai jobsheet Minggu 6. Gunakan Firebase Messaging, local notifications, secure storage, GoRouter, Riverpod, dan Dio. Tambahan dosen: login API sungguhan, inbox yang hilang setelah dibaca, indikator ikon, dan suara. UI minimalis bergaya iOS. Validasi di Vivo 1918.

PushService harus meminta izin, mengambil token, menangani onTokenRefresh dengan POST /devices, menampilkan banner foreground, menangani klik background/terminated, dan subscribe/unsubscribe pengumuman-kampus. Background handler harus top-level dengan pragma vm:entry-point.

## Output awal AI

Draf menghasilkan lapisan TokenStore, AuthRepository, ApiClient, provider autentikasi, PushService, halaman login, inbox, detail, dan pengaturan. Backend menyediakan autentikasi, registrasi perangkat, inbox, dan status baca.

Potongan arsitektur awal:

```text
login -> AuthRepository -> POST /login -> TokenStore
request -> Dio -> 401 -> refresh -> retry sekali
FCM -> handler -> inbox server -> banner -> detail -> read_at
```

## Pemeriksaan dan perbaikan

1. Contoh interceptor jobsheet belum memiliki penanda retry. Implementasi memakai extra.retried agar respons 401 kedua berhenti.
2. Request yang bersamaan berbagi satu Future refresh agar refresh token berotasi tidak dipakai dua kali.
3. Token baru disimpan dari respons server, termasuk refresh token pengganti.
4. Rute dari payload dibatasi ke halaman pengumuman yang valid. URL eksternal ditolak.
5. Klik banner lokal dihubungkan ke router; bukan hanya disimpan dalam variabel.
6. Background handler tidak memakai BuildContext atau container Riverpod. Pesan ditaruh dalam antrean lokal milik pengguna, lalu dikirim ke API saat sesi siap.
7. Notifikasi notification+data tidak ditampilkan ulang di background sehingga menghindari banner ganda.
8. Plugin badge lama yang discontinued diganti app_badge_plus. Firebase Messaging 16 dipilih untuk API getToken/onTokenRefresh yang digunakan jobsheet.
9. HTTPS lokal memakai sertifikat yang diverifikasi pada build debug. Tidak ada badCertificateCallback yang menerima semua sertifikat.
10. Status baca disimpan di database. Pesan duplikat tidak menghapus read_at atau memunculkan ulang notifikasi lama pada inbox.
11. Launcher Vivo lama dan pengaturan badge perangkat diperiksa melalui uji nyata. Screenshot dipakai sebagai bukti, karena label accessibility dapat menyimpan angka lama.
12. Referensi provider untuk logout diambil sebelum operasi asynchronous. Pengujian tambahan menemukan CircularDependencyError karena auth menginvalidasi inbox yang bergantung pada auth. Invalidasi manual dihapus; ref.watch pada inbox sudah otomatis mengikuti perubahan status autentikasi. Tes regresi mereproduksi galat sebelum perbaikan.
13. Pengujian pengguna menemukan inbox tetap kosong meskipun API memiliki pesan belum dibaca. Event kosong lama di antrean lokal ditolak 422 dan menghentikan seluruh sinkronisasi. Sinkronisasi kini mengisolasi kegagalan per pesan dan tetap memuat inbox; event kosong lama dibersihkan, event baru tanpa isi diabaikan, dan API menerima notifikasi dengan judul saja. Tes mencakup antrean gagal, pesan berikutnya, pemuatan inbox, serta kegagalan API yang harus tetap ditampilkan sebagai error.

## Platform

Android 13 ke atas perlu izin POST_NOTIFICATIONS saat runtime. Android 8 ke atas memakai channel pengumuman dengan sound dan badge. iOS memerlukan APNs dan konfigurasi Xcode untuk uji perangkat iOS; pengujian tugas ini memakai Android Vivo.

Background isolate tidak boleh mengakses BuildContext, navigator, atau state UI. Navigasi dilakukan di isolate utama setelah pengguna menekan notifikasi.

## Hasil

Hasil tes Flutter, backend, tiga kondisi aplikasi, dan bukti perangkat dicatat pada validasi.md. Keberhasilan build tidak dianggap sebagai bukti bahwa push sudah diterima.
