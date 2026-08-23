part of 'package:inspire_blur/src/distribution/distribution.dart';

/// A distribution that allows custom fitting inside the widget.
///
/// The default fit for other non-fittable classes is equivalent to `fill`.
mixin FittableDistribution {
  /// Specifies how the distribution is fit inside the widget.
  DistributionFit get distributionFit;
}
