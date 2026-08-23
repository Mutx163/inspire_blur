import 'dart:typed_data';
import 'dart:ui' as ui;

class ImageMaskGenerator {
  Future<ui.Image> generateImage({
    required int width,
    required int height,
    required double strengthFactor,
    required double Function(double, double) intensityAt,
  }) =>
      _pixelsToImage(
        _generatePixels(width, height, strengthFactor, intensityAt),
        width,
        height,
      );

  Future<ui.Image> _pixelsToImage(
    Uint8List pixels,
    int width,
    int height,
  ) async {
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

  Uint8List _generatePixels(
    int width,
    int height,
    double strengthFactor,
    double Function(double, double) intensityAt,
  ) {
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
        final color = (intensity.clamp(0.0, 1.0) * strengthFactor * 255.0)
            .round()
            .clamp(0, 255);

        pixels[offset++] = color;
        pixels[offset++] = color;
        pixels[offset++] = color;
        pixels[offset++] = 255;
      }
    }

    return pixels;
  }
}

class EmptyImageMaskGenerator {
  Future<ui.Image> generateImage() => ImageMaskGenerator().generateImage(
      width: 1, height: 1, strengthFactor: 1.0, intensityAt: (_, __) => 1.0);
}
