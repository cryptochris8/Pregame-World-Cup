import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/services/logging_service.dart';

/// Data class for venue filter options in smart venue discovery.
class SmartVenueFilter {
  final String name;
  final String type;
  final IconData icon;
  final Color color;

  SmartVenueFilter(this.name, this.type, this.icon, this.color);
}

/// Horizontal scrollable filter tabs for smart venue discovery.
///
/// Displays a list of filter chips (Smart Picks, Nearby, Highly Rated, Popular)
/// that the user can select to sort venue recommendations.
class VenueDiscoveryFilterTabs extends StatelessWidget {
  final List<SmartVenueFilter> filters;
  final int selectedFilterIndex;
  final ValueChanged<int> onFilterSelected;

  const VenueDiscoveryFilterTabs({
    super.key,
    required this.filters,
    required this.selectedFilterIndex,
    required this.onFilterSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = index == selectedFilterIndex;

          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () {
                onFilterSelected(index);
                HapticFeedback.lightImpact();
                LoggingService.info(
                  'Filter selected: ${filter.name}',
                  tag: 'SmartVenueDiscovery',
                );
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? filter.color : const Color(0xFF475569),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? filter.color : const Color(0xFF64748B),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      filter.icon,
                      size: 18,
                      color: isSelected ? Colors.white : Colors.white70,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      filter.name,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.white70,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
