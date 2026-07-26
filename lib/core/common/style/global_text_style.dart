import 'package:flutter/material.dart';
import '../../constants/app_color.dart';

class AppTextStyle {
  AppTextStyle._();

  static TextStyle getTextStyle({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? letterSpacing,
    double? height,
    TextDecoration? decoration,
  }) {
    return TextStyle(
      fontFamily: 'Inter',
      fontSize: fontSize ?? 14.0,
      fontWeight: fontWeight ?? FontWeight.w400,
      color: color ?? AppColor.primaryFontColor,
      letterSpacing: letterSpacing,
      height: height,
      decoration: decoration,
    );
  }
}
