import 'package:flutter/material.dart';

class MyCustomScrollBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    return ScrollbarTheme(
      data: ScrollbarThemeData(
        thumbColor: MaterialStateProperty.all(Colors.red), // Set the scroll bar thumb color to blue
      ),
      child: Scrollbar(
        //isAlwaysShown: true, // Add this line to make the scrollbar visible by default
        child: child,
      ),
    );
  }
}