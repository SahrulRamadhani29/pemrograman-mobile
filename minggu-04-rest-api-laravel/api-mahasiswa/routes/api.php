<?php

use App\Http\Controllers\Api\MahasiswaController;
use Illuminate\Support\Facades\Route;

Route::apiResource('mahasiswa', MahasiswaController::class);
