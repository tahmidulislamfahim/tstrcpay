import 'package:get/get.dart';
import '../../features/revenue_cat_test/controller/revenue_cat_controller.dart';

class ControllerBinder extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RevenueCatController>(() => RevenueCatController(), fenix: true);
  }
}
