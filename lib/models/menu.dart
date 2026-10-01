import 'package:cloud_firestore/cloud_firestore.dart';

class MenuModel {
  final String menuId;
  final String vendorId;
  final String itemName;
  final String description;
  final String category;
  final double? price;
  final List<String> imageUrls;
  final double? averageRating;
  final String createdBy;
  final DateTime createdDate;
  final DateTime? lastUpdated;

  MenuModel({
    required this.menuId,
    required this.vendorId,
    required this.itemName,
    this.description = '',
    required this.category,
    this.price,
    this.imageUrls = const [],
    this.averageRating,
    required this.createdBy,
    required this.createdDate,
    this.lastUpdated,
  });

  factory MenuModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data()!;

    return MenuModel(
      menuId: document.id,
      vendorId: data['vendorID'] ?? '',
      itemName: data['itemName'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? '',
      price: (data['price'] as num?)?.toDouble(),
      imageUrls: List<String>.from(data['imageURLs'] ?? []),
      averageRating: (data['averageRating'] as num?)?.toDouble(),
      createdBy: data['createdBy'] ?? '',
      createdDate: (data['createdDate'] as Timestamp).toDate(),
      lastUpdated: (data['lastUpdated'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'vendorID': vendorId,
      'itemName': itemName,
      'description': description,
      'category': category,
      'price': price,
      'imageURLs': imageUrls,
      'averageRating': averageRating,
      'createdBy': createdBy,
      'createdDate': Timestamp.fromDate(createdDate),
      'lastUpdated': lastUpdated == null
          ? null
          : Timestamp.fromDate(lastUpdated!),
    };
  }

  MenuModel copyWith({
    String? menuId,
    String? vendorId,
    String? itemName,
    String? description,
    String? category,
    double? price,
    List<String>? imageUrls,
    double? averageRating,
    String? createdBy,
    DateTime? createdDate,
    DateTime? lastUpdated,
  }) {
    return MenuModel(
      menuId: menuId ?? this.menuId,
      vendorId: vendorId ?? this.vendorId,
      itemName: itemName ?? this.itemName,
      description: description ?? this.description,
      category: category ?? this.category,
      price: price ?? this.price,
      imageUrls: imageUrls ?? this.imageUrls,
      averageRating: averageRating ?? this.averageRating,
      createdBy: createdBy ?? this.createdBy,
      createdDate: createdDate ?? this.createdDate,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}
