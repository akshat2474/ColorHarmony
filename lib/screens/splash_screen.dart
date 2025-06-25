import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _colorController;
  late AnimationController _scaleController;
  late AnimationController _rotationController;
  
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _colorAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    
    _colorController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 4000),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    _colorAnimation = TweenSequence<Color?>(
      [
        TweenSequenceItem(
          weight: 1.0,
          tween: ColorTween(begin: Colors.purple, end: Colors.blue),
        ),
        TweenSequenceItem(
          weight: 1.0,
          tween: ColorTween(begin: Colors.blue, end: Colors.green),
        ),
        TweenSequenceItem(
          weight: 1.0,
          tween: ColorTween(begin: Colors.green, end: Colors.orange),
        ),
        TweenSequenceItem(
          weight: 1.0,
          tween: ColorTween(begin: Colors.orange, end: Colors.red),
        ),
      ],
    ).animate(_colorController);

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.linear,
    ));

    _startAnimations();
  }

  void _startAnimations() async {
    _colorController.repeat();
    _rotationController.repeat();
    
    await Future.delayed(const Duration(milliseconds: 500));
    _scaleController.forward();
    
    await Future.delayed(const Duration(milliseconds: 3000));
    _navigateToHome();
  }

  void _navigateToHome() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const HomeScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 1000),
      ),
    );
  }

  @override
  void dispose() {
    _colorController.dispose();
    _scaleController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF667eea),
              Color(0xFF764ba2),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated Color Wheel
              AnimatedBuilder(
                animation: Listenable.merge([
                  _scaleAnimation, 
                  _colorAnimation, 
                  _rotationAnimation
                ]),
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Transform.rotate(
                      angle: _rotationAnimation.value * 3.14159,
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: SweepGradient(
                            colors: [
                              _colorAnimation.value ?? Colors.purple,
                              Colors.blue,
                              Colors.green,
                              Colors.yellow,
                              Colors.orange,
                              Colors.red,
                              _colorAnimation.value ?? Colors.purple,
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: (_colorAnimation.value ?? Colors.purple)
                                  .withOpacity(0.5),
                              blurRadius: 30,
                              spreadRadius: 10,
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.palette,
                            size: 60,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 40),
              
              // Animated Title
              AnimatedTextKit(
                animatedTexts: [
                  TypewriterAnimatedText(
                    'Color Harmony',
                    textStyle: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    speed: const Duration(milliseconds: 100),
                  ),
                ],
                totalRepeatCount: 1,
              ),
              
              const SizedBox(height: 10),
              
              const Text(
                'Create Beautiful Color Palettes',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
              
              const SizedBox(height: 80),
              
              // Loading indicator
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
