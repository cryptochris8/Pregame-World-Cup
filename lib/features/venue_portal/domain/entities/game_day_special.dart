import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum SpecialValidFor {
  allMatches,
  specificMatches;

  String get displayName {
    switch (this) {
      case SpecialValidFor.allMatches:
        return 'All Matches';
      case SpecialValidFor.specificMatches:
        return 'Specific Matches';
    }
  }

  static SpecialValidFor fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'specific_matches':
      case 'specificmatches':
        return SpecialValidFor.specificMatches;
      default:
        return SpecialValidFor.allMatches;
    }
  }

  String toJson() {
    switch (this) {
      case SpecialValidFor.allMatches:
        return 'all_matches';
      case SpecialValidFor.specificMatches:
        return 'specific_matches';
    }
  }
}

class GameDaySpecial extends Equatable {
  final String id;
  final String title;
  final String description;
  final double? price;
  final int? discountPercent;
  final SpecialValidFor validFor;
  final List<String> matchIds;
  final List<String> validDays; // ['monday', 'tuesday', etc.]
  final String? validTimeStart; // '11:00'
  final String? validTimeEnd; // '23:00'
  final bool isActive;
  final DateTime? expiresAt;
  final DateTime createdAt;

  const GameDaySpecial({
    required this.id,
    required this.title,
    required this.description,
    this.price,
    this.discountPercent,
    this.validFor = SpecialValidFor.allMatches,
    this.matchIds = const [],
    this.validDays = const [],
    this.validTimeStart,
    this.validTimeEnd,
    this.isActive = true,
    this.expiresAt,
    required this.createdAt,
  });

  factory GameDaySpecial.create({
    required String title,
    required String description,
    double? price,
    int? discountPercent,
  }) {
    return GameDaySpecial(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: description,
      price: price,
      discountPercent: discountPercent,
      createdAt: DateTime.now(),
    );
  }

  GameDaySpecial copyWith({
    String? title,
    String? description,
    double? price,
    int? discountPercent,
    SpecialValidFor? validFor,
    List<String>? matchIds,
    List<String>? validDays,
    String? validTimeStart,
    String? validTimeEnd,
    bool? isActive,
    DateTime? expiresAt,
  }) {
    return GameDaySpecial(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      discountPercent: discountPercent ?? this.discountPercent,
      validFor: validFor ?? this.validFor,
      matchIds: matchIds ?? this.matchIds,
      validDays: validDays ?? this.validDays,
      validTimeStart: validTimeStart ?? this.validTimeStart,
      validTimeEnd: validTimeEnd ?? this.validTimeEnd,
      isActive: isActive ?? this.isActive,
      expiresAt: expiresAt ?? this.expiresAt,
      createdAt: createdAt,
    );
  }

  bool get isExpired => expiresAt != null && DateTime.now().isAfter(expiresAt!);
  bool get isCurrentlyValid => isActive && !isExpired;

  String get displayPrice {
    if (price != null) {
      return '\$${price!.toStringAsFixed(2)}';
    }
    if (discountPercent != null) {
      return '$discountPercent% off';
    }
    return 'Special';
  }

  factory GameDaySpecial.fromJson(Map<String, dynamic> json) {
    return GameDaySpecial(
      id: json['id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble(),
      discountPercent: json['discountPercent'] as int?,
      validFor: SpecialValidFor.fromString(json['validFor'] as String?),
      matchIds: List<String>.from(json['matchIds'] ?? []),
      validDays: List<String>.from(json['validDays'] ?? []),
      validTimeStart: json['validTimeStart'] as String?,
      validTimeEnd: json['validTimeEnd'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      expiresAt: json['expiresAt'] != null
          ? (json['expiresAt'] is Timestamp
              ? (json['expiresAt'] as Timestamp).toDate()
              : DateTime.parse(json['expiresAt'] as String))
          : null,
      createdAt: json['createdAt'] != null
          ? (json['createdAt'] is Timestamp
              ? (json['createdAt'] as Timestamp).toDate()
              : DateTime.parse(json['createdAt'] as String))
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'price': price,
      'discountPercent': discountPercent,
      'validFor': validFor.toJson(),
      'matchIds': matchIds,
      'validDays': validDays,
      'validTimeStart': validTimeStart,
      'validTimeEnd': validTimeEnd,
      'isActive': isActive,
      'expiresAt': expiresAt != null ? Timestamp.fromDate(expiresAt!) : null,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        price,
        discountPercent,
        validFor,
        matchIds,
        validDays,
        validTimeStart,
        validTimeEnd,
        isActive,
        expiresAt,
        createdAt,
      ];
}
