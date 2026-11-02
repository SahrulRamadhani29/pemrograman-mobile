<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class CampusController extends Controller
{
    public function received(Request $request)
    {
        $data = $request->validate(['message_id' => 'required|string|max:255', 'announcement_id' => 'nullable|integer|min:1', 'title' => 'required|string|max:255', 'body' => 'nullable|string|max:10000']);
        $data['body'] = $data['body'] ?? '';
        $data['message_id'] = hash('sha256', $request->user()->id.'|'.$data['message_id']);
        $id = DB::transaction(function () use ($data, $request) {
            $existing = isset($data['announcement_id']) ? DB::table('announcements')->where('id', $data['announcement_id'])->first() : null;
            abort_if($existing && $existing->recipient_id !== null && $existing->recipient_id != $request->user()->id, 403);
            if (! $existing) {
                DB::table('announcements')->insertOrIgnore(['source_key' => $data['message_id'], 'recipient_id' => $request->user()->id, 'title' => $data['title'], 'body' => $data['body'], 'created_at' => now(), 'updated_at' => now()]);
                $existing = DB::table('announcements')->where('source_key', $data['message_id'])->first();
            }
            DB::table('inbox')->insertOrIgnore(['user_id' => $request->user()->id, 'announcement_id' => $existing->id, 'created_at' => now(), 'updated_at' => now()]);

            return $existing->id;
        });

        return response()->json(['id' => $id]);
    }

    public function inbox(Request $request)
    {
        return response()->json(['data' => DB::table('inbox')->join('announcements', 'announcements.id', '=', 'inbox.announcement_id')
            ->where('inbox.user_id', $request->user()->id)->whereNull('inbox.read_at')
            ->select('announcements.id', 'announcements.title', 'announcements.body', 'announcements.created_at')->orderByDesc('announcements.id')->get()]);
    }

    public function announcement(Request $request, int $id)
    {
        $item = DB::table('announcements')->where('id', $id)->first();
        abort_unless($item && DB::table('inbox')->where('announcement_id', $id)->where('user_id', $request->user()->id)->exists(), 404);

        return response()->json(['data' => $item]);
    }

    public function read(Request $request, int $id)
    {
        $count = DB::table('inbox')->where('announcement_id', $id)->where('user_id', $request->user()->id)->update(['read_at' => now(), 'updated_at' => now()]);
        abort_unless($count, 404);

        return response()->json(['message' => 'Pengumuman sudah dibaca.']);
    }

    public function device(Request $request)
    {
        $data = $request->validate(['installation_id' => 'required|uuid', 'fcm_token' => 'required|string|max:4096', 'platform' => 'required|in:android,ios']);
        $old = DB::table('devices')->where('installation_id', $data['installation_id'])->first();
        DB::table('devices')->updateOrInsert(['installation_id' => $data['installation_id']], [
            ...$data, 'user_id' => $request->user()->id,
            'token_updates' => $old ? $old->token_updates + ($old->fcm_token !== $data['fcm_token'] ? 1 : 0) : 1,
            'created_at' => $old?->created_at ?? now(), 'updated_at' => now(),
        ]);

        return response()->json(['message' => 'Perangkat terdaftar.', 'token_updates' => DB::table('devices')->where('installation_id', $data['installation_id'])->value('token_updates')]);
    }

    public function unregister(Request $request)
    {
        DB::table('devices')->where('user_id', $request->user()->id)->where('installation_id', $request->input('installation_id'))->delete();

        return response()->json(['message' => 'Perangkat dilepas.']);
    }
}
