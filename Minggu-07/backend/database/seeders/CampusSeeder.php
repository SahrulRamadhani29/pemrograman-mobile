<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;

class CampusSeeder extends Seeder
{
    public function run(): void
    {
        $password = env('CAMPUS_DEMO_PASSWORD');
        if (! $password) {
            throw new \RuntimeException('Isi CAMPUS_DEMO_PASSWORD di .env sebelum menjalankan seeder.');
        }
        $email = strtolower(trim(env('CAMPUS_DEMO_EMAIL', 'rama@polinema.ac.id')));
        User::updateOrCreate(['email' => $email], ['name' => 'Sahrul Ramadhani', 'password' => Hash::make($password)]);
        foreach ([1 => ['Selamat datang di Campus', 'Informasi kuliah, kegiatan, dan pengumuman kampus ada di sini.'], 2 => ['Pengumpulan tugas Mobile', 'Siapkan source code, hasil pengujian, dan laporan praktikum Minggu 6.'], 3 => ['Jadwal kuliah berubah', 'Kelas Pemrograman Mobile pindah ke Ruang A2 jam 13.00.']] as $id => [$title, $body]) {
            DB::table('announcements')->updateOrInsert(['id' => $id], ['title' => $title, 'body' => $body, 'created_at' => now(), 'updated_at' => now()]);
        }
    }
}
