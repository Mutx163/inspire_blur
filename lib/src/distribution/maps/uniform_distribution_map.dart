import 'package:inspire_blur/src/distribution/distribution_map.dart';

class UniformDistributionMap extends IntensityBasedDistributionMap {
  const UniformDistributionMap({
    required super.width,
    required super.height,
    required super.strengthFactor,
  });

  @override
  double intensityAt(double u, double v) => 1.0;
}
