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

void main() {
  runApp(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        home: DeliveryDetail(),)
  );
}



class DeliveryDetail extends StatefulWidget {

  DeliveryDetail({super.key,
  });
  @override
  State<DeliveryDetail> createState() {
    return _DeliveryDetailState();
  }
}

class _DeliveryDetailState extends State<DeliveryDetail> with SingleTickerProviderStateMixin{
  final ScrollController horizontalScroll = ScrollController();
  String? _selectedReason = 'Reason for return';
  final _controller = TextEditingController();
  final TextEditingController InvNoController = TextEditingController();
  List<dynamic> _orderDetails = [];
 bool _isLoading= false;
  Timer? _timer;
  late TextEditingController _dateController;
  String selectedValue = 'Select Location';
  bool _isEditing = false;
  List<TextEditingController> _qtyControllers = [];
  String? _errorText;
  final List<String> list = ['Select Location','  Name 1', '  Name 2', '  Name3'];
  int Index =1 ;
  bool isOrdersSelected = false;
  double totalAmount = 0.0;
  final _textController = TextEditingController();
  final totalController = TextEditingController();
  List<String> storeImages = [];
  DateTime? _selectedDate;
  List<String> imageSizeStrings = [];
  String? errorMessage;
  final TextEditingController NotesController = TextEditingController();
  final TextEditingController TotalController = TextEditingController();
  final TextEditingController EmailAddressController = TextEditingController();
  final TextEditingController ContactpersonController = TextEditingController();
  final TextEditingController deliveryAddressController = TextEditingController();
  final _reasonController = TextEditingController();
  String _enteredValue = '';
  String token = window.sessionStorage["token"] ?? " ";
  final TextEditingController DelAddController = TextEditingController();
  final TextEditingController CustomerIdController = TextEditingController();
  final TextEditingController EmailIdController = TextEditingController();
  final TextEditingController ShippingAddress = TextEditingController();
  final TextEditingController ContactperController = TextEditingController();
  final TextEditingController ContactNumberContoller = TextEditingController();
  double _totalAmount = 0;
  //Timer? _timer;
  String Status='';


  final FocusNode _focusNode = FocusNode();
  late AnimationController _controller1;
  bool _isHovered1 = false;
  late Animation<double> _shakeAnimation;


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
      _buildMenuItem('Customer', Icons.account_circle_outlined, Colors.blue[900]!, '/Customer'),
      _buildMenuItem('Products', Icons.image_outlined, Colors.blue[900]!, '/Product_List'),
      _buildMenuItem('Orders', Icons.warehouse_outlined, Colors.blue[900]!, '/Order_List'),

