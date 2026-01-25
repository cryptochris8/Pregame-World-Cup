import 'package:flutter/material.dart';

import '../../../../core/services/localization_service.dart';
import '../../../../l10n/app_localizations.dart';

/// Screen for selecting app language
class LanguageSelectorScreen extends StatefulWidget {
  const LanguageSelectorScreen({super.key});

  @override
  State<LanguageSelectorScreen> createState() => _LanguageSelectorScreenState();
}

class _LanguageSelectorScreenState extends State<LanguageSelectorScreen> {
  late LocalizationService _localizationService;
  AppLanguage? _selectedLanguage;

  @override
  void initState() {
    super.initState();
    _initService();
  }

  Future<void> _initService() async {
    _localizationService = await LocalizationService.getInstance();
    setState(() {
      _selectedLanguage = _localizationService.currentLanguage;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.selectLanguage),
      ),
      body: _selectedLanguage == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                // Info banner
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Choose your preferred language. The app will restart to apply changes.',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),

                // Language options
                ...AppLanguage.values.map((language) {
                  return _LanguageOptionTile(
                    language: language,
                    isSelected: _selectedLanguage == language,
                    onTap: () => _selectLanguage(language),
                  );
                }),

                const SizedBox(height: 24),

                // Current language info
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Currently using: ${_localizationService.currentLanguageDisplayName}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
    );
  }

  Future<void> _selectLanguage(AppLanguage language) async {
    if (_selectedLanguage == language) return;

    setState(() {
      _selectedLanguage = language;
    });

    await _localizationService.setLanguage(language);

    if (mounted) {
      // Show confirmation
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Language changed to ${language.nativeName}',
          ),
          action: SnackBarAction(
            label: 'OK',
            onPressed: () {},
          ),
        ),
      );
    }
  }
}

/// Individual language option tile
class _LanguageOptionTile extends StatelessWidget {
  final AppLanguage language;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageOptionTile({
    required this.language,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primaryContainer
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            language.flagEmoji,
            style: const TextStyle(fontSize: 24),
          ),
        ),
      ),
      title: Text(
        language.nativeName,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      subtitle: language == AppLanguage.system
          ? Text(
              _getSystemLanguageDescription(),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            )
          : Text(
              _getLanguageDescription(language),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
      trailing: isSelected
          ? Icon(
              Icons.check_circle,
              color: theme.colorScheme.primary,
            )
          : Icon(
              Icons.circle_outlined,
              color: theme.colorScheme.outline,
            ),
    );
  }

  String _getSystemLanguageDescription() {
    final systemLanguage = LocalizationService.detectSystemLanguage();
    return 'Uses device settings (${systemLanguage.nativeName})';
  }

  String _getLanguageDescription(AppLanguage language) {
    switch (language) {
      case AppLanguage.english:
        return 'English (United States)';
      case AppLanguage.spanish:
        return 'Spanish (Mexico)';
      case AppLanguage.portuguese:
        return 'Portuguese (Brazil)';
      case AppLanguage.french:
        return 'French (Canada)';
      case AppLanguage.system:
        return '';
    }
  }
}

/// Compact language selector for settings screen
class LanguageSelectorTile extends StatelessWidget {
  const LanguageSelectorTile({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return FutureBuilder<LocalizationService>(
      future: LocalizationService.getInstance(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return ListTile(
            leading: const Icon(Icons.language),
            title: Text(l10n.language),
            trailing: const CircularProgressIndicator(),
          );
        }

        final service = snapshot.data!;

        return ListTile(
          leading: const Icon(Icons.language),
          title: Text(l10n.language),
          subtitle: Text(service.currentLanguageDisplayName),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const LanguageSelectorScreen(),
              ),
            );
          },
        );
      },
    );
  }
}

/// Quick language picker bottom sheet
class QuickLanguagePicker extends StatelessWidget {
  const QuickLanguagePicker({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const QuickLanguagePicker(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return FutureBuilder<LocalizationService>(
      future: LocalizationService.getInstance(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox(
            height: 200,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final service = snapshot.data!;

        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Title
              Text(
                l10n.selectLanguage,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Language options in grid
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: AppLanguage.values.map((language) {
                  final isSelected = service.currentLanguage == language;

                  return ChoiceChip(
                    selected: isSelected,
                    onSelected: (_) async {
                      await service.setLanguage(language);
                      if (context.mounted) {
                        Navigator.pop(context);
                      }
                    },
                    avatar: Text(language.flagEmoji),
                    label: Text(language.nativeName),
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
}
