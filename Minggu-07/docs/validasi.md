# Validasi Minggu 07

## Pemeriksaan otomatis

- flutter analyze: tidak ada issue.
- flutter test: 24 tes lulus.
- php artisan test: 14 tes lulus dengan 68 assertions.
- Tes domain memakai repository palsu dan tidak memanggil database, Firebase, atau secure storage nyata.
- Tiga tes arsitektur memeriksa domain murni, batas presentation, dan larangan data mengimpor presentation.
- flutter build apk --debug: berhasil. APK telah dipasang ke Vivo dengan adb install -r.
- dart format --output=none --set-exit-if-changed lib test: 50 file, tidak ada perubahan.
- SHA256 untuk 233 file proyek asal diperiksa kembali: 232 file tidak berubah. Satu perubahan yang disengaja pada manifest Android hanya mengganti label Campus menjadi Campus 06 agar mudah dibedakan. Struktur dan logika aplikasi Minggu-06 tetap.
- Endpoint HTTPS /api/health pada port 8447 merespons HTTP 200 dengan verifikasi sertifikat aktif.

## Pemeriksaan import

```powershell
rg -n "package:(flutter|dio|firebase|sqflite|shared_preferences|flutter_secure_storage|flutter_riverpod)" lib/domain
rg -n "import .*data/|package:(dio|firebase|sqflite|flutter_secure_storage|shared_preferences)" lib/presentation -g '!dependencies.dart'
rg -n "presentation/" lib/data
```

Ketiga pencarian tidak menghasilkan temuan. dependencies.dart dikecualikan karena menjadi composition root yang memasangkan kontrak dengan implementasi data.

## Bukti asal

37-before-architecture.png adalah salinan screenshot UI Minggu-06 setelah perbaikan inbox. Bukti dan pengujian proyek asal berada di referensi-minggu-06/. Screenshot dengan nomor 38 sampai 49 berasal dari pemeriksaan Minggu-07 di Vivo.

## Pemeriksaan Vivo pada 2 November 2026

Perangkat: Vivo 1918, Android 11. Backend memakai database Minggu-07, Laravel port 8007, HTTPS port 8447, dan adb reverse. Pengujian awal dilakukan sebelum package dipisah. Versi akhir Campus 07 memakai package id.ac.polinema.sahrul.campus_notify.week07, sedangkan Campus 06 tetap memakai package asal. Hasil pemeriksaan setelah pemisahan dicatat pada bagian Dua aplikasi di bawah.

| Pemeriksaan | Hasil | Bukti |
|---|---|---|
| Membuka APK | Kotak Masuk tampil setelah build dan pemasangan ulang. Pembukaan biasa dari MainActivity juga berhasil. | 38-week07-home.png |
| Logout dan login API | Logout kembali ke form login. Login dengan RaMa@PoLiNeMa.Ac.Id berhasil. | Tampilan Kotak Masuk dan sesi API setelah login |
| Langganan topik | Pengumuman kampus dimatikan lalu diaktifkan kembali. | Pengaturan kembali menampilkan Notifikasi aktif |
| Token | Registrasi perangkat ke API berhasil; UI hanya menampilkan awalan token. | 39-week07-settings.png |
| FCM foreground | Pesan ID 12 muncul saat aplikasi terbuka; notification channel pengumuman memakai importance HIGH, suara default, dan showBadge=true. | 40-week07-fcm-foreground.png dan evidence-40-week07-fcm-foreground.txt |
| Inbox tanpa mengetuk banner | Pesan ID 12 tetap ada sebagai belum dibaca, bersama badge 2. | 41-week07-unread.png |
| Ikon launcher Vivo | Ikon Campus menampilkan angka 2. | 42-week07-launcher-badge.png |
| FCM background | Setelah Home ditekan, pesan masuk dari FCM. Ketukan notifikasi membuka detail ID 12. | 43-week07-fcm-background.png dan 44-week07-detail.png |
| Status baca | Detail menampilkan Sudah dibaca. read_at ID 12 tersimpan di tabel inbox API. Pesan hilang dari daftar dan badge turun dari 2 ke 1. | 45-week07-after-read.png |
| Proses aplikasi tidak aktif | Aplikasi dipindahkan ke background lalu dihentikan dengan am kill; pidof kosong sebelum pengiriman. FCM ID 13 tetap diterima, dan ketukan membuka detail saat aplikasi mulai kembali. read_at ID 13 tersimpan. | 46-week07-fcm-terminated.png dan 47-week07-cold-start.png |
| Suara | Mode Vivo NORMAL, Jangan Ganggu mati, channel mempunyai notification_sound. Pesan ID 14 dikirim ulang; pengguna menjawab Ya, terdengar. | 48-week07-final-notification.png, evidence-48-week07-final-notification.txt, dan konfirmasi pengguna |
| Keadaan akhir | Aplikasi berada di Kotak Masuk. Pesan demo ID 14 masih belum dibaca; total badge 2 termasuk pesan lama dari salinan database. | 49-week07-final-home.png |

