part of 'package:inspire_blur/src/model/progression/progression.dart';

class GradientProgression extends Progression {
  final double start;
  final double end;
  final Curve curve;

  const GradientProgression({
    this.start = 0.0,
    this.end = 1.0,
    this.curve = Curves.easeInSine,
  }) : assert(start <= end, 'start must be less than or equal to end');

  @override
  double samplePoint(double t) {
    if ((end - start).abs() < 1e-6) return t < start ? 1.0 : 0.0;

    final clampedT = t.clamp(start, end);
    final relT = ((clampedT - start) / (end - start)).clamp(0.0, 1.0);

    return curve.transform(1.0 - relT).clamp(0.0, 1.0);
  }

  /// Linearly interpolates between two [GradientProgression] objects.
  ///
  /// Enables seamless transitions inside implicit animations or tweens.
  static GradientProgression lerp(
    GradientProgression a,
    GradientProgression b,
    double t,
  ) {
    if (identical(a, b)) return a;

    return GradientProgression(
      start: lerpDouble(a.start, b.start, t)!,
      end: lerpDouble(a.end, b.end, t)!,
      curve: InterpolatedCurve(a.curve, b.curve, t),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is GradientProgression &&
        start == other.start &&
        end == other.end &&
        curve == other.curve;
  }

  @override
  int get hashCode => Object.hash(start, end, curve);

  @override
  String toString() => 'GradientProgression('
      'start: $start, '
      'end: $end, '
      'curve: $curve'
      ')';
}
