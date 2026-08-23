import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:inspire_blur/src/utils/interpolated_curve.dart';
import 'package:inspire_blur/src/utils/math/inspire_lerp.dart';

part 'package:inspire_blur/src/model/progression/custom_progression.dart';
part 'package:inspire_blur/src/model/progression/gradient_progression.dart';

sealed class Progression {
  const Progression();

  const factory Progression.gradient({
    double start,
    double end,
    Curve curve,
  }) = GradientProgression;

  factory Progression.custom({
    required List<double> values,
    required List<double> stops,
    Curve curve,
  }) = CustomProgression;

  double samplePoint(double t);

  static Progression lerp(
    Progression a,
    Progression b,
    double t,
  ) {
    if (a is GradientProgression && b is GradientProgression) {
      return GradientProgression.lerp(a, b, t);
    }

    if (a is CustomProgression && b is CustomProgression) {
      return CustomProgression.lerp(a, b, t);
    }

    return t < 0.5 ? a : b;
  }
}
