import 'dart:io';

void main(List<String> arguments) {
  print('Masukkan nama Anda: ');
  String? nama = stdin.readLineSync();

  switch (nama) {
    case null:
      print('Nama tidak diketahui');
      break;
    case '':
      print('Nama tidak diketahui');
      break;
    default:
      print('Nama saya adalah $nama');
  }
}
