import 'package:fyp_application/models/preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String userId;
  final String username;
  final String email;
  final String role;
  final int points;
  final String location;
  final String? profileImageURL;
  final UserPreferences preferences;

  UserModel({
    required this.userId,
    required this.username,
    required this.email,
    required this.role,
    this.points = 0,
    this.location = 'Malé',
    this.profileImageURL,
    required this.preferences,
  });

  factory UserModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data()!;

    return UserModel(
      userId: document.id,
      username: data['username'] ?? '',
      email: data['email'] ?? '',
      role: data['role'] ?? 'User',
      points: data['points'] ?? 0,
      location: data['location'] ?? '',
      profileImageURL: data['profileImageURL'],
      preferences: UserPreferences.fromMap(
        data['preferences'] ?? {},
      ),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'username': username,
      'email': email,
      'role': role,
      'points': points,
      'location': location,
      'profileImageURL': profileImageURL,
      'preferences': preferences.toMap(),
    };
  }

  UserModel copyWith({
    String? userId,
    String? username,
    String? email,
    String? role,
    int? points,
    String? location,
    String? profileImageURL,
    UserPreferences? preferences,
  }) {
    return UserModel(
      userId: userId ?? this.userId,
      username: username ?? this.username,
      email: email ?? this.email,
      role: role ?? this.role,
      points: points ?? this.points,
      location: location ?? this.location,
      profileImageURL: profileImageURL ?? this.profileImageURL,
      preferences: preferences ?? this.preferences,
    );
  }
}