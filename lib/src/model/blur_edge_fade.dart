import 'dart:math';

import 'package:inspire_blur/src/model/progression/progression.dart';

class BlurEdgeFade {
  final double? sigma;
  final double? sigmaX;
  final double? sigmaY;
  final Progression progression;

  const BlurEdgeFade({
    this.sigma,
    this.sigmaX,
    this.sigmaY,
    required this.progression,
  });

  double maxSigma() => max(sigma ?? 0.0, max(sigmaX ?? 0.0, sigmaY ?? 0.0));

  static double? effectiveMaxSigma(Iterable<BlurEdgeFade> edges) =>
      edges.isEmpty
          ? null
          : edges.fold(
              edges.first.sigma,
              (previousValue, element) {
                final curr = element.sigma;
                final prev = previousValue;
                return curr == null || prev == null ? null : max(curr, prev);
              },
            );

  static double? effectiveMaxSigmaX(Iterable<BlurEdgeFade> edges) =>
      edges.isEmpty
          ? null
          : edges.fold(
              edges.first.sigmaX,
              (previousValue, element) {
                final curr = element.sigmaX;
                final prev = previousValue;
                return curr == null || prev == null ? null : max(curr, prev);
              },
            );

  static double? effectiveMaxSigmaY(Iterable<BlurEdgeFade> edges) =>
      edges.isEmpty
          ? null
          : edges.fold(
              edges.first.sigmaY,
              (previousValue, element) {
                final curr = element.sigmaY;
                final prev = previousValue;
                return curr == null || prev == null ? null : max(curr, prev);
              },
            );
}
