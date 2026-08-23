import 'package:flutter/widgets.dart';
import 'package:inspire_blur/src/animation/tween/blur_color_adjustment_tween.dart';
import 'package:inspire_blur/src/animation/tween/blur_sigma_tween.dart';
import 'package:inspire_blur/src/animation/tween/blur_transform_tween.dart';
import 'package:inspire_blur/src/animation/tween/distribution_tween.dart';
import 'package:inspire_blur/src/animation/tween/widget_opacity_tween.dart';
import 'package:inspire_blur/src/color_adjustment/blur_color_adjustment.dart';
import 'package:inspire_blur/src/distribution/distribution.dart';
import 'package:inspire_blur/src/inspire_blur_config.dart';
import 'package:inspire_blur/src/opacity/widget_opacity.dart';
import 'package:inspire_blur/src/transform/blur_transform.dart';

abstract class AnimatedInspireBlurBase extends ImplicitlyAnimatedWidget {
  const AnimatedInspireBlurBase({
    super.key,
    required this.config,
    this.clipBehavior = Clip.antiAlias,
    this.useRepaintBoundary = true,
    this.layoutInvalidationKey,
    super.curve,
    required super.duration,
    super.onEnd,
  });

  final InspireBlurConfig config;
  final Clip clipBehavior;
  final bool useRepaintBoundary;
  final Object? layoutInvalidationKey;
}

abstract class AnimatedInspireBlurBaseState<T extends AnimatedInspireBlurBase>
    extends AnimatedWidgetBaseState<T> {
  BlurSigmaTween? _sigmaXTween;
  BlurSigmaTween? _sigmaYTween;
  DistributionTween? _blurDistributionTween;
  BlurTransformTween? _transformTween;
  WidgetOpacityTween? _widgetOpacityTween;
  BlurColorAdjustmentTween? _colorAdjustmentTween;

  double? get currentSigmaX => _sigmaXTween?.evaluate(animation);
  double? get currentSigmaY => _sigmaYTween?.evaluate(animation);

  Distribution get currentBlurDistribution =>
      _blurDistributionTween!.evaluate(animation);

  BlurTransform get currentTransform => _transformTween!.evaluate(animation);

  WidgetOpacity get currentWidgetOpacity =>
      _widgetOpacityTween!.evaluate(animation);

  BlurColorAdjustment get currentColorAdjustment =>
      _colorAdjustmentTween!.evaluate(animation);

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _sigmaXTween = visitor(
      _sigmaXTween,
      widget.config.effectiveSigmaX ?? 0.0,
      (value) => BlurSigmaTween(begin: value as double?),
    ) as BlurSigmaTween?;

    _sigmaYTween = visitor(
      _sigmaYTween,
      widget.config.effectiveSigmaY ?? 0.0,
      (value) => BlurSigmaTween(begin: value as double?),
    ) as BlurSigmaTween?;

    _blurDistributionTween = visitor(
      _blurDistributionTween,
      widget.config.blurDistribution,
      (value) => DistributionTween(begin: value as Distribution),
    ) as DistributionTween?;

    _transformTween = visitor(
      _transformTween,
      widget.config.transform,
      (value) => BlurTransformTween(begin: value as BlurTransform),
    ) as BlurTransformTween?;

    _widgetOpacityTween = visitor(
      _widgetOpacityTween,
      widget.config.widgetOpacity,
      (value) => WidgetOpacityTween(begin: value as WidgetOpacity),
    ) as WidgetOpacityTween?;

    _colorAdjustmentTween = visitor(
      _colorAdjustmentTween,
      widget.config.colorAdjustment,
      (value) => BlurColorAdjustmentTween(begin: value as BlurColorAdjustment),
    ) as BlurColorAdjustmentTween?;
  }
}
