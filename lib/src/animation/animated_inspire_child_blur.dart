import 'package:flutter/widgets.dart';
import 'package:inspire_blur/src/animation/animated_inspire_blur_base.dart';
import 'package:inspire_blur/src/inspire_blur_mode.dart';
import 'package:inspire_blur/src/inspire_child_blur.dart';

class AnimatedInspireChildBlur extends AnimatedInspireBlurBase {
  const AnimatedInspireChildBlur({
    super.key,
    required super.config,
    required this.child,
    this.mode = InspireBlurMode.auto,
    super.clipBehavior = Clip.antiAlias,
    super.useRepaintBoundary = true,
    super.layoutInvalidationKey,
    super.curve,
    required super.duration,
    super.onEnd,
  });

  final InspireBlurMode mode;
  final Widget child;

  @override
  ImplicitlyAnimatedWidgetState<ImplicitlyAnimatedWidget> createState() =>
      _AnimatedInspireChildBlurState();
}

class _AnimatedInspireChildBlurState
    extends AnimatedInspireBlurBaseState<AnimatedInspireChildBlur> {
  @override
  Widget build(BuildContext context) {
    return InspireChildBlur(
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
      mode: widget.mode,
      clipBehavior: widget.clipBehavior,
      useRepaintBoundary: widget.useRepaintBoundary,
      layoutInvalidationKey: widget.layoutInvalidationKey,
      child: widget.child,
    );
  }
}
