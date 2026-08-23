import 'dart:math';

/// Defines how intensity values from overlapping distributions are combined.
///
/// For example, when two distributions overlap, the blend determines the
/// resulting intensity within their intersection.
sealed class DistributionBlend {
  const DistributionBlend._();

  /// Combines distribution intensity values into a normalized intensity.
  ///
  /// Input and output values are expected to be in the range `[0.0, 1.0]`.
  double combine(Iterable<double> values);

  /// {@template distribution_blend.max}
  /// Combines overlapping values by taking the maximum value.
  ///
  /// This blend tends to make intersections look sharper.
  /// {@endtemplate}
  const factory DistributionBlend.max() = MaxDistributionBlend;

  /// {@template distribution_blend.sum}
  /// Combines overlapping values additively.
  ///
  /// Contributions accumulate in overlapping areas and saturate at the
  /// maximum intensity of `1.0`.
  ///
  /// This blend tends to make intersections look fuller and more rounded.
  /// {@endtemplate}
  const factory DistributionBlend.sum() = SumDistributionBlend;

  /// {@template distribution_blend.screen}
  /// Combines overlapping values using screen blending.
  ///
  /// Contributions reinforce each other with diminishing intensity as
  /// the result approaches `1.0`.
  /// {@endtemplate}
  const factory DistributionBlend.screen() = ScreenDistributionBlend;
}

/// {@macro distribution_blend.max}
class MaxDistributionBlend extends DistributionBlend {
  const MaxDistributionBlend() : super._();

  @override
  double combine(Iterable<double> values) {
    double result = 0.0;
    for (final value in values) {
      result = max(result, value);
    }
    return _normalizeRange(result);
  }
}

/// {@macro distribution_blend.sum}
class SumDistributionBlend extends DistributionBlend {
  const SumDistributionBlend() : super._();

  @override
  double combine(Iterable<double> values) {
    double result = 0.0;
    for (final value in values) {
      result += value;
    }
    return _normalizeRange(result);
  }
}

/// {@macro distribution_blend.screen}
class ScreenDistributionBlend extends DistributionBlend {
  const ScreenDistributionBlend() : super._();

  @override
  double combine(Iterable<double> values) {
    double product = 1.0;
    for (final value in values) {
      product *= 1.0 - value;
    }
    return _normalizeRange(1.0 - product);
  }
}

double _normalizeRange(double value) => value.clamp(0.0, 1.0);
