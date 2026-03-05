import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/entities.dart';
import '../bloc/venue_enhancement_cubit.dart';
import '../bloc/venue_enhancement_state.dart';

/// Screen for venue owners to configure their TV/screen setup
class TvSetupScreen extends StatefulWidget {
  final String venueId;
  final String venueName;

  const TvSetupScreen({
    super.key,
    required this.venueId,
    required this.venueName,
  });

  @override
  State<TvSetupScreen> createState() => _TvSetupScreenState();
}

class _TvSetupScreenState extends State<TvSetupScreen> {
  late int _totalScreens;
  late List<ScreenDetail> _screenDetails;
  late AudioSetup _audioSetup;

  @override
  void initState() {
    super.initState();
    _initializeFromState();
  }

  void _initializeFromState() {
    final state = context.read<VenueEnhancementCubit>().state;
    final tvSetup = state.tvSetup;

    _totalScreens = tvSetup?.totalScreens ?? 0;
    _screenDetails = tvSetup?.screenDetails.toList() ?? [];
    _audioSetup = tvSetup?.audioSetup ?? AudioSetup.shared;
  }

  Future<void> _saveSetup() async {
    final setup = TvSetup(
      totalScreens: _totalScreens,
      screenDetails: _screenDetails,
      audioSetup: _audioSetup,
    );

    await context.read<VenueEnhancementCubit>().updateTvSetup(setup);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).tvSetupSaved),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _addScreen() {
    setState(() {
      _screenDetails.add(ScreenDetail(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        size: '55"',
        location: 'Main Area',
        hasAudio: false,
        isPrimary: _screenDetails.isEmpty,
      ));
      _totalScreens = _screenDetails.length;
    });
  }

  void _removeScreen(int index) {
    setState(() {
      _screenDetails.removeAt(index);
      _totalScreens = _screenDetails.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VenueEnhancementCubit, VenueEnhancementState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text(AppLocalizations.of(context).tvScreenSetup),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Quick count
                _buildTotalScreensCard(),

                const SizedBox(height: 24),

                // Audio setup
                _buildAudioSetupSection(),

                const SizedBox(height: 24),

                // Screen details
                _buildScreenDetailsSection(),

                const SizedBox(height: 100), // Space for FAB
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: _addScreen,
            icon: const Icon(Icons.add),
            label: Text(AppLocalizations.of(context).addScreen),
          ),
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: FilledButton.icon(
                onPressed: state.isSaving ? null : _saveSetup,
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
                label: Text(state.isSaving ? AppLocalizations.of(context).savingLabel : AppLocalizations.of(context).saveSetup),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTotalScreensCard() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.tv,
                color: colorScheme.onPrimaryContainer,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context).totalScreens,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    AppLocalizations.of(context).screensConfigured(_totalScreens),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '$_totalScreens',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAudioSetupSection() {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context).audioSetup,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Column(
            children: AudioSetup.values.map((setup) {
              return RadioListTile<AudioSetup>(
                value: setup,
                groupValue: _audioSetup,
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _audioSetup = value;
                    });
                  }
                },
                title: Text(setup.displayName),
                subtitle: Text(_getAudioDescription(setup, context)),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  String _getAudioDescription(AudioSetup setup, BuildContext context) {
    switch (setup) {
      case AudioSetup.dedicated:
        return AppLocalizations.of(context).audioDedicated;
      case AudioSetup.shared:
        return AppLocalizations.of(context).audioShared;
      case AudioSetup.headphonesAvailable:
        return AppLocalizations.of(context).audioHeadphones;
    }
  }

  Widget _buildScreenDetailsSection() {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context).screenDetails,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        if (_screenDetails.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.monitor_outlined,
                      size: 48,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      AppLocalizations.of(context).noScreensConfigured,
                      style: theme.textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppLocalizations.of(context).tapAddScreenToStart,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          ...List.generate(_screenDetails.length, (index) {
            return _buildScreenCard(index);
          }),
      ],
    );
  }

  Widget _buildScreenCard(int index) {
    final screen = _screenDetails[index];
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: screen.isPrimary
                ? colorScheme.primaryContainer
                : colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.tv,
            color: screen.isPrimary
                ? colorScheme.onPrimaryContainer
                : colorScheme.onSurfaceVariant,
          ),
        ),
        title: Text(screen.isPrimary ? AppLocalizations.of(context).screenPrimary(index + 1) : AppLocalizations.of(context).screenNumber(index + 1)),
        subtitle: Text('${screen.size} • ${screen.location}'),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline),
          onPressed: () => _removeScreen(index),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Size dropdown
                DropdownButtonFormField<String>(
                  value: screen.size,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context).screenSizeLabel,
                    border: const OutlineInputBorder(),
                  ),
                  items: ['32"', '42"', '55"', '65"', '75"', '85"', 'Projector']
                      .map((size) => DropdownMenuItem(
                            value: size,
                            child: Text(size),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _screenDetails[index] = screen.copyWith(size: value);
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                // Location
                TextFormField(
                  initialValue: screen.location,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context).locationLabel,
                    hintText: AppLocalizations.of(context).locationHint,
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _screenDetails[index] = screen.copyWith(location: value);
                    });
                  },
                ),
                const SizedBox(height: 16),
                // Options
                Row(
                  children: [
                    Expanded(
                      child: CheckboxListTile(
                        value: screen.hasAudio,
                        onChanged: (value) {
                          setState(() {
                            _screenDetails[index] =
                                screen.copyWith(hasAudio: value ?? false);
                          });
                        },
                        title: Text(AppLocalizations.of(context).hasAudio),
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    Expanded(
                      child: CheckboxListTile(
                        value: screen.isPrimary,
                        onChanged: (value) {
                          setState(() {
                            // Only one can be primary
                            for (int i = 0; i < _screenDetails.length; i++) {
                              _screenDetails[i] = _screenDetails[i]
                                  .copyWith(isPrimary: i == index && (value ?? false));
                            }
                          });
                        },
                        title: Text(AppLocalizations.of(context).primary),
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
