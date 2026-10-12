import 'package:flutter_test/flutter_test.dart';
import 'package:app_mahasiswa/models/mahasiswa.dart';

void main() {
  test('Mahasiswa fromJson aman terhadap data kosong', () {
    final mahasiswa = Mahasiswa.fromJson({});
    expect(mahasiswa.nama, '');
    expect(mahasiswa.angkatan, 0);
    expect(mahasiswa.noHp, '');
  });

  test('Mahasiswa toJson mengirim field API', () {
    final json = const Mahasiswa(
      nim: '1',
      nama: 'Sahrul',
      prodi: 'TI',
      email: 's@example.com',
      angkatan: 2024,
      noHp: '0812',
    ).toJson();
    expect(json['nama'], 'Sahrul');
    expect(json['angkatan'], 2024);
    expect(json['no_hp'], '0812');
  });
}
