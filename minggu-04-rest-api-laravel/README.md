# Praktikum Flutter REST API Laravel

Project ini terdiri dari dua aplikasi:

- `api-mahasiswa`: backend Laravel REST API dengan MySQL.
- `app_mahasiswa`: client Flutter untuk CRUD data mahasiswa.

Fitur:

- Daftar, tambah, detail, edit, dan hapus mahasiswa.
- Pencarian berdasarkan nama atau NIM.
- Field `nim`, `nama`, `prodi`, `email`, `angkatan`, dan `no_hp`.
- Validasi Laravel dan validasi form Flutter.

## Menjalankan Backend

```powershell
cd api-mahasiswa
php artisan migrate:fresh --seed
php artisan serve --host=0.0.0.0 --port=8000
```

## Menjalankan Flutter

Base URL default sudah diarahkan ke IP Wi-Fi laptop `192.168.66.5`. Jika IP berubah:

```powershell
cd app_mahasiswa
flutter run --dart-define=API_BASE_URL=http://IP-LAPTOP:8000/api/mahasiswa
```

HP dan laptop harus berada pada jaringan Wi-Fi yang sama.
