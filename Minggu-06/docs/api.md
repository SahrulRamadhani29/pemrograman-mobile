# API Campus Notify

Base URL pengembangan: https://127.0.0.1:8446/api.

Email login dicocokkan tanpa membedakan huruf besar/kecil. Misalnya rama@polinema.ac.id, raMa@polineMa.ac.id, dan RAMA@POLINEMA.AC.ID mengarah ke akun yang sama. Kata sandi tetap dibandingkan secara persis. Akun lokal dan kata sandi tersimpan di login-lokal.txt yang diabaikan Git; password database berupa hash.

| Method | Endpoint | Fungsi |
|---|---|---|
| POST | /login | Email/password menjadi access token dan refresh token |
| POST | /refresh | Tukar refresh token melalui JSON body, token lama tidak berlaku lagi |
| POST | /logout | Cabut sesi dan registrasi perangkat aktif |
| GET | /me | Identitas pengguna, perlu Bearer token |
| POST | /devices | Daftarkan installation_id, fcm_token, platform |
| DELETE | /devices | Lepas installation_id pengguna saat logout |
| GET | /inbox | Daftar pengumuman pengguna yang belum dibaca |
| POST | /inbox/received | Catat pesan FCM yang diterima; deduplikasi berdasarkan message_id |
| GET | /pengumuman/{id} | Detail yang terhubung ke inbox pengguna |
| POST | /pengumuman/{id}/read | Simpan read_at agar hilang dari daftar belum dibaca |

Access token JWT HS256 berlaku 15 menit. Refresh token acak berlaku 7 hari, disimpan sebagai hash SHA-256 di server dan berotasi pada setiap refresh. Logout mencabut sesi sehingga JWT terkait tidak bisa digunakan lagi. Login dibatasi 10 percobaan per menit.

POST /devices melakukan upsert berdasarkan installation_id. Perubahan token menaikkan token_updates. Token tidak ditampilkan dalam respons API atau screenshot. Endpoint ini benar-benar dipakai oleh getToken dan onTokenRefresh.

Kunci JWT berasal dari APP_KEY. Password demo berasal dari konfigurasi .env. Kedua file konfigurasi lokal dan database tidak dimasukkan ke Git.

POST /inbox/received menerima notifikasi dengan judul saja. Field body boleh tidak dikirim, null, atau string kosong, dan disimpan sebagai string kosong. message_id dan title tetap wajib; otorisasi pengguna dan deduplikasi tetap diberlakukan.
