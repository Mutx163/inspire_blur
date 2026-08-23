part of 'package:inspire_blur/src/distribution/distribution.dart';

/// Defines the shared semantics for a progressing distribution.
sealed class ProgressingDistribution extends Distribution {
  /// Constructs a progressing distribution.
  const ProgressingDistribution({
    required this.progression,
    super.strengthFactor,
  });

  final Progression progression;

  /// Returns `true` if the [progression] of this and the [other]
  /// distribution are equal.
  @protected
  bool progressingDistributionEquals(ProgressingDistribution other) =>
      progression == other.progression;

  /// Returns the hash code of the [progression].
  @protected
  int progressingDistributionHashCode() => progression.hashCode;
}
