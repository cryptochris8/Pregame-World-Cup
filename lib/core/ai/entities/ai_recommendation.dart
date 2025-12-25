import 'package:equatable/equatable.dart';

class AIRecommendation extends Equatable {
  final String id;
  final String title;
  final String description;
  final double confidence;
  final Map<String, dynamic> metadata;
  final List<String> reasons;
  final DateTime timestamp;
  final String category;

  const AIRecommendation({
    required this.id,
    required this.title,
    required this.description,
    required this.confidence,
    required this.metadata,
    required this.reasons,
    required this.timestamp,
    required this.category,
  });

  factory AIRecommendation.fromJson(Map<String, dynamic> json) => AIRecommendation(
    id: json['id'] ?? '',
    title: json['title'] ?? '',
    description: json['description'] ?? '',
    confidence: (json['confidence'] ?? 0).toDouble(),
    metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    reasons: List<String>.from(json['reasons'] ?? []),
    timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
    category: json['category'] ?? '',
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'confidence': confidence,
    'metadata': metadata,
    'reasons': reasons,
    'timestamp': timestamp.toIso8601String(),
    'category': category,
  };

  @override
  List<Object?> get props => [id, title, description, confidence, metadata, reasons, timestamp, category];

  @override
  String toString() => 'AIRecommendation(id: , title: , confidence: )';
}
