<?php

namespace Database\Seeders;

use App\Models\Mahasiswa;
use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        Mahasiswa::query()->delete();
        foreach ([
            ['nim' => '2341720001', 'nama' => 'Andi Pratama', 'prodi' => 'D4 Teknik Informatika', 'email' => 'andi@example.com', 'angkatan' => 2023, 'no_hp' => '081234567801'],
            ['nim' => '2341720002', 'nama' => 'Budi Santoso', 'prodi' => 'D4 Sistem Informasi Bisnis', 'email' => 'budi@example.com', 'angkatan' => 2023, 'no_hp' => '081234567802'],
            ['nim' => '2341720003', 'nama' => 'Citra Ayu', 'prodi' => 'D4 Teknik Informatika', 'email' => 'citra@example.com', 'angkatan' => 2024, 'no_hp' => '081234567803'],
        ] as $data) {
            Mahasiswa::create($data);
        }
    }
}
