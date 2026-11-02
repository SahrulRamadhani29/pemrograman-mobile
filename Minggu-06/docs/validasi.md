# Validasi perangkat

Perangkat: Vivo 1918, serial 33a40574.

| Spesifikasi | Status | Bukti |
|---|---|---|
| Login API dan secure storage | Lulus di Vivo | Login sahrul@kampus.ac.id ke API HTTPS; sesi pulih setelah aplikasi dibuka ulang |
| Perubahan akun dan email tanpa membedakan huruf besar/kecil | Lulus lewat API HTTPS dan tes otomatis | Akun lama diperbarui menjadi rama@polinema.ac.id dengan user ID tetap 1; tiga variasi kapitalisasi mendapat HTTP 200; kata sandi salah mendapat 401 |
| Logout dengan inbox aktif | Lulus di Vivo dan tes regresi | APK final kembali ke login tanpa pesan galat; sesi dan registrasi perangkat di server menjadi 0 |
| Refresh sekali dan logout saat refresh mati | Lulus otomatis | auth_push_test.dart dan CampusApiTest.php |
| Daftar belum dibaca hilang setelah dibaca | Lulus di Vivo | Daftar 1 menjadi 0; read_at tersimpan; tetap kosong setelah aplikasi dibuka ulang |
| getToken dan onTokenRefresh ke POST /devices | Lulus di Vivo | Satu event onTokenRefresh; token_updates berubah dari 1 ke 2 pada instalasi yang sama |
| Hapus data aplikasi lalu login kembali | Lulus di Vivo | pm clear berhasil; getToken menghasilkan token baru dan backend mendaftarkannya; status baca di server tetap tersimpan |
| Foreground | Lulus | Banner lokal muncul; klik membuka pengumuman 3 |
| Background | Lulus | Setelah Home, banner sistem muncul; klik membuka pengumuman 3 |
| Terminated | Lulus | Swipe-close, proses dan Activity Campus tidak ada; push masuk; klik membuka pengumuman 3 |
| Badge lonceng dan ikon Home | Lulus di Vivo | Angka 1 pada lonceng dan badge merah 1 pada ikon; badge visual hilang setelah dibaca |
| Suara notifikasi | Lulus di Vivo, dikonfirmasi pengguna | Channel HIGH dengan sound URI; pengguna mengonfirmasi suara dan popup pada uji Tes notifikasi Vivo |
| Subscribe/unsubscribe | Lulus di Vivo | Switch OFF/ON berhasil; campaign ke topik diterima dan membuka pengumuman 4 |

Token hanya boleh tampil 12 karakter pertama di screenshot. Log bukti harus dibersihkan dari token utuh sebelum disimpan.

## Bukti

- 01-login.png: halaman login.
- 03-foreground.png: daftar dan indikator belum dibaca.
- 04-foreground-banner.png dan 05-detail-dibaca.png: foreground.
- 06-inbox-setelah-dibaca.png: daftar kosong setelah dibaca.
- 07-background-banner.png dan 08-background-detail.png: background.
- 10-terminated-banner.png dan 11-terminated-detail.png: terminated.
- 12-token-masked.png dan 13-token-refresh.png: lifecycle token sebelum logout.
- 18-topic-banner.png, 19-topic-detail.png, dan firebase-campaign-completed.jpg: pengiriman topik. Campaign semula Active dan akhirnya Completed.
- 21-perangkat-dan-suara.png: diagnostik suara dari AudioManager dan dukungan launcher.
- 23-badge-setting-enabled.png: izin badge khusus Campus pada Vivo.
- 25-launcher-unread.png dan 28-launcher-read.png: badge visual sebelum dan setelah dibaca.
- 30-setelah-hapus-data.png dan evidence-clear-data.json: pendaftaran token setelah data aplikasi dihapus. Event onTokenRefresh diuji secara terpisah melalui rotasi token; saat instalasi bersih, token awal didaftarkan melalui getToken.
- 29-logout-login.png dan evidence-final-logout.json: logout bersih pada APK final.
- 31-final-push.png, 32-final-detail.png, dan 33-home-final.png: token baru menerima pesan pengumuman 6; klik membuka detail dan menyimpan status baca. Aplikasi ditinggalkan login pada halaman utama dengan 0 pesan belum dibaca.
- fcm-console-test.png: salinan potongan banner uji background sesuai nama bukti pada jobsheet.

## Pemeriksaan otomatis akhir

