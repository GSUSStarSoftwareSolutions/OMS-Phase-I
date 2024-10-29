import 'package:flutter/material.dart';

class CustomLoadingIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      height: 300,
      child: Image.asset(
        'images/buffer.gif', // Replace with your GIF path
        fit: BoxFit.cover,
      ),
    );

  }
}