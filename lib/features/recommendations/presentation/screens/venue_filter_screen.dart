import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/venue_filter.dart';

class VenueFilterScreen extends StatefulWidget {
  final VenueFilter initialFilter;
  final Function(VenueFilter) onFilterChanged;

  const VenueFilterScreen({
    super.key,
    required this.initialFilter,
    required this.onFilterChanged,
  });

  @override
  State<VenueFilterScreen> createState() => _VenueFilterScreenState();
}

class _VenueFilterScreenState extends State<VenueFilterScreen> {
  late VenueFilter _currentFilter;
  
  // For the distance slider
  late double _distanceValue;
  
  // For the rating filter
  late double? _ratingValue;
  
  // Maps for venue type checkboxes
  late Map<VenueType, bool> _venueTypeSelections;
  
  // Text controller for keyword search
  late TextEditingController _keywordController;

  @override
  void initState() {
    super.initState();
    _currentFilter = widget.initialFilter;
    _distanceValue = widget.initialFilter.maxDistance;
    _ratingValue = widget.initialFilter.minRating;
    _keywordController = TextEditingController(text: widget.initialFilter.keyword);
    
    // Initialize venue type selections based on current filter
    _venueTypeSelections = {
      for (var type in VenueType.values) 
        type: widget.initialFilter.venueTypes.contains(type)
    };
  }
  
  @override
  void dispose() {
    _keywordController.dispose();
    super.dispose();
  }

  void _updateFilter() {
    // Get selected venue types
    List<VenueType> selectedTypes = _venueTypeSelections.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();

    // If nothing is selected, default to all venue types
    if (selectedTypes.isEmpty) {
      selectedTypes = [VenueType.bar, VenueType.restaurant];
    }

    // Update the filter
    _currentFilter = _currentFilter.copyWith(
      venueTypes: selectedTypes,
      maxDistance: _distanceValue,
      minRating: _ratingValue,
      openNow: _currentFilter.openNow,
      priceLevel: _currentFilter.priceLevel,
      keyword: _keywordController.text.isEmpty ? null : _keywordController.text,
    );

    // Notify the parent widget of the change
    widget.onFilterChanged(_currentFilter);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.filterVenues),
        actions: [
          TextButton(
            onPressed: () {
              // Reset filter to default and go back
              setState(() {
                _currentFilter = const VenueFilter();
                _distanceValue = _currentFilter.maxDistance;
                _ratingValue = _currentFilter.minRating;
                _keywordController.text = _currentFilter.keyword ?? '';
                _venueTypeSelections = {
                  for (var type in VenueType.values)
                    type: _currentFilter.venueTypes.contains(type)
                };
              });
              _updateFilter();
              Navigator.pop(context);
            },
            child: Text(l10n.resetLabel, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Venue Types Section
              Text(
                l10n.venueTypes,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                children: VenueType.values.map((type) {
                  return FilterChip(
                    label: Text(_getVenueTypeLabel(type)),
                    selected: _venueTypeSelections[type] ?? false,
                    onSelected: (selected) {
                      setState(() {
                        _venueTypeSelections[type] = selected;
                      });
                      _updateFilter();
                    },
                    backgroundColor: Colors.grey[800],
                    selectedColor: Theme.of(context).colorScheme.primary,
                    checkmarkColor: Colors.white,
                  );
                }).toList(),
              ),
              
              const SizedBox(height: 24),
              
              // Distance Section
              Text(
                l10n.maximumDistance,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              Row(
                children: [
                  Expanded(
                    child: Slider(
                      min: 0.5,
                      max: 10.0,
                      divisions: 19,
                      value: _distanceValue,
                      label: '${_distanceValue.toStringAsFixed(1)} km',
                      onChanged: (value) {
                        setState(() {
                          _distanceValue = value;
                        });
                      },
                      onChangeEnd: (value) {
                        _updateFilter();
                      },
                    ),
                  ),
                  Text('${_distanceValue.toStringAsFixed(1)} km'),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Minimum Rating Section
              Text(
                l10n.minimumRating,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              Row(
                children: [
                  Expanded(
                    child: Slider(
                      min: 1.0,
                      max: 5.0,
                      divisions: 8,
                      value: _ratingValue ?? 1.0,
                      label: (_ratingValue ?? 1.0).toStringAsFixed(1),
                      onChanged: (value) {
                        setState(() {
                          _ratingValue = value;
                        });
                      },
                      onChangeEnd: (value) {
                        _updateFilter();
                      },
                    ),
                  ),
                  Row(
                    children: [
                      Text((_ratingValue ?? 1.0).toStringAsFixed(1)),
                      const Icon(Icons.star, color: Colors.amber, size: 18),
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Open Now Section
              SwitchListTile(
                title: Text(
                  l10n.openNow,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                value: _currentFilter.openNow,
                onChanged: (value) {
                  setState(() {
                    _currentFilter = _currentFilter.copyWith(openNow: value);
                  });
                  _updateFilter();
                },
                tileColor: Colors.grey[800],
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Price Level Section
              Text(
                l10n.priceLevel,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8.0,
                children: PriceLevel.values.map((price) {
                  return ChoiceChip(
                    label: Text(_getPriceLevelLabel(price)),
                    selected: _currentFilter.priceLevel == price,
                    onSelected: (selected) {
                      setState(() {
                        _currentFilter = _currentFilter.copyWith(
                          priceLevel: selected ? price : null,
                        );
                      });
                      _updateFilter();
                    },
                    backgroundColor: Colors.grey[800],
                    selectedColor: Theme.of(context).colorScheme.primary,
                  );
                }).toList(),
              ),
              
              const SizedBox(height: 24),
              
              // Keyword Search Section
              Text(
                l10n.searchSpecificFeatures,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _keywordController,
                decoration: InputDecoration(
                  hintText: l10n.keywordSearchHint,
                  filled: true,
                  fillColor: Colors.grey[800],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  suffixIcon: const Icon(Icons.search),
                ),
                onChanged: (value) {
                  // Update will happen when Apply button is pressed or user submits
                },
                onSubmitted: (value) {
                  _updateFilter();
                },
              ),
              
              const SizedBox(height: 32),
              
              // Apply Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    _updateFilter();
                    Navigator.pop(context);
                  },
                  child: Text(l10n.applyFilters),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getVenueTypeLabel(VenueType type) {
    switch (type) {
      case VenueType.bar:
        return 'Bars';
      case VenueType.restaurant:
        return 'Restaurants';
      case VenueType.cafe:
        return 'Cafés';
      case VenueType.nightclub:
        return 'Nightclubs';
      case VenueType.bakery:
        return 'Bakeries';
      case VenueType.liquorStore:
        return 'Liquor Stores';
    }
  }

  String _getPriceLevelLabel(PriceLevel level) {
    switch (level) {
      case PriceLevel.inexpensive:
        return '\$';
      case PriceLevel.moderate:
        return '\$\$';
      case PriceLevel.expensive:
        return '\$\$\$';
      case PriceLevel.veryExpensive:
        return '\$\$\$\$';
    }
  }
} 