import 'dart:io';

void main(List<String> arguments) {
  print('Masukkan nama Anda: ');
  String? nama = stdin.readLineSync();

  if (nama != null && nama.isNotEmpty) {
    print('Nama anda adalah $nama');
  } else {
    print('Nama tidak diketahui');
  }

  String status = nama != null && nama.isNotEmpty
      ? 'Nama anda adalah $nama'
      : 'Nama tidak diketahui';
  print(status);
}
