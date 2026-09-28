import 'dart:typed_data' show Uint8List;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:inspire_blur/src/distribution/blur_distribution.dart';
import 'package:inspire_blur/src/distribution/blur_distribution_image.dart';
import 'package:inspire_blur/src/distribution/maps/directional_distribution_map.dart';
import 'package:inspire_blur/src/distribution/maps/ellipse_distribution_map.dart';
import 'package:inspire_blur/src/distribution/maps/image_mask_distribution_map.dart';
import 'package:inspire_blur/src/distribution/maps/product_distribution_map.dart';
import 'package:inspire_blur/src/distribution/maps/rrect_distribution_map.dart';
import 'package:inspire_blur/src/distribution/maps/uniform_distribution_map.dart';

abstract class BlurDistributionMap {
  const BlurDistributionMap({
    required this.width,
    required this.height,
  });

  final int width;
  final int height;

  Future<BlurDistributionImage> getBlurDistributionImage();
}

abstract class IntensityBasedDistributionMap extends BlurDistributionMap {
  const IntensityBasedDistributionMap({
    required super.width,
    required super.height,
  });

  @override
  Future<BlurDistributionImage> getBlurDistributionImage() async =>
      imageWithPixels(_generatePixels());

  /// mikcb patch (perf): 用调用方给的像素缓冲出图。
  ///
  /// 与 [getBlurDistributionImage] 唯一的区别是像素从外面进来，于是
  /// [BlurDistributionPixelsCache] 里那份可以复用一次生成的结果。图像本身照旧是
  /// **本次新建、由调用方 `owned`** 的 —— 所有权与释放时机与上游逐字一致。
  Future<BlurDistributionImage> imageWithPixels(Uint8List pixels) async =>
      BlurDistributionImage.owned(await _pixelsToImage(pixels));

  Uint8List _generatePixels() {
    const rgba8888BytesPerPixel = 4;

    final pixels = Uint8List(width * height * rgba8888BytesPerPixel);

    int offset = 0;

    final invWidth = width <= 1 ? 0.0 : 1.0 / (width - 1);
    final invHeight = height <= 1 ? 0.0 : 1.0 / (height - 1);

    for (int y = 0; y < height; y++) {
      final v = y * invHeight;

      for (int x = 0; x < width; x++) {
        final u = x * invWidth;

        final intensity = intensityAt(u, v);
        final color = (intensity.clamp(0.0, 1.0) * 255).round();

        pixels[offset++] = color;
        pixels[offset++] = color;
        pixels[offset++] = color;
        pixels[offset++] = 255;
      }
    }

    return pixels;
  }

  Future<ui.Image> _pixelsToImage(Uint8List pixels) async {
    final buffer = await ui.ImmutableBuffer.fromUint8List(pixels);

    final descriptor = ui.ImageDescriptor.raw(
      buffer,
      width: width,
      height: height,
      pixelFormat: ui.PixelFormat.rgba8888,
    );

    final codec = await descriptor.instantiateCodec();
    final frame = await codec.getNextFrame();

    return frame.image;
  }

  double intensityAt(double u, double v);
}

extension BlurDistributionExtension on BlurDistribution {
  /// Creates a corresponding blur distribution map generator
  /// for the given blur distribution type.
  BlurDistributionMap toDistributionMap({required int size}) => switch (this) {
        UniformDistribution _ => UniformDistributionMap(
            width: size,
            height: size,
          ),
        DirectionalDistribution e => DirectionalDistributionMap(
            width: size,
            height: size,
            begin: e.begin,
            end: e.end,
            values: e.values,
            stops: e.stops,
          ),
        EllipseDistribution e => EllipseDistributionMap(
            width: size,
            height: size,
            radiusX: e.radiusX,
            radiusY: e.radiusY,
            center: e.center,
            values: e.values,
            stops: e.stops,
          ),
        RRectDistribution e => RRectDistributionMap(
            width: size,
            height: size,
            horizontalInset: e.horizontalInset,
            verticalInset: e.verticalInset,
            cornerRadius: e.cornerRadius,
            values: e.values,
            stops: e.stops,
          ),
        ImageMaskDistribution e => ImageMaskDistributionMap(
            width: e.maskImage.width,
            height: e.maskImage.height,
            maskImage: e.maskImage,
          ),
        // mikcb patch (2026-09-28): 两个方向渐变的乘积。
        ProductDistribution e => ProductDistributionMap(
            width: size,
            height: size,
            first: DirectionalDistributionMap(
              width: size,
              height: size,
              begin: e.first.begin,
              end: e.first.end,
              values: e.first.values,
              stops: e.first.stops,
            ),
            second: DirectionalDistributionMap(
              width: size,
              height: size,
              begin: e.second.begin,
              end: e.second.end,
              values: e.second.values,
              stops: e.second.stops,
            ),
          ),
      };

