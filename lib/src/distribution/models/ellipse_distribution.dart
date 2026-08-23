part of 'package:inspire_blur/src/distribution/distribution.dart';

/// A distribution with a shape of an ellipse.
///
/// Intensity from the [center] of the ellipse toward its end is controlled
/// by the [progession].
///
/// Size of the ellipse is defined by the [radiusX] and [radiusY].
final class EllipseDistribution extends ProgressingDistribution
    with FittableDistribution {
  /// Creates an elliptical distribution.
  ///
  /// The intensity is distributed from [center] to the ellipse boundary
  /// according to [progression].
  const EllipseDistribution({
    required this.radiusX,
    required this.radiusY,
    this.center = Alignment.center,
    this.distributionFit = DistributionFit.fill,
    super.progression = const Progression.gradient(),
    super.strengthFactor,
  })  : assert(
          radiusX >= 0.0,
          'radiusX must be greater than or equal to 0.0',
        ),
        assert(
          radiusY >= 0.0,
          'radiusY must be greater than or equal to 0.0',
        );

  /// Horizontal radius of the ellipse.
  ///
  /// Normalized to the range `[0.0, 1.0]`. Values greater than `1.0` are
  /// supported.
  final double radiusX;

  /// Vertical radius of the ellipse.
  ///
  /// Normalized to the range `[0.0, 1.0]`. Values greater than `1.0` are
  /// supported.
  final double radiusY;

  /// Center of the ellipse.
  final Alignment center;

  /// Specifies how the distribution is fit inside the widget.
  @override
  final DistributionFit distributionFit;

  /// Returns a copy of this distribution with the provided properties updated.
  ///
  /// Any parameter left `null` retains its current value.
  @override
  EllipseDistribution copyWith({
    double? radiusX,
    double? radiusY,
    Alignment? center,
    Progression? progression,
    DistributionFit? distributionFit,
    double? strengthFactor,
  }) {
    return EllipseDistribution(
      radiusX: radiusX ?? this.radiusX,
      radiusY: radiusY ?? this.radiusY,
      center: center ?? this.center,
      distributionFit: distributionFit ?? this.distributionFit,
      progression: progression ?? this.progression,
      strengthFactor: strengthFactor ?? this.strengthFactor,
    );
  }

  /// Linearly interpolates between two [EllipseDistribution] objects.
  ///
  /// Enables seamless transitions inside implicit animations or tweens.
  static EllipseDistribution lerp(
    EllipseDistribution a,
    EllipseDistribution b,
    double t,
  ) {
    if (identical(a, b)) return a;

    return EllipseDistribution(
      radiusX: lerpDouble(a.radiusX, b.radiusX, t)!,
      radiusY: lerpDouble(a.radiusY, b.radiusY, t)!,
      center: Alignment.lerp(a.center, b.center, t)!,
      distributionFit: t < 0.5 ? a.distributionFit : b.distributionFit,
      progression: Progression.lerp(a.progression, b.progression, t),
      strengthFactor: lerpDouble(a.strengthFactor, b.strengthFactor, t)!,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is EllipseDistribution &&
        other.radiusX == radiusX &&
        other.radiusY == radiusY &&
        other.center == center &&
        other.distributionFit == distributionFit &&
        progressingDistributionEquals(other) &&
        other.strengthFactor == strengthFactor;
  }

  @override
  int get hashCode => Object.hash(
        radiusX,
        radiusY,
        center,
        distributionFit,
        progression,
        strengthFactor,
      );

  @override
  String toString() => 'EllipseDistribution('
      'radiusX: $radiusX, '
      'radiusY: $radiusY, '
      'center: $center, '
      'distributionFit: $distributionFit, '
      'progression: $progression, '
      'strengthFactor: $strengthFactor'
      ')';
}
