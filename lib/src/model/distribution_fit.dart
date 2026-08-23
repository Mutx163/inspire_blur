/// Method for fitting a distribution inside a widget bounds.
enum DistributionFit {
  /// Stretches out the distribution to fill out the widget area.
  ///
  /// **It does not preserve aspect ratio.**
  /// For example a rectangle will be stretched horizontally inside
  /// a wider widget.
  fill,

  /// Fits the distribution inside the widget keeping aspect ratio.
  ///
  /// **It maintains 1:1 aspect ratio.**
  /// It is useful for `square` and `circle` shapes. The distribution
  /// is centered inside the widget.
  inside,
}
