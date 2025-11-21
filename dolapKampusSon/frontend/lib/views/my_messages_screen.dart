import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/services/api_service.dart';
import 'package:flutter_application_1/models/conversation_model.dart';
import 'package:flutter_application_1/models/listing_model.dart';
import 'package:flutter_application_1/controllers/listing_controller.dart';
import 'package:flutter_application_1/controllers/message_controller.dart';
import 'package:flutter_application_1/views/message_screen.dart';
import 'package:flutter_application_1/theme/app_colors.dart';

class MyMessagesScreen extends StatefulWidget {
  const MyMessagesScreen({super.key});

  @override
  State<MyMessagesScreen> createState() => _MyMessagesScreenState();
}

class _MyMessagesScreenState extends State<MyMessagesScreen> {
  List<Conversation> _conversations = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  Future<void> _loadConversations() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final conversations = await apiService.getMyConversations();
      
      // Her conversation için listing bilgisini çek
      final listingController = Provider.of<ListingController>(context, listen: false);
      await listingController.fetchListings();
      
      setState(() {
        _conversations = conversations;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Listing _getListingForConversation(Conversation conversation) {
    final listingController = Provider.of<ListingController>(context, listen: false);
    try {
      return listingController.listings.firstWhere(
        (listing) => listing.id == conversation.listingId,
      );
    } catch (e) {
      // İlan bulunamadıysa placeholder döndür
      return Listing(
        id: conversation.listingId,
        title: 'İlan bulunamadı',
        price: 0,
        description: '',
        sellerId: conversation.sellerId,
      );
    }
  }

  String _getStageText(String stage) {
    switch (stage) {
      case 'PRICE_NEGOTIATION':
        return 'Fiyat Pazarlığı';
      case 'APPOINTMENT_CONFIRMED':
        return 'Randevu Onaylandı';
      case 'DELIVERY_CONFIRMED':
        return 'Teslimat Onaylandı';
      case 'COMPLETED':
        return 'Tamamlandı';
      default:
        return stage;
    }
  }

  Color _getStageColor(String stage) {
    switch (stage) {
      case 'PRICE_NEGOTIATION':
        return Colors.blue;
      case 'APPOINTMENT_CONFIRMED':
        return AppColors.infoText; // label text color; background handled below
      case 'DELIVERY_CONFIRMED':
        return Colors.green;
      case 'COMPLETED':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mesajlarım'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _loadConversations,
                        child: const Text('Yeniden Dene'),
                      ),
                    ],
                  ),
                )
              : _conversations.isEmpty
                  ? const Center(
                      child: Text(
                        'Henüz mesajınız yok.',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadConversations,
                      child: ListView.builder(
                        itemCount: _conversations.length,
                        itemBuilder: (context, index) {
                          final conversation = _conversations[index];
                          final listing = _getListingForConversation(conversation);
                          
                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: ListTile(
                              leading: const Icon(Icons.message),
                              title: Text(
                                listing.title,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Fiyat: ${listing.price} TL'),
                                  const SizedBox(height: 4),
                                  Chip(
                                    label: Text(
                                      _getStageText(conversation.stage),
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    backgroundColor: conversation.stage == 'APPOINTMENT_CONFIRMED'
                                        ? AppColors.infoBackground
                                        : _getStageColor(conversation.stage).withOpacity(0.2),
                                    labelStyle: TextStyle(
                                      color: conversation.stage == 'APPOINTMENT_CONFIRMED'
                                          ? AppColors.infoText
                                          : _getStageColor(conversation.stage),
                                    ),
                                  ),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () async {
                                      // Silme onayı
                                      final confirmed = await showDialog<bool>(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text('Sohbeti Sil'),
                                          content: const Text('Bu sohbeti silmek istediğinize emin misiniz?'),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.of(context).pop(false),
                                              child: const Text('İptal'),
                                            ),
                                            TextButton(
                                              onPressed: () => Navigator.of(context).pop(true),
                                              child: const Text('Sil', style: TextStyle(color: Colors.red)),
                                            ),
                                          ],
                                        ),
                                      );
                                      
                                      if (confirmed == true && mounted) {
                                        try {
                                          final apiService = Provider.of<ApiService>(context, listen: false);
                                          await apiService.deleteConversation(conversation.id);
                                          // Listeyi yenile
                                          _loadConversations();
                                          if (mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(content: Text('Sohbet silindi')),
                                            );
                                          }
                                        } catch (e) {
                                          if (mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text('Hata: ${e.toString().replaceFirst('Exception: ', '')}'),
                                                backgroundColor: Colors.red,
                                              ),
                                            );
                                          }
                                        }
                                      }
                                    },
                                  ),
                                  const Icon(Icons.arrow_forward_ios),
                                ],
                              ),
                              onTap: () async {
                                // Listing'i yükle ve MessageScreen'i aç
                                final listingController = Provider.of<ListingController>(context, listen: false);
                                await listingController.fetchListings();
                                final updatedListing = listingController.listings.firstWhere(
                                  (l) => l.id == listing.id,
                                  orElse: () => listing,
                                );
                                
                                final apiService = Provider.of<ApiService>(context, listen: false);
                                final messageController = MessageController(
                                  apiService: apiService,
                                  listing: updatedListing,
                                );
                                
                                if (mounted) {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => ChangeNotifierProvider.value(
                                        value: messageController,
                                        child: MessageScreen(),
                                      ),
                                    ),
                                  );
                                }
                              },
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}

