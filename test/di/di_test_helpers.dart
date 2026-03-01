/// Shared test helpers for DI module tests.
///
/// Provides Firebase mock setup and common mock classes used across
/// all DI test files.
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mocktail/mocktail.dart';

// -- Mock classes --
class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockDio extends Mock implements Dio {}

/// Initializes Firebase mocks. Must be called in setUpAll.
Future<void> initFirebaseMocks() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  setupFirebaseCoreMocks();
  await Firebase.initializeApp();
}

/// Resets GetIt between tests.
Future<void> resetGetIt() async {
  final sl = GetIt.instance;
  await sl.reset();
}

/// Registers core mock dependencies that other DI modules rely on.
/// Call this in setUp when testing downstream modules that depend on
/// types registered by core_di (Dio, FirebaseFirestore, FirebaseAuth,
/// SharedPreferences, CacheService, etc.).
Future<void> registerCoreMocks(GetIt sl) async {
  // Core infrastructure
  sl.registerLazySingleton<Dio>(() => MockDio());
  sl.registerLazySingleton<FirebaseFirestore>(
    () => FakeFirebaseFirestore(),
  );
  sl.registerLazySingleton<FirebaseAuth>(() => MockFirebaseAuth());

  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => prefs);
}
