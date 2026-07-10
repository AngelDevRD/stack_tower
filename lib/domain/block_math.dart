/// Pure math for block oscillation, overlap/cut and difficulty. No Flutter imports.
library;

import 'dart:math' as math;

/// Horizontal position of oscillating block at time [t] (seconds since block spawn).
/// Oscillates between [minX] and [maxX] using a sine wave driven by [speed] (rad/s).
double oscillatingX({
  required double t,
  required double minX,
  required double maxX,
  required double speed,
}) {
  final center = (minX + maxX) / 2;
  final amplitude = (maxX - minX) / 2;
  return center + amplitude * math.sin(t * speed);
}

/// Result of landing a block on top of the block below it.
class OverlapResult {
  /// Left edge of the surviving (overlapping) piece.
  final double left;

  /// Width of the surviving (overlapping) piece.
  final double width;

  /// Overlap ratio in [0, 1] relative to the falling block's width.
  final double ratio;

  /// True when overlap is zero (complete miss -> game over).
  final bool isMiss;

  /// True when overlap ratio is at/above the "perfect" threshold.
  final bool isPerfect;

  /// Left edge of the discarded (cut-off) piece, or null if nothing was cut.
  final double? cutLeft;

  /// Width of the discarded (cut-off) piece, or null if nothing was cut.
  final double? cutWidth;

  const OverlapResult({
    required this.left,
    required this.width,
    required this.ratio,
    required this.isMiss,
    required this.isPerfect,
    this.cutLeft,
    this.cutWidth,
  });
}

/// Threshold above which an overlap counts as "perfect" placement.
const double kPerfectOverlapThreshold = 0.95;

/// Computes the overlap between a falling block [fallingLeft, fallingLeft+fallingWidth]
/// and the block below it [belowLeft, belowLeft+belowWidth]. The falling block gets cut
/// down to the overlapping region; the rest becomes a separate discarded piece.
OverlapResult computeOverlap({
  required double fallingLeft,
  required double fallingWidth,
  required double belowLeft,
  required double belowWidth,
}) {
  final fallingRight = fallingLeft + fallingWidth;
  final belowRight = belowLeft + belowWidth;

  final overlapLeft = math.max(fallingLeft, belowLeft);
  final overlapRight = math.min(fallingRight, belowRight);
  final overlapWidth = math.max(0.0, overlapRight - overlapLeft);

  final ratio = fallingWidth <= 0
      ? 0.0
      : (overlapWidth / fallingWidth).clamp(0.0, 1.0);
  final isMiss = overlapWidth <= 0;
  final isPerfect = !isMiss && ratio >= kPerfectOverlapThreshold;

  if (isMiss) {
    return OverlapResult(
      left: fallingLeft,
      width: 0,
      ratio: 0,
      isMiss: true,
      isPerfect: false,
    );
  }

  // Determine the discarded piece (whichever side got cut, could be both sides).
  double? cutLeft;
  double? cutWidth;
  final leftCut = overlapLeft - fallingLeft;
  final rightCut = fallingRight - overlapRight;
  if (leftCut > 0 && rightCut > 0) {
    // Cut on both sides: keep the bigger discarded chunk as the single falling piece.
    if (leftCut >= rightCut) {
      cutLeft = fallingLeft;
      cutWidth = leftCut;
    } else {
      cutLeft = overlapRight;
      cutWidth = rightCut;
    }
  } else if (leftCut > 0) {
    cutLeft = fallingLeft;
    cutWidth = leftCut;
  } else if (rightCut > 0) {
    cutLeft = overlapRight;
    cutWidth = rightCut;
  }

  return OverlapResult(
    left: overlapLeft,
    width: overlapWidth,
    ratio: ratio,
    isMiss: false,
    isPerfect: isPerfect,
    cutLeft: cutLeft,
    cutWidth: cutWidth,
  );
}

/// Oscillation speed (rad/s) for a given tower [height] (number of blocks placed).
/// Increases gradually, bounded so it never becomes unplayable.
double speedForHeight(int height) {
  const base = 1.0;
  const perLevel = 0.06;
  const max = 3.2;
  final speed = base + perLevel * height;
  return speed > max ? max : speed;
}

/// Score bonus awarded for a placement given its overlap ratio.
int scoreBonusForRatio(double ratio) {
  return ratio >= kPerfectOverlapThreshold ? 1 : 0;
}
