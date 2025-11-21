import 'package:flutter/foundation.dart';
import 'package:flutter_application_1/models/appointment_model.dart';
import 'package:flutter_application_1/models/conversation_model.dart';
import 'package:flutter_application_1/models/listing_model.dart';
import 'package:flutter_application_1/models/message_model.dart';
import 'package:flutter_application_1/models/message_template_model.dart';
import 'package:flutter_application_1/services/api_service.dart';

class MessageController extends ChangeNotifier {
  final ApiService _apiService;
  final Listing listing;

  Conversation? _conversation;
  Appointment? appointment;
  List<ConversationMessage> messages = [];
  List<MessageTemplate> priceTemplates = [];
  MessageTemplate? selectedTemplate;
  String? _errorMessage;
  bool _isBusy = false;
  int _currentStep = 1;
  int? _currentUserId;
  String priceInput = '';
  void _clearError() {
    _errorMessage = null;
  }

  // Randevu formu
  DateTime? selectedDay;
  DateTime focusedDay = DateTime.now();
  String? selectedTime;
  String? selectedLocation;

  final List<String> availableTimes = List.generate(16, (index) {
    final hour = 7 + index;
    return '${hour.toString().padLeft(2, '0')}:00';
  });

  final List<String> campusLocations = [
    'Merkezi Kütüphane',
    'Öğrenci Yemekhanesi',
    'Öğrenci Yurtları Girişi',
    'Kampüs AVM Girişi',
  ];

  // Geri bildirim
  double selectedRating = 0;
  String? selectedFeedbackTemplate;

  bool get isLoading => _isBusy;
  String? get errorMessage => _errorMessage;
  int get currentStep => _currentStep;
  Conversation? get conversation => _conversation;
  
  bool get isBuyer {
    if (_currentUserId == null || _conversation == null) return false;
    // Conversation'daki buyer_id ile kontrol et
    final result = _conversation!.buyerId == _currentUserId;
    debugPrint('isBuyer kontrolü: currentUserId=$_currentUserId, buyerId=${_conversation!.buyerId}, sellerId=${_conversation!.sellerId}, listingSellerId=${listing.sellerId}, result=$result');
    return result;
  }
  
  bool get isSeller {
    if (_currentUserId == null || _conversation == null) return false;
    // Hem conversation'daki seller_id hem de listing'deki seller_id ile kontrol et
    final result = _conversation!.sellerId == _currentUserId || 
                   (listing.sellerId != null && listing.sellerId == _currentUserId);
    debugPrint('isSeller kontrolü: currentUserId=$_currentUserId, buyerId=${_conversation!.buyerId}, sellerId=${_conversation!.sellerId}, listingSellerId=${listing.sellerId}, result=$result');
    return result;
  }
  
  bool get hasApprovedAppointment {
    if (_conversation == null || _currentUserId == null) return false;
    if (isBuyer) return _conversation!.buyerApprovedAppointment;
    if (isSeller) return _conversation!.sellerApprovedAppointment;
    return false;
  }
  
  bool get hasApprovedDelivery {
    if (_conversation == null || _currentUserId == null) return false;
    if (isBuyer) return _conversation!.buyerApprovedDelivery;
    if (isSeller) return _conversation!.sellerApprovedDelivery;
    return false;
  }
  
  bool get bothApprovedAppointment {
    if (_conversation == null) return false;
    return _conversation!.buyerApprovedAppointment && _conversation!.sellerApprovedAppointment;
  }
  
  bool get bothApprovedDelivery {
    if (_conversation == null) return false;
    return _conversation!.buyerApprovedDelivery && _conversation!.sellerApprovedDelivery;
  }

  MessageController({required ApiService apiService, required this.listing})
      : _apiService = apiService {
    _initialize();
  }

  Future<void> _initialize() async {
    _setBusy(true);
    try {
      _clearError();
      _currentUserId = await _apiService.readUserId();
      
      // ÖNEMLİ: Her zaman önce tüm state'i temizle
      // Farklı listing için conversation açılırken eski veriler karışmasın
      appointment = null;
      messages = [];
      _currentStep = 1;
      _conversation = null;
      
      await _loadTemplates();
      await _ensureConversation();
      
      // Conversation yüklendikten sonra, listing_id kontrolü yap
      if (_conversation != null && _conversation!.listingId != listing.id) {
        // Yanlış conversation - her şeyi temizle
        appointment = null;
        messages = [];
        _currentStep = 1;
        _conversation = null;
        throw Exception('Yanlış conversation döndü. Lütfen tekrar deneyin.');
      }
      
      // Sadece doğru conversation yüklendiyse mesajları ve appointment'ı yükle
      if (_conversation != null && _conversation!.listingId == listing.id) {
        await fetchMessages();
        await _fetchAppointment();
      }
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _setBusy(false);
      notifyListeners();
    }
  }

  Future<void> _loadTemplates() async {
    try {
      priceTemplates = await _apiService.getMessageTemplates(category: 'PRICE');
    } catch (e) {
      _errorMessage = 'Şablonlar alınamadı: $e';
    }
  }

