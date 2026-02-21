import 'package:equatable/equatable.dart';

enum VenueOwnerRole { owner, manager, staff }

enum VenueType { bar, restaurant, sportsBar, hotelBar, other }

class VenueClaimInfo extends Equatable {
  final String businessName;
  final String contactEmail;
  final String contactPhone;
  final VenueOwnerRole role;
  final VenueType venueType;
  final bool authorizedConfirmed;

  const VenueClaimInfo({
    this.businessName = '',
    this.contactEmail = '',
    this.contactPhone = '',
    this.role = VenueOwnerRole.owner,
    this.venueType = VenueType.bar,
    this.authorizedConfirmed = false,
  });

  VenueClaimInfo copyWith({
    String? businessName,
    String? contactEmail,
    String? contactPhone,
    VenueOwnerRole? role,
    VenueType? venueType,
    bool? authorizedConfirmed,
  }) {
    return VenueClaimInfo(
      businessName: businessName ?? this.businessName,
      contactEmail: contactEmail ?? this.contactEmail,
      contactPhone: contactPhone ?? this.contactPhone,
      role: role ?? this.role,
      venueType: venueType ?? this.venueType,
      authorizedConfirmed: authorizedConfirmed ?? this.authorizedConfirmed,
    );
  }

  bool get isStep1Valid =>
      businessName.isNotEmpty &&
      contactEmail.isNotEmpty &&
      contactEmail.contains('@');

  bool get isStep2Valid => authorizedConfirmed;

  @override
  List<Object?> get props => [
        businessName,
        contactEmail,
        contactPhone,
        role,
        venueType,
        authorizedConfirmed,
      ];
}

extension VenueOwnerRoleExtension on VenueOwnerRole {
  String get displayName {
    switch (this) {
      case VenueOwnerRole.owner:
        return 'Owner';
      case VenueOwnerRole.manager:
        return 'Manager';
      case VenueOwnerRole.staff:
        return 'Staff';
    }
  }

  String toJson() => name;

  static VenueOwnerRole fromJson(String? value) {
    switch (value) {
      case 'manager':
        return VenueOwnerRole.manager;
      case 'staff':
        return VenueOwnerRole.staff;
      default:
        return VenueOwnerRole.owner;
    }
  }
}

extension VenueTypeExtension on VenueType {
  String get displayName {
    switch (this) {
      case VenueType.bar:
        return 'Bar';
      case VenueType.restaurant:
        return 'Restaurant';
      case VenueType.sportsBar:
        return 'Sports Bar';
      case VenueType.hotelBar:
        return 'Hotel Bar';
      case VenueType.other:
        return 'Other';
    }
  }

  String toJson() => name;

  static VenueType fromJson(String? value) {
    switch (value) {
      case 'restaurant':
        return VenueType.restaurant;
      case 'sportsBar':
        return VenueType.sportsBar;
      case 'hotelBar':
        return VenueType.hotelBar;
      case 'other':
        return VenueType.other;
      default:
        return VenueType.bar;
    }
  }
}
