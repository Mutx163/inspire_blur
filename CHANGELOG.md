## 0.5.0

### Added

- **Implicitly animated widgets**
  - Added widgets that automatically animate blur configuration changes: `AnimatedInspireChildBlur` and `AnimatedInspireBackdropBlur`.
  - Animations can be customized using the `duration` and `curve` parameters.
  - Animatable properties: `sigma` (`sigmaX`, `sigmaY`), `blurDistribution`, `transform`, `widgetOpacity`, and `colorAdjustment`.

- **Widget opacity**
  - Added opacity with multiple modes: semi-opaque, matching the blur distribution, or with fully custom distribution.
  - Works with child blur widget.

- **Distribution progressions**
  - Added two types of distribution progression:
    - `GradientProgression`: for regular gradient progressions between start and end points.
    - `CustomProgression`: for advanced non-linear progressions.

- **Combined distributions**
  - Added `CombinedDistribution`, which allows multiple blur distributions to be rendered in a single Inspire Blur widget.
  - Overlapping distributions are blended according to `DistributionBlend` (supports `max`, `sum`, and `screen` blends).
  - Added the `InspireBlurConfig.edges` factory for any blurred edge combination in a single widget. It supports independent sigma values and progressions per edge.
  - Added `strengthFactor` to distributions for scaling their contribution in `CombinedDistribution` (or in general).

- **Aspect-ratio-preserving distributions**
  - Added `square`, `roundedSquare`, and `circle` factories to `InspireBlurConfig`.
  - Added `DistributionFit` enum (`fill`, `inside`) to preserve aspect ratio regardless of the target widget's dimensions.

- **Performance & Shader Optimizations**
  - Enabled linear interpolation of the distribution map in the shader, allowing lower map resolutions while maintaining visual quality.

### Changed

- **Breaking changes**
  - Added `fadeStart` and replaced `extent` with `fadeEnd` in blur directional factories.
  - Renamed `distribution` parameter to `blurDistribution` in `InspireBlurConfig`.
  - Refactored `Distribution` into a generic spatial distribution abstraction applicable to properties beyond blur.
  - `DirectionalDistribution`, `RRectDistribution`, and `EllipseDistribution` now use `progression` instead of `values` and `stops`. Wrap custom control points in a `CustomProgression` to migrate.

- **Color adjustments**
  - Fine-tuned the perceptual scale of color adjustments to produce smoother animations and more consistent results.

- **Dependency cleanup**
  - Removed all underlying dependencies on Flutter's Material and Cupertino libraries. (Thanks @Azzeccagarbugli!)

## 0.4.1

### Fixed

- **Incorrect Y-orientation on Flutter 3.47**
  - Migrated shaders to accommodate the Flutter breaking change where OpenGL ES render-to-texture content is now stored top-down.
  - Backwards compatible with earlier Flutter versions.
  - Applied to both child and backdrop blur.
  - Thanks to @proninyaroslav and others for reporting and investigating this issue!

## 0.4.0

### Added

- **Color adjustments**
  - Added blur area color adjustments: brightness, contrast, exposure, saturation, and vibrance via the new `BlurColorAdjustment` configuration class.
  - Adjustments can be controlled by the `InspireBlurConfig.colorAdjustment` property.
  - Full support implemented for both child and backdrop blur effects.

### Changed

- **Data classes:** Added `lerp()` and other utility methods to configuration data classes to support seamless UI transitions and implicit animations.
- **Documentation:** Optimized docs using templates, improved API wording.

## 0.3.1

### Fixed

- **Backdrop blur positioning**
  - Added automatic screen-position updates for backdrop blur.
  - Fixed backdrop blur misalignment during route transitions, such as Cupertino swipe-back gestures, and when used inside scrollable lists.

## 0.3.0

### Added

- **Custom mask**
  - Added `customMask()` for defining any arbitrary blur distributions using an `Image`.
  - Works with both child and backdrop blur.
- **Blur transformations**
  - Added `BlurTransform` for applying blur distribution transformations, including: scale, offset, rotation, and inversion.
  - Works with both child and backdrop blur.
  - All transformation properties are fully animatable.

### Changed

- **Breaking changes**
  - Replaced `InspireBlurConfig.inverse` with `BlurTransform.inversionFactor`.
  - Inversion is now part of blur distribution transformations. The type has changed from `bool` to `double`, allowing smooth animation and finer control over the inversion amount.

## 0.2.0

### Added

- **Blur shapes:** Added `ellipse()`, `rectangle()`, and `roundedRectangle()` blur distributions.
- **Color tint:** Added the `Inspire.tint` API with factories for applying a gradually fading accent color on top of blur effects.
- **More flexible configuration:** Relaxed constraints on several configuration parameters. For example, `extent` now supports values greater than `1.0`, making it more flexible for advanced use cases such as animations.

### Fixed

- **ImageFilter mode:** Fixed a `nullptr` crash that could occur when using child blur with `InspireBlurMode.imageFilter` in dynamically changing widget trees.
- **Child blur gestures:** Fixed a bug where taps and other gestures were not passed through to widgets wrapped with child blur.

### Changed

- **Breaking change:** Blur distribution parameters are now configured through the `distribution` field of `InspireBlurConfig`, using dedicated `BlurDistribution` subclasses for each type of blur distribution.
- **Package size:** Reduced the published package size from ~15 MB to ~1 MB.
- **Example app:** Merged the example app source files into one `main.dart` file that contains a self-contained and minimal copy-pasteable first use example.
- **Documentation:**
  - Expanded the `README.md` with the new blur shape factories, blur pattern screenshots, a color tint demo, and a "Support the Project" section.
  - Expanded the API documentation and improved the overall structure, formatting, and readability.
- **Unit test coverage:** Expanded test coverage for core utilities, including gradient mask generation.

## 0.1.0

- Initial release
- Centralized `Inspire` API for quick access
- Progressive blur widgets for child and backdrop mode
- GPU-optimized shader program based on a blur-strength gradient map
- Unit and widget tests for improved reliability
- Example app showcasing all available blur types
