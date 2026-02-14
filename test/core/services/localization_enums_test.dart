import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/core/services/localization_service.dart';

void main() {
  group('AppLanguage', () {
    group('Values', () {
      test('has exactly 5 language options', () {
        expect(AppLanguage.values.length, equals(5));
      });

      test('contains all expected languages', () {
        expect(AppLanguage.values, contains(AppLanguage.system));
        expect(AppLanguage.values, contains(AppLanguage.english));
        expect(AppLanguage.values, contains(AppLanguage.spanish));
        expect(AppLanguage.values, contains(AppLanguage.portuguese));
        expect(AppLanguage.values, contains(AppLanguage.french));
      });
    });

    group('Language codes', () {
      test('system has correct code', () {
        expect(AppLanguage.system.code, equals('system'));
      });

      test('english has correct code', () {
        expect(AppLanguage.english.code, equals('en'));
      });

      test('spanish has correct code', () {
        expect(AppLanguage.spanish.code, equals('es'));
      });

      test('portuguese has correct code', () {
        expect(AppLanguage.portuguese.code, equals('pt'));
      });

      test('french has correct code', () {
        expect(AppLanguage.french.code, equals('fr'));
      });
    });

    group('Display names', () {
      test('system display name', () {
        expect(AppLanguage.system.displayName, equals('System Default'));
      });

      test('english display name', () {
        expect(AppLanguage.english.displayName, equals('English'));
      });

      test('spanish display name', () {
        expect(AppLanguage.spanish.displayName, contains('spa'));
      });

      test('portuguese display name', () {
        expect(AppLanguage.portuguese.displayName, contains('Portugu'));
      });

      test('french display name', () {
        expect(AppLanguage.french.displayName, contains('Fran'));
      });
    });

    group('Native names', () {
      test('system native name', () {
        expect(AppLanguage.system.nativeName, equals('System Default'));
      });

      test('english native name', () {
        expect(AppLanguage.english.nativeName, equals('English'));
      });

      test('spanish native name', () {
        expect(AppLanguage.spanish.nativeName, contains('spa'));
      });

      test('portuguese native name', () {
        expect(AppLanguage.portuguese.nativeName, contains('Portugu'));
      });

      test('french native name', () {
        expect(AppLanguage.french.nativeName, contains('Fran'));
      });
    });

    group('Locales', () {
      test('system has null locale', () {
        expect(AppLanguage.system.locale, isNull);
      });

      test('english has en locale', () {
        expect(AppLanguage.english.locale, equals(const Locale('en')));
      });

      test('spanish has es locale', () {
        expect(AppLanguage.spanish.locale, equals(const Locale('es')));
      });

      test('portuguese has pt locale', () {
        expect(AppLanguage.portuguese.locale, equals(const Locale('pt')));
      });

      test('french has fr locale', () {
        expect(AppLanguage.french.locale, equals(const Locale('fr')));
      });

      test('all non-system languages have locales', () {
        for (final lang in AppLanguage.values) {
          if (lang != AppLanguage.system) {
            expect(lang.locale, isNotNull, reason: '${lang.name} should have a locale');
          }
        }
      });
    });

    group('fromCode', () {
      test('returns correct language for valid code', () {
        expect(AppLanguage.fromCode('en'), equals(AppLanguage.english));
        expect(AppLanguage.fromCode('es'), equals(AppLanguage.spanish));
        expect(AppLanguage.fromCode('pt'), equals(AppLanguage.portuguese));
        expect(AppLanguage.fromCode('fr'), equals(AppLanguage.french));
        expect(AppLanguage.fromCode('system'), equals(AppLanguage.system));
      });

      test('returns system for unknown code', () {
        expect(AppLanguage.fromCode('unknown'), equals(AppLanguage.system));
        expect(AppLanguage.fromCode(''), equals(AppLanguage.system));
        expect(AppLanguage.fromCode('de'), equals(AppLanguage.system));
        expect(AppLanguage.fromCode('ja'), equals(AppLanguage.system));
      });

      test('is case-sensitive', () {
        // The codes are lowercase, so uppercase should fall back to system
        expect(AppLanguage.fromCode('EN'), equals(AppLanguage.system));
        expect(AppLanguage.fromCode('Es'), equals(AppLanguage.system));
      });
    });

    group('Flag emojis', () {
      test('all languages have flag emojis', () {
        for (final lang in AppLanguage.values) {
          expect(lang.flagEmoji, isNotEmpty, reason: '${lang.name} should have a flag emoji');
        }
      });

      test('flag emojis are distinct', () {
        final flags = AppLanguage.values.map((l) => l.flagEmoji).toSet();
        expect(flags.length, equals(AppLanguage.values.length));
      });
    });

    group('World Cup host country languages', () {
      test('supports English for USA host city fans', () {
        final english = AppLanguage.fromCode('en');
        expect(english, equals(AppLanguage.english));
        expect(english.locale, isNotNull);
      });

      test('supports Spanish for Mexico host city fans', () {
        final spanish = AppLanguage.fromCode('es');
        expect(spanish, equals(AppLanguage.spanish));
        expect(spanish.locale, isNotNull);
      });

      test('supports French for Canada host city fans', () {
        final french = AppLanguage.fromCode('fr');
        expect(french, equals(AppLanguage.french));
        expect(french.locale, isNotNull);
      });

      test('supports Portuguese for Brazilian fans', () {
        final portuguese = AppLanguage.fromCode('pt');
        expect(portuguese, equals(AppLanguage.portuguese));
        expect(portuguese.locale, isNotNull);
      });
    });
  });
}
