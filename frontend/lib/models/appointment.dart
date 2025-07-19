import 'package:json_annotation/json_annotation.dart';
import 'client.dart';

part 'appointment.g.dart';

@JsonSerializable()
class Appointment {
  final String id;
  final String userId;
  final String clientId;
  final Client? client;
  final String title;
  final String? description;
  final DateTime startDateTime;
  final DateTime endDateTime;
  final String? location;
  final String appointmentType;
  final String status;
  final String priority;
  final int reminderMinutes;
  final bool isRecurring;
  final RecurringPattern? recurringPattern;
  final List<Attendee>? attendees;
  final List<AppointmentNote>? notes;
  final List<Document>? documents;
  final double billableHours;
  final double? hourlyRate;
  final double totalAmount;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Appointment({
    required this.id,
    required this.userId,
    required this.clientId,
    this.client,
    required this.title,
    this.description,
    required this.startDateTime,
    required this.endDateTime,
    this.location,
    required this.appointmentType,
    required this.status,
    required this.priority,
    required this.reminderMinutes,
    required this.isRecurring,
    this.recurringPattern,
    this.attendees,
    this.notes,
    this.documents,
    required this.billableHours,
    this.hourlyRate,
    required this.totalAmount,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) => _$AppointmentFromJson(json);
  Map<String, dynamic> toJson() => _$AppointmentToJson(this);

  Duration get duration => endDateTime.difference(startDateTime);
  
  int get durationMinutes => duration.inMinutes;

  String get dateRange {
    final startDate = startDateTime.toLocal();
    final endDate = endDateTime.toLocal();
    
    if (startDate.day == endDate.day && 
        startDate.month == endDate.month && 
        startDate.year == endDate.year) {
      return '${startDate.day}/${startDate.month}/${startDate.year}';
    }
    
    return '${startDate.day}/${startDate.month}/${startDate.year} - ${endDate.day}/${endDate.month}/${endDate.year}';
  }

  Appointment copyWith({
    String? id,
    String? userId,
    String? clientId,
    Client? client,
    String? title,
    String? description,
    DateTime? startDateTime,
    DateTime? endDateTime,
    String? location,
    String? appointmentType,
    String? status,
    String? priority,
    int? reminderMinutes,
    bool? isRecurring,
    RecurringPattern? recurringPattern,
    List<Attendee>? attendees,
    List<AppointmentNote>? notes,
    List<Document>? documents,
    double? billableHours,
    double? hourlyRate,
    double? totalAmount,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Appointment(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      clientId: clientId ?? this.clientId,
      client: client ?? this.client,
      title: title ?? this.title,
      description: description ?? this.description,
      startDateTime: startDateTime ?? this.startDateTime,
      endDateTime: endDateTime ?? this.endDateTime,
      location: location ?? this.location,
      appointmentType: appointmentType ?? this.appointmentType,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      reminderMinutes: reminderMinutes ?? this.reminderMinutes,
      isRecurring: isRecurring ?? this.isRecurring,
      recurringPattern: recurringPattern ?? this.recurringPattern,
      attendees: attendees ?? this.attendees,
      notes: notes ?? this.notes,
      documents: documents ?? this.documents,
      billableHours: billableHours ?? this.billableHours,
      hourlyRate: hourlyRate ?? this.hourlyRate,
      totalAmount: totalAmount ?? this.totalAmount,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

@JsonSerializable()
class RecurringPattern {
  final String frequency;
  final int interval;
  final DateTime? endDate;
  final List<int>? daysOfWeek;

  RecurringPattern({
    required this.frequency,
    required this.interval,
    this.endDate,
    this.daysOfWeek,
  });

  factory RecurringPattern.fromJson(Map<String, dynamic> json) => _$RecurringPatternFromJson(json);
  Map<String, dynamic> toJson() => _$RecurringPatternToJson(this);
}

@JsonSerializable()
class Attendee {
  final String name;
  final String? email;
  final String? phone;
  final String role;

  Attendee({
    required this.name,
    this.email,
    this.phone,
    required this.role,
  });

  factory Attendee.fromJson(Map<String, dynamic> json) => _$AttendeeFromJson(json);
  Map<String, dynamic> toJson() => _$AttendeeToJson(this);
}

@JsonSerializable()
class AppointmentNote {
  final String content;
  final DateTime createdAt;

  AppointmentNote({
    required this.content,
    required this.createdAt,
  });

  factory AppointmentNote.fromJson(Map<String, dynamic> json) => _$AppointmentNoteFromJson(json);
  Map<String, dynamic> toJson() => _$AppointmentNoteToJson(this);
}
