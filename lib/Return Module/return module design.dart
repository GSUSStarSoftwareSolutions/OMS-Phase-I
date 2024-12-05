import 'dart:async';
import 'dart:convert';
import 'dart:html';
import 'package:adaptive_scrollbar/adaptive_scrollbar.dart';
import 'package:btb/admin/Api%20name.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../delivery module/delivery detail.dart';
import 'package:http/http.dart' as http;

import '../widgets/confirmdialog.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: CreateReturn(
      storeImage: '',
      imageSizeString: const [],
      orderDetailsMap: const {},
      storeImages: const [],
      orderDetails: const [],
      imageSizeStrings: const [],
    ),
  ));
}

class CreateReturn extends StatefulWidget {
  final String storeImage;
  final List<String>? imageSizeString;
  final List<dynamic> orderDetails;
  List<String> storeImages;
  final Map<String, dynamic> orderDetailsMap;
  List<String> imageSizeStrings;
  final _formKey = GlobalKey<FormState>();

  //final Map<Product, TextEditingController> _controller = {};

  CreateReturn(
      {super.key,
      required this.orderDetailsMap,
      required this.storeImage,
      this.imageSizeString,
      required this.imageSizeStrings,
      required this.storeImages,
      required this.orderDetails});

  @override
  State<CreateReturn> createState() {
    return _CreateReturnState();
  }
}

class _CreateReturnState extends State<CreateReturn> {
  // FocusNode _focusNode = FocusNode();
  String? _selectedReason = 'Reason for return';
  final _controller = TextEditingController();
  List<dynamic> _orderDetails = [];
  late TextEditingController _dateController;

  List<TextEditingController> _qtyControllers = [];
  String? _errorText;
  String _enteredValues = '';
  final List<String> list = ['Reason for return', ' Option 1', '  Option 2'];
  int Index = 1;

  bool isOrdersSelected = false;
  double totalAmount = 0.0;
  final ScrollController horizontalScroll = ScrollController();
  final _textController = TextEditingController();
  final totalController = TextEditingController();
  List<String> storeImages = [];
  DateTime? _selectedDate;
  final TextEditingController customerIdController = TextEditingController();
  List<String> imageSizeStrings = [];
  String? errorMessage;
  final TextEditingController ContactPerson = TextEditingController();
  final TextEditingController OrderIDController = TextEditingController();
  final TextEditingController ShippingAddressController =
      TextEditingController();
  final TextEditingController NotesController = TextEditingController();
  final TextEditingController EmailAddressController = TextEditingController();
  final TextEditingController ContactpersonController = TextEditingController();
  final _reasonController = TextEditingController();
  Timer? _timer;
  String token = window.sessionStorage["token"] ?? " ";
  double _totalAmount = 0;
  bool _isLoading = false;
  Map<String, bool> _isHovered = {
    'Home': false,
    'Customer': false,
    'Products': false,
    'Orders': false,
    'Invoice': false,
    'Delivery': false,
    'Payment': false,
    'Return': false,
    'Reports': false,
  };

