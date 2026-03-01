import 'package:get/get.dart';
import 'package:soulnum/src/core/repository/session_repository.dart';
import 'package:soulnum/src/ui/register/interactor/register_cubit.dart';

class RegisterBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<RegisterCubit>()) {
      Get.lazyPut<RegisterCubit>(
        () => RegisterCubit(Get.find<SessionRepository>()),
      );
    }
  }
}
