import 'package:flutter/widgets.dart';

class Responsive {

  static double getWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  static double getHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  static bool isMobile(BuildContext context) {
    double width = getWidth(context);
    return width <= 600;
  }

  static bool isTablet(BuildContext context) {
    double width = getWidth(context);
    return width > 600 && width <= 1204;
  }

  static bool isDesktop(BuildContext context) {
    double width = getWidth(context);
    return width > 1200;
  }

  static double scaleWidth(BuildContext context) {
    double width = getWidth(context);

    if (isMobile(context)) {
      return width * 0.85;
    } else if (isTablet(context)) {
      return 1200;
    }else if (isDesktop(context)) {
      return width * 0.85;
    } else {
      return width * 0.75;
    }
  }

  static double scaleHeight(BuildContext context) {
    double height = getHeight(context);

    if (isMobile(context)) {
      return height * 0.7;
    } else if (isTablet(context)) {
      return height * 0.75;
    } else {
      return height * 0.8;
    }
  }
}
