import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/controllers/auth_controller.dart';
import 'package:provider/provider.dart';

class EditProfileScreen extends StatelessWidget {
  EditProfileScreen({super.key});

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profili Düzenle')),
      body: Consumer<AuthController>(
        builder: (context, controller, child) {
          // Avatar önizleme
          ImageProvider? previewImageProvider;

          if (controller.selectedAvatar != null) {
            previewImageProvider =
                Image.file(File(controller.selectedAvatar!.path)).image;
          } else if (controller.userAvatarUrl != null &&
              controller.userAvatarUrl!.isNotEmpty) {
            previewImageProvider = NetworkImage(controller.userAvatarUrl!);
          }

          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // --------------------------------------------------------
                // ⭐ Profil Fotoğrafı (Avatar)
                // --------------------------------------------------------
                Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey[300],
                        backgroundImage: previewImageProvider,
                        child: previewImageProvider == null
                            ? const Icon(Icons.account_circle,
                                size: 100, color: Colors.grey)
                            : null,
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: controller.pickAvatar,
                        icon: const Icon(Icons.photo),
                        label: const Text("Profil Fotoğrafı Seç"),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // --------------------------------------------------------
                // ⭐ İsim Değiştirme
                // --------------------------------------------------------
                TextFormField(
                  initialValue: controller.name,
                  decoration: const InputDecoration(
                    labelText: 'Ad Soyad',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: controller.onNameChanged,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Ad Soyad alanı zorunludur.';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 30),

                if (controller.isLoading)
                  const Center(child: CircularProgressIndicator())
                else if (controller.errorMessage != null)
                  Text(
                    controller.errorMessage!,
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),

                const SizedBox(height: 20),

                // --------------------------------------------------------
                // ⭐ Kaydet Butonu
                // --------------------------------------------------------
                ElevatedButton(
                  onPressed: controller.isLoading
                      ? null
                      : () async {
                          if (_formKey.currentState!.validate()) {
                            final ok = await controller.updateProfile();
                            if (ok && context.mounted) {
                              Navigator.of(context).pop();
                            }
                          }
                        },
                  child: const Text('Değişiklikleri Kaydet'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
