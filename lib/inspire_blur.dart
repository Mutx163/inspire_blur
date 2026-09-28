/// Inspire Blur provides high-performance progressive and variable blur
/// effects for Flutter.
///
/// The package includes:
/// * Child blur and backdrop blur widgets
/// * Directional and shape-based blur distributions
/// * Tint effects
/// * GPU shader-powered rendering optimized for Impeller
///
/// Designed for building modern, visually rich Flutter interfaces.
library;

export 'src/color_adjustment/blur_color_adjustment.dart'
    show BlurColorAdjustment;
export 'src/distribution/blur_distribution.dart';
// mikcb patch (perf): 分布图像素缓存。**导出它是为了给仓库侧的守卫测试一个稳定
// 入口** —— 一旦把 `dependency_overrides` 里的 inspire_blur 换回 pub.dev，这个
// 名字就不存在，`test/architecture/inspire_blur_patch_test.dart` 会直接编译失败
// （比读 pubspec 字符串更能挡住「悄悄回退」）。上游修好后连同补丁一起删。
//
// 2026-09-28 追加：把 [BlurDistributionExtension] / [BlurDistributionMap] 一并导出，
// 同一个理由 —— 形状补丁（ProductDistribution）的守卫测试要经
// `toDistributionMap()` 把分布烤成强度图、逐点断言「两个方向相乘」。只放缓存类的话
// 那个测试就得 import `package:inspire_blur/src/...`，撞 `implementation_imports`。
export 'src/distribution/blur_distribution_map.dart'
    show
        BlurDistributionExtension,
        BlurDistributionMap,
        BlurDistributionPixelsCache;
export 'src/inspire_backdrop_blur.dart' show InspireBackdropBlur;
export 'src/inspire_blur.dart' show Inspire;
export 'src/inspire_blur_config.dart' show InspireBlurConfig;
export 'src/inspire_blur_mode.dart' show InspireBlurMode;
export 'src/inspire_child_blur.dart' show InspireChildBlur;
export 'src/inspire_tint_api.dart' show InspireTintApi;
export 'src/model/blur_scale.dart' show BlurScale;
export 'src/transform/blur_transform.dart' show BlurTransform;
