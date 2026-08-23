import 'dart:math';

import 'package:inspire_blur/src/distribution/maps/progressing_distribution_map.dart';

class RRectDistributionMap extends ProgressingDistributionMap {
  RRectDistributionMap({
    required super.width,
    required super.height,
    required this.horizontalInset,
    required this.verticalInset,
    required this.cornerRadius,
    required super.progression,
    required super.strengthFactor,
  }) {
    _left = horizontalInset;
    _right = 1.0 - horizontalInset;
    _top = verticalInset;
    _bottom = 1.0 - verticalInset;

    _centerX = (_left + _right) * 0.5;
    _centerY = (_top + _bottom) * 0.5;

    _halfWidth = (_right - _left) * 0.5;
    _halfHeight = (_bottom - _top) * 0.5;

    _effectiveRadius = cornerRadius * min(_halfWidth, _halfHeight);

    _centerDistance = _signedDistanceToRRect(
      x: 0.0,
      y: 0.0,
      halfWidth: _halfWidth,
      halfHeight: _halfHeight,
      radius: _effectiveRadius,
    ).abs();
  }

  final double horizontalInset;
  final double verticalInset;
  final double cornerRadius;

  late final double _left;
  late final double _right;
  late final double _top;
  late final double _bottom;

  late final double _centerX;
  late final double _centerY;

  late final double _halfWidth;
  late final double _halfHeight;

  late final double _effectiveRadius;

  late final double _centerDistance;

  @override
  double intensityAt(double u, double v) {
    if (_halfWidth <= 0.0 || _halfHeight <= 0.0) {
      return 0.0;
    }

    final signedDistance = _signedDistanceToRRect(
      x: u - _centerX,
      y: v - _centerY,
      halfWidth: _halfWidth,
      halfHeight: _halfHeight,
      radius: _effectiveRadius,
    );

    final position =
        _centerDistance == 0.0 ? 1.0 : 1.0 + signedDistance / _centerDistance;

    return sampleProgression(position);
  }

  static double _signedDistanceToRRect({
    required double x,
    required double y,
    required double halfWidth,
    required double halfHeight,
    required double radius,
  }) {
    final qx = x.abs() - (halfWidth - radius);
    final qy = y.abs() - (halfHeight - radius);

    final outsideX = max(qx, 0.0);
    final outsideY = max(qy, 0.0);

    final outsideDistance = sqrt(outsideX * outsideX + outsideY * outsideY);
    final insideDistance = min(max(qx, qy), 0.0);

    return outsideDistance + insideDistance - radius;
  }
}
