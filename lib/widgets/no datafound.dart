import 'package:flutter/material.dart';

class CustomDatafound extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      height: 300,
      child: Image.asset(
        'images/nodata.png',
        fit: BoxFit.cover,
      ),
    );
  }
}



