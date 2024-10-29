import 'package:flutter/material.dart';

class CustomDatafound extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      height: 300,
      child: Image.asset(
        'images/nodata.png', // Replace with your GIF path
        fit: BoxFit.cover,
      ),
    );
  }
}



