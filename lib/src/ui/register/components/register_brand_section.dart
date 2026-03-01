import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:soulnum/src/locale/locale_key.dart';
import 'package:soulnum/src/ui/widgets/app_auth_brand_section.dart';

class RegisterBrandSection extends StatelessWidget {
  const RegisterBrandSection({super.key});

  @override
  Widget build(BuildContext context) {
    return AppAuthBrandSection(
      title: LocaleKey.appName.tr,
      subtitle: LocaleKey.registerBrandTagline.tr,
    );
  }
}
