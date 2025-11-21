import 'package:flutter/material.dart';
import 'package:flutter_application_1/controllers/listing_controller.dart';
import 'package:provider/provider.dart';
import 'dart:io'; // YENİ EKLENDİ (File tipi için)

class CreateListingScreen extends StatelessWidget {
  CreateListingScreen({super.key});

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yeni İlan Oluştur'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.primaryContainer,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Consumer<ListingController>(
        builder: (context, controller, child) {
          return Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    //
                    // YENİ EKLENDİ (Adım 59.3): Fotoğraf Ekleme Alanı
                    //
                    Container(
                      height: 120,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          // Fotoğraf Ekle Butonu
                          InkWell(
                            onTap: () {
                              controller.pickImages(); // Galeriyi aç
                            },
                            child: Container(
                              width: 100,
                              height: 120,
                              color: Colors.grey[200],
                              child: const Center(
                                child: Icon(
                                  Icons.add_a_photo,
                                  size: 40,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ),
                          // Seçilen Fotoğrafların Önizlemesi
                          Expanded(
                            child: controller.newListingImages.isEmpty
                                ? const Center(
                                    child: Text('Fotoğraf seçilmedi'),
                                  )
                                : ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount:
                                        controller.newListingImages.length,
                                    itemBuilder: (ctx, index) {
                                      return Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        // 'XFile' tipini 'File' tipine çevirip gösteriyoruz
                                        child: Image.file(
                                          File(
                                            controller
                                                .newListingImages[index]
                                                .path,
                                          ),
                                          width: 100,
                                          height: 100,
                                          fit: BoxFit.cover,
                                        ),
                                      );
                                    },
                                  ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),

                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Kategori',
                        border: OutlineInputBorder(),
                      ),
                      value: controller.newListingCategory,
                      items: controller.categories
                          .map(
                            (category) => DropdownMenuItem(
                              value: category,
                              child: Text(category),
                            ),
                          )
                          .toList(),
                      onChanged: controller.onNewListingCategoryChanged,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'İlan Başlığı',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: controller.onTitleChanged,
                      validator: (value) {
                        /* ... (Validator aynı) ... */
                        if (value == null || value.isEmpty) {
                          return 'Başlık zorunludur.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Fiyat (TL)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: controller.onPriceChanged,
                      validator: (value) {
                        /* ... (Validator aynı) ... */
                        if (value == null || value.isEmpty) {
                          return 'Fiyat zorunludur.';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Geçerli bir sayı girin.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Açıklama',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 4,
                      onChanged: controller.onDescriptionChanged,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Konum (isteğe bağlı)',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: controller.onLocationChanged,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Vitrin Fotoğrafı URL (isteğe bağlı)',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: controller.onImageUrlChanged,
                    ),
                    const SizedBox(height: 30),

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
                      onPressed: controller.isLoading
                          ? null
                          : () async {
                              if (_formKey.currentState!.validate()) {
                                final bool ilanBasarili = await controller
                                    .submitListing();
                                if (ilanBasarili) {
                                  if (context.mounted) {
                                    Navigator.of(context).pop();
                                  }
                                }
                              }
                            },
                      child: const Text('İlanı Yayınla'),
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
