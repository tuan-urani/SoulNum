import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:soulnum/src/core/failure/auth_error_mapper.dart';
import 'package:soulnum/src/core/repository/session_repository.dart';
import 'package:soulnum/src/locale/locale_key.dart';
import 'package:soulnum/src/ui/widgets/app_screen_scaffold.dart';

import 'package:soulnum/src/utils/app_pages.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        await Get.find<SessionRepository>().ensureSession();
        if (!mounted) return;
        Get.offNamed(AppPages.main);
      } catch (error) {
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
  Widget build(BuildContext context) {
    return AppScreenScaffold(
      title: LocaleKey.appName.tr,
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}
