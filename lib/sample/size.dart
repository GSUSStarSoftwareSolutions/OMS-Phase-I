import 'package:flutter/material.dart';

class Responsive extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget desktop;
  final Widget? fourK; // Adding a fourK widget for larger screens

  const Responsive({
    Key? key,
    required this.mobile,
    this.tablet,
    required this.desktop,
    this.fourK, // Optional fourK widget
  }) : super(key: key);

  // Custom breakpoints based on your design
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 1020; // Custom mobile breakpoint

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1020 &&
          MediaQuery.of(context).size.width < 1280; // Custom tablet breakpoint

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1280 ; // Custom desktop breakpoint

  // static bool isFourK(BuildContext context) =>
  //     MediaQuery.of(context).size.width >= 2560; // Custom 4K breakpoint

  @override
  Widget build(BuildContext context) {
    final Size _size = MediaQuery.of(context).size;
    // If our width is more than 1100 then we consider it a desktop
    if (_size.width >= 1280) {
      return desktop;
    }
    // If width it less then 1100 and more then 850 we consider it as tablet
    else if (_size.width >= 1020 && tablet != null) {
      return tablet!;
    }
    // Or less then that we called it mobile
    else {
      return mobile;
    }
  }
}
