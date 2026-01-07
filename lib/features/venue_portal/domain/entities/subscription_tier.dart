enum SubscriptionTier {
  free,
  premium;

  String get displayName {
    switch (this) {
      case SubscriptionTier.free:
        return 'Free';
      case SubscriptionTier.premium:
        return 'Premium';
    }
  }

  static SubscriptionTier fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'premium':
        return SubscriptionTier.premium;
      default:
        return SubscriptionTier.free;
    }
  }

  String toJson() => name;
}
