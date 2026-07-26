import 'package:get/get.dart';
import '../core/binding/controller_binder.dart';
import '../features/revenue_cat_test/screen/revenue_cat_test_screen.dart';

class AppRoutes {
  AppRoutes._();

  static const String revenueCatTestScreen = '/revenue_cat_test';

  static final List<GetPage> routes = [
    GetPage(
      name: revenueCatTestScreen,
      page: () => const RevenueCatTestScreen(),
      binding: ControllerBinder(),
    ),
  ];
}
