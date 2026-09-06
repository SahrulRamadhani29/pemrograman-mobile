double hitungLuasPersegiPanjang(double panjang, double lebar) {
  return panjang * lebar;
}

class Profil {
  String? nama;
  String? nim;
  String? email;
}

void main() {
  double luas = hitungLuasPersegiPanjang(10, 5);
  print('Luas persegi panjang: $luas');

  Profil profil = Profil();
  profil.nama = 'Sahrul Ramadhani';
  profil.nim = '244107020058';
  profil.email = null;

  print('Nama: ${profil.nama}');
  print('NIM: ${profil.nim}');
  print('Email: ${profil.email ?? 'Belum diisi'}');
}
