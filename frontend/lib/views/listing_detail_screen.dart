import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/listing_model.dart';
import 'package:flutter_application_1/views/message_screen.dart';
import 'package:flutter_application_1/controllers/message_controller.dart';
import 'package:flutter_application_1/services/api_service.dart';
import 'package:flutter_application_1/controllers/listing_controller.dart';
import 'package:flutter_application_1/controllers/auth_controller.dart';
import 'package:provider/provider.dart';

class ListingDetailScreen extends StatelessWidget {
  final Listing listing;
  const ListingDetailScreen({super.key, required this.listing});

  @override
  Widget build(BuildContext context) {
    final listingController =
        Provider.of<ListingController>(context, listen: false);

    final authController =
        Provider.of<AuthController>(context, listen: false);

    final isOwner = authController.userId != null &&
        listing.sellerId != null &&
        authController.userId == listing.sellerId;

    return Scaffold(
      appBar: AppBar(title: Text(listing.title)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---------------------------------------------------------
            // ⭐ 1. FOTOĞRAF ALANI (Berat'ın geliştirilmiş versiyonu)
            // ---------------------------------------------------------
            AspectRatio(
              aspectRatio: 16 / 9,
              child: (listing.imageUrl != null &&
                      listing.imageUrl!.isNotEmpty)
                  ? Image.network(
                      listing.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child: const Center(
                            child:
                                Icon(Icons.broken_image, size: 50, color: Colors.grey),
                          ),
                        );
                      },
                    )
                  : Container(
                      color: Colors.grey[300],
                      child: const Center(
                        child: Icon(Icons.photo_camera,
                            size: 50, color: Colors.grey),
                      ),
                    ),
            ),
            const SizedBox(height: 20),

            // ---------------------------------------------------------
            // ⭐ 2. FİYAT
            // ---------------------------------------------------------
            Text(
              '${listing.price} TL',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 10),

            // ---------------------------------------------------------
            // ⭐ 3. AÇIKLAMA
            // ---------------------------------------------------------
            Text(
              listing.description.isNotEmpty
                  ? listing.description
                  : "Satıcı bu ilan için bir açıklama girmemiş.",
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 20),
            const Divider(),

            // ---------------------------------------------------------
            // ⭐ 4. SATICI BİLGİLERİ (Berat'ın geliştirmesi)
            // ---------------------------------------------------------
            ListTile(
              leading: (listing.sellerAvatarUrl != null &&
                      listing.sellerAvatarUrl!.isNotEmpty)
                  ? CircleAvatar(
                      radius: 22,
                      backgroundImage: NetworkImage(listing.sellerAvatarUrl!),
                    )
                  : const Icon(Icons.account_circle, size: 38),
              title: const Text(
                "Satıcı",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                listing.sellerName ?? "Satıcı adı bulunamadı.",
              ),
            ),
            const Divider(),

            const Spacer(),

            // ---------------------------------------------------------
            // ⭐ 5. MESAJ BUTONU — SADECE İLAN SAHİBİ OLMAYANLARDA
            // ---------------------------------------------------------
            if (!isOwner)
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: () {
                  final msgController =
                      listingController.getOrCreateConversation(listing);

                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ChangeNotifierProvider.value(
                        value: msgController,
                        child: MessageScreen(),
                      ),
                    ),
                  );
                },
                child: const Text("Satıcıyla İletişime Geç"),
              ),
          ],
        ),
      ),
    );
  }
}
