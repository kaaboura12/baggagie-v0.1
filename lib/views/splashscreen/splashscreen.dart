import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/constants.dart';
import '../../controllers/auth_controller.dart';
import '../../widgets/blurred_background.dart';
import '../../widgets/app_logo.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoAnimationController;
  late AnimationController _textAnimationController;
  late AnimationController _backgroundAnimationController;
  
  late Animation<double> _logoFadeAnimation;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoRotationAnimation;
  late Animation<double> _textFadeAnimation;
  late Animation<double> _textSlideAnimation;
  late Animation<double> _backgroundOpacityAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _navigateToNextScreen();
  }

  void _initializeAnimations() {
    // Logo animations
    _logoAnimationController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );

    _logoFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoAnimationController,
      curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
    ));

    _logoScaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoAnimationController,
      curve: const Interval(0.1, 0.6, curve: Curves.elasticOut),
    ));

    _logoRotationAnimation = Tween<double>(
      begin: -0.1,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _logoAnimationController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOutBack),
    ));

    // Text animations
    _textAnimationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _textFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _textAnimationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
    ));

    _textSlideAnimation = Tween<double>(
      begin: 50.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _textAnimationController,
      curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
    ));

    // Background animation
    _backgroundAnimationController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    _backgroundOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _backgroundAnimationController,
      curve: Curves.easeIn,
    ));

    // Start animations in sequence
    _backgroundAnimationController.forward();
    Future.delayed(const Duration(milliseconds: 500), () {
      _logoAnimationController.forward();
    });
    Future.delayed(const Duration(milliseconds: 1000), () {
      _textAnimationController.forward();
    });
  }

  void _navigateToNextScreen() {
    Future.delayed(const Duration(milliseconds: 4000), () {
      if (mounted) {
        final authController = Provider.of<AuthController>(context, listen: false);
        if (authController.isAuthenticated) {
          Navigator.of(context).pushReplacementNamed('/home');
        } else {
          Navigator.of(context).pushReplacementNamed('/signin');
        }
      }
    });
  }

  @override
  void dispose() {
    _logoAnimationController.dispose();
    _textAnimationController.dispose();
    _backgroundAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;
    final isTablet = screenWidth > 600;
    final isSmallScreen = screenHeight < 600;
    
    // Responsive sizing
    final logoSize = isTablet ? screenWidth * 0.2 : screenWidth * 0.3;
    final titleFontSize = isTablet ? screenWidth * 0.08 : screenWidth * 0.09;
    final subtitleFontSize = isTablet ? screenWidth * 0.04 : screenWidth * 0.045;
    final loadingSize = isTablet ? 50.0 : 40.0;
    final spacing1 = isSmallScreen ? 20.0 : 40.0;
    final spacing2 = isSmallScreen ? 8.0 : 12.0;
    final spacing3 = isSmallScreen ? 40.0 : 80.0;
    
    return Scaffold(
      body: BlurredBackground(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Flexible spacer for top
                        Flexible(
                          flex: isSmallScreen ? 1 : 2,
                          child: Container(),
                        ),
                        
                        // Logo Section with Enhanced Animations
                        AnimatedBuilder(
                          animation: _logoAnimationController,
                          builder: (context, child) {
                            return FadeTransition(
                              opacity: _logoFadeAnimation,
                              child: Transform.scale(
                                scale: _logoScaleAnimation.value,
                                child: Transform.rotate(
                                  angle: _logoRotationAnimation.value,
                                  child: AppLogo(
                                    size: logoSize,
                                    showText: false,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        
                        SizedBox(height: spacing1),
                        
                        // App Name with Slide Animation
                        AnimatedBuilder(
                          animation: _textAnimationController,
                          builder: (context, child) {
                            return FadeTransition(
                              opacity: _textFadeAnimation,
                              child: Transform.translate(
                                offset: Offset(0, _textSlideAnimation.value),
                                child: Text(
                                  AppConstants.appName,
                                  style: TextStyle(
                                    fontFamily: 'Pacifico',
                                    fontSize: titleFontSize,
                                    fontWeight: FontWeight.normal,
                                    color: Colors.white,
                                    letterSpacing: titleFontSize * 0.02,
                                    shadows: [
                                      Shadow(
                                        offset: const Offset(0, 2),
                                        blurRadius: 4,
                                        color: Colors.black.withOpacity(0.3),
                                      ),
                                    ],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            );
                          },
                        ),
                        
                        SizedBox(height: spacing2),
                        
                        // Tagline with Slide Animation
                        AnimatedBuilder(
                          animation: _textAnimationController,
                          builder: (context, child) {
                            return FadeTransition(
                              opacity: _textFadeAnimation,
                              child: Transform.translate(
                                offset: Offset(0, _textSlideAnimation.value),
                                child: Text(
                                  'Your Travel Companion',
                                  style: TextStyle(
                                    fontSize: subtitleFontSize,
                                    color: Colors.white.withOpacity(0.9),
                                    letterSpacing: subtitleFontSize * 0.04,
                                    shadows: [
                                      Shadow(
                                        offset: const Offset(0, 1),
                                        blurRadius: 2,
                                        color: Colors.black.withOpacity(0.2),
                                      ),
                                    ],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            );
                          },
                        ),
                        
                        SizedBox(height: spacing3),
                        
                        // Loading Indicator with Pulse Animation
                        AnimatedBuilder(
                          animation: _textAnimationController,
                          builder: (context, child) {
                            return FadeTransition(
                              opacity: _textFadeAnimation,
                              child: Transform.translate(
                                offset: Offset(0, _textSlideAnimation.value),
                                child: Container(
                                  width: loadingSize,
                                  height: loadingSize,
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white.withOpacity(0.9),
                                    ),
                                    strokeWidth: loadingSize * 0.075,
                                    backgroundColor: Colors.white.withOpacity(0.2),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        
                        // Flexible spacer for bottom
                        Flexible(
                          flex: isSmallScreen ? 1 : 2,
                          child: Container(),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
