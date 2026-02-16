import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'features/schedule/presentation/bloc/schedule_bloc.dart';
import 'features/schedule/domain/usecases/get_upcoming_games.dart';
import 'features/schedule/domain/repositories/schedule_repository.dart';
import 'core/services/accessibility_service.dart';
import 'injection_container.dart' as di;

/// Wraps [child] with the top-level providers required by the app.
///
/// Currently provides:
/// - [AccessibilityProvider] for accessibility settings (via InheritedNotifier)
/// - [BlocProvider] for [ScheduleBloc]
class AppProviders extends StatefulWidget {
  const AppProviders({required this.child, super.key});

  final Widget child;

  @override
  State<AppProviders> createState() => _AppProvidersState();
}

class _AppProvidersState extends State<AppProviders> {
  final AccessibilityService _accessibilityService = AccessibilityService();

  @override
  Widget build(BuildContext context) {
    return AccessibilityProvider(
      service: _accessibilityService,
      child: BlocProvider(
        create: (context) => ScheduleBloc(
          getUpcomingGames: di.sl<GetUpcomingGames>(),
          scheduleRepository: di.sl<ScheduleRepository>(),
        ),
        child: widget.child,
      ),
    );
  }
}
