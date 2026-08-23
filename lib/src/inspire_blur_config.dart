import 'dart:math' show max;
import 'dart:ui' as ui show Image;

import 'package:flutter/widgets.dart';
import 'package:inspire_blur/src/color_adjustment/blur_color_adjustment.dart';
import 'package:inspire_blur/src/distribution/distribution.dart';
import 'package:inspire_blur/src/model/blur_edge_fade.dart';
import 'package:inspire_blur/src/model/distribution_blend.dart';
import 'package:inspire_blur/src/model/distribution_fit.dart';
import 'package:inspire_blur/src/model/progression/progression.dart';
import 'package:inspire_blur/src/opacity/widget_opacity.dart';
import 'package:inspire_blur/src/transform/blur_transform.dart';

/// Defines how blur is applied, including strength and spatial
/// [blurDistribution].
///
/// Allows for custom [transform] of the spatial distribution and
/// [colorAdjustment] of the blur effect.
///
/// Blur strength can be:
/// * **Uniform:** using [sigma]
/// * **Independent per-axis:** using [sigmaX] and/or [sigmaY]
///
/// For common patterns, use the factory constructors, such as
/// [InspireBlurConfig.topToBottom] or [InspireBlurConfig.directional].
class InspireBlurConfig {
  /// Blur strength applied uniformly in both directions.
  ///
  /// This produces a standard two-dimensional Gaussian blur.
  ///
  /// To control horizontal and vertical blur strength separately,
  /// use [sigmaX] and/or [sigmaY].
  final double? sigma;

  /// Blur strength applied horizontally.
  ///
  /// Can be used independently or together with [sigmaY].
  final double? sigmaX;

  /// Blur strength applied vertically.
  ///
  /// Can be used independently or together with [sigmaX].
  final double? sigmaY;

  /// Returns the effective horizontal blur strength specified
  /// by [sigma] or [sigmaX].
  ///
  /// A `null` value indicates no horizontal blur.
  double? get effectiveSigmaX => sigma ?? sigmaX;

  /// Returns the effective vertical blur strength specified
  /// by [sigma] or [sigmaY].
  ///
  /// A `null` value indicates no vertical blur.
  double? get effectiveSigmaY => sigma ?? sigmaY;

  /// Spatial distribution of the blur effect.
  final Distribution blurDistribution;

  /// Transformation of the blur effect distribution.
  final BlurTransform transform;

  /// Widget opacity.
  ///
  /// Describes the spatial distribution of the widget opacity.
  ///
  /// Applies only to child blur. By default, the widget is fully opaque.
  final WidgetOpacity widgetOpacity;

  /// Color adjustment of the blur effect.
  final BlurColorAdjustment colorAdjustment;

  /// Creates a blur configuration.
  ///
  /// To define blur strength, provide one of the following combinations:
  /// * [sigma]
  /// * at least one of [sigmaX], [sigmaY]
  ///
  /// [sigmaX] and [sigmaY] can have different values to generate different
  /// blur strengths on the horizontal and vertical axes.
  ///
  /// Providing [sigma] together with [sigmaX] or [sigmaY] will throw an
  /// assertion error.
  const InspireBlurConfig({
    required this.blurDistribution,
    this.transform = BlurTransform.identity,
    this.widgetOpacity = const WidgetOpacity.solid(),
    this.colorAdjustment = const BlurColorAdjustment(),
    this.sigma,
    this.sigmaX,
    this.sigmaY,
  })  : assert(
          (sigma != null) ^ (sigmaX != null || sigmaY != null),
          'Provide either sigma OR at least one of sigmaX / sigmaY',
        ),
        assert(
          sigma != null ? sigma >= 0.0 : true,
          'Provide non-negative sigma',
        ),
        assert(
          sigmaX != null ? sigmaX >= 0.0 : true,
          'Provide non-negative sigmaX',
        ),
        assert(
          sigmaY != null ? sigmaY >= 0.0 : true,
          'Provide non-negative sigmaY',
        );