  List<Widget> _buildMenuItems(BuildContext context) {
    return [
      _buildMenuItem('Home', Icons.home_outlined, Colors.blue[900]!, '/Home'),
      _buildMenuItem(
          'Customer', Icons.account_circle_outlined, Colors.blue[900]!, '/Customer'),
      _buildMenuItem(
          'Products', Icons.image_outlined, Colors.blue[900]!, '/Product_List'),
      _buildMenuItem(
          'Orders', Icons.warehouse_outlined, Colors.blue[900]!, '/Order_List'),
      _buildMenuItem('Delivery', Icons.fire_truck_outlined, Colors.blue[900]!,
          '/Delivery_List'),
      _buildMenuItem('Invoice', Icons.document_scanner_outlined,
          Colors.blue[900]!, '/Invoice'),

      _buildMenuItem('Payment', Icons.payment_rounded, Colors.blue[900]!,
          '/Payment_List'),
      Container(
          decoration: BoxDecoration(
            color: Colors.blue[800],
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8), // Radius for top-left corner
              topRight: Radius.circular(8), // No radius for top-right corner
              bottomLeft: Radius.circular(8), // Radius for bottom-left corner
              bottomRight:
                  Radius.circular(8), // No radius for bottom-right corner
            ),
          ),
          child: _buildMenuItem(
              'Return', Icons.keyboard_return, Colors.white, '/Return_List')),
      _buildMenuItem('Reports', Icons.insert_chart_outlined, Colors.blue[900]!,
          '/Report_List'),
    ];
  }

  Widget _buildMenuItem(
      String title, IconData icon, Color iconColor, String route) {
    iconColor = _isHovered[title] == true ? Colors.blue : Colors.black87;
    title == 'Return' ? _isHovered[title] = false : _isHovered[title] = false;
    title == 'Return' ? iconColor = Colors.white : Colors.black;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered[title] = true),
      onExit: (_) => setState(() => _isHovered[title] = false),
      child: GestureDetector(
        onTap: () {
          context.go(route);
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 5, right: 20),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: _isHovered[title]! ? Colors.black12 : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.only(left: 5, top: 5),
            child: Row(
              children: [
                Icon(icon, color: iconColor),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: TextStyle(
                    color: iconColor,
                    fontSize: 16,
                    decoration: TextDecoration.none, // Remove underline
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  final FocusNode _focusNode = FocusNode();

  Future<void> addReturnMaster() async {
    final orderId = _controller.text.trim();
    print('Order ID: $orderId');

    // Step 1: Fetch all return master data to get invoice numbers
    final returnMasterUrl = '$apicall/return_master/get_all_returnmaster';

    final returnMasterResponse = await http.get(
      Uri.parse(returnMasterUrl),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    if (returnMasterResponse.statusCode == 200) {
      final returnData = jsonDecode(returnMasterResponse.body);
      print('Return Data: $returnData');
      // Step 2: Check if the entered orderId matches any invoice number
      bool isMatched =
          returnData.any((invoice) => invoice['invoiceNumber'] == orderId);
      if (isMatched) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('This Product Already Used Return Policy'),
          ),
        );
        // setState(() {
        //   _selectedReason = 'Reason for return';
        //   _reasonController.text = 'Reason for return';
        //   ContactpersonController.text ='';
        //   EmailAddressController.text ='';
        //   _controller.text = '';
        //   _orderDetails = [];
        //   totalController.text = '';
        //   widget.storeImages = []; // Clear the storeImages list
        //    widget.imageSizeStrings = [];
        // });
        return; // Exit the function if a match is found
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error fetching return master data'),
        ),
      );
      return; // Exit the function if there's an error fetching the return data
    }

    final apiUrl = '$apicall/return_master/add_return_master';

    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json'
    };

    List<Map<String, dynamic>> items = [];
    for (var item in _orderDetails) {
      if (item['enteredQty'] != null && item['enteredQty'] != 0) {
        String imageId = '';
        int index = widget.storeImages
            .map((e) => e.split('-').first)
            .toList()
            .indexOf(item['productName']);
        //int index = widget.storeImages.indexOf(item['productName']);
        if (index != -1) {
          imageId = widget.imageSizeString![index];
        }
        items.add({
          "category": item['category'],
          "creditRequest": item['totalAmount2'],
          "imageId": imageId,
          "invoiceAmount": item['totalAmount'],
          "price": item['price'],
          "productName": item['productName'],
          "qty": item['qty'],
          "returnQty": item['enteredQty'],
          "subCategory": item['subCategory'],
        });
      }
    }

    final requestBody = {
      "contactPerson": ContactpersonController.text,
      "email": EmailAddressController.text,
      "invoiceNumber": _controller.text,
      'returnDate': _dateController.text,
      "notes": NotesController.text,
      "reason": _selectedReason,
      "returnCredit": double.parse(totalController.text).toStringAsFixed(2),
      "items": items,
      "customerId": customerIdController.text,
      'contactNumber': ContactPerson.text,
      'orderId': OrderIDController.text,
      'shippingAddress': ShippingAddressController.text,
      "userId": "",
    };

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: headers,
      body: jsonEncode(requestBody),
    );

    if (response.statusCode == 200) {
      print('Return Master added successfully');
      final responseBody = jsonDecode(response.body);
      final returnId = responseBody['id'];

      await showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(5)),
            ),
            icon: const Icon(
              Icons.check_circle_rounded,
              color: Colors.green,
              size: 25,
            ),
            title: const Padding(
              padding: EdgeInsets.only(left: 12),
              child: Text(
                'Return Created Successfully',
                style: TextStyle(fontSize: 15),
              ),
            ),
            content: Padding(
                padding: const EdgeInsets.only(left: 25),
                child: Row(
                  children: [
                    const Text('Your return ID is: '),
                    SelectableText('$returnId'),
                  ],
                )),
            actions: <Widget>[
              ElevatedButton(
                child: const Text(
                  'OK',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () {
                  context.go('/Return_List');
                  // Navigator.of(context
                  //).pop(); // close the alert dialog
                  // Navigator.push(
                  //   context,
                  //   PageRouteBuilder(
                  //     pageBuilder: (context, animation, secondaryAnimation) =>
                  //     const Returnpage(),
                  //     transitionDuration: const Duration(milliseconds: 200),
                  //     transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  //       return FadeTransition(
                  //         opacity: animation,
                  //         child: child,
                  //       );
                  //     },
                  //   ),
                  // );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  side: const BorderSide(color: Colors.blue),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
            ],
          );
        },
      );
    } else {
      print('Error: ${response.statusCode}');
    }
  }

  Future<void> _fetchOrderDetails() async {
    final orderId = _controller.text.trim();

    // Step 1: Validate Order ID format
    if (!orderId.startsWith("INV_")) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Order ID must start with "INV_"'),
        ),
      );
      return;
    }

    print('Order ID: $orderId');

    try {
      // Step 2: Fetch data from APIs
      final returnMasterUrl = '$apicall/return_master/get_all_returnmaster';
      final returnMasterResponse = await http.get(
        Uri.parse(returnMasterUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      final orderMasterUrl = '$apicall/order_master/get_all_ordermaster';
      final orderMasterResponse = await http.get(
        Uri.parse(orderMasterUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (returnMasterResponse.statusCode == 200 &&
          orderMasterResponse.statusCode == 200) {
        final returnData = jsonDecode(returnMasterResponse.body);
        final orderData = jsonDecode(orderMasterResponse.body);

        // Step 3: Match conditions
        bool isMatchedReturn =
            returnData.any((invoice) => invoice['invoiceNumber'] == orderId);
        bool isMatchedInProgress = orderData.any((order) =>
            order['status'] == 'In Progress' && order['invoiceNo'] == orderId);
        bool isMatchedNotStarted = orderData.any((order) =>
            order['status'] == 'Not Started' && order['invoiceNo'] == orderId);

        if (isMatchedReturn) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('This Product Already Used Return Policy'),
            ),
          );
          setState(() {
            _orderDetails = [];
          });
          return;
        }

        if (isMatchedInProgress) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'This Product is In Progress So You Should Not Be Able to Return'),
            ),
          );
          setState(() {
            _orderDetails = [];
          });
          return;
        }

        if (isMatchedNotStarted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'This Order Delivery Status Is Not Started, So You Cannot Make a Return'),
            ),
          );
          setState(() {
            _orderDetails = [];
          });
          return;
        }

        // Step 4: Fetch delivery data if no matches found
        final deliveryUrl = '$apicall/delivery_master/get_all_deliverymaster';
        final deliveryResponse = await http.get(
          Uri.parse(deliveryUrl),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        );

        if (deliveryResponse.statusCode == 200) {
          final deliveryData = jsonDecode(deliveryResponse.body);
          final orderDetails = deliveryData.firstWhere(
            (order) => order['invoiceNo'] == orderId,
            orElse: () => null,
          );

          if (orderDetails != null) {
            setState(() {
              ContactPerson.text = orderDetails['contactNumber'];
              ShippingAddressController.text = orderDetails['comments'];
              OrderIDController.text = orderDetails['orderId'];
              customerIdController.text = orderDetails['customerId'];
              _orderDetails = orderDetails['items']
                  .map((item) => {
                        'productName': item['productName'],
                        'qty': item['qty'],
                        'totalAmount': item['totalAmount'],
                        'price': item['price'],
                        'category': item['category'],
                        'subCategory': item['subCategory'],
                      })
                  .toList();
            });
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Enter the Valid Invoice No'),
              ),
            );
            setState(() {
              _orderDetails = [];
            });
          }
        } else {
          throw Exception('Error fetching delivery data');
        }
      } else {
        throw Exception('Error fetching return or order master data');
      }
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error fetching order details, please try again'),
        ),
      );
      setState(() {
        _orderDetails = [
          {'productName': 'Error fetching order details'}
        ];
      });
    }
  }

  // old fecthorder
  // Future<void> _fetchOrderDetails() async {
  //   final orderId = _controller.text.trim();
  //   if (!orderId.startsWith("INV_")) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(
  //         content: Text('Order ID must start with "INV_"'),
  //       ),
  //     );
  //     return;
  //   }
  //
  //   print('Order ID: $orderId');
  //
  //   // Step 1: Fetch all return master data to get invoice numbers
  //   final returnMasterUrl = '$apicall/return_master/get_all_returnmaster';
  //
  //   final returnMasterResponse = await http.get(
  //     Uri.parse(returnMasterUrl),
  //     headers: {
  //       'Authorization': 'Bearer $token',
  //       'Content-Type': 'application/json',
  //     },
  //   );
  //
  //   final orderMasterUrl = '$apicall/order_master/get_all_ordermaster';
  //
  //   final orderMasterResponse =
  //       await http.get(Uri.parse(orderMasterUrl), headers: {
  //     'Authorization': 'Bearer $token',
  //     'Content-Type': 'application/json',
  //   });
  //
  //   if (orderMasterResponse.statusCode == 200) {
  //     final orderData = jsonDecode(orderMasterResponse.body);
  //     print('Order Data: $orderData');
  //
  //     bool isMatched2 = orderData.any((order) => order['invoiceNo'] == orderId);
  //
  //     if (returnMasterResponse.statusCode == 200) {
  //       final returnData = jsonDecode(returnMasterResponse.body);
  //       print('Return Data: $returnData');
  //
  //       // Step 2: Check if the entered orderId matches any invoice number
  //       bool isMatched =
  //           returnData.any((invoice) => invoice['invoiceNumber'] == orderId);
  //       final deliveryUrl = '$apicall/delivery_master/get_all_deliverymaster';
  //
  //       final deliveryMasterResponse = await http.get(
  //         Uri.parse(deliveryUrl),
  //         headers: {
  //           'Authorization': 'Bearer $token',
  //           'Content-Type': 'application/json',
  //         },
  //       );
  //       if (deliveryMasterResponse.statusCode == 200) {
  //         final returnData1 = jsonDecode(deliveryMasterResponse.body);
  //         print('Return Data: $returnData1');
  //
  //         // Step 2: Check if the entered orderId matches any invoice number
  //         bool isMatched1 = returnData1.any((invoice) =>
  //             invoice['status'] == 'In Progress' &&
  //             invoice['invoiceNo'] == orderId);
  //
  //         bool isMatched2 = orderData.any((invoice) =>
  //             invoice['status'] == 'Not Started' &&
  //             invoice['invoiceNo'] == orderId);
  //         print('details');
  //         print(isMatched);
  //         print(isMatched1);
  //
  //         if (isMatched) {
  //           ScaffoldMessenger.of(context).showSnackBar(
  //             const SnackBar(
  //               content: Text('This Product Already Used Return Policy'),
  //             ),
  //           );
  //           setState(() {
  //             _orderDetails = [];
  //           });
  //           return; // Exit the function if a match is found
  //         }
  //         if (isMatched1) {
  //           ScaffoldMessenger.of(context).showSnackBar(
  //             const SnackBar(
  //               content: Text(
  //                   'This Product is In Progress So You Should Not Able to Return'),
  //             ),
  //           );
  //           setState(() {
  //             _orderDetails = [];
  //           });
  //           return;
  //         }
  //         if (isMatched2) {
  //           ScaffoldMessenger.of(context).showSnackBar(
  //             const SnackBar(
  //               content: Text(
  //                   'This Order Delivery Status Is Not Started So You can\'t make a Return'),
  //             ),
  //           );
  //           setState(() {
  //             _orderDetails = [];
  //           });
  //           return;
  //         }
  //       }
  //     }
  //   } else {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(
  //         content: Text('Error fetching return master data'),
  //       ),
  //     );
  //     return; // Exit the function if there's an error fetching the return data
  //   }
  //
  //   // Step 3: Proceed with fetching order details if no match found
  //   final url = '$apicall/delivery_master/get_all_deliverymaster';
  //
  //   final response = await http.get(
  //     Uri.parse(url),
  //     headers: {
  //       'Authorization': 'Bearer $token',
  //       'Content-Type': 'application/json',
  //     },
  //   );
  //
  //   if (response.statusCode == 200) {
  //     final jsonData = jsonDecode(response.body);
  //     print('Response: $jsonData');
  //
  //     final orderData = jsonData.firstWhere(
  //       (order) => order['invoiceNo'] == orderId,
  //       orElse: () => null,
  //     );
  //     // final orderData = jsonData.firstWhere(
  //     //       (order) => order['deliveryId'] == orderId,
  //     //   orElse: () => null,
  //     // );
  //
  //     // final orderMaster = '$apicall/order_master/get_all_ordermaster';
  //     //
  //     // final orderMasterResponse = await http.get(Uri.parse(orderMaster),
  //     // headers: {
  //     //   'Authorization': 'Bearer $token',
  //     //   'Content-Type': 'application/json',
  //     // }
  //     // );
  //     //
  //     // if(orderMasterResponse.statusCode == 200){
  //     //
  //     // }
  //
  //     if (orderData != null) {
  //       setState(() {
  //         print('customerid');
  //         print(orderData['customerId']);
  //         print(orderData['tax']);
  //         print(orderData['contactNumber']);
  //         print(orderData['orderId']);
  //         print(orderData['comments']);
  //         print(orderData['discount']);
  //
  //         ContactPerson.text = orderData['contactNumber'];
  //         ShippingAddressController.text = orderData['comments'];
  //         OrderIDController.text = orderData['orderId'];
  //         // contactNumber
  //         // orderId
  //         // shippingAddress
  //         customerIdController.text = orderData['customerId'];
  //         print(customerIdController.text);
  //         _orderDetails = orderData['items']
  //             .map((item) => {
  //                   'productName': item['productName'],
  //                   'qty': item['qty'],
  //                   'totalAmount': item['totalAmount'],
  //                   'price': item['price'],
  //                   'category': item['category'],
  //                   'subCategory': item['subCategory'],
  //                 })
  //             .toList();
  //       });
  //     } else {
  //       setState(() {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           const SnackBar(
  //             content: Text('Enter the Valid Invoice No'),
  //           ),
  //         );
  //         _orderDetails = [
  //           {'productName': 'Order not found'}
  //         ];
  //       });
  //     }
  //   } else {
  //     setState(() {
  //       _orderDetails = [
  //         {'productName': 'Error fetching order details'}
  //       ];
  //     });
  //   }
  // }

  void _onFocusChange() {
    if (!_focusNode.hasFocus) {
      final orderId = _controller.text.trim();
      if (orderId.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter an Invoice No'),
          ),
        );
        return;
      }
      _isLoading = true;
      _fetchOrderDetails();
      _timer = Timer(const Duration(minutes: 2), () {
        setState(() {
          _isLoading = false;
        });
      });
    }
  }

  @override
  void dispose() {
    for (var controller in _qtyControllers) {
      controller.dispose();
    }
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _initializeControllers() {
    _qtyControllers.clear();
    _qtyControllers = List.generate(_orderDetails.length, (index) {
      return TextEditingController(
        text: (_orderDetails[index]['enteredQty'] ?? '').toString(),
      );
    });
  }

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);

    _dateController = TextEditingController();
    //_qtyControllers = List.generate(_orderDetails.length, (index) => TextEditingController());
    _initializeControllers();
    _selectedDate = DateTime.now();
    String formattedDate = DateFormat('dd/MM/yyyy').format(_selectedDate!);
    _dateController.text = formattedDate;

    print('----design');
    print(widget.orderDetailsMap);

    // Check if emailAddress is not null before trying to print it
    if (widget.orderDetailsMap['emailAddress'] != null) {
      print(widget.orderDetailsMap['emailAddress']);
    }

    print('Order Details:');
    if (widget.orderDetailsMap['reason'] != null) {
      print(widget.orderDetailsMap['reason']);
    }

    if (_reasonController.text.isEmpty) {
      _reasonController.text = 'Reason for return';
    }

    if (widget.storeImage == 'hi') {
      print('bfore');
      print(_selectedReason);
      print(widget.imageSizeString);

      // Check if emailAddress is not null before trying to assign it to EmailAddressController
      if (widget.orderDetailsMap['emailAddress'] != null) {
        EmailAddressController.text = widget.orderDetailsMap['emailAddress'];
      }
      if (widget.orderDetailsMap['customerId'] != null) {
        customerIdController.text = widget.orderDetailsMap['customerId'];
      }

      if (widget.orderDetailsMap['contactPerson'] != null) {
        ContactpersonController.text = widget.orderDetailsMap['contactPerson'];
      }

      if (widget.orderDetailsMap['reason'] != null) {
        _selectedReason = widget.orderDetailsMap['reason'];
      }

      print('after');
      print(_selectedReason);

      if (widget.orderDetailsMap['otherField'] != null) {
        _controller.text = widget.orderDetailsMap['otherField'];
      }

      if (widget.orderDetailsMap['orderDetails'] != null) {
        _orderDetails = widget.orderDetailsMap['orderDetails'];
      }

      if (widget.orderDetailsMap['totalAmount2'] != null) {
        totalController.text = widget.orderDetailsMap['totalAmount2'];
      }

      if (widget.orderDetailsMap['notes'] != null) {
        NotesController.text = widget.orderDetailsMap['notes'];
      }
      if (widget.orderDetailsMap['orderId'] != null) {
        OrderIDController.text = widget.orderDetailsMap['orderId'];
      }
      if (widget.orderDetailsMap['shipAddres'] != null) {
        ShippingAddressController.text = widget.orderDetailsMap['shipAddres'];
      }
      if (widget.orderDetailsMap['ContactNumber'] != null) {
        ContactPerson.text = widget.orderDetailsMap['ContactNumber'];
      }

      print('Order Details:');
      if (_orderDetails != null) {
        for (var item in _orderDetails) {
          print('Product Name: ${item['productName']}');
          print('Quantity: ${item['qty']}');
          print('Price: ${item['price']}');
          print('Category: ${item['category']}');
          print('Sub Category: ${item['subCategory']}');
          print('Entered Qty: ${item['enteredQty']}');
          print('Total Amount: ${item['totalAmount']}');
          item['enteredQty'] == _textController.text;
          print('---'); // separator
          print('enteredqty');
          print(_textController.text);
          print(item['enteredQty']);
          //    _textController.text = item['enteredQty'].toString();
        }
      }

      print('--dropdown value');
      print(widget.imageSizeString);
      print(widget.imageSizeStrings);
      print(widget.storeImages);
    }

    _controller.addListener(() {
      if (_controller.text.isEmpty || _controller.text.length != 10) {
        setState(() {
          //    _isEditing = false;
          _selectedReason = 'Reason for return';
          ContactpersonController.clear();
          EmailAddressController.clear();
          totalController.clear();
          NotesController.clear();
          _orderDetails = [];
          widget.storeImages = []; // Clear the storeImages list
          widget.imageSizeStrings = [];
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_qtyControllers.length != _orderDetails.length) {
      _initializeControllers();
    }
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: null,
        backgroundColor: const Color(0xFFFFFFFF),
        title: Image.asset("images/Final-Ikyam-Logo.png"),
        // Set background color to white
        elevation: 2.0,
        shadowColor: const Color(0xFFFFFFFF),
        // Set shadow color to black
        actions: [
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Align(
              alignment: Alignment.topLeft,
              child: IconButton(
                icon: const Icon(Icons.notifications),
                onPressed: () {
                  // Handle notification icon press
                },
              ),
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: AccountMenu(),
          ),
        ],
      ),
      body: LayoutBuilder(builder: (context, constraints) {
        double maxWidth = constraints.maxWidth;
        return Stack(
          //   crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if(constraints.maxHeight <= 500)...{
              SingleChildScrollView(
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Container(
                    width: 200,
                    color: const Color(0xFFF7F6FA),
                    padding: const EdgeInsets.only(left: 15, top: 10,right: 15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: _buildMenuItems(context),
                    ),
                  ),
                ),
              )

            }
            else...{
              Align(
                alignment: Alignment.topLeft,
                child: Container(
                  width: 200,
                  color: const Color(0xFFF7F6FA),
                  padding: const EdgeInsets.only(left: 15, top: 10,right: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _buildMenuItems(context),
                  ),
                ),
              ),
            },
            Padding(
              padding: const EdgeInsets.only(left: 200, top: 0),
              child: Container(
                width: 1, // Set the width to 1 for a vertical line
                height: 900, // Set the height to your liking
                decoration: const BoxDecoration(
                  border:
                      Border(left: BorderSide(width: 1, color: Colors.grey)),
                ),
              ),
            ),
            Positioned(
                left: 202,
                right: 0,
                top: 0,
                bottom: 0,
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      color: Colors.white,
                      height: 50,
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back),
                            // Back button icon
                            onPressed: () {
                              // context.go('/Create_return/Return_List');
                              context.go('/Return_List');
                            },
                          ),
                          const Padding(
                            padding: EdgeInsets.only(left: 30, top: 5),
                            child: Text(
                              'Order Return',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const Spacer(),
                          Align(
                            alignment: Alignment.topRight,
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(top: 10, right: 90),
                              child: OutlinedButton(
                                onPressed: () async {
                                  if (_controller.text.isEmpty &&
                                      ContactpersonController.text.isEmpty &&
                                      EmailAddressController.text.isEmpty &&
                                      _selectedReason == 'Reason for return' &&
                                      totalController.text.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            'Please fill all required fields'),
                                        //  backgroundColor: Colors.red,
                                      ),
                                    );
                                  } else if (_controller.text.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content:
                                            Text('Please fill Invoice Number'),
                                        //  backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                  else if(_orderDetails.isEmpty)
                                    {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content:
                                          Text('Enter Valid  Invoice Number'),
                                          //  backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  else if (!_orderDetails.any((item) =>
                                          item['qty'] > 0 &&
                                          _qtyControllers[
                                                  _orderDetails.indexOf(item)]
                                              .text
                                              .isNotEmpty) ||
                                      _orderDetails.any((item) =>
                                          item['qty'] == 0 &&
                                          _qtyControllers[
                                                  _orderDetails.indexOf(item)]
                                              .text
                                              .isNotEmpty)) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Please Enter Valid Qty'),
                                        //  backgroundColor: Colors.red,
                                      ),
                                    );
                                  }

                                  else if (_selectedReason == null ||
                                      _selectedReason!.isEmpty ||
                                      _selectedReason == 'Reason for return') {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content:
                                            Text('Please Enter Return Reason'),
                                        //  backgroundColor: Colors.red,
                                      ),
                                    );
                                  } else if (ContactpersonController
                                      .text.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            'Please fill Contact Person Name'),
                                        //  backgroundColor: Colors.red,
                                      ),
                                    );
                                  } else if (EmailAddressController
                                          .text.isEmpty ||
                                      !RegExp(r'^[\w-]+(\.[\w-]+)*@[a-zA-Z0-9-]+\.(com|in|net)$')
                                          .hasMatch(
                                              EmailAddressController.text)) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            'Please fill Email Address Format .com/.in/.net'),
                                      ),
                                    );
                                  } else if (totalController.text.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content:
                                            Text('Please Enter Return Qty'),
                                        //  backgroundColor: Colors.red,
                                      ),
                                    );
                                  } else {
                                    await addReturnMaster();
                                  }
                                },
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: Colors.blue[800],
                                  // Button background color
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        5), // Rounded corners
                                  ),
                                  side: BorderSide.none, // No outline
                                ),
                                child: const Text(
                                  'Create Return',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w100,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 1),
                      // Space above/below the border
                      height: 0.3, // Border height
                      color: Colors.black, // Border color
                    ),
                    if (constraints.maxWidth >= 1350) ...{
                      Expanded(
                          child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(right: 100),
                                child: SizedBox(
                                  width: maxWidth,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    // mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(
                                            right: maxWidth * 0.08,
                                            //   * 0.089,
                                            top: 20),
                                        child: Text(
                                          'Return Date',
                                          style: TextStyle(
                                              fontSize: maxWidth * 0.0090),
                                        ),
                                      ),
                                      DecoratedBox(
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              color: const Color(0xFFEBF3FF),
                                              width: 1),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: SizedBox(
                                          height: 39,
                                          width: maxWidth * 0.13,
                                          child: Column(
                                            children: [
                                              Expanded(
                                                child: TextFormField(
                                                  controller: _dateController,
                                                  // Replace with your TextEditingController
                                                  readOnly: true,
                                                  decoration: InputDecoration(
                                                    suffixIcon: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              right: 20),
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                top: 2,
                                                                left: 10),
                                                        child: IconButton(
                                                          icon: const Padding(
                                                            padding:
                                                                EdgeInsets.only(
                                                                    bottom: 16),
                                                            child: Icon(Icons
                                                                .calendar_month),
                                                          ),
                                                          iconSize: 20,
                                                          onPressed: () {
                                                            // _showDatePicker(context);
                                                          },
                                                        ),
                                                      ),
                                                    ),
                                                    hintText: 'Select Date',
                                                    fillColor: Colors.white,
                                                    contentPadding:
                                                        const EdgeInsets
                                                            .symmetric(
                                                            horizontal: 8,
                                                            vertical: 8),
                                                    border: InputBorder.none,
                                                    filled: true,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      // SizedBox(height: 20.h),
                                    ],
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 50, right: 100, top: 30),
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Color(0xff00000029),
                                        offset: Offset(0, 3),
                                        blurRadius: 6,
                                      ),
                                    ],
                                    color: const Color(0xFFFFFFFF),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  const Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Text('Invoice Number'),
                                                      SizedBox(
                                                        width: 5,
                                                      ),
                                                      Text(
                                                        '*',
                                                        style: TextStyle(
                                                            color: Colors.red),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(
                                                    height: 5,
                                                  ),
                                                  SizedBox(
                                                    height: 40,
                                                    child: TextFormField(
                                                      controller: _controller,
                                                      focusNode: _focusNode,
                                                      // onEditingComplete: _fetchOrderDetails,
                                                      decoration:
                                                          InputDecoration(
                                                              filled: true,
                                                              contentPadding:
                                                                  const EdgeInsets.symmetric(
                                                                      vertical:
                                                                          10,
                                                                      horizontal:
                                                                          12),
                                                              fillColor: Colors
                                                                  .grey
                                                                  .shade200,
                                                              border:
                                                                  OutlineInputBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            5.0),
                                                                borderSide:
                                                                    BorderSide
                                                                        .none,
                                                              ),
                                                              hintText:
                                                                  'INV_03312'),
                                                      inputFormatters: [
                                                        UpperCaseTextFormatter(),
                                                        FilteringTextInputFormatter
                                                            .allow(RegExp(
                                                                "[a-zA-Z_0-9]")),
                                                        // Allow only letters, numbers, and single space
                                                        FilteringTextInputFormatter
                                                            .deny(
                                                                RegExp(r'^\s')),
                                                        // Disallow starting with a space
                                                        FilteringTextInputFormatter
                                                            .deny(RegExp(
                                                                r'\s\s')),
                                                        // Disallow multiple spaces
                                                      ],
                                                      validator: (value) {
                                                        if (_controller.text !=
                                                                null &&
                                                            _controller.text
                                                                .trim()
                                                                .isEmpty) {
                                                          return 'Please enter a product name';
                                                        }
                                                        return null;
                                                      },
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  const Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Text('Reason'),
                                                      SizedBox(
                                                        width: 5,
                                                      ),
                                                      Text(
                                                        '*',
                                                        style: TextStyle(
                                                            color: Colors.red),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(
                                                    height: 5,
                                                  ),
                                                  SizedBox(
                                                    height: 40,
                                                    child:
                                                        DropdownButtonFormField<
                                                            String>(
                                                      decoration:
                                                          InputDecoration(
                                                        filled: true,
                                                        fillColor: Colors
                                                            .grey.shade200,
                                                        border:
                                                            OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      5.0),
                                                          borderSide: BorderSide
                                                              .none, // Remove border by setting borderSide to BorderSide.none
                                                        ),
                                                        contentPadding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                horizontal: 8,
                                                                vertical: 8),
                                                      ),
                                                      value: _selectedReason,
                                                      onChanged:
                                                          (String? value) {
                                                        setState(() {
                                                          _selectedReason =
                                                              value!;
                                                          _reasonController
                                                              .text = value;
                                                        });
                                                      },
                                                      items: <String>[
                                                        'Reason for return',
                                                        'Option 1',
                                                        'Option 2'
                                                      ].map<
                                                              DropdownMenuItem<
                                                                  String>>(
                                                          (String value) {
                                                        return DropdownMenuItem<
                                                            String>(
                                                          value: value,
                                                          child: Text(
                                                            value,
                                                            style: TextStyle(
                                                              color: value ==
                                                                      'Reason for return'
                                                                  ? Colors.grey
                                                                  : Colors
                                                                      .black,
                                                            ),
                                                          ),
                                                        );
                                                      }).toList(),
                                                      isExpanded: true,
                                                      //     hint: const Text('Reason for return'),
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  const Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Text('Contact Person'),
                                                      SizedBox(
                                                        width: 5,
                                                      ),
                                                      Text(
                                                        '*',
                                                        style: TextStyle(
                                                            color: Colors.red),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(
                                                    height: 5,
                                                  ),
                                                  SizedBox(
                                                    height: 40,
                                                    child: TextFormField(
                                                      controller:
                                                          ContactpersonController,
                                                      decoration:
                                                          InputDecoration(
                                                              filled: true,
                                                              fillColor: Colors
                                                                  .grey
                                                                  .shade200,
                                                              border:
                                                                  OutlineInputBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            5.0),
                                                                borderSide:
                                                                    BorderSide
                                                                        .none,
                                                              ),
                                                              contentPadding:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                      vertical:
                                                                          10,
                                                                      horizontal:
                                                                          12),
                                                              hintText:
                                                                  'Person Name'),
                                                      inputFormatters: [
                                                        FilteringTextInputFormatter
                                                            .allow(RegExp(
                                                                "[a-zA-Z ]")),
                                                        // Allow only letters, numbers, and single space
                                                        FilteringTextInputFormatter
                                                            .deny(
                                                                RegExp(r'^\s')),
                                                        // Disallow starting with a space
                                                        FilteringTextInputFormatter
                                                            .deny(RegExp(
                                                                r'\s\s')),
                                                        // Disallow multiple spaces
                                                      ],
                                                      validator: (value) {
                                                        if (ContactpersonController
                                                                    .text !=
                                                                null &&
                                                            ContactpersonController
                                                                .text
                                                                .trim()
                                                                .isEmpty) {
                                                          return 'Please enter a product name';
                                                        }
                                                        return null;
                                                      },
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  const Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Text('Email'),
                                                      SizedBox(
                                                        width: 5,
                                                      ),
                                                      Text(
                                                        '*',
                                                        style: TextStyle(
                                                            color: Colors.red),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(
                                                    height: 5,
                                                  ),
                                                  SizedBox(
                                                    height: 40,
                                                    child: TextFormField(
                                                      controller:
                                                          EmailAddressController,
                                                      decoration:
                                                          InputDecoration(
                                                        filled: true,
                                                        fillColor: Colors
                                                            .grey.shade200,
                                                        border:
                                                            OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      5.0),
                                                          borderSide:
                                                              BorderSide.none,
                                                        ),
                                                        contentPadding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                vertical: 10,
                                                                horizontal: 12),
                                                        hintText:
                                                            'Person Email',
                                                        // errorText: _errorText,
                                                      ),
                                                      inputFormatters: [
                                                        FilteringTextInputFormatter
                                                            .allow(RegExp(
                                                                "[a-zA-Z,0-9,@.]")),
                                                        FilteringTextInputFormatter
                                                            .deny(
                                                                RegExp(r'^\s')),
                                                        FilteringTextInputFormatter
                                                            .deny(RegExp(
                                                                r'\s\s')),
                                                      ],
                                                      // inputFormatters: [
                                                      //   FilteringTextInputFormatter.allow(
                                                      //       RegExp("[a-zA-Z,0-9,@.]")),
                                                      //   // Allow only letters, numbers, and single space
                                                      //   FilteringTextInputFormatter.deny(
                                                      //       RegExp(r'^\s')),
                                                      //   // Disallow starting with a space
                                                      //   FilteringTextInputFormatter.deny(
                                                      //       RegExp(r'\s\s')),
                                                      //   // Disallow multiple spaces
                                                      // ],
                                                      // validator: (value) {
                                                      //    if (value!.isEmpty) {
                                                      //        return 'Please enter an email address';
                                                      //      } else if (!RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$,0-9,@.').hasMatch(value)) {
                                                      //        return 'Invalid email address format. Please use the format "username@example.com"';
                                                      //      }
                                                      //    return null;
                                                      //  },
                                                      validator: (value) {
                                                        setState(() {
                                                          if (value!.isEmpty) {
                                                            _errorText =
                                                                'Please enter Valid email address';
                                                          } else if (!RegExp(
                                                                  r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$')
                                                              .hasMatch(
                                                                  value)) {
                                                            _errorText =
                                                                'Please enter valid email address';
                                                          } else {
                                                            _errorText = null;
                                                          }
                                                        });
                                                        if (_errorText !=
                                                            null) {
                                                          ScaffoldMessenger.of(
                                                                  context)
                                                              .showSnackBar(
                                                            SnackBar(
                                                                content: Text(
                                                                    _errorText!)),
                                                          );
                                                        }
                                                        return null;
                                                      },
                                                      // validator: (value) {
                                                      //   if (value!.isEmpty) {
                                                      //     return 'Please enter an email address';
                                                      //   } else if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(value)) {
                                                      //     if (!value.contains('@')) {
                                                      //       return 'Email address should contain "@" symbol';
                                                      //     } else if (!value.contains('.')) {
                                                      //       return 'Email address should contain a valid domain (e.g. .com, .net, etc.)';
                                                      //     } else {
                                                      //       return 'Invalid email address format. Please use the format "username@example.com"';
                                                      //     }
                                                      //   }
                                                      //   return null;
                                                      // },
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 50, right: 100, top: 30),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFFFFF),
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Color(0xFF00000029),
                                        offset: Offset(0, 3),
                                        blurRadius: 6,
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Padding(
                                        padding:
                                            EdgeInsets.only(top: 10, left: 30),
                                        child: Text(
                                          'Add Products',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                            fontFamily: 'Titillium Web',
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Container(
                                        width: maxWidth,
                                        decoration: const BoxDecoration(
                                          border: Border(
                                            top: BorderSide(
                                                color: Color(0xFFB2C2D3),
                                                width: 1.2),
                                            bottom: BorderSide(
                                                color: Color(0xFFB2C2D3),
                                                width: 1.2),
                                          ),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              top: 5, bottom: 5),
                                          child: Table(
                                            columnWidths: const {
                                              0: FlexColumnWidth(1),
                                              1: FlexColumnWidth(3),
                                              2: FlexColumnWidth(2),
                                              3: FlexColumnWidth(2),
                                              4: FlexColumnWidth(2),
                                              5: FlexColumnWidth(1),
                                              6: FlexColumnWidth(1.2),
                                              7: FlexColumnWidth(2),
                                              8: FlexColumnWidth(2),
                                            },
                                            children: const [
                                              TableRow(children: [
                                                TableCell(
                                                  child: Padding(
                                                    padding: EdgeInsets.only(
                                                        top: 10, bottom: 10),
                                                    child: Center(
                                                      child: Text(
                                                        "SN",
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          //  fontSize: 12,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                TableCell(
                                                  child: Padding(
                                                    padding: EdgeInsets.only(
                                                        top: 10, bottom: 10),
                                                    child: Center(
                                                      child: Text(
                                                        'Product Name',
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          //  fontSize: 12,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                TableCell(
                                                  child: Padding(
                                                    padding: EdgeInsets.only(
                                                        top: 10, bottom: 10),
                                                    child: Center(
                                                      child: Text(
                                                        "Category",
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          // fontSize: 12,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                TableCell(
                                                  child: Padding(
                                                    padding: EdgeInsets.only(
                                                        top: 10, bottom: 10),
                                                    child: Center(
                                                      child: Text(
                                                        "Sub Category",
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          // fontSize: 12,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                TableCell(
                                                  child: Padding(
                                                    padding: EdgeInsets.only(
                                                        top: 10, bottom: 10),
                                                    child: Center(
                                                      child: Text(
                                                        "Price",
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          // fontSize: 12,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                TableCell(
                                                  child: Padding(
                                                    padding: EdgeInsets.only(
                                                        top: 10, bottom: 10),
                                                    child: Center(
                                                      child: Text(
                                                        "QTY",
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          // fontSize: 12,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                TableCell(
                                                  child: Padding(
                                                    padding: EdgeInsets.only(
                                                        top: 10, bottom: 10),
                                                    child: Center(
                                                      child: Text(
                                                        "Return QTY",
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          //  fontSize: 12,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                TableCell(
                                                  child: Padding(
                                                    padding: EdgeInsets.only(
                                                        top: 10, bottom: 10),
                                                    child: Center(
                                                      child: Text(
                                                        "Invoice Amount",
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          //  fontSize: 12,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                TableCell(
                                                  child: Padding(
                                                    padding: EdgeInsets.only(
                                                        top: 10, bottom: 10),
                                                    child: Center(
                                                      child: Text(
                                                        "Credit Request",
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          // fontSize: 12,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ])
                                            ],
                                          ),
                                        ),
                                      ),
                                      ListView.builder(
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        itemCount: _orderDetails.length,
                                        itemBuilder: (context, index) {
                                          if (index >= _orderDetails.length ||
                                              index >= _qtyControllers.length) {
                                            return const SizedBox
                                                .shrink(); // Return an empty widget if the index is out of range
                                          }
                                          Map<String, dynamic> item =
                                              _orderDetails[index];
                                          return Table(
                                            border: const TableBorder(
                                              bottom: BorderSide(
                                                  width: 1, color: Colors.grey),
                                              //   horizontalInside: BorderSide(width: 1,color: Colors.grey), // horizontal border inside the table
                                              verticalInside: BorderSide(
                                                  width: 1, color: Colors.grey),
                                            ),
                                            // border: TableBorder.all(color: Colors.blue),
                                            //  Color(0xFFFFFFFF)
                                            columnWidths: const {
                                              0: FlexColumnWidth(1),
                                              1: FlexColumnWidth(3),
                                              2: FlexColumnWidth(2),
                                              3: FlexColumnWidth(2),
                                              4: FlexColumnWidth(2),
                                              5: FlexColumnWidth(1),
                                              6: FlexColumnWidth(1.2),
                                              7: FlexColumnWidth(2),
                                              8: FlexColumnWidth(2),
                                            },

                                            children: [
                                              TableRow(children: [
                                                TableCell(
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 10,
                                                            right: 10,
                                                            top: 15,
                                                            bottom: 5),
                                                    child: Center(
                                                        child: Text(
                                                            '${index + 1}')),
                                                  ),
                                                ),
                                                TableCell(
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 10,
                                                            right: 10,
                                                            top: 10,
                                                            bottom: 10),
                                                    child: Container(
                                                      height: 35,
                                                      width: 50,
                                                      decoration: BoxDecoration(
                                                        color: Colors
                                                            .grey.shade200,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(4.0),
                                                      ),
                                                      child: Center(
                                                          child: Text(
                                                        item['productName'],
                                                        textAlign:
                                                            TextAlign.center,
                                                      )),
                                                    ),
                                                  ),
                                                ),
                                                TableCell(
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 10,
                                                            right: 10,
                                                            top: 10,
                                                            bottom: 10),
                                                    child: Container(
                                                      height: 35,
                                                      width: 50,
                                                      decoration: BoxDecoration(
                                                        color: Colors
                                                            .grey.shade200,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(4.0),
                                                      ),
                                                      child: Center(
                                                          child: Text(
                                                        item['category'],
                                                        textAlign:
                                                            TextAlign.center,
                                                      )),
                                                    ),
                                                  ),
                                                ),
                                                TableCell(
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 10,
                                                            right: 10,
                                                            top: 10,
                                                            bottom: 10),
                                                    child: Container(
                                                      height: 35,
                                                      width: 50,
                                                      decoration: BoxDecoration(
                                                        color: Colors
                                                            .grey.shade200,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(4.0),
                                                      ),
                                                      child: Center(
                                                          child: Text(item[
                                                              'subCategory'])),
                                                    ),
                                                  ),
                                                ),

                                                TableCell(
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 10,
                                                            right: 10,
                                                            top: 10,
                                                            bottom: 10),
                                                    child: Container(
                                                      height: 35,
                                                      width: 50,
                                                      decoration: BoxDecoration(
                                                        color: Colors
                                                            .grey.shade200,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(4.0),
                                                      ),
                                                      child: Center(
                                                          child: Text(
                                                              item['price']
                                                                  .toString())),
                                                    ),
                                                  ),
                                                ),
                                                TableCell(
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 10,
                                                            right: 10,
                                                            top: 10,
                                                            bottom: 10),
                                                    child: Container(
                                                      height: 35,
                                                      width: 50,
                                                      decoration: BoxDecoration(
                                                        color: Colors
                                                            .grey.shade200,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(4.0),
                                                      ),
                                                      child: Center(
                                                          child: Text(
                                                              item['qty']
                                                                  .toString())),
                                                    ),
                                                  ),
                                                ),
                                                TableCell(
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 10,
                                                            right: 10,
                                                            top: 10,
                                                            bottom: 10),
                                                    child: Container(
                                                      height: 35,
                                                      width: 50,
                                                      decoration: BoxDecoration(
                                                        color: Colors
                                                            .grey.shade200,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(4.0),
                                                      ),
                                                      child: Center(
                                                        child: TextFormField(
                                                          controller:
                                                              _qtyControllers[
                                                                  index],
                                                          // controller: _qtyControllers[index],
                                                          //controller: _textController[item],
                                                          // controller: TextEditingController.fromValue(TextEditingValue(
                                                          //   text: (item['enteredQty']?? '').toString(),
                                                          //   selection: TextSelection.collapsed(offset: (item['enteredQty']?? '').toString().length),
                                                          // )),
                                                          textAlign:
                                                              TextAlign.center,
                                                          // Center alignment
                                                          decoration:
                                                              const InputDecoration(
                                                                  border:
                                                                      InputBorder
                                                                          .none,
                                                                  // Remove underline
                                                                  contentPadding:
                                                                      EdgeInsets.only(
                                                                          bottom:
                                                                              12)
                                                                  //contentPadding: EdgeInsets.symmetric(vertical: 5,horizontal: 8) // Set content padding
                                                                  ),
                                                          inputFormatters: [
                                                            LengthLimitingTextInputFormatter(
                                                                4),
                                                            FilteringTextInputFormatter
                                                                .allow(RegExp(
                                                                    "[0-9]")),
                                                            // Allow only letters, numbers, and single space
                                                            FilteringTextInputFormatter
                                                                .deny(RegExp(
                                                                    r'^\s')),
                                                            // Disallow starting with a space
                                                            FilteringTextInputFormatter
                                                                .deny(RegExp(
                                                                    r'\s\s')),
                                                            // Disallow multiple spaces
                                                          ],
                                                          onChanged: (value) {
                                                            setState(() {
                                                              if (value
                                                                  .isEmpty) {
                                                                item['enteredQty'] =
                                                                    0;
                                                                item['totalAmount2'] =
                                                                    0;
                                                                _qtyControllers[
                                                                        index]
                                                                    .clear();
                                                              } else {
                                                                int enteredQty =
                                                                    int.parse(
                                                                        value);

                                                                if (enteredQty >
                                                                        (item['qty'] ??
                                                                            0) ||
                                                                    enteredQty ==
                                                                        0) {
                                                                  //  if (enteredQty > (item['qty']?? 0) || (item['qty'] == 0)) {
                                                                  ScaffoldMessenger.of(
                                                                          context)
                                                                      .showSnackBar(
                                                                    const SnackBar(
                                                                        content:
                                                                            Text('Return qty must be less than or equal to the order qty.')),
                                                                  );
                                                                  // Clear the entered value
                                                                  item['enteredQty'] =
                                                                      0;
                                                                  _qtyControllers[
                                                                          index]
                                                                      .clear();
                                                                  //  _textController.clear(); // Clear the text field
                                                                } else {
                                                                  item['enteredQty'] =
                                                                      enteredQty;
                                                                  item[
                                                                      'totalAmount2'] = (item[
                                                                              'totalAmount'] /
                                                                          item[
                                                                              'qty']) *
                                                                      enteredQty;
                                                                }
                                                              }
                                                              // calculate the total amount
                                                              totalAmount = _orderDetails.fold(
                                                                  0.0,
                                                                  (sum, item) =>
                                                                      sum +
                                                                      (item['totalAmount2'] ??
                                                                          0));
                                                              totalController
                                                                      .text =
                                                                  totalAmount
                                                                      .toStringAsFixed(
                                                                          2); // update the totalController
                                                              print(
                                                                  'enteredqty');
                                                              print(
                                                                  _qtyControllers[
                                                                          index]
                                                                      .text);
                                                              print(item[
                                                                  'enteredQty']);
                                                              print(
                                                                  _qtyControllers[
                                                                          index]
                                                                      .text);
                                                            });
                                                          },
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                // TableCell(
                                                //   child: Padding(
                                                //     padding: const EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10),
                                                //     child: Container(
                                                //       height: 35,
                                                //       width: 50,
                                                //       decoration: BoxDecoration(
                                                //         color: Colors.grey.shade200,
                                                //         borderRadius: BorderRadius.circular(4.0),
                                                //       ),
                                                //       child: Center(
                                                //         child: TextFormField(
                                                //           initialValue: (item['enteredQty']?? '').toString(),
                                                //           textAlign: TextAlign.center, // Center alignment
                                                //           decoration: const InputDecoration(
                                                //               border: InputBorder.none, // Remove underline
                                                //               contentPadding: EdgeInsets.only(
                                                //                   bottom: 12
                                                //               )
                                                //               //contentPadding: EdgeInsets.symmetric(vertical: 5,horizontal: 8) // Set content padding
                                                //           ),
                                                //           inputFormatters: [
                                                //             LengthLimitingTextInputFormatter(4),
                                                //             FilteringTextInputFormatter.allow(
                                                //                 RegExp("[0-9]")),
                                                //             // Allow only letters, numbers, and single space
                                                //             FilteringTextInputFormatter.deny(
                                                //                 RegExp(r'^\s')),
                                                //             // Disallow starting with a space
                                                //             FilteringTextInputFormatter.deny(
                                                //                 RegExp(r'\s\s')),
                                                //             // Disallow multiple spaces
                                                //           ],
                                                //           onChanged: (value) {
                                                //             setState(() {
                                                //               if (value.isEmpty) {
                                                //                 item['enteredQty'] = 0;
                                                //                 item['totalAmount2'] = 0;
                                                //               } else {
                                                //                 item['enteredQty'] = int.parse(value);
                                                //                 if (item['enteredQty'] > (item['qty']?? 0)) {
                                                //                   ScaffoldMessenger.of(context).showSnackBar(
                                                //                     const SnackBar(content: Text('Return qty must be less than or equal to the order qty.')),
                                                //                   );
                                                //                 } else {
                                                //                   item['totalAmount2'] = item['price'] * item['enteredQty'];
                                                //                 }
                                                //               }
                                                //               // calculate the total amount
                                                //               totalAmount = _orderDetails.fold(0.0, (sum, item) => sum + (item['totalAmount2']?? 0));
                                                //               totalController.text = totalAmount.toStringAsFixed(2); // update the totalController
                                                //               print('enteredqty');
                                                //               print(item['enteredQty']);
                                                //             });
                                                //           },
                                                //         ),
                                                //       ),
                                                //     ),
                                                //   ),
                                                // ),
                                                TableCell(
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 10,
                                                            right: 10,
                                                            top: 10,
                                                            bottom: 10),
                                                    child: Container(
                                                      height: 35,
                                                      width: 50,
                                                      decoration: BoxDecoration(
                                                        color: Colors
                                                            .grey.shade200,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(4.0),
                                                      ),
                                                      child: Center(
                                                          child: Text(item[
                                                                  'totalAmount']
                                                              .toString())),
                                                    ),
                                                  ),
                                                ),
                                                TableCell(
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 10,
                                                            right: 10,
                                                            top: 10,
                                                            bottom: 10),
                                                    child: Container(
                                                      height: 35,
                                                      width: 50,
                                                      decoration: BoxDecoration(
                                                        color: Colors
                                                            .grey.shade200,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(4.0),
                                                      ),
                                                      child: Center(
                                                        child: Text(item[
                                                                    'totalAmount2'] !=
                                                                null
                                                            ? item['totalAmount2']
                                                                .toString()
                                                            : '0'),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ])
                                            ],
                                          );
                                        },
                                      ),
                                      const SizedBox(height: 8),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            right: 25, top: 5, bottom: 5),
                                        child: Align(
                                          alignment: Alignment.centerRight,
                                          child: Container(
                                            height: 40,
                                            padding: const EdgeInsets.only(
                                                left: 15,
                                                right: 10,
                                                top: 6,
                                                bottom: 2),
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                  color:
                                                      const Color(0xFF0277BD)),
                                              borderRadius:
                                                  BorderRadius.circular(2.0),
                                              color: Colors.white,
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  bottom: 2),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  RichText(
                                                    text: TextSpan(
                                                      children: [
                                                        const TextSpan(
                                                          text: 'Total Credit',
                                                          style: TextStyle(
                                                              fontSize: 14,
                                                              color: Colors.blue
                                                              // fontWeight: FontWeight.bold,
                                                              ),
                                                        ),
                                                        const TextSpan(
                                                          text: '  ₹',
                                                          style: TextStyle(
                                                            color: Colors.black,
                                                          ),
                                                        ),
                                                        TextSpan(
                                                          text: totalController
                                                              .text,
                                                          style:
                                                              const TextStyle(
                                                            color: Colors.black,
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 50, right: 100, top: 30),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFFFFF),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Color(0xFF00000029),
                                        offset: Offset(0, 3),
                                        blurRadius: 6,
                                      ),
                                    ],
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          const Padding(
                                            padding: EdgeInsets.only(left: 30),
                                            child: Text(
                                              'Image Upload',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                                fontFamily: 'Titillium Web',
                                              ),
                                            ),
                                          ),
                                          const Spacer(),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                right: 30),
                                            child: Padding(
                                              padding: EdgeInsets.only(
                                                  left: maxWidth * 0.15),
                                              child: OutlinedButton.icon(
                                                icon: const Icon(
                                                  Icons.upload,
                                                  color: Colors.white,
                                                  size: 18,
                                                ),
                                                label: const Text(
                                                  'Upload',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                onPressed: () {
                                                  if (_controller
                                                      .text.isNotEmpty) {
                                                    Map<String, dynamic>
                                                        orderDetailsMap = {
                                                      'emailAddress':
                                                          EmailAddressController
                                                              .text,
                                                      'contactPerson':
                                                          ContactpersonController
                                                              .text,
                                                      'reason': _selectedReason,
                                                      'otherField':
                                                          _controller.text,
                                                      'orderDetails':
                                                          _orderDetails,
                                                      'totalAmount2':
                                                          totalController.text,
                                                      'notes':
                                                          NotesController.text,
                                                      'customerId':
                                                          customerIdController
                                                              .text,
                                                      'orderId':
                                                          OrderIDController
                                                              .text,
                                                      'shipAddres':
                                                          ShippingAddressController
                                                              .text,
                                                      'ContactNumber':
                                                          ContactPerson.text,
                                                    };
                                                    print(
                                                        'return design module file');
                                                    print(orderDetailsMap);
                                                    print(_orderDetails);
                                                    // context.go(
                                                    //     '/Create_Return/Add_Image',
                                                    //     extra: {
                                                    //       'orderDetails': _orderDetails,
                                                    //       'imageSizeString': widget.imageSizeString,
                                                    //       'storeImages': widget
                                                    //           .storeImages,
                                                    //       'imageSizeStrings': widget
                                                    //           .imageSizeStrings,
                                                    //       'orderDetailsMap': orderDetailsMap,
                                                    //     });
                                                    context.go('/Add_Image',
                                                        extra: {
                                                          'orderDetails':
                                                              _orderDetails,
                                                          'imageSizeString': widget
                                                              .imageSizeString,
                                                          'storeImages': widget
                                                              .storeImages,
                                                          'imageSizeStrings': widget
                                                              .imageSizeStrings,
                                                          'orderDetailsMap':
                                                              orderDetailsMap,
                                                          'customerId':
                                                              customerIdController
                                                                  .text,
                                                        });
                                                  } else {
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                      const SnackBar(
                                                        content: Text(
                                                            'Please Enter Invoice Number'),
                                                        //  backgroundColor: Colors.red,
                                                      ),
                                                    );
                                                  }
                                                },
                                                style: OutlinedButton.styleFrom(
                                                  backgroundColor:
                                                      Colors.blue[800],
                                                  // Button background color
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5), // Rounded corners
                                                  ),
                                                  side: BorderSide
                                                      .none, // No outline
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Divider(
                                        color: Color(0xFFB2C2D3),
                                        // Choose a color that contrasts with the background
                                        thickness:
                                            1, // Set a non-zero thickness
                                      ),
                                      const SizedBox(height: 8),
                                      Column(
                                        children: [
                                          if (widget.storeImages != '')
                                            Column(
                                              children: List.generate(
                                                  widget.storeImages.length,
                                                  (i) {
                                                return Row(
                                                  children: [
                                                    const Padding(
                                                      padding: EdgeInsets.only(
                                                          left: 30),
                                                      child: Icon(
                                                        Icons.image,
                                                        color: Colors.blue,
                                                        size: 30,
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 15),
                                                      child: Text(
                                                        '${widget.storeImages[i].split('-')[0]}',
                                                        style: const TextStyle(
                                                            fontSize: 18),
                                                      ),
                                                    ),
                                                    // Padding(
                                                    //   padding: const EdgeInsets.only(left: 15),
                                                    //   child: Text('${widget.storeImages[i]}', style: const TextStyle(fontSize: 18)),
                                                    // ),
                                                    const Spacer(),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              right: 30),
                                                      // add 10 pixels of space to the left
                                                      child: Text(
                                                          '${widget.imageSizeStrings[i]}',
                                                          style:
                                                              const TextStyle(
                                                                  fontSize:
                                                                      18)),
                                                    ),
                                                    IconButton(
                                                      icon: const Icon(
                                                        Icons
                                                            .delete_forever_rounded,
                                                        color:
                                                            Colors.deepOrange,
                                                        size: 35,
                                                      ),
                                                      onPressed: () {
                                                        if (i <
                                                            widget.storeImages
                                                                    .length -
                                                                0) {
                                                          setState(() {
                                                            widget.storeImages
                                                                .removeAt(i);
                                                            widget
                                                                .imageSizeString!
                                                                .removeAt(i);
                                                            widget
                                                                .imageSizeStrings
                                                                .removeAt(i);
                                                          });
                                                        } else {
                                                          setState(() {
                                                            widget.storeImages
                                                                .removeAt(i);
                                                            widget
                                                                .imageSizeStrings
                                                                .removeAt(
                                                                    i - 1);
                                                          });
                                                        }
                                                      },
                                                    ),
                                                  ],
                                                );
                                              }),
                                            )
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 50, right: 100, top: 30, bottom: 20),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFFFFF),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Color(0xFF00000029),
                                        offset: Offset(0, 3),
                                        blurRadius: 6,
                                      ),
                                    ],
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text('Notes',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold)),
                                        const SizedBox(height: 8),
                                        TextFormField(
                                          controller: NotesController,
                                          decoration: InputDecoration(
                                            filled: true,
                                            fillColor: Colors.grey.shade200,
                                            border: InputBorder.none,
                                          ),
                                          maxLines:
                                              5, // To make it a single line text field
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ))
                    } else ...{
                      Expanded(
                          child: SingleChildScrollView(
                        child: AdaptiveScrollbar(
                          position: ScrollbarPosition.top,
                          controller: horizontalScroll,
                          child: SingleChildScrollView(
                            controller: horizontalScroll,
                            scrollDirection: Axis.horizontal,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                width: 1700,
                                child: Column(
                                  children: [
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(right: 100),
                                      child: SizedBox(
                                        width: 1700,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          // mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.only(
                                                  right: 130,
                                                  //   * 0.089,
                                                  top: 20),
                                              child: Text(
                                                'Return Date',
                                                style: TextStyle(
                                                    fontSize:
                                                        maxWidth * 0.0090),
                                              ),
                                            ),
                                            DecoratedBox(
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                    color:
                                                        const Color(0xFFEBF3FF),
                                                    width: 1),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: SizedBox(
                                                height: 39,
                                                width: 170,
                                                child: Column(
                                                  children: [
                                                    Expanded(
                                                      child: TextFormField(
                                                        controller:
                                                            _dateController,
                                                        // Replace with your TextEditingController
                                                        readOnly: true,
                                                        decoration:
                                                            InputDecoration(
                                                          suffixIcon: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                                    right: 20),
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .only(
                                                                      top: 2,
                                                                      left: 10),
                                                              child: IconButton(
                                                                icon:
                                                                    const Padding(
                                                                  padding: EdgeInsets
                                                                      .only(
                                                                          bottom:
                                                                              16),
                                                                  child: Icon(Icons
                                                                      .calendar_month),
                                                                ),
                                                                iconSize: 20,
                                                                onPressed: () {
                                                                  // _showDatePicker(context);
                                                                },
                                                              ),
                                                            ),
                                                          ),
                                                          hintText:
                                                              'Select Date',
                                                          fillColor:
                                                              Colors.white,
                                                          contentPadding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal: 8,
                                                                  vertical: 8),
                                                          border:
                                                              InputBorder.none,
                                                          filled: true,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            // SizedBox(height: 20.h),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 50, right: 100, top: 30),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          border:
                                              Border.all(color: Colors.grey),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          boxShadow: const [
                                            BoxShadow(
                                              color: Color(0xff00000029),
                                              offset: Offset(0, 3),
                                              blurRadius: 6,
                                            ),
                                          ],
                                          color: const Color(0xFFFFFFFF),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(16.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        const Row(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            Text(
                                                                'Invoice Number'),
                                                            SizedBox(
                                                              width: 5,
                                                            ),
                                                            Text(
                                                              '*',
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .red),
                                                            ),
                                                          ],
                                                        ),
                                                        const SizedBox(
                                                          height: 5,
                                                        ),
                                                        SizedBox(
                                                          height: 40,
                                                          child: TextFormField(
                                                            controller:
                                                                _controller,
                                                            focusNode:
                                                                _focusNode,
                                                            // onEditingComplete: _fetchOrderDetails,
                                                            decoration:
                                                                InputDecoration(
                                                                    filled:
                                                                        true,
                                                                    contentPadding: const EdgeInsets
                                                                        .symmetric(
                                                                        vertical:
                                                                            10,
                                                                        horizontal:
                                                                            12),
                                                                    fillColor: Colors
                                                                        .grey
                                                                        .shade200,
                                                                    border:
                                                                        OutlineInputBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              5.0),
                                                                      borderSide:
                                                                          BorderSide
                                                                              .none,
                                                                    ),
                                                                    hintText:
                                                                        'INV_03312'),
                                                            inputFormatters: [
                                                              UpperCaseTextFormatter(),
                                                              FilteringTextInputFormatter
                                                                  .allow(RegExp(
                                                                      "[a-zA-Z_0-9]")),
                                                              // Allow only letters, numbers, and single space
                                                              FilteringTextInputFormatter
                                                                  .deny(RegExp(
                                                                      r'^\s')),
                                                              // Disallow starting with a space
                                                              FilteringTextInputFormatter
                                                                  .deny(RegExp(
                                                                      r'\s\s')),
                                                              // Disallow multiple spaces
                                                            ],
                                                            validator: (value) {
                                                              if (_controller
                                                                          .text !=
                                                                      null &&
                                                                  _controller
                                                                      .text
                                                                      .trim()
                                                                      .isEmpty) {
                                                                return 'Please enter a product name';
                                                              }
                                                              return null;
                                                            },
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  const SizedBox(width: 16),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        const Row(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            Text('Reason'),
                                                            SizedBox(
                                                              width: 5,
                                                            ),
                                                            Text(
                                                              '*',
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .red),
                                                            ),
                                                          ],
                                                        ),
                                                        const SizedBox(
                                                          height: 5,
                                                        ),
                                                        SizedBox(
                                                          height: 40,
                                                          child:
                                                              DropdownButtonFormField<
                                                                  String>(
                                                            decoration:
                                                                InputDecoration(
                                                              filled: true,
                                                              fillColor: Colors
                                                                  .grey
                                                                  .shade200,
                                                              border:
                                                                  OutlineInputBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            5.0),
                                                                borderSide:
                                                                    BorderSide
                                                                        .none, // Remove border by setting borderSide to BorderSide.none
                                                              ),
                                                              contentPadding:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          8,
                                                                      vertical:
                                                                          8),
                                                            ),
                                                            value:
                                                                _selectedReason,
                                                            onChanged: (String?
                                                                value) {
                                                              setState(() {
                                                                _selectedReason =
                                                                    value!;
                                                                _reasonController
                                                                        .text =
                                                                    value;
                                                              });
                                                            },
                                                            items: <String>[
                                                              'Reason for return',
                                                              'Option 1',
                                                              'Option 2'
                                                            ].map<
                                                                DropdownMenuItem<
                                                                    String>>((String
                                                                value) {
                                                              return DropdownMenuItem<
                                                                  String>(
                                                                value: value,
                                                                child: Text(
                                                                  value,
                                                                  style:
                                                                      TextStyle(
                                                                    color: value ==
                                                                            'Reason for return'
                                                                        ? Colors
                                                                            .grey
                                                                        : Colors
                                                                            .black,
                                                                  ),
                                                                ),
                                                              );
                                                            }).toList(),
                                                            isExpanded: true,
                                                            //     hint: const Text('Reason for return'),
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                  const SizedBox(width: 16),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        const Row(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            Text(
                                                                'Contact Person'),
                                                            SizedBox(
                                                              width: 5,
                                                            ),
                                                            Text(
                                                              '*',
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .red),
                                                            ),
                                                          ],
                                                        ),
                                                        const SizedBox(
                                                          height: 5,
                                                        ),
                                                        SizedBox(
                                                          height: 40,
                                                          child: TextFormField(
                                                            controller:
                                                                ContactpersonController,
                                                            decoration:
                                                                InputDecoration(
                                                                    filled:
                                                                        true,
                                                                    fillColor: Colors
                                                                        .grey
                                                                        .shade200,
                                                                    border:
                                                                        OutlineInputBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              5.0),
                                                                      borderSide:
                                                                          BorderSide
                                                                              .none,
                                                                    ),
                                                                    contentPadding: const EdgeInsets
                                                                        .symmetric(
                                                                        vertical:
                                                                            10,
                                                                        horizontal:
                                                                            12),
                                                                    hintText:
                                                                        'Person Name'),
                                                            inputFormatters: [
                                                              FilteringTextInputFormatter
                                                                  .allow(RegExp(
                                                                      "[a-zA-Z ]")),
                                                              // Allow only letters, numbers, and single space
                                                              FilteringTextInputFormatter
                                                                  .deny(RegExp(
                                                                      r'^\s')),
                                                              // Disallow starting with a space
                                                              FilteringTextInputFormatter
                                                                  .deny(RegExp(
                                                                      r'\s\s')),
                                                              // Disallow multiple spaces
                                                            ],
                                                            validator: (value) {
                                                              if (ContactpersonController
                                                                          .text !=
                                                                      null &&
                                                                  ContactpersonController
                                                                      .text
                                                                      .trim()
                                                                      .isEmpty) {
                                                                return 'Please enter a product name';
                                                              }
                                                              return null;
                                                            },
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  const SizedBox(width: 16),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        const Row(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            Text('Email'),
                                                            SizedBox(
                                                              width: 5,
                                                            ),
                                                            Text(
                                                              '*',
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .red),
                                                            ),
                                                          ],
                                                        ),
                                                        const SizedBox(
                                                          height: 5,
                                                        ),
                                                        SizedBox(
                                                          height: 40,
                                                          child: TextFormField(
                                                            controller:
                                                                EmailAddressController,
                                                            decoration:
                                                                InputDecoration(
                                                              filled: true,
                                                              fillColor: Colors
                                                                  .grey
                                                                  .shade200,
                                                              border:
                                                                  OutlineInputBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            5.0),
                                                                borderSide:
                                                                    BorderSide
                                                                        .none,
                                                              ),
                                                              contentPadding:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                      vertical:
                                                                          10,
                                                                      horizontal:
                                                                          12),
                                                              hintText:
                                                                  'Person Email',
                                                              // errorText: _errorText,
                                                            ),
                                                            inputFormatters: [
                                                              FilteringTextInputFormatter
                                                                  .allow(RegExp(
                                                                      "[a-zA-Z,0-9,@.]")),
                                                              FilteringTextInputFormatter
                                                                  .deny(RegExp(
                                                                      r'^\s')),
                                                              FilteringTextInputFormatter
                                                                  .deny(RegExp(
                                                                      r'\s\s')),
                                                            ],
                                                            // inputFormatters: [
                                                            //   FilteringTextInputFormatter.allow(
                                                            //       RegExp("[a-zA-Z,0-9,@.]")),
                                                            //   // Allow only letters, numbers, and single space
                                                            //   FilteringTextInputFormatter.deny(
                                                            //       RegExp(r'^\s')),
                                                            //   // Disallow starting with a space
                                                            //   FilteringTextInputFormatter.deny(
                                                            //       RegExp(r'\s\s')),
                                                            //   // Disallow multiple spaces
                                                            // ],
                                                            // validator: (value) {
                                                            //    if (value!.isEmpty) {
                                                            //        return 'Please enter an email address';
                                                            //      } else if (!RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$,0-9,@.').hasMatch(value)) {
                                                            //        return 'Invalid email address format. Please use the format "username@example.com"';
                                                            //      }
                                                            //    return null;
                                                            //  },
                                                            validator: (value) {
                                                              setState(() {
                                                                if (value!
                                                                    .isEmpty) {
                                                                  _errorText =
                                                                      'Please enter Valid email address';
                                                                } else if (!RegExp(
                                                                        r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$')
                                                                    .hasMatch(
                                                                        value)) {
                                                                  _errorText =
                                                                      'Please enter valid email address';
                                                                } else {
                                                                  _errorText =
                                                                      null;
                                                                }
                                                              });
                                                              if (_errorText !=
                                                                  null) {
                                                                ScaffoldMessenger.of(
                                                                        context)
                                                                    .showSnackBar(
                                                                  SnackBar(
                                                                      content: Text(
                                                                          _errorText!)),
                                                                );
                                                              }
                                                              return null;
                                                            },
                                                            // validator: (value) {
                                                            //   if (value!.isEmpty) {
                                                            //     return 'Please enter an email address';
                                                            //   } else if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(value)) {
                                                            //     if (!value.contains('@')) {
                                                            //       return 'Email address should contain "@" symbol';
                                                            //     } else if (!value.contains('.')) {
                                                            //       return 'Email address should contain a valid domain (e.g. .com, .net, etc.)';
                                                            //     } else {
                                                            //       return 'Invalid email address format. Please use the format "username@example.com"';
                                                            //     }
                                                            //   }
                                                            //   return null;
                                                            // },
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 50, right: 100, top: 30),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFFFFFF),
                                          border:
                                              Border.all(color: Colors.grey),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          boxShadow: const [
                                            BoxShadow(
                                              color: Color(0xFF00000029),
                                              offset: Offset(0, 3),
                                              blurRadius: 6,
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Padding(
                                              padding: EdgeInsets.only(
                                                  top: 10, left: 30),
                                              child: Text(
                                                'Add Products',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                  fontFamily: 'Titillium Web',
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Container(
                                              width: 1700,
                                              decoration: const BoxDecoration(
                                                border: Border(
                                                  top: BorderSide(
                                                      color: Color(0xFFB2C2D3),
                                                      width: 1.2),
                                                  bottom: BorderSide(
                                                      color: Color(0xFFB2C2D3),
                                                      width: 1.2),
                                                ),
                                              ),
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 5, bottom: 5),
                                                child: Table(
                                                  columnWidths: const {
                                                    0: FlexColumnWidth(1),
                                                    1: FlexColumnWidth(3),
                                                    2: FlexColumnWidth(2),
                                                    3: FlexColumnWidth(2),
                                                    4: FlexColumnWidth(2),
                                                    5: FlexColumnWidth(1),
                                                    6: FlexColumnWidth(1.2),
                                                    7: FlexColumnWidth(2),
                                                    8: FlexColumnWidth(2),
                                                  },
                                                  children: const [
                                                    TableRow(children: [
                                                      TableCell(
                                                        child: Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  top: 10,
                                                                  bottom: 10),
                                                          child: Center(
                                                            child: Text(
                                                              "SN",
                                                              style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                //  fontSize: 12,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      TableCell(
                                                        child: Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  top: 10,
                                                                  bottom: 10),
                                                          child: Center(
                                                            child: Text(
                                                              'Product Name',
                                                              style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                //  fontSize: 12,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      TableCell(
                                                        child: Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  top: 10,
                                                                  bottom: 10),
                                                          child: Center(
                                                            child: Text(
                                                              "Category",
                                                              style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                // fontSize: 12,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      TableCell(
                                                        child: Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  top: 10,
                                                                  bottom: 10),
                                                          child: Center(
                                                            child: Text(
                                                              "Sub Category",
                                                              style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                // fontSize: 12,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      TableCell(
                                                        child: Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  top: 10,
                                                                  bottom: 10),
                                                          child: Center(
                                                            child: Text(
                                                              "Price",
                                                              style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                // fontSize: 12,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      TableCell(
                                                        child: Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  top: 10,
                                                                  bottom: 10),
                                                          child: Center(
                                                            child: Text(
                                                              "QTY",
                                                              style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                // fontSize: 12,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      TableCell(
                                                        child: Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  top: 10,
                                                                  bottom: 10),
                                                          child: Center(
                                                            child: Text(
                                                              "Return QTY",
                                                              style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                //  fontSize: 12,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      TableCell(
                                                        child: Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  top: 10,
                                                                  bottom: 10),
                                                          child: Center(
                                                            child: Text(
                                                              "Invoice Amount",
                                                              style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                //  fontSize: 12,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      TableCell(
                                                        child: Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  top: 10,
                                                                  bottom: 10),
                                                          child: Center(
                                                            child: Text(
                                                              "Credit Request",
                                                              style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                // fontSize: 12,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ])
                                                  ],
                                                ),
                                              ),
                                            ),
                                            ListView.builder(
                                              shrinkWrap: true,
                                              physics:
                                                  const NeverScrollableScrollPhysics(),
                                              itemCount: _orderDetails.length,
                                              itemBuilder: (context, index) {
                                                if (index >=
                                                        _orderDetails.length ||
                                                    index >=
                                                        _qtyControllers
                                                            .length) {
                                                  return const SizedBox
                                                      .shrink(); // Return an empty widget if the index is out of range
                                                }
                                                Map<String, dynamic> item =
                                                    _orderDetails[index];
                                                return Table(
                                                  border: const TableBorder(
                                                    bottom: BorderSide(
                                                        width: 1,
                                                        color: Colors.grey),
                                                    //   horizontalInside: BorderSide(width: 1,color: Colors.grey), // horizontal border inside the table
                                                    verticalInside: BorderSide(
                                                        width: 1,
                                                        color: Colors.grey),
                                                  ),
                                                  // border: TableBorder.all(color: Colors.blue),
                                                  //  Color(0xFFFFFFFF)
                                                  columnWidths: const {
                                                    0: FlexColumnWidth(1),
                                                    1: FlexColumnWidth(3),
                                                    2: FlexColumnWidth(2),
                                                    3: FlexColumnWidth(2),
                                                    4: FlexColumnWidth(2),
                                                    5: FlexColumnWidth(1),
                                                    6: FlexColumnWidth(1.2),
                                                    7: FlexColumnWidth(2),
                                                    8: FlexColumnWidth(2),
                                                  },

                                                  children: [
                                                    TableRow(children: [
                                                      TableCell(
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  left: 10,
                                                                  right: 10,
                                                                  top: 15,
                                                                  bottom: 5),
                                                          child: Center(
                                                              child: Text(
                                                                  '${index + 1}')),
                                                        ),
                                                      ),
                                                      TableCell(
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  left: 10,
                                                                  right: 10,
                                                                  top: 10,
                                                                  bottom: 10),
                                                          child: Container(
                                                            height: 35,
                                                            width: 50,
                                                            decoration:
                                                                BoxDecoration(
                                                              color: Colors.grey
                                                                  .shade200,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          4.0),
                                                            ),
                                                            child: Center(
                                                                child: Text(
                                                              item[
                                                                  'productName'],
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                            )),
                                                          ),
                                                        ),
                                                      ),
                                                      TableCell(
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  left: 10,
                                                                  right: 10,
                                                                  top: 10,
                                                                  bottom: 10),
                                                          child: Container(
                                                            height: 35,
                                                            width: 50,
                                                            decoration:
                                                                BoxDecoration(
                                                              color: Colors.grey
                                                                  .shade200,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          4.0),
                                                            ),
                                                            child: Center(
                                                                child: Text(
                                                              item['category'],
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                            )),
                                                          ),
                                                        ),
                                                      ),
                                                      TableCell(
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  left: 10,
                                                                  right: 10,
                                                                  top: 10,
                                                                  bottom: 10),
                                                          child: Container(
                                                            height: 35,
                                                            width: 50,
                                                            decoration:
                                                                BoxDecoration(
                                                              color: Colors.grey
                                                                  .shade200,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          4.0),
                                                            ),
                                                            child: Center(
                                                                child: Text(item[
                                                                    'subCategory'])),
                                                          ),
                                                        ),
                                                      ),

                                                      TableCell(
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  left: 10,
                                                                  right: 10,
                                                                  top: 10,
                                                                  bottom: 10),
                                                          child: Container(
                                                            height: 35,
                                                            width: 50,
                                                            decoration:
                                                                BoxDecoration(
                                                              color: Colors.grey
                                                                  .shade200,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          4.0),
                                                            ),
                                                            child: Center(
                                                                child: Text(item[
                                                                        'price']
                                                                    .toString())),
                                                          ),
                                                        ),
                                                      ),
                                                      TableCell(
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  left: 10,
                                                                  right: 10,
                                                                  top: 10,
                                                                  bottom: 10),
                                                          child: Container(
                                                            height: 35,
                                                            width: 50,
                                                            decoration:
                                                                BoxDecoration(
                                                              color: Colors.grey
                                                                  .shade200,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          4.0),
                                                            ),
                                                            child: Center(
                                                                child: Text(item[
                                                                        'qty']
                                                                    .toString())),
                                                          ),
                                                        ),
                                                      ),
                                                      TableCell(
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  left: 10,
                                                                  right: 10,
                                                                  top: 10,
                                                                  bottom: 10),
                                                          child: Container(
                                                            height: 35,
                                                            width: 50,
                                                            decoration:
                                                                BoxDecoration(
                                                              color: Colors.grey
                                                                  .shade200,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          4.0),
                                                            ),
                                                            child: Center(
                                                              child:
                                                                  TextFormField(
                                                                controller:
                                                                    _qtyControllers[
                                                                        index],
                                                                // controller: _qtyControllers[index],
                                                                //controller: _textController[item],
                                                                // controller: TextEditingController.fromValue(TextEditingValue(
                                                                //   text: (item['enteredQty']?? '').toString(),
                                                                //   selection: TextSelection.collapsed(offset: (item['enteredQty']?? '').toString().length),
                                                                // )),
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                // Center alignment
                                                                decoration:
                                                                    const InputDecoration(
                                                                        border: InputBorder
                                                                            .none,
                                                                        // Remove underline
                                                                        contentPadding:
                                                                            EdgeInsets.only(bottom: 12)
                                                                        //contentPadding: EdgeInsets.symmetric(vertical: 5,horizontal: 8) // Set content padding
                                                                        ),
                                                                inputFormatters: [
                                                                  LengthLimitingTextInputFormatter(
                                                                      4),
                                                                  FilteringTextInputFormatter
                                                                      .allow(RegExp(
                                                                          "[0-9]")),
                                                                  // Allow only letters, numbers, and single space
                                                                  FilteringTextInputFormatter
                                                                      .deny(RegExp(
                                                                          r'^\s')),
                                                                  // Disallow starting with a space
                                                                  FilteringTextInputFormatter
                                                                      .deny(RegExp(
                                                                          r'\s\s')),
                                                                  // Disallow multiple spaces
                                                                ],
                                                                onChanged:
                                                                    (value) {
                                                                  setState(() {
                                                                    if (value
                                                                        .isEmpty) {
                                                                      item['enteredQty'] =
                                                                          0;
                                                                      item['totalAmount2'] =
                                                                          0;
                                                                      _qtyControllers[
                                                                              index]
                                                                          .clear();
                                                                    } else {
                                                                      int enteredQty =
                                                                          int.parse(
                                                                              value);

                                                                      if (enteredQty >
                                                                              (item['qty'] ??
                                                                                  0) ||
                                                                          enteredQty ==
                                                                              0) {
                                                                        //  if (enteredQty > (item['qty']?? 0) || (item['qty'] == 0)) {
                                                                        ScaffoldMessenger.of(context)
                                                                            .showSnackBar(
                                                                          const SnackBar(
                                                                              content: Text('Return qty must be less than or equal to the order qty.')),
                                                                        );
                                                                        // Clear the entered value
                                                                        item['enteredQty'] =
                                                                            0;
                                                                        _qtyControllers[index]
                                                                            .clear();
                                                                        //  _textController.clear(); // Clear the text field
                                                                      } else {
                                                                        item['enteredQty'] =
                                                                            enteredQty;
                                                                        item[
                                                                            'totalAmount2'] = (item['totalAmount'] /
                                                                                item['qty']) *
                                                                            enteredQty;
                                                                      }
                                                                    }
                                                                    // calculate the total amount
                                                                    totalAmount = _orderDetails.fold(
                                                                        0.0,
                                                                        (sum, item) =>
                                                                            sum +
                                                                            (item['totalAmount2'] ??
                                                                                0));
                                                                    totalController
                                                                            .text =
                                                                        totalAmount
                                                                            .toStringAsFixed(2); // update the totalController
                                                                    print(
                                                                        'enteredqty');
                                                                    print(_qtyControllers[
                                                                            index]
                                                                        .text);
                                                                    print(item[
                                                                        'enteredQty']);
                                                                    print(_qtyControllers[
                                                                            index]
                                                                        .text);
                                                                  });
                                                                },
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      // TableCell(
                                                      //   child: Padding(
                                                      //     padding: const EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10),
                                                      //     child: Container(
                                                      //       height: 35,
                                                      //       width: 50,
                                                      //       decoration: BoxDecoration(
                                                      //         color: Colors.grey.shade200,
                                                      //         borderRadius: BorderRadius.circular(4.0),
                                                      //       ),
                                                      //       child: Center(
                                                      //         child: TextFormField(
                                                      //           initialValue: (item['enteredQty']?? '').toString(),
                                                      //           textAlign: TextAlign.center, // Center alignment
                                                      //           decoration: const InputDecoration(
                                                      //               border: InputBorder.none, // Remove underline
                                                      //               contentPadding: EdgeInsets.only(
                                                      //                   bottom: 12
                                                      //               )
                                                      //               //contentPadding: EdgeInsets.symmetric(vertical: 5,horizontal: 8) // Set content padding
                                                      //           ),
                                                      //           inputFormatters: [
                                                      //             LengthLimitingTextInputFormatter(4),
                                                      //             FilteringTextInputFormatter.allow(
                                                      //                 RegExp("[0-9]")),
                                                      //             // Allow only letters, numbers, and single space
                                                      //             FilteringTextInputFormatter.deny(
                                                      //                 RegExp(r'^\s')),
                                                      //             // Disallow starting with a space
                                                      //             FilteringTextInputFormatter.deny(
                                                      //                 RegExp(r'\s\s')),
                                                      //             // Disallow multiple spaces
                                                      //           ],
                                                      //           onChanged: (value) {
                                                      //             setState(() {
                                                      //               if (value.isEmpty) {
                                                      //                 item['enteredQty'] = 0;
                                                      //                 item['totalAmount2'] = 0;
                                                      //               } else {
                                                      //                 item['enteredQty'] = int.parse(value);
                                                      //                 if (item['enteredQty'] > (item['qty']?? 0)) {
                                                      //                   ScaffoldMessenger.of(context).showSnackBar(
                                                      //                     const SnackBar(content: Text('Return qty must be less than or equal to the order qty.')),
                                                      //                   );
                                                      //                 } else {
                                                      //                   item['totalAmount2'] = item['price'] * item['enteredQty'];
                                                      //                 }
                                                      //               }
                                                      //               // calculate the total amount
                                                      //               totalAmount = _orderDetails.fold(0.0, (sum, item) => sum + (item['totalAmount2']?? 0));
                                                      //               totalController.text = totalAmount.toStringAsFixed(2); // update the totalController
                                                      //               print('enteredqty');
                                                      //               print(item['enteredQty']);
                                                      //             });
                                                      //           },
                                                      //         ),
                                                      //       ),
                                                      //     ),
                                                      //   ),
                                                      // ),
                                                      TableCell(
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  left: 10,
                                                                  right: 10,
                                                                  top: 10,
                                                                  bottom: 10),
                                                          child: Container(
                                                            height: 35,
                                                            width: 50,
                                                            decoration:
                                                                BoxDecoration(
                                                              color: Colors.grey
                                                                  .shade200,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          4.0),
                                                            ),
                                                            child: Center(
                                                                child: Text(item[
                                                                        'totalAmount']
                                                                    .toString())),
                                                          ),
                                                        ),
                                                      ),
                                                      TableCell(
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  left: 10,
                                                                  right: 10,
                                                                  top: 10,
                                                                  bottom: 10),
                                                          child: Container(
                                                            height: 35,
                                                            width: 50,
                                                            decoration:
                                                                BoxDecoration(
                                                              color: Colors.grey
                                                                  .shade200,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          4.0),
                                                            ),
                                                            child: Center(
                                                              child: Text(item[
                                                                          'totalAmount2'] !=
                                                                      null
                                                                  ? item['totalAmount2']
                                                                      .toString()
                                                                  : '0'),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ])
                                                  ],
                                                );
                                              },
                                            ),
                                            const SizedBox(height: 8),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 25, top: 5, bottom: 5),
                                              child: Align(
                                                alignment:
                                                    Alignment.centerRight,
                                                child: Container(
                                                  height: 40,
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 15,
                                                          right: 10,
                                                          top: 6,
                                                          bottom: 2),
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                        color: const Color(
                                                            0xFF0277BD)),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            2.0),
                                                    color: Colors.white,
                                                  ),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            bottom: 2),
                                                    child: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        RichText(
                                                          text: TextSpan(
                                                            children: [
                                                              const TextSpan(
                                                                text:
                                                                    'Total Credit',
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        14,
                                                                    color: Colors
                                                                        .blue
                                                                    // fontWeight: FontWeight.bold,
                                                                    ),
                                                              ),
                                                              const TextSpan(
                                                                text: '  ₹',
                                                                style:
                                                                    TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                ),
                                                              ),
                                                              TextSpan(
                                                                text:
                                                                    totalController
                                                                        .text,
                                                                style:
                                                                    const TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                ),
                                                              )
                                                            ],
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 50, right: 100, top: 30),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFFFFFF),
                                          boxShadow: const [
                                            BoxShadow(
                                              color: Color(0xFF00000029),
                                              offset: Offset(0, 3),
                                              blurRadius: 6,
                                            ),
                                          ],
                                          border:
                                              Border.all(color: Colors.grey),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const SizedBox(height: 8),
                                            Row(
                                              children: [
                                                const Padding(
                                                  padding:
                                                      EdgeInsets.only(left: 30),
                                                  child: Text(
                                                    'Image Upload',
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 14,
                                                      fontFamily:
                                                          'Titillium Web',
                                                    ),
                                                  ),
                                                ),
                                                const Spacer(),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          right: 30),
                                                  child: Padding(
                                                    padding: EdgeInsets.only(
                                                        left: maxWidth * 0.15),
                                                    child: OutlinedButton.icon(
                                                      icon: const Icon(
                                                        Icons.upload,
                                                        color: Colors.white,
                                                        size: 18,
                                                      ),
                                                      label: const Text(
                                                        'Upload',
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                      onPressed: () {
                                                        if (_controller
                                                            .text.isNotEmpty) {
                                                          Map<String, dynamic>
                                                              orderDetailsMap =
                                                              {
                                                            'emailAddress':
                                                                EmailAddressController
                                                                    .text,
                                                            'contactPerson':
                                                                ContactpersonController
                                                                    .text,
                                                            'reason':
                                                                _selectedReason,
                                                            'otherField':
                                                                _controller
                                                                    .text,
                                                            'orderDetails':
                                                                _orderDetails,
                                                            'totalAmount2':
                                                                totalController
                                                                    .text,
                                                            'notes':
                                                                NotesController
                                                                    .text,
                                                            'customerId':
                                                                customerIdController
                                                                    .text,
                                                            'orderId':
                                                                OrderIDController
                                                                    .text,
                                                            'shipAddres':
                                                                ShippingAddressController
                                                                    .text,
                                                            'ContactNumber':
                                                                ContactPerson
                                                                    .text,
                                                          };
                                                          print(
                                                              'return design module file');
                                                          print(
                                                              orderDetailsMap);
                                                          print(_orderDetails);
                                                          // context.go(
                                                          //     '/Create_Return/Add_Image',
                                                          //     extra: {
                                                          //       'orderDetails': _orderDetails,
                                                          //       'imageSizeString': widget.imageSizeString,
                                                          //       'storeImages': widget
                                                          //           .storeImages,
                                                          //       'imageSizeStrings': widget
                                                          //           .imageSizeStrings,
                                                          //       'orderDetailsMap': orderDetailsMap,
                                                          //     });
                                                          context.go(
                                                              '/Add_Image',
                                                              extra: {
                                                                'orderDetails':
                                                                    _orderDetails,
                                                                'imageSizeString':
                                                                    widget
                                                                        .imageSizeString,
                                                                'storeImages':
                                                                    widget
                                                                        .storeImages,
                                                                'imageSizeStrings':
                                                                    widget
                                                                        .imageSizeStrings,
                                                                'orderDetailsMap':
                                                                    orderDetailsMap,
                                                                'customerId':
                                                                    customerIdController
                                                                        .text,
                                                              });
                                                        } else {
                                                          ScaffoldMessenger.of(
                                                                  context)
                                                              .showSnackBar(
                                                            const SnackBar(
                                                              content: Text(
                                                                  'Please Enter Invoice Number'),
                                                              //  backgroundColor: Colors.red,
                                                            ),
                                                          );
                                                        }
                                                      },
                                                      style: OutlinedButton
                                                          .styleFrom(
                                                        backgroundColor:
                                                            Colors.blue[800],
                                                        // Button background color
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                  5), // Rounded corners
                                                        ),
                                                        side: BorderSide
                                                            .none, // No outline
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const Divider(
                                              color: Color(0xFFB2C2D3),
                                              // Choose a color that contrasts with the background
                                              thickness:
                                                  1, // Set a non-zero thickness
                                            ),
                                            const SizedBox(height: 8),
                                            Column(
                                              children: [
                                                if (widget.storeImages != '')
                                                  Column(
                                                    children: List.generate(
                                                        widget.storeImages
                                                            .length, (i) {
                                                      return Row(
                                                        children: [
                                                          const Padding(
                                                            padding:
                                                                EdgeInsets.only(
                                                                    left: 30),
                                                            child: Icon(
                                                              Icons.image,
                                                              color:
                                                                  Colors.blue,
                                                              size: 30,
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                                    left: 15),
                                                            child: Text(
                                                              '${widget.storeImages[i].split('-')[0]}',
                                                              style:
                                                                  const TextStyle(
                                                                      fontSize:
                                                                          18),
                                                            ),
                                                          ),
                                                          // Padding(
                                                          //   padding: const EdgeInsets.only(left: 15),
                                                          //   child: Text('${widget.storeImages[i]}', style: const TextStyle(fontSize: 18)),
                                                          // ),
                                                          const Spacer(),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                                    right: 30),
                                                            // add 10 pixels of space to the left
                                                            child: Text(
                                                                '${widget.imageSizeStrings[i]}',
                                                                style:
                                                                    const TextStyle(
                                                                        fontSize:
                                                                            18)),
                                                          ),
                                                          IconButton(
                                                            icon: const Icon(
                                                              Icons
                                                                  .delete_forever_rounded,
                                                              color: Colors
                                                                  .deepOrange,
                                                              size: 35,
                                                            ),
                                                            onPressed: () {
                                                              if (i <
                                                                  widget.storeImages
                                                                          .length -
                                                                      0) {
                                                                setState(() {
                                                                  widget
                                                                      .storeImages
                                                                      .removeAt(
                                                                          i);
                                                                  widget
                                                                      .imageSizeString!
                                                                      .removeAt(
                                                                          i);
                                                                  widget
                                                                      .imageSizeStrings
                                                                      .removeAt(
                                                                          i);
                                                                });
                                                              } else {
                                                                setState(() {
                                                                  widget
                                                                      .storeImages
                                                                      .removeAt(
                                                                          i);
                                                                  widget
                                                                      .imageSizeStrings
                                                                      .removeAt(
                                                                          i - 1);
                                                                });
                                                              }
                                                            },
                                                          ),
                                                        ],
                                                      );
                                                    }),
                                                  )
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 50,
                                          right: 100,
                                          top: 30,
                                          bottom: 20),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFFFFFF),
                                          boxShadow: const [
                                            BoxShadow(
                                              color: Color(0xFF00000029),
                                              offset: Offset(0, 3),
                                              blurRadius: 6,
                                            ),
                                          ],
                                          border:
                                              Border.all(color: Colors.grey),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                        child: Padding(
                                          padding: const EdgeInsets.all(16.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Text('Notes',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold)),
                                              const SizedBox(height: 8),
                                              TextFormField(
                                                controller: NotesController,
                                                decoration: InputDecoration(
                                                  filled: true,
                                                  fillColor:
                                                      Colors.grey.shade200,
                                                  border: InputBorder.none,
                                                ),
                                                maxLines:
                                                    5, // To make it a single line text field
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ))
                    }
                  ],
                ))
          ],
        );
      }),
    );
  }
}

