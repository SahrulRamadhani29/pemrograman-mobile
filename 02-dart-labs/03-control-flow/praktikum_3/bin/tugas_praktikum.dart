import 'dart:io';

void main() {
  Map<String, int> dataMahasiswa = {};

  for (int i = 1; i <= 5; i++) {
    stdout.write('Nama mahasiswa ke-$i: ');
    String nama = stdin.readLineSync()!;

    stdout.write('Nilai ujian $nama: ');
    int nilai = int.parse(stdin.readLineSync()!);

    dataMahasiswa[nama] = nilai;
  }

  print('\n--- Daftar Mahasiswa dan Kategori ---');

  dataMahasiswa.forEach((nama, nilai) {
    String kategori;

    if (nilai >= 80) {
      kategori = 'A';
    } else if (nilai >= 60) {
      kategori = 'B';
    } else {
      kategori = 'C';
    }

    print('$nama | Nilai: $nilai | Kategori: $kategori');
  });
}
