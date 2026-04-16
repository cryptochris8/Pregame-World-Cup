import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../l10n/app_localizations.dart';

/// A widget displaying account action buttons for the user profile.
///
/// Shows links to privacy policy and terms, export data, and delete account buttons.
class ProfileAccountActions extends StatelessWidget {
  const ProfileAccountActions({
    super.key,
    required this.onExportData,
    required this.onDeleteAccount,
  });

  final VoidCallback onExportData;
  final VoidCallback onDeleteAccount;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Column(
      children: [
        const SizedBox(height: 24),

        // Privacy Policy and Terms Links
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              InkWell(
                onTap: () => _launchUrl(
                  'https://pregameworldcup.com/privacy',
                  context,
                ),
                child: Text(
                  l10n.privacyPolicy,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.primaryColor,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Text(
                '|',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.textTheme.bodyMedium?.color?.withValues(alpha:0.5),
                ),
              ),
              const SizedBox(width: 16),
              InkWell(
                onTap: () => _launchUrl(
                  'https://pregameworldcup.com/terms',
                  context,
                ),
                child: Text(
                  l10n.termsOfService,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.primaryColor,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Independent app disclaimer
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            l10n.appDisclaimer,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.textTheme.bodyMedium?.color?.withValues(alpha:0.7),
              fontSize: 11,
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Export Data Button
        OutlinedButton.icon(
          onPressed: onExportData,
          icon: const Icon(Icons.download),
          label: Text(l10n.exportMyData),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 12,
            ),
            side: BorderSide(color: theme.primaryColor),
          ),
        ),
        const SizedBox(height: 16),

        // Delete Account Button
        OutlinedButton.icon(
          onPressed: onDeleteAccount,
          icon: const Icon(Icons.delete_forever),
          label: Text(l10n.deleteAccount),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 12,
            ),
            side: BorderSide(color: theme.primaryColor),
          ),
        ),
      ],
    );
  }

  Future<void> _launchUrl(String urlString, BuildContext context) async {
    final uri = Uri.parse(urlString);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open URL')),
        );
      }
    }
  }
}
