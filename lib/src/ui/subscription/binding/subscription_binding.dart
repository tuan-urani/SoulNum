import 'package:get/get.dart';
import 'package:soulnum/src/core/repository/subscription_repository.dart';
import 'package:soulnum/src/ui/subscription/interactor/subscription_cubit.dart';

class SubscriptionBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<SubscriptionCubit>()) {
      Get.lazyPut<SubscriptionCubit>(
        () => SubscriptionCubit(Get.find<SubscriptionRepository>()),
      );
    }
  }
}

