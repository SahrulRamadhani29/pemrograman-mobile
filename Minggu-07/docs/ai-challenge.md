# AI Challenge Minggu 07

## Prompt tugas

Salin aplikasi notifikasi Minggu-06 ke Minggu-07. Refactor memakai SOLID dan layer-first dengan lib/data, lib/domain, lib/presentation. Pertahankan fungsi aplikasi, uji kembali, lalu buat laporan perbandingan singkat.

## Draf awal

Draf memisahkan entity, kontrak repository, model JSON, adapter API/penyimpanan, use case Login, Logout, OpenAnnouncement, dan controller notifikasi. Implementasi SDK Firebase berada di data dan dependency injection memakai Riverpod.

## Keputusan

| Usulan | Keputusan final | Alasan |
|---|---|---|
| Feature-first seperti contoh slide | Layer-first | Instruksi tugas secara eksplisit menetapkan tiga layer langsung di lib/. |
| Repository konkret dipakai widget | Kontrak dan use case domain | Mengurangi ketergantungan halaman terhadap Dio dan Firebase. |
| Use case untuk setiap CRUD | Tiga use case yang mengoordinasikan langkah | Pembacaan inbox sederhana tetap langsung melalui kontrak. |
| Error SDK diteruskan ke UI | Konversi AppFailure di adapter | Pesan UI tidak menerima rincian exception mentah. |
| Menghapus alur token/antrean saat refactor | Mempertahankan logikanya dan memindahkan batas tanggung jawab | Mencegah hilangnya perbaikan antrean dan refresh yang sudah diuji. |

## Verifikasi

Tes mencakup use case sukses/failure dengan repository palsu, refresh token, logout saat inbox aktif, parsing tujuan notifikasi, antrean pesan gagal, dan aturan dependensi. Log perintah pemeriksaan serta hasil perangkat dicatat di validasi.md.
