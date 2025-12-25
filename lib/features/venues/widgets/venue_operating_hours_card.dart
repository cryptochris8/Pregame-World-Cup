import 'package:flutter/material.dart';
import '../../../features/recommendations/domain/entities/place.dart';

class VenueOperatingHoursCard extends StatelessWidget {
  final Place venue;
  final bool showFullSchedule;

  const VenueOperatingHoursCard({
    super.key,
    required this.venue,
    this.showFullSchedule = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF334155), // Dark blue-gray background
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF475569)), // Lighter border
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with status
          Row(
            children: [
              const Icon(
                Icons.access_time,
                color: Color(0xFFFF6B35), // Vibrant orange
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Hours',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white, // White text for dark background
                ),
              ),
              const Spacer(),
              _buildCurrentStatus(),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Current day info
          _buildTodayHours(),
          
          // Show full schedule if requested
          if (showFullSchedule) ...[
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            _buildFullSchedule(),
          ] else ...[
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => _showFullScheduleDialog(context),
              child:               const Text(
                'View full schedule',
                style: TextStyle(
                  color: Color(0xFFFF6B35), // Vibrant orange
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCurrentStatus() {
    final now = DateTime.now();
    final isOpenNow = _isOpenNow(now);
    final statusInfo = _getStatusInfo(now);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isOpenNow 
            ? const Color(0xFF2D6A4F).withOpacity(0.1)
            : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isOpenNow 
              ? const Color(0xFF2D6A4F).withOpacity(0.3)
              : Colors.red.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: isOpenNow ? const Color(0xFF2D6A4F) : Colors.red,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            statusInfo['status']!,
            style: TextStyle(
              color: isOpenNow ? const Color(0xFF2D6A4F) : Colors.red,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayHours() {
    final now = DateTime.now();
    final todayHours = _getTodayHours(now);
    final statusInfo = _getStatusInfo(now);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              _getDayName(now.weekday),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white, // White text for dark background
              ),
            ),
            const Spacer(),
            Text(
              todayHours,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.white70, // Light text for dark background
              ),
            ),
          ],
        ),
        
        if (statusInfo['nextTime'] != null) ...[
          const SizedBox(height: 8),
          Text(
            statusInfo['nextTime']!,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white60, // Light text for dark background
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildFullSchedule() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Weekly Schedule',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white, // White text for dark background
          ),
        ),
        const SizedBox(height: 12),
        
        ...List.generate(7, (index) {
          final dayIndex = (index + 1) % 7; // Start with Monday (1)
          final dayIndex7 = dayIndex == 0 ? 7 : dayIndex; // Convert Sunday to 7
          final dayName = _getDayName(dayIndex7);
          final hours = _getHoursForDay(dayIndex7);
          final isToday = DateTime.now().weekday == dayIndex7;
          
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                SizedBox(
                  width: 80,
                  child: Text(
                    dayName,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isToday ? FontWeight.w600 : FontWeight.w500,
                      color: isToday ? const Color(0xFFFF6B35) : Colors.white, // Orange for today, white for others
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    hours,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isToday ? FontWeight.w500 : FontWeight.normal,
                      color: isToday ? Colors.white : Colors.white70, // White text for dark background
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  String _getDayName(int weekday) {
    switch (weekday) {
      case 1: return 'Monday';
      case 2: return 'Tuesday';
      case 3: return 'Wednesday';
      case 4: return 'Thursday';
      case 5: return 'Friday';
      case 6: return 'Saturday';
      case 7: return 'Sunday';
      default: return 'Unknown';
    }
  }



  bool _isOpenNow(DateTime now) {
    // This is a simplified implementation
    // In a real app, you would get opening hours from the venue data
    final hour = now.hour;
    final weekday = now.weekday;
    
    // Example business hours logic
    if (weekday >= 1 && weekday <= 5) { // Monday to Friday
      return hour >= 8 && hour < 22; // 8 AM to 10 PM
    } else if (weekday == 6) { // Saturday
      return hour >= 9 && hour < 23; // 9 AM to 11 PM
    } else { // Sunday
      return hour >= 10 && hour < 21; // 10 AM to 9 PM
    }
  }

  Map<String, String?> _getStatusInfo(DateTime now) {
    final isOpen = _isOpenNow(now);
    
    if (isOpen) {
      final closingTime = _getClosingTime(now);
      return {
        'status': 'Open Now',
        'nextTime': closingTime != null ? 'Closes at $closingTime' : null,
      };
    } else {
      final openingTime = _getNextOpeningTime(now);
      return {
        'status': 'Closed',
        'nextTime': openingTime != null ? 'Opens $openingTime' : null,
      };
    }
  }

  String? _getClosingTime(DateTime now) {
    // Simplified logic - in real app, get from venue data
    final weekday = now.weekday;
    
    if (weekday >= 1 && weekday <= 5) { // Monday to Friday
      return '10:00 PM';
    } else if (weekday == 6) { // Saturday
      return '11:00 PM';
    } else { // Sunday
      return '9:00 PM';
    }
  }

  String? _getNextOpeningTime(DateTime now) {
    // Simplified logic - in real app, calculate from venue data
    final hour = now.hour;
    final weekday = now.weekday;
    
    if (weekday >= 1 && weekday <= 5) { // Monday to Friday
      if (hour < 8) {
        return 'at 8:00 AM';
      } else {
        return 'tomorrow at 8:00 AM';
      }
    } else if (weekday == 6) { // Saturday
      if (hour < 9) {
        return 'at 9:00 AM';
      } else {
        return 'tomorrow at 10:00 AM'; // Sunday
      }
    } else { // Sunday
      if (hour < 10) {
        return 'at 10:00 AM';
      } else {
        return 'tomorrow at 8:00 AM'; // Monday
      }
    }
  }

  String _getTodayHours(DateTime now) {
    return _getHoursForDay(now.weekday);
  }

  String _getHoursForDay(int weekday) {
    // Simplified logic - in real app, get from venue data
    if (weekday >= 1 && weekday <= 5) { // Monday to Friday
      return '8:00 AM - 10:00 PM';
    } else if (weekday == 6) { // Saturday
      return '9:00 AM - 11:00 PM';
    } else { // Sunday
      return '10:00 AM - 9:00 PM';
    }
  }

  void _showFullScheduleDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Color(0xFF334155), // Dark blue-gray background for dialog
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.schedule,
                    color: Color(0xFFFF6B35), // Vibrant orange
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '${venue.name} Hours',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white, // White text for dark dialog
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: Colors.white), // White close icon
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              
              _buildFullSchedule(),
              
              const SizedBox(height: 20),
              
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF475569), // Darker blue-gray for info box
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: Color(0xFFFF6B35), // Vibrant orange
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Hours may vary on holidays. Call ahead to confirm.',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white70, // Light text for dark background
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Compact version for venue cards
class VenueHoursChip extends StatelessWidget {
  final Place venue;
  final bool showIcon;

  const VenueHoursChip({
    super.key,
    required this.venue,
    this.showIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final isOpen = _isOpenNow(now);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isOpen 
            ? const Color(0xFF2D6A4F).withOpacity(0.1)
            : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isOpen 
              ? const Color(0xFF2D6A4F).withOpacity(0.3)
              : Colors.red.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: isOpen ? const Color(0xFF2D6A4F) : Colors.red,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
          ],
          Text(
            isOpen ? 'Open Now' : 'Closed',
            style: TextStyle(
              color: isOpen ? const Color(0xFF2D6A4F) : Colors.red,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  bool _isOpenNow(DateTime now) {
    // Same logic as above
    final hour = now.hour;
    final weekday = now.weekday;
    
    if (weekday >= 1 && weekday <= 5) { // Monday to Friday
      return hour >= 8 && hour < 22; // 8 AM to 10 PM
    } else if (weekday == 6) { // Saturday
      return hour >= 9 && hour < 23; // 9 AM to 11 PM
    } else { // Sunday
      return hour >= 10 && hour < 21; // 10 AM to 9 PM
    }
  }
} 