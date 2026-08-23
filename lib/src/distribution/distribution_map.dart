import 'package:inspire_blur/src/distribution/distribution.dart';
import 'package:inspire_blur/src/distribution/distribution_image.dart';
import 'package:inspire_blur/src/distribution/maps/combined_distribution_map.dart';
import 'package:inspire_blur/src/distribution/maps/directional_distribution_map.dart';
import 'package:inspire_blur/src/distribution/maps/ellipse_distribution_map.dart';
import 'package:inspire_blur/src/distribution/maps/image_mask_distribution_map.dart';
import 'package:inspire_blur/src/distribution/maps/rrect_distribution_map.dart';
import 'package:inspire_blur/src/distribution/maps/uniform_distribution_map.dart';
import 'package:inspire_blur/src/image/image_mask_generator.dart';

abstract class DistributionMap {
  const DistributionMap({
    required this.width,
    required this.height,
  });

  final int width;
  final int height;

  Future<DistributionImage> getDistributionImage();
}

abstract class IntensityBasedDistributionMap extends DistributionMap {
  final double strengthFactor;

  const IntensityBasedDistributionMap({
    required super.width,
    required super.height,
    required this.strengthFactor,
  });

  @override
  Future<DistributionImage> getDistributionImage() async {
    final image = await ImageMaskGenerator().generateImage(
      width: width,
      height: height,
      strengthFactor: strengthFactor,
      intensityAt: intensityAt,
    );
    return DistributionImage.owned(image);
  }

  double intensityAt(double u, double v);
}

extension DistributionExtension on Distribution {
  DistributionMap toDistributionMap({required int size}) => switch (this) {
        UniformDistribution _ => UniformDistributionMap(
            width: size,
            height: size,
            strengthFactor: strengthFactor,
          ),
        DirectionalDistribution e => DirectionalDistributionMap(
            width: size,
            height: size,
            begin: e.begin,
            end: e.end,
            progression: e.progression,
            strengthFactor: strengthFactor,
          ),
        EllipseDistribution e => EllipseDistributionMap(
            width: size,
            height: size,
            radiusX: e.radiusX,
            radiusY: e.radiusY,
            center: e.center,
            progression: e.progression,
            strengthFactor: strengthFactor,
          ),
        RRectDistribution e => RRectDistributionMap(
            width: size,
            height: size,
            horizontalInset: e.horizontalInset,
            verticalInset: e.verticalInset,
            cornerRadius: e.cornerRadius,
            progression: e.progression,
            strengthFactor: strengthFactor,
          ),
        ImageMaskDistribution e => ImageMaskDistributionMap(
            width: e.maskImage.width,
            height: e.maskImage.height,
            maskImage: e.maskImage,
          ),
        CombinedDistribution e => CombinedDistributionMap(
            width: size,
            height: size,
            distributionMaps: e.distributions
                .map((e) => e.toDistributionMap(size: size))
                .whereType<IntensityBasedDistributionMap>()
                .toList(),
            blend: e.blend,
            strengthFactor: strengthFactor,
          ),
      };
}
