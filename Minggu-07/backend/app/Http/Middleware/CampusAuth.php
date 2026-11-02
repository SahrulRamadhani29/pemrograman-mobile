<?php

namespace App\Http\Middleware;

use App\Models\User;
use App\Services\SessionTokens;
use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class CampusAuth
{
    public function handle(Request $request, Closure $next)
    {
        try {
            $claims = app(SessionTokens::class)->decode($request->bearerToken() ?? '');
            $session = DB::table('auth_sessions')->where('id', $claims->sid)->where('expires_at', '>', now())->first();
            $user = User::find($claims->sub);
            if (! $session || ! $user || $session->user_id != $user->id) {
                throw new \RuntimeException('Sesi berakhir');
            }
            $request->setUserResolver(fn () => $user);
            $request->attributes->set('session_id', $claims->sid);
        } catch (\Throwable) {
            return response()->json(['message' => 'Sesi berakhir. Silakan login kembali.'], 401);
        }

        return $next($request);
    }
}
