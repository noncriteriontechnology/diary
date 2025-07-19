import 'package:flutter/foundation.dart';
import '../models/client.dart';
import '../services/api_service.dart';

class ClientProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<Client> _clients = [];
  bool _isLoading = false;
  String? _error;
  int _currentPage = 1;
  bool _hasMoreData = true;

  List<Client> get clients => _clients;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasMoreData => _hasMoreData;

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

  Future<void> loadClients({
    bool refresh = false,
    String? search,
    String? status,
    String? caseType,
  }) async {
    if (refresh) {
      _currentPage = 1;
      _hasMoreData = true;
      _clients.clear();
    }

    if (!_hasMoreData || _isLoading) return;

    _setLoading(true);
    _setError(null);

    try {
      final response = await _apiService.getClients(
        page: _currentPage,
        limit: 20,
        search: search,
        status: status,
        caseType: caseType,
      );

      if (response.success && response.data != null) {
        if (refresh) {
          _clients = response.data!;
        } else {
          _clients.addAll(response.data!);
        }
        
        _currentPage++;
        _hasMoreData = response.data!.length == 20; // If we got less than limit, no more data
        notifyListeners();
      } else {
        _setError(response.error ?? 'Failed to load clients');
      }
    } catch (e) {
      _setError('An unexpected error occurred while loading clients');
    } finally {
      _setLoading(false);
    }
  }

  Future<Client?> getClient(String id) async {
    try {
      final response = await _apiService.getClient(id);
      if (response.success && response.data != null) {
        return response.data;
      } else {
        _setError(response.error ?? 'Failed to load client');
        return null;
      }
    } catch (e) {
      _setError('An unexpected error occurred while loading client');
      return null;
    }
  }

  Future<bool> createClient({
    required String name,
    String? email,
    required String phone,
    String? alternatePhone,
    Map<String, String>? address,
    required String caseType,
    String? caseNumber,
    String? caseDescription,
    String status = 'Active',
    String priority = 'Medium',
    double? retainerFee,
    double? hourlyRate,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final clientData = {
        'name': name,
        'email': email,
        'phone': phone,
        'alternatePhone': alternatePhone,
        'address': address,
        'caseType': caseType,
        'caseNumber': caseNumber,
        'caseDescription': caseDescription,
        'status': status,
        'priority': priority,
        'retainerFee': retainerFee,
        'hourlyRate': hourlyRate,
      };

      final response = await _apiService.createClient(clientData);

      if (response.success && response.data != null) {
        _clients.insert(0, response.data!);
        notifyListeners();
        return true;
      } else {
        _setError(response.error ?? 'Failed to create client');
        return false;
      }
    } catch (e) {
      _setError('An unexpected error occurred while creating client');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateClient(String id, Map<String, dynamic> updates) async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await _apiService.updateClient(id, updates);

      if (response.success && response.data != null) {
        final index = _clients.indexWhere((client) => client.id == id);
        if (index != -1) {
          _clients[index] = response.data!;
          notifyListeners();
        }
        return true;
      } else {
        _setError(response.error ?? 'Failed to update client');
        return false;
      }
    } catch (e) {
      _setError('An unexpected error occurred while updating client');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteClient(String id) async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await _apiService.deleteClient(id);

      if (response.success) {
        _clients.removeWhere((client) => client.id == id);
        notifyListeners();
        return true;
      } else {
        _setError(response.error ?? 'Failed to delete client');
        return false;
      }
    } catch (e) {
      _setError('An unexpected error occurred while deleting client');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  List<Client> searchClients(String query) {
    if (query.isEmpty) return _clients;
    
    return _clients.where((client) {
      return client.name.toLowerCase().contains(query.toLowerCase()) ||
             client.phone.contains(query) ||
             (client.caseNumber?.toLowerCase().contains(query.toLowerCase()) ?? false) ||
             (client.email?.toLowerCase().contains(query.toLowerCase()) ?? false);
    }).toList();
  }

  List<Client> getClientsByStatus(String status) {
    return _clients.where((client) => client.status == status).toList();
  }

  List<Client> getClientsByCaseType(String caseType) {
    return _clients.where((client) => client.caseType == caseType).toList();
  }
}
