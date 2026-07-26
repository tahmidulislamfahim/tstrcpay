import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'core/binding/controller_binder.dart';
import 'core/constants/app_color.dart';
import 'routes/app_routes.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'RevenueCat Tester',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColor.bgDark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColor.accentPurple,
          brightness: Brightness.dark,
        ),
      ),
      initialBinding: ControllerBinder(),
      initialRoute: AppRoutes.revenueCatTestScreen,
      getPages: AppRoutes.routes,
      builder: EasyLoading.init(),
    );
  }
}
