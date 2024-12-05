import 'dart:async';
import 'dart:convert';
import 'dart:html';

import 'package:adaptive_scrollbar/adaptive_scrollbar.dart';
import 'package:btb/admin/Api%20name.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

import '../widgets/confirmdialog.dart';
import 'delivery list.dart';

void main() {
  runApp(
      MaterialApp(
          debugShowCheckedModeBanner: false,
          home: DeliveryConfirm(deliveryId: '',)));
}



class DeliveryConfirm extends StatefulWidget {
  final String? deliveryId;
  final String? invoice;
  final String? deliverystatus;
  final String? deliverymasterId;


  //final Map<Product, TextEditingController> _controller = {};

  DeliveryConfirm({super.key,required this.deliveryId,this.invoice,this.deliverystatus,this.deliverymasterId,
  });
  @override
  State<DeliveryConfirm> createState() {
    return _DeliveryDetailState();
  }
}

class _DeliveryDetailState extends State<DeliveryConfirm> {

  // FocusNode _focusNode = FocusNode();
  final _controller = TextEditingController();
  List<dynamic> _orderDetails = [];
  Timer? _timer;
  late TextEditingController _dateController;

  List<TextEditingController> _qtyControllers = [];
  String? _errorText;
  String _enteredValues = '';

  int Index =1 ;
  bool _isEditing = false;
  bool isOrdersSelected = false;
  double totalAmount = 0.0;
  final _textController = TextEditingController();
  final totalController = TextEditingController();
  List<String> storeImages = [];
  final ScrollController horizontalScroll = ScrollController();
  DateTime? _selectedDate;
  List<Map<String, dynamic>> items = [];
  List<String> imageSizeStrings = [];
  String? errorMessage;
  final TextEditingController InvNoController = TextEditingController();
  final TextEditingController deliveryStatusController = TextEditingController();
  final TextEditingController NotesController = TextEditingController();
  final TextEditingController EmailAddressController = TextEditingController();
  final TextEditingController ContactpersonController = TextEditingController();
  final TextEditingController CustomerIdcontroller = TextEditingController();
  final _reasonController = TextEditingController();
  String _enteredValue = '';
  String token = window.sessionStorage["token"] ?? " ";
  double _totalAmount = 0;
  bool _isLoading= false;
  final TextEditingController EmailIdController = TextEditingController();
  final TextEditingController DelAddController = TextEditingController();
  final TextEditingController ShippingAddress = TextEditingController();
  final TextEditingController ContactperController = TextEditingController();
  final TextEditingController ContactNumberContoller = TextEditingController();
  String selectedValue = 'Select Location';
  final List<String> list = ['Select Location','  Name 1', '  Name 2', '  Name3'];
  final TextEditingController TotalController = TextEditingController();


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
  final FocusNode _focusNode = FocusNode();

