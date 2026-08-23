import 'package:flutter/widgets.dart';
import 'package:inspire_blur/src/distribution/distribution.dart';

class DistributionTween extends Tween<Distribution> {
  DistributionTween({super.begin, super.end});

  @override
  Distribution lerp(double t) => Distribution.lerp(begin, end, t);
}
