import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
class Card extends StatefulWidget {
  const Card({super.key});

  @override
  State<Card> createState() => _CardState();
}

class _CardState extends State<Card> {
  int itemCount = 0;
  @override
  Widget build(BuildContext context) {
    return  Align(
      alignment: Alignment.topLeft,
      child: Stack(
        clipBehavior: Clip.none, // This ensures the badge can be positioned outside the icon bounds
        children: [
          IconButton(
            icon:  Icon(Icons.shopping_cart),
            onPressed: () {
              context.go('/Customer_Draft_List');
              // Handle notification icon press
            },
          ),
          Positioned(
            right: 0,
            top: -5, // Adjust this value to move the text field
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.red, // Background color of the badge
                shape: BoxShape.circle,
              ),
              child:  Text(
                '${itemCount}', // The text field value (like a badge count)
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12, // Adjust the font size as needed
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
