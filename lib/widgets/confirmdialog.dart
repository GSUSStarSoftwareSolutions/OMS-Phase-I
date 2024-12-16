// import 'dart:html';
//
// import 'package:btb/screen/login.dart';
// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
//
//
//
// class AccountMenu extends StatelessWidget {
//   bool _hasShownPopup = false;
//   @override
//   Widget build(BuildContext context) {
//     return Align(
//       alignment: Alignment.topLeft,
//       child: Padding(
//         padding: const EdgeInsets.only(right: 35),
//         child: PopupMenuButton<String>(
//           icon: const Icon(Icons.account_circle),
//           onSelected: (value) {
//             if (!_hasShownPopup) {
//               _hasShownPopup = true;
//               if (value == 'logout') {
//                 window.sessionStorage.remove('token');
//                 showConfirmationDialog(context);
//                 //context.go('/');
//               }
//             }
//           },
//           itemBuilder: (BuildContext context) {
//             return [
//               const PopupMenuItem<String>(
//                 value: 'logout',
//                 child: Text('Logout'),
//               ),
//             ];
//           },
//           offset: const Offset(0, 40), // Adjust the offset to display the menu below the icon
//         ),
//       ),
//     );
//   }
//
//   void showConfirmationDialog(BuildContext context) {
//
//     showDialog(
//       barrierDismissible: false,
//       context: context,
//       builder: (BuildContext context) {
//         return
//           AlertDialog(
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(15.0),
//             ),
//             contentPadding: EdgeInsets.zero,
//             content:
//             Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 // Close Button
//                 Align(
//                   alignment: Alignment.topRight,
//                   child: IconButton(
//                     icon: Icon(Icons.close, color: Colors.red),
//                     onPressed: () {
//                       Navigator.of(context).pop();
//                     },
//                   ),
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Column(
//                     children: [
//                       // Warning Icon
//                       Icon(Icons.warning, color: Colors.orange, size: 50),
//                       SizedBox(height: 16),
//                       // Confirmation Message
//                       Text(
//                         'Are You Sure',
//                         style: TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.black,
//                         ),
//                       ),
//                       SizedBox(height: 20),
//                       // Buttons
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                         children: [
//                           ElevatedButton(
//                             onPressed: () {
//                               // Handle Yes action
//                               context.go('/');
//                              //  Navigator.push(
//                              //    context,
//                              //    PageRouteBuilder(
//                              //      pageBuilder: (context, animation,
//                              //          secondaryAnimation) =>
//                              //          LoginScr(),
//                              //      transitionDuration:
//                              //      const Duration(milliseconds: 5),
//                              //      transitionsBuilder: (context, animation,
//                              //          secondaryAnimation, child) {
//                              //        return FadeTransition(
//                              //          opacity: animation,
//                              //          child: child,
//                              //        );
//                              //      },
//                              //    ),
//                              //  );
//                               // Navigator.of(context).pop();
//                             },
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: Colors.white,
//                               side: BorderSide(color: Colors.blue),
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(10.0),
//                               ),
//                             ),
//                             child: Text(
//                               'Yes',
//                               style: TextStyle(
//                                 color: Colors.blue,
//                               ),
//                             ),
//                           ),
//                           ElevatedButton(
//                             onPressed: () {
//                               // Handle No action
//                               Navigator.of(context).pop();
//                             },
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: Colors.white,
//                               side: BorderSide(color: Colors.red),
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(10.0),
//                               ),
//                             ),
//                             child: Text(
//                               'No',
//                               style: TextStyle(
//                                 color: Colors.red,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           );
//       },
//     ).whenComplete(() {
//       _hasShownPopup = false;
//     }
//     );
//   }
// }
//


import 'package:btb/widgets/text_style.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:html' as html; // Import html package

class AccountMenu extends StatelessWidget {
  bool _hasShownPopup = false;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: const EdgeInsets.only(right: 35),
        child: PopupMenuButton<String>(
          color: Colors.white,
          icon: Icon(Icons.account_circle_sharp),
          onSelected: (value) {
            if (!_hasShownPopup) {
              _hasShownPopup = true;
              if (value == 'logout') {
                _logout(context);
              }
            }
          },
          itemBuilder: (BuildContext context) {
            return [
               PopupMenuItem<String>(
                value: 'logout',
                child: Text('Logout',style: TextStyles.body,),
              ),

            ];
          },
          offset: const Offset(0, 40), // Adjust the offset to display the menu below the icon
        ),
      ),
    );
  }

  void _logout(BuildContext context)  {
   // await html.window.sessionStorage.remove('token');
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
                  icon: Icon(Icons.close, color: Colors.red),
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
                    Icon(Icons.warning, color: Colors.orange, size: 50),
                    SizedBox(height: 16),
                    // Confirmation Message
                    Text(
                      'Are You Sure',
                      style: TextStyles.header1,
                    ),
                    SizedBox(height: 20),
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
                            side: BorderSide(color: Colors.blue),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                          child: Text(
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
                            side: BorderSide(color: Colors.red),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                          child: Text(
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
class AccountMenu1 extends StatelessWidget {
  bool _hasShownPopup = false;

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

  void _logout(BuildContext context) async {
    await html.window.sessionStorage.remove('token');
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
                    icon: Icon(Icons.close, color: Colors.red),
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
                      Icon(Icons.warning, color: Colors.orange, size: 50),
                      SizedBox(height: 16),
                      // Confirmation Message
                      Text(
                        'Are You Sure',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 20),
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
                              side: BorderSide(color: Colors.blue),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                            child: Text(
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
                              side: BorderSide(color: Colors.red),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                            child: Text(
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