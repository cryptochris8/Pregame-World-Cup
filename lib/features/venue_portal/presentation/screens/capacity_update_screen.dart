import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../l10n/app_localizations.dart';
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
        SnackBar(
          content: Text(AppLocalizations.of(context).venuePortalCapacityUpdated),
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
            title: Text(AppLocalizations.of(context).venuePortalLiveCapacity),
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
                label: Text(state.isSaving ? AppLocalizations.of(context).venuePortalSaving : AppLocalizations.of(context).venuePortalUpdateCapacity),
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

    final l10n = AppLocalizations.of(context);
    Color statusColor;
    String statusText;
    if (occupancyPercent >= 95) {
      statusColor = Colors.red;
      statusText = l10n.venuePortalAtCapacity;
    } else if (occupancyPercent >= 80) {
      statusColor = Colors.orange;
      statusText = l10n.venuePortalAlmostFull;
    } else if (occupancyPercent >= 50) {
      statusColor = Colors.yellow.shade700;
      statusText = l10n.venuePortalBusy;
    } else if (occupancyPercent >= 25) {
      statusColor = Colors.green;
      statusText = l10n.venuePortalModerate;
    } else {
      statusColor = Colors.green.shade700;
      statusText = l10n.venuePortalPlentyOfRoom;
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
                      AppLocalizations.of(context).venuePortalCurrentStatus,
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
                    color: statusColor.withValues(alpha:0.2),
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
              AppLocalizations.of(context).venuePortalGuestsCount(_currentOccupancy, _maxCapacity),
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
          AppLocalizations.of(context).venuePortalMaximumCapacity,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          AppLocalizations.of(context).venuePortalMaxCapacityDesc,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          initialValue: _maxCapacity.toString(),
          decoration: InputDecoration(
            labelText: AppLocalizations.of(context).venuePortalMaxCapacity,
            suffixText: AppLocalizations.of(context).venuePortalSuffixGuests,
            border: const OutlineInputBorder(),
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
              AppLocalizations.of(context).venuePortalCurrentOccupancy,
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
          AppLocalizations.of(context).venuePortalEstimatedWaitTime,
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
            final l10n = AppLocalizations.of(context);
            String label;
            if (time == null) {
              label = l10n.venuePortalUnknownWait;
            } else if (time == 0) {
              label = l10n.venuePortalNoWait;
            } else if (time < 60) {
              label = l10n.venuePortalWaitTimeMinutes(time);
            } else {
              label = l10n.venuePortalOneHourPlus;
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
          AppLocalizations.of(context).venuePortalAcceptingReservations,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          _reservationsAvailable
              ? AppLocalizations.of(context).venuePortalReservationsOpen
              : AppLocalizations.of(context).venuePortalReservationsClosed,
        ),
        secondary: Icon(
          _reservationsAvailable ? Icons.check_circle : Icons.cancel,
          color: _reservationsAvailable ? Colors.green : Colors.red,
        ),
      ),
    );
  }
}
