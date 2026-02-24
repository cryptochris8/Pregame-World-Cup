import 'package:flutter/material.dart';
import '../../../../../l10n/app_localizations.dart';

/// Shown when the venue has already been claimed by another user.
class AlreadyClaimedView extends StatelessWidget {
  const AlreadyClaimedView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock, size: 64, color: Colors.white38),
            const SizedBox(height: 16),
            Text(
              l10n.venueAlreadyManaged,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.venueAlreadyManagedDesc,
              style: const TextStyle(color: Colors.white60, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white70,
                side: const BorderSide(color: Colors.white24),
              ),
              child: Text(l10n.goBack),
            ),
          ],
        ),
      ),
    );
  }
}
