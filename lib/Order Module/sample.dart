// import 'package:flutter/material.dart';
//
// void main() {
//   runApp(MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         body: Center(
//           child: Stack(
//             alignment: Alignment.center,
//             children: [
//               // Half Circle
//               CustomPaint(
//                 size: Size(200, 100), // Adjust size
//                 painter: HalfCirclePainter(),
//               ),
//               // Dot
//               Positioned(
//                 top: 40, // Adjust position
//                 left: 150, // Adjust position
//                 child: Container(
//                   width: 20, // Adjust size
//                   height: 20,
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     color: Colors.grey, // Adjust dot color
//                   ),
//                 ),
//               ),
//               // Logo
//               // Positioned(
//               //   top: 10, // Adjust position
//               //   child: Image.asset(
//               //     'assets/logo.png', // Replace with your logo asset
//               //     width: 100, // Adjust size
//               //   ),
//               // ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// // Custom Painter for Half Circle
// class HalfCirclePainter extends CustomPainter {
//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..color = Colors.lightBlueAccent // Adjust color
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = 20; // Adjust width
//
//     final rect = Rect.fromLTWH(0, 0, size.width, size.height * 2);
//     final startAngle = -3.14; // Start at the left
//     final sweepAngle = 3.14; // Half circle
//     final useCenter = false;
//
//     canvas.drawArc(rect, startAngle, sweepAngle, useCenter, paint);
//   }
//
//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) {
//     return false;
//   }
// }
//full circle
// import 'package:flutter/material.dart';
//
// void main() {
//   runApp(MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         body: Padding(
//           padding: EdgeInsets.only(left: 1200,top: 200),
//           child: Stack(
//             alignment: Alignment.center,
//             children: [
//               // Outer Circle
//               Container(
//                 width: 300, // Adjust size
//                 height: 300,
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   border: Border.all(
//                     color: Colors.blue[100]!, // Adjust the color
//                     width: 2, // Adjust border width
//                   ),
//                 ),
//               ),
//               // Inner Circle
//               Container(
//                 width: 250, // Adjust size
//                 height: 250,
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   color: Colors.transparent, // Adjust color if needed
//                   border: Border.all(
//                     color: Colors.lightBlueAccent.withOpacity(0.5), // Adjust the color and opacity
//                     width: 30, // Adjust border width
//                   ),
//                 ),
//               ),
//               // Dot
//               Positioned(
//                 top: 60, // Adjust position
//                 left: 15, // Adjust position
//                 child: Container(
//                   width: 20, // Adjust size
//                   height: 20,
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     color: Colors.grey, // Adjust dot color
//                   ),
//                 ),
//               ),
//               // Logo
//               // Positioned(
//               //   top: 20, // Adjust position
//               //   child: Image.asset(
//               //     'assets/logo.png', // Replace with your logo asset
//               //     width: 100, // Adjust size
//               //   ),
//               // ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

//falf
// import 'package:flutter/material.dart';
//
// void main() {
//   runApp(MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         body: Padding(
//           padding: EdgeInsets.only(left: 1200, top: 200),
//           child: Stack(
//             alignment: Alignment.center,
//             children: [
//               // Outer Circle (Half)
//               ClipPath(
//                 clipper: HalfCircleClipper(), // Use custom clipper for half circle
//                 child: Container(
//                   width: 300, // Adjust size
//                   height: 300,
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     border: Border.all(
//                       color: Colors.blue[100]!, // Adjust the color
//                       width: 2, // Adjust border width
//                     ),
//                   ),
//                 ),
//               ),
//               // Inner Circle (Half)
//               ClipPath(
//                 clipper: HalfCircleClipper(), // Use custom clipper for half circle
//                 child: Container(
//                   width: 250, // Adjust size
//                   height: 250,
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     color: Colors.transparent, // Adjust color if needed
//                     border: Border.all(
//                       color: Colors.lightBlueAccent.withOpacity(0.5), // Adjust the color and opacity
//                       width: 30, // Adjust border width
//                     ),
//                   ),
//                 ),
//               ),
//               // Dot
//               Positioned(
//                 top: 60, // Adjust position
//                 left: 15, // Adjust position
//                 child: Container(
//                   width: 20, // Adjust size
//                   height: 20,
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     color: Colors.grey, // Adjust dot color
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// // Custom clipper for half-circle
// class HalfCircleClipper extends CustomClipper<Path> {
//   @override
//   Path getClip(Size size) {
//     Path path = Path();
//     path.addArc(Rect.fromLTWH(0, 0, size.width, size.height), 3.14, 3.14); // Add arc to create half circle
//     return path;
//   }
//
//   @override
//   bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
//     return false; // No need to reclip since the shape is constant
//   }
// }




// correct code
// import 'package:flutter/material.dart';
//
// void main() {
//   runApp(MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         body: Padding(
//           padding: EdgeInsets.only(left: 1200, top: 200,right: 50),
//           child: Stack(
//             alignment: Alignment.center,
//             children: [
//               // Outer Circle (Half) with Right Side Visible
//               ClipPath(
//                 clipper: LeftHalfCircleClipper(), // Use custom clipper for half circle
//                 child: Container(
//                   width: 300, // Adjust size
//                   height: 300,
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     border: Border.all(
//                       color: Colors.blue[100]!, // Adjust the color
//                       width: 2, // Adjust border width
//                     ),
//                   ),
//                 ),
//               ),
//               // Inner Circle (Half) with Right Side Visible
//               ClipPath(
//                 clipper: LeftHalfCircleClipper(), // Use custom clipper for half circle
//                 child: Container(
//                   width: 250, // Adjust size
//                   height: 250,
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     color: Colors.transparent, // Adjust color if needed
//                     border: Border.all(
//                       color: Colors.lightBlueAccent.withOpacity(0.5), // Adjust the color and opacity
//                       width: 30, // Adjust border width
//                     ),
//                   ),
//                 ),
//               ),
//               // Dot
//               Positioned(
//                 top: 60, // Adjust position
//                 left: 15, // Adjust position
//                 child: Container(
//                   width: 20, // Adjust size
//                   height: 20,
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     color: Colors.grey, // Adjust dot color
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// class LeftHalfCircleClipper extends CustomClipper<Path> {
//   @override
//   Path getClip(Size size) {
//     Path path = Path();
//     path.addArc(Rect.fromLTWH(0, 0, size.width, size.height), 1.57, 3.14); // Adjust arc to start from left side
//     path.lineTo(size.width / 2, size.height); // Draw line to the bottom middle
//     path.lineTo(size.width / 2, 0); // Draw line back to the top middle
//     path.close(); // Close the path to form a half circle
//     return path;
//   }
//
//   @override
//   bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
//     return false; // No need to reclip since the shape is constant
//   }
// }



import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Padding(
          padding: EdgeInsets.only(left: 1200, top: 200, right: 50),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer Circle (Half) with Right Side Visible
              ClipPath(
                clipper: RightHalfCircleClipper(),
                child: CustomPaint(
                  size: Size(300, 300),
                  painter: CirclePainter(
                    color: Colors.blue[100]!,
                    strokeWidth: 2,
                  ),
                ),
              ),
              // Inner Circle (Half) with Left Side Visible
              ClipPath(
                clipper: LeftHalfCircleClipper(),
                child: CustomPaint(
                  size: Size(250, 250),
                  painter: CirclePainter(
                    color: Colors.lightBlueAccent.withOpacity(0.5),
                    strokeWidth: 30,
                  ),
                ),
              ),
              // Dot
              Positioned(
                top: 60,
                right: 15,
                child: CustomPaint(
                  size: Size(20, 20),
                  painter: CirclePainter(
                    color: Colors.grey,
                    strokeWidth: 0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CirclePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  CirclePainter({required this.color, required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = color;

    canvas.drawCircle(Offset(size.width / 2, size.height / 2), size.width / 2, paint);
  }

  @override
  bool shouldRepaint(CirclePainter oldDelegate) {
    return false;
  }
}

class RightHalfCircleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.addArc(Rect.fromLTWH(0, 0, size.width, size.height), 0, 3.14);
    path.lineTo(size.width / 2, size.height);
    path.lineTo(size.width / 2, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}

class LeftHalfCircleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.addArc(Rect.fromLTWH(0, 0, size.width, size.height), 1.57, 3.14);
    path.lineTo(size.width / 2, size.height);
    path.lineTo(size.width / 2, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}