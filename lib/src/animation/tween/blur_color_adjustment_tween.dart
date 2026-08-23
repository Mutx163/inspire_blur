import 'package:flutter/widgets.dart';
import 'package:inspire_blur/src/color_adjustment/blur_color_adjustment.dart';

class BlurColorAdjustmentTween extends Tween<BlurColorAdjustment> {
  BlurColorAdjustmentTween({super.begin, super.end});

  @override
  BlurColorAdjustment lerp(double t) => BlurColorAdjustment.lerp(begin, end, t);
}
