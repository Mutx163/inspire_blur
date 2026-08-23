import 'package:flutter/widgets.dart';
import 'package:inspire_blur/src/animation/animated_inspire_blur_base.dart';
import 'package:inspire_blur/src/inspire_backdrop_blur.dart';

class AnimatedInspireBackdropBlur extends AnimatedInspireBlurBase {
  const AnimatedInspireBackdropBlur({
    super.key,
    required super.config,
    this.child,
    super.clipBehavior = Clip.antiAlias,
    super.useRepaintBoundary = true,
    super.layoutInvalidationKey,
    super.curve,
    required super.duration,
    super.onEnd,
  });

  final Widget? child;

  @override
  ImplicitlyAnimatedWidgetState<ImplicitlyAnimatedWidget> createState() =>
      _AnimatedInspireBackdropBlurState();
}

class _AnimatedInspireBackdropBlurState
    extends AnimatedInspireBlurBaseState<AnimatedInspireBackdropBlur> {
  @override
  Widget build(BuildContext context) {
    return InspireBackdropBlur(
      config: widget.config
          .withSigma(
            sigmaX: currentSigmaX,
            sigmaY: currentSigmaY,
          )
          .copyWith(
            blurDistribution: currentBlurDistribution,
            transform: currentTransform,
            widgetOpacity: currentWidgetOpacity,
            colorAdjustment: currentColorAdjustment,
          ),
      clipBehavior: widget.clipBehavior,
      useRepaintBoundary: widget.useRepaintBoundary,
      layoutInvalidationKey: widget.layoutInvalidationKey,
      child: widget.child,
    );
  }
}