  /// Progressive blur fading from top to bottom.
  ///
  /// {@macro inspire_blur_config.progression_fade_range}
  ///
  /// {@macro inspire_blur_config.progression_curves}
  factory InspireBlurConfig.topToBottom({
    double? sigma,
    double? sigmaX,
    double? sigmaY,
    double fadeStart = 0.0,
    double fadeEnd = 1.0,
    Curve fadeCurve = Curves.easeInSine,
    BlurTransform transform = BlurTransform.identity,
    WidgetOpacity widgetOpacity = const WidgetOpacity.solid(),
    BlurColorAdjustment colorAdjustment = const BlurColorAdjustment(),
  }) {
    return InspireBlurConfig.directional(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      sigma: sigma,
      sigmaX: sigmaX,
      sigmaY: sigmaY,
      fadeStart: fadeStart,
      fadeEnd: fadeEnd,
      fadeCurve: fadeCurve,
      transform: transform,
      widgetOpacity: widgetOpacity,
      colorAdjustment: colorAdjustment,
    );
  }

  /// Progressive blur fading from bottom to top.
  ///
  /// {@macro inspire_blur_config.progression_fade_range}
  ///
  /// {@macro inspire_blur_config.progression_curves}
  factory InspireBlurConfig.bottomToTop({
    double? sigma,
    double? sigmaX,
    double? sigmaY,
    double fadeStart = 0.0,
    double fadeEnd = 1.0,
    Curve fadeCurve = Curves.easeInSine,
    BlurTransform transform = BlurTransform.identity,
    WidgetOpacity widgetOpacity = const WidgetOpacity.solid(),
    BlurColorAdjustment colorAdjustment = const BlurColorAdjustment(),
  }) {
    return InspireBlurConfig.directional(
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
      sigma: sigma,
      sigmaX: sigmaX,
      sigmaY: sigmaY,
      fadeStart: fadeStart,
      fadeEnd: fadeEnd,
      fadeCurve: fadeCurve,
      transform: transform,
      widgetOpacity: widgetOpacity,
      colorAdjustment: colorAdjustment,
    );
  }

  /// Progressive blur fading from left to right.
  ///
  /// {@macro inspire_blur_config.progression_fade_range}
  ///
  /// {@macro inspire_blur_config.progression_curves}
  factory InspireBlurConfig.leftToRight({
    double? sigma,
    double? sigmaX,
    double? sigmaY,
    double fadeStart = 0.0,
    double fadeEnd = 1.0,
    Curve fadeCurve = Curves.easeInSine,
    BlurTransform transform = BlurTransform.identity,
    WidgetOpacity widgetOpacity = const WidgetOpacity.solid(),
    BlurColorAdjustment colorAdjustment = const BlurColorAdjustment(),
  }) {
    return InspireBlurConfig.directional(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      sigma: sigma,
      sigmaX: sigmaX,
      sigmaY: sigmaY,
      fadeStart: fadeStart,
      fadeEnd: fadeEnd,
      fadeCurve: fadeCurve,
      transform: transform,
      widgetOpacity: widgetOpacity,
      colorAdjustment: colorAdjustment,
    );
  }

  /// Progressive blur fading from right to left.
  ///
  /// {@macro inspire_blur_config.progression_fade_range}
  ///
  /// {@macro inspire_blur_config.progression_curves}
  factory InspireBlurConfig.rightToLeft({
    double? sigma,
    double? sigmaX,
    double? sigmaY,
    double fadeStart = 0.0,
    double fadeEnd = 1.0,
    Curve fadeCurve = Curves.easeInSine,
    BlurTransform transform = BlurTransform.identity,
    WidgetOpacity widgetOpacity = const WidgetOpacity.solid(),
    BlurColorAdjustment colorAdjustment = const BlurColorAdjustment(),
  }) {
    return InspireBlurConfig.directional(
      begin: Alignment.centerRight,
      end: Alignment.centerLeft,
      sigma: sigma,
      sigmaX: sigmaX,
      sigmaY: sigmaY,
      fadeStart: fadeStart,
      fadeEnd: fadeEnd,
      fadeCurve: fadeCurve,
      transform: transform,
      widgetOpacity: widgetOpacity,
      colorAdjustment: colorAdjustment,
    );
  }

