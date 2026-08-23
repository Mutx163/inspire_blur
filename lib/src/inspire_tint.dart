import 'package:flutter/widgets.dart';
import 'package:inspire_blur/src/model/progression/progression.dart';

class InspireTint extends StatelessWidget {
  final Color color;
  final double opacity;
  final Alignment begin;
  final Alignment end;
  final Progression progression;
  final int stopsCount;
  final Widget? child;

  const InspireTint({
    super.key,
    required this.color,
    required this.opacity,
    required this.begin,
    required this.end,
    required this.progression,
    required this.child,
    this.stopsCount = 16,
  }) : assert(stopsCount >= 2, 'stopsCount must be greater than or equal to 2');

  @override
  Widget build(BuildContext context) {
    if (opacity <= 0.0) return child ?? const SizedBox.shrink();

    final opacityControlPoints = List.generate(
      stopsCount,
      (i) {
        final stop = i / (stopsCount - 1);
        return (progression.samplePoint(stop), stop);
      },
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: begin,
          end: end,
          colors: opacityControlPoints
              .map((e) => color.withValues(alpha: e.$1 * opacity))
              .toList(),
          stops: opacityControlPoints.map((e) => e.$2).toList(),
        ),
      ),
      child: child,
    );
  }
}
