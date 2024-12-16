import 'package:flutter/material.dart';

class CustomLoadingIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 120,
      child: Image.asset(
        'images/buffer.gif',
        fit: BoxFit.cover,
      ),
    );

  }
}



