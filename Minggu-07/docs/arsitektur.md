# Perbandingan arsitektur

## Pemetaan file

| Minggu-06 | Minggu-07 | Alasan |
|---|---|---|
| data/auth_repository.dart | domain/repositories/auth_repository.dart dan data/repositories/api_auth_repository.dart | Kontrak dan akses Dio dipisahkan. |
| AuthSession di repository | domain/entities/auth_session.dart dan data/models/auth_session_model.dart | Entity bebas parsing JSON. |
| Announcement di inbox_repository.dart | domain/entities/announcement.dart dan data/models/announcement_model.dart | UI menerima entity, bukan JSON atau DTO. |
| data/token_store.dart | domain/storage dan data/storage | Sesi dan identitas instalasi memiliki kontrak tersendiri. |
| messaging/push_service.dart | data/repositories/firebase_notification_repository.dart dan presentation/providers/notification_controller.dart | Integrasi Firebase terpisah dari state UI dan Riverpod. |
| messaging/pending_inbox.dart | data/services/pending_inbox.dart | Parsing antrean lokal berada pada data layer. |
| providers/auth_provider.dart | presentation/providers/auth_provider.dart dan domain/usecases/login.dart | State memanggil operasi bisnis melalui kontrak. |
| pages/announcement_page.dart | presentation/pages/announcement_page.dart dan domain/usecases/open_announcement.dart | Aturan memuat lalu membaca pesan terpisah dari widget. |
| pages/settings_page.dart | presentation/pages/settings_page.dart dan domain/usecases/logout.dart | Logout tidak mengoordinasikan adapter langsung dari widget. |
| routes.dart | presentation/routing/app_routes.dart dan domain/entities/announcement_target.dart | Router Flutter terpisah dari validasi tujuan pengumuman yang murni Dart. |
| Pemetaan error Dio | data/api/api_errors.dart dan domain/failures/app_failure.dart | Exception infrastruktur menjadi Failure sebelum mencapai UI. |
| Format tanggal dalam widget | presentation/formatters/display_date.dart | Format tanggal dapat diuji sebagai fungsi murni. |

Path tabel di atas relatif terhadap lib/. Semua source baru berada dalam data, domain, presentation, dan main.dart.

## Arah dependensi

Presentation bergantung pada domain. Data bergantung pada domain. Domain tidak mengimpor Flutter, Riverpod, Dio, Firebase, atau implementasi data. File dependencies.dart merupakan wiring DI yang menghubungkan kontrak dengan implementasinya.

## Pilihan struktur

Tugas ini memakai layer-first sesuai instruksi: setiap layer diletakkan langsung di lib/. Auth dan pengumuman mempunyai kontrak terpisah di dalam layer yang sama. Use case hanya dibuat untuk operasi yang mengoordinasikan beberapa langkah. Pembacaan inbox satu langkah cukup melalui repository.

## Biaya perubahan

Jumlah file bertambah karena kontrak, model, dan implementasi dipisahkan. Sebagai gantinya, tes bisnis dapat memakai repository palsu tanpa Firebase, secure storage, atau server. Perubahan ini tidak menyertakan fitur pengguna baru.
