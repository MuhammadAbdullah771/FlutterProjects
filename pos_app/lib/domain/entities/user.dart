import 'package:equatable/equatable.dart';

/// User entity representing a user in the system
/// This is part of the domain layer and is independent of any data source
class User extends Equatable {
  final String id;
  final String email;
  final String? fullName;
  final DateTime? createdAt;
  
  const User({
    required this.id,
    required this.email,
    this.fullName,
    this.createdAt,
  });
  
  /// Creates a User from a map (useful for JSON deserialization)
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as String,
      email: map['email'] as String,
      fullName: map['full_name'] as String?,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : null,
    );
  }
  
  /// Converts User to a map (useful for JSON serialization)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'created_at': createdAt?.toIso8601String(),
    };
  }
  
  @override
  List<Object?> get props => [id, email, fullName, createdAt];
  
  @override
  String toString() => 'User(id: $id, email: $email, fullName: $fullName)';
}

