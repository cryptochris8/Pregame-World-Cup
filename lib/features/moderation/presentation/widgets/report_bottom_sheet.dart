import 'package:flutter/material.dart';

import '../../domain/entities/report.dart';
import '../../domain/services/moderation_service.dart';

/// Bottom sheet for reporting content or users
class ReportBottomSheet extends StatefulWidget {
  final ReportableContentType contentType;
  final String contentId;
  final String? contentOwnerId;
  final String? contentOwnerDisplayName;
  final String? contentSnapshot;
  final String title;

  const ReportBottomSheet({
    super.key,
    required this.contentType,
    required this.contentId,
    this.contentOwnerId,
    this.contentOwnerDisplayName,
    this.contentSnapshot,
    this.title = 'Report',
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
        title: title ?? 'Report ${contentType.name}',
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
    if (_selectedReason == null) {
      setState(() {
        _errorMessage = 'Please select a reason for your report';
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
          const SnackBar(
            content: Text('Report submitted successfully. Thank you.'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        setState(() {
          _errorMessage = 'Failed to submit report. Please try again.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
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
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Icon(
                      Icons.flag_outlined,
                      color: theme.colorScheme.error,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      widget.title,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),

              const Divider(),

              // Content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  children: [
                    // Content preview if available
                    if (widget.contentSnapshot != null) ...[
                      Text(
                        'Content being reported:',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Text(
                          widget.contentSnapshot!,
                          style: theme.textTheme.bodyMedium,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Reason selection
                    Text(
                      'Why are you reporting this?',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
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
                      'Additional details (optional)',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _detailsController,
                      maxLines: 4,
                      maxLength: 500,
                      decoration: InputDecoration(
                        hintText:
                            'Provide any additional context that might help us review this report...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
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
                          backgroundColor: theme.colorScheme.error,
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
                            : const Text(
                                'Submit Report',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Disclaimer
                    Text(
                      'Reports are reviewed by our moderation team. False reports may result in action against your account.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
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

  String get _reasonDescription {
    switch (reason) {
      case ReportReason.spam:
        return 'Unwanted commercial content or repetitive messages';
      case ReportReason.harassment:
        return 'Bullying, threats, or targeted attacks';
      case ReportReason.hateSpeech:
        return 'Discrimination based on race, religion, gender, etc.';
      case ReportReason.violence:
        return 'Threats of violence or graphic content';
      case ReportReason.sexualContent:
        return 'Sexually explicit or suggestive content';
      case ReportReason.misinformation:
        return 'False or misleading information';
      case ReportReason.impersonation:
        return 'Pretending to be someone else';
      case ReportReason.scam:
        return 'Fraud, phishing, or suspicious requests';
      case ReportReason.inappropriateContent:
        return 'Content that violates community guidelines';
      case ReportReason.other:
        return 'Other issue not listed above';
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
              color: isSelected ? theme.colorScheme.primary : Colors.grey[300]!,
              width: isSelected ? 2 : 1,
            ),
            color: isSelected
                ? theme.colorScheme.primary.withValues(alpha: 0.05)
                : Colors.transparent,
          ),
          child: Row(
            children: [
              Icon(
                _reasonIcon,
                color: isSelected
                    ? theme.colorScheme.primary
                    : Colors.grey[600],
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
                            ? theme.colorScheme.primary
                            : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _reasonDescription,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: theme.colorScheme.primary,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
