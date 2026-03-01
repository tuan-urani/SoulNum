import 'package:get/get.dart';
import 'package:soulnum/src/core/repository/profile_repository.dart';
import 'package:soulnum/src/core/repository/reading_repository.dart';
import 'package:soulnum/src/core/repository/session_repository.dart';
import 'package:soulnum/src/ui/reading_detail/interactor/reading_detail_cubit.dart';

class ReadingDetailBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ReadingDetailCubit>()) {
      Get.lazyPut<ReadingDetailCubit>(
        () => ReadingDetailCubit(
          Get.find<ReadingRepository>(),
          Get.find<ProfileRepository>(),
          Get.find<SessionRepository>(),
        ),
      );
    }
  }
}