  Future<void> _ensureConversation() async {
    if (listing.sellerId == null) {
      throw Exception('İlanın satıcı bilgisi bulunamadı.');
    }
    
    // ÖNEMLİ: Her zaman önce mevcut conversation'ı temizle
    // Farklı listing için conversation açılırken eski veriler karışmasın
    final oldListingId = _conversation?.listingId;
    if (oldListingId != null && oldListingId != listing.id) {
      // Farklı listing için conversation açılıyor - her şeyi temizle
      appointment = null;
      messages = [];
      _currentStep = 1;
      _conversation = null;
    }
    
    // Conversation'ı her zaman backend'den çek (cache sorunlarını önlemek için)
    _conversation = await _apiService.startConversation(
      listingId: listing.id,
      sellerId: listing.sellerId!,
    );
    
    // Conversation'ı refresh et (onay durumlarını güncellemek için)
    if (_conversation != null) {
      _conversation = await _apiService.fetchConversation(_conversation!.id);
      
      // KRİTİK KONTROL: Conversation'ın listing_id'si mevcut listing'in ID'si ile eşleşmeli
      // Eğer eşleşmiyorsa, bu yanlış bir conversation - her şeyi temizle ve hata fırlat
      if (_conversation!.listingId != listing.id) {
        appointment = null;
        messages = [];
        _currentStep = 1;
        _conversation = null;
        throw Exception('Yanlış conversation döndü. Lütfen tekrar deneyin.');
      }
      
      // Yeni conversation veya farklı listing için conversation açıldıysa,
      // mesajları ve appointment'ı sıfırla
      if (oldListingId == null || oldListingId != listing.id) {
        appointment = null;
        messages = [];
        _currentStep = 1;
      }
    }
    
    // Step'i güncelle
    _syncStepWithStage();
  }

  Future<void> fetchMessages() async {
    if (_conversation == null) return;
    try {
      messages = await _apiService.getConversationHistory(_conversation!.id);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
    }
  }

  Future<void> _fetchAppointment() async {
    if (_conversation == null) {
      appointment = null;
      _syncStepWithStage();
      return;
    }
    
    // ÖNEMLİ: Conversation'ın listing_id'si mevcut listing'in ID'si ile eşleşmeli
    // Eğer eşleşmiyorsa, bu yanlış bir conversation - appointment'ı null yap
    if (_conversation!.listingId != listing.id) {
      appointment = null;
      _syncStepWithStage();
      notifyListeners();
      return;
    }
    
    // Her zaman appointment'ı backend'den yükle
    // Eğer appointment yoksa null dönecek, bu normal
    try {
      appointment = await _apiService.getAppointment(_conversation!.id);
    } catch (e) {
      // Appointment yoksa null kalır, bu normal
      appointment = null;
    }
    _syncStepWithStage();
    notifyListeners();
  }

  void onTemplateChanged(MessageTemplate? template) {
    selectedTemplate = template;
    notifyListeners();
  }

  void onPriceParameterChanged(String value) {
    priceInput = value.trim();
  }

  Future<void> sendTemplateMessage({Map<String, dynamic>? params}) async {
    if (_conversation == null || selectedTemplate == null) return;
    _clearError();
    final payload = Map<String, dynamic>.from(params ?? {});
    if (selectedTemplate!.paramKeys.contains('price')) {
      payload['price'] = priceInput;
    }
    _setBusy(true);
    try {
      await _apiService.sendConversationMessage(
        conversationId: _conversation!.id,
        templateId: selectedTemplate!.id,
        params: payload.isEmpty ? null : payload,
      );
      selectedTemplate = null;
      priceInput = '';
      await fetchMessages();
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _setBusy(false);
    }
  }

  void onDaySelected(DateTime day, DateTime focusDay) {
    if (day.isBefore(DateTime.now())) return;
    selectedDay = day;
    focusedDay = focusDay;
    notifyListeners();
  }

  void updateTime(String? value) {
    selectedTime = value;
    notifyListeners();
  }

  void updateLocation(String? value) {
    selectedLocation = value;
    notifyListeners();
  }

  Future<void> submitAppointment() async {
    if (_conversation == null ||
        selectedDay == null ||
        selectedTime == null ||
        selectedLocation == null) {
      _errorMessage = 'Lütfen tarih, saat ve konumu seçin.';
      notifyListeners();
      return;
    }

    _setBusy(true);
    try {
      _clearError();
      // Randevuyu oluştur
      final created = await _apiService.createAppointment(
        conversationId: _conversation!.id,
        date: selectedDay!.toIso8601String(),
        time: selectedTime!,
        location: selectedLocation!,
      );
      // Appointment'ı set et
      appointment = created;
      // Conversation'ı refresh et
      await _refreshConversation();
      // Appointment'ı tekrar yükle (güncel hali için)
      await _fetchAppointment();
      // Form alanlarını temizle
      selectedDay = null;
      selectedTime = null;
      selectedLocation = null;
      // Step'i güncelle ve UI'ı yenile
      _syncStepWithStage();
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
    } finally {
      _setBusy(false);
      notifyListeners();
    }
  }

