import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_application_1/models/appointment_model.dart';
import 'package:flutter_application_1/models/conversation_model.dart';
import 'package:flutter_application_1/models/listing_model.dart';
import 'package:flutter_application_1/models/message_model.dart';
import 'package:flutter_application_1/models/message_template_model.dart';
import 'package:image_picker/image_picker.dart';

class ApiService {
  static const String _defaultBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://127.0.0.1:5000/api',
  );

  static const String _tokenKey = 'auth_token';
  static const String _roleKey = 'user_role';
  static const String _userIdKey = 'user_id';
  static const String _userEmailKey = 'user_email';
  static const String _userNameKey = 'user_name';
  static const String _userAvatarKey = 'user_avatar';

  final Dio _dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  ApiService({String? baseUrl}) : _dio = Dio() {
    _dio.options.baseUrl = baseUrl ?? _defaultBaseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 5);
    _dio.options.receiveTimeout = const Duration(seconds: 5);

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final bool isAuthLogin = options.path.contains('/auth/login');
          final bool isAuthRegister = options.path.contains('/auth/register');

          if (!(isAuthLogin || isAuthRegister)) {
            final token = await readToken();
            if (token != null) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          }

          debugPrint('REQ: ${options.method} ${options.uri}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          debugPrint('RES: ${response.statusCode}');
          return handler.next(response);
        },
        onError: (error, handler) {
          debugPrint('API ERROR: ${error.message}');
          return handler.next(error);
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // AUTH
  // ---------------------------------------------------------------------------
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );

      final data = response.data as Map<String, dynamic>;
      final token = data['token'] as String?;
      final user = (data['user'] as Map<String, dynamic>?) ?? {};
      final role = (data['role'] as String?) ?? 'user';

      if (token == null) {
        throw Exception("Token bulunamadı");
      }

      await _persistSession(token: token, role: role, user: user);

      return {
        'id': user['id'],
        'email': user['email'],
        'name': user['name'],
        'avatar_url': user['avatar_url'],
        'role': role,
      };
    } on DioException catch (e) {
      throw Exception(
        'Giriş başarısız: ${e.response?.data['error'] ?? e.message}',
      );
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      await _dio.post(
        '/auth/register',
        data: {'name': name, 'email': email, 'password': password},
      );
    } on DioException catch (e) {
      throw Exception(
        'Kayıt başarısız: ${e.response?.data['error'] ?? e.message}',
      );
    }
  }

  Future<void> logout() => clearSession();

  Future<void> _persistSession({
    required String token,
    required String role,
    required Map<String, dynamic> user,
  }) async {
    await _storage.write(key: _tokenKey, value: token);
    await _storage.write(key: _roleKey, value: role);

    if (user['id'] != null) {
      await _storage.write(key: _userIdKey, value: user['id'].toString());
    }
    if (user['email'] != null) {
      await _storage.write(key: _userEmailKey, value: user['email']);
    }
    if (user['name'] != null) {
      await _storage.write(key: _userNameKey, value: user['name']);
    }
    if (user['avatar_url'] != null) {
      await _storage.write(key: _userAvatarKey, value: user['avatar_url']);
    }
  }

  Future<void> clearSession() async {
    await Future.wait([
      _storage.delete(key: _tokenKey),
      _storage.delete(key: _roleKey),
      _storage.delete(key: _userIdKey),
      _storage.delete(key: _userEmailKey),
      _storage.delete(key: _userNameKey),
      _storage.delete(key: _userAvatarKey),
    ]);
  }

  // ---------------------------------------------------------------------------
  // IMAGE UPLOAD
  // ---------------------------------------------------------------------------
  Future<String> uploadImage(XFile file) async {
    try {
      final token = await readToken();
      final fileName = file.name;

      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          file.path,
          filename: fileName,
        ),
      });

      final response = await _dio.post(
        '/listings/upload',
        data: formData,
        queryParameters: token != null ? {'token': token} : null,
        options: Options(
          headers: token != null ? {'Authorization': 'Bearer $token'} : null,
          contentType: 'multipart/form-data',
        ),
      );

      return response.data['url'];
    } on DioException catch (e) {
      throw Exception(
        'Görsel yüklenemedi: ${e.response?.data['error'] ?? e.message}',
      );
    }
  }

  // ---------------------------------------------------------------------------
  // LISTINGS → (Arama + Filtreleme + Sıralama + Seller info)
  // ---------------------------------------------------------------------------
  Future<List<Listing>> getListings({
    String? query,
    String? category,
    double? minPrice,
    double? maxPrice,
    String? sortBy,
  }) async {
    try {
      final params = <String, dynamic>{};

      if (query != null && query.isNotEmpty) params['query'] = query;
      if (category != null && category.isNotEmpty) params['category'] = category;
      if (minPrice != null) params['min_price'] = minPrice;
      if (maxPrice != null) params['max_price'] = maxPrice;
      if (sortBy != null) params['sort'] = sortBy;

      final response = await _dio.get(
        '/listings/',
        queryParameters: params.isEmpty ? null : params,
      );

      return (response.data as List)
          .map((e) => Listing.fromJson(e))
          .toList();
    } catch (e) {
      throw Exception('Listeleme hatası: $e');
    }
  }

  Future<Listing> createListing({
    required String title,
    required double price,
    required String description,
    String? category,
    String? location,
    String? imageUrl,
    List<XFile>? images,
  }) async {
    try {
      String? finalImageUrl = imageUrl;
      if ((finalImageUrl == null || finalImageUrl.isEmpty) &&
          images != null &&
          images.isNotEmpty) {
        finalImageUrl = await uploadImage(images.first);
      }

      final response = await _dio.post(
        '/listings/create',
        data: {
          'title': title,
          'price': price,
          'description': description,
          'category': category,
          'location': location,
          'image_url': finalImageUrl,
        },
      );

      return Listing.fromJson(response.data['listing']);
    } on DioException catch (e) {
      throw Exception(
        'İlan oluşturulamadı: ${e.response?.data['error'] ?? e.message}',
      );
    }
  }

  Future<void> deleteListing(int id) async {
    try {
      await _dio.delete('/listings/delete/$id');
    } on DioException catch (e) {
      throw Exception(
        'İlan silinemedi: ${e.response?.data['error'] ?? e.message}',
      );
    }
  }

  Future<void> updateListing({
    required int id,
    required String title,
    required double price,
    required String description,
    String? category,
    String? location,
    String? imageUrl,
  }) async {
    try {
      await _dio.put(
        '/listings/update/$id',
        data: {
          'title': title,
          'price': price,
          'description': description,
          'category': category,
          'location': location,
          'image_url': imageUrl,
        },
      );
    } on DioException catch (e) {
      throw Exception(
        'İlan güncellenemedi: ${e.response?.data['error'] ?? e.message}',
      );
    }
  }

  // ---------------------------------------------------------------------------
  // PROFILE
  // ---------------------------------------------------------------------------
  Future<Map<String, dynamic>> updateProfile({
    String? name,
    String? avatarUrl,
  }) async {
    try {
      final token = await readToken();

      final response = await _dio.put(
        '/auth/profile',
        data: {
          'name': name,
          'avatar_url': avatarUrl,
        },
        options: Options(
          headers: token != null ? {'Authorization': 'Bearer $token'} : null,
        ),
      );

      final updated = response.data;

      if (updated['name'] != null) {
        await _storage.write(key: _userNameKey, value: updated['name']);
      }
      if (updated['avatar_url'] != null) {
        await _storage.write(key: _userAvatarKey, value: updated['avatar_url']);
      }

      return updated;
    } on DioException catch (e) {
      throw Exception(
        'Profil güncellenemedi: ${e.response?.data['error'] ?? e.message}',
      );
    }
  }

  // ---------------------------------------------------------------------------
  // MESAJLAŞMA & RANDEVU (Senin projenden tamamen korundu)
  // ---------------------------------------------------------------------------
  Future<List<MessageTemplate>> getMessageTemplates({String? category}) async {
    try {
      final response = await _dio.get(
        '/messages/templates',
        queryParameters: category == null ? null : {'category': category},
      );
      return (response.data as List)
          .map((e) => MessageTemplate.fromJson(e))
          .toList();
    } on DioException catch (e) {
      throw Exception(
        'Şablonlar alınamadı: ${e.response?.data['error'] ?? e.message}',
      );
    }
  }

  Future<Conversation> startConversation({
    required int listingId,
    required int sellerId,
  }) async {
    try {
      final response =
          await _dio.post('/messages/start/$listingId/$sellerId');
      return Conversation.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(
        'Sohbet başlatılamadı: ${e.response?.data['error'] ?? e.message}',
      );
    }
  }

  Future<Conversation> fetchConversation(int conversationId) async {
    try {
      final response = await _dio.get('/conversations/$conversationId');
      return Conversation.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(
        'Sohbet getirilemedi: ${e.response?.data['error'] ?? e.message}',
      );
    }
  }

  Future<List<Conversation>> getMyConversations() async {
    try {
      final response = await _dio.get('/conversations/my-conversations');
      return (response.data as List)
          .map((e) => Conversation.fromJson(e))
          .toList();
    } on DioException catch (e) {
      throw Exception(
        'Sohbetler alınamadı: ${e.response?.data['error'] ?? e.message}',
      );
    }
  }

  Future<void> deleteConversation(int conversationId) async {
    try {
      await _dio.delete('/conversations/$conversationId');
    } on DioException catch (e) {
      throw Exception(
        'Sohbet silinemedi: ${e.response?.data['error'] ?? e.message}',
      );
    }
  }

  Future<List<ConversationMessage>> getConversationHistory(
      int conversationId) async {
    try {
      final response =
          await _dio.get('/messages/history/$conversationId');
      return (response.data as List)
          .map((e) => ConversationMessage.fromJson(e))
          .toList();
    } on DioException catch (e) {
      throw Exception(
        'Mesaj geçmişi alınamadı: ${e.response?.data['error'] ?? e.message}',
      );
    }
  }

  Future<void> sendConversationMessage({
    required int conversationId,
    required int templateId,
    Map<String, dynamic>? params,
  }) async {
    try {
      await _dio.post(
        '/messages/send',
        data: {
          'conversation_id': conversationId,
          'template_id': templateId,
          'params': params,
        },
      );
    } on DioException catch (e) {
      throw Exception(
        'Mesaj gönderilemedi: ${e.response?.data['error'] ?? e.message}',
      );
    }
  }

  Future<Appointment> createAppointment({
    required int conversationId,
    required String date,
    required String time,
    required String location,
  }) async {
    try {
      final response = await _dio.post(
        '/appointments/create',
        data: {
          'conversation_id': conversationId,
          'date': date,
          'time': time,
          'location': location,
        },
      );
      return Appointment.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(
        'Randevu oluşturulamadı: ${e.response?.data['error'] ?? e.message}',
      );
    }
  }

  Future<Appointment> getAppointment(int conversationId) async {
    try {
      final response = await _dio.get(
        '/appointments/conversation/$conversationId',
      );
      return Appointment.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(
        'Randevu alınamadı: ${e.response?.data['error'] ?? e.message}',
      );
    }
  }

  Future<Conversation> approveAppointment(int conversationId) async {
    try {
      final response = await _dio.post(
        '/conversations/$conversationId/approve-appointment',
      );
      return Conversation.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(
        'Randevu onayı başarısız: ${e.response?.data['error'] ?? e.message}',
      );
    }
  }

  Future<Conversation> approveDelivery(int conversationId) async {
    try {
      final response = await _dio.post(
        '/conversations/$conversationId/approve-delivery',
      );
      return Conversation.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(
        'Teslimat onayı başarısız: ${e.response?.data['error'] ?? e.message}',
      );
    }
  }

  Future<Conversation> confirmDelivery(int conversationId) async {
    try {
      final response = await _dio.post(
        '/conversations/$conversationId/confirm-delivery',
      );
      return Conversation.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(
        'Teslimat onayı başarısız: ${e.response?.data['error'] ?? e.message}',
      );
    }
  }

  Future<Conversation> completeConversation(int conversationId) async {
    try {
      final response = await _dio.post(
        '/conversations/$conversationId/complete',
      );
      return Conversation.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(
        'Sohbet tamamlanamadı: ${e.response?.data['error'] ?? e.message}',
      );
    }
  }

  // ---------------------------------------------------------------------------
  // SECURE READ HELPERS
  // ---------------------------------------------------------------------------
  Future<String?> readToken() async {
    try {
      return await _storage.read(key: _tokenKey);
    } catch (e) {
      return null;
    }
  }

  Future<String?> readUserRole() async {
    try {
      return await _storage.read(key: _roleKey);
    } catch (e) {
      return null;
    }
  }

  Future<int?> readUserId() async {
    try {
      final value = await _storage.read(key: _userIdKey);
      return value == null ? null : int.tryParse(value);
    } catch (e) {
      return null;
    }
  }

  Future<String?> readUserEmail() async {
    return await _storage.read(key: _userEmailKey);
  }

  Future<String?> readUserName() async {
    return await _storage.read(key: _userNameKey);
  }

  Future<String?> readUserAvatar() async {
    return await _storage.read(key: _userAvatarKey);
  }
}
