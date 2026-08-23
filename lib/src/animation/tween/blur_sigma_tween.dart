import 'dart:ui';

import 'package:flutter/widgets.dart';

class BlurSigmaTween extends Tween<double> {
  BlurSigmaTween({super.begin, super.end});

  @override
  double lerp(double t) => lerpDouble(begin, end, t)!;
}
