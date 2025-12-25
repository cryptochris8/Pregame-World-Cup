import 'package:cloud_firestore/cloud_firestore.dart';

/// Entity representing a learned user preference
class LearnedPreference {
  final String preferenceId;
  final String userId;
  final String category;
  final String description;
  final double confidence;
  final DateTime createdAt;
  final DateTime updatedAt;

  const LearnedPreference({
    required this.preferenceId,
    required this.userId,
    required this.category,
    required this.description,
    required this.confidence,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create from Firestore document
  factory LearnedPreference.fromFirestore(DocumentSnapshot doc) {
    final data = Map<String, dynamic>.from(doc.data() as Map);
    
    return LearnedPreference(
      preferenceId: doc.id,
      userId: data['userId'] as String,
      category: data['category'] as String,
      description: data['description'] as String,
      confidence: (data['confidence'] as num).toDouble(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  /// Convert to Firestore format
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'category': category,
      'description': description,
      'confidence': confidence,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  /// Create copy with updated values
  LearnedPreference copyWith({
    String? preferenceId,
    String? userId,
    String? category,
    String? description,
    double? confidence,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return LearnedPreference(
      preferenceId: preferenceId ?? this.preferenceId,
      userId: userId ?? this.userId,
      category: category ?? this.category,
      description: description ?? this.description,
      confidence: confidence ?? this.confidence,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'LearnedPreference(category: $category, description: $description, confidence: ${(confidence * 100).round()}%)';
  }
} 