<?php

namespace App\Services;

use Firebase\JWT\JWT;
use Illuminate\Support\Facades\Http;

class FirebaseSender
{
    public function send(int $id, string $title, string $body, ?string $token = null): array
    {
        $path = config('campus.firebase_credentials');
        if (! $path || ! is_file($path)) {
            throw new \RuntimeException('FIREBASE_CREDENTIALS belum diisi. Kirim dari Firebase Console atau konfigurasi service account server terlebih dahulu.');
        }
        $credentials = json_decode(file_get_contents($path), true, flags: JSON_THROW_ON_ERROR);
        $jwt = JWT::encode(['iss' => $credentials['client_email'], 'scope' => 'https://www.googleapis.com/auth/firebase.messaging', 'aud' => 'https://oauth2.googleapis.com/token', 'iat' => time(), 'exp' => time() + 3600], $credentials['private_key'], 'RS256');
        $access = Http::asForm()->post('https://oauth2.googleapis.com/token', ['grant_type' => 'urn:ietf:params:oauth:grant-type:jwt-bearer', 'assertion' => $jwt])->throw()->json('access_token');
        $target = $token ? ['token' => $token] : ['topic' => 'pengumuman-kampus'];

        return Http::withToken($access)->post('https://fcm.googleapis.com/v1/projects/'.$credentials['project_id'].'/messages:send', ['message' => [
            ...$target, 'notification' => ['title' => $title, 'body' => $body],
            'data' => ['route' => '/pengumuman/'.$id, 'id' => (string) $id],
            'android' => ['priority' => 'high', 'notification' => ['channel_id' => 'pengumuman', 'sound' => 'default', 'tag' => 'announcement-'.$id, 'notification_count' => 1]],
            'apns' => ['payload' => ['aps' => ['sound' => 'default', 'badge' => 1]]],
        ]])->throw()->json();
    }
}
