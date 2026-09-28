part of 'package:inspire_blur/src/distribution/blur_distribution.dart';

/// Blur intensity = the **product** of two directional gradients.
///
/// ## Why (mikcb patch 2026-09-28)
///
/// Every upstream distribution describes a *single* shape: uniform over the whole
/// area, or one gradient along one direction, or an ellipse, or a rounded rect
/// (which is, by construction, a function of the distance to *one* boundary).
/// None of them can express "full strength along one axis while fading out along
/// the other" — the shape needed by the bottom-sheet top band, which must be at
/// full strength on the panel's top edge (so content scrolling under it
/// dissolves) yet fall to zero across the panel's two top corners (so the
/// panel's own edge light keeps reading the corners as rounded).
///
/// Before this patch that combination was only reachable by *nudging parameters*:
/// either the corners got a flat plate, or the top edge went transparent. Both
/// were rejected on a real device.
///
/// ## Semantics
///
/// `intensity(u, v) = first(u, v) * second(u, v)`, each factor sampled by the
/// normal directional rules. The result is clamped to `[0.0, 1.0]` when the
/// distribution map is baked, so a factor pair that overshoots cannot brighten
/// anything above full blur.
///
/// This is a pure *shape* description: `sigma` still lives on
/// [InspireBlurConfig] and multiplies the sampled factor in the shader, exactly
/// as for every other distribution.
final class ProductDistribution extends BlurDistribution {
  /// The first factor. Conventionally the axis that carries the full strength
  /// (e.g. top-to-bottom for a top edge).
  final DirectionalDistribution first;

  /// The second factor. Conventionally the axis the band tapers along.
  final DirectionalDistribution second;

  /// Creates a product of two directional gradients.
  const ProductDistribution({
    required this.first,
    required this.second,
  });

  /// Returns a copy of this distribution with the provided properties updated.
  ///
  /// Any parameter left `null` retains its current value.
  @override
  ProductDistribution copyWith({
    DirectionalDistribution? first,
    DirectionalDistribution? second,
  }) {
    return ProductDistribution(
      first: first ?? this.first,
      second: second ?? this.second,
    );
  }

  /// Linearly interpolates between two [ProductDistribution] objects.
  ///
  /// Enables seamless transitions inside implicit animations or tweens.
  static ProductDistribution? lerp(
    ProductDistribution? a,
    ProductDistribution? b,
    double t,
  ) {
    if (identical(a, b)) return a;
    if (a == null) return b;
    if (b == null) return a;

    return ProductDistribution(
      first: DirectionalDistribution.lerp(a.first, b.first, t)!,
      second: DirectionalDistribution.lerp(a.second, b.second, t)!,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ProductDistribution &&
        other.first == first &&
        other.second == second;
  }

  @override
  int get hashCode => Object.hash(first, second);

  @override
  String toString() => 'ProductDistribution('
      'first: $first, '
      'second: $second'
      ')';
}
