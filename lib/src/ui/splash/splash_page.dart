import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:soulnum/src/core/failure/auth_error_mapper.dart';
import 'package:soulnum/src/core/repository/session_repository.dart';
import 'package:soulnum/src/extensions/int_extensions.dart';
import 'package:soulnum/src/locale/locale_key.dart';
import 'package:soulnum/src/ui/widgets/app_circular_progress.dart';
import 'package:soulnum/src/utils/app_colors.dart';

import 'package:soulnum/src/utils/app_pages.dart';
import 'package:soulnum/src/utils/app_styles.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  static const int _minimumSplashMs = 3000;
  late final AnimationController _ambientController;
  late final Animation<double> _pulse;
  late final Animation<double> _rotation;

  @override
  void initState() {
    super.initState();
    _ambientController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
    _pulse = CurvedAnimation(
      parent: _ambientController,
      curve: Curves.easeInOutSine,
    );
    _rotation = Tween<double>(begin: 0, end: 2 * math.pi).animate(
      CurvedAnimation(parent: _ambientController, curve: Curves.linear),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final Stopwatch splashTimer = Stopwatch()..start();
      try {
        await Get.find<SessionRepository>().ensureSession();
        final int remainingMs =
            _minimumSplashMs - splashTimer.elapsedMilliseconds;
        if (remainingMs > 0) {
          await Future<void>.delayed(Duration(milliseconds: remainingMs));
        }
        if (!mounted) return;
        Get.offNamed(AppPages.main);
      } catch (error) {
        final int remainingMs =
            _minimumSplashMs - splashTimer.elapsedMilliseconds;
        if (remainingMs > 0) {
          await Future<void>.delayed(Duration(milliseconds: remainingMs));
        }
        if (!mounted) return;
        Get.offNamed(
          AppPages.login,
          arguments: <String, dynamic>{
            'message': AuthErrorMapper.toLoginMessage(error),
          },
        );
      }
    });
  }

  @override
  void dispose() {
    _ambientController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.authBackground,
      body: SizedBox.expand(
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: <Color>[
                    AppColors.authBackground,
                    AppColors.authBackgroundSurface,
                    AppColors.black,
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.topRight,
              child: Transform.translate(
                offset: const Offset(40, -70),
                child: _SplashGlow(
                  size: 220,
                  color: AppColors.authAccentViolet.withValues(alpha: 0.22),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomLeft,
              child: Transform.translate(
                offset: const Offset(-60, 80),
                child: _SplashGlow(
                  size: 180,
                  color: AppColors.authAccentGold.withValues(alpha: 0.14),
                ),
              ),
            ),
            SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 460),
                  child: Padding(
                    padding: 24.paddingHorizontal,
                    child: Column(
                      children: <Widget>[
                        const Spacer(),
                        AnimatedBuilder(
                          animation: _ambientController,
                          builder: (BuildContext context, Widget? child) {
                            final double scale = 0.96 + (_pulse.value * 0.08);
                            return Transform.scale(
                              scale: scale,
                              child: _NumerologyCore(rotation: _rotation.value),
                            );
                          },
                        ),
                        28.height,
                        Text(
                          LocaleKey.appName.tr,
                          style: AppStyles.h1(
                            color: AppColors.authText,
                            fontWeight: FontWeight.w700,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        10.height,
                        Text(
                          LocaleKey.splashLoading.tr,
                          style: AppStyles.bodyMedium(
                            color: AppColors.authTextMuted,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.authPanel.withValues(alpha: 0.95),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: AppColors.authBorder.withValues(
                                alpha: 0.7,
                              ),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              const AppCircularProgress(
                                color: AppColors.authAccentGold,
                                size: 18,
                              ),
                              10.width,
                              Text(
                                LocaleKey.commonLoading.tr,
                                style: AppStyles.bodySmall(
                                  color: AppColors.authTextMuted,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        24.height,
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SplashGlow extends StatelessWidget {
  const _SplashGlow({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: <BoxShadow>[
          BoxShadow(color: color, blurRadius: 70, spreadRadius: 10),
        ],
      ),
    );
  }
}

class _NumerologyCore extends StatelessWidget {
  const _NumerologyCore({required this.rotation});

  final double rotation;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 228,
      height: 228,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Container(
            width: 228,
            height: 228,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: <Color>[
                  AppColors.authBackgroundSurface.withValues(alpha: 0.92),
                  AppColors.authBackground.withValues(alpha: 0.84),
                ],
              ),
              border: Border.all(
                color: AppColors.authAccentGold.withValues(alpha: 0.32),
              ),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: AppColors.authGlowViolet.withValues(alpha: 0.5),
                  blurRadius: 42,
                  spreadRadius: 8,
                ),
              ],
            ),
          ),
          Transform.rotate(
            angle: rotation,
            child: SizedBox(
              width: 198,
              height: 198,
              child: Stack(
                children: List<Widget>.generate(9, (int index) {
                  final double angle = (2 * math.pi / 9) * index;
                  final double radius = 90;
                  final double dx = (99 + radius * math.cos(angle)) - 4;
                  final double dy = (99 + radius * math.sin(angle)) - 4;
                  return Positioned(
                    left: dx,
                    top: dy,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: AppColors.authAccentGold.withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
          Container(
            width: 136,
            height: 136,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.authAccentViolet.withValues(alpha: 0.48),
                width: 1.6,
              ),
              gradient: RadialGradient(
                colors: <Color>[
                  AppColors.authInputBackground,
                  AppColors.authBackground,
                ],
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  '9',
                  style: AppStyles.headlineLarge(
                    color: AppColors.authAccentGold,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '3 • 6 • 9',
                  style: AppStyles.bodySmall(
                    color: AppColors.authTextMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
