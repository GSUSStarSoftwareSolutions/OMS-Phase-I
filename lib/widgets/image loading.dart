import 'package:flutter/material.dart';

class ImageLoadingIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      height: 100,
      child: Image.asset(
        'images/loadind.gif',
        fit: BoxFit.cover,
      ),
    );

  }
}