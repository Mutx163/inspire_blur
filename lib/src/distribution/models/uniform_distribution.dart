part of 'package:inspire_blur/src/distribution/distribution.dart';

/// A blur distribution with uniform intensity over the entire area.
///
/// Every point receives the maximum blur strength.
final class UniformDistribution extends Distribution {
  /// Creates a uniform blur distribution.
  const UniformDistribution({super.strengthFactor});

  /// Returns a copy of this distribution with the provided properties updated.
  ///
  /// Any parameter left `null` retains its current value.
  @override
  UniformDistribution copyWith({double? strengthFactor}) {
    return UniformDistribution(
      strengthFactor: strengthFactor ?? this.strengthFactor,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UniformDistribution &&
        other.strengthFactor == strengthFactor;
  }

  @override
  int get hashCode => strengthFactor.hashCode;

  @override
  String toString() => 'UniformDistribution('
      'strengthFactor: $strengthFactor'
      ')';
}
