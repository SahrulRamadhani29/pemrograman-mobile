# Perbandingan Storage

| Kriteria | SharedPreferences | Hive | sqflite | Drift |
|---|---|---|---|---|
| Kompleksitas query | Key-value sederhana | Query NoSQL sederhana | SQL lengkap | SQL dengan API Dart |
| Dukungan relasi | Tidak ada | Tidak ada relasi SQL | Ada relasi dan join | Ada relasi dan join |
| Reaktivitas | Tidak bawaan | Terbatas | Tidak bawaan | Stream/watch kuat |
| Type-safety | Rendah | Sedang | Manual | Tinggi dengan generator |
| Boilerplate | Sangat kecil | Kecil | Sedang | Lebih besar di awal |
| Kemudahan testing | Mudah di-mock | Mudah | Repository perlu fake | Baik, tetapi generator menambah setup |
| Cocok untuk preferensi | Ya | Bisa | Terlalu berat | Terlalu berat |
| Cocok untuk 1000+ catatan | Tidak | Bisa | Ya | Ya |
| Keputusan | Dipakai | Alternatif | Dipakai | Alternatif |

Keputusan akhir memakai SharedPreferences untuk nilai kecil seperti tema dan waktu terakhir dibuka. Catatan memakai SQLite karena membutuhkan daftar banyak baris, pengurutan, field dirty, dan kemungkinan query lanjutan. Hive dan Drift tetap valid, tetapi tidak dipilih karena jobsheet melatih sqflite dan kebutuhan aplikasi belum memerlukan stream Drift atau generator model.
