<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('auth_sessions', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->string('refresh_hash', 64)->unique();
            $table->timestamp('expires_at');
            $table->timestamps();
        });
        Schema::create('devices', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->uuid('installation_id')->unique();
            $table->text('fcm_token');
            $table->string('platform', 20);
            $table->unsignedInteger('token_updates')->default(1);
            $table->timestamps();
        });
        Schema::create('announcements', function (Blueprint $table) {
            $table->id();
            $table->string('source_key')->nullable()->unique();
            $table->string('title');
            $table->text('body');
            $table->timestamps();
        });
        Schema::create('inbox', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->foreignId('announcement_id')->constrained()->cascadeOnDelete();
            $table->timestamp('read_at')->nullable();
            $table->timestamps();
            $table->unique(['user_id', 'announcement_id']);
        });
    }

    public function down(): void
    {
        foreach (['inbox', 'announcements', 'devices', 'auth_sessions'] as $name) {
            Schema::dropIfExists($name);
        }
    }
};
