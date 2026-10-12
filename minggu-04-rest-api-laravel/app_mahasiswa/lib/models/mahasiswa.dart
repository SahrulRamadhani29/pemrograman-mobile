class Mahasiswa {
  const Mahasiswa({
    this.id,
    required this.nim,
    required this.nama,
    required this.prodi,
    required this.email,
    required this.angkatan,
    required this.noHp,
  });
  final int? id;
  final String nim, nama, prodi, email, noHp;
  final int angkatan;
  factory Mahasiswa.fromJson(Map<String, dynamic> json) => Mahasiswa(
    id: (json['id'] as num?)?.toInt(),
    nim: json['nim'] as String? ?? '',
    nama: json['nama'] as String? ?? '',
    prodi: json['prodi'] as String? ?? '',
    email: json['email'] as String? ?? '',
    angkatan: (json['angkatan'] as num?)?.toInt() ?? 0,
    noHp: json['no_hp'] as String? ?? '',
  );
  Map<String, dynamic> toJson() => {
    'nim': nim,
    'nama': nama,
    'prodi': prodi,
    'email': email,
    'angkatan': angkatan,
    'no_hp': noHp,
  };
}
