part of 'package:inspire_blur/src/distribution/distribution.dart';

class CombinedDistribution extends Distribution {
  final List<Distribution> distributions;
  final DistributionBlend blend;

  const CombinedDistribution({
    required this.distributions,
    required this.blend,
    super.strengthFactor,
  });

  @override
  CombinedDistribution copyWith({
    List<Distribution>? distributions,
    DistributionBlend? blend,
    double? strengthFactor,
  }) {
    return CombinedDistribution(
      distributions: distributions ?? this.distributions,
      blend: blend ?? this.blend,
      strengthFactor: strengthFactor ?? this.strengthFactor,
    );
  }

  static CombinedDistribution lerp(
    CombinedDistribution a,
    CombinedDistribution b,
    double t,
  ) {
    if (identical(a, b)) return a;

    final commonLength = min(
      a.distributions.length,
      b.distributions.length,
    );

    final distributions = <Distribution>[
      for (var i = 0; i < commonLength; i++)
        Distribution.lerp(
          a.distributions[i],
          b.distributions[i],
          t,
        ),
      if (t < 0.5)
        ...a.distributions.skip(commonLength)
      else
        ...b.distributions.skip(commonLength),
    ];

    return CombinedDistribution(
      distributions: distributions,
      blend: t < 0.5 ? a.blend : b.blend,
      strengthFactor: lerpDouble(a.strengthFactor, b.strengthFactor, t)!,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is CombinedDistribution &&
        listEquals(other.distributions, distributions) &&
        other.blend == blend &&
        other.strengthFactor == strengthFactor;
  }

  @override
  int get hashCode => Object.hash(
        Object.hashAll(distributions),
        blend,
        strengthFactor,
      );

  @override
  String toString() => 'CombinedDistribution('
      'distributions: $distributions, '
      'blend: $blend, '
      'strengthFactor: $strengthFactor'
      ')';
}
