import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:inspire_blur/src/distribution/distribution.dart';
import 'package:inspire_blur/src/opacity/widget_opacity.dart';

class WidgetOpacityTween extends Tween<WidgetOpacity> {
  WidgetOpacityTween({super.begin, super.end});

  @override
  WidgetOpacity lerp(double t) {
    final a = begin;
    final b = end;

    if (identical(a, b) && a != null) return a;

    if (a is SolidWidgetOpacity && b is SolidWidgetOpacity) return a;
    if (a is MatchingWidgetOpacity && b is MatchingWidgetOpacity) return a;

    if (a != null &&
        b != null &&
        _isUniformOpacityBased(a) &&
        _isUniformOpacityBased(b)) {
      final opacity =
          lerpDouble(a.shaderOpacityValue, b.shaderOpacityValue, t)!;
      return opacity == 1.0
          ? const WidgetOpacity.solid()
          : WidgetOpacity.semiOpaque(opacity: opacity);
    }

    if (a != null &&
        b != null &&
        _isDistributionBased(a) &&
        _isDistributionBased(b)) {
      return WidgetOpacity.customDistribution(
        distribution: Distribution.lerp(a.distribution!, b.distribution!, t),
      );
    }

    return (t < 0.5 ? a : b) ?? const WidgetOpacity.solid();
  }

  bool _isUniformOpacityBased(WidgetOpacity? widgetOpacity) =>
      widgetOpacity is SolidWidgetOpacity ||
      widgetOpacity is SemiOpaqueWidgetOpacity;

  bool _isDistributionBased(WidgetOpacity? widgetOpacity) =>
      widgetOpacity is CustomDistributionWidgetOpacity;
}
