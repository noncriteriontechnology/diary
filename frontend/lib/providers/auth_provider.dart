import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  User? _user;
  bool _isLoading = false;
  String? _error;
  bool _isAuthenticated = false;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _isAuthenticated;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String barNumber,
    String? firm,
    List<String>? specialization,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await _apiService.register(
        name: name,
        email: email,
        password: password,
        phone: phone,
        barNumber: barNumber,
        firm: firm,
        specialization: specialization,
      );

      if (response.success && response.data != null) {
        _user = response.data;
        _isAuthenticated = true;
        notifyListeners();
        return true;
      } else {
        _setError(response.error ?? 'Registration failed');
        return false;
      }
    } catch (e) {
      _setError('An unexpected error occurred during registration');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await _apiService.login(
        email: email,
        password: password,
      );

      if (response.success && response.data != null) {
        _user = response.data;
        _isAuthenticated = true;
        notifyListeners();
        return true;
      } else {
        _setError(response.error ?? 'Login failed');
        return false;
      }
    } catch (e) {
      _setError('An unexpected error occurred during login');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    _setLoading(true);
    
    try {
      await _apiService.logout();
      _user = null;
      _isAuthenticated = false;
      _error = null;
      notifyListeners();
    } catch (e) {
      _setError('Error during logout');
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> checkAuthStatus() async {
    _setLoading(true);
    
    try {
      final token = await _apiService.getToken();
      if (token == null) {
        _isAuthenticated = false;
        return false;
      }

      final response = await _apiService.getCurrentUser();
      if (response.success && response.data != null) {
        _user = response.data;
        _isAuthenticated = true;
        notifyListeners();
        return true;
      } else {
        _isAuthenticated = false;
        await _apiService.clearToken();
        return false;
      }
    } catch (e) {
      _isAuthenticated = false;
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateProfile({
    String? name,
    String? phone,
    String? firm,
    List<String>? specialization,
  }) async {
    if (_user == null) return false;

    _setLoading(true);
    _setError(null);

    try {
      // This would require implementing the update profile API endpoint
      // For now, we'll update locally
      _user = _user!.copyWith(
        name: name ?? _user!.name,
        phone: phone ?? _user!.phone,
        firm: firm ?? _user!.firm,
        specialization: specialization ?? _user!.specialization,
      );
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to update profile');
      return false;
    } finally {
      _setLoading(false);
    }
  }
}