  void updateRating(double rating) {
    selectedRating = rating;
    notifyListeners();
  }

  void updateFeedbackTemplate(String? value) {
    selectedFeedbackTemplate = value;
    notifyListeners();
  }

  Future<void> approveAppointment() async {
    if (_conversation == null) return;
    _clearError();
    _setBusy(true);
    try {
      _conversation = await _apiService.approveAppointment(_conversation!.id);
      _syncStepWithStage();
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _setBusy(false);
    }
  }

  Future<void> approveDelivery() async {
    if (_conversation == null) return;
    _clearError();
    _setBusy(true);
    try {
      _conversation = await _apiService.approveDelivery(_conversation!.id);
      _syncStepWithStage();
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _setBusy(false);
    }
  }

  Future<void> submitDeliveryConfirmation() async {
    // Eski metod, artık approveDelivery kullanılacak
    return approveDelivery();
  }

  Future<void> submitFeedback() async {
    if (_conversation == null) return;
    if (selectedRating == 0 || selectedFeedbackTemplate == null) {
      _errorMessage = 'Lütfen puan ve yorum seçin.';
      notifyListeners();
      return;
    }
    _setBusy(true);
    try {
      _clearError();
      await _apiService.completeConversation(_conversation!.id);
      await _refreshConversation();
      selectedRating = 0;
      selectedFeedbackTemplate = null;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _setBusy(false);
    }
  }

  void showAppointmentForm() {
    // Randevu formunu göster - step'i 2'ye geçir ve form alanlarını sıfırla
    _currentStep = 2;
    // Form alanlarını sıfırla (yeni randevu için)
    selectedDay = null;
    selectedTime = null;
    selectedLocation = null;
    notifyListeners();
  }

  void backToMessages() {
    _currentStep = 1;
    notifyListeners();
  }

  bool isMessageMine(ConversationMessage message) {
    if (_currentUserId == null) return false;
    return message.senderId == _currentUserId;
  }

  String renderMessage(ConversationMessage message) {
    var text = message.template;
    message.params?.forEach((key, value) {
      text = text.replaceAll('[${key.toUpperCase()}]', value.toString());
    });
    return text;
  }

  Future<void> _refreshConversation() async {
    if (_conversation == null) return;
    _conversation = await _apiService.fetchConversation(_conversation!.id);
    _syncStepWithStage();
    notifyListeners();
  }

  void _syncStepWithStage() {
    if (_conversation == null) {
      _currentStep = 1;
      return;
    }
    
    // KRİTİK KONTROL: Conversation'ın listing_id'si mevcut listing'in ID'si ile eşleşmeli
    // Eğer eşleşmiyorsa, bu yanlış bir conversation - her şeyi temizle ve step'i 1'e geç
    if (_conversation!.listingId != listing.id) {
      // Yanlış conversation - her şeyi temizle
      appointment = null;
      messages = [];
      _currentStep = 1;
      _conversation = null;
      return;
    }
    
    final stage = _conversation!.stage;
    
    // ÖNCE: Randevu oluşturulmuşsa (appointment varsa), step 2'ye geç
    // Bu kontrol stage'den önce yapılmalı çünkü randevu oluşturulduktan sonra
    // stage hala PRICE_NEGOTIATION olabilir ama appointment varsa step 2'de olmalıyız
    // AMA: Appointment'ın da bu conversation'a ait olduğundan emin ol
    if (appointment != null) {
      // Randevu var ama henüz her iki taraf da onaylamamışsa step 2'de kal
      if (!bothApprovedAppointment && stage != 'APPOINTMENT_CONFIRMED') {
        _currentStep = 2;
        return;
      }
      // Her iki taraf da onayladıysa step 3'e geç
      if (bothApprovedAppointment || stage == 'APPOINTMENT_CONFIRMED') {
        _currentStep = 3;
        return;
      }
    }
    
    // Yeni conversation veya fiyat pazarlığı aşaması - randevu yoksa step 1
    if (stage == 'PRICE_NEGOTIATION' || stage.isEmpty) {
      // Yeni conversation'da appointment olmamalı - eğer varsa null yap
      if (appointment != null) {
        appointment = null;
      }
      // Randevu yoksa step 1'e geç
      // Ama eğer kullanıcı randevu formunu açtıysa (step 2'deyse), step'i değiştirme
      if (_currentStep != 2) {
        _currentStep = 1;
      }
      return;
    }
    
    switch (stage) {
      case 'APPOINTMENT_CONFIRMED':
        _currentStep = 3;
        break;
      case 'DELIVERY_CONFIRMED':
        // Teslimat onaylandı ama henüz her iki taraf da onaylamamışsa step 3'te kal
        if (!bothApprovedDelivery) {
          _currentStep = 3;
        } else {
          _currentStep = 4;
        }
        break;
      case 'COMPLETED':
        _currentStep = 4;
        break;
      default:
        // Güvenli fallback: Randevu yoksa step 1, varsa step 2
        if (appointment == null) {
          _currentStep = 1;
        } else {
          _currentStep = 2;
        }
    }
  }

  void _setBusy(bool value) {
    _isBusy = value;
    notifyListeners();
  }
}
