import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class VenueDistanceRings extends StatefulWidget {
  final LatLng centerLocation;
  final List<DistanceRing> rings;
  final bool isVisible;
  final VoidCallback? onToggle;

  const VenueDistanceRings({
    super.key,
    required this.centerLocation,
    required this.rings,
    this.isVisible = false,
    this.onToggle,
  });

  @override
  State<VenueDistanceRings> createState() => _VenueDistanceRingsState();
}

class _VenueDistanceRingsState extends State<VenueDistanceRings>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
    
    if (widget.isVisible) {
      _animationController.forward();
    }
  }

  @override
  void didUpdateWidget(VenueDistanceRings oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.isVisible != oldWidget.isVisible) {
      if (widget.isVisible) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Stack(
          children: [
            // Ring legend (if visible)
            if (widget.isVisible && _fadeAnimation.value > 0.5)
              _buildRingLegend(),
            
            // Toggle control
            _buildToggleControl(),
          ],
        );
      },
    );
  }

  Widget _buildRingLegend() {
    return Positioned(
      top: 120,
      left: 16,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha:0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Walking Distance',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D1810),
                  ),
                ),
                const SizedBox(height: 12),
                ...widget.rings.map((ring) => _buildLegendItem(ring)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLegendItem(DistanceRing ring) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: ring.color,
              shape: BoxShape.circle,
              border: Border.all(color: ring.color.withValues(alpha:0.5), width: 2),
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                ring.label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D1810),
                ),
              ),
              Text(
                ring.description,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildToggleControl() {
    return Positioned(
      top: 120,
      right: 16,
      child: GestureDetector(
        onTap: widget.onToggle,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: widget.isVisible 
                ? const Color(0xFF8B4513) 
                : Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha:0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            Icons.layers,
            color: widget.isVisible ? Colors.white : const Color(0xFF2D1810),
            size: 20,
          ),
        ),
      ),
    );
  }

  /// Create circles for Google Maps based on current visibility
  Set<Circle> createMapCircles() {
    if (!widget.isVisible) return {};
    
    return widget.rings.map((ring) => Circle(
      circleId: CircleId('ring_${ring.radiusKm}'),
      center: widget.centerLocation,
      radius: ring.radiusKm * 1000, // Convert km to meters
      strokeColor: ring.color.withValues(alpha:0.8),
      strokeWidth: 2,
      fillColor: ring.color.withValues(alpha:0.1),
    )).toSet();
  }
}

// Distance ring data model
class DistanceRing {
  final double radiusKm;
  final String label;
  final String description;
  final Color color;
  final int estimatedWalkTime;

  DistanceRing({
    required this.radiusKm,
    required this.label,
    required this.description,
    required this.color,
    required this.estimatedWalkTime,
  });
}

// Predefined distance rings for game day venues
class GameDayDistanceRings {
  static List<DistanceRing> get defaultRings => [
    DistanceRing(
      radiusKm: 0.5,
      label: 'Very Close',
      description: '2-5 min walk',
      color: const Color(0xFF2D6A4F),
      estimatedWalkTime: 3,
    ),
    DistanceRing(
      radiusKm: 1.0,
      label: 'Close',
      description: '8-12 min walk',
      color: const Color(0xFFFFB300),
      estimatedWalkTime: 10,
    ),
    DistanceRing(
      radiusKm: 1.5,
      label: 'Moderate',
      description: '15-20 min walk',
      color: const Color(0xFFFF8F00),
      estimatedWalkTime: 18,
    ),
    DistanceRing(
      radiusKm: 2.0,
      label: 'Far',
      description: '20+ min walk',
      color: const Color(0xFFD32F2F),
      estimatedWalkTime: 25,
    ),
  ];

  static List<DistanceRing> get quickAccessRings => [
    DistanceRing(
      radiusKm: 0.3,
      label: 'Immediate',
      description: '1-3 min walk',
      color: const Color(0xFF1B5E20),
      estimatedWalkTime: 2,
    ),
    DistanceRing(
      radiusKm: 0.8,
      label: 'Quick',
      description: '5-8 min walk',
      color: const Color(0xFF388E3C),
      estimatedWalkTime: 7,
    ),
    DistanceRing(
      radiusKm: 1.5,
      label: 'Accessible',
      description: '12-18 min walk',
      color: const Color(0xFFF57C00),
      estimatedWalkTime: 15,
    ),
  ];
}

// Helper widget for distance-based venue organization
class VenueDistanceOrganizer extends StatelessWidget {
  final List<VenueDistanceGroup> groups;
  final Function(VenueDistanceGroup)? onGroupTap;

  const VenueDistanceOrganizer({
    super.key,
    required this.groups,
    this.onGroupTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: groups.length,
        itemBuilder: (context, index) {
          final group = groups[index];
          return _buildDistanceGroupCard(group);
        },
      ),
    );
  }

  Widget _buildDistanceGroupCard(VenueDistanceGroup group) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: group.color.withValues(alpha:0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: group.color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  group.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D1810),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          Text(
            group.description,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          
          const Spacer(),
          
          Row(
            children: [
              Icon(
                Icons.place,
                size: 14,
                color: group.color,
              ),
              const SizedBox(width: 4),
              Text(
                '${group.venueCount} venues',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: group.color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Venue distance group data model
class VenueDistanceGroup {
  final String title;
  final String description;
  final Color color;
  final int venueCount;
  final double minDistance;
  final double maxDistance;

  VenueDistanceGroup({
    required this.title,
    required this.description,
    required this.color,
    required this.venueCount,
    required this.minDistance,
    required this.maxDistance,
  });
} 