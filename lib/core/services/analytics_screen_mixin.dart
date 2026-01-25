import 'package:flutter/widgets.dart';
import 'analytics_service.dart';

/// Mixin for automatic screen view tracking
///
/// Usage:
/// ```dart
/// class MyScreenState extends State<MyScreen> with AnalyticsScreenMixin {
///   @override
///   String get screenName => 'my_screen';
///
///   @override
///   String? get screenClass => 'MyScreen';
/// }
/// ```
mixin AnalyticsScreenMixin<T extends StatefulWidget> on State<T> {
  /// Override this to provide the screen name for analytics
  String get screenName;

  /// Override this to provide the screen class name (optional)
  String? get screenClass => null;

  /// Called when the screen becomes visible
  /// Override to add custom tracking parameters
  Map<String, Object>? get screenParameters => null;

  final AnalyticsService _analyticsService = AnalyticsService();

  @override
  void initState() {
    super.initState();
    _trackScreenView();
  }

  void _trackScreenView() {
    _analyticsService.logScreenView(
      screenName: screenName,
      screenClass: screenClass,
    );

    // Log additional screen parameters if provided
    if (screenParameters != null && screenParameters!.isNotEmpty) {
      _analyticsService.logEvent(
        'screen_view_details',
        parameters: {
          'screen_name': screenName,
          ...screenParameters!,
        },
      );
    }
  }

  /// Call this to log a custom event on this screen
  Future<void> trackEvent(String eventName, {Map<String, Object>? parameters}) async {
    await _analyticsService.logEvent(
      eventName,
      parameters: {
        'screen': screenName,
        ...?parameters,
      },
    );
  }

  /// Call this to log an error on this screen
  Future<void> trackError(String errorType, String message) async {
    await _analyticsService.logError(
      errorType: errorType,
      message: message,
    );
  }
}

/// Widget wrapper for tracking screen views without mixin
/// Useful for screens that can't use the mixin
class AnalyticsScreenWrapper extends StatefulWidget {
  final String screenName;
  final String? screenClass;
  final Widget child;
  final Map<String, Object>? parameters;

  const AnalyticsScreenWrapper({
    super.key,
    required this.screenName,
    this.screenClass,
    required this.child,
    this.parameters,
  });

  @override
  State<AnalyticsScreenWrapper> createState() => _AnalyticsScreenWrapperState();
}

class _AnalyticsScreenWrapperState extends State<AnalyticsScreenWrapper> {
  @override
  void initState() {
    super.initState();
    AnalyticsService().logScreenView(
      screenName: widget.screenName,
      screenClass: widget.screenClass,
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

/// Route observer for automatic screen tracking with Navigator
class AnalyticsRouteObserver extends RouteObserver<PageRoute<dynamic>> {
  final AnalyticsService _analyticsService = AnalyticsService();

  void _sendScreenView(PageRoute<dynamic> route) {
    final screenName = route.settings.name;
    if (screenName != null) {
      _analyticsService.logScreenView(
        screenName: screenName,
        screenClass: route.runtimeType.toString(),
      );
    }
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    if (route is PageRoute) {
      _sendScreenView(route);
    }
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute is PageRoute) {
      _sendScreenView(newRoute);
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    if (previousRoute is PageRoute && route is PageRoute) {
      _sendScreenView(previousRoute);
    }
  }
}
