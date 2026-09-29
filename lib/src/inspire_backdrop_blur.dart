import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:inspire_blur/src/color_adjustment/blur_color_adjustment.dart';
import 'package:inspire_blur/src/inspire_blur_config.dart';
import 'package:inspire_blur/src/inspire_blur_wrapper.dart';
import 'package:inspire_blur/src/inspire_child_blur.dart';
import 'package:inspire_blur/src/inspire_shaders.dart';
import 'package:inspire_blur/src/transform/blur_transform.dart';
import 'package:inspire_blur/src/utils/extensions/inspire_geometry_extensions.dart';

/// Applies a blur effect to the content behind this widget.
///
/// Unlike [InspireChildBlur], this widget does not blur its child.
/// Instead, it blurs everything rendered behind it in the widget tree.
///
/// Typically used inside a [Stack], positioned above the content that
/// should be blurred.
class InspireBackdropBlur extends StatelessWidget {
  /// Configuration of the backdrop blur.
  ///
  /// Specifies the strength and spatial distribution of the blur effect.
  final InspireBlurConfig config;

  /// Defines how the blur effect is clipped.
  ///
  /// Disabling clipping allows the blur to extend beyond widget bounds.
  final Clip clipBehavior;

  /// Defines whether to isolate the widget into a [RepaintBoundary].
  ///
  /// Can improve rendering performance and stability.
  ///
  /// In some cases, disabling it may produce more accurate blur updates,
  /// such as in deeply nested scrollable lists.
  final bool useRepaintBoundary;

  /// Allows to manually invalidate the cached screen position of the
  /// blur effect.
  ///
  /// Set [layoutInvalidationKey] to a different value whenever the blur effect
  /// should recalculate its position on the screen. The value can be a simple
  /// integer counter.
  ///
  /// In most cases, this is not needed. The blur effect automatically tracks
  /// changes to the blurred widget's position.
  ///
  /// This might be needed during advanced transitions or animations, where
  /// the blur effect is not receiving a callback about the change of its
  /// screen bounds.
  ///
  /// For example, this might be required when the blur widget is
  /// transformed with [ScaleTransition] or [PositionedTransition].
  final Object? layoutInvalidationKey;

  /// Optional child widget.
  ///
  /// Typically used to define the size of the backdrop blur area.
  ///
  /// Alternatively, the size can be controlled externally using widgets
  /// such as [SizedBox] or [Positioned].
  final Widget? child;

