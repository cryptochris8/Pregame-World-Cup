import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/watch_party_bloc.dart';
import '../widgets/visibility_badge.dart';
import '../../domain/entities/watch_party.dart';
import 'venue_selector_screen.dart';

/// Screen for editing an existing watch party
class EditWatchPartyScreen extends StatefulWidget {
  final WatchParty watchParty;

  const EditWatchPartyScreen({
    Key? key,
    required this.watchParty,
  }) : super(key: key);

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
      text: wp.virtualAttendanceFee?.toStringAsFixed(2) ?? '0.00',
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
            const SnackBar(content: Text('Watch party updated!')),
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
      child: WillPopScope(
        onWillPop: _onWillPop,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Edit Watch Party'),
            actions: [
              if (_hasChanges)
                TextButton(
                  onPressed: _isLoading ? null : _saveChanges,
                  child: const Text('Save', style: TextStyle(color: Colors.white)),
                ),
            ],
          ),
          body: Form(
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
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, color: Colors.orange),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Some fields cannot be edited after the party has started.',
                            style: TextStyle(color: Colors.orange[800], fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Name field
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Party Name',
                    hintText: 'e.g., USA vs Mexico Watch Party',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Description field
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'Tell people about your watch party...',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 24),

                // Visibility toggle (only for upcoming parties)
                if (widget.watchParty.status == WatchPartyStatus.upcoming) ...[
                  const Text(
                    'Visibility',
                    style: TextStyle(fontWeight: FontWeight.w600),
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
                        ? 'Anyone can discover and join this party'
                        : 'Only invited people can join',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  const SizedBox(height: 24),
                ],

                // Game info (read-only)
                const Text(
                  'Game',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.sports_soccer, color: Color(0xFF1E3A8A)),
                    title: Text(widget.watchParty.gameName),
                    subtitle: const Text('Game cannot be changed'),
                    enabled: false,
                  ),
                ),
                const SizedBox(height: 24),

                // Venue selection (can be changed for upcoming parties)
                const Text(
                  'Venue',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                _buildVenueSelector(),
                const SizedBox(height: 24),

                // Max attendees (only for upcoming parties)
                if (widget.watchParty.status == WatchPartyStatus.upcoming) ...[
                  const Text(
                    'Maximum Attendees',
                    style: TextStyle(fontWeight: FontWeight.w600),
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
                              const Expanded(
                                child: Text(
                                  'Virtual Attendance',
                                  style: TextStyle(fontWeight: FontWeight.w600),
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
                              'Allow fans to join virtually and participate in chat',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _feeController,
                              decoration: const InputDecoration(
                                labelText: 'Virtual Attendance Fee',
                                prefixText: '\$ ',
                                hintText: '0.00 for free',
                                border: OutlineInputBorder(),
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
            color: Colors.black.withOpacity(0.05),
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
              : const Text('Save Changes'),
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

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard Changes?'),
        content: const Text('You have unsaved changes. Are you sure you want to leave?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep Editing'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Discard'),
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
