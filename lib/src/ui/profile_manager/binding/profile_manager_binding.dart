import 'package:get/get.dart';
import 'package:soulnum/src/core/repository/profile_deletion_repository.dart';
import 'package:soulnum/src/core/repository/profile_repository.dart';
import 'package:soulnum/src/ui/profile_manager/interactor/profile_manager_cubit.dart';

class ProfileManagerBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ProfileManagerCubit>()) {
      Get.lazyPut<ProfileManagerCubit>(
        () => ProfileManagerCubit(
          Get.find<ProfileRepository>(),
          Get.find<ProfileDeletionRepository>(),
        ),
      );
    }
  }
}

