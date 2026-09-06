import 'dart:io';

void main(List<String> arguments) {
  print('Masukkan nama Anda: ');
  String? nama = stdin.readLineSync();

  print(
    'Nama saya adalah ${nama == null || nama.isEmpty ? 'Nama tidak diketahui' : nama}',
  );
}
