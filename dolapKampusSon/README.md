# Campus Market Monorepo

Bu klasör artık Flutter istemcisi ile Flask tabanlı backend'i aynı çatı altında
toplar. `frontend/` dizini Flutter uygulamasını (eski `flutter_application_1`),
`backend/` dizini ise API servislerini barındırır.

```
campus_market/
├─ backend/          # Flask + SQLAlchemy API
├─ frontend/         # Flutter istemcisi
├─ INTEGRATION_STATUS.md
└─ README.md
```

## Backend Çalıştırma
```bash
cd backend
python -m venv .venv
.venv\Scripts\activate          # PowerShell için
pip install -r requirements.txt
flask run                       # veya python app.py
```
Varsayılan olarak API `http://127.0.0.1:5000` adresindeki `/api/...` yollarından
yayınlanır.

## Flutter Frontend Çalıştırma
```bash
cd frontend
flutter pub get
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:5000/api
```
`API_BASE_URL` dart-define verilmezse istemci Android emülatörleri için
`http://10.0.2.2:5000/api` değerini kullanır. Fiziksel cihaz ya da web için
uygun host/IP değeri ile override edilmelidir.

## Bağlantı Durumu
- Giriş, kayıt, ilan listeleme/oluşturma/güncelleme/silme uçları Flask
  backend'i ile konuşur.
- Backend kullanıcı rolü döndürmediği için istemci tüm hesapları `user`
  rolünde varsayar. Admin paneli yalnızca `user_role == 'admin'` olduğunda
  açılır.
- Mesajlaşma, randevu ve teslimat onayı adımları `/api/messages`,
  `/api/appointments` ve `/api/conversations` uçlarına bağlıdır; konuşma
  aşaması backend tarafında güncellendikçe Flutter arayüzüne otomatik yansır.

