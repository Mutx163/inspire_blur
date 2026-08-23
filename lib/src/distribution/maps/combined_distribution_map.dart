import 'package:inspire_blur/src/distribution/distribution_map.dart';
import 'package:inspire_blur/src/model/distribution_blend.dart';

class CombinedDistributionMap extends IntensityBasedDistributionMap {
  final List<IntensityBasedDistributionMap> distributionMaps;
  final DistributionBlend blend;

  const CombinedDistributionMap({
    required super.width,
    required super.height,
    required super.strengthFactor,
    required this.distributionMaps,
    required this.blend,
  });

  @override
  double intensityAt(double u, double v) {
    return blend.combine(
      distributionMaps.map(
        (distribution) =>
            distribution.intensityAt(u, v) * distribution.strengthFactor,
      ),
    );
  }
}