  /// Creates a backdrop blur.
  ///
  /// Blur effect visual properties are specified in the [config].
  ///
  /// An optional [child] may be used, mainly for sizing.
  ///
  /// For performance and stability adjustments, refer to documentation of the
  /// [clipBehavior] and [useRepaintBoundary].
  const InspireBackdropBlur({
    super.key,
    required this.config,
    this.clipBehavior = Clip.antiAlias,
    this.useRepaintBoundary = true,
    this.layoutInvalidationKey,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    if (!ui.ImageFilter.isShaderFilterSupported) {
      // No Impeller support, exit gracefully.
      return child ?? const SizedBox.shrink();
    }

    final childValue = child;

    return InspireBlurWrapper(
      config: config,
      layoutInvalidationKey: layoutInvalidationKey,
      builder: (context, builderData) {
        final gradientMap = builderData.blurGradientMap;
        final globalBounds = builderData.globalBounds;

        // Dependencies are not ready yet — skip a frame with no blur.
        // Typically it should not happen, unless device is slow.
        if (gradientMap == null || globalBounds == null) {
          // ⚠️ 临时探针（2026-09-29 开窗无模糊排查，定位后删除）
          // ignore: avoid_print
          print('blur-probe: blur层缺数据 map≠null=${gradientMap != null} '
              'bounds≠null=${globalBounds != null}');
          return const SizedBox.shrink();
        }

        // ⚠️ 临时探针（2026-09-29 开窗无模糊排查，定位后删除）
        // ignore: avoid_print
        print('blur-probe: wrapper出pass bounds=$globalBounds '
            'mapSize=${gradientMap.width}x${gradientMap.height} '
            'sigmaH=${config.effectiveSigmaX} sigmaV=${config.effectiveSigmaY} '
            'corner=${config.topCornerRadius}');

        final sigmaHorizontal = config.effectiveSigmaX;
        final sigmaVertical = config.effectiveSigmaY;

        if (sigmaHorizontal != null &&
            sigmaVertical != null &&
            sigmaHorizontal > 0.0 &&
            sigmaVertical > 0.0) {
          return _wrapWithClipRect(
            child: _maybeWrapWithRepaintBoundary(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: _InspireBackdropBlurPass(
                      gradientMap: gradientMap,
                      transform: config.transform,
                      colorAdjustment: config.colorAdjustment.disabled(),
                      globalBounds: globalBounds,
                      direction: Axis.horizontal,
                      sigma: sigmaHorizontal,
                      topCornerRadius: config.topCornerRadius,
                    ),
                  ),
                  Positioned.fill(
                    child: _InspireBackdropBlurPass(
                      gradientMap: gradientMap,
                      transform: config.transform,
                      colorAdjustment: config.colorAdjustment,
                      globalBounds: globalBounds,
                      direction: Axis.vertical,
                      sigma: sigmaVertical,
                      topCornerRadius: config.topCornerRadius,
                    ),
                  ),
                  if (childValue != null) childValue,
                ],
              ),
            ),
          );
        }

        if (sigmaHorizontal != null && sigmaHorizontal > 0.0) {
          return _wrapWithClipRect(
            child: _maybeWrapWithRepaintBoundary(
              child: _InspireBackdropBlurPass(
                gradientMap: gradientMap,
                transform: config.transform,
                colorAdjustment: config.colorAdjustment,
                globalBounds: globalBounds,
                direction: Axis.horizontal,
                sigma: sigmaHorizontal,
                topCornerRadius: config.topCornerRadius,
                child: childValue,
              ),
            ),
          );
        }

        if (sigmaVertical != null && sigmaVertical > 0.0 ||

            // Allow to render the effect if there's no blur, but there's
            // an active color adjustment.
            config.colorAdjustment.isActive) {
          return _wrapWithClipRect(
            child: _maybeWrapWithRepaintBoundary(
              child: _InspireBackdropBlurPass(
                gradientMap: gradientMap,
                transform: config.transform,
                colorAdjustment: config.colorAdjustment,
                globalBounds: globalBounds,
                direction: Axis.vertical,
                sigma: sigmaVertical ?? 0.0,
                topCornerRadius: config.topCornerRadius,
                child: childValue,
              ),
            ),
          );
        }

        return childValue ?? const SizedBox.shrink();
      },
    );
  }

  Widget _wrapWithClipRect({required Widget child}) {
    return ClipRect(clipBehavior: clipBehavior, child: child);
  }

  Widget _maybeWrapWithRepaintBoundary({required Widget child}) {
    if (useRepaintBoundary) {
      return RepaintBoundary(child: child);
    } else {
      return child;
    }
  }
}

class _InspireBackdropBlurPass extends StatefulWidget {
  final ui.Image gradientMap;
  final BlurTransform transform;
  final BlurColorAdjustment colorAdjustment;
  final Rect globalBounds;
  final Axis direction;
  final double sigma;

  /// mikcb patch 5：材料形状两个上角的圆弧半径（逻辑 px，0 = 关）。
  final double topCornerRadius;

  final Widget? child;

  const _InspireBackdropBlurPass({
    required this.gradientMap,
    required this.transform,
    required this.colorAdjustment,
    required this.globalBounds,
    required this.direction,
    required this.sigma,
    required this.topCornerRadius,
    this.child,
  });

  @override
  State<_InspireBackdropBlurPass> createState() =>
      _InspireBackdropBlurPassState();
}

class _InspireBackdropBlurPassState extends State<_InspireBackdropBlurPass> {
  ui.FragmentShader? _shader;

  @override
  void initState() {
    super.initState();
    _loadShader();
  }

  void _loadShader() {
    InspireShaders.backdropBlur.then((program) {
      final shader = program?.fragmentShader();
      if (mounted) {
        setState(() {
          _shader = shader;
          _updateShader();
        });
      } else {
        _shader = shader;
        _updateShader();
      }
    });
  }

  @override
  void didUpdateWidget(covariant _InspireBackdropBlurPass oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateShader();
  }

