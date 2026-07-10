import 'package:flutter_test/flutter_test.dart';
import 'package:stack_tower/domain/block_math.dart';

void main() {
  group('computeOverlap', () {
    test('perfect overlap: identical position and width', () {
      final result = computeOverlap(
        fallingLeft: 100,
        fallingWidth: 80,
        belowLeft: 100,
        belowWidth: 80,
      );
      expect(result.isMiss, isFalse);
      expect(result.isPerfect, isTrue);
      expect(result.ratio, 1.0);
      expect(result.width, 80);
      expect(result.cutLeft, isNull);
    });

    test('partial overlap: falling block shifted right, cut on the left side', () {
      final result = computeOverlap(
        fallingLeft: 120,
        fallingWidth: 80,
        belowLeft: 100,
        belowWidth: 80,
      );
      // Overlap region: [120, 180] intersect [100,180] = [120,180] width 60
      expect(result.isMiss, isFalse);
      expect(result.width, 60);
      expect(result.ratio, closeTo(60 / 80, 1e-9));
      expect(result.isPerfect, isFalse);
      // The falling block's own right side beyond below's right edge is cut off? Check geometry:
      // fallingRight=200, belowRight=180 -> rightCut = 200-180=20 > 0 -> cut piece exists.
      expect(result.cutWidth, 20);
      expect(result.cutLeft, 180);
    });

    test('zero overlap is a miss (game over)', () {
      final result = computeOverlap(
        fallingLeft: 300,
        fallingWidth: 50,
        belowLeft: 0,
        belowWidth: 80,
      );
      expect(result.isMiss, isTrue);
      expect(result.width, 0);
      expect(result.ratio, 0);
      expect(result.isPerfect, isFalse);
    });

    test('overlap exactly touching edges counts as zero-width miss', () {
      final result = computeOverlap(
        fallingLeft: 80,
        fallingWidth: 50,
        belowLeft: 0,
        belowWidth: 80,
      );
      expect(result.isMiss, isTrue);
    });

    test('near-perfect overlap above threshold is flagged perfect', () {
      // 96% overlap: falling width 100, overlap width 96.
      final result = computeOverlap(
        fallingLeft: 4,
        fallingWidth: 100,
        belowLeft: 0,
        belowWidth: 100,
      );
      expect(result.ratio, closeTo(0.96, 1e-9));
      expect(result.isPerfect, isTrue);
    });
  });

  group('speedForHeight', () {
    test('increases monotonically with height', () {
      double prev = speedForHeight(0);
      for (var h = 1; h <= 100; h++) {
        final speed = speedForHeight(h);
        expect(speed, greaterThanOrEqualTo(prev));
        prev = speed;
      }
    });

    test('is bounded (never exceeds max)', () {
      final speed = speedForHeight(10000);
      expect(speed, lessThanOrEqualTo(3.2));
    });

    test('starts at a sane base value', () {
      expect(speedForHeight(0), 1.0);
    });
  });

  group('oscillatingX', () {
    test('stays within [minX, maxX] bounds', () {
      for (double t = 0; t < 20; t += 0.1) {
        final x = oscillatingX(t: t, minX: 10, maxX: 90, speed: 1.5);
        expect(x, greaterThanOrEqualTo(10 - 1e-9));
        expect(x, lessThanOrEqualTo(90 + 1e-9));
      }
    });
  });
}
