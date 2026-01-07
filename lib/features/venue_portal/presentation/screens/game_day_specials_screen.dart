import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/entities.dart';
import '../bloc/venue_enhancement_cubit.dart';
import '../bloc/venue_enhancement_state.dart';

/// Screen for venue owners to manage game day specials and deals
class GameDaySpecialsScreen extends StatelessWidget {
  final String venueId;
  final String venueName;

  const GameDaySpecialsScreen({
    super.key,
    required this.venueId,
    required this.venueName,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VenueEnhancementCubit, VenueEnhancementState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Game Day Specials'),
          ),
          body: state.gameSpecials.isEmpty
              ? _buildEmptyState(context)
              : _buildSpecialsList(context, state),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showAddSpecialDialog(context),
            icon: const Icon(Icons.add),
            label: const Text('Add Special'),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.local_offer_outlined,
              size: 64,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'No Specials Yet',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Add game day specials to attract more fans to your venue during matches.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => _showAddSpecialDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('Create Your First Special'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecialsList(BuildContext context, VenueEnhancementState state) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: state.gameSpecials.length,
      itemBuilder: (context, index) {
        final special = state.gameSpecials[index];
        return _buildSpecialCard(context, special);
      },
    );
  }

  Widget _buildSpecialCard(BuildContext context, GameDaySpecial special) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: special.isActive
                    ? colorScheme.primaryContainer
                    : colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.local_offer,
                color: special.isActive
                    ? colorScheme.onPrimaryContainer
                    : colorScheme.onSurfaceVariant,
              ),
            ),
            title: Text(
              special.title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(special.description),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (special.displayPrice.isNotEmpty)
                  Chip(
                    label: Text(
                      special.displayPrice,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    backgroundColor: colorScheme.secondaryContainer,
                  ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        _showEditSpecialDialog(context, special);
                        break;
                      case 'toggle':
                        final updated = special.copyWith(isActive: !special.isActive);
                        context.read<VenueEnhancementCubit>().updateGameSpecial(updated);
                        break;
                      case 'delete':
                        _showDeleteConfirmation(context, special);
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: ListTile(
                        leading: Icon(Icons.edit),
                        title: Text('Edit'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    PopupMenuItem(
                      value: 'toggle',
                      child: ListTile(
                        leading: Icon(
                          special.isActive ? Icons.pause : Icons.play_arrow,
                        ),
                        title: Text(special.isActive ? 'Deactivate' : 'Activate'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: ListTile(
                        leading: Icon(Icons.delete, color: Colors.red),
                        title: Text('Delete', style: TextStyle(color: Colors.red)),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
            child: Row(
              children: [
                _buildStatusChip(
                  context,
                  label: special.isActive ? 'Active' : 'Inactive',
                  isActive: special.isActive,
                ),
                const SizedBox(width: 8),
                _buildStatusChip(
                  context,
                  label: special.validFor.displayName,
                  isActive: true,
                ),
                if (special.isExpired) ...[
                  const SizedBox(width: 8),
                  _buildStatusChip(
                    context,
                    label: 'Expired',
                    isActive: false,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(
    BuildContext context, {
    required String label,
    required bool isActive,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isActive
            ? colorScheme.primaryContainer
            : colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: isActive
              ? colorScheme.onPrimaryContainer
              : colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  void _showAddSpecialDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _SpecialEditorSheet(
        onSave: (special) {
          context.read<VenueEnhancementCubit>().addGameSpecial(special);
        },
      ),
    );
  }

  void _showEditSpecialDialog(BuildContext context, GameDaySpecial special) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _SpecialEditorSheet(
        existing: special,
        onSave: (updated) {
          context.read<VenueEnhancementCubit>().updateGameSpecial(updated);
        },
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, GameDaySpecial special) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Special?'),
        content: Text('Are you sure you want to delete "${special.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              context.read<VenueEnhancementCubit>().deleteGameSpecial(special.id);
              Navigator.pop(context);
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

/// Bottom sheet for creating/editing specials
class _SpecialEditorSheet extends StatefulWidget {
  final GameDaySpecial? existing;
  final Function(GameDaySpecial) onSave;

  const _SpecialEditorSheet({
    this.existing,
    required this.onSave,
  });

  @override
  State<_SpecialEditorSheet> createState() => _SpecialEditorSheetState();
}

class _SpecialEditorSheetState extends State<_SpecialEditorSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _discountController;
  late SpecialValidFor _validFor;
  late bool _isActive;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.existing?.title ?? '');
    _descriptionController =
        TextEditingController(text: widget.existing?.description ?? '');
    _priceController = TextEditingController(
      text: widget.existing?.price?.toString() ?? '',
    );
    _discountController = TextEditingController(
      text: widget.existing?.discountPercent?.toString() ?? '',
    );
    _validFor = widget.existing?.validFor ?? SpecialValidFor.allMatches;
    _isActive = widget.existing?.isActive ?? true;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _discountController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final special = widget.existing != null
        ? widget.existing!.copyWith(
            title: _titleController.text,
            description: _descriptionController.text,
            price: double.tryParse(_priceController.text),
            discountPercent: int.tryParse(_discountController.text),
            validFor: _validFor,
            isActive: _isActive,
          )
        : GameDaySpecial.create(
            title: _titleController.text,
            description: _descriptionController.text,
            price: double.tryParse(_priceController.text),
            discountPercent: int.tryParse(_discountController.text),
          );

    widget.onSave(special);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.existing != null ? 'Edit Special' : 'New Special',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  hintText: 'e.g., \$5 Pitcher Special',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Describe your special...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _priceController,
                      decoration: const InputDecoration(
                        labelText: 'Price',
                        hintText: '5.00',
                        prefixText: '\$ ',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _discountController,
                      decoration: const InputDecoration(
                        labelText: 'Discount',
                        hintText: '20',
                        suffixText: '%',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<SpecialValidFor>(
                value: _validFor,
                decoration: const InputDecoration(
                  labelText: 'Valid For',
                  border: OutlineInputBorder(),
                ),
                items: SpecialValidFor.values
                    .map((v) => DropdownMenuItem(
                          value: v,
                          child: Text(v.displayName),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _validFor = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                value: _isActive,
                onChanged: (value) {
                  setState(() {
                    _isActive = value;
                  });
                },
                title: const Text('Active'),
                subtitle: const Text('Special is visible to users'),
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _save,
                  child: Text(widget.existing != null ? 'Update' : 'Create'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
