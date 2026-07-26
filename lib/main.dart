import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'app.dart';
import 'core/constants/app_color.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  _configEasyLoading();
  runApp(const MyApp());
}

void _configEasyLoading() {
  EasyLoading.instance
    ..displayDuration = const Duration(milliseconds: 2500)
    ..indicatorType = EasyLoadingIndicatorType.ring
    ..loadingStyle = EasyLoadingStyle.custom
    ..indicatorSize = 35.0
    ..radius = 12.0
    ..backgroundColor = AppColor.cardDark
    ..indicatorColor = AppColor.accentPurpleLight
    ..textColor = AppColor.white
    ..maskColor = Colors.black.withValues(alpha: 0.5)
    ..userInteractions = false
    ..dismissOnTap = false;
}
