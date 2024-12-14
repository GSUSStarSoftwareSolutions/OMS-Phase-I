import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'confirmdialog.dart';

void main() => runApp(const MaterialApp(
  debugShowCheckedModeBanner: false,
  home: AdminListScreen(),
));

class ResponsiveAdminLayout extends StatelessWidget {
  final Widget bodyContent;

  const ResponsiveAdminLayout({super.key, required this.bodyContent});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      double maxWidth = constraints.maxWidth;
      double maxHeight = constraints.maxHeight;
      return Stack(
        children: [
          Container(
            color: Colors.white,
            width: maxWidth,
            height: maxHeight * 0.09,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 15, top: 5),
                      child: Image.asset(
                        "images/Final-Ikyam-Logo.png",
                        height: 35.0,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        const SizedBox(width: 10),
                        Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: AccountMenu(),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(
                  height: maxHeight * 0.022,
                ),
                const Divider(
                  height: 3.0,
                  thickness: 3.0,
                  color: Color(0x29000000),
                ),
              ],
            ),
          ),
          if (constraints.maxHeight <= 500) ...{
            SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.only(top: maxHeight * 0.083),
                child: Container(
                  height: maxHeight,
                  width: maxWidth * 0.14,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _buildMenuItems(context, constraints),
                  ),
                ),
              ),
            ),
          } else ...{
            Padding(
              padding: EdgeInsets.only(top: maxHeight * 0.083),
              child: Container(
                height: maxHeight,
                width: maxWidth * 0.14,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _buildMenuItems(context, constraints),
                ),
              ),
            ),
            VerticalDividerWidget1(
              height: maxHeight,
              color: const Color(0x29000000),
            ),
          },
          bodyContent
          // Padding(
          //   padding: EdgeInsets.only(
          //       left: maxWidth * 0.16,
          //       top: maxHeight * 0.16,
          //       right: maxWidth * 0.02,
          //       bottom: maxHeight * 0.01
          //       ),
          //   child: Container(
          //     width: maxWidth,
          //     height: maxHeight,
          //     decoration: BoxDecoration(
          //       color: Colors.white,
          //       border: Border.all(color: const Color(0x29000000)),
          //       borderRadius: BorderRadius.circular(10),
          //       boxShadow: [
          //         BoxShadow(
          //           color: Colors.grey.withOpacity(0.1),
          //           spreadRadius: 3,
          //           blurRadius: 3,
          //           offset: const Offset(0, 3),
          //         ),
          //       ],
          //     ),
          //     child: bodyContent,
          //   ),
          // )
        ],
      );
    });
  }

  List<Widget> _buildMenuItems(BuildContext context, constraints) {
    double maxWidth = constraints.maxWidth;
    return [
      Column(
        children: [
          const SizedBox(
            height: 10,
          ),
          Container(
            padding: const EdgeInsets.all(8.0),
            child: Container(
                width: maxWidth * 0.11,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.blue[800],
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                    bottomLeft: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ),
                ),
                child: _buildMenuItem(
                    context,'Home', Icons.home, Colors.white, '/User_List')),
          ),
        ],
      ),
      const SizedBox(
        height: 6,
      ),
    ];
  }

    Widget _buildMenuItem(
        BuildContext context,String title, IconData icon, Color iconColor, String route) {
      return MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => {},
        onExit: (_) => {},
        child: GestureDetector(
          onTap: () {
            context.go(route);
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 5, right: 20),
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Padding(
              padding: const EdgeInsets.only(left: 10, top: 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Icon(
                    icon,
                    color: iconColor,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    title,
                    style: TextStyle(
                      color: iconColor,
                      fontSize: 15,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
}

class VerticalDividerWidget1 extends StatelessWidget {
  final double height;
  final Color color;

  const VerticalDividerWidget1({
    Key? key,
    this.height = 100,
    this.color = Colors.grey,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      double maxWidth = constraints.maxWidth;
      double maxHeight = constraints.maxHeight;
      return Padding(
        padding: EdgeInsets.only(left: maxWidth * 0.127, top: maxHeight * 0.08),
        child: Container(
          width: 4,
          height: height,
          color: color,
        ),
      );
    });
  }
}



class AdminListScreen extends StatelessWidget {
  const AdminListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveAdminLayout(
      bodyContent: Center(
        child: Text(
          'Admin List Screen Content Goes Here',
          style: TextStyle(fontSize: 18, color: Colors.black),
        ),
      ),
    );
  }
}
