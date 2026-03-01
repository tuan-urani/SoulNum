import 'package:flutter/material.dart';
import 'package:soulnum/src/extensions/int_extensions.dart';
import 'package:soulnum/src/utils/app_colors.dart';
import 'package:soulnum/src/utils/app_dimensions.dart';
import 'package:soulnum/src/utils/app_styles.dart';

class AppScreenScaffold extends StatelessWidget {
  const AppScreenScaffold({
    super.key,
    required this.title,
    required this.child,
    this.actions = const <Widget>[],
    this.bottomNavigationBar,
  });

  final String title;
  final Widget child;
  final List<Widget> actions;
  final Widget? bottomNavigationBar;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        backgroundColor: AppColors.black,
        title: Text(
          title,
          style: AppStyles.h5(color: AppColors.white),
        ),
        actions: actions,
      ),
      body: SafeArea(
        child: Container(
          padding: AppDimensions.sideMargins.add(12.paddingVertical),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[
                Color(0xFF0F1020),
                Color(0xFF0A0A14),
              ],
            ),
          ),
          child: child,
        ),
      ),
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}

