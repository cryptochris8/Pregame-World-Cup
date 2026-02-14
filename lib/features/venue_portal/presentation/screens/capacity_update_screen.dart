import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/venue_enhancement_cubit.dart';
import '../bloc/venue_enhancement_state.dart';

/// Screen for venue owners to update real-time capacity information
class CapacityUpdateScreen extends StatefulWidget {
  final String venueId;
  final String venueName;

  const CapacityUpdateScreen({
    super.key,
    required this.venueId,
    required this.venueName,
  });

  @override
  State<CapacityUpdateScreen> createState() => _CapacityUpdateScreenState();
}

class _CapacityUpdateScreenState extends State<CapacityUpdateScreen> {
  late int _maxCapacity;
  late int _currentOccupancy;
  late int? _waitTimeMinutes;
  late bool _reservationsAvailable;

  @override
  void initState() {
    super.initState();
    _initializeFromState();
  }

  void _initializeFromState() {
    final state = context.read<VenueEnhancementCubit>().state;
    final capacity = state.liveCapacity;

    _maxCapacity = capacity?.maxCapacity ?? 100;
    _currentOccupancy = capacity?.currentOccupancy ?? 0;
    _waitTimeMinutes = capacity?.waitTimeMinutes;
    _reservationsAvailable = capacity?.reservationsAvailable ?? true;
  }

  Future<void> _saveCapacity() async {
    final cubit = context.read<VenueEnhancementCubit>();

    // First set max capacity if changed
    if (cubit.state.liveCapacity?.maxCapacity != _maxCapacity) {
      await cubit.setMaxCapacity(_maxCapacity);
    }

    // Then update live data
    await cubit.updateLiveCapacity(
      currentOccupancy: _currentOccupancy,
      waitTimeMinutes: _waitTimeMinutes,
      reservationsAvailable: _reservationsAvailable,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Capacity updated'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VenueEnhancementCubit, VenueEnhancementState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Live Capacity'),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Capacity overview card
                _buildCapacityOverviewCard(),

                const SizedBox(height: 24),

                // Max capacity setting
                _buildMaxCapacitySection(),

                const SizedBox(height: 24),

                // Current occupancy slider
                _buildOccupancySection(),

                const SizedBox(height: 24),

                // Wait time
                _buildWaitTimeSection(),

                const SizedBox(height: 24),

                // Reservations toggle
                _buildReservationsSection(),

                const SizedBox(height: 80), // Space for button
              ],
            ),
          ),
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: FilledButton.icon(
                onPressed: state.isSaving ? null : _saveCapacity,
                icon: state.isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.save),
                label: Text(state.isSaving ? 'Saving...' : 'Update Capacity'),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCapacityOverviewCard() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final occupancyPercent = _maxCapacity > 0
        ? (_currentOccupancy / _maxCapacity * 100).clamp(0.0, 100.0)
        : 0.0;

    Color statusColor;
    String statusText;
    if (occupancyPercent >= 95) {
      statusColor = Colors.red;
      statusText = 'At Capacity';
    } else if (occupancyPercent >= 80) {
      statusColor = Colors.orange;
      statusText = 'Almost Full';
    } else if (occupancyPercent >= 50) {
      statusColor = Colors.yellow.shade700;
      statusText = 'Busy';
    } else if (occupancyPercent >= 25) {
      statusColor = Colors.green;
      statusText = 'Moderate';
    } else {
      statusColor = Colors.green.shade700;
      statusText = 'Plenty of Room';
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current Status',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      statusText,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${occupancyPercent.round()}%',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: occupancyPercent / 100,
                minHeight: 12,
                backgroundColor: colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation(statusColor),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$_currentOccupancy / $_maxCapacity guests',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMaxCapacitySection() {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Maximum Capacity',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Set the maximum number of guests your venue can accommodate',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          initialValue: _maxCapacity.toString(),
          decoration: const InputDecoration(
            labelText: 'Max Capacity',
            suffixText: 'guests',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
          onChanged: (value) {
            final parsed = int.tryParse(value);
            if (parsed != null && parsed > 0) {
              setState(() {
                _maxCapacity = parsed;
                if (_currentOccupancy > _maxCapacity) {
                  _currentOccupancy = _maxCapacity;
                }
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildOccupancySection() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Current Occupancy',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '$_currentOccupancy',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Slider(
          value: _currentOccupancy.toDouble(),
          min: 0,
          max: _maxCapacity.toDouble(),
          divisions: _maxCapacity > 0 ? _maxCapacity : 1,
          label: _currentOccupancy.toString(),
          onChanged: (value) {
            setState(() {
              _currentOccupancy = value.round();
            });
          },
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            OutlinedButton.icon(
              onPressed: _currentOccupancy > 0
                  ? () => setState(() => _currentOccupancy = (_currentOccupancy - 10).clamp(0, _maxCapacity))
                  : null,
              icon: const Icon(Icons.remove),
              label: const Text('-10'),
            ),
            OutlinedButton.icon(
              onPressed: _currentOccupancy < _maxCapacity
                  ? () => setState(() => _currentOccupancy = (_currentOccupancy + 10).clamp(0, _maxCapacity))
                  : null,
              icon: const Icon(Icons.add),
              label: const Text('+10'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWaitTimeSection() {
    final theme = Theme.of(context);

    final waitTimes = [null, 0, 5, 10, 15, 30, 45, 60, 90];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Estimated Wait Time',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: waitTimes.map((time) {
            final isSelected = _waitTimeMinutes == time;
            String label;
            if (time == null) {
              label = 'Unknown';
            } else if (time == 0) {
              label = 'No Wait';
            } else if (time < 60) {
              label = '~${time}m';
            } else {
              label = '1hr+';
            }

            return ChoiceChip(
              label: Text(label),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _waitTimeMinutes = selected ? time : null;
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildReservationsSection() {
    final theme = Theme.of(context);

    return Card(
      child: SwitchListTile(
        value: _reservationsAvailable,
        onChanged: (value) {
          setState(() {
            _reservationsAvailable = value;
          });
        },
        title: Text(
          'Accepting Reservations',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          _reservationsAvailable
              ? 'Reservations are currently open'
              : 'Reservations are closed',
        ),
        secondary: Icon(
          _reservationsAvailable ? Icons.check_circle : Icons.cancel,
          color: _reservationsAvailable ? Colors.green : Colors.red,
        ),
      ),
    );
  }
}
