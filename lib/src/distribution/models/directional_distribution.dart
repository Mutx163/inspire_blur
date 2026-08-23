part of 'package:inspire_blur/src/distribution/distribution.dart';

/// A directional distribution based on a [progression] of intensity
/// from [begin] to [end].
final class DirectionalDistribution extends ProgressingDistribution {
  /// Creates a directional distribution.
  ///
  /// The intensity is distributed along the direction from [begin] to [end]
  /// according to [progression].
  ///
  /// If [begin] is equal to [end], the distribution is collapsed, and produces
  /// zero intensity across the whole area.
  const DirectionalDistribution({
    required this.begin,
    required this.end,
    super.progression = const Progression.gradient(),
    super.strengthFactor,
  });

  /// Starting point of the distribution.
  final Alignment begin;

  /// Ending point of the distribution.
  final Alignment end;

  /// Returns a copy of this distribution with the provided properties updated.
  ///
  /// Any parameter left `null` retains its current value.
  @override
  DirectionalDistribution copyWith({
    Alignment? begin,
    Alignment? end,
    Progression? progression,
    double? strengthFactor,
  }) {
    return DirectionalDistribution(
      begin: begin ?? this.begin,
      end: end ?? this.end,
      progression: progression ?? this.progression,
      strengthFactor: strengthFactor ?? this.strengthFactor,
    );
  }

  /// Linearly interpolates between two [DirectionalDistribution] objects.
  ///
  /// Enables seamless transitions inside implicit animations or tweens.
  static DirectionalDistribution lerp(
    DirectionalDistribution a,
    DirectionalDistribution b,
    double t,
  ) {
    if (identical(a, b)) return a;

    return DirectionalDistribution(
      begin: Alignment.lerp(a.begin, b.begin, t)!,
      end: Alignment.lerp(a.end, b.end, t)!,
      progression: Progression.lerp(a.progression, b.progression, t),
      strengthFactor: lerpDouble(a.strengthFactor, b.strengthFactor, t)!,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is DirectionalDistribution &&
        other.begin == begin &&
        other.end == end &&
        progressingDistributionEquals(other) &&
        other.strengthFactor == strengthFactor;
  }

  @override
  int get hashCode => Object.hash(
        begin,
        end,
        progression,
        strengthFactor,
      );

  @override
  String toString() => 'DirectionalDistribution('
      'begin: $begin, '
      'end: $end, '
      'progression: $progression, '
      'strengthFactor: $strengthFactor'
      ')';
}
