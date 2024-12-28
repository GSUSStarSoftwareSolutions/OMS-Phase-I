import 'package:btb/widgets/text_style.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:html' as html;

import 'package:provider/provider.dart';

import '../sample/provider.dart';



class AccountMenu extends StatefulWidget {
  const AccountMenu({super.key});

  @override
  _AccountMenuState createState() =>
      _AccountMenuState();
}

class _AccountMenuState extends State<AccountMenu> {
  bool showTriangle = false; // Flag to manage the triangle visibility

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 35),
        child: Stack(
          clipBehavior: Clip.none,
          children: [

            // PopupMenuButton wrapped in StatefulWidget to handle triangle visibility
            PopupMenuButton<String>(
              color: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(

                borderRadius: BorderRadius.circular(10),
               // side: BorderSide(color: Colors.grey),

              ),
              onSelected: (value) {
                if (value == 'logout') {
                  setState(() {
                    html.window.sessionStorage.clear(); // Clears all data in sessionStorage
                    showTriangle = false;
                  //  window.s
                    //window.sessionStorage["token"].remove;
                    showConfirmationDialog(context);
                    print('Logged out');
                  });
                }
              },
              itemBuilder: (BuildContext context) {
                return [
                  const PopupMenuItem<String>(

                    value: 'logout',
                    child: Row(
                      children: [
                        Icon(Icons.exit_to_app, color: Colors.black),
                        SizedBox(width: 8),
                        Text('Logout'),
                      ],
                    ),
                  ),

                ];
              },
              offset: const  Offset(0,50),
              icon: const Icon(Icons.account_circle_outlined),
              onOpened: () {
                setState(() {
                  showTriangle = true; // Show the triangle when the menu is opened
                });
              },
              onCanceled: () {
                setState(() {
                  showTriangle = false; // Hide the triangle when the menu is closed
                });
              },
            ),
            if (showTriangle)
              Positioned(
                top: 40,
                right: 10,
                child: CustomPaint(
                  painter: TrianglePainter(),
                  size: const Size(20, 10), // Width and height of the triangle
                ),
              ),
          ],
        ),
      ),
    );
  }
}

  void showConfirmationDialog(BuildContext context) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return
          AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          contentPadding: EdgeInsets.zero,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Close Button
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.red),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Warning Icon
                    const Icon(Icons.warning, color: Colors.orange, size: 50),
                    const SizedBox(height: 16),
                    // Confirmation Message
                    Text(
                      'Are You Sure',
                      style: TextStyles.header1,
                    ),
                    const SizedBox(height: 20),
                    // Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                          //  final authProvider = Provider.of<AuthProvider>(context, listen: false);
                            // Handle Yes action
                            context.go('/');
                            //authProvider.logout();
                            // Navigator.push(
                            //   context,
                            //   PageRouteBuilder(
                            //     pageBuilder: (context, animation,
                            //         secondaryAnimation) =>
                            //         LoginScr(),
                            //     transitionDuration:
                            //     const Duration(milliseconds: 5),
                            //     transitionsBuilder: (context, animation,
                            //         secondaryAnimation, child) {
                            //       return FadeTransition(
                            //         opacity: animation,
                            //         child: child,
                            //       );
                            //     },
                            //   ),
                            // );
                            // Navigator.of(context).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            side: const BorderSide(color: Colors.blue),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                          child: const Text(
                            'Yes',
                            style: TextStyle(
                              color: Colors.blue,
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            // Handle No action
                            Navigator.of(context).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            side: const BorderSide(color: Colors.red),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                          child: const Text(
                            'No',
                            style: TextStyle(
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    ).whenComplete(() {
      //_hasShownPopup = false;
    });
  }

class TrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Paint for the white fill color
    final Paint fillPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // Paint for the grey border
    final Paint borderPaint = Paint()
      ..color = Colors.grey
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Define the triangle path
    final Path path = Path();
    path.moveTo(0, size.height);
    path.lineTo(size.width / 2, 0);
    path.lineTo(size.width, size.height);
    path.close();

    // Draw the triangle fill
    canvas.drawPath(path, fillPaint);

    // Draw the triangle border
    //canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}


//original
// class AccountMenu extends StatelessWidget {
//   bool _hasShownPopup = false;
//
//
//   @override
//   Widget build(BuildContext context) {
//     return Align(
//       alignment: Alignment.topLeft,
//       child: Padding(
//         padding: const EdgeInsets.only(right: 35),
//         child: PopupMenuButton<String>(
//           color: Colors.white,
//           icon: Icon(Icons.account_circle_sharp),
//           onSelected: (value) {
//             if (!_hasShownPopup) {
//               _hasShownPopup = true;
//               if (value == 'logout') {
//                 _logout(context);
//               }
//             }
//           },
//           itemBuilder: (BuildContext context) {
//             return [
//                PopupMenuItem<String>(
//                 value: 'logout',
//                 child: Text('Logout',style: TextStyles.body,),
//               ),
//
//             ];
//           },
//           offset: const Offset(0, 40), // Adjust the offset to display the menu below the icon
//         ),
//       ),
//     );
//   }
//
//   void _logout(BuildContext context)  {
//    // await html.window.sessionStorage.remove('token');
//     showConfirmationDialog(context);
//   }
//
//   void showConfirmationDialog(BuildContext context) {
//     showDialog(
//       barrierDismissible: false,
//       context: context,
//       builder: (BuildContext context) {
//         return
//           AlertDialog(
//
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(15.0),
//           ),
//           contentPadding: EdgeInsets.zero,
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               // Close Button
//               Align(
//                 alignment: Alignment.topRight,
//                 child: IconButton(
//                   icon: Icon(Icons.close, color: Colors.red),
//                   onPressed: () {
//                     Navigator.of(context).pop();
//                   },
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Column(
//                   children: [
//                     // Warning Icon
//                     Icon(Icons.warning, color: Colors.orange, size: 50),
//                     SizedBox(height: 16),
//                     // Confirmation Message
//                     Text(
//                       'Are You Sure',
//                       style: TextStyles.header1,
//                     ),
//                     SizedBox(height: 20),
//                     // Buttons
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                       children: [
//                         ElevatedButton(
//                           onPressed: () {
//                             // Handle Yes action
//                             context.go('/');
//                             // Navigator.push(
//                             //   context,
//                             //   PageRouteBuilder(
//                             //     pageBuilder: (context, animation,
//                             //         secondaryAnimation) =>
//                             //         LoginScr(),
//                             //     transitionDuration:
//                             //     const Duration(milliseconds: 5),
//                             //     transitionsBuilder: (context, animation,
//                             //         secondaryAnimation, child) {
//                             //       return FadeTransition(
//                             //         opacity: animation,
//                             //         child: child,
//                             //       );
//                             //     },
//                             //   ),
//                             // );
//                             // Navigator.of(context).pop();
//                           },
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.white,
//                             side: BorderSide(color: Colors.blue),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(10.0),
//                             ),
//                           ),
//                           child: Text(
//                             'Yes',
//                             style: TextStyle(
//                               color: Colors.blue,
//                             ),
//                           ),
//                         ),
//                         ElevatedButton(
//                           onPressed: () {
//                             // Handle No action
//                             Navigator.of(context).pop();
//                           },
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.white,
//                             side: BorderSide(color: Colors.red),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(10.0),
//                             ),
//                           ),
//                           child: Text(
//                             'No',
//                             style: TextStyle(
//                               color: Colors.red,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     ).whenComplete(() {
//       _hasShownPopup = false;
//     });
//   }
// }


class AccountMenu1 extends StatelessWidget {
  bool _hasShownPopup = false;

  AccountMenu1({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: const EdgeInsets.only(right: 35),
        child: PopupMenuButton<String>(
          icon: const Icon(Icons.account_circle),
          onSelected: (value) {
            if (!_hasShownPopup) {
              _hasShownPopup = true;
              if (value == 'logout') {
                _logout(context);
              }
              if(value == 'Profile') {
    Map<String, dynamic> User_details ={
    "text": "hi",
    };

                context.go('/Cus_Profile',extra: {'Usr_detail':User_details});
              }
            }
          },
          itemBuilder: (BuildContext context) {
            return [
              const PopupMenuItem<String>(
                value: 'logout',
                child: Text('Logout'),
              ),
              const PopupMenuItem<String>(
                value: 'Profile',
                child: Text('Profile'),
              ),
            ];
          },
          offset: const Offset(0, 40), // Adjust the offset to display the menu below the icon
        ),
      ),
    );
  }

  void _logout(BuildContext context)  {
    //await html.window.sessionStorage.remove('token');
    showConfirmationDialog(context);
  }

  void showConfirmationDialog(BuildContext context) {
    showDialog(

      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return
          AlertDialog(

            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            contentPadding: EdgeInsets.zero,
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Close Button
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.red),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // Warning Icon
                      const Icon(Icons.warning, color: Colors.orange, size: 50),
                      const SizedBox(height: 16),
                      // Confirmation Message
                      const Text(
                        'Are You Sure',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              // Handle Yes action
                              context.go('/');
                              // Navigator.push(
                              //   context,
                              //   PageRouteBuilder(
                              //     pageBuilder: (context, animation,
                              //         secondaryAnimation) =>
                              //         LoginScr(),
                              //     transitionDuration:
                              //     const Duration(milliseconds: 5),
                              //     transitionsBuilder: (context, animation,
                              //         secondaryAnimation, child) {
                              //       return FadeTransition(
                              //         opacity: animation,
                              //         child: child,
                              //       );
                              //     },
                              //   ),
                              // );
                              // Navigator.of(context).pop();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              side: const BorderSide(color: Colors.blue),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                            child: const Text(
                              'Yes',
                              style: TextStyle(
                                color: Colors.blue,
                              ),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              // Handle No action
                              Navigator.of(context).pop();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              side: const BorderSide(color: Colors.red),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                            child: const Text(
                              'No',
                              style: TextStyle(
                                color: Colors.red,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
      },
    ).whenComplete(() {
      _hasShownPopup = false;
    });
  }
}