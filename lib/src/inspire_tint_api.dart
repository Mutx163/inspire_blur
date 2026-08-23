import 'package:flutter/widgets.dart';
import 'package:inspire_blur/src/inspire_tint.dart';
import 'package:inspire_blur/src/model/progression/progression.dart';

/// API for the Inspire color tint widgets.
///
/// Contains convenience factories that cover all typical tint directions,
/// as well as the custom [directional] tint builder.
final class InspireTintApi {
  /// Creates an instance of Inspire Tint API.
  const InspireTintApi();

  /// Creates a tint that starts from [begin] and fades toward [end].
  ///
  /// {@template inspire_tint_api.common}
  /// [fadeStart] defines where the tint effect starts.
  ///
  /// [fadeEnd] defines where the tint effect starts.
  ///
  /// Typical values are in the range `[0.0, 1.0]`, although larger values
  /// are also supported.
  ///
  /// [curve] defines how the tint intensity transitions across the gradient.
  ///
  /// [Curves.easeOutCubic] is the default [curve], as in most cases it produces
  /// a visually smoother and more natural-looking effect than [Curves.linear].
  /// {@endtemplate}
  Widget directional({
    required Color color,
    required Alignment begin,
    required Alignment end,
    double opacity = 1.0,
    double fadeStart = 0.0,
    double fadeEnd = 1.0,
    Curve curve = Curves.easeOutCubic,
    Widget? child,
  }) {
    return InspireTint(
      color: color,
      opacity: opacity,
      begin: begin,
      end: end,
      progression: GradientProgression(
        start: fadeStart,
        end: fadeEnd,
        curve: curve,
      ),
      child: child,
    );
  }

  /// Creates a tint that starts from the top and fades toward the bottom.
  ///
  /// {@macro inspire_tint_api.common}
  Widget topToBottom({
    required Color color,
    double opacity = 1.0,
    double fadeStart = 0.0,
    double fadeEnd = 1.0,
    Curve curve = Curves.easeOutCubic,
    Widget? child,
  }) {
    return directional(
      color: color,
      opacity: opacity,
      fadeStart: fadeStart,
      fadeEnd: fadeEnd,
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      curve: curve,
      child: child,
    );
  }

  /// Creates a tint that starts from the bottom and fades toward the top.
  ///
  /// {@macro inspire_tint_api.common}
  Widget bottomToTop({
    required Color color,
    double opacity = 1.0,
    double fadeStart = 0.0,
    double fadeEnd = 1.0,
    Curve curve = Curves.easeOutCubic,
    Widget? child,
  }) {
    return directional(
      color: color,
      opacity: opacity,
      fadeStart: fadeStart,
      fadeEnd: fadeEnd,
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
      curve: curve,
      child: child,
    );
  }

  /// Creates a tint that starts from the left and fades toward the right.
  ///
  /// {@macro inspire_tint_api.common}
  Widget leftToRight({
    required Color color,
    double opacity = 1.0,
    double fadeStart = 0.0,
    double fadeEnd = 1.0,
    Curve curve = Curves.easeOutCubic,
    Widget? child,
  }) {
    return directional(
      color: color,
      opacity: opacity,
      fadeStart: fadeStart,
      fadeEnd: fadeEnd,
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      curve: curve,
      child: child,
    );
  }

  /// Creates a tint that starts from the right and fades toward the left.
  ///
  /// {@macro inspire_tint_api.common}
  Widget rightToLeft({
    required Color color,
    double opacity = 1.0,
    double fadeStart = 0.0,
    double fadeEnd = 1.0,
    Curve curve = Curves.easeOutCubic,
    Widget? child,
  }) {
    return directional(
      color: color,
      opacity: opacity,
      fadeStart: fadeStart,
      fadeEnd: fadeEnd,
      begin: Alignment.centerRight,
      end: Alignment.centerLeft,
      curve: curve,
      child: child,
    );
  }
}
