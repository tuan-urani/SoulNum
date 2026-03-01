import 'package:get/get.dart';
import 'package:soulnum/src/core/repository/history_repository.dart';
import 'package:soulnum/src/ui/history/interactor/history_cubit.dart';

class HistoryBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<HistoryCubit>()) {
      Get.lazyPut<HistoryCubit>(
        () => HistoryCubit(Get.find<HistoryRepository>()),
      );
    }
  }
}

