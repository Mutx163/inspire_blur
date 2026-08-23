import 'dart:ui';

/// The [FilterQuality] type to pass to [FragmentShader.setImageSampler] that
/// enables interpolated sampling between pixels of the distribution.
///
/// It prevents banding effect that would normally occur with the default
/// [FilterQuality.none] sampling. It also allows to reduce the size of
/// distribution maps, keeping similar quality. Using smaller maps
/// improves shader performance.
const kShaderMapSamplingQuality = FilterQuality.low;
