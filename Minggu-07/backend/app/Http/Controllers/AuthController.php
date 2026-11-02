<?php

namespace App\Http\Controllers;

use App\Models\User;
use App\Services\SessionTokens;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;

class AuthController extends Controller
{
    public function login(Request $request, SessionTokens $tokens)
    {
        $data = $request->validate(['email' => 'required|email', 'password' => 'required|string']);
        $user = User::whereRaw('LOWER(email) = ?', [strtolower(trim($data['email']))])->first();
        if (! $user || ! Hash::check($data['password'], $user->password)) {
            return response()->json(['message' => 'Email atau kata sandi salah.'], 401);
        }

        return response()->json([...$tokens->issue($user->id), 'user' => $user->only('id', 'name', 'email')]);
    }

    public function refresh(Request $request, SessionTokens $tokens)
    {
        $data = $request->validate(['refresh_token' => 'required|string']);

        return DB::transaction(function () use ($data, $tokens) {
            $session = DB::table('auth_sessions')->where('refresh_hash', hash('sha256', $data['refresh_token']))->lockForUpdate()->first();
            if (! $session || now()->greaterThanOrEqualTo($session->expires_at)) {
                return response()->json(['message' => 'Refresh token sudah tidak berlaku.'], 401);
            }

            return response()->json($tokens->issue($session->user_id, $session->id));
        });
    }

    public function logout(Request $request)
    {
        DB::table('devices')->where('user_id', $request->user()->id)->where('installation_id', $request->input('installation_id'))->delete();
        DB::table('auth_sessions')->where('id', $request->attributes->get('session_id'))->delete();

        return response()->json(['message' => 'Berhasil keluar.']);
    }
}
