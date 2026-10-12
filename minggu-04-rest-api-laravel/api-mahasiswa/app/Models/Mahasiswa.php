<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Mahasiswa extends Model
{
    protected $table = 'mahasiswa';

    protected $fillable = [
        'nim', 'nama', 'prodi', 'email', 'angkatan', 'no_hp',
    ];

    protected function casts(): array
    {
        return ['angkatan' => 'integer'];
    }
}
