import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/note.dart';
import '../services/api_service.dart';

class NoteProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<Note> _notes = [];
  bool _isLoading = false;
  String? _error;
  int _currentPage = 1;
  bool _hasMoreData = true;

  List<Note> get notes => _notes;
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

  Future<void> loadNotes({
    bool refresh = false,
    String? search,
    String? clientId,
    String? noteType,
    String? priority,
  }) async {
    if (refresh) {
      _currentPage = 1;
      _hasMoreData = true;
      _notes.clear();
    }

    if (!_hasMoreData || _isLoading) return;

    _setLoading(true);
    _setError(null);

    try {
      final response = await _apiService.getNotes(
        page: _currentPage,
        limit: 20,
        search: search,
        clientId: clientId,
        noteType: noteType,
        priority: priority,
      );

      if (response.success && response.data != null) {
        if (refresh) {
          _notes = response.data!;
        } else {
          _notes.addAll(response.data!);
        }
        
        _currentPage++;
        _hasMoreData = response.data!.length == 20;
        notifyListeners();
      } else {
        _setError(response.error ?? 'Failed to load notes');
      }
    } catch (e) {
      _setError('An unexpected error occurred while loading notes');
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> createNote({
    required String title,
    required String content,
    String? clientId,
    String? appointmentId,
    String noteType = 'General',
    String priority = 'Medium',
    List<String>? tags,
    bool isPrivate = false,
    DateTime? reminderDate,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final noteData = {
        'title': title,
        'content': content,
        'clientId': clientId,
        'appointmentId': appointmentId,
        'noteType': noteType,
        'priority': priority,
        'tags': tags ?? [],
        'isPrivate': isPrivate,
        'reminderDate': reminderDate?.toIso8601String(),
      };

      final response = await _apiService.createNote(noteData);

      if (response.success && response.data != null) {
        _notes.insert(0, response.data!);
        notifyListeners();
        return true;
      } else {
        _setError(response.error ?? 'Failed to create note');
        return false;
      }
    } catch (e) {
      _setError('An unexpected error occurred while creating note');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateNote(String id, Map<String, dynamic> updates) async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await _apiService.updateNote(id, updates);

      if (response.success && response.data != null) {
        final index = _notes.indexWhere((note) => note.id == id);
        if (index != -1) {
          _notes[index] = response.data!;
          notifyListeners();
        }
        return true;
      } else {
        _setError(response.error ?? 'Failed to update note');
        return false;
      }
    } catch (e) {
      _setError('An unexpected error occurred while updating note');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteNote(String id) async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await _apiService.deleteNote(id);

      if (response.success) {
        _notes.removeWhere((note) => note.id == id);
        notifyListeners();
        return true;
      } else {
        _setError(response.error ?? 'Failed to delete note');
        return false;
      }
    } catch (e) {
      _setError('An unexpected error occurred while deleting note');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> uploadVoiceRecording(String noteId, File audioFile) async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await _apiService.uploadVoiceRecording(noteId, audioFile);

      if (response.success && response.data != null) {
        final index = _notes.indexWhere((note) => note.id == noteId);
        if (index != -1) {
          _notes[index] = _notes[index].copyWith(voiceRecording: response.data);
          notifyListeners();
        }
        return true;
      } else {
        _setError(response.error ?? 'Failed to upload voice recording');
        return false;
      }
    } catch (e) {
      _setError('An unexpected error occurred while uploading voice recording');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> toggleFavorite(String id) async {
    try {
      final index = _notes.indexWhere((note) => note.id == id);
      if (index != -1) {
        final updatedNote = _notes[index].copyWith(isFavorite: !_notes[index].isFavorite);
        _notes[index] = updatedNote;
        notifyListeners();
        
        // Update on server
        await updateNote(id, {'isFavorite': updatedNote.isFavorite});
        return true;
      }
      return false;
    } catch (e) {
      _setError('Failed to toggle favorite status');
      return false;
    }
  }

  List<Note> searchNotes(String query) {
    if (query.isEmpty) return _notes;
    
    return _notes.where((note) {
      return note.title.toLowerCase().contains(query.toLowerCase()) ||
             note.content.toLowerCase().contains(query.toLowerCase()) ||
             note.tags.any((tag) => tag.toLowerCase().contains(query.toLowerCase()));
    }).toList();
  }

  List<Note> getNotesByType(String noteType) {
    return _notes.where((note) => note.noteType == noteType).toList();
  }

  List<Note> getNotesByPriority(String priority) {
    return _notes.where((note) => note.priority == priority).toList();
  }

  List<Note> getFavoriteNotes() {
    return _notes.where((note) => note.isFavorite).toList();
  }

  List<Note> getNotesByClient(String clientId) {
    return _notes.where((note) => note.clientId == clientId).toList();
  }

  List<Note> getNotesWithVoiceRecordings() {
    return _notes.where((note) => note.voiceRecording != null).toList();
  }

  List<Note> getNotesWithReminders() {
    return _notes.where((note) => note.reminderDate != null).toList();
  }

  List<String> getAllTags() {
    final allTags = <String>{};
    for (final note in _notes) {
      allTags.addAll(note.tags);
    }
    return allTags.toList()..sort();
  }
}
