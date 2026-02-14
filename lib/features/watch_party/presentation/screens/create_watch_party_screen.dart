import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../bloc/watch_party_bloc.dart';
import '../widgets/visibility_badge.dart';
import '../../domain/entities/watch_party.dart';
import 'game_selector_screen.dart';
import 'venue_selector_screen.dart';

/// Screen for creating a new watch party
class CreateWatchPartyScreen extends StatefulWidget {
  final String? preselectedGameId;
  final String? preselectedGameName;
  final DateTime? preselectedGameDateTime;

  const CreateWatchPartyScreen({
    super.key,
    this.preselectedGameId,
    this.preselectedGameName,
    this.preselectedGameDateTime,
  });

  @override
  State<CreateWatchPartyScreen> createState() => _CreateWatchPartyScreenState();
}

class _CreateWatchPartyScreenState extends State<CreateWatchPartyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _feeController = TextEditingController(text: '0.00');

  WatchPartyVisibility _visibility = WatchPartyVisibility.public;
  int _maxAttendees = 20;
  bool _allowVirtualAttendance = false;

  // Selected game
  String? _gameId;
  String? _gameName;
  DateTime? _gameDateTime;

  // Selected venue
  String? _venueId;
  String? _venueName;
  String? _venueAddress;
  double? _venueLatitude;
  double? _venueLongitude;

  final List<String> _tags = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _gameId = widget.preselectedGameId;
    _gameName = widget.preselectedGameName;
    _gameDateTime = widget.preselectedGameDateTime;
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
        if (state is WatchPartyCreated) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Watch party created!')),
          );
          Navigator.pop(context, state.watchParty);
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
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Create Watch Party'),
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
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

              // Visibility toggle
              const Text(
                'Visibility',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              VisibilityToggle(
                value: _visibility,
                onChanged: (value) => setState(() => _visibility = value),
              ),
              const SizedBox(height: 8),
              Text(
                _visibility == WatchPartyVisibility.public
                    ? 'Anyone can discover and join this party'
                    : 'Only invited people can join',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
              const SizedBox(height: 24),

              // Game selection
              const Text(
                'Game',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              _buildGameSelector(),
              const SizedBox(height: 24),

              // Venue selection
              const Text(
                'Venue',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              _buildVenueSelector(),
              const SizedBox(height: 24),

              // Max attendees
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
                      min: 2,
                      max: 100,
                      divisions: 49,
                      label: _maxAttendees.toString(),
                      onChanged: (value) {
                        setState(() => _maxAttendees = value.round());
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

              // Virtual attendance
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
                              setState(() => _allowVirtualAttendance = value);
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
    );
  }

  Widget _buildGameSelector() {
    if (_gameName != null && _gameDateTime != null) {
      final dateFormat = DateFormat('MMM d, yyyy');
      final timeFormat = DateFormat('h:mm a');

      return Card(
        child: ListTile(
          leading: const Icon(Icons.sports_soccer, color: Color(0xFF1E3A8A)),
          title: Text(_gameName!),
          subtitle: Text(
            '${dateFormat.format(_gameDateTime!)} at ${timeFormat.format(_gameDateTime!)}',
          ),
          trailing: IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _selectGame,
          ),
        ),
      );
    }

    return OutlinedButton.icon(
      onPressed: _selectGame,
      icon: const Icon(Icons.sports_soccer),
      label: const Text('Select Game'),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
    );
  }

  Widget _buildVenueSelector() {
    if (_venueName != null) {
      return Card(
        child: ListTile(
          leading: const Icon(Icons.location_on, color: Color(0xFFDC2626)),
          title: Text(_venueName!),
          subtitle: _venueAddress != null ? Text(_venueAddress!) : null,
          trailing: IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _selectVenue,
          ),
        ),
      );
    }

    return OutlinedButton.icon(
      onPressed: _selectVenue,
      icon: const Icon(Icons.location_on),
      label: const Text('Select Venue'),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
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
          onPressed: _isLoading ? null : _createWatchParty,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Create Watch Party'),
        ),
      ),
    );
  }

  void _selectGame() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => const GameSelectorScreen(),
      ),
    );

    if (result != null && mounted) {
      setState(() {
        _gameId = result['gameId'] as String?;
        _gameName = result['gameName'] as String?;
        _gameDateTime = result['gameDateTime'] as DateTime?;
      });
    }
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
        _venueId = result['venueId'] as String?;
        _venueName = result['venueName'] as String?;
        _venueAddress = result['venueAddress'] as String?;
        _venueLatitude = result['venueLatitude'] as double?;
        _venueLongitude = result['venueLongitude'] as double?;
      });
    }
  }

  void _createWatchParty() {
    if (!_formKey.currentState!.validate()) return;

    if (_gameId == null || _gameName == null || _gameDateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a game')),
      );
      return;
    }

    if (_venueId == null || _venueName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a venue')),
      );
      return;
    }

    final fee = double.tryParse(_feeController.text) ?? 0.0;

    context.read<WatchPartyBloc>().add(
          CreateWatchPartyEvent(
            name: _nameController.text.trim(),
            description: _descriptionController.text.trim(),
            visibility: _visibility,
            gameId: _gameId!,
            gameName: _gameName!,
            gameDateTime: _gameDateTime!,
            venueId: _venueId!,
            venueName: _venueName!,
            venueAddress: _venueAddress,
            venueLatitude: _venueLatitude,
            venueLongitude: _venueLongitude,
            maxAttendees: _maxAttendees,
            allowVirtualAttendance: _allowVirtualAttendance,
            virtualAttendanceFee: fee,
            tags: _tags,
          ),
        );
  }
}
