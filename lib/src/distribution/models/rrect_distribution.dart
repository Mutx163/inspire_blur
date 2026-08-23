part of 'package:inspire_blur/src/distribution/distribution.dart';

/// A distribution with a shape of a rounded rectangle.
///
/// Intensity from the center of the area toward its edges is controlled
/// by the [progression].
final class RRectDistribution extends ProgressingDistribution
    with FittableDistribution {
  /// Creates a rounded-rectangular distribution.
  ///
  /// The intensity is distributed from the center towards the edge of the
  /// rounded rectangle according to [progression].
  const RRectDistribution({
    this.horizontalInset = 0.0,
    this.verticalInset = 0.0,
    this.cornerRadius = 0.0,
    this.distributionFit = DistributionFit.fill,
    super.progression = const Progression.gradient(start: 0.5),
    super.strengthFactor,
  }) : assert(
          cornerRadius >= 0.0 && cornerRadius <= 1.0,
          'cornerRadius must be in the range [0.0, 1.0]',
        );

  /// The normalized distance from the left and right edges to the start
  /// of the progression.
  ///
  /// Normalized to the range `[0.0, 0.5)`. Values greater than or equal
  /// to `0.5` will collapse the distribution area.
  final double horizontalInset;

  /// The normalized distance from the top and bottom edges to the start
  /// of the progression.
  ///
  /// Normalized to the range `[0.0, 0.5)`. Values greater than or equal
  /// to `0.5` will collapse the distribution area.
  final double verticalInset;

  /// The normalized corner radius of the shape.
  ///
  /// The value must be in the range `[0.0, 1.0]`.
  ///
  /// A value of `0.0` produces a rectangle, while `1.0` produces the
  /// maximum corner rounding for the given shape.
  final double cornerRadius;

  /// Specifies how the distribution is fit inside the widget.
  @override
  final DistributionFit distributionFit;

  /// Returns a copy of this distribution with the provided properties updated.
  ///
  /// Any parameter left `null` retains its current value.
  @override
  RRectDistribution copyWith({
    double? horizontalInset,
    double? verticalInset,
    double? cornerRadius,
    DistributionFit? distributionFit,
    Progression? progression,
    double? strengthFactor,
  }) {
    return RRectDistribution(
      horizontalInset: horizontalInset ?? this.horizontalInset,
      verticalInset: verticalInset ?? this.verticalInset,
      cornerRadius: cornerRadius ?? this.cornerRadius,
      distributionFit: distributionFit ?? this.distributionFit,
      progression: progression ?? this.progression,
      strengthFactor: strengthFactor ?? this.strengthFactor,
    );
  }

  /// Linearly interpolates between two [RRectDistribution] objects.
  ///
  /// Enables seamless transitions inside implicit animations or tweens.
  static RRectDistribution lerp(
    RRectDistribution a,
    RRectDistribution b,
    double t,
  ) {
    if (identical(a, b)) return a;

    return RRectDistribution(
      horizontalInset: lerpDouble(a.horizontalInset, b.horizontalInset, t)!,
      verticalInset: lerpDouble(a.verticalInset, b.verticalInset, t)!,
      cornerRadius: lerpDouble(a.cornerRadius, b.cornerRadius, t)!,
      distributionFit: t < 0.5 ? a.distributionFit : b.distributionFit,
      progression: Progression.lerp(a.progression, b.progression, t),
      strengthFactor: lerpDouble(a.strengthFactor, b.strengthFactor, t)!,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is RRectDistribution &&
        other.horizontalInset == horizontalInset &&
        other.verticalInset == verticalInset &&
        other.cornerRadius == cornerRadius &&
        other.distributionFit == distributionFit &&
        progressingDistributionEquals(other) &&
        other.strengthFactor == strengthFactor;
  }

  @override
  int get hashCode => Object.hash(
        horizontalInset,
        verticalInset,
        cornerRadius,
        distributionFit,
        progressingDistributionHashCode(),
        strengthFactor,
      );

  @override
  String toString() => 'RRectDistribution('
      'horizontalInset: $horizontalInset, '
      'verticalInset: $verticalInset, '
      'cornerRadius: $cornerRadius, '
      'distributionFit: $distributionFit, '
      'progression: $progression, '
      'strengthFactor: $strengthFactor'
      ')';
}
