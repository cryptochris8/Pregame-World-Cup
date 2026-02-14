import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/schedule/presentation/widgets/prediction_accuracy_helpers.dart';

void main() {
  group('PredictionAccuracyHelpers', () {
    group('getAccuracyColor', () {
      test('returns green for accuracy >= 0.7', () {
        expect(PredictionAccuracyHelpers.getAccuracyColor(0.7), equals(Colors.green));
        expect(PredictionAccuracyHelpers.getAccuracyColor(0.8), equals(Colors.green));
        expect(PredictionAccuracyHelpers.getAccuracyColor(0.9), equals(Colors.green));
        expect(PredictionAccuracyHelpers.getAccuracyColor(1.0), equals(Colors.green));
      });

      test('returns orange for accuracy >= 0.5 and < 0.7', () {
        expect(PredictionAccuracyHelpers.getAccuracyColor(0.5), equals(Colors.orange));
        expect(PredictionAccuracyHelpers.getAccuracyColor(0.6), equals(Colors.orange));
        expect(PredictionAccuracyHelpers.getAccuracyColor(0.69), equals(Colors.orange));
      });

      test('returns red for accuracy < 0.5', () {
        expect(PredictionAccuracyHelpers.getAccuracyColor(0.0), equals(Colors.red));
        expect(PredictionAccuracyHelpers.getAccuracyColor(0.1), equals(Colors.red));
        expect(PredictionAccuracyHelpers.getAccuracyColor(0.3), equals(Colors.red));
        expect(PredictionAccuracyHelpers.getAccuracyColor(0.49), equals(Colors.red));
      });
    });

    group('getAccuracyDescription', () {
      test('returns Excellent for >= 0.8', () {
        expect(PredictionAccuracyHelpers.getAccuracyDescription(0.8), equals('Excellent'));
        expect(PredictionAccuracyHelpers.getAccuracyDescription(0.9), equals('Excellent'));
        expect(PredictionAccuracyHelpers.getAccuracyDescription(1.0), equals('Excellent'));
      });

      test('returns Good for >= 0.7 and < 0.8', () {
        expect(PredictionAccuracyHelpers.getAccuracyDescription(0.7), equals('Good'));
        expect(PredictionAccuracyHelpers.getAccuracyDescription(0.75), equals('Good'));
        expect(PredictionAccuracyHelpers.getAccuracyDescription(0.79), equals('Good'));
      });

      test('returns Average for >= 0.6 and < 0.7', () {
        expect(PredictionAccuracyHelpers.getAccuracyDescription(0.6), equals('Average'));
        expect(PredictionAccuracyHelpers.getAccuracyDescription(0.65), equals('Average'));
        expect(PredictionAccuracyHelpers.getAccuracyDescription(0.69), equals('Average'));
      });

      test('returns Below Average for >= 0.5 and < 0.6', () {
        expect(PredictionAccuracyHelpers.getAccuracyDescription(0.5), equals('Below Average'));
        expect(PredictionAccuracyHelpers.getAccuracyDescription(0.55), equals('Below Average'));
        expect(PredictionAccuracyHelpers.getAccuracyDescription(0.59), equals('Below Average'));
      });

      test('returns Needs Improvement for < 0.5', () {
        expect(PredictionAccuracyHelpers.getAccuracyDescription(0.0), equals('Needs Improvement'));
        expect(PredictionAccuracyHelpers.getAccuracyDescription(0.3), equals('Needs Improvement'));
        expect(PredictionAccuracyHelpers.getAccuracyDescription(0.49), equals('Needs Improvement'));
      });
    });

    group('getVolumeDescription', () {
      test('returns High Volume for >= 50', () {
        expect(PredictionAccuracyHelpers.getVolumeDescription(50), equals('High Volume'));
        expect(PredictionAccuracyHelpers.getVolumeDescription(100), equals('High Volume'));
        expect(PredictionAccuracyHelpers.getVolumeDescription(500), equals('High Volume'));
      });

      test('returns Moderate Volume for >= 20 and < 50', () {
        expect(PredictionAccuracyHelpers.getVolumeDescription(20), equals('Moderate Volume'));
        expect(PredictionAccuracyHelpers.getVolumeDescription(35), equals('Moderate Volume'));
        expect(PredictionAccuracyHelpers.getVolumeDescription(49), equals('Moderate Volume'));
      });

      test('returns Getting Started for >= 10 and < 20', () {
        expect(PredictionAccuracyHelpers.getVolumeDescription(10), equals('Getting Started'));
        expect(PredictionAccuracyHelpers.getVolumeDescription(15), equals('Getting Started'));
        expect(PredictionAccuracyHelpers.getVolumeDescription(19), equals('Getting Started'));
      });

      test('returns Early Days for < 10', () {
        expect(PredictionAccuracyHelpers.getVolumeDescription(0), equals('Early Days'));
        expect(PredictionAccuracyHelpers.getVolumeDescription(1), equals('Early Days'));
        expect(PredictionAccuracyHelpers.getVolumeDescription(9), equals('Early Days'));
      });
    });

    group('getScoreAccuracyDescription', () {
      test('returns Very Precise for >= 0.8', () {
        expect(PredictionAccuracyHelpers.getScoreAccuracyDescription(0.8), equals('Very Precise'));
        expect(PredictionAccuracyHelpers.getScoreAccuracyDescription(0.9), equals('Very Precise'));
        expect(PredictionAccuracyHelpers.getScoreAccuracyDescription(1.0), equals('Very Precise'));
      });

      test('returns Fairly Accurate for >= 0.6 and < 0.8', () {
        expect(PredictionAccuracyHelpers.getScoreAccuracyDescription(0.6), equals('Fairly Accurate'));
        expect(PredictionAccuracyHelpers.getScoreAccuracyDescription(0.7), equals('Fairly Accurate'));
        expect(PredictionAccuracyHelpers.getScoreAccuracyDescription(0.79), equals('Fairly Accurate'));
      });

      test('returns Room for Improvement for >= 0.4 and < 0.6', () {
        expect(PredictionAccuracyHelpers.getScoreAccuracyDescription(0.4), equals('Room for Improvement'));
        expect(PredictionAccuracyHelpers.getScoreAccuracyDescription(0.5), equals('Room for Improvement'));
        expect(PredictionAccuracyHelpers.getScoreAccuracyDescription(0.59), equals('Room for Improvement'));
      });

      test('returns Developing for < 0.4', () {
        expect(PredictionAccuracyHelpers.getScoreAccuracyDescription(0.0), equals('Developing'));
        expect(PredictionAccuracyHelpers.getScoreAccuracyDescription(0.2), equals('Developing'));
        expect(PredictionAccuracyHelpers.getScoreAccuracyDescription(0.39), equals('Developing'));
      });
    });
  });
}
