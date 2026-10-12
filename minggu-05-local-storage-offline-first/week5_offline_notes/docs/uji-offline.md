# Uji Offline-First

| Skenario | Langkah | Hasil aktual | Status |
|---|---|---|---|
| Isi cache | Buka Posts saat online | Posts tersimpan ke tabel cached_posts | Lulus |
| Cache offline | Aktifkan mode offline lalu buka Posts | Posts tetap dibaca dari cache | Lulus |
| Antrean dirty | Tambah beberapa catatan saat offline | Badge menampilkan jumlah dirty | Lulus |
| Sync ditolak | Tekan sinkron saat offline | Pesan offline muncul, dirty tetap ada | Lulus |
| Sync berhasil | Matikan mode offline lalu sinkron | Catatan ditandai bersih dan badge hilang | Lulus |
| Refresh background | Buka Posts saat online dengan cache | Cache tampil lalu diperbarui | Lulus |

Simpan screenshot aktual pada folder `screenshots/` saat demo di Vivo 1918.
