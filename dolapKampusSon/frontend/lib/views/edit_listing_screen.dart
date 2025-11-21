import 'package:flutter/material.dart';
import 'package:flutter_application_1/controllers/listing_controller.dart';
import 'package:flutter_application_1/models/listing_model.dart';
import 'package:provider/provider.dart';

class EditListingScreen extends StatefulWidget {
  final Listing listing; // Düzenlenecek ilan
  const EditListingScreen({super.key, required this.listing});

  @override
  State<EditListingScreen> createState() => _EditListingScreenState();
}

class _EditListingScreenState extends State<EditListingScreen> {
  final _formKey = GlobalKey<FormState>();

  // Form alanları için kontrolcüler (Başlangıç verilerini tutmak için)
  late TextEditingController _titleController;
  late TextEditingController _priceController;
  late TextEditingController _descController;

  @override
  void initState() {
    super.initState();
    // Kontrolcüleri mevcut ilan bilgileriyle doldur
    _titleController = TextEditingController(text: widget.listing.title);
    _priceController = TextEditingController(
      text: widget.listing.price.toString(),
    );
    _descController = TextEditingController(text: widget.listing.description);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final listingController = Provider.of<ListingController>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('İlanı Düzenle')),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Fotoğraf Alanı (Şimdilik sadece ikon)
                Container(
                  height: 120,
                  width: double.infinity,
                  color: Colors.grey[200],
                  child: const Center(
                    child: Icon(Icons.photo, size: 50, color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 20),

                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'İlan Başlığı',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'Başlık zorunludur' : null,
                ),
                const SizedBox(height: 20),

                TextFormField(
                  controller: _priceController,
                  decoration: const InputDecoration(
                    labelText: 'Fiyat (TL)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                      value!.isEmpty ? 'Fiyat zorunludur' : null,
                ),
                const SizedBox(height: 20),

                TextFormField(
                  controller: _descController,
                  decoration: const InputDecoration(
                    labelText: 'Açıklama',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 4,
                ),
                const SizedBox(height: 30),

                ElevatedButton(
                  onPressed: listingController.isLoading
                      ? null
                      : () async {
                          if (_formKey.currentState!.validate()) {
                            // Controller'daki güncelleme metodunu çağır
                            final success = await listingController
                                .updateListing(
                                  widget.listing.id,
                                  _titleController.text,
                                  double.parse(_priceController.text),
                                  _descController.text,
                                );

                            if (success && context.mounted) {
                              Navigator.of(
                                context,
                              ).pop(); // Başarılıysa geri dön
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('İlan güncellendi!'),
                                ),
                              );
                            }
                          }
                        },
                  child: listingController.isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Değişiklikleri Kaydet'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
