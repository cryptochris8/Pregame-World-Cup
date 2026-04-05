import 'package:flutter/material.dart';

import '../../../../config/app_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/report.dart';
import '../../domain/services/moderation_service.dart';

/// Bottom sheet for reporting content or users
class ReportBottomSheet extends StatefulWidget {
  final ReportableContentType contentType;
  final String contentId;
  final String? contentOwnerId;
  final String? contentOwnerDisplayName;
  final String? contentSnapshot;
  final String? title;

  const ReportBottomSheet({
    super.key,
    required this.contentType,
    required this.contentId,
    this.contentOwnerId,
    this.contentOwnerDisplayName,
    this.contentSnapshot,
    this.title,
  });

  /// Show the report bottom sheet
  static Future<Report?> show({
    required BuildContext context,
    required ReportableContentType contentType,
    required String contentId,
    String? contentOwnerId,
    String? contentOwnerDisplayName,
    String? contentSnapshot,
    String? title,
  }) async {
    return showModalBottomSheet<Report>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ReportBottomSheet(
        contentType: contentType,
        contentId: contentId,
        contentOwnerId: contentOwnerId,
        contentOwnerDisplayName: contentOwnerDisplayName,
        contentSnapshot: contentSnapshot,
        title: title,
      ),
    );
  }

  @override
  State<ReportBottomSheet> createState() => _ReportBottomSheetState();
}

class _ReportBottomSheetState extends State<ReportBottomSheet> {
  final ModerationService _moderationService = ModerationService();
  final TextEditingController _detailsController = TextEditingController();

  ReportReason? _selectedReason;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _detailsController.dispose();
    super.dispose();
  }

  Future<void> _submitReport() async {
    final l10n = AppLocalizations.of(context);

    if (_selectedReason == null) {
      setState(() {
        _errorMessage = l10n.reportSelectReason;
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    final report = await _moderationService.submitReport(
      contentType: widget.contentType,
      contentId: widget.contentId,
      contentOwnerId: widget.contentOwnerId,
      contentOwnerDisplayName: widget.contentOwnerDisplayName,
      reason: _selectedReason!,
      additionalDetails:
          _detailsController.text.isNotEmpty ? _detailsController.text : null,
      contentSnapshot: widget.contentSnapshot,
    );

    setState(() {
      _isSubmitting = false;
    });

    if (mounted) {
      if (report != null) {
        Navigator.of(context).pop(report);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.reportSubmittedSuccess),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        setState(() {
          _errorMessage = l10n.reportSubmitFailed;
        });
      }
    }
  }

  String _getDisplayTitle(AppLocalizations l10n) {
    if (widget.title != null) return widget.title!;
    return l10n.reportContentType(widget.contentType.name);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.backgroundDark,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.textTertiary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    const Icon(
                      Icons.flag_outlined,
                      color: AppTheme.primaryOrange,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _getDisplayTitle(l10n),
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textWhite,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close, color: AppTheme.textSecondary),
                    ),
                  ],
                ),
              ),

              const Divider(color: AppTheme.backgroundElevated),

              // Content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  children: [
                    // Content preview if available
                    if (widget.contentSnapshot != null) ...[
                      Text(
                        l10n.reportContentBeingReported,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.textTertiary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.backgroundCard,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppTheme.backgroundElevated),
                        ),
                        child: Text(
                          widget.contentSnapshot!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Reason selection
                    Text(
                      l10n.reportWhyReporting,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textWhite,
                      ),
                    ),
                    const SizedBox(height: 12),

                    ...ReportReason.values.map(
                      (reason) => _ReasonTile(
                        reason: reason,
                        isSelected: _selectedReason == reason,
                        onTap: () {
                          setState(() {
                            _selectedReason = reason;
                            _errorMessage = null;
                          });
                        },
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Additional details
                    Text(
                      l10n.reportAdditionalDetails,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textWhite,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _detailsController,
                      maxLines: 4,
                      maxLength: 500,
                      style: const TextStyle(color: AppTheme.textLight),
                      decoration: InputDecoration(
                        hintText: l10n.reportDetailsHint,
                        hintStyle: const TextStyle(color: AppTheme.textTertiary),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppTheme.backgroundElevated),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppTheme.backgroundElevated),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppTheme.primaryOrange),
                        ),
                        filled: true,
                        fillColor: AppTheme.backgroundCard,
                        counterStyle: const TextStyle(color: AppTheme.textTertiary),
                      ),
                    ),

                    // Error message
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.error.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: theme.colorScheme.error,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: TextStyle(
                                  color: theme.colorScheme.error,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 24),

                    // Submit button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submitReport,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryOrange,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                l10n.reportSubmitButton,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Disclaimer
                    Text(
                      l10n.reportDisclaimer,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.textTertiary,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ReasonTile extends StatelessWidget {
  final ReportReason reason;
  final bool isSelected;
  final VoidCallback onTap;

  const _ReasonTile({
    required this.reason,
    required this.isSelected,
    required this.onTap,
  });

  String _getLocalizedDescription(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    switch (reason) {
      case ReportReason.spam:
        return l10n.reportReasonSpam;
      case ReportReason.harassment:
        return l10n.reportReasonHarassment;
      case ReportReason.hateSpeech:
        return l10n.reportReasonHateSpeech;
      case ReportReason.violence:
        return l10n.reportReasonViolence;
      case ReportReason.sexualContent:
        return l10n.reportReasonSexualContent;
      case ReportReason.misinformation:
        return l10n.reportReasonMisinformation;
      case ReportReason.impersonation:
        return l10n.reportReasonImpersonation;
      case ReportReason.scam:
        return l10n.reportReasonScam;
      case ReportReason.inappropriateContent:
        return l10n.reportReasonInappropriate;
      case ReportReason.other:
        return l10n.reportReasonOther;
    }
  }

  IconData get _reasonIcon {
    switch (reason) {
      case ReportReason.spam:
        return Icons.mark_email_unread_outlined;
      case ReportReason.harassment:
        return Icons.person_off_outlined;
      case ReportReason.hateSpeech:
        return Icons.warning_amber_outlined;
      case ReportReason.violence:
        return Icons.dangerous_outlined;
      case ReportReason.sexualContent:
        return Icons.no_adult_content;
      case ReportReason.misinformation:
        return Icons.fact_check_outlined;
      case ReportReason.impersonation:
        return Icons.badge_outlined;
      case ReportReason.scam:
        return Icons.money_off_outlined;
      case ReportReason.inappropriateContent:
        return Icons.block_outlined;
      case ReportReason.other:
        return Icons.more_horiz;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppTheme.primaryOrange : AppTheme.backgroundElevated,
              width: isSelected ? 2 : 1,
            ),
            color: isSelected
                ? AppTheme.primaryOrange.withValues(alpha: 0.1)
                : AppTheme.backgroundCard,
          ),
          child: Row(
            children: [
              Icon(
                _reasonIcon,
                color: isSelected
                    ? AppTheme.primaryOrange
                    : AppTheme.textTertiary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      Report(
                        reportId: '',
                        reporterId: '',
                        reporterDisplayName: '',
                        contentType: ReportableContentType.user,
                        contentId: '',
                        reason: reason,
                        createdAt: DateTime.now(),
                      ).reasonDisplayText,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: isSelected
                            ? AppTheme.primaryOrange
                            : AppTheme.textWhite,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _getLocalizedDescription(context),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                const Icon(
                  Icons.check_circle,
                  color: AppTheme.primaryOrange,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
