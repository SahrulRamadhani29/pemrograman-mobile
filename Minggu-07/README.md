# Minggu 07 Campus Notify dengan SOLID dan layer first

Sahrul Ramadhani · TI 3C

Minggu-07 merupakan salinan Minggu-06 yang direfactor menjadi tiga layer. Login API, refresh token, notifikasi FCM, daftar belum dibaca, status baca, badge, topik, dan suara tetap memakai alur yang sama.

## Struktur

```text
lib/
├── data/
│   ├── api/
│   ├── models/
│   ├── repositories/
│   ├── services/
│   ├── storage/
│   └── bootstrap.dart
├── domain/
│   ├── entities/
│   ├── failures/
│   ├── repositories/
│   ├── storage/
│   └── usecases/
├── presentation/
│   ├── pages/
│   ├── providers/
│   ├── routing/
│   ├── formatters/
│   └── app.dart
└── main.dart
```

Domain berisi Dart murni. Data mengimplementasikan kontrak domain. Presentation memakai kontrak dan use case domain. Pembuatan implementasi data dipusatkan di presentation/providers/dependencies.dart sebagai composition root; main.dart hanya melakukan bootstrap dan menjalankan aplikasi.

## Menjalankan

PowerShell dari folder Minggu-07:

```powershell
.\run-vivo.ps1
```

Script menyalakan Laravel pada port 8007, HTTPS pada 8447, memasang adb reverse, lalu menjalankan Flutter pada Vivo. Login lokal tersedia di login-lokal.txt yang diabaikan Git. Email menerima variasi huruf besar/kecil.

Untuk menjalankan server secara terpisah:

```powershell
# Terminal 1
cd "D:\Pemrograman Mobile\Minggu-07\backend"
& "C:\laragon\bin\php\php-8.5.5-Win32-vs17-x64\php.exe" artisan serve --host=127.0.0.1 --port=8007

# Terminal 2
cd "D:\Pemrograman Mobile\Minggu-07"
python scripts\https_proxy.py

# Terminal 3
adb -s 33a40574 reverse tcp:8447 tcp:8447
cd "D:\Pemrograman Mobile\Minggu-07"
flutter run -d 33a40574
```

Port berbeda dari Minggu-06 agar kedua backend memakai database masing-masing. Campus 07 memakai package id.ac.polinema.sahrul.campus_notify.week07 dan aplikasi Android tersendiri di proyek Firebase yang sama. Campus 06 tetap memakai package id.ac.polinema.sahrul.campus_notify. Keduanya dapat dipasang bersamaan, dengan token FCM dan penyimpanan aplikasi yang terpisah.

Untuk menyalakan server kedua minggu sekaligus, buka PowerShell di folder D:\Pemrograman Mobile dan jalankan .\jalankan-server-06-07.ps1. Setelah itu buka ikon Campus 06 atau Campus 07 pada Vivo. Script ini menyiapkan koneksi server dan USB tanpa membangun ulang APK.

Di laptop ini cache build lokal diarahkan ke drive C melalui junction pada folder build karena ruang drive D terbatas. Cache bukan bagian source code dan tidak masuk Git.

## Penerapan SOLID

| Prinsip | Penerapan |
|---|---|
| Single Responsibility | Entity menyimpan data bisnis; model memetakan JSON; adapter mengakses API/penyimpanan; halaman menampilkan state. |
| Open Closed | Implementasi repository dapat diganti melalui provider tanpa mengubah halaman. |
| Liskov Substitution | Repository palsu mengimplementasikan kontrak yang sama untuk menguji alur sukses dan Failure. |
| Interface Segregation | Kontrak auth, inbox, perangkat, notifikasi, sesi, dan identitas instalasi dipisahkan. |
| Dependency Inversion | Use case dan state bergantung pada kontrak domain; adapter nyata disuntikkan oleh Riverpod. |

Use case Login menggabungkan autentikasi dan penyimpanan sesi. Logout melepas notifikasi lalu membersihkan sesi. OpenAnnouncement memuat detail dan menyimpan status baca. Pembacaan inbox sederhana tetap langsung melalui kontrak repository.

## Pengujian

- flutter analyze: bersih.
- flutter test: 24 tes lulus.
- Backend: 14 tes lulus, 68 assertions.
- Pemeriksaan import domain, presentation, dan data: nol pelanggaran, dengan pengecualian wiring DI yang dijelaskan di atas.
- Hasil uji perangkat dan bukti sebelum/sesudah: [docs/validasi.md](docs/validasi.md).
- Vivo Android 11: login dengan email campuran huruf besar/kecil, FCM foreground/background/mulai ulang, detail pesan, status baca, dan badge berhasil. Pengguna mengonfirmasi suara terdengar.

## Dokumen

- [Pemetaan arsitektur dan keputusan](docs/arsitektur.md)
- [Panduan penggunaan](docs/panduan-penggunaan.md)
- [Kontrak API](docs/api.md)
- [AI Challenge](docs/ai-challenge.md)
- [Laporan perbandingan repository konkret dan SOLID](<docs/Laporan Perbandingan Arsitektur Repository dan SOLID.docx>)

Dokumen bukti dari proyek asal berada di docs/referensi-minggu-06. Source code Minggu-06 tetap berada pada foldernya sendiri.