  /// Progressive blur from [begin] to [end].
  ///
  /// {@template inspire_blur_config.progression_fade_range}
  /// [fadeStart] defines where the blur progression starts.
  ///
  /// [fadeEnd] defines where the blur progression ends.
  ///
  /// Typical values are in the range `[0.0, 1.0]`, although values outside
  /// this range are also supported.
  ///
  /// [fadeEnd] must be greater than or equal to [fadeStart].
  /// {@endtemplate}
  ///
  /// {@template inspire_blur_config.progression_curves}
  /// [fadeCurve] defines how blur intensity transitions across the progression.
  ///
  /// For example:
  /// * [Curves.easeIn] produces a smoother, more gradual fade than
  ///   [Curves.linear], especially for large blur sigma values.
  /// * [Curves.easeOut] concentrates most of the blur near the beginning,
  ///   creating a more abrupt fade near the end.
  /// {@endtemplate}
  factory InspireBlurConfig.directional({
    required Alignment begin,
    required Alignment end,
    double? sigma,
    double? sigmaX,
    double? sigmaY,
    double fadeStart = 0.0,
    double fadeEnd = 1.0,
    Curve fadeCurve = Curves.easeInSine,
    BlurTransform transform = BlurTransform.identity,
    WidgetOpacity widgetOpacity = const WidgetOpacity.solid(),
    BlurColorAdjustment colorAdjustment = const BlurColorAdjustment(),
  }) {
    assert(
      fadeStart <= fadeEnd,
      'fadeStart must be less than or equal to fadeEnd',
    );

    return InspireBlurConfig(
      sigma: sigma,
      sigmaX: sigmaX,
      sigmaY: sigmaY,
      blurDistribution: DirectionalDistribution(
        begin: begin,
        end: end,
        progression: Progression.gradient(
          start: fadeStart,
          end: fadeEnd,
          curve: fadeCurve,
        ),
      ),
      transform: transform,
      widgetOpacity: widgetOpacity,
      colorAdjustment: colorAdjustment,
    );
  }

  factory InspireBlurConfig.edges({
    BlurEdgeFade? top,
    BlurEdgeFade? bottom,
    BlurEdgeFade? left,
    BlurEdgeFade? right,
    DistributionBlend blend = const DistributionBlend.max(),
    BlurTransform transform = BlurTransform.identity,
    WidgetOpacity widgetOpacity = const WidgetOpacity.solid(),
    BlurColorAdjustment colorAdjustment = const BlurColorAdjustment(),
  }) {
    final allEdges = [top, bottom, left, right].nonNulls;

    final double? sigma, sigmaX, sigmaY;

    if (allEdges.isEmpty) {
      sigma = 0.0;
      sigmaX = null;
      sigmaY = null;
    } else {
      sigma = BlurEdgeFade.effectiveMaxSigma(allEdges);
      sigmaX = BlurEdgeFade.effectiveMaxSigmaX(allEdges);
      sigmaY = BlurEdgeFade.effectiveMaxSigmaY(allEdges);
    }

    final maxSigma = max(sigma ?? 0.0, max(sigmaX ?? 0.0, sigmaY ?? 0.0));

    return InspireBlurConfig(
      sigma: sigma,
      sigmaX: sigmaX,
      sigmaY: sigmaY,
      blurDistribution: CombinedDistribution(
        distributions: [
          if (top != null)
            DirectionalDistribution(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              progression: top.progression,
              strengthFactor: maxSigma == 0.0 ? 0.0 : top.maxSigma() / maxSigma,
            ),
          if (bottom != null)
            DirectionalDistribution(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              progression: bottom.progression,
              strengthFactor:
                  maxSigma == 0.0 ? 0.0 : bottom.maxSigma() / maxSigma,
            ),
          if (left != null)
            DirectionalDistribution(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              progression: left.progression,
              strengthFactor:
                  maxSigma == 0.0 ? 0.0 : left.maxSigma() / maxSigma,
            ),
          if (right != null)
            DirectionalDistribution(
              begin: Alignment.centerRight,
              end: Alignment.centerLeft,
              progression: right.progression,
              strengthFactor:
                  maxSigma == 0.0 ? 0.0 : right.maxSigma() / maxSigma,
            ),
        ],
        blend: blend,
      ),
      transform: transform,
      widgetOpacity: widgetOpacity,
      colorAdjustment: colorAdjustment,
    );
  }

