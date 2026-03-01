import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/test.dart';

import 'package:pregame_world_cup/features/moderation/moderation.dart';
import 'package:pregame_world_cup/features/admin/domain/services/admin_service.dart';
import 'package:pregame_world_cup/features/match_chat/match_chat.dart';

import 'package:pregame_world_cup/di/moderation_admin_di.dart';

/// Tests for lib/di/moderation_admin_di.dart  (Steps 11-13)
///
/// registerModerationAdminServices registers:
///   Step 11: ProfanityFilterService, ModerationService (depends on profanity filter)
///   Step 12: AdminService
///   Step 13: MatchChatService, MatchChatCubit (factory)
void main() {
  final sl = GetIt.instance;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    setupFirebaseCoreMocks();
    await Firebase.initializeApp();
  });

  setUp(() async {
    await sl.reset();
  });

  group('Moderation/Admin DI - registerModerationAdminServices', () {
    setUp(() {
      registerModerationAdminServices(sl);
    });

    test('registers all 5 expected types', () {
      expect(sl.isRegistered<ProfanityFilterService>(), isTrue);
      expect(sl.isRegistered<ModerationService>(), isTrue);
      expect(sl.isRegistered<AdminService>(), isTrue);
      expect(sl.isRegistered<MatchChatService>(), isTrue);
      expect(sl.isRegistered<MatchChatCubit>(), isTrue);
    });

    test('ProfanityFilterService is a lazy singleton', () {
      final a = sl<ProfanityFilterService>();
      final b = sl<ProfanityFilterService>();
      expect(identical(a, b), isTrue);
    });

    test('ModerationService is a lazy singleton', () {
      final a = sl<ModerationService>();
      final b = sl<ModerationService>();
      expect(identical(a, b), isTrue);
    });

    test('AdminService is a lazy singleton', () {
      final a = sl<AdminService>();
      final b = sl<AdminService>();
      expect(identical(a, b), isTrue);
    });

    test('MatchChatService is a lazy singleton', () {
      final a = sl<MatchChatService>();
      final b = sl<MatchChatService>();
      expect(identical(a, b), isTrue);
    });

    test('MatchChatCubit is a factory - returns new instance each time', () {
      final a = sl<MatchChatCubit>();
      final b = sl<MatchChatCubit>();
      expect(identical(a, b), isFalse, reason: 'Factory should create new instances');
    });
  });

  group('Moderation/Admin DI - type correctness', () {
    setUp(() {
      registerModerationAdminServices(sl);
    });

    test('resolved types are correct', () {
      expect(sl<ProfanityFilterService>(), isA<ProfanityFilterService>());
      expect(sl<ModerationService>(), isA<ModerationService>());
      expect(sl<AdminService>(), isA<AdminService>());
      expect(sl<MatchChatService>(), isA<MatchChatService>());
      expect(sl<MatchChatCubit>(), isA<MatchChatCubit>());
    });
  });

  group('Moderation/Admin DI - dependency wiring', () {
    test('ModerationService receives ProfanityFilterService from sl', () {
      registerModerationAdminServices(sl);

      // If dependency wiring is broken, resolving would throw
      final modService = sl<ModerationService>();
      expect(modService, isNotNull);
    });

    test('MatchChatCubit receives MatchChatService from sl', () {
      registerModerationAdminServices(sl);

      final cubit = sl<MatchChatCubit>();
      expect(cubit, isNotNull);
    });
  });

  group('Moderation/Admin DI - duplicate registration guard', () {
    test('calling registerModerationAdminServices twice throws', () {
      registerModerationAdminServices(sl);
      expect(
        () => registerModerationAdminServices(sl),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}
