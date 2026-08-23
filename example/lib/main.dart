import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:inspire_blur/inspire_blur.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Optional: Warm up to ensure no shader loading stutter on first draw.
  await Inspire.warmUp();

  // Set edge-to-edge mode for a transparent status bar.
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  runApp(const _ExampleApp());
}

class _ExampleApp extends StatelessWidget {
  const _ExampleApp();

  @override
  Widget build(BuildContext context) {
    return WidgetsApp(
      title: 'Inspire Blur Demo',
      color: _colorWhite,
      debugShowCheckedModeBanner: false,
      pageRouteBuilder: <T>(settings, builder) => PageRouteBuilder<T>(
        settings: settings,
        pageBuilder: (context, _, __) => builder(context),
      ),
      home: const AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: _DemoScreen(),
      ),
    );
  }
}

class _DemoScreen extends StatefulWidget {
  const _DemoScreen();

  @override
  State<_DemoScreen> createState() => _DemoScreenState();
}

class _DemoScreenState extends State<_DemoScreen> {
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: _colorGrey50,
      child: Column(
        children: [
          Expanded(
            child: IndexedStack(
              index: _currentPage,
              children: const [
                _BackdropBlurDemo(key: PageStorageKey('backdrop_blur')),
                _ChildBlurDemo(key: PageStorageKey('child_blur')),
              ],
            ),
          ),
          _BottomNavigation(
            currentPage: _currentPage,
            onPageChange: (newPage) => setState(() => _currentPage = newPage),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// SCREEN 1: Backdrop Blur
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

class _BackdropBlurDemo extends StatelessWidget {
  const _BackdropBlurDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const Positioned.fill(child: _BackdropBlurDemoContent()),

        // Backdrop blur effect that blurs the content behind it.
        //
        // To apply a top fading blur, backdrop blur does not need to fill
        // the entire stack. For efficiency, blur effect should be positioned
        // only where it is actually rendered.
        Positioned(
          left: 0,
          right: 0,
          top: 0,
          height: 132,
          child: Inspire.backdropBlur(
            config: InspireBlurConfig.topToBottom(sigma: 34),
          ),
        ),
      ],
    );
  }
}

/// List with image cards for the backdrop blur example.
class _BackdropBlurDemoContent extends StatelessWidget {
  const _BackdropBlurDemoContent();

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);
    final screenPadding = MediaQuery.paddingOf(context);
    final isLandscape = screenSize.width > screenSize.height;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
            horizontal: 34,
            vertical: isLandscape ? 55 : 89,
          ) +
          EdgeInsets.only(
            left: screenPadding.left,
            right: screenPadding.right,
            bottom: isLandscape ? 0 : screenSize.height * 0.618,
          ),
      child: Column(
        children: _demoImages
            .map((image) => _buildImage(imagePath: image.url))
            .toList(),
      ),
    );
  }

  Widget _buildImage({required String imagePath}) {
    const double radius = 44;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 44),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF000000).withValues(alpha: 0.125),
              blurRadius: 44,
              offset: const Offset(5, 34),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: AspectRatio(
            aspectRatio: 1.4,
            child: _DemoImage(imagePath: imagePath),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// SCREEN 2: Child Blur
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

class _ChildBlurDemo extends StatelessWidget {
  const _ChildBlurDemo({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);
    final screenPadding = MediaQuery.paddingOf(context);
    final isLandscape = screenSize.width > screenSize.height;

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 21,
        mainAxisSpacing: 44,
        childAspectRatio: isLandscape ? 1.5 : 0.65,
      ),
      padding: EdgeInsets.only(
            left: 21,
            right: 21,
            top: isLandscape ? 44 : 112,
          ) +
          EdgeInsets.only(
            left: screenPadding.left,
            right: screenPadding.right,
            bottom: screenSize.height * 0.618,
          ),
      itemCount: _demoImages.length,
      itemBuilder: (context, index) {
        final image = _demoImages[index];

        return _ChildBlurDemoCard(
          key: ValueKey(image.url),
          imagePath: image.url,
          tintColor: image.tint,
          title: image.title,
          subtitle: image.subtitle,
        );
      },
    );
  }
}

/// Image card demonstrating child blur.
class _ChildBlurDemoCard extends StatelessWidget {
  const _ChildBlurDemoCard({
    super.key,
    required this.imagePath,
    required this.tintColor,
    required this.title,
    required this.subtitle,
  });

  final String imagePath;
  final Color tintColor;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    const double radius = 21;

