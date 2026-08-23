import 'package:flutter/widgets.dart';
import 'package:inspire_blur/src/distribution/distribution_image.dart';
import 'package:inspire_blur/src/distribution/distribution_map_holder.dart';
import 'package:inspire_blur/src/inspire_blur_config.dart';
import 'package:inspire_blur/src/model/inspire_blur_widget_type.dart';
import 'package:inspire_blur/src/utils/layout/inspire_bounds_observer.dart';

enum DistributionMapType { blur, opacity }

class InspireBlurWrapperData {
  final DistributionImage? blurDistributionImage;
  final DistributionImage? opacityDistributionImage;
  final Rect? globalBounds;

  const InspireBlurWrapperData({
    required this.blurDistributionImage,
    required this.opacityDistributionImage,
    required this.globalBounds,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is InspireBlurWrapperData &&
        other.blurDistributionImage == blurDistributionImage &&
        other.opacityDistributionImage == opacityDistributionImage &&
        other.globalBounds == globalBounds;
  }

  @override
  int get hashCode => Object.hash(
        blurDistributionImage,
        opacityDistributionImage,
        globalBounds,
      );

  @override
  String toString() => 'InspireBlurWrapperData('
      'blurDistributionImage: $blurDistributionImage, '
      'opacityDistributionImage: $opacityDistributionImage, '
      'globalBounds: $globalBounds'
      ')';
}

typedef InspireBlurWrapperBuilder = Widget Function(
    BuildContext, InspireBlurWrapperData);

class InspireBlurWrapper extends StatefulWidget {
  final InspireBlurConfig config;
  final InspireBlurWidgetType widgetType;
  final InspireBlurWrapperBuilder builder;
  final Object? layoutInvalidationKey;

  const InspireBlurWrapper({
    super.key,
    required this.config,
    required this.widgetType,
    required this.builder,
    required this.layoutInvalidationKey,
  });

  @override
  State<InspireBlurWrapper> createState() => _InspireBlurWrapperState();
}

class _InspireBlurWrapperState extends State<InspireBlurWrapper> {
  final _distributionMapHolders =
      <DistributionMapType, DistributionMapHolder>{};

  @override
  void initState() {
    super.initState();

    _distributionMapHolders.putIfAbsent(
      DistributionMapType.blur,
      () => DistributionMapHolder(),
    );

    if (widget.widgetType == InspireBlurWidgetType.child) {
      _distributionMapHolders.putIfAbsent(
        DistributionMapType.opacity,
        () => DistributionMapHolder(),
      );
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _distributionMapHolders[DistributionMapType.blur]?.didChangeDependencies(
      context: context,
      distribution: widget.config.blurDistribution,
    );

    _distributionMapHolders[DistributionMapType.opacity]?.didChangeDependencies(
      context: context,
      distribution: widget.config.widgetOpacity.distribution,
    );
  }

  @override
  void didUpdateWidget(covariant InspireBlurWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.config.blurDistribution != widget.config.blurDistribution) {
      _distributionMapHolders[DistributionMapType.blur]?.regenerateIfNeeded(
        distribution: widget.config.blurDistribution,
        invalidate: true,
      );
    }

    if (oldWidget.config.widgetOpacity.distribution !=
        widget.config.widgetOpacity.distribution) {
      _distributionMapHolders[DistributionMapType.opacity]?.regenerateIfNeeded(
        distribution: widget.config.widgetOpacity.distribution,
        invalidate: true,
      );
    }
  }

  @override
  void dispose() {
    for (final holder in _distributionMapHolders.values) {
      holder.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InspireBoundsObserver(
      layoutInvalidationKey: widget.layoutInvalidationKey,
      builder: (context, boundsNotifier) => ValueListenableBuilder(
        valueListenable: boundsNotifier,
        builder: (context, globalBounds, child) => ListenableBuilder(
          listenable: Listenable.merge(
            _distributionMapHolders.values
                .map(((holder) => holder.distributionImage)),
          ),
          builder: (context, child) => widget.builder(
            context,
            InspireBlurWrapperData(
              blurDistributionImage:
                  _distributionMapHolders[DistributionMapType.blur]
                      ?.distributionImage
                      .value,
              opacityDistributionImage:
                  _distributionMapHolders[DistributionMapType.opacity]
                      ?.distributionImage
                      .value,
              globalBounds: globalBounds,
            ),
          ),
        ),
      ),
    );
  }
}
