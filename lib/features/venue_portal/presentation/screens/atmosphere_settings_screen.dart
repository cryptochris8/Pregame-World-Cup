import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/entities.dart';
import '../bloc/venue_enhancement_cubit.dart';
import '../bloc/venue_enhancement_state.dart';

/// Screen for venue owners to configure atmosphere settings
class AtmosphereSettingsScreen extends StatefulWidget {
  final String venueId;
  final String venueName;

  const AtmosphereSettingsScreen({
    super.key,
    required this.venueId,
    required this.venueName,
  });

  @override
  State<AtmosphereSettingsScreen> createState() => _AtmosphereSettingsScreenState();
}

class _AtmosphereSettingsScreenState extends State<AtmosphereSettingsScreen> {
  late Set<String> _selectedTags;
  late List<String> _fanBaseAffinity;
  late NoiseLevel _noiseLevel;
  late CrowdDensity _crowdDensity;

  final TextEditingController _teamController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeFromState();
  }

  void _initializeFromState() {
    final state = context.read<VenueEnhancementCubit>().state;
    final atmosphere = state.atmosphere;

    _selectedTags = Set.from(atmosphere?.tags ?? []);
    _fanBaseAffinity = atmosphere?.fanBaseAffinity.toList() ?? [];
    _noiseLevel = atmosphere?.noiseLevel ?? NoiseLevel.moderate;
    _crowdDensity = atmosphere?.crowdDensity ?? CrowdDensity.comfortable;
  }

  @override
  void dispose() {
    _teamController.dispose();
    super.dispose();
  }

  Future<void> _saveSettings() async {
    final settings = AtmosphereSettings(
      tags: _selectedTags.toList(),
      fanBaseAffinity: _fanBaseAffinity,
      noiseLevel: _noiseLevel,
      crowdDensity: _crowdDensity,
    );

    await context.read<VenueEnhancementCubit>().updateAtmosphere(settings);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Atmosphere settings saved'),
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
            title: const Text('Atmosphere Settings'),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Vibe Tags
                _buildTagsSection(),

                const SizedBox(height: 24),

                // Noise Level
                _buildNoiseLevelSection(),

                const SizedBox(height: 24),

                // Crowd Density
                _buildCrowdDensitySection(),

                const SizedBox(height: 24),

                // Team Affinity
                _buildTeamAffinitySection(),

                const SizedBox(height: 80), // Space for button
              ],
            ),
          ),
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: FilledButton.icon(
                onPressed: state.isSaving ? null : _saveSettings,
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
                label: Text(state.isSaving ? 'Saving...' : 'Save Settings'),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTagsSection() {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Venue Vibe',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Select tags that describe your venue\'s atmosphere',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: AtmosphereSettings.availableTags.map((tag) {
            final isSelected = _selectedTags.contains(tag);
            return FilterChip(
              label: Text(_formatTag(tag)),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedTags.add(tag);
                  } else {
                    _selectedTags.remove(tag);
                  }
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  String _formatTag(String tag) {
    return tag
        .split('-')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  Widget _buildNoiseLevelSection() {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Noise Level',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'What\'s the typical noise level during matches?',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),
        _buildSelectionRow(
          NoiseLevel.values,
          _noiseLevel,
          (level) => setState(() => _noiseLevel = level),
          (level) => level.displayName,
          (level) => _getNoiseLevelIcon(level),
        ),
      ],
    );
  }

  IconData _getNoiseLevelIcon(NoiseLevel level) {
    switch (level) {
      case NoiseLevel.quiet:
        return Icons.volume_off;
      case NoiseLevel.moderate:
        return Icons.volume_down;
      case NoiseLevel.loud:
        return Icons.volume_up;
      case NoiseLevel.veryLoud:
        return Icons.campaign;
    }
  }

  Widget _buildCrowdDensitySection() {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Typical Crowd',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'How crowded is your venue during matches?',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),
        _buildSelectionRow(
          CrowdDensity.values,
          _crowdDensity,
          (density) => setState(() => _crowdDensity = density),
          (density) => density.displayName,
          (density) => _getCrowdDensityIcon(density),
        ),
      ],
    );
  }

  IconData _getCrowdDensityIcon(CrowdDensity density) {
    switch (density) {
      case CrowdDensity.spacious:
        return Icons.person;
      case CrowdDensity.comfortable:
        return Icons.group;
      case CrowdDensity.cozy:
        return Icons.groups;
      case CrowdDensity.packed:
        return Icons.groups_3;
    }
  }

  Widget _buildSelectionRow<T>(
    List<T> values,
    T selected,
    Function(T) onSelected,
    String Function(T) getLabel,
    IconData Function(T) getIcon,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: values.map((value) {
        final isSelected = value == selected;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: InkWell(
              onTap: () => onSelected(value),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? colorScheme.primaryContainer
                      : colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                  border: isSelected
                      ? Border.all(color: colorScheme.primary, width: 2)
                      : null,
                ),
                child: Column(
                  children: [
                    Icon(
                      getIcon(value),
                      color: isSelected
                          ? colorScheme.onPrimaryContainer
                          : colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      getLabel(value),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.bold : null,
                        color: isSelected
                            ? colorScheme.onPrimaryContainer
                            : colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTeamAffinitySection() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Fan Base Affinity',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Add team codes that your venue typically supports (e.g., USA, MEX, ARG)',
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),
        if (_fanBaseAffinity.isNotEmpty) ...[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _fanBaseAffinity.map((team) {
              return Chip(
                label: Text(team.toUpperCase()),
                onDeleted: () {
                  setState(() {
                    _fanBaseAffinity.remove(team);
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
        ],
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _teamController,
                decoration: const InputDecoration(
                  hintText: 'Team code (e.g., USA)',
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.characters,
                maxLength: 3,
              ),
            ),
            const SizedBox(width: 12),
            FilledButton.icon(
              onPressed: () {
                final team = _teamController.text.trim().toUpperCase();
                if (team.isNotEmpty && !_fanBaseAffinity.contains(team)) {
                  setState(() {
                    _fanBaseAffinity.add(team);
                    _teamController.clear();
                  });
                }
              },
              icon: const Icon(Icons.add),
              label: const Text('Add'),
            ),
          ],
        ),
      ],
    );
  }
}