  List<Widget> _buildMenuItems(BuildContext context) {
    return [
      _buildMenuItem('Home', Icons.home_outlined, Colors.blue[900]!, '/Home'),
      _buildMenuItem('Customer', Icons.account_circle_outlined, Colors.blue[900]!, '/Customer'),
      _buildMenuItem('Products', Icons.image_outlined, Colors.blue[900]!, '/Product_List'),
      _buildMenuItem('Orders', Icons.warehouse_outlined, Colors.blue[900]!, '/Order_List'),

      Container(decoration: BoxDecoration(
        color: Colors.blue[800]  ,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(8), // Radius for top-left corner
          topRight: Radius.circular(8), // No radius for top-right corner
          bottomLeft: Radius.circular(8), // Radius for bottom-left corner
          bottomRight: Radius.circular(8), // No radius for bottom-right corner
        ),
      ),child: _buildMenuItem('Delivery', Icons.fire_truck_outlined, Colors.white, '/Delivery_List')),
      _buildMenuItem('Invoice', Icons.document_scanner_outlined, Colors.blue[900]!, '/Invoice'),
      _buildMenuItem('Payment', Icons.payment_rounded, Colors.blue[900]!, '/Payment_List'),
      _buildMenuItem('Return', Icons.keyboard_return, Colors.blue[900]!, '/Return_List'),
      _buildMenuItem('Reports', Icons.insert_chart_outlined, Colors.blue[900]!, '/Report_List'),
    ];
  }

  Widget _buildMenuItem(String title, IconData icon, Color iconColor, String route) {
    iconColor = _isHovered[title] == true ? Colors.blue : Colors.black87;
    title == 'Delivery'? _isHovered[title] = false :  _isHovered[title] = false;
    title == 'Delivery'? iconColor = Colors.white : Colors.black;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered[title] = true),
      onExit: (_) => setState(() => _isHovered[title] = false),
      child: GestureDetector(
        onTap: () {
          context.go(route);
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 5,right: 20),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: _isHovered[title]! ? Colors.black12 : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.only(left: 5,top: 5),
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

  Future<void> addReturnMaster1() async {
    final orderId = widget.deliveryId?.trim();
    print('Order ID: $orderId');

    // Step 1: Fetch all return master data to get invoice numbers
    final returnMasterUrl =
        '$apicall/delivery_master/get_all_deliverymaster';

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
      bool isMatched = returnData.any((invoice) => invoice['deliveryId'] == orderId && invoice['status'] == "Delivered");

      if (isMatched) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('This Product Already Used Return Policy'),
          ),
        );


        setState(() {
          // _selectedReason = 'Reason for return';
          // _reasonController.text = 'Reason for return';
          ContactpersonController.text ='';
          EmailAddressController.text ='';
          _controller.text = '';
          _orderDetails = [];
          totalController.text = '';
        });
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
    print('enter');

    final apiUrl = '$apicall/delivery_master/update_delivery_master';

    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json'
    };

    List<Map<String, dynamic>> items1 = [];

    for (var item in items) {
      items1.add({
        // "deliveryId": item['deliveryId'],
        "deliveryMasterItemId": item['deliveryMasterItemId'],
        "category": item['category'],
        "price": item['price'],
        "productName": item['productName'],
        "qty": item['qty'],
        "actualAmount":item['actualAmount'],
        'discount': item['discount'],
        'tax': item['tax'],
        "subCategory": item['subCategory'],
        "totalAmount": item['totalAmount'],
      });
    }

    Map<String, dynamic> requestBody = {

      "deliveryId": widget.deliveryId,
      "comments": ShippingAddress.text,
      "contactNumber": ContactNumberContoller.text,
      "contactPerson": ContactperController.text,
      "deliveryAddress": DelAddController.text,
      "deliveryLocation": EmailIdController.text,
      "items": items1,
      "customerId" :CustomerIdcontroller.text,
      "invoiceNo": InvNoController.text,
      "pickedDate": _dateController.text,
      "orderId": _controller.text,
      // "status": "Delivered",
      "total": TotalController.text,
    };
    print(requestBody);
    final response = await http.put(
      Uri.parse(apiUrl),
      headers: headers,
      body: jsonEncode(requestBody),
    );

    if (response.statusCode == 200) {
      {

        print('Return Master added successfully');
        final responseBody = jsonDecode(response.body);
        print(responseBody);
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
                child: Text('Delivery has been picked', style: TextStyle(fontSize: 15),),
              ),
              actions: <Widget>[
                ElevatedButton(
                  child: const Text('OK',style: TextStyle(color: Colors.white),),
                  onPressed: () {
                    context.go('/Delivery_List');

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
      }
    } else {
      print('Error: ${response.statusCode}');
    }
  }
  Future<void> addReturnMaster() async {
    final orderId = widget.deliveryId?.trim();
    print('Order ID: $orderId');

    // Step 1: Fetch all return master data to get invoice numbers
    final returnMasterUrl =
        '$apicall/delivery_master/get_all_deliverymaster';

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
      bool isMatched = returnData.any((invoice) => invoice['deliveryId'] == orderId && invoice['status'] == "Delivered");

      if (isMatched) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('This Product Already Used Return Policy'),
          ),
        );


        setState(() {
          // _selectedReason = 'Reason for return';
          // _reasonController.text = 'Reason for return';
          ContactpersonController.text ='';
          EmailAddressController.text ='';
          _controller.text = '';
          _orderDetails = [];
          totalController.text = '';
        });
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
    print('enter');

    final apiUrl = '$apicall/delivery_master/update_delivered';

    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json'
    };

    List<Map<String, dynamic>> items1 = [];

    for (var item in items) {
      items1.add({
       // "deliveryId": item['deliveryId'],
        "deliveryMasterItemId": item['deliveryMasterItemId'],
        "category": item['category'],
        "price": item['price'],
        "productName": item['productName'],
        "qty": item['qty'],
        "actualAmount":item['actualAmount'],
        'discount': item['discount'],
        'tax': item['tax'],
        "subCategory": item['subCategory'],
        "totalAmount": item['totalAmount'],
      });
    }

    Map<String, dynamic> requestBody = {

      "deliveryId": widget.deliveryId,
      "comments": ShippingAddress.text,
      "contactNumber": ContactNumberContoller.text,
      "contactPerson": ContactperController.text,
      "deliveryAddress": DelAddController.text,
      "deliveryLocation": EmailIdController.text,
      "items": items1,
      "customerId" :CustomerIdcontroller.text,
      "invoiceNo": InvNoController.text,
      "deliveredDate": _dateController.text,
      "orderId": _controller.text,
      "total": TotalController.text,
    };
    print(requestBody);
    final response = await http.put(
      Uri.parse(apiUrl),
      headers: headers,
      body: jsonEncode(requestBody),
    );

    if (response.statusCode == 200) {
      final url = '$apicall/invoice_master/add_invoice_master';
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${token}',
      };
      final body = {
        "deliveryId": widget.deliveryId,
        "comments": ShippingAddress.text,
        "contactNumber": ContactNumberContoller.text,
        "contactPerson": ContactperController.text,
        "deliveryAddress": DelAddController.text,
        "deliveryLocation": EmailIdController.text,
        "items": items1,
        "customerId" :CustomerIdcontroller.text,
        "invoiceNo": InvNoController.text,
        "deliveredDate": _dateController.text,
        "orderId": _controller.text,
        "status": "Delivered",
        "total": TotalController.text,
      };

      final response = await http.post(Uri.parse(url), headers: headers, body: json.encode(body));

      if (response.statusCode == 200) {

        print('Return Master added successfully');
        final responseBody = jsonDecode(response.body);
        print(responseBody);
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
                child: Text('Delivery Confirmed Successfully', style: TextStyle(fontSize: 15),),
              ),
              actions: <Widget>[
                ElevatedButton(
                  child: const Text('OK',style: TextStyle(color: Colors.white),),
                  onPressed: () {
                    // context.go('/Return_List');
                    Navigator.of(context
                    ).pop(); // close the alert dialog
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                        const DeliveryList(),
                        transitionDuration: const Duration(milliseconds: 200),
                        transitionsBuilder: (context, animation, secondaryAnimation, child) {
                          return FadeTransition(
                            opacity: animation,
                            child: child,
                          );
                        },
                      ),
                    );
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
        print('API call failed with status code ${response.statusCode}');
      }
    } else {
      print('Error: ${response.statusCode}');
    }
  }



  Future<void> _fetchOrderDetails() async {
    final orderId = _controller.text.trim();
    final url = orderId.isEmpty
        ? '$apicall/order_master/get_all_ordermaster/'
        : '$apicall/order_master/search_by_orderid/$orderId';

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      print('Response: $jsonData');
      final orderData = jsonData.firstWhere(
              (order) => order['orderId'] == orderId, orElse: () => null);

      if (orderData != null) {
        setState(() {
          _orderDetails = orderData['items'].map((item) => {
            'productName': item['productName'],
            'qty': item['qty'],
            'totalAmount': item['totalAmount'],
            'price': item['price'],
            'tax': item['tax'],
            'discount': item['discount'],
            'category': item['category'],
            'actualAmount': item['price'] * item['qty'],
            'subCategory': item['subCategory']
          }).toList();
        });
      } else {
        setState(() {
          _orderDetails = [{'productName': 'not found'}];
        });
      }
    } else {
      setState(() {
        _orderDetails = [{'productName': 'Error fetching order details'}];
      });
    }
  }


  void _onFocusChange() {
    if (!_focusNode.hasFocus) {
      _fetchOrderDetails();
      _isLoading = true;
      _timer = Timer(const Duration(seconds: 2), () {
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
    print('delivery id this is');

    print(widget.deliverystatus);
    deliveryStatusController.text =
        widget.deliverystatus ?? '';

    print(widget.deliveryId);

    InvNoController.text = widget.invoice!;



    _fetchDeliveryDetails();
    _focusNode.addListener(_onFocusChange);
    _dateController = TextEditingController();
    //_qtyControllers = List.generate(_orderDetails.length, (index) => TextEditingController());
    _initializeControllers();
    _selectedDate = DateTime.now();
    String formattedDate = DateFormat('dd/MM/yyyy').format(_selectedDate!);
    _dateController.text = formattedDate;

  }




  Future<void> _fetchDeliveryDetails() async {
    String orderId = widget.deliveryId!;
    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json'
    };

    final response = await http.get(
      Uri.parse(
          '$apicall/delivery_master/get_all_deliverymaster'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      dynamic deliveryData;
      // Find the delivery data that matches the orderId
      for (var data in jsonData) {
        if (data['deliveryId'] == orderId) {
          deliveryData = data;
          break;
        }
      }

      if (deliveryData != null) {

        setState(() {
          print('hi2342');
          ShippingAddress.text = deliveryData['comments'] ?? '';
          ContactNumberContoller.text = deliveryData['contactNumber'] ?? '' ;
          ContactperController.text = deliveryData['contactPerson'] ?? '';
          DelAddController.text = deliveryData['deliveryAddress'] ?? '';
          EmailIdController.text = deliveryData['deliveryLocation'] ?? '';
          // _dateController.text = deliveryData['createdDate'] ?? '';
          _controller.text = deliveryData['orderId'] ?? '';
          CustomerIdcontroller.text = deliveryData['customerId'] ?? '';

          TotalController.text = deliveryData['total'].toString();
          print(deliveryData['items']);
          items.clear();
          for (var item in deliveryData['items']) {
            items.add({
              "category": item['category'],
              "price": item['price'],
              "productName": item['productName'],
              "qty": item['qty'],
              "tax": item['tax'],
              "discount": item['discount'],
              "actualAmount": item['actualAmount'],
              "subCategory": item['subCategory'],
              "totalAmount": item['totalAmount'],
            });
          }
        });
      } else {
        throw Exception('Delivery data not found for orderId $orderId');
      }
    } else {
      throw Exception('Failed to load delivery details');
    }
  }



  @override
  Widget build(BuildContext context) {
    if (_qtyControllers.length != _orderDetails.length) {
      _initializeControllers();
    }
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar:
      AppBar(
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
          const SizedBox(width: 10,),
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child:
            AccountMenu(),
          ),
        ],
      ),
      body: LayoutBuilder(
          builder: (context, constraints){
            double maxHeight = constraints.maxHeight;
            double maxWidth = constraints.maxWidth;
            TableRow row1 = const TableRow(
              children: [
                TableCell(
                  child: Padding(
                    padding: EdgeInsets.only(left: 30,top: 10,bottom: 10),
                    child: Text('Delivery Details',style: TextStyle(fontSize: 19),),
                  ),
                ),
                TableCell(
                  child: Text(''),
                ),
              ],
            );

            TableRow row2 = const TableRow(
              children: [
                TableCell(
                  child: Padding(
                    padding: EdgeInsets.only(left: 30,top: 10,bottom: 10),
                    child: Text('Billing Address',style: TextStyle(fontSize: 16),),
                  ),
                ),
                TableCell(
                  child: Padding(
                    padding: EdgeInsets.only(left: 10,top: 10,bottom: 10),
                    child: Text('Shipping Address',style: TextStyle(fontSize: 16),),
                  ),
                ),
              ],
            );
            TableRow row3 = TableRow(

              children: [
                TableCell(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding:  EdgeInsets.only(left: 30,top: 10),
                              child:  Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('Contact Person'),
                                  SizedBox(width: 5,),
                                  Text('*', style: TextStyle(color: Colors.red),),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10,),
                            Padding(
                              padding: const EdgeInsets.only(left: 30),
                              child: SizedBox(
                                width: maxWidth * 0.35,
                                height: 40,
                                child: TextField(
                                  controller: ContactperController,
                                  enabled: deliveryStatusController.text == "Delivered" ? _isEditing : true,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                        RegExp("[a-zA-Z ]")),
                                    // Allow only letters, numbers, and single space
                                    FilteringTextInputFormatter.deny(
                                        RegExp(r'^\s')),
                                    // Disallow starting with a space
                                    FilteringTextInputFormatter.deny(
                                        RegExp(r'\s\s')),
                                    // Disallow multiple spaces
                                  ],
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Colors.grey.shade100, // Changed to white
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5.0),
                                      borderSide: const BorderSide(color: Color(0xFFBBDEFB)), // Added blue border
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5.0),
                                      borderSide: const BorderSide(color: Colors.grey), // Added blue border
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5.0),
                                      borderSide: const BorderSide(color: Colors.blue), // Added blue border
                                    ),
                                    hintText: 'Contact Person Number',
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 8),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Padding(
                              padding:  EdgeInsets.only(left: 30),
                              child:  Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('Address'),
                                  SizedBox(width: 5,),
                                  Text('*', style: TextStyle(color: Colors.red),),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10,),
                            Padding(
                              padding:  const EdgeInsets.only(left: 30),
                              child: SizedBox(
                                width: maxWidth * 0.35,
                                height: 120,
                                child: TextField(
                                  enabled: deliveryStatusController.text == "Delivered" ? _isEditing : true,
                                   controller: DelAddController,
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Colors.grey.shade100, // Changed to white
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5.0),
                                      borderSide: const BorderSide(color: Color(0xFFBBDEFB)), // Added blue border
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5.0),
                                      borderSide: const BorderSide(color: Colors.grey), // Added blue border
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5.0),
                                      borderSide: const BorderSide(color: Colors.blue), // Added blue border
                                    ),
                                    hintText: 'Enter Your Address',
                                  ),

                                  inputFormatters: [


                                    FilteringTextInputFormatter.allow(
                                      RegExp("[a-zA-Z0-9-,./ \r\n]"), // Add \r\n to the pattern
                                    ),
                                    //  Allow only letters, numbers, and single space
                                    FilteringTextInputFormatter.deny(
                                        RegExp(r'^\s')),
                                    // Disallow starting with a space
                                    FilteringTextInputFormatter.deny(
                                        RegExp(r'\s\s')),
                                    //  Disallow multiple spaces
                                  ],
                                  maxLines: 3,

                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 30),
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(top: 10),
                              child:  Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('Contact Number'),
                                  SizedBox(width: 5,),
                                  Text('*', style: TextStyle(color: Colors.red),),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10,),
                            Padding(
                              padding: const  EdgeInsets.only(right: 20),
                              child: SizedBox(
                                width: maxWidth * 0.2,
                                // width: 370,
                                height: 40,
                                child: TextFormField(
                                  enabled: deliveryStatusController.text == "Delivered" ? _isEditing : true,
                                  controller: ContactNumberContoller,

                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Colors.grey.shade100, // Changed to white
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5.0),
                                      borderSide: const BorderSide(color: Color(0xFFBBDEFB)), // Added blue border
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5.0),
                                      borderSide: const BorderSide(color: Colors.grey), // Added blue border
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5.0),
                                      borderSide: const BorderSide(color: Colors.blue), // Added blue border
                                    ),
                                    hintText: 'Contact Person Name',
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 8),
                                  ),
                                  keyboardType:
                                  TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter
                                        .digitsOnly,
                                    LengthLimitingTextInputFormatter(
                                        10),
                                    // limits to 10 digits
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('Email Id'),
                                SizedBox(width: 5,),
                                Text('*', style: TextStyle(color: Colors.red),),
                              ],
                            ),
                            const SizedBox(height: 10,),
                            Padding(
                              padding: const EdgeInsets.only(right: 20),
                              child: SizedBox(
                                width: maxWidth * 0.2,
                                height: 40,
                                child: TextField(
                                  enabled: deliveryStatusController.text == "Delivered" ? _isEditing : true,
                                  controller: EmailIdController,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(RegExp("[a-zA-Z,0-9,@.]")),
                                    FilteringTextInputFormatter.deny(RegExp(r'^\s')),
                                    FilteringTextInputFormatter.deny(RegExp(r'\s\s')),
                                  ],

                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Colors.grey.shade100, // Changed to white
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5.0),
                                      borderSide: const BorderSide(color: Color(0xFFBBDEFB)), // Added blue border
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5.0),
                                      borderSide: const BorderSide(color: Colors.grey), // Added blue border
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5.0),
                                      borderSide: const BorderSide(color: Colors.blue), // Added blue border
                                    ),
                                    hintText: 'Contact Person Number',
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 8),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                TableCell(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('    '),
                              Padding(
                                padding: const EdgeInsets.only(right: 10,left: 10,bottom: 5),
                                child: SizedBox(
                                  height: 250,
                                  child: TextField(
                                    enabled: deliveryStatusController.text == "Delivered" ? _isEditing : true,
                                      controller: ShippingAddress,
                                    decoration: InputDecoration(
                                        filled: true,
                                        fillColor: Colors.grey.shade100, // Changed to white
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(5.0),
                                          borderSide: const BorderSide(color: Color(0xFFBBDEFB)), // Added blue border
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(5.0),
                                          borderSide: const BorderSide(color: Colors.grey), // Added blue border
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(5.0),
                                          borderSide: const BorderSide(color: Colors.blue), // Added blue border
                                        ),
                                        hintText: 'Enter Your Shipping Address'
                                    ),
                                    maxLines: 5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )

                ),
              ],
            );
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
                  padding: const EdgeInsets.only(left: 200,top: 0),
                  child: Container(
                    width: 1, // Set the width to 1 for a vertical line
                    height: 900, // Set the height to your liking
                    decoration: const BoxDecoration(
                      border: Border(left: BorderSide(width: 1, color: Colors.grey)),
                    ),
                  ),
                ),
                Positioned(
                    left: 202,
                    right: 0,
                    top: 0,
                    bottom: 0,
                    child:
                    Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          color: Colors.white,
                          height: 50,
                          child: Row(
                            children: [
                              IconButton(
                                icon:
                                const Icon(Icons.arrow_back), // Back button icon
                                onPressed: () {
                                  // context.go('/Create_return/Return_List');
                                  context.go('/Delivery_List');
                                },
                              ),
                              if(widget.deliverystatus == 'Created')...{
                                const Padding(
                                  padding: EdgeInsets.only(left: 30,top: 5),
                                  child: Text(
                                    'Item Picking',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              }
                              else if(widget.deliverystatus == 'Picked')...{
                                const Padding(
                                  padding: EdgeInsets.only(left: 30,top: 5),
                                  child: Text(
                                    'Confirm Delivery',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              }
                              else...{
                                  const Padding(
                                    padding: EdgeInsets.only(left: 30,top: 5),
                                    child: Text(
                                      'Delivery View',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                },

                              const Spacer(),
if(widget.deliverystatus == 'Picked')...{
  Align(
    alignment: Alignment.topRight,
    child: Padding(
      padding: const EdgeInsets.only(
          top: 10, right: 90),
      child:OutlinedButton(
        onPressed: () async {
          if(ContactperController.text.isEmpty || ContactperController.text.length <=2){
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Please enter a contact person name'),
              ),
            );
          }
          else if(EmailIdController.text.isEmpty || !RegExp(r'^[\w-]+(\.[\w-]+)*@[a-zA-Z0-9-]+\.(com|in|net)$').hasMatch(EmailIdController.text) ){  ScaffoldMessenger.of(context).showSnackBar(    SnackBar(content: Text(        'Enter Valid E-mail Address')),  );}
          else if (ShippingAddress.text.isEmpty){
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Please Enter Shipping Address'),
                //  backgroundColor: Colors.red,
              ),
            );
          }
          else if (DelAddController.text.isEmpty){
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Please Enter Delivery Address'),
                //  backgroundColor: Colors.red,
              ),
            );
          }
          else if(ContactNumberContoller.text.isEmpty || ContactNumberContoller.text.length !=10){
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Please enter a valid phone number.'),
              ),
            );
          }
          else{
            await addReturnMaster();
          }
          // await addReturnMaster();

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
          side: BorderSide.none, // No outline
        ),
        child: const Text(
          'Confirm Delivery',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w100,
            color: Colors.white,
          ),
        ),
      ),
    ),
  ),
}
            else if(widget.deliverystatus == 'Created')...{
  Align(
    alignment: Alignment.topRight,
    child: Padding(
      padding: const EdgeInsets.only(
          top: 10, right: 90),
      child:
      OutlinedButton(
        onPressed: () async {
          if(ContactperController.text.isEmpty || ContactperController.text.length <=2){
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Please enter a contact person name'),
              ),
            );
          }
          else if(EmailIdController.text.isEmpty || !RegExp(r'^[\w-]+(\.[\w-]+)*@[a-zA-Z0-9-]+\.(com|in|net)$').hasMatch(EmailIdController.text) ){  ScaffoldMessenger.of(context).showSnackBar(    SnackBar(content: Text(        'Enter Valid E-mail Address')),  );}
          else if (ShippingAddress.text.isEmpty){
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Please Enter Shipping Address'),
                //  backgroundColor: Colors.red,
              ),
            );
          }
          else if (DelAddController.text.isEmpty){
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Please Enter Delivery Address'),
                //  backgroundColor: Colors.red,
              ),
            );
          }
          else if(ContactNumberContoller.text.isEmpty || ContactNumberContoller.text.length !=10){
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Please enter a valid phone number.'),
              ),
            );
          }
          else{
            await addReturnMaster1();
          }
          // await addReturnMaster();

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
          side: BorderSide.none, // No outline
        ),
        child: const Text(
          'Pick Items',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w100,
            color: Colors.white,
          ),
        ),
      ) ,
    ),
  ),
            }
            else...{
              Container(),

  },

                            ],
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(
                              vertical: 1),
                          // Space above/below the border
                          height: 0.3, // Border height
                          color: Colors.black, // Border color
                        ),
                        if(constraints.maxWidth >= 1300)...{
                          Expanded(child: SingleChildScrollView(child: Stack(children: [

                            // Row(
                            //   crossAxisAlignment: CrossAxisAlignment.start,
                            //   children: [

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 30,right: 350,top: 20),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Padding(
                                                  padding: const EdgeInsets.only(left: 30,top: 20),
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Row(
                                                        mainAxisSize: MainAxisSize.min,
                                                        children: [
                                                          const Text('Delivery ID: ',style: TextStyle(fontWeight: FontWeight.bold),),
                                                          const SizedBox(width: 5,),
                                                          Text('${widget.deliveryId}', style: const TextStyle(color: Colors.black,fontWeight: FontWeight.bold),),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(right: 5),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(right: maxWidth * 0.08, top: 20),
                                        child: Text('Delivery Date', style: TextStyle(fontSize: maxWidth * 0.0090),),
                                      ),
                                      const SizedBox(height: 5,),
                                      Padding(
                                        padding: const EdgeInsets.only(right: 100),
                                        child: DecoratedBox(
                                          decoration: BoxDecoration(
                                            border: Border.all(color: const Color(0xFFEBF3FF), width: 1),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: SizedBox(
                                            height: 39,
                                            width: maxWidth * 0.13,
                                            child: Column(
                                              children: [
                                                Expanded(
                                                  child: TextFormField(
                                                    controller: _dateController,
                                                    readOnly: true,
                                                    decoration: InputDecoration(
                                                      suffixIcon: Padding(
                                                        padding: const EdgeInsets.only(right: 20),
                                                        child: Padding(
                                                          padding: const EdgeInsets.only(top: 2, left: 10),
                                                          child: IconButton(
                                                            icon: const Padding(
                                                              padding: EdgeInsets.only(bottom: 16),
                                                              child: Icon(Icons.calendar_month),
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
                                                      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                                      border: InputBorder.none,
                                                      filled: true,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 50, top: 100,right: 100),
                              child: Container(
                                height: 100,
                                width: maxWidth,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFFFFF), // background: #FFFFFF
                                  boxShadow: const [
                                    BoxShadow(
                                      offset: Offset(0, 3),
                                      blurRadius: 6,
                                      color: Color(0x29000000), // box-shadow: 0px 3px 6px #00000029
                                    )],
                                  border: Border.all(
                                    // border: 2px
                                    color: const Color(0xFFB2C2D3), // border: #B2C2D3
                                  ),
                                  borderRadius: const BorderRadius.all(Radius.circular(8)), // border-radius: 8px
                                ),
                                child:  Padding(
                                  padding: const EdgeInsets.only(top: 30),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      const Expanded(
                                        flex: 1,
                                        child: Column(
                                          children: [
                                            Icon(
                                              Icons.check_box,
                                              color: Colors.green,
                                            ),
                                            Text(
                                              'Order Created',
                                              style: TextStyle(
                                                color: Colors.black,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: Column(
                                          children: [
                                            Icon(
                                              Icons.check_box,
                                              color:  deliveryStatusController.text == 'Created'
                                                  ? Colors.grey
                                                  :  deliveryStatusController.text == 'Picked' || deliveryStatusController.text == 'Delivered'
                                                  ? Colors.green
                                                  : Colors.grey,// default color
                                            ),
                                            Text(
                                              'Picked',
                                              style: TextStyle(
                                                color: deliveryStatusController.text.toLowerCase() == 'Created'
                                                    ? Colors.grey
                                                    : deliveryStatusController.text.toLowerCase() == 'Picked' || deliveryStatusController.text.toLowerCase() == 'Delivered'
                                                    ? Colors.grey
                                                    : Colors.black,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: Column(
                                          children: [
                                            Icon(
                                              Icons.check_box,
                                              color: deliveryStatusController.text == 'Created' || deliveryStatusController.text == 'Picked'
                                                  ? Colors.grey
                                                  :  deliveryStatusController.text == 'Delivered'
                                                  ? Colors.green
                                                  : Colors.grey,
                                            ),
                                            const Text(
                                              'Delivered',
                                              style: TextStyle(
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                    ],
                                  ),
                                ),
                              ),
                            ),

                            // ],),


                            Padding(
                              padding: const EdgeInsets.only(left: 50,right: 100,top: 250),
                              child: Container(

                                decoration: const BoxDecoration(

                                   color: Color(0xFFFFFFFF), // background: #FFFFFF
                                  boxShadow: [BoxShadow(
                                    offset: Offset(0, 3),
                                    blurRadius: 6,
                                    color: Color(0x29000000), // box-shadow: 0px 3px 6px #00000029
                                  )],
                                  // border: Border.all(
                                  //   // border: 2px
                                  //   color: Color(0xFFB2C2D3), // border: #B2C2D3
                                  // ),
                                  borderRadius: BorderRadius.all(Radius.circular(4)), // border-radius: 8px
                                ),
                                child: Table(
                                  border: TableBorder.all(color: const Color(0xFFB2C2D3),borderRadius: BorderRadius.circular(4)),

                                  columnWidths: const {
                                    0: FlexColumnWidth(2),
                                    1: FlexColumnWidth(1.4),
                                  },
                                  children: [
                                    row1,
                                    row2,
                                    row3,
                                  ],
                                ),
                              ),
                            ),
                            _isLoading
                                ? const Padding(
                              padding: EdgeInsets.only(top: 250),
                              child: SpinKitWave(
                                color: Colors.blue,
                                size: 30.0,
                              ),
                            )
                                : Container(),
                            //  const SizedBox(height: 16),
                            Padding(
                              padding: const EdgeInsets.only(left: 50,right: 100,top: 670,bottom: 10),
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Padding(
                                      padding: EdgeInsets.only(top: 10,left: 30),
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
                                          top: BorderSide(color: Color(0xFFB2C2D3), width: 1.2),
                                          bottom: BorderSide(color: Color(0xFFB2C2D3), width: 1.2),
                                        ),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.only(top: 5, bottom: 5),
                                        child: Table(
                                          columnWidths: const {
                                            0: FlexColumnWidth(1),
                                            1: FlexColumnWidth(3),
                                            2: FlexColumnWidth(2),
                                            3: FlexColumnWidth(2),
                                            4: FlexColumnWidth(2),
                                            5: FlexColumnWidth(1),
                                            6: FlexColumnWidth(2),

                                          },
                                          children: const [
                                            TableRow(
                                                children: [
                                                  TableCell(child: Padding(
                                                    padding: EdgeInsets.only(top: 10, bottom: 10),
                                                    child: Center(
                                                      child: Text(
                                                        "SN",
                                                        style: TextStyle(
                                                          fontWeight: FontWeight.bold,
                                                          //  fontSize: 12,
                                                        ),
                                                      ),
                                                    ),
                                                  ),),
                                                  TableCell(child: Padding(
                                                    padding: EdgeInsets.only(top: 10, bottom: 10),
                                                    child: Center(
                                                      child: Text(
                                                        'Product Name',
                                                        style: TextStyle(
                                                          fontWeight: FontWeight.bold,
                                                          //  fontSize: 12,
                                                        ),
                                                      ),
                                                    ),
                                                  ),),
                                                  TableCell(child: Padding(
                                                    padding: EdgeInsets.only(top: 10, bottom: 10),
                                                    child: Center(
                                                      child: Text(
                                                        "Category",
                                                        style: TextStyle(
                                                          fontWeight: FontWeight.bold,
                                                          // fontSize: 12,
                                                        ),
                                                      ),
                                                    ),
                                                  ),),
                                                  TableCell(child: Padding(
                                                    padding: EdgeInsets.only(top: 10, bottom: 10),
                                                    child: Center(
                                                      child: Text(
                                                        "Sub Category",
                                                        style: TextStyle(
                                                          fontWeight: FontWeight.bold,
                                                          // fontSize: 12,
                                                        ),
                                                      ),
                                                    ),
                                                  ),),
                                                  TableCell(child: Padding(
                                                    padding: EdgeInsets.only(top: 10, bottom: 10),
                                                    child: Center(
                                                      child: Text(
                                                        "Price",
                                                        style: TextStyle(
                                                          fontWeight: FontWeight.bold,
                                                          // fontSize: 12,
                                                        ),
                                                      ),
                                                    ),
                                                  ),),
                                                  TableCell(child: Padding(
                                                    padding: EdgeInsets.only(top: 10, bottom: 10),
                                                    child: Center(
                                                      child: Text(
                                                        "QTY",
                                                        style: TextStyle(
                                                          fontWeight: FontWeight.bold,
                                                          // fontSize: 12,
                                                        ),
                                                      ),
                                                    ),
                                                  ),),
                                                  TableCell(child: Padding(
                                                    padding: EdgeInsets.only(top: 10, bottom: 10),
                                                    child: Center(
                                                      child: Text(
                                                        "Total Amount",
                                                        style: TextStyle(
                                                          fontWeight: FontWeight.bold,
                                                          //  fontSize: 12,
                                                        ),
                                                      ),
                                                    ),
                                                  ),),

                                                ]
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                    ListView.builder(
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      itemCount: items.length,
                                      itemBuilder: (context, index) {
                                        // if (index >= _orderDetails.length || index >= _qtyControllers.length) {
                                        //   return SizedBox.shrink(); // Return an empty widget if the index is out of range
                                        // }
                                        Map<String, dynamic> item = items[index];
                                        //Map<String, dynamic> item = _orderDetails[index];
                                        return Table(
                                          border: const TableBorder(
                                            bottom: BorderSide(width:1 ,color: Colors.grey),
                                            //   horizontalInside: BorderSide(width: 1,color: Colors.grey), // horizontal border inside the table
                                            verticalInside: BorderSide(width: 1,color: Colors.grey),
                                          ),
                                          // border: TableBorder.all(color: Colors.blue),
                                          //  Color(0xFFFFFFFF)
                                          columnWidths: const {
                                            0: FlexColumnWidth(1),
                                            1: FlexColumnWidth(3),
                                            2: FlexColumnWidth(2),
                                            3: FlexColumnWidth(2),
                                            4: FlexColumnWidth(2),
                                            5: FlexColumnWidth(1.2),
                                            6: FlexColumnWidth(2),

                                          },

                                          children: [
                                            TableRow(
                                                children:[
                                                  TableCell(
                                                    child: Padding(
                                                      padding: const EdgeInsets.only( left: 10,
                                                          right: 10,
                                                          top: 15,
                                                          bottom: 5),
                                                      child: Center(child: Text('${index + 1}')),
                                                    ),
                                                  ),
                                                  TableCell(
                                                    child: Padding(
                                                      padding: const EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10),
                                                      child: Container(
                                                        height: 35,
                                                        width: 50,
                                                        decoration: BoxDecoration(
                                                          color: Colors.grey.shade200,
                                                          borderRadius: BorderRadius.circular(4.0),
                                                        ),
                                                        child: Center(child: Text(item['productName'],textAlign: TextAlign.center,)),
                                                      ),
                                                    ),
                                                  ),
                                                  TableCell(
                                                    child: Padding(
                                                      padding: const EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10),
                                                      child: Container(
                                                        height: 35,
                                                        width: 50,
                                                        decoration: BoxDecoration(
                                                          color: Colors.grey.shade200,
                                                          borderRadius: BorderRadius.circular(4.0),
                                                        ),
                                                        child: Center(child: Text(item['category'],textAlign: TextAlign.center,)),
                                                      ),
                                                    ),
                                                  ),
                                                  TableCell(
                                                    child: Padding(
                                                      padding: const EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10),
                                                      child: Container(
                                                        height: 35,
                                                        width: 50,
                                                        decoration: BoxDecoration(
                                                          color: Colors.grey.shade200,
                                                          borderRadius: BorderRadius.circular(4.0),
                                                        ),
                                                        child: Center(child: Text(item['subCategory'])),
                                                      ),
                                                    ),
                                                  ),
                                                  TableCell(
                                                    child: Padding(
                                                      padding: const EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10),
                                                      child: Container(
                                                        height: 35,
                                                        width: 50,
                                                        decoration: BoxDecoration(
                                                          color: Colors.grey.shade200,
                                                          borderRadius: BorderRadius.circular(4.0),
                                                        ),
                                                        child: Center(child: Text(item['price'].toString())),
                                                      ),
                                                    ),
                                                  ),
                                                  TableCell(
                                                    child: Padding(
                                                      padding: const EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10),
                                                      child: Container(
                                                        height: 35,
                                                        width: 50,
                                                        decoration: BoxDecoration(
                                                          color: Colors.grey.shade200,
                                                          borderRadius: BorderRadius.circular(4.0),
                                                        ),
                                                        child: Center(child: Text(item['qty'].toString())),
                                                      ),
                                                    ),
                                                  ),
                                                  TableCell(
                                                    child: Padding(
                                                      padding: const EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10),
                                                      child: Container(
                                                        height: 35,
                                                        width: 50,
                                                        decoration: BoxDecoration(
                                                          color: Colors.grey.shade200,
                                                          borderRadius: BorderRadius.circular(4.0),
                                                        ),
                                                        child: Center(child: Text(item['totalAmount'].toString())),
                                                      ),
                                                    ),
                                                  ),

                                                ]
                                            )
                                          ],

                                        );
                                      },
                                    ),
                                    const SizedBox(height: 8),
                                    Padding(
                                      padding: const EdgeInsets.only(right: 25 ,top: 5,bottom: 5),
                                      child: Align(
                                        alignment: Alignment.centerRight,
                                        child: Container(
                                          height: 40,
                                          padding: const EdgeInsets.only(left: 15,right: 10,top: 6,bottom: 2),
                                          decoration: BoxDecoration(
                                            border: Border.all(color: const Color(0xFF0277BD)),
                                            borderRadius: BorderRadius.circular(2.0),
                                            color: Colors.white,
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.only(bottom: 2),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                RichText(text:
                                                TextSpan(
                                                  children: [
                                                    const TextSpan(
                                                      text:  'Total Amount',
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
                                                      text: TotalController.text,
                                                      style: const TextStyle(
                                                        color: Colors.black,
                                                      ),
                                                    ) ],
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
                          ],),))
                        }
                        else...{
                        Expanded(
                            child: AdaptiveScrollbar(
                              position: ScrollbarPosition.bottom,controller: horizontalScroll,
                              child: SingleChildScrollView(
                                controller: horizontalScroll,
                                scrollDirection: Axis.horizontal,
                                child: SingleChildScrollView(
                                                          child: Container(
                                                      width: 1700,
                                                      child: Stack(children: [

                                                        // Row(
                                                        //   crossAxisAlignment: CrossAxisAlignment.start,
                                                        //   children: [

                                                        Row(
                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                          children: [
                                                            Expanded(
                                                              flex: 1,
                                                              child: Padding(
                                                                padding: const EdgeInsets.only(left: 30,right: 350,top: 20),
                                                                child: Padding(
                                                                  padding: const EdgeInsets.all(16.0),
                                                                  child: Column(
                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                    children: [
                                                                      Row(
                                                                        children: [
                                                                          Expanded(
                                                                            child: Padding(
                                                                              padding: const EdgeInsets.only(left: 30,top: 20),
                                                                              child: Column(
                                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                                children: [
                                                          Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text('Delivery ID: ',style: TextStyle(fontWeight: FontWeight.bold),),
                                  const SizedBox(width: 5,),
                                  Text('${widget.deliveryId}', style: const TextStyle(color: Colors.black,fontWeight: FontWeight.bold),),
                                ],
                                                          ),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            Padding(
                                                              padding: const EdgeInsets.only(right: 5),
                                                              child: Column(
                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                children: [
                                                                  Padding(
                                                                    padding: EdgeInsets.only(right: maxWidth * 0.08, top: 20),
                                                                    child: Text('Delivery Date', style: TextStyle(fontSize: maxWidth * 0.0090),),
                                                                  ),
                                                                  const SizedBox(height: 5,),
                                                                  Padding(
                                                                    padding: const EdgeInsets.only(right: 100),
                                                                    child: DecoratedBox(
                                                                      decoration: BoxDecoration(
                                                                        border: Border.all(color: const Color(0xFFEBF3FF), width: 1),
                                                                        borderRadius: BorderRadius.circular(10),
                                                                      ),
                                                                      child: SizedBox(
                                                                        height: 39,
                                                                        width: 200,
                                                                        child: Column(
                                                                          children: [
                                                                            Expanded(
                                                                              child: TextFormField(
                                                                                controller: _dateController,
                                                                                readOnly: true,
                                                                                decoration: InputDecoration(
                                                          suffixIcon: Padding(
                                padding: const EdgeInsets.only(right: 20),
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 2, left: 10),
                                  child: IconButton(
                                    icon: const Padding(
                                      padding: EdgeInsets.only(bottom: 16),
                                      child: Icon(Icons.calendar_month),
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
                                                          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                                          border: InputBorder.none,
                                                          filled: true,
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),

                                                          ],
                                                        ),
                                                        Padding(
                                                          padding: const EdgeInsets.only(left: 50, top: 100,right: 100),
                                                          child: Container(
                                                            height: 100,
                                                            width: 1700,
                                                            decoration: BoxDecoration(
                                                              color: const Color(0xFFFFFFFF), // background: #FFFFFF
                                                              boxShadow: const [
                                                                BoxShadow(
                                                                  offset: Offset(0, 3),
                                                                  blurRadius: 6,
                                                                  color: Color(0x29000000), // box-shadow: 0px 3px 6px #00000029
                                                                )],
                                                              border: Border.all(
                                                                // border: 2px
                                                                color: const Color(0xFFB2C2D3), // border: #B2C2D3
                                                              ),
                                                              borderRadius: const BorderRadius.all(Radius.circular(8)), // border-radius: 8px
                                                            ),
                                                            child:  Padding(
                                                              padding: const EdgeInsets.only(top: 30),
                                                              child: Row(
                                                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                                children: [
                                                                  const Expanded(
                                                                    flex: 1,
                                                                    child: Column(
                                                                      children: [
                                                                        Icon(
                                                                          Icons.check_box,
                                                                          color: Colors.green,
                                                                        ),
                                                                        Text(
                                                                          'Order Created',
                                                                          style: TextStyle(
                                                                            color: Colors.black,
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                  Expanded(
                                                                    flex: 1,
                                                                    child: Column(
                                                                      children: [
                                                                        Icon(
                                                                          Icons.check_box,
                                                                          color:  deliveryStatusController.text == 'Created'
                                                                              ? Colors.grey
                                                                              :  deliveryStatusController.text == 'Picked' || deliveryStatusController.text == 'Delivered'
                                                                              ? Colors.green
                                                                              : Colors.grey,// default color
                                                                        ),
                                                                        Text(
                                                                          'Picked',
                                                                          style: TextStyle(
                                                                            color: deliveryStatusController.text.toLowerCase() == 'Created'
                                                                                ? Colors.grey
                                                                                : deliveryStatusController.text.toLowerCase() == 'Picked' || deliveryStatusController.text.toLowerCase() == 'Delivered'
                                                                                ? Colors.grey
                                                                                : Colors.black,
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                  Expanded(
                                                                    flex: 1,
                                                                    child: Column(
                                                                      children: [
                                                                        Icon(
                                                                          Icons.check_box,
                                                                          color: deliveryStatusController.text == 'Created' || deliveryStatusController.text == 'Picked'
                                                                              ? Colors.grey
                                                                              :  deliveryStatusController.text == 'Delivered'
                                                                              ? Colors.green
                                                                              : Colors.grey,
                                                                        ),
                                                                        const Text(
                                                                          'Delivered',
                                                                          style: TextStyle(
                                                                            color: Colors.grey,
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),

                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        ),

                                                        // ],),


                                                        Padding(
                                                          padding: const EdgeInsets.only(left: 50,right: 100,top: 250),
                                                          child: Container(

                                                            decoration: const BoxDecoration(

                                                              color: Color(0xFFFFFFFF), // background: #FFFFFF
                                                              boxShadow: [BoxShadow(
                                                                offset: Offset(0, 3),
                                                                blurRadius: 6,
                                                                color: Color(0x29000000), // box-shadow: 0px 3px 6px #00000029
                                                              )],
                                                              // border: Border.all(
                                                              //   // border: 2px
                                                              //   color: Color(0xFFB2C2D3), // border: #B2C2D3
                                                              // ),
                                                              borderRadius: BorderRadius.all(Radius.circular(4)), // border-radius: 8px
                                                            ),
                                                            child: Table(
                                                              border: TableBorder.all(color: const Color(0xFFB2C2D3),borderRadius: BorderRadius.circular(4)),

                                                              columnWidths: const {
                                                                0: FlexColumnWidth(2),
                                                                1: FlexColumnWidth(1.4),
                                                              },
                                                              children: [
                                                                row1,
                                                                row2,
                                                                row3,
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                        _isLoading
                                                            ? const Padding(
                                                          padding: EdgeInsets.only(top: 250),
                                                          child: SpinKitWave(
                                                            color: Colors.blue,
                                                            size: 30.0,
                                                          ),
                                                        )
                                                            : Container(),
                                                        //  const SizedBox(height: 16),
                                                        Padding(
                                                          padding: const EdgeInsets.only(left: 50,right: 100,top: 670,bottom: 10),
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
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              children: [
                                                                const Padding(
                                                                  padding: EdgeInsets.only(top: 10,left: 30),
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
                                                                      top: BorderSide(color: Color(0xFFB2C2D3), width: 1.2),
                                                                      bottom: BorderSide(color: Color(0xFFB2C2D3), width: 1.2),
                                                                    ),
                                                                  ),
                                                                  child: Padding(
                                                                    padding: const EdgeInsets.only(top: 5, bottom: 5),
                                                                    child: Table(
                                                                      columnWidths: const {
                                                                        0: FlexColumnWidth(1),
                                                                        1: FlexColumnWidth(3),
                                                                        2: FlexColumnWidth(2),
                                                                        3: FlexColumnWidth(2),
                                                                        4: FlexColumnWidth(2),
                                                                        5: FlexColumnWidth(1),
                                                                        6: FlexColumnWidth(2),

                                                                      },
                                                                      children: const [
                                                                        TableRow(
                                                                            children: [
                                                                              TableCell(child: Padding(
                                                                                padding: EdgeInsets.only(top: 10, bottom: 10),
                                                                                child: Center(
                                                          child: Text(
                                "SN",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  //  fontSize: 12,
                                ),
                                                          ),
                                                                                ),
                                                                              ),),
                                                                              TableCell(child: Padding(
                                                                                padding: EdgeInsets.only(top: 10, bottom: 10),
                                                                                child: Center(
                                                          child: Text(
                                'Product Name',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  //  fontSize: 12,
                                ),
                                                          ),
                                                                                ),
                                                                              ),),
                                                                              TableCell(child: Padding(
                                                                                padding: EdgeInsets.only(top: 10, bottom: 10),
                                                                                child: Center(
                                                          child: Text(
                                "Category",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  // fontSize: 12,
                                ),
                                                          ),
                                                                                ),
                                                                              ),),
                                                                              TableCell(child: Padding(
                                                                                padding: EdgeInsets.only(top: 10, bottom: 10),
                                                                                child: Center(
                                                          child: Text(
                                "Sub Category",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  // fontSize: 12,
                                ),
                                                          ),
                                                                                ),
                                                                              ),),
                                                                              TableCell(child: Padding(
                                                                                padding: EdgeInsets.only(top: 10, bottom: 10),
                                                                                child: Center(
                                                          child: Text(
                                "Price",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  // fontSize: 12,
                                ),
                                                          ),
                                                                                ),
                                                                              ),),
                                                                              TableCell(child: Padding(
                                                                                padding: EdgeInsets.only(top: 10, bottom: 10),
                                                                                child: Center(
                                                          child: Text(
                                "QTY",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  // fontSize: 12,
                                ),
                                                          ),
                                                                                ),
                                                                              ),),
                                                                              TableCell(child: Padding(
                                                                                padding: EdgeInsets.only(top: 10, bottom: 10),
                                                                                child: Center(
                                                          child: Text(
                                "Total Amount",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  //  fontSize: 12,
                                ),
                                                          ),
                                                                                ),
                                                                              ),),

                                                                            ]
                                                                        )
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ),
                                                                ListView.builder(
                                                                  shrinkWrap: true,
                                                                  physics: const NeverScrollableScrollPhysics(),
                                                                  itemCount: items.length,
                                                                  itemBuilder: (context, index) {
                                                                    // if (index >= _orderDetails.length || index >= _qtyControllers.length) {
                                                                    //   return SizedBox.shrink(); // Return an empty widget if the index is out of range
                                                                    // }
                                                                    Map<String, dynamic> item = items[index];
                                                                    //Map<String, dynamic> item = _orderDetails[index];
                                                                    return Table(
                                                                      border: const TableBorder(
                                                                        bottom: BorderSide(width:1 ,color: Colors.grey),
                                                                        //   horizontalInside: BorderSide(width: 1,color: Colors.grey), // horizontal border inside the table
                                                                        verticalInside: BorderSide(width: 1,color: Colors.grey),
                                                                      ),
                                                                      // border: TableBorder.all(color: Colors.blue),
                                                                      //  Color(0xFFFFFFFF)
                                                                      columnWidths: const {
                                                                        0: FlexColumnWidth(1),
                                                                        1: FlexColumnWidth(3),
                                                                        2: FlexColumnWidth(2),
                                                                        3: FlexColumnWidth(2),
                                                                        4: FlexColumnWidth(2),
                                                                        5: FlexColumnWidth(1.2),
                                                                        6: FlexColumnWidth(2),

                                                                      },

                                                                      children: [
                                                                        TableRow(
                                                                            children:[
                                                                              TableCell(
                                                                                child: Padding(
                                                          padding: const EdgeInsets.only( left: 10,
                                  right: 10,
                                  top: 15,
                                  bottom: 5),
                                                          child: Center(child: Text('${index + 1}')),
                                                                                ),
                                                                              ),
                                                                              TableCell(
                                                                                child: Padding(
                                                          padding: const EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10),
                                                          child: Container(
                                height: 35,
                                width: 50,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(4.0),
                                ),
                                child: Center(child: Text(item['productName'],textAlign: TextAlign.center,)),
                                                          ),
                                                                                ),
                                                                              ),
                                                                              TableCell(
                                                                                child: Padding(
                                                          padding: const EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10),
                                                          child: Container(
                                height: 35,
                                width: 50,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(4.0),
                                ),
                                child: Center(child: Text(item['category'],textAlign: TextAlign.center,)),
                                                          ),
                                                                                ),
                                                                              ),
                                                                              TableCell(
                                                                                child: Padding(
                                                          padding: const EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10),
                                                          child: Container(
                                height: 35,
                                width: 50,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(4.0),
                                ),
                                child: Center(child: Text(item['subCategory'])),
                                                          ),
                                                                                ),
                                                                              ),
                                                                              TableCell(
                                                                                child: Padding(
                                                          padding: const EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10),
                                                          child: Container(
                                height: 35,
                                width: 50,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(4.0),
                                ),
                                child: Center(child: Text(item['price'].toString())),
                                                          ),
                                                                                ),
                                                                              ),
                                                                              TableCell(
                                                                                child: Padding(
                                                          padding: const EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10),
                                                          child: Container(
                                height: 35,
                                width: 50,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(4.0),
                                ),
                                child: Center(child: Text(item['qty'].toString())),
                                                          ),
                                                                                ),
                                                                              ),
                                                                              TableCell(
                                                                                child: Padding(
                                                          padding: const EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10),
                                                          child: Container(
                                height: 35,
                                width: 50,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(4.0),
                                ),
                                child: Center(child: Text(item['totalAmount'].toString())),
                                                          ),
                                                                                ),
                                                                              ),

                                                                            ]
                                                                        )
                                                                      ],

                                                                    );
                                                                  },
                                                                ),
                                                                const SizedBox(height: 8),
                                                                Padding(
                                                                  padding: const EdgeInsets.only(right: 25 ,top: 5,bottom: 5),
                                                                  child: Align(
                                                                    alignment: Alignment.centerRight,
                                                                    child: Container(
                                                                      height: 40,
                                                                      padding: const EdgeInsets.only(left: 15,right: 10,top: 6,bottom: 2),
                                                                      decoration: BoxDecoration(
                                                                        border: Border.all(color: const Color(0xFF0277BD)),
                                                                        borderRadius: BorderRadius.circular(2.0),
                                                                        color: Colors.white,
                                                                      ),
                                                                      child: Padding(
                                                                        padding: const EdgeInsets.only(bottom: 2),
                                                                        child: Row(
                                                                          mainAxisSize: MainAxisSize.min,
                                                                          children: [
                                                                            RichText(text:
                                                                            TextSpan(
                                                                              children: [
                                                                                const TextSpan(
                                                          text:  'Total Amount',
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
                                                          text: TotalController.text,
                                                          style: const TextStyle(
                                color: Colors.black,
                                                          ),
                                                                                ) ],
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
                                                      ],),
                                                          ),
                                                        ),
                              ),
                            )),

                        }

                      ],
                    ))

              ],
            );
          }
      ),
    );
  }
}


String removeCharAt(String str, int index) {
  return str.substring(0, index) + str.substring(index + 1);
}

DataRow dataRow(int sn, String productName, String brand, String category, String subCategory, String price, int qty, int returnQty, String invoiceAmount, String creditRequest) {
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