// // import 'package:flutter/material.dart';
// //
// // void main() {
// //   runApp(MyApp());
// // }
// //
// // class MyApp extends StatelessWidget {
// //   @override
// //   Widget build(BuildContext context) {
// //     return MaterialApp(
// //       home: Scaffold(
// //         appBar: AppBar(
// //           title: Text('Tracking Status'),
// //         ),
// //         body: Center(
// //           child: TrackingStatus(),
// //         ),
// //       ),
// //     );
// //   }
// // }
// //
// // class TrackingStatus extends StatefulWidget {
// //   @override
// //   _TrackingStatusState createState() => _TrackingStatusState();
// // }
// //
// // class _TrackingStatusState extends State<TrackingStatus> {
// //   final TextEditingController _deliveryStatusController = TextEditingController();
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Padding(
// //       padding: const EdgeInsets.only(left: 90, top: 100, right: 120),
// //       child: Container(
// //         height: 100,
// //         width: double.infinity,
// //         decoration: BoxDecoration(
// //           color: Color(0xFFFFFFFF), // background: #FFFFFF
// //           boxShadow: [BoxShadow(
// //             offset: Offset(0, 3),
// //             blurRadius: 6,
// //             color: Color(0x29000000), // box-shadow: 0px 3px 6px #00000029
// //           )],
// //           border: Border.all(
// //             // border: 2px
// //             color: Color(0xFFB2C2D3), // border: #B2C2D3
// //           ),
// //           borderRadius: BorderRadius.all(Radius.circular(8)), // border-radius: 8px
// //         ),
// //         child: Padding(
// //           padding: EdgeInsets.only(top: 30),
// //           child: Row(
// //             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
// //             children: [
// //               Expanded(
// //                 flex: 1,
// //                 child: Column(
// //                   children: [
// //                     Text(
// //                       'Registration',
// //                       style: TextStyle(
// //                         color: Colors.green, // completed stage
// //                       ),
// //                     ),
// //                     Container(
// //                       height: 2,
// //                       width: double.infinity,
// //                       color: Colors.green, // tracking line
// //                     ),
// //                   ],
// //                 ),
// //               ),
// //               Expanded(
// //                 flex: 1,
// //                 child: Column(
// //                   children: [
// //                     Text(
// //                       'GPO Consultation',
// //                       style: TextStyle(
// //                         color: Colors.green, // completed stage
// //                       ),
// //                     ),
// //                     Container(
// //                       height: 2,
// //                       width: double.infinity,
// //                       color: Colors.green, // tracking line
// //                     ),
// //                   ],
// //                 ),
// //               ),
// //               Expanded(
// //                 flex: 1,
// //                 child: Column(
// //                   children: [
// //                     Text(
// //                       'Nursing Corner',
// //                       style: TextStyle(
// //                         color: Colors.grey, // not completed stage
// //                       ),
// //                     ),
// //                     Container(
// //                       height: 2,
// //                       width: double.infinity,
// //                       color: Colors.grey, // tracking line
// //                     ),
// //                   ],
// //                 ),
// //               ),
// //               Expanded(
// //                 flex: 1,
// //                 child: Column(
// //                   children: [
// //                     Text(
// //                       'GPO Drugs',
// //                       style: TextStyle(
// //                         color: Colors.grey, // not completed stage
// //                       ),
// //                     ),
// //                     Container(
// //                       height: 2,
// //                       width: double.infinity,
// //                       color: Colors.grey, // tracking line
// //                     ),
// //                   ],
// //                 ),
// //               ),
// //               Expanded(
// //                 flex: 1,
// //                 child: Column(
// //                   children: [
// //                     Text(
// //                       'Pathology',
// //                       style: TextStyle(
// //                         color: Colors.grey, // not completed stage
// //                       ),
// //                     ),
// //                     Container(
// //                       height: 2,
// //                       width: double.infinity,
// //                       color: Colors.grey, // tracking line
// //                     ),
// //                   ],
// //                 ),
// //               ),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }
// // import 'package:flutter/material.dart';
// //
// // void main() {
// //   runApp(MaterialApp(
// //     home: Scaffold(
// //       appBar: AppBar(title: Text('Tracking Status')),
// //       body: TrackingStatus(),
// //     ),
// //   ));
// // }
// //
// // class TrackingStatus extends StatelessWidget {
// //   @override
// //   Widget build(BuildContext context) {
// //     return Padding(
// //       padding: const EdgeInsets.all(20.0),
// //       child: Row(
// //         children: [
// //           _buildStatusItem("Registration", true, true),
// //           _buildConnector(true),
// //           _buildStatusItem("OPD Consultation", true, true),
// //           _buildConnector(false),
// //           _buildStatusItem("Nursing Corner", false, false),
// //           _buildConnector(false),
// //           _buildStatusItem("OPD Drugs", false, false),
// //           _buildConnector(false),
// //           _buildStatusItem("Pathology", false, false),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   Widget _buildStatusItem(String title, bool isCompleted, bool isActive) {
// //     return Expanded(
// //       child: Column(
// //         children: [
// //           Stack(
// //             alignment: Alignment.center,
// //             children: [
// //               Container(
// //                 height: 5,
// //                 color: isActive ? Colors.green : Colors.transparent,
// //                 margin: EdgeInsets.only(bottom: 20), // Adjust margin for spacing
// //               ),
// //               CircleAvatar(
// //                 radius: 20,
// //                 backgroundColor: isCompleted ? Colors.green : Colors.grey[300],
// //                 child: Icon(
// //                   isCompleted ? Icons.check : Icons.circle,
// //                   color: isCompleted ? Colors.white : Colors.grey,
// //                 ),
// //               ),
// //             ],
// //           ),
// //           SizedBox(height: 8),
// //           Text(
// //             title,
// //             style: TextStyle(
// //               color: isCompleted ? Colors.black : Colors.grey,
// //               fontWeight: FontWeight.bold,
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   Widget _buildConnector(bool isActive) {
// //     return Container(
// //       width: 40,
// //       height: 2,
// //       color: isActive ? Colors.green : Colors.grey[300],
// //     );
// //   }
// // }
// /// Order Tracker Zen
// ///
// /// A Flutter package that provides a simple and customizable order tracking widget for your applications.
// /// This example demonstrates how to create an order tracking widget using the OrderTrackerZen package.
// ///
// /// To use this package, add `order_tracker_zen` as a dependency in your `pubspec.yaml` file.
// import 'package:flutter/material.dart';
// import 'package:order_tracker_zen/order_tracker_zen.dart';
//
// /// The main function is the entry point of the application.
// void main(List<String> args) {
//   runApp(MyApp());
// }
//
// /// MyApp is a StatelessWidget that acts as the root widget of the application.
// ///
// /// It configures the MaterialApp with the necessary theme and routing information.
// class MyApp extends StatelessWidget {
//   const MyApp({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         useMaterial3: true,
//       ),
//         home: Scaffold(
//           appBar: AppBar(
//             title: const Text("Order Tracker Zen"),
//           ),
//           body: Center(
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 // Add padding around the OrderTrackerZen widget for better presentation.
//                 Padding(
//                   padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
//                   child: SizedBox(
//                     width: 300, // specify a width here
//                     child: OrderTrackerZen(
//                       // Provide an array of TrackerData objects to display the order tracking information.
//                       tracker_data: [
//                         // TrackerData represents a single step in the order tracking process.
//                         TrackerData(
//                           title: "Order Placed",
//                           date: "",
//                           // Provide an array of TrackerDetails objects to display more details about this step.
//                           tracker_details: [
//                             // TrackerDetails contains detailed information about a specific event in the order tracking process.
//                             TrackerDetails(
//                               title: "Your order was placed on Zenzzen",
//                               datetime: "Sat, 8 Apr '22 - 17:17",
//                             ),
//                             TrackerDetails(
//                               title: "Zenzzen Arranged A Callback Request",
//                               datetime: "Sat, 8 Apr '22 - 17:42",
//                             ),
//                           ],
//                         ),
//                         // yet another TrackerData object
//                         TrackerData(
//                           title: "Order Shipped",
//                           date: "Sat, 8 Apr '22",
//                           tracker_details: [
//                             TrackerDetails(
//                               title: "Your order was shipped with MailDeli",
//                               datetime: "Sat, 8 Apr '22 - 17:50",
//                             ),
//                           ],
//                         ),
//                         // And yet another TrackerData object
//                         TrackerData(
//                           title: "Order Delivered",
//                           date: "Sat,8 Apr '22",
//                           tracker_details: [
//                             TrackerDetails(
//                               title: "You received your order, by MailDeli",
//                               datetime: "Sat, 8 Apr '22 - 17:51",
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         )
//     );
//   }
// }
//
// // Path: example/lib/main.dart
// // Order Tracker Zen
// // A Flutter package that provides a simple and customizable order tracking widget for your applications.
// // This example demonstrates how to create an order tracking widget using the OrderTrackerZen package.
// // To use this package, add `order_tracker_zen` as a dependency in your `pubspec.yaml` file.