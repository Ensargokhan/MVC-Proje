import 'package:flutter/material.dart';

class AdminPanelScreen extends StatelessWidget {
  const AdminPanelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Paneli'),
        backgroundColor: Colors.indigo,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // 'onTap' içerdiği için 'const' yok
          ListTile(
            leading: const Icon(Icons.people_outline), // Bu 'const' geçerli
            title: const Text('Kullanıcıları Yönet'),
            subtitle: const Text(
              'Kullanıcı rollerini gör, yasakla veya düzenle.',
            ),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              // TODO: Kullanıcı listesi ekranını aç
            },
          ),
          const Divider(),

          ListTile(
            leading: const Icon(
              Icons.list_alt,
            ), // 'list_alt_error_outline' DÜZELTİLDİ
            title: const Text('İlanları Yönet (Moderasyon)'),
            subtitle: const Text('Tüm ilanları gör, onayla veya sil.'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              // TODO: Tüm ilanlar listesi ekranını aç
            },
          ),
          const Divider(),

          // 'onTap' içerdiği için 'const' yok
          ListTile(
            leading: const Icon(Icons.message_outlined),
            title: const Text('Mesaj Şablonlarını Yönet'),
            subtitle: const Text('Pazarlık şablonlarını ekle veya düzenle.'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              // TODO: Mesaj şablonu CRUD ekranını aç
            },
          ),
          const Divider(),
        ],
      ),
    );
  }
}
