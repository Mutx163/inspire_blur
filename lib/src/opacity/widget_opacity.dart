import 'package:inspire_blur/src/distribution/distribution.dart';

enum WidgetOpacityType {
  solid,
  semiOpaque,
  matchingBlurDistribution,
  customDistribution;

  double shaderType() => switch (this) {
        solid => 0.0,
        semiOpaque => 1.0,
        matchingBlurDistribution => 2.0,
        customDistribution => 3.0,
      };
}

sealed class WidgetOpacity {
  const WidgetOpacity();

  const factory WidgetOpacity.solid() = SolidWidgetOpacity;

  const factory WidgetOpacity.semiOpaque({required double opacity}) =
      SemiOpaqueWidgetOpacity;

  const factory WidgetOpacity.matchingBlurDistribution() =
      MatchingWidgetOpacity;

  const factory WidgetOpacity.customDistribution(
      {required Distribution distribution}) = CustomDistributionWidgetOpacity;

  double get shaderOpacityType;
  double get shaderOpacityValue => 0.0;

  Distribution? get distribution => null;
}

class SolidWidgetOpacity extends WidgetOpacity {
  const SolidWidgetOpacity();

  @override
  double get shaderOpacityType => WidgetOpacityType.solid.shaderType();

  @override
  double get shaderOpacityValue => 1.0;
}

class SemiOpaqueWidgetOpacity extends WidgetOpacity {
  const SemiOpaqueWidgetOpacity({required this.opacity});

  final double opacity;

  @override
  double get shaderOpacityType => WidgetOpacityType.semiOpaque.shaderType();

  @override
  double get shaderOpacityValue => opacity;
}

class MatchingWidgetOpacity extends WidgetOpacity {
  const MatchingWidgetOpacity();

  @override
  double get shaderOpacityType =>
      WidgetOpacityType.matchingBlurDistribution.shaderType();
}

class CustomDistributionWidgetOpacity extends WidgetOpacity {
  const CustomDistributionWidgetOpacity({required this.distribution});

  @override
  final Distribution distribution;

  @override
  double get shaderOpacityType =>
      WidgetOpacityType.customDistribution.shaderType();
}
