<?php

use App\Http\Controllers\AuthController;
use App\Http\Controllers\CampusController;
use App\Http\Middleware\CampusAuth;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

Route::get('/health', fn () => ['status' => 'ok', 'service' => 'Campus Notify API']);
Route::post('/login', [AuthController::class, 'login'])->middleware('throttle:10,1');
Route::post('/refresh', [AuthController::class, 'refresh'])->middleware('throttle:30,1');
Route::middleware(CampusAuth::class)->group(function () {
    Route::get('/me', fn (Request $request) => $request->user()->only('id', 'name', 'email'));
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::post('/devices', [CampusController::class, 'device']);
    Route::delete('/devices', [CampusController::class, 'unregister']);
    Route::get('/inbox', [CampusController::class, 'inbox']);
    Route::post('/inbox/received', [CampusController::class, 'received']);
    Route::get('/pengumuman/{id}', [CampusController::class, 'announcement']);
    Route::post('/pengumuman/{id}/read', [CampusController::class, 'read']);
});
