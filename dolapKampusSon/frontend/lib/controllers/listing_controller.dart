import 'package:flutter/foundation.dart';
import 'package:flutter_application_1/controllers/message_controller.dart';
import 'package:flutter_application_1/models/listing_model.dart';
import 'package:flutter_application_1/services/api_service.dart';
import 'package:image_picker/image_picker.dart';

class ListingController extends ChangeNotifier {
  ListingController({required ApiService apiService})
      : _apiService = apiService;

  final ApiService _apiService;
  final ImagePicker _picker = ImagePicker();

  // ---------------------------------------------------------------------------
  // DURUM & FORM DEĞERLERİ
  // ---------------------------------------------------------------------------
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMorePages = false;
  String? _errorMessage;
  String _currentQuery = '';
  String? _selectedCategory;
  String? _sortBy;
  double? _minPrice;
  double? _maxPrice;
  int? _currentUserId;

  List<Listing> listings = [];
  List<Listing> myListings = [];
  final Map<int, MessageController> _conversationControllers = {};

  // Yeni ilan formu
  String newListingTitle = '';
  double newListingPrice = 0.0;
  String newListingDescription = '';
  String? newListingCategory;
  String? newListingLocation;
  String? newListingImageUrl;
  List<XFile> newListingImages = [];

  // GETTER'LAR
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get errorMessage => _errorMessage;
  String? get selectedCategory => _selectedCategory;
  String? get sortBy => _sortBy;
  double? get minPrice => _minPrice;
  double? get maxPrice => _maxPrice;
  final List<String> categories = ['Elektronik', 'Ders Kitabı', 'Ev Eşyası', 'Diğer'];
  final List<String> sortOptions = [
    'En Yeni İlanlar',
    'Fiyata Göre Artan',
    'Fiyata Göre Azalan',
  ];

  void updateSession({int? userId}) {
    _currentUserId = userId;
    if (userId == null) {
      myListings = [];
      notifyListeners();
    }
  }

  // ---------------------------------------------------------------------------
  // ARAMA & FİLTRELEME
  // ---------------------------------------------------------------------------
  void updateCategory(String? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void updateMinPrice(String value) {
    _minPrice = double.tryParse(value);
  }

  void updateMaxPrice(String value) {
    _maxPrice = double.tryParse(value);
  }

  void updateSortBy(String? value) {
    _sortBy = value;
    notifyListeners();
  }

  Future<void> fetchListings({
    String? query,
    String? category,
    double? minPrice,
    double? maxPrice,
    String? sortBy,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _currentQuery = query?.trim() ?? '';
    _selectedCategory = category;
    _minPrice = minPrice;
    _maxPrice = maxPrice;
    _sortBy = sortBy;
    notifyListeners();

    try {
      final fetched = await _apiService.getListings(
        category: category,
        minPrice: minPrice,
        maxPrice: maxPrice,
      );
      listings = _applyClientFilters(fetched);
      _hasMorePages = false;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<Listing> _applyClientFilters(List<Listing> source) {
    var result = List<Listing>.from(source);

    if (_currentQuery.isNotEmpty) {
      result = result
          .where(
            (l) =>
                l.title.toLowerCase().contains(_currentQuery.toLowerCase()) ||
                l.description.toLowerCase().contains(_currentQuery.toLowerCase()),
          )
          .toList();
    }

    switch (_sortBy) {
      case 'Fiyata Göre Artan':
        result.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'Fiyata Göre Azalan':
        result.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'En Yeni İlanlar':
        result.sort(
          (a, b) => (b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0))
              .compareTo(a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0)),
        );
        break;
      default:
        break;
    }
    return result;
  }

  Future<void> loadMoreListings() async {
    if (_isLoadingMore || !_hasMorePages) return;
    _isLoadingMore = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 300));
    _isLoadingMore = false;
    _hasMorePages = false;
    notifyListeners();
  }

  Future<void> fetchMyListings({bool showLoader = true}) async {
    if (showLoader) {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
    }
    try {
      final fetched = await _apiService.getListings();
      if (_currentUserId == null) {
        myListings = [];
      } else {
        myListings =
            fetched.where((listing) => listing.sellerId == _currentUserId).toList();
      }
      if (!showLoader) {
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      if (!showLoader) {
        notifyListeners();
      }
    } finally {
      if (showLoader) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  // ---------------------------------------------------------------------------
  // FORM ALANLARI VE CRUD
  // ---------------------------------------------------------------------------
  void onTitleChanged(String value) {
    newListingTitle = value.trim();
  }

  void onPriceChanged(String value) {
    newListingPrice = double.tryParse(value.trim()) ?? 0.0;
  }

  void onDescriptionChanged(String value) {
    newListingDescription = value.trim();
  }

  void onNewListingCategoryChanged(String? value) {
    newListingCategory = value;
    notifyListeners();
  }

  void onLocationChanged(String value) {
    newListingLocation = value.trim();
  }

  void onImageUrlChanged(String value) {
    newListingImageUrl = value.trim();
  }

  Future<void> pickImages() async {
    final picked = await _picker.pickMultiImage();
    if (picked.isNotEmpty) {
      newListingImages = picked;
      notifyListeners();
    }
  }

  Future<bool> submitListing() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _apiService.createListing(
        title: newListingTitle,
        price: newListingPrice,
        description: newListingDescription,
        category: newListingCategory,
        location: newListingLocation,
        imageUrl: newListingImageUrl,
        images: newListingImages,
      );
      await fetchListings(
        query: _currentQuery,
        category: _selectedCategory,
        minPrice: _minPrice,
        maxPrice: _maxPrice,
        sortBy: _sortBy,
      );
      await fetchMyListings(showLoader: false);
      _resetForm();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> deleteListing(int id) async {
    try {
      await _apiService.deleteListing(id);
      listings.removeWhere((listing) => listing.id == id);
      myListings.removeWhere((listing) => listing.id == id);
      notifyListeners();
      await fetchMyListings(showLoader: false);
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
    }
  }

  Future<bool> updateListing(
    int id,
    String title,
    double price,
    String description,
  ) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _apiService.updateListing(
        id: id,
        title: title,
        price: price,
        description: description,
      );
      await fetchListings(
        query: _currentQuery,
        category: _selectedCategory,
        minPrice: _minPrice,
        maxPrice: _maxPrice,
        sortBy: _sortBy,
      );
      await fetchMyListings(showLoader: false);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void _resetForm() {
    newListingTitle = '';
    newListingPrice = 0.0;
    newListingDescription = '';
    newListingCategory = null;
    newListingLocation = null;
    newListingImageUrl = null;
    newListingImages = [];
  }

  // ---------------------------------------------------------------------------
  // MESAJLAŞMA YARDIMCILARI (TODO)
  // ---------------------------------------------------------------------------
  MessageController getOrCreateConversation(Listing listing) {
    // Her zaman yeni MessageController oluştur - cache sorunlarını önlemek için
    // Eski conversation'lar farklı listing'ler için karışmasın diye
    return MessageController(apiService: _apiService, listing: listing);
  }
}
