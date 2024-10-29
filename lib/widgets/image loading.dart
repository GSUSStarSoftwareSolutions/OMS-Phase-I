import 'package:flutter/material.dart';

class ImageLoadingIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      child: Image.asset(
        'images/loadind.gif', // Replace with your GIF path
        fit: BoxFit.cover,
      ),
    );

  }
}