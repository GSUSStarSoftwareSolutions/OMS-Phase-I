// // import 'package:flutter/material.dart';
// // import 'package:flutter_stripe/flutter_stripe.dart';
// // import 'package:http/http.dart' as http;
// // import 'dart:convert';
// //
// // void main() {
// //   WidgetsFlutterBinding.ensureInitialized();
// //   Stripe.publishableKey = "pk_test_your_publishable_key"; // Replace with your Stripe publishable key
// //   runApp(MyApp());
// // }
// //
// // class MyApp extends StatelessWidget {
// //   @override
// //   Widget build(BuildContext context) {
// //     return MaterialApp(
// //       home: PaymentScreen(),
// //     );
// //   }
// // }
// //
// // class PaymentScreen extends StatefulWidget {
// //   @override
// //   _PaymentScreenState createState() => _PaymentScreenState();
// // }
// //
// // class _PaymentScreenState extends State<PaymentScreen> {
// //   String _clientSecret = "";
// //
// //   Future<void> _createPaymentIntent() async {
// //     final url = Uri.parse('http://localhost:8080/api/payment/create-payment-intent');
// //     final response = await http.post(
// //       url,
// //       headers: {'Content-Type': 'application/json'},
// //       body: json.encode({'amount': 5000}), // $50.00
// //     );
// //
// //     final responseData = json.decode(response.body);
// //     setState(() {
// //       _clientSecret = responseData['clientSecret'];
// //     });
// //   }
// //
// //   Future<void> _confirmPayment() async {
// //     try {
// //       await Stripe.instance.confirmPayment(
// //         paymentIntentClientSecret: _clientSecret,
// //         paymentMethodParams: PaymentMethodParams.card(paymentMethodData: null),
// //       );
// //       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Payment successful')));
// //     } catch (e) {
// //       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Payment failed: $e')));
// //     }
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(title: Text('Stripe Payment')),
// //       body: Padding(
// //         padding: const EdgeInsets.all(20.0),
// //         child: Column(
// //           children: [
// //             ElevatedButton(
// //               onPressed: _createPaymentIntent,
// //               child: Text('Create Payment Intent'),
// //             ),
// //             if (_clientSecret.isNotEmpty)
// //               ElevatedButton(
// //                 onPressed: _confirmPayment,
// //                 child: Text('Confirm Payment'),
// //               ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }
// //original
// // import 'package:flutter_stripe/flutter_stripe.dart';
// // import 'package:flutter/material.dart';
// // import 'package:http/http.dart' as http;
// // import 'dart:convert';
// //
// //
// //
// //
// // class PaymentScreen extends StatefulWidget {
// //   @override
// //   _PaymentScreenState createState() => _PaymentScreenState();
// // }
// //
// // class _PaymentScreenState extends State<PaymentScreen> {
// //   String _clientSecret = "";
// //
// //   Future<void> _createPaymentIntent() async {
// //     final url = Uri.parse('http://localhost:8080/api/payment/create-payment-intent');
// //     final response = await http.post(
// //       url,
// //       headers: {'Content-Type': 'application/json'},
// //       body: json.encode({'amount': 5000}), // $50.00
// //     );
// //
// //     final responseData = json.decode(response.body);
// //     setState(() {
// //       _clientSecret = responseData['clientSecret'];
// //     });
// //   }
// //
// //   Future<void> _confirmPayment() async {
// //     try {
// //       // Create a payment method with card details
// //       final paymentMethod = await Stripe.instance.createPaymentMethod(
// //         params: PaymentMethodParams.card(
// //           paymentMethodData: PaymentMethodData(),
// //         ),
// //       );
// //
// //       // Confirm the payment using the payment intent's client secret and the created payment method
// //       await Stripe.instance.confirmPayment(
// //         data: PaymentIntentConfirmParams(
// //           paymentIntentClientSecret: _clientSecret,
// //           payment_method: paymentMethod.id,
// //         ), paymentIntentClientSecret: '',
// //       );
// //
// //       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Payment successful')));
// //     } catch (e) {
// //       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Payment failed: $e')));
// //     }
// //   }
// //   // Future<void> _confirmPayment() async {
// //   //   try {
// //   //     // Create a payment method with card details
// //   //     final paymentMethod = await Stripe.instance.createPaymentMethod(
// //   //       PaymentMethodParams.card(
// //   //         paymentMethodData: PaymentMethodData(),
// //   //       ),
// //   //     );
// //   //
// //   //     // Confirm the payment using the payment intent's client secret and the created payment method
// //   //     await Stripe.instance.confirmPayment(
// //   //       paymentIntentClientSecret: _clientSecret,
// //   //       data: PaymentMethodData(paymentMethod: paymentMethod),
// //   //     );
// //   //
// //   //     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Payment successful')));
// //   //   } catch (e) {
// //   //     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Payment failed: $e')));
// //   //   }
// //   // }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(title: Text('Stripe Payment')),
// //       body: Padding(
// //         padding: const EdgeInsets.all(20.0),
// //         child: Column(
// //           children: [
// //             ElevatedButton(
// //               onPressed: _createPaymentIntent,
// //               child: Text('Create Payment Intent'),
// //             ),
// //             if (_clientSecret.isNotEmpty)
// //               ElevatedButton(
// //                 onPressed: _confirmPayment,
// //                 child: Text('Confirm Payment'),
// //               ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// //
// //   PaymentIntentConfirmParams({required String paymentIntentClientSecret, required String payment_method}) {}
// // }
// //
// // void main() {
// //   WidgetsFlutterBinding.ensureInitialized();
// //   Stripe.publishableKey = "pk_test_your_publishable_key"; // Replace with your Stripe publishable key
// //   runApp(MaterialApp(home: PaymentScreen()));
// // }
//
//
//
// import 'dart:convert';
//
// import 'package:flutter/material.dart';
// import 'package:flutter_stripe/flutter_stripe.dart';
// import 'package:http/http.dart' as http;
// ///import 'package:universal_platform/universal_platform.dart';
//
// void main() {
//   WidgetsFlutterBinding.ensureInitialized();
//   Stripe.publishableKey =
//   'pk_test_51BTUDGJAJfZb9HEBwDg8'
//       '6TN1KNprHjkfipXmEDMb0gSCassK5T3ZfxsAb'
//       'cgKVmAIXF7oZ6ItlZZbXO6idTHE67IM007EwQ4uN3';
//   runApp(const MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({Key? key}) : super(key: key);
//   @override
//   Widget build(BuildContext context) {
//     return const MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'Flutter Demo',
//       home: StripePaymentScreen(),
//     );
//   }
// }
//
// class StripePaymentScreen extends StatefulWidget {
//   const StripePaymentScreen({super.key});
//
//   @override
//   State<StripePaymentScreen> createState() => _StripePaymentScreenState();
// }
//
// class _StripePaymentScreenState extends State<StripePaymentScreen> {
//   Map<String, dynamic>? paymentIntent;
//   bool isWeb = UniversalPlatform.isWeb;
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Stripe Payment'),
//       ),
//       body: Center(
//         child: ElevatedButton(
//           child: const Text('Make Payment'),
//           onPressed: () async {
//             await makePayment();
//           },
//         ),
//       ),
//     );
//   }
//
//   Future<void> makePayment() async {
//     try {
//       // Create payment intent data
//       paymentIntent = await createPaymentIntent('10', 'INR');
//       // initialise the payment sheet setup
//       await Stripe.instance.initPaymentSheet(
//         paymentSheetParameters: SetupPaymentSheetParameters(
//           // Client secret key from payment data
//           paymentIntentClientSecret: paymentIntent!['client_secret'],
//           googlePay: const PaymentSheetGooglePay(
//             // Currency and country code is accourding to India
//               testEnv: true,
//               currencyCode: "INR",
//               merchantCountryCode: "IN"),
//           // Merchant Name
//           merchantDisplayName: 'Flutterwings',
//           // return URl if you want to add
//           // returnURL: 'flutterstripe://redirect',
//         ),
//       );
//       // Display payment sheet
//       displayPaymentSheet();
//     } catch (e) {
//       print("exception $e");
//
//       if (e is StripeConfigException) {
//         print("Stripe exception ${e.message}");
//       } else {
//         print("exception $e");
//       }
//     }
//   }
//
//   displayPaymentSheet() async {
//     try {
//       // "Display payment sheet";
//       await Stripe.instance.presentPaymentSheet();
//       // Show when payment is done
//       // Displaying snackbar for it
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Paid successfully")),
//       );
//       paymentIntent = null;
//     } on StripeException catch (e) {
//       // If any error comes during payment
//       // so payment will be cancelled
//       print('Error: $e');
//
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text(" Payment Cancelled")),
//       );
//     } catch (e) {
//       print("Error in displaying");
//       print('$e');
//     }
//   }
//
//   createPaymentIntent(String amount, String currency) async {
//     try {
//       Map<String, dynamic> body = {
//         'amount': ((int.parse(amount)) * 100).toString(),
//         'currency': currency,
//         'payment_method_types[]': 'card',
//       };
//       var secretKey =
//           "<secret_key>";
//       var response = await http.post(
//         Uri.parse('https://api.stripe.com/v1/payment_intents'),
//         headers: {
//           'Authorization': 'Bearer $secretKey',
//           'Content-Type': 'application/x-www-form-urlencoded'
//         },
//         body: body,
//       );
//       print('Payment Intent Body: ${response.body.toString()}');
//       return jsonDecode(response.body.toString());
//     } catch (err) {
//       print('Error charging user: ${err.toString()}');
//     }
//   }
// }
//
