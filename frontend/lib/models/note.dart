import 'package:json_annotation/json_annotation.dart';
import 'client.dart';
import 'appointment.dart';

part 'note.g.dart';

@JsonSerializable()
class Note {
  final String id;
  final String userId;
  final String? clientId;
  final String? appointmentId;
  final Client? client;
  final Appointment? appointment;
  final String title;
  final String content;
  final String noteType;
  final String priority;
  final List<String> tags;
  final VoiceRecording? voiceRecording;
  final List<Attachment> attachments;
  final bool isPrivate;
  final bool isFavorite;
  final DateTime? reminderDate;
  final String status;
  final DateTime lastAccessedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  Note({
    required this.id,
    required this.userId,
    this.clientId,
    this.appointmentId,
    this.client,
    this.appointment,
    required this.title,
    required this.content,
    required this.noteType,
    required this.priority,
    required this.tags,
    this.voiceRecording,
    required this.attachments,
    required this.isPrivate,
    required this.isFavorite,
    this.reminderDate,
    required this.status,
    required this.lastAccessedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Note.fromJson(Map<String, dynamic> json) => _$NoteFromJson(json);
  Map<String, dynamic> toJson() => _$NoteToJson(this);

  int get wordCount => content.split(RegExp(r'\s+')).length;
  
  int get readingTimeMinutes => (wordCount / 200).ceil();

  Note copyWith({
    String? id,
    String? userId,
    String? clientId,
    String? appointmentId,
    Client? client,
    Appointment? appointment,
    String? title,
    String? content,
    String? noteType,
    String? priority,
    List<String>? tags,
    VoiceRecording? voiceRecording,
    List<Attachment>? attachments,
    bool? isPrivate,
    bool? isFavorite,
    DateTime? reminderDate,
    String? status,
    DateTime? lastAccessedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Note(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      clientId: clientId ?? this.clientId,
      appointmentId: appointmentId ?? this.appointmentId,
      client: client ?? this.client,
      appointment: appointment ?? this.appointment,
      title: title ?? this.title,
      content: content ?? this.content,
      noteType: noteType ?? this.noteType,
      priority: priority ?? this.priority,
      tags: tags ?? this.tags,
      voiceRecording: voiceRecording ?? this.voiceRecording,
      attachments: attachments ?? this.attachments,
      isPrivate: isPrivate ?? this.isPrivate,
      isFavorite: isFavorite ?? this.isFavorite,
      reminderDate: reminderDate ?? this.reminderDate,
      status: status ?? this.status,
      lastAccessedAt: lastAccessedAt ?? this.lastAccessedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

@JsonSerializable()
class VoiceRecording {
  final String filename;
  final String path;
  final int? duration; // in seconds
  final int size; // in bytes
  final DateTime uploadedAt;

  VoiceRecording({
    required this.filename,
    required this.path,
    this.duration,
    required this.size,
    required this.uploadedAt,
  });

  factory VoiceRecording.fromJson(Map<String, dynamic> json) => _$VoiceRecordingFromJson(json);
  Map<String, dynamic> toJson() => _$VoiceRecordingToJson(this);

  String get durationFormatted {
    if (duration == null) return '00:00';
    final minutes = duration! ~/ 60;
    final seconds = duration! % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String get sizeFormatted {
    if (size < 1024) return '${size}B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)}KB';
    return '${(size / (1024 * 1024)).toStringAsFixed(1)}MB';
  }
}

@JsonSerializable()
class Attachment {
  final String name;
  final String path;
  final int size;
  final String mimeType;
  final DateTime uploadedAt;

  Attachment({
    required this.name,
    required this.path,
    required this.size,
    required this.mimeType,
    required this.uploadedAt,
  });

  factory Attachment.fromJson(Map<String, dynamic> json) => _$AttachmentFromJson(json);
  Map<String, dynamic> toJson() => _$AttachmentToJson(this);

  String get sizeFormatted {
    if (size < 1024) return '${size}B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)}KB';
    return '${(size / (1024 * 1024)).toStringAsFixed(1)}MB';
  }

  String get fileExtension {
    return name.split('.').last.toLowerCase();
  }

  bool get isImage => ['jpg', 'jpeg', 'png', 'gif', 'bmp'].contains(fileExtension);
  bool get isPdf => fileExtension == 'pdf';
  bool get isDocument => ['doc', 'docx', 'txt'].contains(fileExtension);
}
