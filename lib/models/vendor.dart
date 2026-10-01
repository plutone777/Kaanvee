import 'package:cloud_firestore/cloud_firestore.dart';

class VendorModel {
  final String vendorId;
  final String vendorType;
  final String name;
  final String description;
  final String location;
  final List<String> tags;
  final String operatingHours;
  final bool openClosedStatus;
  final String priceRange;
  final double? averagePrice;

  final double averageRating;
  final int reviewCount;
  final int likeCount;

  final String createdBy;
  final DateTime createdDate;
  final DateTime? lastUpdated;
  final String? instagram;
  final String? viber;
  final String? whatsapp;
  final String? facebook;
  final String? phone;
  final List<String> imageUrls;
  final List<String> menuImageUrls;
  final String approvalStatus;

  VendorModel({
    required this.vendorId,
    required this.vendorType,
    required this.name,
    this.description = '',
    required this.location,
    required this.tags,
    this.operatingHours = '',
    this.openClosedStatus = false,
    this.priceRange = '',
    this.averagePrice,

    this.averageRating = 0.0,
    this.reviewCount = 0,
    this.likeCount = 0,

    required this.createdBy,
    required this.createdDate,
    this.lastUpdated,
    this.instagram,
    this.viber,
    this.whatsapp,
    this.facebook,
    this.phone,
    this.imageUrls = const [],
    this.menuImageUrls = const [],
    this.approvalStatus = 'Pending',
  });

  factory VendorModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data()!;

    return VendorModel(
      vendorId: document.id,
      vendorType: data['vendorType'] ?? '',
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      location: data['location'] ?? '',
      tags: List<String>.from(data['tags'] ?? []),
      operatingHours: data['operatingHours'] ?? '',
      openClosedStatus: data['openClosedStatus'] ?? false,
      priceRange: data['priceRange'] ?? '',
      averagePrice: (data['averagePrice'] as num?)?.toDouble(),

      // Review summary
      averageRating: (data['averageRating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: (data['reviewCount'] as num?)?.toInt() ?? 0,
      likeCount: (data['likeCount'] as num?)?.toInt() ?? 0,

      createdBy: data['createdBy'] ?? '',
      createdDate: (data['createdDate'] as Timestamp).toDate(),
      lastUpdated: (data['lastUpdated'] as Timestamp?)?.toDate(),
      instagram: data['instagram'],
      viber: data['viber'],
      whatsapp: data['whatsapp'],
      facebook: data['facebook'],
      phone: data['phone'],
      imageUrls: List<String>.from(data['imageURLs'] ?? []),
      menuImageUrls: List<String>.from(data['menuImageURLs'] ?? []),
      approvalStatus: data['approvalStatus'] ?? 'Pending',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'vendorType': vendorType,
      'name': name,
      'description': description,
      'location': location,
      'tags': tags,
      'operatingHours': operatingHours,
      'openClosedStatus': openClosedStatus,
      'priceRange': priceRange,
      'averagePrice': averagePrice,

      // Review summary
      'averageRating': averageRating,
      'reviewCount': reviewCount,
      'likeCount': likeCount,

      'createdBy': createdBy,
      'createdDate': Timestamp.fromDate(createdDate),
      'lastUpdated': lastUpdated == null
          ? null
          : Timestamp.fromDate(lastUpdated!),
      'instagram': instagram,
      'viber': viber,
      'whatsapp': whatsapp,
      'facebook': facebook,
      'phone': phone,
      'imageURLs': imageUrls,
      'menuImageURLs': menuImageUrls,
      'approvalStatus': approvalStatus,
    };
  }

  VendorModel copyWith({
    String? vendorId,
    String? vendorType,
    String? name,
    String? description,
    String? location,
    List<String>? tags,
    String? operatingHours,
    bool? openClosedStatus,
    String? priceRange,
    double? averagePrice,

    // Review summary
    double? averageRating,
    int? reviewCount,
    int? likeCount,

    String? createdBy,
    DateTime? createdDate,
    DateTime? lastUpdated,
    String? instagram,
    String? viber,
    String? whatsapp,
    String? facebook,
    String? phone,
    List<String>? imageUrls,
    List<String>? menuImageUrls,
    String? approvalStatus,
  }) {
    return VendorModel(
      vendorId: vendorId ?? this.vendorId,
      vendorType: vendorType ?? this.vendorType,
      name: name ?? this.name,
      description: description ?? this.description,
      location: location ?? this.location,
      tags: tags ?? this.tags,
      operatingHours: operatingHours ?? this.operatingHours,
      openClosedStatus: openClosedStatus ?? this.openClosedStatus,
      priceRange: priceRange ?? this.priceRange,
      averagePrice: averagePrice ?? this.averagePrice,

      // Review summary
      averageRating: averageRating ?? this.averageRating,
      reviewCount: reviewCount ?? this.reviewCount,
      likeCount: likeCount ?? this.likeCount,

      createdBy: createdBy ?? this.createdBy,
      createdDate: createdDate ?? this.createdDate,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      instagram: instagram ?? this.instagram,
      viber: viber ?? this.viber,
      whatsapp: whatsapp ?? this.whatsapp,
      facebook: facebook ?? this.facebook,
      phone: phone ?? this.phone,
      imageUrls: imageUrls ?? this.imageUrls,
      menuImageUrls: menuImageUrls ?? this.menuImageUrls,
      approvalStatus: approvalStatus ?? this.approvalStatus,
    );
  }
}
