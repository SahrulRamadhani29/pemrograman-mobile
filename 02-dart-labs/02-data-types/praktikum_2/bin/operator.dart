import 'dart:io';

void main(List<String> arguments) {
  stdout.write('Masukkan angka pertama: ');
  String? input1 = stdin.readLineSync();

  stdout.write('Masukkan angka kedua: ');
  String? input2 = stdin.readLineSync();

  int? angka1 = int.tryParse(input1 ?? '');
  int? angka2 = int.tryParse(input2 ?? '');

  if (angka1 == null || angka2 == null) {
    print('Input tidak valid. Masukkan dua bilangan bulat.');
    return;
  }

  print('Hasil penjumlahan: ${angka1 + angka2}');
  print('Hasil pengurangan: ${angka1 - angka2}');
  print('Hasil perkalian: ${angka1 * angka2}');
  print(
    angka2 == 0
        ? 'Hasil pembagian: tidak dapat membagi dengan nol'
        : 'Hasil pembagian: ${angka1 / angka2}',
  );
}
