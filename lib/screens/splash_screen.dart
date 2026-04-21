import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';
import '../widgets/sakura_particle.dart';
import 'calendar_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _particleCtrl;

  @override
  void initState() {
    super.initState();
    _particleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _particleCtrl.dispose();
    super.dispose();
  }

  void _navigate() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        pageBuilder: (_, __, ___) => const CalendarScreen(),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 700),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _navigate,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Stack(
          children: [
            // Sakura particles
            AnimatedBuilder(
              animation: _particleCtrl,
              builder: (context, _) => CustomPaint(
                painter:
                    SakuraParticlePainter(_particleCtrl.value),
                size: MediaQuery.of(context).size,
              ),
            ),

            // Center content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  Text(
                    'MEMO',
                    style: TextStyle(
                      fontFamily: 'serif',
                      fontSize: 64,
                      fontWeight: FontWeight.w300,
                      color: AppColors.gold,
                      letterSpacing: 20,
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 1200.ms)
                      .slideY(
                          begin: 0.25,
                          end: 0,
                          curve: Curves.easeOutCubic,
                          duration: 1000.ms),

                  const SizedBox(height: 8),

                  Text(
                    'K a l e i d o s c o p e',
                    style: TextStyle(
                      fontSize: 13,
                      color:
                          AppColors.primary.withValues(alpha: 0.55),
                      letterSpacing: 5,
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 500.ms, duration: 900.ms),

                  const SizedBox(height: 80),

                  // Tap hint — subtle pulse
                  _TapHint()
                      .animate()
                      .fadeIn(delay: 1800.ms, duration: 600.ms),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TapHint extends StatefulWidget {
  @override
  State<_TapHint> createState() => _TapHintState();
}

class _TapHintState extends State<_TapHint>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _opacity = Tween<double>(begin: 0.3, end: 0.9).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _opacity,
      builder: (_, __) => Opacity(
        opacity: _opacity.value,
        child: const Text(
          'tap to begin',
          style: TextStyle(
            fontSize: 11,
            color: AppColors.textMuted,
            letterSpacing: 4,
          ),
        ),
      ),
    );
  }
}
