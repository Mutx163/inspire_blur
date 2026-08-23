import 'dart:ui' as ui show Image;

import 'package:inspire_blur/src/distribution/distribution_image.dart';
import 'package:inspire_blur/src/distribution/distribution_map.dart';

class ImageMaskDistributionMap extends DistributionMap {
  final ui.Image maskImage;

  ImageMaskDistributionMap({
    required super.width,
    required super.height,
    required this.maskImage,
  });

  @override
  Future<DistributionImage> getDistributionImage() async =>
      DistributionImage.borrowed(maskImage);
}