String removeCharAt(String str, int index) {
  return str.substring(0, index) + str.substring(index + 1);
}

DataRow dataRow(
    int sn,
    String productName,
    String brand,
    String category,
    String subCategory,
    String price,
    int qty,
    int returnQty,
    String invoiceAmount,
    String creditRequest) {
  return DataRow(cells: [
    DataCell(
      Container(
        decoration: const BoxDecoration(
          color: Color(0xFFEEEEEE),
        ),
        child: Center(
          child: Text(sn.toString()),
        ),
      ),
    ),
    DataCell(
      Container(
        decoration: const BoxDecoration(
          color: Color(0xFFEEEEEE),
        ),
        child: Center(
          child: Text(productName),
        ),
      ),
    ),
    DataCell(
      Container(
        decoration: const BoxDecoration(
          color: Color(0xFFEEEEEE),
        ),
        child: Center(
          child: Text(brand),
        ),
      ),
    ),
    DataCell(
      Container(
        decoration: const BoxDecoration(
          color: Color(0xFFEEEEEE),
        ),
        child: Center(
          child: Text(category),
        ),
      ),
    ),
    DataCell(
      Container(
        decoration: const BoxDecoration(
          color: Color(0xFFEEEEEE),
        ),
        child: Center(
          child: Text(subCategory),
        ),
      ),
    ),
    DataCell(
      Container(
        decoration: const BoxDecoration(
          color: Color(0xFFEEEEEE),
        ),
        child: Center(
          child: Text(price),
        ),
      ),
    ),
    DataCell(
      Container(
        decoration: const BoxDecoration(
          color: Color(0xFFEEEEEE),
        ),
        child: Center(
          child: Text(qty.toString()),
        ),
      ),
    ),
    DataCell(
      Container(
        decoration: const BoxDecoration(
          color: Color(0xFFEEEEEE),
        ),
        child: Center(
          child: Text(returnQty.toString()),
        ),
      ),
    ),
    DataCell(
      Container(
        decoration: const BoxDecoration(
          color: Color(0xFFEEEEEE),
        ),
        child: Center(
          child: Text(invoiceAmount),
        ),
      ),
    ),
    DataCell(
      Container(
        decoration: const BoxDecoration(
          color: Color(0xFFEEEEEE),
        ),
        child: Center(
          child: Text(creditRequest),
        ),
      ),
    ),
  ]);
}
