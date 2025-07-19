import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user.dart';
import '../models/client.dart';
import '../models/appointment.dart';
import '../models/note.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:3000/api';
  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  
  late final Dio _dio;
  
  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
      },
    ));
    
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) {
        if (error.response?.statusCode == 401) {
          // Token expired, clear storage
          clearToken();
        }
        handler.next(error);
      },
    ));
  }

  // Token management
  Future<String?> getToken() async {
    return await _storage.read(key: 'auth_token');
  }

  Future<void> saveToken(String token) async {
    await _storage.write(key: 'auth_token', value: token);
  }

  Future<void> clearToken() async {
    await _storage.delete(key: 'auth_token');
  }

  // Authentication APIs
  Future<ApiResponse<User>> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String barNumber,
    String? firm,
    List<String>? specialization,
  }) async {
    try {
      final response = await _dio.post('/auth/register', data: {
        'name': name,
        'email': email,
        'password': password,
        'phone': phone,
        'barNumber': barNumber,
        'firm': firm,
        'specialization': specialization,
      });

      if (response.data['success']) {
        await saveToken(response.data['token']);
        return ApiResponse.success(User.fromJson(response.data['user']));
      } else {
        return ApiResponse.error(response.data['message']);
      }
    } on DioException catch (e) {
      return ApiResponse.error(_handleDioError(e));
    }
  }

  Future<ApiResponse<User>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });

      if (response.data['success']) {
        await saveToken(response.data['token']);
        return ApiResponse.success(User.fromJson(response.data['user']));
      } else {
        return ApiResponse.error(response.data['message']);
      }
    } on DioException catch (e) {
      return ApiResponse.error(_handleDioError(e));
    }
  }

  Future<ApiResponse<User>> getCurrentUser() async {
    try {
      final response = await _dio.get('/auth/me');
      
      if (response.data['success']) {
        return ApiResponse.success(User.fromJson(response.data['user']));
      } else {
        return ApiResponse.error(response.data['message']);
      }
    } on DioException catch (e) {
      return ApiResponse.error(_handleDioError(e));
    }
  }

  Future<ApiResponse<void>> logout() async {
    await clearToken();
    return ApiResponse.success(null);
  }

  // Client APIs
  Future<ApiResponse<List<Client>>> getClients({
    int page = 1,
    int limit = 10,
    String? search,
    String? status,
    String? caseType,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };
      
      if (search != null) queryParams['search'] = search;
      if (status != null) queryParams['status'] = status;
      if (caseType != null) queryParams['caseType'] = caseType;

      final response = await _dio.get('/clients', queryParameters: queryParams);
      
      if (response.data['success']) {
        final clients = (response.data['data'] as List)
            .map((json) => Client.fromJson(json))
            .toList();
        return ApiResponse.success(clients);
      } else {
        return ApiResponse.error(response.data['message']);
      }
    } on DioException catch (e) {
      return ApiResponse.error(_handleDioError(e));
    }
  }

  Future<ApiResponse<Client>> getClient(String id) async {
    try {
      final response = await _dio.get('/clients/$id');
      
      if (response.data['success']) {
        return ApiResponse.success(Client.fromJson(response.data['data']));
      } else {
        return ApiResponse.error(response.data['message']);
      }
    } on DioException catch (e) {
      return ApiResponse.error(_handleDioError(e));
    }
  }

  Future<ApiResponse<Client>> createClient(Map<String, dynamic> clientData) async {
    try {
      final response = await _dio.post('/clients', data: clientData);
      
      if (response.data['success']) {
        return ApiResponse.success(Client.fromJson(response.data['data']));
      } else {
        return ApiResponse.error(response.data['message']);
      }
    } on DioException catch (e) {
      return ApiResponse.error(_handleDioError(e));
    }
  }

  Future<ApiResponse<Client>> updateClient(String id, Map<String, dynamic> clientData) async {
    try {
      final response = await _dio.put('/clients/$id', data: clientData);
      
      if (response.data['success']) {
        return ApiResponse.success(Client.fromJson(response.data['data']));
      } else {
        return ApiResponse.error(response.data['message']);
      }
    } on DioException catch (e) {
      return ApiResponse.error(_handleDioError(e));
    }
  }

  Future<ApiResponse<void>> deleteClient(String id) async {
    try {
      final response = await _dio.delete('/clients/$id');
      
      if (response.data['success']) {
        return ApiResponse.success(null);
      } else {
        return ApiResponse.error(response.data['message']);
      }
    } on DioException catch (e) {
      return ApiResponse.error(_handleDioError(e));
    }
  }

  // Appointment APIs
  Future<ApiResponse<List<Appointment>>> getAppointments({
    int page = 1,
    int limit = 10,
    DateTime? startDate,
    DateTime? endDate,
    String? status,
    String? clientId,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };
      
      if (startDate != null) queryParams['startDate'] = startDate.toIso8601String();
      if (endDate != null) queryParams['endDate'] = endDate.toIso8601String();
      if (status != null) queryParams['status'] = status;
      if (clientId != null) queryParams['clientId'] = clientId;

      final response = await _dio.get('/appointments', queryParameters: queryParams);
      
      if (response.data['success']) {
        final appointments = (response.data['data'] as List)
            .map((json) => Appointment.fromJson(json))
            .toList();
        return ApiResponse.success(appointments);
      } else {
        return ApiResponse.error(response.data['message']);
      }
    } on DioException catch (e) {
      return ApiResponse.error(_handleDioError(e));
    }
  }

  Future<ApiResponse<List<Appointment>>> getCalendarAppointments({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final response = await _dio.get('/appointments/calendar', queryParameters: {
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
      });
      
      if (response.data['success']) {
        final appointments = (response.data['data'] as List)
            .map((json) => Appointment.fromJson(json))
            .toList();
        return ApiResponse.success(appointments);
      } else {
        return ApiResponse.error(response.data['message']);
      }
    } on DioException catch (e) {
      return ApiResponse.error(_handleDioError(e));
    }
  }

  Future<ApiResponse<Appointment>> createAppointment(Map<String, dynamic> appointmentData) async {
    try {
      final response = await _dio.post('/appointments', data: appointmentData);
      
      if (response.data['success']) {
        return ApiResponse.success(Appointment.fromJson(response.data['data']));
      } else {
        return ApiResponse.error(response.data['message']);
      }
    } on DioException catch (e) {
      return ApiResponse.error(_handleDioError(e));
    }
  }

  Future<ApiResponse<Appointment>> updateAppointment(String id, Map<String, dynamic> appointmentData) async {
    try {
      final response = await _dio.put('/appointments/$id', data: appointmentData);
      
      if (response.data['success']) {
        return ApiResponse.success(Appointment.fromJson(response.data['data']));
      } else {
        return ApiResponse.error(response.data['message']);
      }
    } on DioException catch (e) {
      return ApiResponse.error(_handleDioError(e));
    }
  }

  Future<ApiResponse<void>> deleteAppointment(String id) async {
    try {
      final response = await _dio.delete('/appointments/$id');
      
      if (response.data['success']) {
        return ApiResponse.success(null);
      } else {
        return ApiResponse.error(response.data['message']);
      }
    } on DioException catch (e) {
      return ApiResponse.error(_handleDioError(e));
    }
  }

  // Notes APIs
  Future<ApiResponse<List<Note>>> getNotes({
    int page = 1,
    int limit = 10,
    String? search,
    String? clientId,
    String? noteType,
    String? priority,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };
      
      if (search != null) queryParams['search'] = search;
      if (clientId != null) queryParams['clientId'] = clientId;
      if (noteType != null) queryParams['noteType'] = noteType;
      if (priority != null) queryParams['priority'] = priority;

      final response = await _dio.get('/notes', queryParameters: queryParams);
      
      if (response.data['success']) {
        final notes = (response.data['data'] as List)
            .map((json) => Note.fromJson(json))
            .toList();
        return ApiResponse.success(notes);
      } else {
        return ApiResponse.error(response.data['message']);
      }
    } on DioException catch (e) {
      return ApiResponse.error(_handleDioError(e));
    }
  }

  Future<ApiResponse<Note>> createNote(Map<String, dynamic> noteData) async {
    try {
      final response = await _dio.post('/notes', data: noteData);
      
      if (response.data['success']) {
        return ApiResponse.success(Note.fromJson(response.data['data']));
      } else {
        return ApiResponse.error(response.data['message']);
      }
    } on DioException catch (e) {
      return ApiResponse.error(_handleDioError(e));
    }
  }

  Future<ApiResponse<Note>> updateNote(String id, Map<String, dynamic> noteData) async {
    try {
      final response = await _dio.put('/notes/$id', data: noteData);
      
      if (response.data['success']) {
        return ApiResponse.success(Note.fromJson(response.data['data']));
      } else {
        return ApiResponse.error(response.data['message']);
      }
    } on DioException catch (e) {
      return ApiResponse.error(_handleDioError(e));
    }
  }

  Future<ApiResponse<void>> deleteNote(String id) async {
    try {
      final response = await _dio.delete('/notes/$id');
      
      if (response.data['success']) {
        return ApiResponse.success(null);
      } else {
        return ApiResponse.error(response.data['message']);
      }
    } on DioException catch (e) {
      return ApiResponse.error(_handleDioError(e));
    }
  }

  // File upload
  Future<ApiResponse<VoiceRecording>> uploadVoiceRecording(String noteId, File audioFile) async {
    try {
      final formData = FormData.fromMap({
        'voiceRecording': await MultipartFile.fromFile(audioFile.path),
      });

      final response = await _dio.post('/notes/$noteId/voice', data: formData);
      
      if (response.data['success']) {
        return ApiResponse.success(VoiceRecording.fromJson(response.data['data']));
      } else {
        return ApiResponse.error(response.data['message']);
      }
    } on DioException catch (e) {
      return ApiResponse.error(_handleDioError(e));
    }
  }

  String _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timeout. Please check your internet connection.';
      case DioExceptionType.badResponse:
        if (e.response?.data != null && e.response?.data['message'] != null) {
          return e.response!.data['message'];
        }
        return 'Server error occurred.';
      case DioExceptionType.cancel:
        return 'Request was cancelled.';
      case DioExceptionType.unknown:
        return 'Network error occurred. Please check your connection.';
      default:
        return 'An unexpected error occurred.';
    }
  }
}

class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? error;

  ApiResponse.success(this.data) : success = true, error = null;
  ApiResponse.error(this.error) : success = false, data = null;
}
