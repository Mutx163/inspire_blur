import 'package:inspire_blur/src/distribution/blur_distribution_map.dart';
import 'package:inspire_blur/src/distribution/maps/directional_distribution_map.dart';

/// Bakes a [ProductDistribution] by multiplying the two factors per pixel.
///
/// Extends [IntensityBasedDistributionMap] on purpose: that is what lets the
/// fork's pixel cache ([BlurDistributionPixelsCache]) kick in for this
/// distribution too. Without it every mount would re-evaluate width×height
/// pixels synchronously — the exact cost patch #1 was written to remove.
class ProductDistributionMap extends IntensityBasedDistributionMap {
  final DirectionalDistributionMap first;
  final DirectionalDistributionMap second;

  ProductDistributionMap({
    required super.width,
    required super.height,
    required this.first,
    required this.second,
  });

  @override
  double intensityAt(double u, double v) =>
      first.intensityAt(u, v) * second.intensityAt(u, v);
}
