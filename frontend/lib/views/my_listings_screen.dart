import 'package:flutter/material.dart';
import 'package:flutter_application_1/controllers/listing_controller.dart';
import 'package:flutter_application_1/models/listing_model.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/views/edit_listing_screen.dart'; // YENİ EKLENDİ

class MyListingsScreen extends StatefulWidget {
  const MyListingsScreen({super.key});

  @override
  State<MyListingsScreen> createState() => _MyListingsScreenState();
}

class _MyListingsScreenState extends State<MyListingsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ListingController>(context, listen: false).fetchMyListings();
    });
  }

  @override
  Widget build(BuildContext context) {
    final listingController = Provider.of<ListingController>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('İlanlarım')),
      body: listingController.isLoading
          ? const Center(child: CircularProgressIndicator())
          : listingController.errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      listingController.errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                )
              : listingController.myListings.isEmpty
          ? const Center(child: Text('Henüz hiç ilan oluşturmamışsınız.'))
          : ListView.builder(
              itemCount: listingController.myListings.length,
              itemBuilder: (context, index) {
                final Listing listing = listingController.myListings[index];

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12.0,
                    vertical: 6.0,
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.shopping_bag_outlined),
                    title: Text(listing.title),
                    subtitle: Text('Fiyat: ${listing.price} TL'),

                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                // Seçilen ilanı düzenleme ekranına gönderiyoruz
                                builder: (context) =>
                                    EditListingScreen(listing: listing),
                              ),
                            );
                          },
                        ),

                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('İlanı Sil'),
                                content: const Text(
                                  'Bu ilanı silmek istediğinizden emin misiniz?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(ctx).pop(),
                                    child: const Text('İptal'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      listingController.deleteListing(
                                        listing.id,
                                      );
                                      Navigator.of(ctx).pop();
                                    },
                                    child: const Text(
                                      'Sil',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
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
