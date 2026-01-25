import 'package:flutter/material.dart';

import '../../domain/entities/report.dart';
import 'report_bottom_sheet.dart';

/// A button widget for reporting content
class ReportButton extends StatelessWidget {
  final ReportableContentType contentType;
  final String contentId;
  final String? contentOwnerId;
  final String? contentOwnerDisplayName;
  final String? contentSnapshot;
  final Widget? child;
  final bool showLabel;
  final Color? iconColor;
  final double iconSize;

  const ReportButton({
    super.key,
    required this.contentType,
    required this.contentId,
    this.contentOwnerId,
    this.contentOwnerDisplayName,
    this.contentSnapshot,
    this.child,
    this.showLabel = false,
    this.iconColor,
    this.iconSize = 20,
  });

  /// Factory for reporting a user
  factory ReportButton.user({
    Key? key,
    required String userId,
    required String displayName,
    bool showLabel = false,
    Color? iconColor,
    double iconSize = 20,
  }) {
    return ReportButton(
      key: key,
      contentType: ReportableContentType.user,
      contentId: userId,
      contentOwnerId: userId,
      contentOwnerDisplayName: displayName,
      showLabel: showLabel,
      iconColor: iconColor,
      iconSize: iconSize,
    );
  }

  /// Factory for reporting a message
  factory ReportButton.message({
    Key? key,
    required String messageId,
    required String senderId,
    required String senderDisplayName,
    required String messageContent,
    bool showLabel = false,
    Color? iconColor,
    double iconSize = 20,
  }) {
    return ReportButton(
      key: key,
      contentType: ReportableContentType.message,
      contentId: messageId,
      contentOwnerId: senderId,
      contentOwnerDisplayName: senderDisplayName,
      contentSnapshot: messageContent,
      showLabel: showLabel,
      iconColor: iconColor,
      iconSize: iconSize,
    );
  }

  /// Factory for reporting a watch party
  factory ReportButton.watchParty({
    Key? key,
    required String watchPartyId,
    required String hostId,
    required String hostDisplayName,
    required String watchPartyName,
    bool showLabel = false,
    Color? iconColor,
    double iconSize = 20,
  }) {
    return ReportButton(
      key: key,
      contentType: ReportableContentType.watchParty,
      contentId: watchPartyId,
      contentOwnerId: hostId,
      contentOwnerDisplayName: hostDisplayName,
      contentSnapshot: watchPartyName,
      showLabel: showLabel,
      iconColor: iconColor,
      iconSize: iconSize,
    );
  }

  void _showReportSheet(BuildContext context) {
    String title;
    switch (contentType) {
      case ReportableContentType.user:
        title = 'Report User';
        break;
      case ReportableContentType.message:
        title = 'Report Message';
        break;
      case ReportableContentType.watchParty:
        title = 'Report Watch Party';
        break;
      case ReportableContentType.chatRoom:
        title = 'Report Chat Room';
        break;
      case ReportableContentType.prediction:
        title = 'Report Prediction';
        break;
      case ReportableContentType.comment:
        title = 'Report Comment';
        break;
    }

    ReportBottomSheet.show(
      context: context,
      contentType: contentType,
      contentId: contentId,
      contentOwnerId: contentOwnerId,
      contentOwnerDisplayName: contentOwnerDisplayName,
      contentSnapshot: contentSnapshot,
      title: title,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (child != null) {
      return GestureDetector(
        onTap: () => _showReportSheet(context),
        child: child,
      );
    }

    if (showLabel) {
      return TextButton.icon(
        onPressed: () => _showReportSheet(context),
        icon: Icon(
          Icons.flag_outlined,
          size: iconSize,
          color: iconColor ?? Colors.grey[600],
        ),
        label: Text(
          'Report',
          style: TextStyle(
            color: iconColor ?? Colors.grey[600],
          ),
        ),
      );
    }

    return IconButton(
      onPressed: () => _showReportSheet(context),
      icon: Icon(
        Icons.flag_outlined,
        size: iconSize,
        color: iconColor ?? Colors.grey[600],
      ),
      tooltip: 'Report',
    );
  }
}

/// Menu item for use in PopupMenuButton
class ReportMenuItem extends PopupMenuEntry<String> {
  final ReportableContentType contentType;
  final String contentId;
  final String? contentOwnerId;
  final String? contentOwnerDisplayName;
  final String? contentSnapshot;

  const ReportMenuItem({
    super.key,
    required this.contentType,
    required this.contentId,
    this.contentOwnerId,
    this.contentOwnerDisplayName,
    this.contentSnapshot,
  });

  @override
  double get height => 48;

  @override
  bool represents(String? value) => value == 'report';

  @override
  State<ReportMenuItem> createState() => _ReportMenuItemState();
}

class _ReportMenuItemState extends State<ReportMenuItem> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        Icons.flag_outlined,
        color: Colors.red[400],
      ),
      title: const Text('Report'),
      onTap: () {
        Navigator.of(context).pop('report');
        ReportBottomSheet.show(
          context: context,
          contentType: widget.contentType,
          contentId: widget.contentId,
          contentOwnerId: widget.contentOwnerId,
          contentOwnerDisplayName: widget.contentOwnerDisplayName,
          contentSnapshot: widget.contentSnapshot,
        );
      },
    );
  }
}

/// Extension to easily add report option to PopupMenuButton
extension ReportMenuExtension on List<PopupMenuEntry<String>> {
  void addReportOption({
    required ReportableContentType contentType,
    required String contentId,
    String? contentOwnerId,
    String? contentOwnerDisplayName,
    String? contentSnapshot,
  }) {
    add(const PopupMenuDivider());
    add(ReportMenuItem(
      contentType: contentType,
      contentId: contentId,
      contentOwnerId: contentOwnerId,
      contentOwnerDisplayName: contentOwnerDisplayName,
      contentSnapshot: contentSnapshot,
    ));
  }
}
