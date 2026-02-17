// Data models for venue route panel.

/// Available route/transport options.
enum RouteOption {
  walking,
  driving,
  transit,
}

/// Display name extension for RouteOption.
extension RouteOptionExtension on RouteOption {
  String get displayName {
    switch (this) {
      case RouteOption.walking:
        return 'Walking';
      case RouteOption.driving:
        return 'Driving';
      case RouteOption.transit:
        return 'Transit';
    }
  }
}

/// Details about a calculated route between stadium and venue.
class RouteDetails {
  final int walkingTime;
  final int drivingTime;
  final double distance;
  final List<RouteStep> steps;

  RouteDetails({
    required this.walkingTime,
    required this.drivingTime,
    required this.distance,
    required this.steps,
  });
}

/// A single step/instruction in a route.
class RouteStep {
  final String instruction;
  final String? distance;

  RouteStep({
    required this.instruction,
    this.distance,
  });
}