  void _updateShader() {
    final dpr = MediaQuery.of(context).devicePixelRatio;

    // mikcb patch 3 (fix, 2026-09-29): u_size 从未被设置 —— 上游 bug。
    //
    // 着色器里 `uv = FlutterFragCoord() / u_size` 把像素位置换算成整块画布的
    // 归一化坐标，`u_area_origin/size` 也按同一空间解释；u_size 恒为 (0,0) 时
    // uv 与 areaUV 全部退化（Inf/NaN，clamp 后塌到 (0,0)），强度图实际只采样
    // **左上角那一个点的值**，且全程恒定：
    //
    // * 单向渐变分布（顶栏渐进模糊，本库迄今唯一的生产用法）：map(0,0) = 1
    //   → 恒满强度 —— **碰巧接近正确**，bug 被掩盖（grad 顶部渐弱形其实从未
    //   真正生效过，只是衬底渐变掩盖了观感差异）；
    // * 两个方向的乘积分布（底部弹窗顶部渐变带）：map(0,0) = 1 × 0 = 0
    //   → **恒零强度，模糊整条死掉**，只剩衬底白纱（真机口径「渐变模糊变成
    //   透明的，只剩顶部一层白雾」，2026-09-29 定位）。
    //
    // 修法：显式给 u_size = 物理屏幕尺寸。FlutterFragCoord() 在非 GLES 目标
    // 上的 Y 翻转（`u_size.y - y`）也依赖它，一并修正。u_area 传的是
    // globalBounds × dpr（物理、屏幕绝对），同一空间，两处从此自洽。
    final size = MediaQuery.of(context).size * dpr;
    final normalizedOrigin = widget.transform.origin.toNormalizedOffset();

    _shader?.setImageSampler(1, widget.gradientMap);
    _shader?.setFloat(0, size.width);
    _shader?.setFloat(1, size.height);
    _shader?.setFloat(2, widget.sigma);
    _shader?.setFloat(3, widget.direction == Axis.horizontal ? 1.0 : 0.0);
    _shader?.setFloat(4, widget.direction == Axis.vertical ? 1.0 : 0.0);
    _shader?.setFloat(5, widget.globalBounds.left * dpr);
    _shader?.setFloat(6, widget.globalBounds.top * dpr);
    _shader?.setFloat(7, widget.globalBounds.width * dpr);
    _shader?.setFloat(8, widget.globalBounds.height * dpr);
    _shader?.setFloat(9, widget.transform.scale.scaleX);
    _shader?.setFloat(10, widget.transform.scale.scaleY);
    _shader?.setFloat(11, widget.transform.offset.dx);
    _shader?.setFloat(12, widget.transform.offset.dy);
    _shader?.setFloat(13, widget.transform.rotation);
    _shader?.setFloat(14, normalizedOrigin.dx);
    _shader?.setFloat(15, normalizedOrigin.dy);
    _shader?.setFloat(16, widget.transform.inversionFactor);
    _shader?.setFloat(17, widget.colorAdjustment.shaderBrightness);
    _shader?.setFloat(18, widget.colorAdjustment.shaderContrast);
    _shader?.setFloat(19, widget.colorAdjustment.shaderExposure);
    _shader?.setFloat(20, widget.colorAdjustment.shaderSaturation);
    _shader?.setFloat(21, widget.colorAdjustment.shaderVibrance);
    _shader?.setFloat(22, widget.colorAdjustment.blurAdjustmentStrength);
    _shader?.setFloat(23, widget.colorAdjustment.nonBlurAdjustmentStrength);
    // mikcb patch 5：顶角圆弧半径（逻辑 → 物理，SDF 在等比空间里算）。
    _shader?.setFloat(24, widget.topCornerRadius * dpr);
    // ⚠️ 临时探针（2026-09-29 开窗无模糊排查，定位后删除）
    // ignore: avoid_print
    print('blur-probe: updateShader dir=${widget.direction} '
        'areaPx=LTRB(${(widget.globalBounds.left * dpr).toStringAsFixed(1)}, '
        '${(widget.globalBounds.top * dpr).toStringAsFixed(1)}, '
        '${(widget.globalBounds.right * dpr).toStringAsFixed(1)}, '
        '${(widget.globalBounds.bottom * dpr).toStringAsFixed(1)}) '
        'sigma=${widget.sigma} cornerPx=${(widget.topCornerRadius * dpr).toStringAsFixed(1)} '
        'dpr=$dpr');
  }

  @override
  void dispose() {
    _shader?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final shader = _shader;
    // ⚠️ 临时探针（2026-09-29 开窗无模糊排查，定位后删除）
    // ignore: avoid_print
    print('blur-probe: pass build shader=${shader != null} dir=${widget.direction} '
        'bounds=${widget.globalBounds}');
    if (shader == null) {
      return widget.child ?? const SizedBox.shrink();
    }

    return BackdropFilter(
      filter: ui.ImageFilter.shader(shader),
      // The child of BackdropFilter is drawn over the blurred background.
      //
      // If no child is provided, a transparent content is filled in order
      // to semantically indicate to the engine that there is content
      // inside, and thus it should not collapse the backdrop filter area.
      child: widget.child ??
          const ColoredBox(
            color: Colors.transparent,
            child: SizedBox.expand(),
          ),
    );
  }
}
