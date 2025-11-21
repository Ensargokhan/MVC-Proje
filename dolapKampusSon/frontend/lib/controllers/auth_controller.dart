import 'package:flutter/foundation.dart';
import 'package:flutter_application_1/services/api_service.dart';
import 'package:image_picker/image_picker.dart';

class AuthController extends ChangeNotifier {
  final ApiService _apiService;
  AuthController({required ApiService apiService}) : _apiService = apiService;

  // ---------------------------------------------------------------------------
  // FORM ALANLARI
  // ---------------------------------------------------------------------------
  String email = '';
  String password = '';
  String name = '';
  double trustScore = 4.5;

  // ---------------------------------------------------------------------------
  // DURUM DEĞİŞKENLERİ
  // ---------------------------------------------------------------------------
  bool _isLoading = false;
  String? _errorMessage;
  bool _isAuthenticated = false;

  String? _userRole;
  int? _userId;
  String? _userEmail;
  String? _userName;
  String? _userAvatarUrl; // ⭐ Berat’tan eklendi

  final ImagePicker _picker = ImagePicker(); // ⭐ Berat’tan eklendi
  XFile? _selectedAvatar; // ⭐ Berat’tan eklendi

  // ---------------------------------------------------------------------------
  // GETTER'LAR
  // ---------------------------------------------------------------------------
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _isAuthenticated;

  String? get userRole => _userRole;
  int? get userId => _userId;
  String? get userEmail => _userEmail;
  String? get userName => _userName;
  String? get userAvatarUrl => _userAvatarUrl; // ⭐
  XFile? get selectedAvatar => _selectedAvatar; // ⭐

  // ---------------------------------------------------------------------------
  // FORM ALAN DEĞİŞTİRİCİLERİ
  // ---------------------------------------------------------------------------
  void onEmailChanged(String value) => email = value.trim();
  void onPasswordChanged(String value) => password = value.trim();
  void onNameChanged(String value) => name = value.trim();

  // ---------------------------------------------------------------------------
  // ⭐ AVATAR SEÇME
  // ---------------------------------------------------------------------------
  Future<void> pickAvatar() async {
    final XFile? picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      _selectedAvatar = picked;
      notifyListeners();
    }
  }

  void clearSelectedAvatar() {
    _selectedAvatar = null;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // LOGIN
  // ---------------------------------------------------------------------------
  Future<bool> loginUser() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _apiService.login(email, password);

      _isAuthenticated = true;
      _userRole = result['role'] as String? ?? 'user';
      _userId = result['id'] as int?;
      _userEmail = result['email'] as String?;
      _userName = result['name'] as String?;
      _userAvatarUrl = result['avatar_url'] as String?; // ⭐ Berat’tan

      name = _userName ?? name;
      email = _userEmail ?? email;

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isAuthenticated = false;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ---------------------------------------------------------------------------
  // REGISTER
  // ---------------------------------------------------------------------------
  Future<bool> registerUser() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _apiService.register(name: name, email: email, password: password);

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

  // ---------------------------------------------------------------------------
  // ⭐ PROFİL GÜNCELLEME (Berat’ın mantığı ile)
  // ---------------------------------------------------------------------------
  Future<bool> updateProfile() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      String? finalAvatarUrl = _userAvatarUrl;

      // ⭐ Avatar seçilmişse önce yükle
      if (_selectedAvatar != null) {
        finalAvatarUrl = await _apiService.uploadImage(_selectedAvatar!);
      }

      final updated = await _apiService.updateProfile(
        name: name.isNotEmpty ? name : null,
        avatarUrl: finalAvatarUrl,
      );

      // Güncel değerleri kaydet
      _userName = updated['name'] as String?;
      _userAvatarUrl = updated['avatar_url'] as String?;
      _selectedAvatar = null;

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ---------------------------------------------------------------------------
  // LOGIN DURUMU KONTROLÜ
  // ---------------------------------------------------------------------------
  Future<void> checkLoginStatus() async {
    final token = await _apiService.readToken();

    if (token != null && token.isNotEmpty) {
      _isAuthenticated = true;

      _userRole = await _apiService.readUserRole() ?? 'user';
      _userId = await _apiService.readUserId();
      _userEmail = await _apiService.readUserEmail();
      _userName = await _apiService.readUserName();
      _userAvatarUrl = await _apiService.readUserAvatar(); // ⭐

      name = _userName ?? name;
      email = _userEmail ?? email;
    } else {
      _isAuthenticated = false;
      _userRole = null;
      _userId = null;
      _userEmail = null;
      _userName = null;
      _userAvatarUrl = null;
    }

    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // LOGOUT
  // ---------------------------------------------------------------------------
  Future<void> logoutUser() async {
    await _apiService.logout();

    _isAuthenticated = false;
    _userRole = null;
    _userId = null;
    _userEmail = null;
    _userName = null;
    _userAvatarUrl = null;

    name = '';
    email = '';
    password = '';

    notifyListeners();
  }
}
