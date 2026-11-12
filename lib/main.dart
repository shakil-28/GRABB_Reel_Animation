import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MyApp());
}

/// Root widget of the application
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Grabb Reel Animation',
      theme: ThemeData.dark(),
      home: const GoldenNuggetReelAnimation(),
    );
  }
}

/// Facebook Reels Animation Screen showcasing Grabb product boxes
class GoldenNuggetReelAnimation extends StatefulWidget {
  const GoldenNuggetReelAnimation({super.key});

  @override
  State<GoldenNuggetReelAnimation> createState() =>
      _GoldenNuggetReelAnimationState();
}

class _GoldenNuggetReelAnimationState extends State<GoldenNuggetReelAnimation>
    with SingleTickerProviderStateMixin {
  // Animation controller and timeline animations
  late final AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _textFadeAnimation;

  // Controls infinite looping of product showcase
  final bool _isLooping = true;
  int _product = 0;

  // List of product box images cycled during the animation
  final List<String> _productImages = [
    'assets/Golden Nugget Box v4.png',
    'assets/Grabb Box v4.png',
    'assets/Sausage Overload Box v4.png',
  ];

  // List of corresponding product titles
  final List<String> _productTitles = [
    'GOLDEN\nNUGGET BOX',
    'GRABB BOX',
    'SAUSAGE\nOVERLOAD BOX',
  ];

  @override
  void initState() {
    super.initState();

    // Total duration for one full product cycle (3.5 seconds)
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3500),
    );

    _initAnimations();

    // On animation completion, cycle to the next product and replay if looping is enabled
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && _isLooping) {
        setState(() {
          _product = (_product + 1) % _productImages.length;
        });
        _controller.forward(from: 0.0);
      }
    });

    // Start the animation
    _controller.forward();
  }

  /// Initializes or updates animation sequences (safe for Hot Reload via reassemble)
  void _initAnimations() {
    // Timeline Slide Sequence:
    // 0% - 35%: Slide in from off-screen Right (2.5, 0.0) to Center (0.0, 0.0) with easeOutCubic
    // 35% - 65%: Hold/Pause in Center (0.0, 0.0) for ~1.05s
    // 65% - 100%: Slide out from Center (0.0, 0.0) to off-screen Left (-2.5, 0.0) with easeInCubic
    _slideAnimation = TweenSequence<Offset>([
      TweenSequenceItem(
        tween: Tween<Offset>(
          begin: const Offset(2.5, 0.0),
          end: Offset.zero,
        ).chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 35.0,
      ),
      TweenSequenceItem(
        tween: ConstantTween<Offset>(Offset.zero),
        weight: 30.0,
      ),
      TweenSequenceItem(
        tween: Tween<Offset>(
          begin: Offset.zero,
          end: const Offset(-2.5, 0.0),
        ).chain(CurveTween(curve: Curves.easeInCubic)),
        weight: 35.0,
      ),
    ]).animate(_controller);

    // Synchronized Fade In / Fade Out Sequence for product title text:
    // 0% - 35%: Fade in from 0.0 -> 1.0 opacity as bowl slides in
    // 35% - 65%: Hold 1.0 opacity while bowl pauses in center
    // 65% - 100%: Fade out from 1.0 -> 0.0 opacity as bowl slides out
    _textFadeAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 35.0,
      ),
      TweenSequenceItem(
        tween: ConstantTween<double>(1.0),
        weight: 30.0,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 35.0,
      ),
    ]).animate(_controller);
  }

  @override
  void reassemble() {
    super.reassemble();
    // Ensures newly added animations are safely initialized during Hot Reload
    _initAnimations();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: AspectRatio(
            aspectRatio: 9 / 16, // Framed in 9:16 aspect ratio for Facebook Reels
            child: Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                color: Colors.black,
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // 1. Background image with 4 clipped rounded corners
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      'assets/Background v2.png',
                      fit: BoxFit.cover,
                    ),
                  ),

                  // GRABB LOGO on top-right corner
                  Positioned(
                    top: 7,
                    right: 7,
                    child: Image.asset(
                      'assets/GRABB_logo.png',
                      height: 100,
                    )
                  ),

                  // 2. Dynamic product title text with synchronized fade in/out behind bowl
                  _productNameAnimation(),

                  // 3. Animated sliding bowl/box image (Top layer)
                  _buildAnimatedBowl(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Positioned _productNameAnimation() {
    return Positioned(
                  bottom: 400,
                  left: 20,
                  right: 20,
                  child: FadeTransition(
                    opacity: _textFadeAnimation,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Outer dark brown text stroke border
                            Text(
                              _productTitles[_product],
                              textAlign: TextAlign.center,
                              style: GoogleFonts.ranchers(
                                fontSize: 58,
                                height: 0.98, // Ensures proper line spacing for \n multi-line titles
                                fontWeight: FontWeight.w700,
                                foreground: Paint()
                                  ..style = PaintingStyle.stroke
                                  ..strokeWidth = 14
                                  ..strokeJoin = StrokeJoin.round
                                  ..strokeCap = StrokeCap.round
                                  ..color = const Color(0xff4a160c),
                              ),
                            ),

                            // Inner cream-colored text fill
                            Text(
                              _productTitles[_product],
                              textAlign: TextAlign.center,
                              style: GoogleFonts.ranchers(
                                fontSize: 58,
                                height: 0.98, // Ensures proper line spacing for \n multi-line titles
                                fontWeight: FontWeight.w700,
                                color: const Color(0xfffbdeba),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
  }

  /// Builds the animated sliding bowl with dynamic motion rotation
  Widget _buildAnimatedBowl() {
    return Positioned(
      bottom: 210,
      left: 0,
      right: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30.0),
        child: SlideTransition(
          position: _slideAnimation,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final double x = _slideAnimation.value.dx;

              // Applies a subtle physical tilt/rotation to the bowl during movement
              final double bowlRotation = x > 0
                  ? (x / 2.5) * 0.025
                  : (x / 2.5) * 0.035;

              return Transform.rotate(
                angle: bowlRotation,
                child: Image.asset(
                  _productImages[_product],
                  fit: BoxFit.contain,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}