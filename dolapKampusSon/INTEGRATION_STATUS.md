# Entegrasyon Durumu

Bu dosya Flutter istemcisi ile Flask backend arasında yapılan bağları ve halen
açık kalan işleri özetler.

## Tamamlanan Bağlantılar

- **Kimlik Doğrulama**: `/api/auth/register` ve `/api/auth/login` uçları
  gerçek API üzerinden çalışır; token, kullanıcı ID/e-posta bilgileri güvenli
  depoya yazılır.
- **İlan İşlemleri**: Listeleme (`GET /api/listings/`), oluşturma, güncelleme
  ve silme uçları (`/create`, `/update/<id>`, `/delete/<id>`) Flutter tarafı ile
  eşleştirildi. Filtreleme (kategori + min/max fiyat) backend parametrelerine
  gönderiliyor; arama ve sıralama istemci tarafında uygulanıyor.
- **Klasör Yapısı**: Flutter projesi `frontend/` altına taşındı, eski boş
  Flutter şablonu kaldırıldı. Backend bağımsız kalmaya devam ediyor.
- **Mesajlaşma & Aşamalar**: `/api/messages`, `/api/appointments` ve
  `/api/conversations` uçları Flutter mesaj ekranına bağlandı. Sohbet başlatma,
  şablon üzerinden mesaj gönderme, randevu oluşturma ve teslimat onayı sonrası
  stage güncellemeleri uygulamaya yansıyor.

## Eksikler / TODO

- **Rol Yönetimi**: Backend kullanıcı modeli rol döndürmediği için istemci
  tüm oturumları `user` rolünde kabul eder. Admin paneli arayüzde kalsa da
  backend veri eksikliğinden dolayı gizli kalıyor. Çözüm: `User` tablosuna
  `role` alanı ekleyip `/auth/login` yanıtına dahil etmek.
- **Medya Yükleme**: Flutter tarafı fotoğraf seçmeye izin veriyor ancak backend
  şu an `image_url` alanını metin olarak bekliyor. Dosya yükleme / çoklu foto
  desteği henüz yok.
- **Sayfalama / Arama**: Backend tarafında sayfalama ve serbest metin arama
  uçları bulunmadığı için Flutter tüm sonuçları çekip istemci içerisinde
  filtreliyor. Büyük veri setlerinde iyileştirme gerekiyor.
- **İlanlarım**: Backend'de "kullanıcının ilanları" için özel bir endpoint
  olmadığından istemci tüm ilanları çekip `seller_id` filtreliyor. Kullanıcı
  kimliği JWT'den okunarak döndürülse daha verimli olur.
- **Geri Bildirim Kaydı**: Flutter tarafında puan/şablon seçimi yapılıyor
  ancak backend'de Feedback modeline kayıt atılmıyor; yalnızca conversation
  stage `COMPLETED` olacak şekilde güncelleniyor.
- **Profil Güncelleme**: `AuthController.updateProfile` testi amaçlı kısa
  gecikme döndürüyor; backend tarafında karşılığı yok.

## Konfigürasyon Notları

- Flutter istemcisi `API_BASE_URL` dart-define parametresiyle override
  edilebilir; verilmezse Android emülatörleri için `http://10.0.2.2:5000/api`
  kullanılır.
- Backend `.env`/`Config` tarafında CORS, JWT secret ve veritabanı ayarları
  aynı kaldı; yeni dizin yapısı değişikliğinden etkilenmedi.

Bu listedeki kalemler kapatıldıkça dosyayı güncelleyebilirsiniz.