  /// Blur with a circular fade.
  ///
  /// [radius] defines the size of the circular blur region as a fraction
  /// of the area.
  ///
  /// Typical values are in the range `[0.0, 1.0]`, although values greater
  /// than `1.0` are also supported. This causes the circle to extend beyond
  /// the widget bounds, which can be useful for creating large vignette or
  /// spotlight effects.
  ///
  /// {@template inspire_blur_config.progression_feather}
  /// [feather] is the width of the blur transition. A value of `0.0` creates
  /// a hard edge, while larger values create a softer and more gradual
  /// transition.
  /// {@endtemplate}
  ///
  /// [center] specifies the center point of the circular blur region.
  /// The default is [Alignment.center].
  ///
  /// {@macro inspire_blur_config.progression_curves}
  factory InspireBlurConfig.circle({
    required double radius,
    double? sigma,
    double? sigmaX,
    double? sigmaY,
    double feather = 1.0,
    Alignment center = Alignment.center,
    Curve fadeCurve = Curves.easeOutSine,
    BlurTransform transform = BlurTransform.identity,
    WidgetOpacity widgetOpacity = const WidgetOpacity.solid(),
    BlurColorAdjustment colorAdjustment = const BlurColorAdjustment(),
  }) {
    return InspireBlurConfig.ellipse(
      radiusX: radius,
      radiusY: radius,
      sigma: sigma,
      sigmaX: sigmaX,
      sigmaY: sigmaY,
      feather: feather,
      center: center,
      fadeCurve: fadeCurve,
      distributionFit: DistributionFit.inside,
      transform: transform,
      widgetOpacity: widgetOpacity,
      colorAdjustment: colorAdjustment,
    );
  }

  /// Blur with an elliptical fade.
  ///
  /// [radiusX] and [radiusY] define the size of the elliptical blur region
  /// as a fraction of the area.
  ///
  /// Typical values are in the range `[0.0, 1.0]`, although values greater
  /// than `1.0` are also supported. This causes the ellipse to extend beyond
  /// the widget bounds, which can be useful for creating large vignette or
  /// spotlight effects.
  ///
  /// {@macro inspire_blur_config.progression_feather}
  ///
  /// [center] specifies the center point of the elliptical blur region.
  /// The default is [Alignment.center].
  ///
  /// {@macro inspire_blur_config.progression_curves}
  ///
  /// [distributionFit] controls how the distribution is fitted to the
  /// widget bounds. By default, it fills the available area.
  factory InspireBlurConfig.ellipse({
    required double radiusX,
    required double radiusY,
    double? sigma,
    double? sigmaX,
    double? sigmaY,
    double feather = 1.0,
    Alignment center = Alignment.center,
    DistributionFit distributionFit = DistributionFit.fill,
    Curve fadeCurve = Curves.easeOutSine,
    BlurTransform transform = BlurTransform.identity,
    WidgetOpacity widgetOpacity = const WidgetOpacity.solid(),
    BlurColorAdjustment colorAdjustment = const BlurColorAdjustment(),
  }) {
    assert(
      feather >= 0.0 && feather <= 1.0,
      'feather must be in the range [0.0, 1.0]',
    );

    return InspireBlurConfig(
      sigma: sigma,
      sigmaX: sigmaX,
      sigmaY: sigmaY,
      blurDistribution: EllipseDistribution(
        radiusX: radiusX,
        radiusY: radiusY,
        center: center,
        progression: Progression.gradient(
          start: 1.0 - feather,
          end: 1.0,
          curve: fadeCurve,
        ),
        distributionFit: distributionFit,
      ),
      transform: transform,
      widgetOpacity: widgetOpacity,
      colorAdjustment: colorAdjustment,
    );
  }

