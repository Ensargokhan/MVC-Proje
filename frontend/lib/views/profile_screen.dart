import 'package:flutter/material.dart';
import 'package:flutter_application_1/controllers/auth_controller.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/views/edit_profile_screen.dart';
import 'package:flutter_application_1/views/my_listings_screen.dart';
import 'package:flutter_application_1/views/my_messages_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profilim')),
      body: Consumer<AuthController>(
        builder: (context, controller, child) {
          final String userName = controller.userName ?? controller.name;
          final String userEmail = controller.userEmail ?? controller.email;
          final double trustScore = controller.trustScore;

          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // --------------------------------------------------------
                  // ⭐ PROFİL FOTOĞRAFI (Berat'ın avatar desteği)
                  // --------------------------------------------------------
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey[300],
                    backgroundImage: controller.userAvatarUrl != null &&
                            controller.userAvatarUrl!.isNotEmpty
                        ? NetworkImage(controller.userAvatarUrl!)
                        : null,
                    child: (controller.userAvatarUrl == null ||
                            controller.userAvatarUrl!.isEmpty)
                        ? const Icon(Icons.account_circle,
                            size: 100, color: Colors.grey)
                        : null,
                  ),

                  const SizedBox(height: 20),

                  // --------------------------------------------------------
                  // ⭐ Kullanıcı adı
                  // --------------------------------------------------------
                  Text(
                    userName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  // --------------------------------------------------------
                  // ⭐ E-posta
                  // --------------------------------------------------------
                  Text(
                    userEmail,
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),

                  const SizedBox(height: 30),
                  const Divider(),

                  // --------------------------------------------------------
                  // ⭐ Güven Puanı
                  // --------------------------------------------------------
                  ListTile(
                    leading: const Icon(Icons.star_border, color: Colors.amber),
                    title: const Text('Güven Puanı (Trust Score)'),
                    subtitle: Text('$trustScore / 5.0'),
                  ),

                  // --------------------------------------------------------
                  // ⭐ İlanlarım
                  // --------------------------------------------------------
                  ListTile(
                    leading: const Icon(Icons.list_alt),
                    title: const Text('İlanlarım'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const MyListingsScreen(),
                        ),
                      );
                    },
                  ),
                  const Divider(),

                  // --------------------------------------------------------
                  // ⭐ Mesajlarım
                  // --------------------------------------------------------
                  ListTile(
                    leading: const Icon(Icons.message),
                    title: const Text('Mesajlarım'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const MyMessagesScreen(),
                        ),
                      );
                    },
                  ),

                  const Divider(),
                  const Spacer(),

                  // --------------------------------------------------------
                  // ⭐ Profili Düzenle
                  // --------------------------------------------------------
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => EditProfileScreen(),
                        ),
                      );
                    },
                    child: const Text('Profili Düzenle'),
                  ),

                  const SizedBox(height: 10),

                  // --------------------------------------------------------
                  // ⭐ Çıkış Yap
                  // --------------------------------------------------------
                  TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                      controller.logoutUser();
                    },
                    child: const Text('Çıkış Yap'),
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
