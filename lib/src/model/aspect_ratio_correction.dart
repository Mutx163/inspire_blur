import 'dart:ui';

import 'package:inspire_blur/src/distribution/distribution.dart';
import 'package:inspire_blur/src/model/distribution_fit.dart';

class AspectRatioCorrection {
  const AspectRatioCorrection(this.aspectRatio);

  final double? aspectRatio;

  double get shaderAspectRatio => aspectRatio ?? -1.0;

  factory AspectRatioCorrection.forDistribution({
    required Distribution distribution,
    required Rect bounds,
  }) {
    return switch (distribution) {
      FittableDistribution(distributionFit: DistributionFit.inside) =>
        AspectRatioCorrection(bounds.width / bounds.height),
      _ => const AspectRatioCorrection(null),
    };
  }
}
