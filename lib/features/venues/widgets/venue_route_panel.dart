import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../features/recommendations/domain/entities/place.dart';
import '../../../core/services/venue_recommendation_service.dart';
import 'venue_route_models.dart';
import 'venue_route_details_section.dart';
import 'venue_route_action_buttons.dart';
import 'venue_route_option_chips.dart';

/// Slide-up panel showing route directions from a stadium to a venue.
///
/// Orchestrates the header, route option chips, route details (or loading/error
/// states), and action buttons. Delegates heavy UI to extracted sub-widgets.
class VenueRoutePanel extends StatefulWidget {
  final Place venue;
  final LatLng? stadiumLocation;
  final VoidCallback onClose;

  const VenueRoutePanel({
    super.key,
    required this.venue,
    this.stadiumLocation,
    required this.onClose,
  });

  @override
  State<VenueRoutePanel> createState() => _VenueRoutePanelState();
}

class _VenueRoutePanelState extends State<VenueRoutePanel>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;

  RouteOption _selectedRoute = RouteOption.walking;
  bool _isLoadingRoute = false;
  RouteDetails? _routeDetails;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
    _calculateRoute();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _calculateRoute() {
    if (widget.stadiumLocation == null) return;

    setState(() {
      _isLoadingRoute = true;
    });

    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        final venueLat = widget.venue.latitude ?? widget.venue.geometry?.location?.lat;
        final venueLng = widget.venue.longitude ?? widget.venue.geometry?.location?.lng;

        if (venueLat != null && venueLng != null) {
          final distance = VenueRecommendationService.calculateWalkingDistance(
            widget.stadiumLocation!.latitude,
            widget.stadiumLocation!.longitude,
            venueLat,
            venueLng,
          );

          final walkTime = VenueRecommendationService.estimateWalkingTime(distance);
          final driveTime = (walkTime * 0.3).round();

          setState(() {
            _routeDetails = RouteDetails(
              walkingTime: walkTime,
              drivingTime: driveTime,
              distance: distance,
              steps: _generateRouteSteps(),
            );
            _isLoadingRoute = false;
          });
        } else {
          setState(() {
            _isLoadingRoute = false;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, MediaQuery.of(context).size.height * _slideAnimation.value),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.6,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 20,
                  offset: Offset(0, -5),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildHeader(),
                VenueRouteOptionChips(
                  selectedRoute: _selectedRoute,
                  routeDetails: _routeDetails,
                  onRouteSelected: (option) {
                    setState(() {
                      _selectedRoute = option;
                    });
                  },
                ),
                if (_routeDetails != null && !_isLoadingRoute)
                  Expanded(
                    child: VenueRouteDetailsSection(
                      routeDetails: _routeDetails!,
                      selectedRoute: _selectedRoute,
                    ),
                  )
                else if (_isLoadingRoute)
                  const Expanded(child: _RoutePanelLoadingState())
                else
                  const Expanded(child: _RoutePanelErrorState()),
                VenueRouteActionButtons(
                  selectedRoute: _selectedRoute,
                  onStartNavigation: _startNavigation,
                  onShare: _shareRoute,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Directions to',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.venue.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D1810),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: _closePanel,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    size: 20,
                    color: Colors.grey,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<RouteStep> _generateRouteSteps() {
    return [
      RouteStep(instruction: 'Start at Stadium', distance: null),
      RouteStep(instruction: 'Head north on Stadium Drive', distance: '0.2 mi'),
      RouteStep(instruction: 'Turn right on Main Street', distance: '0.3 mi'),
      RouteStep(instruction: 'Continue straight for 2 blocks', distance: '0.4 mi'),
      RouteStep(instruction: 'Arrive at ${widget.venue.name}', distance: null),
    ];
  }

  void _closePanel() async {
    await _animationController.reverse();
    widget.onClose();
  }

  void _startNavigation() async {
    final venueLat = widget.venue.latitude ?? widget.venue.geometry?.location?.lat;
    final venueLng = widget.venue.longitude ?? widget.venue.geometry?.location?.lng;

    if (venueLat == null || venueLng == null) return;

    final url = _selectedRoute == RouteOption.walking
        ? 'https://www.google.com/maps/dir/?api=1&destination=$venueLat,$venueLng&travelmode=walking'
        : _selectedRoute == RouteOption.driving
            ? 'https://www.google.com/maps/dir/?api=1&destination=$venueLat,$venueLng&travelmode=driving'
            : 'https://www.google.com/maps/dir/?api=1&destination=$venueLat,$venueLng&travelmode=transit';

    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  void _shareRoute() {
    HapticFeedback.lightImpact();
  }
}

/// Loading state shown while the route is being calculated.
class _RoutePanelLoadingState extends StatelessWidget {
  const _RoutePanelLoadingState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            'Calculating route...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

/// Error state shown when route calculation fails.
class _RoutePanelErrorState extends StatelessWidget {
  const _RoutePanelErrorState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          const Text(
            'Unable to calculate route',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
