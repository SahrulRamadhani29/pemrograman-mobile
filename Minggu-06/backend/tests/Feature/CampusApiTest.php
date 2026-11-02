<?php

namespace Tests\Feature;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use PHPUnit\Framework\Attributes\TestWith;
use Tests\TestCase;

class CampusApiTest extends TestCase
{
    use RefreshDatabase;

    private function loginSession(): array
    {
        User::factory()->create(['email' => 'student@example.test', 'password' => Hash::make('test-password')]);

        return $this->postJson('/api/login', ['email' => 'student@example.test', 'password' => 'test-password'])->assertOk()->json();
    }

    public function test_login_rejects_wrong_password_and_protects_routes(): void
    {
        $this->getJson('/api/inbox')->assertUnauthorized();
        $this->postJson('/api/login', ['email' => 'nobody@example.test', 'password' => 'wrong-password'])->assertUnauthorized();
    }

    #[TestWith(['rama@polinema.ac.id', 'raMa@polineMa.ac.id'])]
    #[TestWith(['raMa@polineMa.ac.id', 'rama@polinema.ac.id'])]
    #[TestWith(['rama@polinema.ac.id', 'RAMA@POLINEMA.AC.ID'])]
    public function test_login_accepts_email_case_variations_for_the_same_user(string $storedEmail, string $loginEmail): void
    {
        $user = User::factory()->create(['email' => $storedEmail, 'password' => Hash::make('test-password')]);

        $response = $this->postJson('/api/login', ['email' => $loginEmail, 'password' => 'test-password']);

        $response->assertOk()->assertJsonPath('user.id', $user->id);
        $this->assertDatabaseHas('auth_sessions', ['user_id' => $user->id]);
    }

    public function test_login_returns_401_for_wrong_password_with_mixed_case_email(): void
    {
        User::factory()->create(['email' => 'rama@polinema.ac.id', 'password' => Hash::make('test-password')]);

        $response = $this->postJson('/api/login', ['email' => 'raMa@polineMa.ac.id', 'password' => 'wrong-password']);

        $response->assertUnauthorized();
        $this->assertDatabaseCount('auth_sessions', 0);
    }

    public function test_real_login_refresh_rotation_and_logout(): void
    {
        $session = $this->loginSession();
        $this->withToken($session['access_token'])->getJson('/api/me')->assertOk()->assertJsonPath('email', 'student@example.test');
        $new = $this->postJson('/api/refresh', ['refresh_token' => $session['refresh_token']])->assertOk()->json();
        $this->assertNotSame($session['refresh_token'], $new['refresh_token']);
        $this->postJson('/api/refresh', ['refresh_token' => $session['refresh_token']])->assertUnauthorized();
        $this->withToken($new['access_token'])->postJson('/api/logout')->assertOk();
        $this->withToken($new['access_token'])->getJson('/api/me')->assertUnauthorized();
    }

    public function test_inbox_is_persistent_idempotent_and_disappears_after_read(): void
    {
        $session = $this->loginSession();
        $payload = ['message_id' => 'fcm-test-1', 'title' => 'Jadwal berubah', 'body' => 'Ruang A2'];
        $id = $this->withToken($session['access_token'])->postJson('/api/inbox/received', $payload)->assertOk()->json('id');
        $this->postJson('/api/inbox/received', $payload)->assertOk()->assertJsonPath('id', $id);
        $this->getJson('/api/inbox')->assertOk()->assertJsonCount(1, 'data');
        $this->getJson('/api/pengumuman/'.$id)->assertOk();
        $this->postJson('/api/pengumuman/'.$id.'/read')->assertOk();
        $this->getJson('/api/inbox')->assertOk()->assertJsonCount(0, 'data');
        $this->postJson('/api/inbox/received', $payload)->assertOk();
        $this->getJson('/api/inbox')->assertOk()->assertJsonCount(0, 'data');
        $this->assertNotNull(DB::table('inbox')->value('read_at'));
    }

    public function test_device_token_rotation_updates_one_installation(): void
    {
        $session = $this->loginSession();
        $data = ['installation_id' => 'a543fb0e-8943-4e72-b732-a86b378f7f6e', 'fcm_token' => 'test-fcm-first', 'platform' => 'android'];
        $this->withToken($session['access_token'])->postJson('/api/devices', $data)->assertOk()->assertJsonPath('token_updates', 1);
        $this->postJson('/api/devices', [...$data, 'fcm_token' => 'test-fcm-second'])->assertOk()->assertJsonPath('token_updates', 2);
        $this->postJson('/api/devices', [...$data, 'fcm_token' => 'test-fcm-second'])->assertOk()->assertJsonPath('token_updates', 2);
        $this->assertDatabaseCount('devices', 1);
        $this->assertDatabaseHas('devices', ['fcm_token' => 'test-fcm-second']);
    }

    #[TestWith([[]])]
    #[TestWith([['body' => '']])]
    #[TestWith([['body' => null]])]
    public function test_title_only_notification_is_saved_in_inbox(array $extra): void
    {
        $session = $this->loginSession();

        $response = $this->withToken($session['access_token'])->postJson('/api/inbox/received', [
            'message_id' => 'title-only-message', 'title' => 'Pengumuman singkat', ...$extra,
        ]);

        $id = $response->assertOk()->json('id');
        $this->assertDatabaseHas('announcements', ['id' => $id, 'title' => 'Pengumuman singkat', 'body' => '']);
        $this->getJson('/api/inbox')->assertOk()->assertJsonCount(1, 'data')->assertJsonPath('data.0.id', $id);
    }

    public function test_user_cannot_read_another_users_announcement(): void
    {
        $session = $this->loginSession();
        $other = User::factory()->create();
        $id = DB::table('announcements')->insertGetId(['title' => 'Private', 'body' => 'Only owner', 'recipient_id' => $other->id, 'created_at' => now(), 'updated_at' => now()]);
        DB::table('inbox')->insert(['user_id' => $other->id, 'announcement_id' => $id, 'created_at' => now(), 'updated_at' => now()]);
        $this->withToken($session['access_token'])->getJson('/api/pengumuman/'.$id)->assertNotFound();
        $this->postJson('/api/pengumuman/'.$id.'/read')->assertNotFound();
        $this->postJson('/api/inbox/received', ['message_id' => 'forged', 'announcement_id' => $id, 'title' => 'Forged', 'body' => 'Forged'])->assertForbidden();
    }
}