flutter analyze bersih. Setelah perbaikan antrean inbox, 14 tes Flutter dan 14 tes Laravel lulus dengan 68 assertions backend. Tes regresi logout terlebih dahulu mereproduksi CircularDependencyError ketika inbox sedang diamati; perbaikan mengandalkan ref.watch agar inbox mengikuti status autentikasi tanpa invalidasi manual dari auth.

Potongan kartu notifikasi diambil dari screenshot asli. Bagian notifikasi aplikasi lain tidak disimpan. File evidence-*.txt hanya memuat record NotificationManager untuk package Campus.

## Penyesuaian perangkat

Template Gradle menyediakan heap 8 GB, sedangkan RAM laptop sekitar 12 GB. Heap diturunkan menjadi 2 GB dan worker dibatasi dua agar build tidak memenuhi memori. Kotlin incremental dimatikan karena cache package dan project berada pada drive berbeda.

Plugin badge umum tidak mengenali launcher com.bbk.launcher2. Dukungan launcher lama ditambahkan melalui plugin lokal. Selain itu, opsi badge ikon pada pengaturan notifikasi Vivo ternyata belum aktif. Setelah diaktifkan khusus untuk Campus, badge merah terlihat pada screenshot dan menghilang setelah notifikasi dibaca. Nilai accessibility launcher dapat tertinggal; penilaian akhir memakai tampilan screenshot sebenarnya.

Setelah pm clear, pengaturan badge dan notifikasi melayang Campus diperiksa ulang dan tetap aktif. Bukti 23 diperbarui dari layar pengaturan perangkat sesudah uji tersebut.

Sebelumnya mode Diam aktif. Pengujian suara dilakukan dalam mode bunyi dengan volume notifikasi 3/7. Bukti suara yang dapat diverifikasi otomatis adalah konfigurasi AudioManager dan channel NotificationManager; tidak ada rekaman mikrofon atau klaim bahwa suara didengar langsung oleh asisten.

Push uji akhir juga memiliki mImportance=HIGH, mSound=content://settings/system/notification_sound, dan mShowBadge=true. Pada pengujian ulang Tes notifikasi Vivo tanggal 2 November 2026, pengguna mengonfirmasi: "ada nnotifikasi suara dan popup". Ini melengkapi bukti konfigurasi dengan konfirmasi pendengaran langsung dari pengguna.

Saat pengujian ulang, koneksi USB sempat hilang sehingga aplikasi tidak bisa mengakses API lokal walaupun Wi-Fi aktif. Setelah Vivo terdeteksi kembali dan adb reverse dipulihkan, inbox berhasil memuat pengumuman 7. Pemeriksaan berikutnya menunjukkan read_at pengumuman 7 sudah terisi, sehingga pesan hilang dari daftar belum dibaca sesuai perilaku aplikasi.

Project Firebase memakai paket Spark tanpa Analytics. Pengujian mencakup beberapa pesan test perangkat dan campaign topik sungguhan. Backend pengirim HTTP v1 tersedia sebagai pilihan, tetapi service account server tidak dibuat; pengiriman yang diuji memakai Firebase Console.

## Perbaikan antrean inbox

Pengumuman 8 berjudul test woi masih memiliki read_at=null dan tampil pada GET /inbox, tetapi UI Vivo menunjukkan 0 pesan. Pull-to-refresh menghasilkan pesan validasi 422. Pemeriksaan antrean SharedPreferences khusus aplikasi menemukan event kosong lama dengan message_id=0-null, judul fallback Pengumuman, dan body kosong, diikuti pesan test final week 6 yang belum terkirim ke API.

Perbaikan mengabaikan event baru tanpa isi, membersihkan event kosong lama, melanjutkan antrean setelah kegagalan satu pesan, dan tetap mengambil daftar belum dibaca dari server. Pesan gagal yang mempunyai isi dipertahankan untuk dicoba lagi. API juga menerima body kosong untuk notifikasi yang hanya memiliki judul. Screenshot 35 merekam UI sebelum perbaikan.

APK perbaikan dipasang dengan adb install -r tanpa menghapus data aplikasi. Setelah dibuka kembali, antrean pending menjadi 0 dan UI Vivo menampilkan test final week 6 dengan badge 1. Pesan tersebut tetap muncul setelah pull-to-refresh dan masih memiliki read_at=null. Screenshot 36 dan evidence-inbox-repair.json merekam hasil setelah perbaikan. Status pengumuman 8 pada akhir uji sudah berubah menjadi dibaca; bukti awal tetap menunjukkan bahwa saat masalah dilaporkan, pengumuman itu belum dibaca tetapi UI menampilkan 0.
