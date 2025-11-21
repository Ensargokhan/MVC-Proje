import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/controllers/auth_controller.dart';
import 'package:flutter_application_1/controllers/listing_controller.dart';
//
// HATA DÜZELTMESİ (Adım 86): 'packagepackage:' -> 'package:' olarak düzeltildi
//
import 'package:flutter_application_1/views/create_listing_screen.dart';
import 'package:flutter_application_1/views/profile_screen.dart';
import 'package:flutter_application_1/views/listing_detail_screen.dart';
import 'package:flutter_application_1/models/listing_model.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/views/admin_panel_screen.dart';
import 'package:flutter_application_1/views/my_messages_screen.dart';
// --- Hata Düzeltmesi Sonu ---

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ListingController>(context, listen: false).fetchListings();
    });
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    // Listenin sonuna gelindiğini kontrol et
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      // Zaten yüklenmiyorsa, daha fazla yükle
      if (!Provider.of<ListingController>(
        context,
        listen: false,
      ).isLoadingMore) {
        debugPrint('Listenin sonuna ulaşıldı. Daha fazla yükleniyor...');
        Provider.of<ListingController>(
          context,
          listen: false,
        ).loadMoreListings();
      }
    }
  }

  void _showFilterSheet(BuildContext context, ListingController controller) {
    // ... (Bu metot Adım 63'teki gibi aynı kalıyor)
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Filtrele ve Sırala',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  hint: const Text('Kategori Seçin'),
                  value: controller.selectedCategory,
                  items: controller.categories.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (value) {
                    controller.updateCategory(value);
                  },
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(
                          labelText: 'Min Fiyat (TL)',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        onChanged: (value) {
                          controller.updateMinPrice(value);
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(
                          labelText: 'Max Fiyat (TL)',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        onChanged: (value) {
                          controller.updateMaxPrice(value);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  hint: const Text('Sıralama Ölçütü'),
                  value: controller.sortBy,
                  items: controller.sortOptions.map((sortOption) {
                    return DropdownMenuItem(
                      value: sortOption,
                      child: Text(sortOption),
                    );
                  }).toList(),
                  onChanged: (value) {
                    controller.updateSortBy(value);
                  },
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  onPressed: () {
                    controller.fetchListings(
                      query: _searchController.text,
                      category: controller.selectedCategory,
                      minPrice: controller.minPrice,
                      maxPrice: controller.maxPrice,
                      sortBy: controller.sortBy,
                    );
                    Navigator.of(ctx).pop();
                  },
                  child: const Text('Filtreyi Uygula'),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final listingController = Provider.of<ListingController>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Campus Marketplace'),
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
        actions: [
          Consumer<AuthController>(
            builder: (context, auth, child) {
              if (auth.userRole == 'admin') {
                return IconButton(
                  icon: const Icon(Icons.admin_panel_settings),
                  tooltip: 'Admin Paneli',
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => AdminPanelScreen(),
                      ),
                    );
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
          IconButton(
            icon: const Icon(Icons.message_outlined),
            tooltip: 'Mesajlarım',
            onPressed: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (context) => const MyMessagesScreen()));
            },
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            tooltip: 'Profilim',
            onPressed: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (context) => ProfileScreen()));
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'İlanlarda Ara...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                    ),
                    onSubmitted: (query) {
                      listingController.fetchListings(
                        query: query,
                        category: listingController.selectedCategory,
                        minPrice: listingController.minPrice,
                        maxPrice: listingController.maxPrice,
                        sortBy: listingController.sortBy,
                      );
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.filter_list),
                  tooltip: 'Filtrele',
                  onPressed: () {
                    _showFilterSheet(context, listingController);
                  },
                ),
              ],
            ),
          ),
          if (listingController.errorMessage != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                listingController.errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          Expanded(
            child: listingController.isLoading
                ? const Center(child: CircularProgressIndicator())
                : listingController.listings.isEmpty
                    ? const Center(child: Text('Gösterilecek ilan bulunamadı.'))
                    : ListView.builder(
                        controller: _scrollController,
                        itemCount: listingController.listings.length + 1,
                        itemBuilder: (context, index) {
                          if (index == listingController.listings.length) {
                            return listingController.isLoadingMore
                                ? const Center(
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(vertical: 16.0),
                                      child: CircularProgressIndicator(),
                                    ),
                                  )
                                : const SizedBox.shrink();
                          }

                          final Listing listing =
                              listingController.listings[index];
                          return InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ListingDetailScreen(listing: listing),
                                ),
                              );
                            },
                            child: Card(
                              clipBehavior: Clip.hardEdge,
                              child: Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 12),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(14),
                                      child: Container(
                                        width: 96,
                                        height: 96,
                                        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(.6),
                                        child: listing.imageUrl != null && listing.imageUrl!.isNotEmpty
                                            ? Image.network(
                                                listing.imageUrl!,
                                                fit: BoxFit.cover,
                                                errorBuilder: (c, e, s) => const Icon(Icons.image_not_supported),
                                              )
                                            : const Icon(Icons.shopping_bag_outlined),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            listing.title,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            listing.description.isNotEmpty ? listing.description : 'Açıklama yok',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                                          ),
                                          const SizedBox(height: 10),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              if (listing.category != null)
                                                Chip(
                                                  label: Text(listing.category!),
                                                  padding: const EdgeInsets.symmetric(horizontal: 6),
                                                ),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                                decoration: BoxDecoration(
                                                  color: Theme.of(context).colorScheme.primaryContainer,
                                                  borderRadius: BorderRadius.circular(10),
                                                ),
                                                child: Text(
                                                  '${listing.price.toStringAsFixed(0)} TL',
                                                  style: TextStyle(
                                                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => CreateListingScreen()),
          );
        },
        tooltip: 'Yeni İlan Ekle',
        child: const Icon(Icons.add),
      ),
    );
  }
}