  /// mikcb patch (perf): 取分布图，带像素缓存。
  ///
  /// 上游 [BlurDistributionMap.getBlurDistributionImage] 每次调用都重新
  /// `_generatePixels()`：一个 width×height 的双重循环（size 取屏幕长边 × 0.75，
  /// 上限 1024），逐像素求 `intensityAt` 并写满一份 RGBA8888 缓冲。真机实测
  /// （1280×2772 / dpr 2.75 → size 820）这一句是 **674k 次求值 + 2.7MB 分配**，
  /// 而且它跑在第一个 `await` 之前 —— 也就是**同步**占住 UI 线程 36~49ms。
  /// `_InspireBlurWrapperState.didChangeDependencies` 每个新挂载的顶栏都会调一次，
  /// 所以「每进一个子页，首帧都要多花 40 毫秒」。
  ///
  /// 而像素只取决于 (distribution, size)：同一屏上所有顶栏用的是同一份配置。
  /// 这里把它记忆化，首次生成之后按引用复用。
  ///
  /// 非强度型（[ImageMaskDistribution]）不走缓存 —— 它直接光栅化用户给的图，
  /// 没有这个循环。
  Future<BlurDistributionImage> toDistributionImage({required int size}) {
    final map = toDistributionMap(size: size);
    if (map is! IntensityBasedDistributionMap) {
      return map.getBlurDistributionImage();
    }
    return map.imageWithPixels(
      BlurDistributionPixelsCache.pixelsFor(this, size, map._generatePixels),
    );
  }
}

/// mikcb patch (perf): 分布图像素的进程级缓存（见
/// [BlurDistributionExtension.toDistributionImage]）。
///
/// **只缓存像素，不缓存 `ui.Image`。** 图像的所有权与释放时机完全不动：每个消费者
/// 照旧拿到自己 `owned` 的图、照旧自己 `dispose()`。于是逐出缓存永远不会踩到
/// 「图已经被释放、但还有人在采样」这种最难查的问题——缓冲是纯数据，丢弃安全。
///
/// 上游修好后删本类、[IntensityBasedDistributionMap.imageWithPixels] 与
/// [BlurDistributionExtension.toDistributionImage] 即可。
abstract final class BlurDistributionPixelsCache {
  /// 最多留几份。尺寸固定、配置只在用户拖调参滑杆时才变；8 份足够覆盖「几页叠在
  /// 一起 + 刚拖过滑杆」，再多按插入顺序丢最旧的。
  static const int maxEntries = 8;

  static final Map<(BlurDistribution, int), Uint8List> _entries =
      <(BlurDistribution, int), Uint8List>{};

  /// 取 [distribution] 在 [size] 下的像素；未命中时用 [generate] 生成并留下。
  ///
  /// 键用 `(distribution, size)`：分布类型都实现了值相等（如
  /// `DirectionalDistribution` 比对 begin/end/梯度），所以每帧重建的同配置对象
  /// 也能命中同一条。
  static Uint8List pixelsFor(
    BlurDistribution distribution,
    int size,
    Uint8List Function() generate,
  ) {
    final key = (distribution, size);
    final cached = _entries[key];
    if (cached != null) {
      return cached;
    }
    final pixels = generate();
    if (_entries.length >= maxEntries) {
      _entries.remove(_entries.keys.first);
    }
    _entries[key] = pixels;
    return pixels;
  }

  /// 仅测试用：清空缓存。
  @visibleForTesting
  static void clear() => _entries.clear();

  /// 仅测试用：当前条目数。
  @visibleForTesting
  static int get entryCount => _entries.length;
}
