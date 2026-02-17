/// Content Moderation Feature
///
/// Provides content moderation, reporting, and user sanction capabilities.
///
/// Features:
/// - Report users, messages, watch parties, and other content
/// - Profanity filtering with multi-language support
/// - User sanctions (warnings, mutes, suspensions, bans)
/// - Moderation status tracking
/// - Admin tools for reviewing reports
library moderation;

// Domain - Entities
export 'domain/entities/report.dart';
export 'domain/entities/user_sanction.dart';

// Domain - Services
export 'domain/services/moderation_service.dart';
export 'domain/services/moderation_report_service.dart';
export 'domain/services/moderation_action_service.dart';
export 'domain/services/moderation_content_filter_service.dart';
export 'domain/services/profanity_filter_service.dart';

// Presentation - Widgets
export 'presentation/widgets/report_bottom_sheet.dart';
export 'presentation/widgets/report_button.dart';
export 'presentation/widgets/moderation_status_banner.dart';
