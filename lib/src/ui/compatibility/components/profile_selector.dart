import 'package:flutter/material.dart';
import 'package:soulnum/src/core/model/user_profile_model.dart';
import 'package:soulnum/src/utils/app_colors.dart';
import 'package:soulnum/src/utils/app_styles.dart';

class ProfileSelector extends StatelessWidget {
  const ProfileSelector({
    super.key,
    required this.label,
    required this.value,
    required this.profiles,
    required this.onChanged,
  });

  final String label;
  final String? value;
  final List<UserProfileModel> profiles;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      key: ValueKey<String?>(value),
      initialValue: value,
      dropdownColor: const Color(0xFF17172A),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppStyles.bodySmall(color: AppColors.colorFBFC9DE),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.colorF586AA6.withValues(alpha: 0.3)),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.primary),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      items: profiles
          .map(
            (UserProfileModel profile) => DropdownMenuItem<String>(
              value: profile.id,
              child: Text(
                profile.fullName,
                style: AppStyles.bodyMedium(color: AppColors.white),
              ),
            ),
          )
          .toList(),
      onChanged: onChanged,
    );
  }
}