  /// Blur with a square fade.
  ///
  /// [inset] is the distance from the left and right or top and bottom
  /// edge of the widget to the rectangular blur region (whichever pair
  /// is shorter).
  ///
  /// {@macro inspire_blur_config.progression_feather}
  ///
  /// [inset] and [feather] are normalized to the range `[0.0, 1.0]`.
  ///
  /// {@macro inspire_blur_config.progression_curves}
  factory InspireBlurConfig.square({
    double inset = 0.0,
    double feather = 0.5,
    double? sigma,
    double? sigmaX,
    double? sigmaY,
    Curve fadeCurve = Curves.easeOutSine,
    BlurTransform transform = BlurTransform.identity,
    WidgetOpacity widgetOpacity = const WidgetOpacity.solid(),
    BlurColorAdjustment colorAdjustment = const BlurColorAdjustment(),
  }) {
    return InspireBlurConfig.rectangle(
      horizontalInset: inset,
      verticalInset: inset,
      feather: feather,
      sigma: sigma,
      sigmaX: sigmaX,
      sigmaY: sigmaY,
      fadeCurve: fadeCurve,
      distributionFit: DistributionFit.inside,
      transform: transform,
      widgetOpacity: widgetOpacity,
      colorAdjustment: colorAdjustment,
    );
  }

  /// Blur with a rounded square fade.
  ///
  /// [inset] is the distance from the left and right or top and bottom
  /// edge of the widget to the rectangular blur region (whichever pair
  /// is shorter).
  ///
  /// [cornerRadius] is the radius of the rectangle corners.
  ///
  /// {@macro inspire_blur_config.progression_feather}
  ///
  /// [inset] and [feather] are normalized to the range `[0.0, 1.0]`.
  ///
  /// {@macro inspire_blur_config.progression_curves}
  factory InspireBlurConfig.roundedSquare({
    double inset = 0.0,
    required double cornerRadius,
    double feather = 0.5,
    double? sigma,
    double? sigmaX,
    double? sigmaY,
    Curve fadeCurve = Curves.easeOutSine,
    BlurTransform transform = BlurTransform.identity,
    WidgetOpacity widgetOpacity = const WidgetOpacity.solid(),
    BlurColorAdjustment colorAdjustment = const BlurColorAdjustment(),
  }) {
    return InspireBlurConfig.roundedRectangle(
      horizontalInset: inset,
      verticalInset: inset,
      cornerRadius: cornerRadius,
      feather: feather,
      sigma: sigma,
      sigmaX: sigmaX,
      sigmaY: sigmaY,
      fadeCurve: fadeCurve,
      distributionFit: DistributionFit.inside,
      transform: transform,
      widgetOpacity: widgetOpacity,
      colorAdjustment: colorAdjustment,
    );
  }

  /// Blur with a rectangular fade.
  ///
  /// [horizontalInset] is the distance from the left and right edges of
  /// the widget to the rectangular blur region.
  ///
  /// [verticalInset] is the distance from the top and bottom edges of
  /// the widget to the rectangular blur region.
  ///
  /// {@macro inspire_blur_config.progression_feather}
  ///
  /// [horizontalInset], [verticalInset], and [feather] are normalized
  /// to the range `[0.0, 1.0]`.
  ///
  /// {@macro inspire_blur_config.progression_curves}
  ///
  /// [distributionFit] controls how the distribution is fitted to the
  /// widget bounds. By default, it fills the available area.
  factory InspireBlurConfig.rectangle({
    double horizontalInset = 0.0,
    double verticalInset = 0.0,
    double feather = 0.5,
    double? sigma,
    double? sigmaX,
    double? sigmaY,
    Curve fadeCurve = Curves.easeOutSine,
    DistributionFit distributionFit = DistributionFit.fill,
    BlurTransform transform = BlurTransform.identity,
    WidgetOpacity widgetOpacity = const WidgetOpacity.solid(),
    BlurColorAdjustment colorAdjustment = const BlurColorAdjustment(),
  }) {
    return InspireBlurConfig.roundedRectangle(
      horizontalInset: horizontalInset,
      verticalInset: verticalInset,
      cornerRadius: 0.0,
      feather: feather,
      sigma: sigma,
      sigmaX: sigmaX,
      sigmaY: sigmaY,
      fadeCurve: fadeCurve,
      distributionFit: distributionFit,
      transform: transform,
      widgetOpacity: widgetOpacity,
      colorAdjustment: colorAdjustment,
    );
  }

