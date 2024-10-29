// // import 'package:flutter/material.dart';
// // import 'package:razorpay_flutter/razorpay_flutter.dart';
// //
// // void main() {
// //   runApp(const MyApp());
// // }
// //
// // class MyApp extends StatelessWidget {
// //   const MyApp({super.key});
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return MaterialApp(
// //       title: 'Flutter Demo',
// //       theme: ThemeData(
// //         primarySwatch: Colors.blue,
// //       ),
// //       home: const MyHomePage(title: 'Flutter Demo Home Page'),
// //     );
// //   }
// // }
// //
// // class MyHomePage extends StatefulWidget {
// //   const MyHomePage({super.key, required this.title});
// //
// //   final String title;
// //
// //   @override
// //   State<MyHomePage> createState() => _MyHomePageState();
// // }
// //
// // class _MyHomePageState extends State<MyHomePage> {
// //   late Razorpay _razorpay;
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     _razorpay = Razorpay();
// //         //_razorpay.init('YOUR_API_KEY_HERE');
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: Text(widget.title),
// //       ),
// //       body: Center(
// //         child: Column(
// //           mainAxisAlignment: MainAxisAlignment.center,
// //           children: <Widget>[
// //             const Text(
// //               'Pay with Razorpay',
// //             ),
// //             ElevatedButton(
// //               onPressed: () async {
// //                 var options = {
// //                   'key': 'rzp_live_ILgsfZCZoFIKMb',
// //                   'amount': 100,
// //                   'name': 'Acme Corp.',
// //                   'description': 'Fine T-Shirt',
// //                   'retry': {'enabled': true, 'max_count': 1},
// //                   'send_sms_hash': true,
// //                   'prefill': {'contact': '8888888888', 'email': 'test@razorpay.com'},
// //                   'external': {
// //                     'wallets': ['paytm']
// //                   }
// //                 };
// //                 _razorpay.open(options);
// //               },
// //               child: const Text("Pay with Razorpay"),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// //
// //   void handlePaymentErrorResponse(PaymentFailureResponse response) {
// //     showAlertDialog(context, "Payment Failed", "Code: ${response.code}\nDescription: ${response.message}\nMetadata:${response.error.toString()}");
// //   }
// //
// //   void handlePaymentSuccessResponse(PaymentSuccessResponse response) {
// //     showAlertDialog(context, "Payment Successful", "Payment ID: ${response.paymentId}");
// //   }
// //
// //   void handleExternalWalletSelected(ExternalWalletResponse response) {
// //     showAlertDialog(context, "External Wallet Selected", "${response.walletName}");
// //   }
// //
// //   void showAlertDialog(BuildContext context, String title, String message) {
// //     AlertDialog alert = AlertDialog(
// //       title: Text(title),
// //       content: Text(message),
// //     );
// //     showDialog(
// //       context: context,
// //       builder: (BuildContext context) {
// //         return alert;
// //       },
// //     );
// //   }
// // }
//
//
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/widgets.dart';
//
// void main() {
//   runApp(MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Alert Dialog Demo',
//       home: MyHomePage(),
//     );
//   }
// }
//
// class MyHomePage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Alert Dialog Demo'),
//       ),
//       body: Center(
//         child: ElevatedButton(
//           child: const Text('Show Alert Dialog'),
//           onPressed: () {
//             _showAlertDialog(context);
//             // showDialog(context: context, builder: (context) => const
//             // CustomAlert()
//            // );
//            // _showAlertDialog(context);
//           },
//         ),
//       ),
//     );
//   }
//
//   void _showAlertDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return Stack(
//           children: [
//             Container(
//               decoration: BoxDecoration(
//                   color: Colors.white.withOpacity(0.5),
//                 //borderRadius: BorderRadius.circular(5)
//               ),
//             ),
//             Positioned(
//               top: 0,
//               left: 0,
//               right: 0,
//               child: AlertDialog(
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(4)
//                 ),
//                 contentPadding: EdgeInsets.zero, // remove default padding
//                 content: SizedBox(
//                   width: 150, // set width
//                   height: 65, // set height
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min, // make the column wrap its content
//                     children: [
//                       Icon(Icons.check_circle_rounded,color: Colors.green,size: 20,),
//
//                       Text('Product Successfully Created',style: TextStyle(fontSize: 15),),// your content here
//                       Padding(
//                           padding: EdgeInsets.only(left: 50),
//                           child: SelectableText('Your Order id Is : ORD_02276')),
//                     ],
//                   ),
//                 ),
//                 actions: [
//                   TextButton(
//                     child: Text('OK'),
//                     onPressed: () {
//                       Navigator.of(context).pop();
//                     },
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         );
//       },
//     );
//   }
// }
//
//
// class CustomAlert extends StatelessWidget {
//   const CustomAlert({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Positioned(
//       left: 0,
//       right: 0,
//       top: 10,
//       child: Dialog(
//         child: Container(
//           width: 120,
//           height: 100,
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(5)
//           ),
//           child: const Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//
//               SizedBox(height: 10,),
//               Row(
//                 children: [
//
//                   // SelectableRegion(
//                   //   selectionControls: TextSelection(),
//                   //     focusNode: _focusNode,
//                   //     child: Text('Your Order id Is : ORD_02276'),
//                   //
//                   //     ),
//                 ],
//               )
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
