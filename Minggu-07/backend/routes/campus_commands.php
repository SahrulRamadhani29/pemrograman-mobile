<?php

use App\Services\FirebaseSender;
use Illuminate\Support\Facades\Artisan;
use Illuminate\Support\Facades\DB;

Artisan::command('campus:announce {title} {body} {--send} {--personal=}', function () {
    $users = $this->option('personal') ? DB::table('users')->where('email', $this->option('personal'))->get() : DB::table('users')->get();
    if ($this->option('personal') && $users->isEmpty()) {
        $this->error('Pengguna tidak ditemukan.');

        return 1;
    }
    $id = DB::table('announcements')->insertGetId(['title' => $this->argument('title'), 'body' => $this->argument('body'), 'recipient_id' => $this->option('personal') ? $users->first()->id : null, 'created_at' => now(), 'updated_at' => now()]);
    foreach ($users as $user) {
        DB::table('inbox')->insert(['user_id' => $user->id, 'announcement_id' => $id, 'created_at' => now(), 'updated_at' => now()]);
    }
    $this->info('Pengumuman tersimpan. ID: '.$id.' | route: /pengumuman/'.$id);
    if ($this->option('send')) {
        if ($this->option('personal')) {
            foreach (DB::table('devices')->whereIn('user_id', $users->pluck('id'))->get() as $device) {
                app(FirebaseSender::class)->send($id, $this->argument('title'), $this->argument('body'), $device->fcm_token);
            }
        } else {
            app(FirebaseSender::class)->send($id, $this->argument('title'), $this->argument('body'));
        }
        $this->info('FCM menerima permintaan pengiriman.');
    }
})->purpose('Simpan pengumuman dan kirim notifikasi melalui FCM (opsional).');
