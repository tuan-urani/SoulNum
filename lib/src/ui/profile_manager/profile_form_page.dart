import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:soulnum/src/core/model/request/profile_upsert_request.dart';
import 'package:soulnum/src/extensions/int_extensions.dart';
import 'package:soulnum/src/locale/locale_key.dart';
import 'package:soulnum/src/ui/profile_manager/interactor/profile_manager_cubit.dart';
import 'package:soulnum/src/ui/profile_manager/interactor/profile_manager_state.dart';
import 'package:soulnum/src/ui/widgets/app_button.dart';
import 'package:soulnum/src/ui/widgets/app_input.dart';
import 'package:soulnum/src/ui/widgets/app_screen_scaffold.dart';
import 'package:soulnum/src/ui/widgets/due_date_picker.dart';
import 'package:soulnum/src/utils/app_colors.dart';
import 'package:soulnum/src/utils/app_pages.dart';
import 'package:soulnum/src/utils/app_styles.dart';

class ProfileFormPage extends StatefulWidget {
  const ProfileFormPage({super.key});

  @override
  State<ProfileFormPage> createState() => _ProfileFormPageState();
}

class _ProfileFormPageState extends State<ProfileFormPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();
  final TextEditingController _relationController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _birthDateController.dispose();
    _relationController.dispose();
    super.dispose();
  }

  Future<void> _pickBirthDate() async {
    FocusScope.of(context).unfocus();
    final DateTime now = DateTime.now();
    final DateTime initialDate =
        DateTime.tryParse(_birthDateController.text.trim()) ??
        DateTime(now.year - 20, now.month, now.day);

    await showCupertinoDatePickerBottomSheet(
      initialDateTime: initialDate,
      minimumDate: DateTime(1900, 1, 1),
      maximumDate: now,
      onDateTimeChanged: (DateTime pickedDate) {
        _birthDateController.text = _formatDate(pickedDate);
      },
    );
  }

  String _formatDate(DateTime value) {
    final String month = value.month.toString().padLeft(2, '0');
    final String day = value.day.toString().padLeft(2, '0');
    return '${value.year}-$month-$day';
  }

  Future<void> _submit(ProfileManagerCubit cubit) async {
    final Map<String, dynamic> args =
        (Get.arguments as Map?)?.cast<String, dynamic>() ?? <String, dynamic>{};
    final bool forceSelectActive = args['force_select_active'] == true;

    final String fullName = _nameController.text.trim();
    final String birthRaw = _birthDateController.text.trim();
    final DateTime? birthDate = DateTime.tryParse(birthRaw);
    if (fullName.isEmpty || birthDate == null) {
      Get.snackbar(
        LocaleKey.error.tr,
        LocaleKey.formRequiredError.tr,
        backgroundColor: AppColors.error,
        colorText: AppColors.white,
      );
      return;
    }

    try {
      await cubit.createProfile(
        ProfileUpsertRequest(
          fullName: fullName,
          birthDate: birthDate,
          relationLabel: _relationController.text.trim().isEmpty
              ? null
              : _relationController.text.trim(),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      final String message =
          cubit.state.errorMessage ?? LocaleKey.commonError.tr;
      Get.snackbar(
        LocaleKey.error.tr,
        message,
        backgroundColor: AppColors.error,
        colorText: AppColors.white,
      );
      return;
    }
    if (cubit.state.errorMessage != null) {
      if (!mounted) return;
      Get.snackbar(
        LocaleKey.error.tr,
        cubit.state.errorMessage!,
        backgroundColor: AppColors.error,
        colorText: AppColors.white,
      );
      return;
    }
    if (!mounted) return;
    if (forceSelectActive) {
      Get.offAllNamed(AppPages.main);
      return;
    }
    Get.back<void>();
  }

  @override
  Widget build(BuildContext context) {
    final ProfileManagerCubit cubit = Get.find<ProfileManagerCubit>();
    return BlocProvider<ProfileManagerCubit>.value(
      value: cubit,
      child: BlocBuilder<ProfileManagerCubit, ProfileManagerState>(
        builder: (BuildContext context, ProfileManagerState state) {
          return AppScreenScaffold(
            title: LocaleKey.profileCreateTitle.tr,
            child: ListView(
              children: <Widget>[
                Text(
                  LocaleKey.profileCreateTitle.tr,
                  style: AppStyles.h5(color: AppColors.white),
                ),
                16.height,
                AppInput(
                  label: LocaleKey.profileFullNameLabel.tr,
                  controller: _nameController,
                  isRequired: true,
                ),
                12.height,
                AppInput(
                  label: LocaleKey.profileBirthDateLabel.tr,
                  controller: _birthDateController,
                  hint: '1995-08-12',
                  isRequired: true,
                  isDisabledTyping: true,
                  onPressed: _pickBirthDate,
                  suffixIcon: const Icon(
                    CupertinoIcons.calendar,
                    color: AppColors.authAccentGold,
                    size: 20,
                  ),
                ),
                // 12.height,
                // AppInput(
                //   label: LocaleKey.profileRelationLabel.tr,
                //   controller: _relationController,
                // ),
                20.height,
                AppButton(
                  label: LocaleKey.commonSave.tr,
                  isLoading: state.isSubmitting,
                  onPressed: () => _submit(cubit),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
