import 'package:flutter/material.dart';
import 'package:flutter_application_1/controllers/auth_controller.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/views/register_screen.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key}); // 'const' kaldırılmıştı

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    //
    // DEĞİŞİKLİK 1: Controller'a erişimi 'build' metodunun içine taşıdık
    //
    final authController = Provider.of<AuthController>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kampüs 2. El - Giriş'),
        backgroundColor: Colors.lightBlue,
        automaticallyImplyLeading: false,
      ),
      //
      // DEĞİŞİKLİK 2: Tüm gövdeyi 'Consumer' ile sarıyoruz
      // Bu, 'notifyListeners' çağrıldığında ekranın güncellenmesini sağlar
      //
      body: Consumer<AuthController>(
        builder: (context, controller, child) {
          return Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Sadece @selcuk.edu.tr uzantılı e-posta ile giriş yapılabilir.',
                    style: TextStyle(color: Colors.grey[700]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),

                  // E-posta
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'E-posta (@selcuk.edu.tr)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    onChanged: controller.onEmailChanged,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'E-posta alanı zorunludur.';
                      }
                      if (!value.endsWith('@selcuk.edu.tr')) {
                        return 'Sadece @selcuk.edu.tr e-postası geçerlidir.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Şifre
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Şifre',
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                    onChanged: controller.onPasswordChanged,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Şifre alanı zorunludur.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 30),

                  //
                  // DEĞİŞİKLİK 3: Hata Mesajını ve Yüklenme Çemberini Gösterme
                  //
                  if (controller.isLoading)
                    const CircularProgressIndicator()
                  else if (controller.errorMessage != null)
                    Text(
                      // Hata varsa mesajı kırmızı göster
                      controller.errorMessage!,
                      style: const TextStyle(color: Colors.red, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),

                  const SizedBox(height: 20), // Hata ile buton arasına boşluk

                  ElevatedButton(
                    // Yükleniyorsa butonu pasif yap
                    onPressed: controller.isLoading
                        ? null
                        : () async {
                            if (_formKey.currentState!.validate()) {
                              final bool loginBasarili = await controller
                                  .loginUser();
                              if (loginBasarili) {
                                // TODO: Ana sayfaya yönlendir
                                debugPrint('GİRİŞ BAŞARILI! (Consumer)');
                              }
                            }
                          },
                    child: const Text('Giriş Yap'),
                  ),
                  TextButton(
                    onPressed: controller.isLoading
                        ? null
                        : () {
                            // YENİ: Kayıt Ekranı'na yönlendir
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => RegisterScreen(),
                              ),
                            );
                          },
                    child: const Text('Hesabın yok mu? Kayıt Ol'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
