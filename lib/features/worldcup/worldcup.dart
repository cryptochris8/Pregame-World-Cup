/// 2026 tournament Feature Module
///
/// This barrel file exports all 2026 tournament components:
/// - Domain entities (NationalTeam, WorldCupMatch, Group, Bracket, Venue)
/// - Repository interfaces
/// - Repository implementations
/// - Data sources
/// - BLoC/Cubit state management
/// - UI widgets and pages
library;

// Domain Entities
export 'domain/entities/entities.dart';

// Repository Interfaces
export 'domain/repositories/repositories.dart';

// Repository Implementations
export 'data/repositories/repositories.dart';

// Data Sources
export 'data/datasources/datasources.dart';

// BLoC/Cubit
export 'presentation/bloc/bloc.dart';

// Widgets
export 'presentation/widgets/widgets.dart';

// Pages
export 'presentation/pages/pages.dart';
