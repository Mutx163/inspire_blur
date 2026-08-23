import 'package:flutter/widgets.dart';
import 'package:inspire_blur/src/distribution/maps/progressing_distribution_map.dart';
import 'package:inspire_blur/src/utils/extensions/inspire_geometry_extensions.dart';

class DirectionalDistributionMap extends ProgressingDistributionMap {
  DirectionalDistributionMap({
    required super.width,
    required super.height,
    required this.begin,
    required this.end,
    required super.progression,
    required super.strengthFactor,
  }) {
    _beginUV = begin.toNormalizedOffset();
    _endUV = end.toNormalizedOffset();
    _gradientVector = _endUV - _beginUV;
    _isDegenerate = _gradientVector.distanceSquared < 1e-6;
    if (!_isDegenerate) {
      _beginEndDistanceInvSquared = 1.0 / _gradientVector.dot(_gradientVector);
    }
  }

  final Alignment begin;
  final Alignment end;

  late final Offset _beginUV;
  late final Offset _endUV;
  late final Offset _gradientVector;
  late final double _beginEndDistanceInvSquared;
  late final bool _isDegenerate;

  @override
  double intensityAt(double u, double v) {
    if (_isDegenerate) return 0.0;

    final point = Offset(u, v) - _beginUV;

    return sampleProgression(
      point.dot(_gradientVector) * _beginEndDistanceInvSquared,
    );
  }
}
