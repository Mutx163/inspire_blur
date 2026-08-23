import 'dart:math';
import 'dart:ui' as ui show Image;
import 'dart:ui' show lerpDouble;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:inspire_blur/src/model/distribution_blend.dart';
import 'package:inspire_blur/src/model/distribution_fit.dart';
import 'package:inspire_blur/src/model/progression/progression.dart';

part 'package:inspire_blur/src/distribution/models/combined_distribution.dart';
part 'package:inspire_blur/src/distribution/models/directional_distribution.dart';
part 'package:inspire_blur/src/distribution/models/ellipse_distribution.dart';
part 'package:inspire_blur/src/distribution/models/fittable_distribution.dart';
part 'package:inspire_blur/src/distribution/models/image_mask_distribution.dart';
part 'package:inspire_blur/src/distribution/models/progressing_distribution.dart';
part 'package:inspire_blur/src/distribution/models/rrect_distribution.dart';
part 'package:inspire_blur/src/distribution/models/uniform_distribution.dart';

/// Defines how blur strength is distributed spatially.
sealed class Distribution {
  /// Optional factor for reducing the distribution strength.
  ///
  /// Particularly useful inside [CombinedDistribution] to control the
  /// contribution of each distribution.
  ///
  /// Normalized to the range `[0.0, 1.0]`, where `0.0` makes the distribution
  /// empty, where values above `1.0` amplify the strength uniformly.
  final double strengthFactor;

  /// Creates a distribution with [strengthFactor].
  const Distribution({this.strengthFactor = 1.0});

  /// Returns a copy of this distribution with the provided properties updated.
  ///
  /// Any parameter left `null` retains its current value.
  Distribution copyWith();

  /// Linearly interpolates between two distributions.
  ///
  /// Distributions are interpolated only when they are of the same concrete
  /// type. Otherwise, the result switches discretely from [begin] to [end]
  /// halfway through the animation.
  static Distribution lerp(Distribution? begin, Distribution? end, double t) {
    if (identical(begin, end) && begin != null) return begin;

    if (begin is CombinedDistribution && end is CombinedDistribution) {
      return CombinedDistribution.lerp(begin, end, t);
    }

    if (begin is DirectionalDistribution && end is DirectionalDistribution) {
      return DirectionalDistribution.lerp(begin, end, t);
    }

    if (begin is EllipseDistribution && end is EllipseDistribution) {
      return EllipseDistribution.lerp(begin, end, t);
    }

    if (begin is RRectDistribution && end is RRectDistribution) {
      return RRectDistribution.lerp(begin, end, t);
    }

    return (t < 0.5 ? begin : end) ?? const UniformDistribution();
  }
}
