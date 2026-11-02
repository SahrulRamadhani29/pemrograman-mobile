# Panduan Campus Notify Minggu 07

1. Hubungkan Vivo melalui USB dan izinkan USB debugging. adb devices harus menampilkan status device.
2. Buka PowerShell di D:\Pemrograman Mobile\Minggu-07 dan jalankan .\run-vivo.ps1.
3. Masuk memakai akun di login-lokal.txt. Email bebas huruf besar/kecil.
4. Buka Kotak Masuk untuk melihat pesan belum dibaca. Tarik layar ke bawah untuk menyegarkan daftar.
5. Ketuk pesan atau banner untuk membaca detail. Setelah status baca tersimpan, pesan hilang dari daftar dan badge berkurang.
6. Pengaturan menyediakan langganan topik pengumuman-kampus, diagnostik token/suara, dan logout.

## Mengirim pengumuman

Di terminal backend, buat data dengan perintah berikut menggunakan PHP 8.5:

```powershell
& "C:\laragon\bin\php\php-8.5.5-Win32-vs17-x64\php.exe" artisan campus:announce "Judul" "Isi" --no-interaction
```

Gunakan ID yang dicetak terminal pada Firebase Console > Messaging. Isi judul dan pesan, pilih topic pengumuman-kampus, channel pengumuman, custom data id=ID dan route=/pengumuman/ID, serta Sound Enabled. Gunakan ID baru untuk demo pesan belum dibaca.

## Port

API Laravel: 8007. HTTPS aplikasi: 8447. Jika kabel dicabut, jalankan lagi adb -s 33a40574 reverse tcp:8447 tcp:8447. API lokal memerlukan laptop dan jalur USB, sedangkan push FCM memakai internet.

## Dua aplikasi pada Vivo

Campus 06 dan Campus 07 mempunyai package Android berbeda, sehingga pemasangan ulang tidak saling menggantikan. Login dan token FCM masing-masing terpisah. Untuk menyalakan server keduanya, jalankan .\jalankan-server-06-07.ps1 dari D:\Pemrograman Mobile, lalu buka aplikasi yang ingin diuji. Pesan yang dikirim ke topik pengumuman-kampus dapat masuk ke kedua aplikasi jika keduanya berlangganan. Untuk uji satu aplikasi saja, pilih token FCM aplikasi tersebut pada Send test message di Firebase Console.

## Pengujian

Hasil otomatis dan perangkat tersedia pada [validasi.md](validasi.md). Pemetaan file tersedia pada [arsitektur.md](arsitektur.md).
