import 'package:flutter/widgets.dart';
import 'package:inspire_blur/src/transform/blur_transform.dart';

class BlurTransformTween extends Tween<BlurTransform> {
  BlurTransformTween({super.begin, super.end});

  @override
  BlurTransform lerp(double t) => BlurTransform.lerp(begin, end, t);
}
