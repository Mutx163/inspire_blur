import 'dart:ui';

import 'package:flutter/widgets.dart';

class InterpolatedCurve extends Curve {
  const InterpolatedCurve(
    this.curveA,
    this.curveB,
    this.interpolationPoint,
  );

  final Curve curveA;
  final Curve curveB;
  final double interpolationPoint;

  @override
  double transform(double t) {
    return lerpDouble(
      curveA.transform(t),
      curveB.transform(t),
      interpolationPoint,
    )!;
  }
}
