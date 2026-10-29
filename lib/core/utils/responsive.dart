import 'package:flutter/material.dart';

class Breakpoints {
  const Breakpoints._();

  static const double mobile = 700;
  static const double desktop = 1040;

  static double width(BuildContext context) => MediaQuery.sizeOf(context).width;

  static bool isMobile(BuildContext context) => width(context) < mobile;

  static bool isDesktop(BuildContext context) => width(context) >= desktop;

  static bool isTablet(BuildContext context) =>
      width(context) >= mobile && width(context) < desktop;

  static double pagePadding(BuildContext context) {
    final w = width(context);
    if (w < 480) return 20;
    if (w < mobile) return 24;
    if (w < desktop) return 36;
    return 52;
  }

  static double sectionSpacing(BuildContext context) {
    return isMobile(context) ? 44 : 72;
  }

  static int gridColumns(BuildContext context) {
    final w = width(context);
    if (w < 620) return 1;
    if (w < 980) return 2;
    if (w < 1320) return 3;
    return 4;
  }
}