    return _ClickableContainer(
      builder: (animationValue) => Transform.scale(
        scale: 1.0 + animationValue * 0.05,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            boxShadow: [
              BoxShadow(
                color: _colorBlack.withValues(alpha: 0.175),
                blurRadius: 21,
                offset: const Offset(5, 13),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(radius),
            child: Stack(
              children: [
                Positioned.fill(
                  child: _buildBackgroundImage(animationValue: animationValue),
                ),

                // Additional tint to make the fade look more pronounced
                Positioned.fill(
                  child: Inspire.tint.bottomToTop(
                    color: tintColor,
                    opacity: 0.5,
                    fadeEnd: 0.5,
                    curve: Curves.easeOut,
                  ),
                ),

                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 13,
                  child: _buildTextContent(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackgroundImage({required double animationValue}) {
    // Child blur effect that wraps inside the content to be blurred
    return Inspire.childBlur(
      config: InspireBlurConfig.bottomToTop(
        sigma: 55,
        fadeEnd: 0.5,
        fadeCurve: Curves.easeInOutQuad,
      ),

      // Widget to be blurred (transform applied as an extra visual effect)
      child: Transform.scale(
        scale: 1.0 + animationValue * 0.4,
        alignment: Alignment.topCenter,
        child: _DemoImage(imagePath: imagePath),
      ),
    );
  }

  Widget _buildTextContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: _colorWhite,
            shadows: [
              Shadow(
                color: _colorBlack.withValues(alpha: 0.25),
                blurRadius: 55,
                offset: const Offset(0, 5),
              ),
            ],
          ),
        ),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: _colorWhite,
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// DEMO IMAGES
//
// Not needed for InspireBlur to work. Intended for demo only.
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

const _demoImages = [
  _DemoImageModel(
    'https://raw.githubusercontent.com/inspirestack/inspire_blur/main/assets/example/images/watermelon.jpg',
    Color.fromARGB(255, 189, 189, 189),
    'Watermelon',
    'Citrullus lanatus',
  ),
  _DemoImageModel(
    'https://raw.githubusercontent.com/inspirestack/inspire_blur/main/assets/example/images/cosmos-flowers.jpg',
    Color.fromARGB(255, 202, 244, 134),
    'Cosmos Flowers',
    'Found at allotments · Wrocław, PL',
  ),
  _DemoImageModel(
    'https://raw.githubusercontent.com/inspirestack/inspire_blur/main/assets/example/images/head-of-david.jpg',
    Color.fromARGB(255, 224, 224, 224),
    'Head of David',
    'Marble sculpture',
  ),
  _DemoImageModel(
    'https://raw.githubusercontent.com/inspirestack/inspire_blur/main/assets/example/images/london-plane-tree.jpg',
    Color.fromARGB(255, 128, 207, 241),
    'London Plane Tree',
    'Found in Park Grabiszyński · Wrocław, PL',
  ),
  _DemoImageModel(
    'https://raw.githubusercontent.com/inspirestack/inspire_blur/main/assets/example/images/hibiscus.jpg',
    Color.fromARGB(255, 134, 205, 237),
    'Hibiscus syriacus',
    'Rose of Sharon',
  ),
  _DemoImageModel(
    'https://raw.githubusercontent.com/inspirestack/inspire_blur/main/assets/example/images/monkey-puzzle-tree.jpg',
    Color.fromARGB(255, 191, 246, 149),
    'Monkey Puzzle Tree',
    'Observed at Kew Gardens · London, UK',
  ),
];

class _DemoImageModel {
  final String url;
  final Color tint;
  final String title;
  final String subtitle;

  const _DemoImageModel(this.url, this.tint, this.title, this.subtitle);
}

class _DemoImage extends StatelessWidget {
  const _DemoImage({required this.imagePath});

  final String imagePath;

  @override
  Widget build(BuildContext context) {
    return Image.network(
      imagePath,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => const ColoredBox(
        color: _colorGrey50,
        child: Center(
          child: Text(
            'Image unavailable',
            textAlign: TextAlign.center,
            style: TextStyle(color: _colorBlack),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// DEMO UTILITIES
//
// Not needed for InspireBlur to work. Intended for demo only.
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

class _BottomNavigation extends StatelessWidget {
  const _BottomNavigation({
    required this.currentPage,
    required this.onPageChange,
  });

  final int currentPage;
  final Function(int) onPageChange;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: _colorWhite,
      child: SafeArea(
        bottom: true,
        top: false,
        child: Row(
          children: [
            Expanded(
              child: _NavButton(
                title: 'Backdrop blur',
                isSelected: currentPage == 0,
                onPressed: () => onPageChange(0),
              ),
            ),
            Expanded(
              child: _NavButton(
                title: 'Child blur',
                isSelected: currentPage == 1,
                onPressed: () => onPageChange(1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.title,
    required this.isSelected,
    required this.onPressed,
  });

  final String title;
  final bool isSelected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: 68,
        color: _colorWhite,
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(21),
              color: isSelected
                  ? const Color.fromARGB(255, 235, 248, 255)
                  : _colorTransparent,
            ),
            child: Text(
              title,
              style: TextStyle(
                color: isSelected
                    ? const Color.fromARGB(255, 20, 160, 255)
                    : const Color.fromARGB(255, 105, 195, 255),
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ClickableContainer extends StatefulWidget {
  const _ClickableContainer({required this.builder});

  final Widget Function(double) builder;

  @override
  State<_ClickableContainer> createState() => _ClickableContainerState();
}

class _ClickableContainerState extends State<_ClickableContainer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOutSine,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanDown: (_) => _startAnimation(),
      onPanEnd: (_) => _endAnimation(),
      onPanCancel: () => _endAnimation(),
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) => widget.builder(_animation.value),
      ),
    );
  }

  void _startAnimation() => _controller.forward();
  void _endAnimation() => _controller.reverse();
}

const _colorTransparent = Color(0x00000000);
const _colorBlack = Color(0xFF000000);
const _colorWhite = Color(0xFFFFFFFF);
const _colorGrey50 = Color(0xFFFAFAFA);
