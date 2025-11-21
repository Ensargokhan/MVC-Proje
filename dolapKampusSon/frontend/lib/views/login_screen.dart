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
    // Controller erişimi Consumer içinde yapılacak
    //

    return Scaffold(
      appBar: AppBar(
        title: const Text('Campus Marketplace'),
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
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Large logo above the card
                      Center(
                        child: Image.asset(
                          'assets/images/campus_marketplace_logo.png',
                          height: 220,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.shopping_bag_outlined, size: 56),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 480),
                        child: Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  'Sadece @selcuk.edu.tr uzantılı e-posta ile giriş yapılabilir.',
                                  style: TextStyle(color: Colors.grey[700]),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 20),
                                TextFormField(
                                  decoration: const InputDecoration(
                                    labelText: 'E-posta (@selcuk.edu.tr)',
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
                                const SizedBox(height: 16),
                                TextFormField(
                                  decoration: const InputDecoration(
                                    labelText: 'Şifre',
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
                                const SizedBox(height: 20),
                                if (controller.isLoading)
                                  const Center(
                                      child: CircularProgressIndicator())
                                else if (controller.errorMessage != null)
                                  Text(
                                    controller.errorMessage!,
                                    style: const TextStyle(
                                        color: Colors.red, fontSize: 16),
                                    textAlign: TextAlign.center,
                                  ),
                                const SizedBox(height: 12),
                                ElevatedButton(
                                  onPressed: controller.isLoading
                                      ? null
                                      : () async {
                                          if (_formKey.currentState!
                                              .validate()) {
                                            final bool loginBasarili =
                                                await controller.loginUser();
                                            if (loginBasarili) {
                                              debugPrint(
                                                  'GİRİŞ BAŞARILI! (Consumer)');
                                            }
                                          }
                                        },
                                  child: const Text('Giriş Yap'),
                                ),
                                TextButton(
                                  onPressed: controller.isLoading
                                      ? null
                                      : () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  RegisterScreen(),
                                            ),
                                          );
                                        },
                                  child: const Text(
                                      'Hesabın yok mu? Kayıt Ol'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
