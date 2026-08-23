import 'package:inspire_blur/src/distribution/distribution_map.dart';
import 'package:inspire_blur/src/model/progression/progression.dart';

abstract class ProgressingDistributionMap
    extends IntensityBasedDistributionMap {
  ProgressingDistributionMap({
    required super.width,
    required super.height,
    required this.progression,
    required super.strengthFactor,
  });

  final Progression progression;

  double sampleProgression(double t) => progression.samplePoint(t);
}
