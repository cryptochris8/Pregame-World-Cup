import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/app_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../bloc/watch_party_bloc.dart';
import '../widgets/visibility_badge.dart';
import '../../domain/entities/watch_party.dart';
import 'venue_selector_screen.dart';

/// Screen for editing an existing watch party
class EditWatchPartyScreen extends StatefulWidget {
  final WatchParty watchParty;

  const EditWatchPartyScreen({
    super.key,
    required this.watchParty,
  });

  @override
  State<EditWatchPartyScreen> createState() => _EditWatchPartyScreenState();
}

class _EditWatchPartyScreenState extends State<EditWatchPartyScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _feeController;

  late WatchPartyVisibility _visibility;
  late int _maxAttendees;
  late bool _allowVirtualAttendance;

  // Selected venue (can be changed)
  late String _venueId;
  late String _venueName;
  String? _venueAddress;
  double? _venueLatitude;
  double? _venueLongitude;

  bool _isLoading = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    final wp = widget.watchParty;

    _nameController = TextEditingController(text: wp.name);
    _descriptionController = TextEditingController(text: wp.description);
    _feeController = TextEditingController(
      text: wp.virtualAttendanceFee.toStringAsFixed(2),
    );

    _visibility = wp.visibility;
    _maxAttendees = wp.maxAttendees;
    _allowVirtualAttendance = wp.allowVirtualAttendance;

    _venueId = wp.venueId;
    _venueName = wp.venueName;
    _venueAddress = wp.venueAddress;
    _venueLatitude = wp.venueLatitude;
    _venueLongitude = wp.venueLongitude;

    // Listen for changes
    _nameController.addListener(_markChanged);
    _descriptionController.addListener(_markChanged);
    _feeController.addListener(_markChanged);
  }

  void _markChanged() {
    if (!_hasChanges) {
      setState(() => _hasChanges = true);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _feeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<WatchPartyBloc, WatchPartyState>(
      listener: (context, state) {
        if (state is WatchPartyUpdated) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context).watchPartyUpdated)),
          );
          Navigator.pop(context, true);
        }
        if (state is WatchPartyError) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
        if (state is WatchPartyOperationInProgress) {
          setState(() => _isLoading = true);
        }
      },
      child: PopScope(
        canPop: !_hasChanges,
        onPopInvokedWithResult: (didPop, result) async {
          if (didPop) return;
          final shouldPop = await _onWillPop();
          if (shouldPop && context.mounted) {
            Navigator.of(context).pop();
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(AppLocalizations.of(context).editWatchParty),
            actions: [
              if (_hasChanges)
                TextButton(
                  onPressed: _isLoading ? null : _saveChanges,
                  child: Text(AppLocalizations.of(context).saveButton, style: const TextStyle(color: Colors.white)),
                ),
            ],
          ),
          body: Container(
            decoration: AppTheme.mainGradientDecoration,
            child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Party status info
                if (widget.watchParty.status != WatchPartyStatus.upcoming)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha:0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange.withValues(alpha:0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, color: Colors.orange),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            AppLocalizations.of(context).fieldsCannotBeEdited,
                            style: TextStyle(color: Colors.orange[800], fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Name field
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context).watchPartyNameLabel,
                    hintText: AppLocalizations.of(context).watchPartyNameHint,
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return AppLocalizations.of(context).pleaseEnterName;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Description field
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context).watchPartyDescriptionLabel,
                    hintText: AppLocalizations.of(context).watchPartyDescriptionHint,
                    border: const OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 24),

                // Visibility toggle (only for upcoming parties)
                if (widget.watchParty.status == WatchPartyStatus.upcoming) ...[
                  Text(
                    AppLocalizations.of(context).visibilityLabel,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  VisibilityToggle(
                    value: _visibility,
                    onChanged: (value) {
                      setState(() {
                        _visibility = value;
                        _hasChanges = true;
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _visibility == WatchPartyVisibility.public
                        ? AppLocalizations.of(context).visibilityPublicDesc
                        : AppLocalizations.of(context).visibilityPrivateDesc,
                    style: TextStyle(color: AppTheme.textTertiary, fontSize: 12),
                  ),
                  const SizedBox(height: 24),
                ],

                // Game info (read-only)
                Text(
                  AppLocalizations.of(context).gameLabel,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.sports_soccer, color: Color(0xFF1E3A8A)),
                    title: Text(widget.watchParty.gameName),
                    subtitle: Text(AppLocalizations.of(context).gameCannotBeChanged),
                    enabled: false,
                  ),
                ),
                const SizedBox(height: 24),

                // Venue selection (can be changed for upcoming parties)
                Text(
                  AppLocalizations.of(context).venueLabel,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                _buildVenueSelector(),
                const SizedBox(height: 24),

                // Max attendees (only for upcoming parties)
                if (widget.watchParty.status == WatchPartyStatus.upcoming) ...[
                  Text(
                    AppLocalizations.of(context).maximumAttendees,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Slider(
                          value: _maxAttendees.toDouble(),
                          min: widget.watchParty.currentAttendeesCount.toDouble(),
                          max: 100,
                          divisions: 49,
                          label: _maxAttendees.toString(),
                          onChanged: (value) {
                            setState(() {
                              _maxAttendees = value.round();
                              _hasChanges = true;
                            });
                          },
                        ),
                      ),
                      Container(
                        width: 50,
                        alignment: Alignment.center,
                        child: Text(
                          '$_maxAttendees',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],

                // Virtual attendance (only for upcoming parties)
                if (widget.watchParty.status == WatchPartyStatus.upcoming)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.videocam, color: Color(0xFF059669)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  AppLocalizations.of(context).virtualAttendance,
                                  style: const TextStyle(fontWeight: FontWeight.w600),
                                ),
                              ),
                              Switch(
                                value: _allowVirtualAttendance,
                                onChanged: (value) {
                                  setState(() {
                                    _allowVirtualAttendance = value;
                                    _hasChanges = true;
                                  });
                                },
                              ),
                            ],
                          ),
                          if (_allowVirtualAttendance) ...[
                            const SizedBox(height: 12),
                            Text(
                              AppLocalizations.of(context).virtualAttendanceDesc,
                              style: TextStyle(
                                color: AppTheme.textTertiary,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _feeController,
                              decoration: InputDecoration(
                                labelText: AppLocalizations.of(context).watchPartyVirtualFeeLabel,
                                prefixText: '\$ ',
                                hintText: AppLocalizations.of(context).watchPartyVirtualFeeHint,
                                border: const OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 32),
              ],
            ),
          ),
          ),
          bottomNavigationBar: _buildBottomBar(),
        ),
      ),
    );
  }

  Widget _buildVenueSelector() {
    final canEdit = widget.watchParty.status == WatchPartyStatus.upcoming;

    return Card(
      child: ListTile(
        leading: const Icon(Icons.location_on, color: Color(0xFFDC2626)),
        title: Text(_venueName),
        subtitle: _venueAddress != null ? Text(_venueAddress!) : null,
        trailing: canEdit
            ? IconButton(
                icon: const Icon(Icons.edit),
                onPressed: _selectVenue,
              )
            : null,
        enabled: canEdit,
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: ElevatedButton(
          onPressed: (_isLoading || !_hasChanges) ? null : _saveChanges,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(AppLocalizations.of(context).saveChanges),
        ),
      ),
    );
  }

  void _selectVenue() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => const VenueSelectorScreen(),
      ),
    );

    if (result != null && mounted) {
      setState(() {
        _venueId = result['venueId'] as String? ?? _venueId;
        _venueName = result['venueName'] as String? ?? _venueName;
        _venueAddress = result['venueAddress'] as String?;
        _venueLatitude = result['venueLatitude'] as double?;
        _venueLongitude = result['venueLongitude'] as double?;
        _hasChanges = true;
      });
    }
  }

  Future<bool> _onWillPop() async {
    if (!_hasChanges) return true;

    final l10n = AppLocalizations.of(context);
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.backgroundCard,
        title: Text(l10n.discardChangesTitle),
        content: Text(l10n.discardChangesMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.keepEditing),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(l10n.discard),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  void _saveChanges() {
    if (!_formKey.currentState!.validate()) return;

    final fee = double.tryParse(_feeController.text) ?? 0.0;

    context.read<WatchPartyBloc>().add(
          UpdateWatchPartyEvent(
            watchPartyId: widget.watchParty.watchPartyId,
            name: _nameController.text.trim(),
            description: _descriptionController.text.trim(),
            visibility: _visibility,
            venueId: _venueId,
            venueName: _venueName,
            venueAddress: _venueAddress,
            venueLatitude: _venueLatitude,
            venueLongitude: _venueLongitude,
            maxAttendees: _maxAttendees,
            allowVirtualAttendance: _allowVirtualAttendance,
            virtualAttendanceFee: fee,
          ),
        );
  }
}
