<?php

namespace App\Services;

use Firebase\JWT\JWT;
use Firebase\JWT\Key;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

class SessionTokens
{
    public function issue(int $userId, ?string $sessionId = null): array
    {
        $id = $sessionId ?? (string) Str::uuid();
        $refresh = bin2hex(random_bytes(48));
        DB::table('auth_sessions')->updateOrInsert(['id' => $id], [
            'user_id' => $userId, 'refresh_hash' => hash('sha256', $refresh),
            'expires_at' => now()->addDays(7), 'created_at' => now(), 'updated_at' => now(),
        ]);
        $access = JWT::encode([
            'iss' => 'campus-notify', 'aud' => 'campus-notify-mobile',
            'sub' => $userId, 'sid' => $id, 'iat' => time(),
            'exp' => time() + (int) config('campus.access_ttl', 900),
        ], $this->key(), 'HS256');

        return ['access_token' => $access, 'refresh_token' => $refresh, 'token_type' => 'Bearer', 'expires_in' => (int) config('campus.access_ttl', 900)];
    }

    public function decode(string $token): object
    {
        $claims = JWT::decode($token, new Key($this->key(), 'HS256'));
        if ($claims->iss !== 'campus-notify' || $claims->aud !== 'campus-notify-mobile') {
            throw new \RuntimeException('Token tidak valid');
        }

        return $claims;
    }

    private function key(): string
    {
        $key = config('app.key');

        return str_starts_with($key, 'base64:') ? base64_decode(substr($key, 7)) : $key;
    }
}