  /// Blur with a rounded rectangular fade.
  ///
  /// [horizontalInset] is the distance from the left and right edges of
  /// the widget to the rectangular blur region.
  ///
  /// [verticalInset] is the distance from the top and bottom edges of
  /// the widget to the rectangular blur region.
  ///
  /// [cornerRadius] is the radius of the rectangle corners.
  ///
  /// {@macro inspire_blur_config.progression_feather}
  ///
  /// [horizontalInset], [verticalInset], [cornerRadius], and [feather]
  /// are normalized to the range `[0.0, 1.0]`.
  ///
  /// {@macro inspire_blur_config.progression_curves}
  ///
  /// [distributionFit] controls how the distribution is fitted to the
  /// widget bounds. By default, it fills the available area.
  factory InspireBlurConfig.roundedRectangle({
    double horizontalInset = 0.0,
    double verticalInset = 0.0,
    required double cornerRadius,
    double feather = 0.5,
    double? sigma,
    double? sigmaX,
    double? sigmaY,
    Curve fadeCurve = Curves.easeOutSine,
    DistributionFit distributionFit = DistributionFit.fill,
    BlurTransform transform = BlurTransform.identity,
    WidgetOpacity widgetOpacity = const WidgetOpacity.solid(),
    BlurColorAdjustment colorAdjustment = const BlurColorAdjustment(),
  }) {
    assert(
      feather >= 0.0 && feather <= 1.0,
      'feather must be in the range [0.0, 1.0]',
    );

    return InspireBlurConfig(
      sigma: sigma,
      sigmaX: sigmaX,
      sigmaY: sigmaY,
      blurDistribution: RRectDistribution(
        horizontalInset: horizontalInset,
        verticalInset: verticalInset,
        cornerRadius: cornerRadius,
        progression: Progression.gradient(
          start: 1.0 - feather,
          end: 1.0,
          curve: fadeCurve,
        ),
        distributionFit: distributionFit,
      ),
      transform: transform,
      widgetOpacity: widgetOpacity,
      colorAdjustment: colorAdjustment,
    );
  }

  /// Blur with a fade controlled by a custom mask.
  ///
  /// [maskImage] controls the blur intensity over the blur area.
  ///
  /// The intensity of the blur effect is controlled by the red channel,
  /// whereas other channels, including alpha, are ignored.
  ///
  /// ## Recommendations
  ///
  /// * Use an image between 64×64 and 1024×1024 pixels.
  /// * Make image grayscale and fully opaque.
  /// * Match the image aspect ratio to the blurred widget bounds to prevent
  ///   distortion.
  ///
  /// Any image size and aspect ratio is supported. Note that larger images
  /// produce smoother fades but — as a trade-off — consume more GPU memory
  /// and may reduce performance.
  ///
  /// The caller retains ownership of [maskImage] and is responsible for
  /// disposing it after it is no longer used by the blur effect.
  ///
  /// ## Example
  ///
  /// ```dart
  /// ui.Image? maskImage;
  ///
  /// @override
  /// void initState() {
  ///   super.initState();
  ///   loadMaskImage(...).then((image) {
  ///     if (!mounted) {
  ///       image.dispose();
  ///       return;
  ///     }
  ///     setState(() => maskImage = image);
  ///   });
  /// }
  ///
  /// @override
  /// Widget build(BuildContext context) {
  ///   final image = maskImage;
  ///   if (image == null) return const SizedBox.shrink(); // Or a placeholder
  ///
  ///   return Inspire.childBlur(
  ///     config: InspireBlurConfig.customMask(maskImage: image),
  ///     child: ...,
  ///   );
  /// }
  ///
  /// @override
  /// void dispose() {
  ///   maskImage?.dispose();
  ///   super.dispose();
  /// }
  /// ```
  factory InspireBlurConfig.customMask({
    required ui.Image maskImage,
    double? sigma,
    double? sigmaX,
    double? sigmaY,
    BlurTransform transform = BlurTransform.identity,
    WidgetOpacity widgetOpacity = const WidgetOpacity.solid(),
    BlurColorAdjustment colorAdjustment = const BlurColorAdjustment(),
  }) {
    assert(
      maskImage.width > 0 && maskImage.height > 0,
      'maskImage must have valid dimensions.',
    );

    return InspireBlurConfig(
      sigma: sigma,
      sigmaX: sigmaX,
      sigmaY: sigmaY,
      blurDistribution: ImageMaskDistribution(
        maskImage: maskImage,
      ),
      transform: transform,
      widgetOpacity: widgetOpacity,
      colorAdjustment: colorAdjustment,
    );
  }

