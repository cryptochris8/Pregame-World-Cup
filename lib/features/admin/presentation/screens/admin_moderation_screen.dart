import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';

import '../../../moderation/domain/entities/report.dart';
import '../../domain/services/admin_service.dart';

/// Admin screen for content moderation
class AdminModerationScreen extends StatefulWidget {
  const AdminModerationScreen({super.key});

  @override
  State<AdminModerationScreen> createState() => _AdminModerationScreenState();
}

class _AdminModerationScreenState extends State<AdminModerationScreen> {
  final AdminService _adminService = AdminService();

  List<Report> _reports = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    setState(() => _isLoading = true);

    final reports = await _adminService.getPendingReports();

    setState(() {
      _reports = reports;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.contentModeration),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadReports,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _reports.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        size: 64,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.noPendingReports,
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.allCaughtUp,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadReports,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _reports.length,
                    itemBuilder: (context, index) {
                      final report = _reports[index];
                      return _buildReportCard(theme, report);
                    },
                  ),
                ),
    );
  }

  Widget _buildReportCard(ThemeData theme, Report report) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                _getContentTypeIcon(report.contentType),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getContentTypeLabel(report.contentType),
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        AppLocalizations.of(context).reportedBy(report.reporterDisplayName),
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                _buildReasonChip(theme, report.reason),
              ],
            ),
            const Divider(height: 24),

            // Content info
            if (report.contentOwnerDisplayName != null)
              _buildInfoRow(AppLocalizations.of(context).contentOwner, report.contentOwnerDisplayName!),
            _buildInfoRow(AppLocalizations.of(context).contentId, report.contentId),
            if (report.contentSnapshot != null && report.contentSnapshot!.isNotEmpty)
              _buildContentSnapshot(theme, report.contentSnapshot!),
            if (report.additionalDetails != null && report.additionalDetails!.isNotEmpty)
              _buildInfoRow(AppLocalizations.of(context).details, report.additionalDetails!),
            _buildInfoRow(AppLocalizations.of(context).reported, _formatDateTime(report.createdAt)),

            const SizedBox(height: 16),

            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => _dismissReport(report),
                  child: Text(AppLocalizations.of(context).dismiss),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () => _warnUser(report),
                  style: TextButton.styleFrom(foregroundColor: Colors.orange),
                  child: Text(AppLocalizations.of(context).warn),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => _showActionDialog(report),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: Text(AppLocalizations.of(context).takeAction),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _getContentTypeIcon(ReportableContentType type) {
    IconData icon;
    Color color;

    switch (type) {
      case ReportableContentType.user:
        icon = Icons.person;
        color = Colors.blue;
        break;
      case ReportableContentType.message:
        icon = Icons.message;
        color = Colors.green;
        break;
      case ReportableContentType.watchParty:
        icon = Icons.groups;
        color = Colors.orange;
        break;
      case ReportableContentType.chatRoom:
        icon = Icons.chat_bubble;
        color = Colors.purple;
        break;
      case ReportableContentType.comment:
        icon = Icons.comment;
        color = Colors.teal;
        break;
      case ReportableContentType.prediction:
        icon = Icons.analytics;
        color = Colors.indigo;
        break;
    }

    return CircleAvatar(
      backgroundColor: color.withValues(alpha:0.2),
      child: Icon(icon, color: color, size: 20),
    );
  }

  String _getContentTypeLabel(ReportableContentType type) {
    switch (type) {
      case ReportableContentType.user:
        return 'User Profile';
      case ReportableContentType.message:
        return 'Message';
      case ReportableContentType.watchParty:
        return 'Watch Party';
      case ReportableContentType.chatRoom:
        return 'Chat Room';
      case ReportableContentType.comment:
        return 'Comment';
      case ReportableContentType.prediction:
        return 'Prediction';
    }
  }

  Widget _buildReasonChip(ThemeData theme, ReportReason reason) {
    Color color;
    switch (reason) {
      case ReportReason.spam:
        color = Colors.grey;
        break;
      case ReportReason.harassment:
      case ReportReason.hateSpeech:
        color = Colors.red;
        break;
      case ReportReason.inappropriateContent:
        color = Colors.orange;
        break;
      case ReportReason.misinformation:
        color = Colors.amber;
        break;
      case ReportReason.impersonation:
        color = Colors.purple;
        break;
      case ReportReason.violence:
        color = Colors.red.shade900;
        break;
      case ReportReason.sexualContent:
        color = Colors.pink.shade800;
        break;
      case ReportReason.scam:
        color = Colors.deepOrange;
        break;
      case ReportReason.other:
        color = Colors.grey;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha:0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        reason.name.replaceAllMapped(
          RegExp(r'([A-Z])'),
          (match) => ' ${match.group(1)}',
        ).trim(),
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Widget _buildContentSnapshot(ThemeData theme, String content) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha:0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context).reportedContent,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            content,
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _dismissReport(Report report) async {
    final success = await _adminService.resolveReport(
      report.reportId,
      ModerationAction.none,
      'Report dismissed - no violation found',
    );

    if (success && mounted) {
      setState(() {
        _reports.removeWhere((r) => r.reportId == report.reportId);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).reportDismissed)),
      );
    }
  }

  Future<void> _warnUser(Report report) async {
    if (report.contentOwnerId == null) return;

    final success = await _adminService.resolveReport(
      report.reportId,
      ModerationAction.warning,
      'Warning issued to user',
    );

    if (success && mounted) {
      setState(() {
        _reports.removeWhere((r) => r.reportId == report.reportId);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).warningIssued)),
      );
    }
  }

  void _showActionDialog(Report report) {
    final l10n = AppLocalizations.of(context);
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                l10n.takeAction,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.orange),
              title: Text(l10n.removeContent),
              subtitle: Text(l10n.deleteReportedContent),
              onTap: () async {
                Navigator.pop(context);
                await _takeAction(report, ModerationAction.contentRemoved);
              },
            ),
            ListTile(
              leading: const Icon(Icons.volume_off, color: Colors.blue),
              title: Text(l10n.muteUser24h),
              subtitle: Text(l10n.temporarilyPreventPosting),
              onTap: () async {
                Navigator.pop(context);
                await _takeAction(report, ModerationAction.temporaryMute);
              },
            ),
            ListTile(
              leading: const Icon(Icons.block, color: Colors.red),
              title: Text(l10n.suspendUser7Days),
              subtitle: Text(l10n.suspendUserAccount),
              onTap: () async {
                Navigator.pop(context);
                await _takeAction(report, ModerationAction.temporarySuspension);
              },
            ),
            ListTile(
              leading: const Icon(Icons.gavel, color: Colors.purple),
              title: Text(l10n.permanentBan),
              subtitle: Text(l10n.permanentlyBanUser),
              onTap: () async {
                Navigator.pop(context);
                await _takeAction(report, ModerationAction.permanentBan);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _takeAction(Report report, ModerationAction action) async {
    final success = await _adminService.resolveReport(
      report.reportId,
      action,
      'Action taken: ${action.name}',
    );

    if (success && mounted) {
      setState(() {
        _reports.removeWhere((r) => r.reportId == report.reportId);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).actionTaken(action.name))),
      );
    }
  }
}
