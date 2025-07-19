import 'package:json_annotation/json_annotation.dart';

part 'client.g.dart';

@JsonSerializable()
class Client {
  final String id;
  final String userId;
  final String name;
  final String? email;
  final String phone;
  final String? alternatePhone;
  final Address? address;
  final String caseType;
  final String? caseNumber;
  final String? caseDescription;
  final String status;
  final String priority;
  final double? retainerFee;
  final double? hourlyRate;
  final double totalBilled;
  final List<ClientNote>? notes;
  final List<Document>? documents;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Client({
    required this.id,
    required this.userId,
    required this.name,
    this.email,
    required this.phone,
    this.alternatePhone,
    this.address,
    required this.caseType,
    this.caseNumber,
    this.caseDescription,
    required this.status,
    required this.priority,
    this.retainerFee,
    this.hourlyRate,
    required this.totalBilled,
    this.notes,
    this.documents,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Client.fromJson(Map<String, dynamic> json) => _$ClientFromJson(json);
  Map<String, dynamic> toJson() => _$ClientToJson(this);

  Client copyWith({
    String? id,
    String? userId,
    String? name,
    String? email,
    String? phone,
    String? alternatePhone,
    Address? address,
    String? caseType,
    String? caseNumber,
    String? caseDescription,
    String? status,
    String? priority,
    double? retainerFee,
    double? hourlyRate,
    double? totalBilled,
    List<ClientNote>? notes,
    List<Document>? documents,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Client(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      alternatePhone: alternatePhone ?? this.alternatePhone,
      address: address ?? this.address,
      caseType: caseType ?? this.caseType,
      caseNumber: caseNumber ?? this.caseNumber,
      caseDescription: caseDescription ?? this.caseDescription,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      retainerFee: retainerFee ?? this.retainerFee,
      hourlyRate: hourlyRate ?? this.hourlyRate,
      totalBilled: totalBilled ?? this.totalBilled,
      notes: notes ?? this.notes,
      documents: documents ?? this.documents,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

@JsonSerializable()
class Address {
  final String? street;
  final String? city;
  final String? state;
  final String? zipCode;
  final String? country;

  Address({
    this.street,
    this.city,
    this.state,
    this.zipCode,
    this.country,
  });

  factory Address.fromJson(Map<String, dynamic> json) => _$AddressFromJson(json);
  Map<String, dynamic> toJson() => _$AddressToJson(this);

  String get fullAddress {
    final parts = [street, city, state, zipCode, country].where((part) => part != null && part.isNotEmpty);
    return parts.join(', ');
  }
}

@JsonSerializable()
class ClientNote {
  final String content;
  final DateTime createdAt;

  ClientNote({
    required this.content,
    required this.createdAt,
  });

  factory ClientNote.fromJson(Map<String, dynamic> json) => _$ClientNoteFromJson(json);
  Map<String, dynamic> toJson() => _$ClientNoteToJson(this);
}

@JsonSerializable()
class Document {
  final String name;
  final String path;
  final DateTime uploadedAt;

  Document({
    required this.name,
    required this.path,
    required this.uploadedAt,
  });

  factory Document.fromJson(Map<String, dynamic> json) => _$DocumentFromJson(json);
  Map<String, dynamic> toJson() => _$DocumentToJson(this);
}
