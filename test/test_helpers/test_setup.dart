import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pregame_world_cup/features/worldcup/data/services/match_reminder_service.dart';
import 'package:pregame_world_cup/features/worldcup/domain/entities/match_reminder.dart';

// Mock Services
class MockMatchReminderService extends Mock implements MatchReminderService {}

/// Sets up GetIt with mock services for testing
/// Call this in setUp() and call tearDownGetIt() in tearDown()
void setUpTestGetIt() {
  final sl = GetIt.instance;

  // Reset GetIt to ensure clean state
  if (sl.isRegistered<MatchReminderService>()) {
    sl.unregister<MatchReminderService>();
  }

  // Register mock services
  final mockReminderService = MockMatchReminderService();

  // Set up default mock behaviors
  when(() => mockReminderService.hasReminderCached(any())).thenReturn(false);
  when(() => mockReminderService.getReminderTimingCached(any())).thenReturn(null);
  when(() => mockReminderService.hasReminder(any())).thenAnswer((_) async => false);

  sl.registerSingleton<MatchReminderService>(mockReminderService);
}

/// Tears down GetIt after tests
void tearDownTestGetIt() {
  final sl = GetIt.instance;

  if (sl.isRegistered<MatchReminderService>()) {
    sl.unregister<MatchReminderService>();
  }
}

/// Resets GetIt completely for tests that need a clean slate
void resetGetIt() {
  GetIt.instance.reset();
}
