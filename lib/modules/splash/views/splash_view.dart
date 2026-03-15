import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:sum_academy/app/theme.dart';
import 'package:sum_academy/modules/splash/controllers/splash_controller.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: SumAcademyTheme.light(),
      child: Builder(
        builder: (context) {
          const isDark = false;
          final headlineColor = SumAcademyTheme.darkBase;
          final subtitleColor = headlineColor.withOpacityFloat(0.7);

          return Scaffold(
            backgroundColor: SumAcademyTheme.white,
            body: SafeArea(
              child: Stack(
                children: [
                  const _AnimatedBackground(),
                  Column(
                    children: [
                      Expanded(
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              FadeTransition(
                                opacity: controller.logoFade,
                                child: SlideTransition(
                                  position: controller.logoSlide,
                                  child: ScaleTransition(
                                    scale: controller.logoScale,
                                    child: _LogoRevealCard(isDark: isDark),
                                  ),
                                ),
                              ),
                              SizedBox(height: 24.h),
                              SlideTransition(
                                position: controller.nameSlide,
                                child: FadeTransition(
                                  opacity: controller.nameFade,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Sum Academy LMS',
                                        textAlign: TextAlign.center,
                                        style: Theme.of(context)
                                            .textTheme
                                            .headlineLarge
                                            ?.copyWith(
                                              color: headlineColor,
                                              fontSize: 32.sp,
                                              letterSpacing: -0.6,
                                            ),
                                      ),
                                      SizedBox(height: 6.h),
                                      Text(
                                        'Premium learning, beautifully delivered.',
                                        textAlign: TextAlign.center,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(color: subtitleColor),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(height: 28.h),
                              FadeTransition(
                                opacity: controller.loaderFade,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    _PremiumLoader(
                                      key: const ValueKey('splash_loader'),
                                      isDark: isDark,
                                    ),
                                    SizedBox(height: 12.h),
                                    Text(
                                      'Preparing your workspace...',
                                      textAlign: TextAlign.center,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: subtitleColor,
                                            letterSpacing: 0.2,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      FadeTransition(
                        opacity: controller.loaderFade,
                        child: Padding(
                          padding: EdgeInsets.only(bottom: 20.h),
                          child: Text(
                            'Developed by Alee \n TryUnity Solutions +92 302 3476605',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.labelMedium
                                ?.copyWith(
                                  color: subtitleColor,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.2,
                                  fontSize: 10.sp,
                                ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _AnimatedBackground extends StatefulWidget {
  const _AnimatedBackground();

  @override
  State<_AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<_AnimatedBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 12000),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final t = _controller.value * 2 * math.pi;
          final dx = math.cos(t) * 0.25;
          final dy = math.sin(t) * 0.2;

          return DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment(-0.8 + dx, -0.6 + dy),
                end: Alignment(0.8 - dx, 0.6 - dy),
                colors: [
                  SumAcademyTheme.brandBluePale.withOpacityFloat(0.35),
                  SumAcademyTheme.white,
                  SumAcademyTheme.brandBlueLight.withOpacityFloat(0.12),
                ],
                stops: const [0.0, 0.52, 1.0],
              ),
            ),
            child: const SizedBox.expand(),
          );
        },
      ),
    );
  }
}

class _LogoRevealCard extends StatefulWidget {
  final bool isDark;

  const _LogoRevealCard({required this.isDark});

  @override
  State<_LogoRevealCard> createState() => _LogoRevealCardState();
}

class _LogoRevealCardState extends State<_LogoRevealCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cardColor = widget.isDark
        ? SumAcademyTheme.darkSurface
        : SumAcademyTheme.white;
    final glassTop = cardColor.withOpacityFloat(widget.isDark ? 0.9 : 0.98);
    final glassBottom = cardColor.withOpacityFloat(widget.isDark ? 0.65 : 0.9);

    return Container(
      width: 200.w,
      height: 200.w,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(44.r)),
      child: Padding(
        padding: EdgeInsets.all(6.r),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(38.r),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [glassTop, glassBottom],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(36.r),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28.r),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final size = constraints.maxWidth;

                    return Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.asset('assets/logo.jpeg', fit: BoxFit.cover),
                        IgnorePointer(
                          child: AnimatedBuilder(
                            animation: _shimmerController,
                            builder: (context, child) {
                              final shimmerX =
                                  (_shimmerController.value * 2 - 1) * size;

                              return Align(
                                alignment: Alignment.center,
                                child: Transform.translate(
                                  offset: Offset(shimmerX, 0),
                                  child: Transform.rotate(
                                    angle: -0.35,
                                    child: Container(
                                      width: size * 0.55,
                                      height: size * 1.6,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.transparent,
                                            SumAcademyTheme.white
                                                .withOpacityFloat(0.5),
                                            Colors.transparent,
                                          ],
                                          stops: const [0.25, 0.5, 0.75],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PremiumLoader extends StatefulWidget {
  final bool isDark;

  const _PremiumLoader({required this.isDark, super.key});

  @override
  State<_PremiumLoader> createState() => _PremiumLoaderState();
}

class _PremiumLoaderState extends State<_PremiumLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double _dotScale(double t, double offset) {
    final value = math.sin((t + offset) * 2 * math.pi);
    return 0.6 + (value + 1) * 0.2;
  }

  double _dotOpacity(double t, double offset) {
    final value = math.sin((t + offset) * 2 * math.pi);
    return 0.4 + (value + 1) * 0.3;
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = SumAcademyTheme.brandBluePale;
    final background = SumAcademyTheme.white.withOpacityFloat(0.96);
    final dotColor = SumAcademyTheme.brandBlue;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = _controller.value;
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(SumAcademyTheme.radiusPill.r),
            border: Border.all(color: borderColor),
            boxShadow: [
              BoxShadow(
                color: SumAcademyTheme.brandBlue.withOpacityFloat(0.08),
                blurRadius: 18.r,
                offset: Offset(0, 8.h),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _Dot(
                scale: _dotScale(t, 0.0),
                opacity: _dotOpacity(t, 0.0),
                color: dotColor,
              ),
              SizedBox(width: 10.w),
              _Dot(
                scale: _dotScale(t, 0.2),
                opacity: _dotOpacity(t, 0.2),
                color: dotColor,
              ),
              SizedBox(width: 10.w),
              _Dot(
                scale: _dotScale(t, 0.4),
                opacity: _dotOpacity(t, 0.4),
                color: dotColor,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Dot extends StatelessWidget {
  final double scale;
  final double opacity;
  final Color color;

  const _Dot({required this.scale, required this.opacity, required this.color});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: Transform.scale(
        scale: scale,
        child: Container(
          width: 10.r,
          height: 10.r,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
      ),
    );
  }
}