  /// Blur with a constant strength across the whole widget area.
  factory InspireBlurConfig.solid({
    double? sigma,
    double? sigmaX,
    double? sigmaY,
    BlurTransform transform = BlurTransform.identity,
    WidgetOpacity widgetOpacity = const WidgetOpacity.solid(),
    BlurColorAdjustment colorAdjustment = const BlurColorAdjustment(),
  }) {
    return InspireBlurConfig(
      sigma: sigma,
      sigmaX: sigmaX,
      sigmaY: sigmaY,
      blurDistribution: const UniformDistribution(),
      transform: transform,
      widgetOpacity: widgetOpacity,
      colorAdjustment: colorAdjustment,
    );
  }

  /// Returns a copy of this config with the provided properties updated.
  ///
  /// Any parameter left `null` retains its current value.
  InspireBlurConfig copyWith({
    double? sigma,
    double? sigmaX,
    double? sigmaY,
    Distribution? blurDistribution,
    BlurTransform? transform,
    WidgetOpacity? widgetOpacity,
    BlurColorAdjustment? colorAdjustment,
  }) {
    return InspireBlurConfig(
      sigma: sigma ?? this.sigma,
      sigmaX: sigmaX ?? this.sigmaX,
      sigmaY: sigmaY ?? this.sigmaY,
      blurDistribution: blurDistribution ?? this.blurDistribution,
      transform: transform ?? this.transform,
      widgetOpacity: widgetOpacity ?? this.widgetOpacity,
      colorAdjustment: colorAdjustment ?? this.colorAdjustment,
    );
  }

  /// Returns a copy of this config with all sigma values replaced with
  /// [sigma], [sigmaX], and [sigmaY] parameter values.
  ///
  /// Value of `null` replaces the current config sigma value.
  InspireBlurConfig withSigma({
    double? sigma,
    double? sigmaX,
    double? sigmaY,
  }) {
    return InspireBlurConfig(
      sigma: sigma,
      sigmaX: sigmaX,
      sigmaY: sigmaY,
      blurDistribution: blurDistribution,
      transform: transform,
      widgetOpacity: widgetOpacity,
      colorAdjustment: colorAdjustment,
    );
  }

  /// Returns a copy with blur applied only horizontally.
  InspireBlurConfig onlyHorizontal(double sigma) {
    return InspireBlurConfig(
      sigmaX: sigma,
      sigmaY: null,
      sigma: null,
      blurDistribution: blurDistribution,
      transform: transform,
      widgetOpacity: widgetOpacity,
      colorAdjustment: colorAdjustment,
    );
  }

  /// Returns a copy with blur applied only vertically.
  InspireBlurConfig onlyVertical(double sigma) {
    return InspireBlurConfig(
      sigmaX: null,
      sigmaY: sigma,
      sigma: null,
      blurDistribution: blurDistribution,
      transform: transform,
      widgetOpacity: widgetOpacity,
      colorAdjustment: colorAdjustment,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is InspireBlurConfig &&
        other.sigma == sigma &&
        other.sigmaX == sigmaX &&
        other.sigmaY == sigmaY &&
        other.blurDistribution == blurDistribution &&
        other.transform == transform &&
        other.widgetOpacity == widgetOpacity &&
        other.colorAdjustment == colorAdjustment;
  }

  @override
  int get hashCode => Object.hash(
        sigma,
        sigmaX,
        sigmaY,
        blurDistribution,
        transform,
        widgetOpacity,
        colorAdjustment,
      );

  @override
  String toString() => 'InspireBlurConfig('
      'sigma: $sigma, '
      'sigmaX: $sigmaX, '
      'sigmaY: $sigmaY, '
      'blurDistribution: $blurDistribution, '
      'transform: $transform, '
      'widgetOpacity: $widgetOpacity, '
      'colorAdjustment: $colorAdjustment'
      ')';
}
