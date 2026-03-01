import 'package:get/get.dart';
import 'package:soulnum/src/core/repository/session_repository.dart';
import 'package:soulnum/src/ui/login/interactor/login_cubit.dart';

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<LoginCubit>()) {
      Get.lazyPut<LoginCubit>(
        () => LoginCubit(Get.find<SessionRepository>()),
      );
    }
  }
}