Pengujian proses tidak aktif memakai am kill, bukan force-stop. Android memang membatasi penerimaan FCM jika aplikasi di-force-stop dari pengaturan.

## Catatan startup

Pemasangan APK pertama sempat menampilkan layar hitam. APK dibangun dan dipasang ulang, kemudian startup TLS, Firebase, dan handler background berhasil. Setelah itu pembukaan biasa, logout/login, serta pembukaan dari notifikasi setelah proses mati berhasil diuji. Log startup debug hanya berisi nama tahap, tanpa token atau kata sandi.

## Laporan

[Laporan perbandingan repository konkret dan SOLID](<Laporan Perbandingan Arsitektur Repository dan SOLID.docx>) terdiri dari empat halaman. Pembandingnya disebut berdasarkan pendekatan arsitektur, yaitu repository konkret dan SOLID dengan struktur layer-first. Isinya membandingkan kondisi awal, layer-first, arah dependensi, alur login, entity dan JSON, notifikasi, serta lima prinsip SOLID. Semua teks Times New Roman dan hitam. Judul berukuran 16 pt, subjudul dan judul bagian 14 pt, sedangkan isi 12 pt. Cetak tebal hanya dipakai pada judul dan subjudul. Setiap halaman dirender dengan Microsoft Word dan diperiksa sebagai PNG.

## Dua aplikasi pada Vivo

| Hal | Campus 06 | Campus 07 |
|---|---|---|
| Package | id.ac.polinema.sahrul.campus_notify | id.ac.polinema.sahrul.campus_notify.week07 |
| Arsitektur | Struktur Minggu-06 semula | SOLID dan layer-first |
| Laravel dan HTTPS | 8006 dan 8446 | 8007 dan 8447 |
| Firebase | Aplikasi Android asal | Aplikasi Android baru pada proyek Firebase yang sama |
| Login | Berhasil ke API Minggu-06 | Berhasil ke API Minggu-07 |
| Pesan uji | Campus 06 tetap aktif, ID 12 | Campus 07 terpisah, ID 15 |

Kedua package tercantum bersamaan dalam hasil adb shell pm list packages campus_notify. Ikon launcher juga menampilkan Campus 06 dan Campus 07. 52-campus06-dan07.png merupakan komposit dua potongan screenshot asli ikon tersebut.

- Campus 06 dipasang ulang dari source Minggu-06; hanya label Android berubah menjadi Campus 06. Bukti: [login](../../Minggu-06/screenshots/50-campus06-restored.png), [detail](../../Minggu-06/screenshots/59-campus06-restored-detail.png), dan [daftar setelah membaca](../../Minggu-06/screenshots/60-campus06-after-read.png).
- Campus 07 dibangun dengan package baru, MainActivity yang sesuai, dan google-services.json hasil unduhan Firebase setelah pendaftaran aplikasi baru. Bukti form login terpisah dan inbox: 51-campus07-login-separate.png serta 53-campus07-separate-home.png.
- Token FCM kedua aplikasi berbeda. Registrasi perangkat lama milik Campus 06 di database salinan Minggu-07 dihapus setelah database dicadangkan, sehingga daftar perangkat tiap server sesuai aplikasinya. Cache inbox pada package asal disegarkan setelah dicadangkan; sesi secure storage dan data inbox API tetap dipertahankan.
- Pengiriman memakai Send test message ke satu token aplikasi pada setiap uji. Campus 07 menerima pesan foreground dengan package .week07, lalu menerima pesan setelah Home dan am kill. Ketukan membuka pengumuman ID 15. read_at tersimpan dan jumlah badge turun dari 3 menjadi 2. Bukti: 54-campus07-new-package-fcm.png, 55-campus07-cold-notification.png, 56-campus07-new-detail.png, dan 57-campus07-after-read.png.
- Campus 06 menerima pesan background pada package asal, membuka pengumuman ID 12, dan menyimpan read_at pada database Minggu-06. Setelah dibaca, daftar kembali berisi satu pesan lama. Bukti notifikasi: 58-campus06-notification.png.
- Kedua endpoint HTTPS /api/health merespons HTTP 200 dengan validasi sertifikat aktif. Script jalankan-server-06-07.ps1 telah dijalankan dan menyiapkan kedua adb reverse. Saat USB tersambung ulang, jalankan kembali script tersebut karena ADB menghapus reverse saat koneksi putus.

Nama screenshot pada daftar di atas berada pada Minggu-07/screenshots kecuali yang secara eksplisit disebut berada pada Minggu-06.