      Container(
          decoration: BoxDecoration(
            color: Colors.blue[800]  ,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8), // Radius for top-left corner
              topRight: Radius.circular(8), // No radius for top-right corner
              bottomLeft: Radius.circular(8), // Radius for bottom-left corner
              bottomRight: Radius.circular(8), // No radius for bottom-right corner
            ),
          ),
          child: _buildMenuItem('Delivery', Icons.fire_truck_outlined, Colors.white, '/Delivery_List')),
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
    _focusNode.addListener(_onFocusChange);
    _controller1 = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 5)
        .chain(CurveTween(curve: Curves.elasticIn))
        .animate(_controller1)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _controller1.reverse();
        } else if (status == AnimationStatus.dismissed) {
          _controller1.forward();
        }
      });
    _controller.addListener(() {
      if (_controller.text.isEmpty || _controller.text.length != 9) {
        setState(() {
          _isEditing = false;
          Status = '';
          selectedValue = 'Select Location';
          DelAddController.clear();
          ShippingAddress.clear();
          ContactperController.clear();
          ContactNumberContoller.clear();
          TotalController.clear();
          _orderDetails = [];
        });
      }
    });
    _dateController = TextEditingController();
    //_qtyControllers = List.generate(_orderDetails.length, (index) => TextEditingController());
    _initializeControllers();
    _selectedDate = DateTime.now();
    String formattedDate = DateFormat('dd/MM/yyyy').format(_selectedDate!);
    _dateController.text = formattedDate;
  }




  Future<void> addReturnMaster() async {
    final orderId = _controller.text.trim().toUpperCase();
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
      bool isMatched = returnData.any((invoice) => invoice['orderId'] == orderId);

      if (isMatched) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('This product Move on to Delivery'),
          ),
        );
        setState(() {
          _orderDetails = [];
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
              (order) => order['orderId'] == orderId, orElse: () => null

      );
      if (orderData == null) {
        // Show the ScaffoldMessenger with a SnackBar
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please Enter a valid Order ID'),
          ),
        );
        // Handle the case when orderData is null (if needed)
      }

      print('details');
      print(orderData);
      if (orderData != null) {
        print('enter');

        final apiUrl = '$apicall/delivery_master/add_delivery_master';

        final headers = {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json'
        };

        List<Map<String, dynamic>> items = [];

        for (var item in _orderDetails) {
          items.add({
            "category": item['category'],
            "price": item['price'],
            "productName": item['productName'],
            "qty": item['qty'],
            "discount": item['discount'],
            "tax": item['tax'],
            "actualAmount":item['price'] * item['qty'],
            "subCategory": item['subCategory'],
            "totalAmount": item['totalAmount'],
          });
        }

        Map<String, dynamic> requestBody = {
            "comments": ShippingAddress.text,
            "contactNumber": ContactNumberContoller.text,
            "contactPerson": ContactperController.text,
            "customerId":  CustomerIdController.text,
            "deliveryAddress":  DelAddController.text,
            "deliveryLocation":  EmailIdController.text,
            "invoiceNo": InvNoController.text,
            "items": items,
            "createdDate": _dateController.text,
            "orderId":  _controller.text,
            "total":TotalController.text,
        };

        print(requestBody);

        final response = await http.post(
          Uri.parse(apiUrl),
          headers: headers,
          body: jsonEncode(requestBody),
        );

        if (response.statusCode == 200) {
          print('Return Master added successfully');
          final responseBody = jsonDecode(response.body);
          print(responseBody);
           final DeliveryId = responseBody['id'];

          await showDialog(
            barrierDismissible: false,
            context: context,
            builder: (BuildContext context) {
              return
                AlertDialog(  shape: const RoundedRectangleBorder(    side: BorderSide(color: Colors.blue, width: 1),     borderRadius: BorderRadius.all(Radius.circular(4)),  ),  backgroundColor: Colors.white,  content: Padding(      padding: const EdgeInsets.only(left: 25),      child: Row(        children: [          const Text('Your Delivery ID is: ',style: TextStyle(color: Colors.black),),          SelectableText('$DeliveryId',style: const TextStyle(color: Colors.black),),        ],      )  ),  actions: <Widget>[    ElevatedButton(      child: const Text('OK',style: TextStyle(color: Colors.white),),      onPressed: () {                     context.go('/Delivery_List');      },      style: ElevatedButton.styleFrom(        backgroundColor: Colors.blue,        side: const BorderSide(color: Colors.blue),        shape: RoundedRectangleBorder(          borderRadius: BorderRadius.circular(10.0),        ),      ),    ),  ],);
            },
          );
        } else {
          print('Error: ${response.statusCode}');
        }
      } else {
        setState(() {
          _orderDetails = [{'productName': 'not found'}];
        });
      }
    }else {
      setState(() {
        _orderDetails = [{'productName': 'Error fetching order details'}];
      });
    }
  }

  Future<void> _fetchOrderDetails() async {
    final orderId = _controller.text.trim().toUpperCase();
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
      bool isMatched = returnData.any((invoice) => invoice['orderId'] == orderId);

      if (isMatched) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('This product Move on to Delivery'),
          ),
        );
        setState(() {
          _orderDetails = [];
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
      Status ='';

      final orderData = jsonData.firstWhere(
            (order) => order['orderId'] == orderId, orElse: () =>
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please Enter valid Order Id'),
            ),
          ),
      );
      Status = orderData['status'];
      print('details');
      print(orderData);
      if (orderData != null) {
        setState(() {

          CustomerIdController.text = orderData['customerId'];
          EmailIdController.text = orderData['deliveryLocation'];
          DelAddController.text = orderData['deliveryAddress'];
          InvNoController.text = orderData['invoiceNo'];
          print('eel');
          print(DelAddController.text);
          ShippingAddress.text = orderData['comments'];
          ContactperController.text = orderData['contactPerson'];
          ContactNumberContoller.text =  orderData['contactNumber'];
          print(orderData['total']);
          TotalController.text = orderData['total'].toString();
          _orderDetails = orderData['items'].map((item) => {
            'productName': item['productName'],
            'qty': item['qty'],
            'discount': item['discount'],
            'tax': item['tax'],
            'ActualTotalAmount':item['ActualTotalAmount'],
            'totalAmount': item['totalAmount'],
            'price': item['price'],
            'category': item['category'],
            'subCategory': item['subCategory']
          }).toList();
        });
      } else {
        setState(() {
          _orderDetails = [{'productName': 'not found'}];
        });
      }
    }else {
      setState(() {
        _orderDetails = [{'productName': 'Error fetching order details'}];
      });
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

            TableRow row1 =  TableRow(
              children: [
                const TableCell(
                  child: Padding(
                    padding: EdgeInsets.only(left: 30,top: 10,bottom: 10),
                    child: Text('Delivery Details',style: TextStyle(fontSize: 19),),
                  ),
                ),
                TableCell(
                  child:
                  Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding:  const EdgeInsets.only(
                          top: 10, right: 30),
                      child:OutlinedButton(
                        onPressed: () {
                          if(_controller.text.isEmpty){
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please fill order Id'),
                                //  backgroundColor: Colors.red,
                              ),
                            );
                          }
                          else if(_orderDetails.isEmpty){
                            _fetchOrderDetails();

                          }
                          else {
                            _timer = Timer(const Duration(milliseconds: 2), () {

                              setState(() {
                                _isLoading = true;
                                _isEditing = true;
                                _timer = Timer(const Duration(seconds: 1), () {
                                  setState(() {
                                    _isLoading = false;
                                  });
                                });
                              });
                            });
                          }
                        },
                        style: OutlinedButton.styleFrom(
                          backgroundColor: _isEditing? Colors.blue[200]: Colors.blue[800],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                          side: BorderSide.none,
                        ),
                        onHover: null,                        child: Text(
                        _isEditing ? 'Edit' : 'Edit',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w100,
                          color: Colors.white,
                        ),
                      ),
                      ),
                    ),
                  ),
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
                              padding:  const EdgeInsets.only(left: 30),
                              child: SizedBox(
                                width: maxWidth * 0.35,
                                height: 40,
                                child: TextField(
                                  controller: ContactperController,
                                  enabled: _isEditing,
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Colors.grey.shade100, // Changed to white
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5.0),
                                      borderSide: const BorderSide(color: Color(0xFFBBDEFB)), // Added blue border
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 8),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5.0),
                                      borderSide: const BorderSide(color: Colors.grey), // Added blue border
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5.0),
                                      borderSide: const BorderSide(color: Colors.blue), // Added blue border
                                    ),
                                    hintText: 'Enter Your Name',
                                  ),

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
                                  enabled: _isEditing,
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
                                  enabled: _isEditing,
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
                                    hintText: 'Contact Your Number',
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
                                Text('Email ID'),
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
                                  enabled: _isEditing,
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
                                    hintText: 'Enter your Email ID',
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
                                    enabled: _isEditing,
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
                                        hintText: 'Enter Shipping Address'
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
                                //  context.go('/Return_List');
                                context.go('/Delivery_List');

                                },
                              ),
                              const Padding(
                                padding: EdgeInsets.only(left: 15,top: 5),
                                child: Text(
                                  'Create Delivery',
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
                                  padding: const EdgeInsets.only(
                                      top: 10, right: 90),
                                  child: AnimatedBuilder(
                                    animation: _controller1,
                                    builder: (context, child) {

                                      return Transform.translate(offset: Offset(_isHovered1? _shakeAnimation.value : 0,0),
                                        child: AnimatedContainer(
                                        duration: const Duration(milliseconds: 300),
                                        curve: Curves.easeInOut,
                                        decoration: BoxDecoration(
                                          color: _isHovered1
                                              ? Colors.blue[800]
                                              : Colors.blue[800], // Background color change on hover
                                          borderRadius: BorderRadius.circular(5),
                                          boxShadow: _isHovered1
                                              ? [
                                            const BoxShadow(
                                                color: Colors.black45,
                                                blurRadius: 6,
                                                spreadRadius: 2)
                                          ]
                                              : [],
                                        ),
                                        child: OutlinedButton(
                                          onPressed: () async {
                                            print('naveen');
                                            if(_controller.text.isEmpty){
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(
                                                  content: Text('Please fill Order Id'),
                                        //  backgroundColor: Colors.red,
                                                ),
                                              );
                                            }
                                            else if(_orderDetails.isEmpty){
                                              _fetchOrderDetails();
                                            }
                                            else if(EmailIdController.text.isEmpty || !RegExp(r'^[\w-]+(\.[\w-]+)*@[a-zA-Z0-9-]+\.(com|in|net)$').hasMatch(EmailIdController.text) ){  ScaffoldMessenger.of(context).showSnackBar(    SnackBar(content: Text(        'Enter Valid E-mail Address')),  );}
                                            else if(ContactperController.text.isEmpty || ContactperController.text.length <=2){
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(
                                                  content: Text('Please enter a contact person name'),
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
                                            else if (ShippingAddress.text.isEmpty){
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(
                                                  content: Text('Please Enter Shipping Address'),
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
                                            'Create Delivery',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w100,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ));
                                    }
                                  ),
                                ),
                              ),
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
                          Expanded(child:
                          SingleChildScrollView(
                            child:
                            Stack(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      flex: 1,
                                      child: Padding(
                                        padding: const EdgeInsets.only(left: 30,top: 20),
                                        child: Padding(
                                          padding: const EdgeInsets.all(16.0),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        const Row(
                                                          mainAxisSize: MainAxisSize.min,
                                                          children: [
                                                            Text('Order ID'),
                                                            SizedBox(width: 5,),
                                                            Text('*', style: TextStyle(color: Colors.red),),
                                                          ],
                                                        ),

                                                        const SizedBox(height: 5,),
                                                        SizedBox(
                                                          height: 40,
                                                          width: maxWidth * 0.12,
                                                          child: TextFormField(
                                                            controller: _controller,
                                                            focusNode: _focusNode,
                                                            //  onEditingComplete: _fetchOrderDetails,
                                                            decoration: InputDecoration(
                                                              filled: true,
                                                              contentPadding: const EdgeInsets.symmetric(vertical: 10,horizontal: 12),
                                                              fillColor: Colors.white,
                                                              // border: InputBorder.none,
                                                              // focusedBorder: OutlineInputBorder(
                                                              //   borderRadius: BorderRadius.circular(5.0),
                                                              //   borderSide: const BorderSide(color: Colors.white), // Added blue border
                                                              // ),
                                                              border: OutlineInputBorder(
                                                                borderRadius: BorderRadius.circular(5.0),
                                                                borderSide: BorderSide.none,
                                                              ),
                                                              hintText: 'ORD_00392',
                                                            ),
                                                            inputFormatters: [
                                                              UpperCaseTextFormatter(),
                                                              FilteringTextInputFormatter.allow(
                                                                  RegExp("[a-zA-Z_0-9]")),
                                                              // Allow only letters, numbers, and single space
                                                              FilteringTextInputFormatter.deny(
                                                                  RegExp(r'^\s')),
                                                              // Disallow starting with a space
                                                              FilteringTextInputFormatter.deny(
                                                                  RegExp(r'\s\s')),
                                                              // Disallow multiple spaces
                                                            ],
                                                            validator: (value) {
                                                              if (_controller.text != null && _controller.text.trim().isEmpty) {
                                                                return 'Please enter a product name';
                                                              }
                                                              return null;
                                                            },
                                                          ),
                                                        ),
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
                                    Padding(
                                      padding:  const EdgeInsets.only(right: 5),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.only(right: maxWidth * 0.08, top: 20),
                                            child: const Text('Delivery Date', style: TextStyle(fontSize: 13),),
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
                                  padding: const EdgeInsets.only(left: 50, top: 140,right: 100),
                                  child: Container(
                                    height: 100,
                                    width: maxWidth,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFFFFF), // background: #FFFFFF
                                      boxShadow: [const BoxShadow(
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
                                          Expanded(
                                            flex: 1,
                                            child: Column(
                                              children: [
                                                if(Status == 'Created')...{
                                                  const Icon(
                                                    Icons.check_box,
                                                    color: Colors.green,
                                                  ),
                                                }
                                                else...{
                                                  const Icon(
                                                    Icons.check_box,
                                                    color: Colors.grey,
                                                  ),
                                                },
                                                const Text(
                                                  'Order Created',
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const Expanded(
                                            flex: 1,
                                            child: Column(
                                              children: [
                                                Icon(
                                                  Icons.check_box,
                                                  color:  Colors.grey,// default color
                                                ),
                                                Text(
                                                  'Picked',
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const Expanded(
                                            flex: 1,
                                            child: Column(
                                              children: [
                                                Icon(
                                                  Icons.check_box,
                                                  color:  Colors.grey,
                                                ),
                                                Text(
                                                  'Delivered',
                                                  style: TextStyle(
                                                    color: Colors.black,
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

                                Padding(
                                  padding: const EdgeInsets.only(left: 50,right: 100,top: 290),
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
                                  padding: EdgeInsets.only(top: 500),
                                  child: SpinKitWave(
                                    color: Colors.blue,
                                    size: 30.0,
                                  ),
                                )
                                    : Container(),

                                // const SizedBox(height: 16),
                                Padding(
                                  padding: const EdgeInsets.only(left: 50,right: 100,top: 700,bottom: 10),
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
                                          itemCount: _orderDetails.length,
                                          itemBuilder: (context, index) {
                                            if (index >= _orderDetails.length || index >= _qtyControllers.length) {
                                              return const SizedBox.shrink(); // Return an empty widget if the index is out of range
                                            }
                                            Map<String, dynamic> item = _orderDetails[index];
                                            return Table(
                                              border: const TableBorder(
                                                bottom: BorderSide(width:1 ,color: Colors.grey),
                                                //   horizontalInside: BorderSide(width: 1,color: Colors.grey), // horizontal border inside the table
                                                verticalInside: BorderSide(width: 1,color: Colors.grey),
                                              ),
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
                                                            child: Center(child: Text(item['totalAmount'].toStringAsFixed(2))),
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
                                          padding: const EdgeInsets.only(right: 60 ,top: 5,bottom: 5),
                                          child: Align(
                                            alignment: Alignment.centerRight,
                                            child: Container(
                                              height: 40,
                                              padding: const EdgeInsets.only(left: 5,right: 10,top: 6,bottom: 2),
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
                                                          text:  'Total :',
                                                          style: TextStyle(
                                                              fontSize: 14,
                                                              color: Colors.blue
                                                            // fontWeight: FontWeight.bold,
                                                          ),
                                                        ),
                                                        const TextSpan(
                                                          text: ' ₹',
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
                          Expanded(child:
                          AdaptiveScrollbar(

                            position: ScrollbarPosition.bottom,controller: horizontalScroll,
                            child: SingleChildScrollView(
                              controller: horizontalScroll,
                              scrollDirection: Axis.horizontal,
                              child: SingleChildScrollView(
                                child:
                                Container(
                                  width: 1700,
                                  child: Stack(
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            flex: 1,
                                            child: Padding(
                                              padding: const EdgeInsets.only(left: 30,top: 20),
                                              child: Padding(
                                                padding: const EdgeInsets.all(16.0),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Expanded(
                                                          child: Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              const Row(
                                                                mainAxisSize: MainAxisSize.min,
                                                                children: [
                                                                  Text('Order ID'),
                                                                  SizedBox(width: 5,),
                                                                  Text('*', style: TextStyle(color: Colors.red),),
                                                                ],
                                                              ),

                                                              const SizedBox(height: 5,),
                                                              SizedBox(
                                                                height: 40,
                                                                width: 200,
                                                                child: TextFormField(
                                                                  controller: _controller,
                                                                  focusNode: _focusNode,
                                                                  //  onEditingComplete: _fetchOrderDetails,
                                                                  decoration: InputDecoration(
                                                                    filled: true,
                                                                    contentPadding: const EdgeInsets.symmetric(vertical: 10,horizontal: 12),
                                                                    fillColor: Colors.white,
                                                                    // border: InputBorder.none,
                                                                    // focusedBorder: OutlineInputBorder(
                                                                    //   borderRadius: BorderRadius.circular(5.0),
                                                                    //   borderSide: const BorderSide(color: Colors.white), // Added blue border
                                                                    // ),
                                                                    border: OutlineInputBorder(
                                                                      borderRadius: BorderRadius.circular(5.0),
                                                                      borderSide: BorderSide.none,
                                                                    ),
                                                                    hintText: 'ORD_00392',
                                                                  ),
                                                                  inputFormatters: [
                                                                    UpperCaseTextFormatter(),
                                                                    FilteringTextInputFormatter.allow(
                                                                        RegExp("[a-zA-Z_0-9]")),
                                                                    // Allow only letters, numbers, and single space
                                                                    FilteringTextInputFormatter.deny(
                                                                        RegExp(r'^\s')),
                                                                    // Disallow starting with a space
                                                                    FilteringTextInputFormatter.deny(
                                                                        RegExp(r'\s\s')),
                                                                    // Disallow multiple spaces
                                                                  ],
                                                                  validator: (value) {
                                                                    if (_controller.text != null && _controller.text.trim().isEmpty) {
                                                                      return 'Please enter a product name';
                                                                    }
                                                                    return null;
                                                                  },
                                                                ),
                                                              ),
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
                                          Padding(
                                            padding:  const EdgeInsets.only(right: 5),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Padding(
                                                  padding: EdgeInsets.only(right: maxWidth * 0.08, top: 20),
                                                  child: const Text('Delivery Date', style: TextStyle(fontSize: 13),),
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
                                        padding: const EdgeInsets.only(left: 50, top: 140,right: 100),
                                        child: Container(
                                          height: 100,
                                          width: 1700,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFFFFFFF), // background: #FFFFFF
                                            boxShadow: [const BoxShadow(
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
                                                Expanded(
                                                  flex: 1,
                                                  child: Column(
                                                    children: [
                                                      if(Status == 'Created')...{

                                                        const Icon(
                                                          Icons.check_box,
                                                          color: Colors.green,
                                                        ),
                                                      }
                                                      else...{

                                                        const Icon(
                                                          Icons.check_box,
                                                          color: Colors.grey,
                                                        ),
                                                      },
                                                      const Text(
                                                        'Order Create',
                                                        style: TextStyle(
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                const Expanded(
                                                  flex: 1,
                                                  child: Column(
                                                    children: [
                                                      Icon(
                                                        Icons.check_box,
                                                        color:  Colors.grey,// default color
                                                      ),
                                                      Text(
                                                        'Picked',
                                                        style: TextStyle(
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                const Expanded(
                                                  flex: 1,
                                                  child: Column(
                                                    children: [
                                                      Icon(
                                                        Icons.check_box,
                                                        color:  Colors.grey,
                                                      ),
                                                      Text(
                                                        'Delivered',
                                                        style: TextStyle(
                                                          color: Colors.black,
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

                                      Padding(
                                        padding: const EdgeInsets.only(left: 50,right: 100,top: 290),
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
                                        padding: EdgeInsets.only(top: 500),
                                        child: SpinKitWave(
                                          color: Colors.blue,
                                          size: 30.0,
                                        ),
                                      )
                                          : Container(),

                                      // const SizedBox(height: 16),
                                      Padding(
                                        padding: const EdgeInsets.only(left: 50,right: 100,top: 700,bottom: 10),
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
                                                itemCount: _orderDetails.length,
                                                itemBuilder: (context, index) {
                                                  if (index >= _orderDetails.length || index >= _qtyControllers.length) {
                                                    return const SizedBox.shrink(); // Return an empty widget if the index is out of range
                                                  }
                                                  Map<String, dynamic> item = _orderDetails[index];
                                                  return Table(
                                                    border: const TableBorder(
                                                      bottom: BorderSide(width:1 ,color: Colors.grey),
                                                      //   horizontalInside: BorderSide(width: 1,color: Colors.grey), // horizontal border inside the table
                                                      verticalInside: BorderSide(width: 1,color: Colors.grey),
                                                    ),
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
                                                                  child: Center(child: Text(item['totalAmount'].toStringAsFixed(2))),
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
                                                padding: const EdgeInsets.only(right: 60 ,top: 5,bottom: 5),
                                                child: Align(
                                                  alignment: Alignment.centerRight,
                                                  child: Container(
                                                    height: 40,
                                                    padding: const EdgeInsets.only(left: 5,right: 10,top: 6,bottom: 2),
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
                                                                text:  'Total :',
                                                                style: TextStyle(
                                                                    fontSize: 14,
                                                                    color: Colors.blue
                                                                  // fontWeight: FontWeight.bold,
                                                                ),
                                                              ),
                                                              const TextSpan(
                                                                text: ' ₹',
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
                                ),),
                            ),
                          ))
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

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
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

