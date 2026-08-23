part of 'package:inspire_blur/src/model/progression/progression.dart';

/// A custom progression defined by control points.
///
/// Control points are defined by pairs of [stops] and their corresponding
/// [values]. Both lists must have the same length.
///
/// Progression of values is transformed by the [curve].
class CustomProgression extends Progression {
  /// Constructs the custom progression with [values] and [stops].
  ///
  /// There must be at least two control points.
  CustomProgression({
    required List<double> values,
    required List<double> stops,
    this.curve = Curves.easeInSine,
  })  : values = List.unmodifiable(values),
        stops = List.unmodifiable(stops) {
    assert(
      values.length >= 2,
      'Provide at least two control point values',
    );

    assert(
      stops.length >= 2,
      'Provide at least two control point stops',
    );

    assert(
      values.length == stops.length,
      'Provide same number of values and stops for control points',
    );

    for (final value in values) {
      assert(
        value >= 0.0 && value <= 1.0,
        'Provide all values in the range [0.0, 1.0]',
      );
    }

    for (int i = 1; i < stops.length; i++) {
      assert(
        stops[i] >= stops[i - 1],
        'Provide stops in non-decreasing order',
      );
    }
  }

  /// The blur intensity at each corresponding stop.
  ///
  /// Each value defines the fraction of the maximum blur strength
  /// (defined by `sigma`) applied at the corresponding control point
  /// from [stops].
  ///
  /// * `0.0`: Effective sigma is zero, which results in no blur effect.
  /// * `1.0`: Sigma reaches maximum, which produces full blur strength.
  ///
  /// The values must be in the range `[0.0, 1.0]`.
  ///
  /// ## Examples
  ///
  /// Fading out from begin to end:
  /// ```dart
  /// values: const <double>[1.0, 0.0],
  /// stops:  const <double>[0.0, 1.0],
  /// ```
  ///
  /// Peaking in the middle of the gradient:
  /// ```dart
  /// values: const <double>[0.0, 1.0, 0.0],
  /// stops:  const <double>[0.0, 0.5, 1.0],
  /// ```
  final List<double> values;

  /// Positions of the blur strength control points.
  ///
  /// Normalized to the range `[0.0, 1.0]`. Values outside this range are
  /// allowed.
  ///
  /// Must be sorted in non-decreasing order and match the length of [values].
  final List<double> stops;

  /// Curve that transforms the progression values.
  final Curve curve;

  @override
  double samplePoint(double t) {
    if (t <= stops.first) return values.first;
    if (t >= stops.last) return values.last;

    int i = 0;

    while (i < stops.length - 2 && t > stops[i + 1]) {
      i++;
    }

    final next = i + 1;

    final stop0 = stops[i];
    final stop1 = stops[next];

    if (stop0 == stop1) {
      return t > stop0 ? values[next] : values[i];
    }

    final localT = (t - stop0) / (stop1 - stop0);
    final value = lerpDouble(
      values[i],
      values[next],
      localT,
    )!;

    return curve.transform(value.clamp(0.0, 1.0)).clamp(0.0, 1.0);
  }

  /// Linearly interpolates between two [CustomProgression] objects.
  ///
  /// Enables seamless transitions inside implicit animations or tweens.
  ///
  /// Lists must have the same length to be interpolated continuously.
  static CustomProgression lerp(
    CustomProgression a,
    CustomProgression b,
    double t,
  ) {
    if (identical(a, b)) return a;

    if (a.values.length != b.values.length) return t < 0.5 ? a : b;

    return CustomProgression(
      values: lerpDoubleList(a.values, b.values, t),
      stops: lerpDoubleList(a.stops, b.stops, t),
      curve: InterpolatedCurve(a.curve, b.curve, t),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is CustomProgression &&
        listEquals(other.values, values) &&
        listEquals(other.stops, stops) &&
        other.curve == curve;
  }

  @override
  int get hashCode => Object.hash(
        Object.hashAll(values),
        Object.hashAll(stops),
        curve,
      );

  @override
  String toString() => 'CustomProgression('
      'values: $values, '
      'stops: $stops, '
      'curve: $curve'
      ')';
}
