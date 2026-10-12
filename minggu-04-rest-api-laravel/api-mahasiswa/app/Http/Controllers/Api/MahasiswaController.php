<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Mahasiswa;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

class MahasiswaController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index(Request $request)
    {
        $search = trim((string) $request->query('search', ''));
        $query = Mahasiswa::query()->latest('id');
        if ($search !== '') {
            $query->where(fn ($q) => $q
                ->where('nama', 'like', "%{$search}%")
                ->orWhere('nim', 'like', "%{$search}%"));
        }

        return response()->json([
            'success' => true,
            'message' => 'Daftar mahasiswa',
            'data' => $query->get(),
        ]);
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(Request $request)
    {
        $validated = $request->validate($this->rules());
        $mahasiswa = Mahasiswa::create($validated);
        return response()->json([
            'success' => true,
            'message' => 'Mahasiswa berhasil ditambahkan',
            'data' => $mahasiswa,
        ], 201);
    }

    /**
     * Display the specified resource.
     */
    public function show(Mahasiswa $mahasiswa)
    {
        return response()->json([
            'success' => true,
            'message' => 'Detail mahasiswa',
            'data' => $mahasiswa,
        ]);
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(Request $request, Mahasiswa $mahasiswa)
    {
        $validated = $request->validate($this->rules($mahasiswa));
        $mahasiswa->update($validated);
        return response()->json([
            'success' => true,
            'message' => 'Mahasiswa berhasil diperbarui',
            'data' => $mahasiswa->fresh(),
        ]);
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(Mahasiswa $mahasiswa)
    {
        $mahasiswa->delete();
        return response()->json([
            'success' => true,
            'message' => 'Mahasiswa berhasil dihapus',
        ]);
    }

    private function rules(?Mahasiswa $mahasiswa = null): array
    {
        $nim = Rule::unique('mahasiswa', 'nim');
        $email = Rule::unique('mahasiswa', 'email');
        if ($mahasiswa) {
            $nim->ignore($mahasiswa->id);
            $email->ignore($mahasiswa->id);
        }

        return [
            'nim' => ['required', 'string', 'max:10', $nim],
            'nama' => ['required', 'string', 'max:100'],
            'prodi' => ['required', 'string', 'max:50'],
            'email' => ['required', 'email', 'max:255', $email],
            'angkatan' => ['required', 'integer', 'between:2000,2100'],
            'no_hp' => ['required', 'string', 'max:20'],
        ];
    }
}
