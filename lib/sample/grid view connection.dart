import 'package:flutter/material.dart';

class CustomGridView extends StatelessWidget {
  final int crossAxisCount;
  final double childAspectRatio;

  const CustomGridView({
    super.key,
    this.crossAxisCount = 4,
    this.childAspectRatio = 1,
  });

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: childAspectRatio,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: 20, // Dummy item count
      itemBuilder: (context, index) {
        return Container(
          color: Colors.blueAccent,
          child: Center(
            child: Text(
              'Item $index',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        );
      },
    );
  }
}
