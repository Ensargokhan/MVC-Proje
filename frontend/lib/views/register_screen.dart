import 'package:flutter/material.dart';
import 'package:flutter_application_1/controllers/auth_controller.dart';
import 'package:provider/provider.dart';

class RegisterScreen extends StatelessWidget {
  RegisterScreen({super.key}); // const hatasını baştan çözdük

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final authController = Provider.of<AuthController>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kampüs 2. El - Kayıt Ol'),
        backgroundColor: Colors.lightBlue,
        // Geri tuşu otomatik olarak eklenecek
      ),
      body: Consumer<AuthController>(
        builder: (context, controller, child) {
          return Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: SingleChildScrollView(
                // Taşmayı önlemek için
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Hesap oluşturmak için lütfen bilgilerinizi girin.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),

                    // YENİ: Ad Soyad Alanı
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Ad Soyad',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: authController.onNameChanged, // YENİ EKLENDİ
                      validator: (value) {
                        // ... (validator kısmı aynı kalıyor)
                      },
                    ),
                    const SizedBox(height: 20),

                    // E-posta Alanı
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'E-posta (@selcuk.edu.tr)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      onChanged: authController.onEmailChanged, // YENİ EKLENDİ
                      validator: (value) {
                        // ... (validator kısmı aynı kalıyor)
                      },
                    ),
                    const SizedBox(height: 20),

                    // Şifre Alanı
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Şifre',
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                      onChanged:
                          authController.onPasswordChanged, // YENİ EKLENDİ
                      validator: (value) {
                        // ... (validator kısmı aynı kalıyor)
                      },
                    ),
                    const SizedBox(height: 30),

                    // Hata Mesajı veya Yüklenme Çemberi
                    if (controller.isLoading)
                      const CircularProgressIndicator()
                    else if (controller.errorMessage != null)
                      Text(
                        controller.errorMessage!,
                        style: const TextStyle(color: Colors.red, fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    const SizedBox(height: 20),

                    ElevatedButton(
                      // Yükleniyorsa butonu pasif yap
                      onPressed: controller.isLoading
                          ? null
                          : () async {
                              // 1. Formun geçerli olup olmadığını kontrol et
                              if (_formKey.currentState!.validate()) {
                                // 2. Form geçerliyse, Controller'daki register metodunu çağır
                                debugPrint(
                                  'Kayıt Formu geçerli! API çağrılıyor...',
                                );

                                final bool kayitBasarili = await controller
                                    .registerUser();

                                // 3. API'den gelen sonuca göre hareket et
                                if (kayitBasarili) {
                                  // BAŞARILI: Kullanıcıya mesaj göster ve Giriş Ekranına dön
                                  debugPrint(
                                    'KAYIT BAŞARILI! Giriş ekranına dönülüyor...',
                                  );

                                  // 'context' hatası almamak için bu kontrolü ekliyoruz
                                  if (context.mounted) {
                                    Navigator.of(
                                      context,
                                    ).pop(); // Bir önceki ekrana (Giriş) dön
                                  }
                                } else {
                                  // BAŞARISIZ: Hata mesajı zaten ekranda görünecek
                                  debugPrint(
                                    'KAYIT BAŞARISIZ! Hata mesajı ekranda gösterildi.',
                                  );
                                }
                              }
                            },
                      child: const Text('Kayıt Ol'),
                    ),
                    TextButton(
                      onPressed: () {
                        // Giriş ekranına geri dön
                        Navigator.of(context).pop();
                      },
                      child: const Text('Zaten bir hesabın var mı? Giriş Yap'),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
