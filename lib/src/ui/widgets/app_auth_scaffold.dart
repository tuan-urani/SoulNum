import 'package:flutter/material.dart';
import 'package:soulnum/src/extensions/int_extensions.dart';
import 'package:soulnum/src/utils/app_colors.dart';

class AppAuthScaffold extends StatelessWidget {
  const AppAuthScaffold({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.authBackground,
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            const Positioned(
              top: -44,
              right: -36,
              child: _AuthGlow(size: 170, color: AppColors.authGlowViolet),
            ),
            const Positioned(
              left: -45,
              bottom: -45,
              child: _AuthGlow(size: 180, color: AppColors.authGlowGold),
            ),
            Align(
              child: SingleChildScrollView(
                padding: 24.paddingHorizontal.add(24.paddingVertical),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 390),
                  child: child,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AuthGlow extends StatelessWidget {
  const _AuthGlow({required this.size, required this.color});

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
          BoxShadow(color: color, blurRadius: 42, spreadRadius: 12),
        ],
      ),
    );
  }
}
