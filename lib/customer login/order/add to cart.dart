import 'dart:async';
import 'dart:convert';
import 'dart:html';

import 'package:adaptive_scrollbar/adaptive_scrollbar.dart';
import 'package:btb/Order%20Module/firstpage.dart';
import 'package:btb/admin/Api%20name.dart';

import 'package:btb/widgets/productclass.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../../widgets/confirmdialog.dart';


void main() => runApp(const CusAddtoCart(selectedProducts: [], select: '', data: {}));


class CusAddtoCart extends StatefulWidget {
  final List<Product> selectedProducts;
  final Map<String, dynamic> data;
  final String select;

  const CusAddtoCart(
      {super.key, required this.selectedProducts,
        required this.select,

        required this.data});

  @override
  State<CusAddtoCart> createState() => _CusAddtoCartState();
}

class _CusAddtoCartState extends State<CusAddtoCart> {
  List<Product> products = [];
  bool _hasShownPopup = false;
  final ScrollController horizontalScroll = ScrollController();
  final dummyProducts = '';
  Timer? _searchDebounceTimer;
  double _total = 0.0;
  String _searchText = '';
  late Future<List<detail>> futureOrders;
  String searchQuery = '';
  final String _category = '';
  double _total1 = 0.0;
  final List<String> list = ['  Name 1', '  Name 2', '  Name3'];
  bool isOrdersSelected = false;
  List<Product> selectedProducts = [];
  final TextEditingController ShippingAddress = TextEditingController();
  final TextEditingController totalAmountController = TextEditingController();
  List<detail>filteredData= [];

  final TextEditingController totalController = TextEditingController();
  final TextEditingController productNameController = TextEditingController();
  List<Product> showProducts = [];
  int itemCount = 0;
  final TextEditingController EmailIdController = TextEditingController();
  final TextEditingController CusIdController = TextEditingController();

  final TextEditingController deliveryAddressController = TextEditingController();
  final TextEditingController contactNumberController = TextEditingController();
  final TextEditingController contactPersonController = TextEditingController();
  bool _isRefreshed = false;
  DateTime? _selectedDate;
  late TextEditingController _dateController;
  final String _subCategory = '';
  Map<String, dynamic> data2 = {};
  Map<String, dynamic> PaymentMap = {};
  int startIndex = 0;
  List<Product> filteredProducts = [];
  int currentPage = 1;
  List<dynamic> detailJson =[];
  String? dropdownValue1 = 'Filter I';
  List<Product> productList = [];
  String token = window.sessionStorage["token"] ?? " ";
  String userId = window.sessionStorage['userId'] ?? '';
  String? dropdownValue2 = 'Filter II';
  String status= '';
  String selectDate ='';

  Map<String, bool> _isHovered = {
    'Orders': false,
    'Invoice': false,
    'Delivery': false,
    'Payment': false,
    'Return': false,
  };
  Future<void> fetchProducts() async {
    if (isLoading) return;
    if (!mounted) return;
    setState(() {
      isLoading = true;
    });
    try {
      final response = await http.get(
        Uri.parse(
          '$apicall/order_master/get_all_draft_master'
        ),
        headers: {
          "Content-type": "application/json",
          "Authorization": 'Bearer $token',
        },
      );
      if(token == " "){
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
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          // Warning Icon
                          Icon(Icons.warning, color: Colors.orange, size: 50),
                          SizedBox(height: 16),
                          // Confirmation Message
                          Text(
                            'Session Expired',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          Text("Please log in again to continue",style: TextStyle(
                            fontSize: 12,

                            color: Colors.black,
                          ),),
                          SizedBox(height: 20),
                          // Buttons
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  // Handle Yes action
                                  context.go('/');
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
                                  'ok',
                                  style: TextStyle(
                                    color: Colors.blue,
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
      else{
        if (response.statusCode == 200) {
          final jsonData = jsonDecode(response.body);
          List<detail> products = [];
          if (jsonData != null) {
            if (jsonData is List) {
              products = jsonData.map((item) => detail.fromJson(item)).toList();
            }
            else if (jsonData is Map && jsonData.containsKey('body')) {
              products = (jsonData['body'] as List)
                  .map((item) => detail.fromJson(item))
                  .toList();
              totalItems =
                  jsonData['totalItems'] ?? 0; // Get the total number of items
            }
            List<detail> matchedCustomers = products.where((customer) {  return customer.CusId == userId;}).toList();

            if (matchedCustomers.isNotEmpty) {
              setState(() {
                itemCount = products.length;
              });
            }
          }
        } else {
          throw Exception('Failed to load data');
        }
      }

    } catch (e) {
      print('Error decoding JSON: $e');
// Optionally, show an error message to the user
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  List<Widget> _buildMenuItems(BuildContext context) {
    return [
      _buildMenuItem('Home', Icons.home_outlined, Colors.blue[900]!, '/Cus_Home'),
      Container(
          decoration: BoxDecoration(
            color: Colors.blue[800],
            // border: Border(  left: BorderSide(    color: Colors.blue,    width: 5.0,  ),),
            // color: Color.fromRGBO(224, 59, 48, 1.0),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8), // Radius for top-left corner
              topRight: Radius.circular(8), // No radius for top-right corner
              bottomLeft: Radius.circular(8), // Radius for bottom-left corner
              bottomRight: Radius.circular(8), // No radius for bottom-right corner
            ),
          ),child: _buildMenuItem('Orders', Icons.warehouse, Colors.blueAccent, '/Customer_Order_List')),
      _buildMenuItem('Delivery', Icons.fire_truck_outlined, Colors.blue[900]!, '/Customer_Delivery_List'),
      _buildMenuItem('Invoice', Icons.document_scanner_rounded, Colors.blue[900]!, '/Customer_Invoice_List'),

      _buildMenuItem('Payment', Icons.payment_outlined, Colors.blue[900]!, '/Customer_Payment_List'),
      _buildMenuItem('Return', Icons.backspace_sharp, Colors.blue[900]!, '/Customer_Return_List'),
    ];
  }

  Widget _buildMenuItem(String title, IconData icon, Color iconColor, String route) {
    iconColor = _isHovered[title] == true ? Colors.blue : Colors.black87;
    title == 'Orders'? _isHovered[title] = false :  _isHovered[title] = false;
    title == 'Orders'? iconColor = Colors.white : Colors.black;
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

  @override
  void initState() {
    super.initState();
    fetchProducts();
    _dateController = TextEditingController();
    futureOrders = fetchOrders() as Future<List<detail>>;
    ShippingAddress.text = widget.data['Comments'] ?? '';
    deliveryAddressController.text = widget.data['Address'] ?? '';
    contactNumberController.text = widget.data['ContactNumber'] ?? '';
    contactPersonController.text = widget.data['ContactName'] ?? '';
    EmailIdController.text = widget.data['deliveryLocation'] ?? '';
    CusIdController.text = widget.data['CusId'] ??'';
    print('------------dadf');
    _calculateTotal();
    _selectedDate = DateTime.now();
    String formattedDate = DateFormat('dd/MM/yyyy').format(_selectedDate!);
    // _dateController.text = _selectedDate != null ? DateFormat('dd/MM/yyy').format(_selectedDate!) : '';
    _dateController.text = formattedDate;
    print(widget.data);
    print('-hello');
    data2 = Map.from(widget.data);
    // totalAmountController.text = data2['totalAmount'];
    print(widget.selectedProducts);
    // print(showProducts);
  }
  Future<List<detail>> fetchOrders() async {
    if(token == " "){
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
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        // Warning Icon
                        Icon(Icons.warning, color: Colors.orange, size: 50),
                        SizedBox(height: 16),
                        // Confirmation Message
                        Text(
                          'Session Expired',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        Text("Please log in again to continue",style: TextStyle(
                          fontSize: 12,

                          color: Colors.black,
                        ),),
                        SizedBox(height: 20),
                        // Buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                // Handle Yes action
                                context.go('/');
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
                                'ok',
                                style: TextStyle(
                                  color: Colors.blue,
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
return [];
    }
    final response = await http.get(
      Uri.parse(
          '$apicall/order_master/get_all_ordermaster'),
      headers: {
        'Authorization': 'Bearer $token',
        // Add the token to the Authorization header
      },
    );


      if (response.statusCode == 200) {
        detailJson = json.decode(response.body);
        List<detail> filteredData = detailJson.map((json) => detail.fromJson(json)).toList();
        if (_searchText.isNotEmpty) {
          print(_searchText);
          filteredData = filteredData.where((detail) => detail.orderId!.toLowerCase().contains(_searchText.toLowerCase())).toList();
        }
        return filteredData;
      } else {
        throw Exception('Failed to load orders');
    }

  }
  void _calculateTotal() {
    _total = 0.0;
    _total1 = 0.0; // Initialize _total1 to 0.0
    for (var product in widget.selectedProducts) {
      product.total = product.quantity * product.totalAmount;
      _total += product.total; // Add the total of each product to _total
      // Calculate the alternative total using price and quantity
      product.total = (product.price * product.quantity) as double;
      _total1 += product.total; // Add the alternative total to _total1
    }
    setState(() {

    });
  }





  int itemsPerPage = 10;
  int totalItems = 0;
  int totalPages = 0;
  bool isLoading = false;






  Future<void>  callApi() async {

    List<Map<String, dynamic>> items = [];

    for (int i = 0; i < widget.selectedProducts.length; i++) {
      Product product = widget.selectedProducts[i];
      items.add({
        "productName": product.productName,
        "category": product.category,
        "subCategory": product.subCategory,
        "price": product.price,
        "qty": product.quantity,
        "actualAmount":  product.price * product.quantity,
        "totalAmount": (product.totalAmount * product.quantity),
        "discount": product.discount,
        "tax": product.tax,
      });
    }

    final url = '$apicall/order_master/add_order_master';
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${token}',
    };
    final body = {
      "orderDate": data2['date'],
      "deliveryLocation": EmailIdController.text,
      "deliveryAddress":  deliveryAddressController.text,
      "contactPerson": contactPersonController.text,
      "contactNumber": contactNumberController.text,
      "comments":  ShippingAddress.text,
      "status": "-",
      "customerId": userId,
      "total": data2['totalAmount'],
      "items": items,
    };

    final response = await http.post(Uri.parse(url), headers: headers, body: json.encode(body));
if(token == " "){
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
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Warning Icon
                    Icon(Icons.warning, color: Colors.orange, size: 50),
                    SizedBox(height: 16),
                    // Confirmation Message
                    Text(
                      'Session Expired',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Text("Please log in again to continue",style: TextStyle(
                      fontSize: 12,

                      color: Colors.black,
                    ),),
                    SizedBox(height: 20),
                    // Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            // Handle Yes action
                            context.go('/');
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
                            'ok',
                            style: TextStyle(
                              color: Colors.blue,
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
else{
  if (response.statusCode == 200) {
    context.go('/Customer_Draft_List');
    print('sucess');
  }else {
    print('API call failed with status code ${response.statusCode}');
  }
}

  }


  void _deleteProduct(Product product) {
    setState(() {
      widget.selectedProducts.remove(product);
      _calculateTotal();
    });
  }

  @override
  void dispose() {
    _searchDebounceTimer
        ?.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        // backgroundColor: const Color(0xFFFFFFFF),
          appBar:
          AppBar(
            leading: null,
            automaticallyImplyLeading: false,
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
                  child: Stack(
                    clipBehavior: Clip.none, // This ensures the badge can be positioned outside the icon bounds
                    children: [
                      IconButton(
                        icon: const Icon(Icons.shopping_cart),
                        onPressed: () {
                          context.go('/Customer_Draft_List');
                          // Handle notification icon press
                        },
                      ),
                      Positioned(
                        right: 0,
                        top: -5, // Adjust this value to move the text field
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.red, // Background color of the badge
                            shape: BoxShape.circle,
                          ),
                          child:  Text(
                            '${itemCount}', // The text field value (like a badge count)
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12, // Adjust the font size as needed
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 10,),
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child:AccountMenu(),
              ),
            ],
          ),
          body:
          LayoutBuilder(
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
                                    width: maxWidth * 0.2,
                                    height: 40,
                                    child:
                                    TextFormField(
                                      controller: contactPersonController,
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
                                      validator: (value) {
                                        if (contactPersonController.text != null && contactPersonController.text.trim().isEmpty) {
                                          return 'Please enter a product name';
                                        }
                                        return null;
                                      },
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
                                    child: TextField(
                                      controller: deliveryAddressController,
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
                                        // Allow only letters, numbers, and single space
                                        FilteringTextInputFormatter.deny(
                                            RegExp(r'^\s')),
                                        // Disallow starting with a space
                                        FilteringTextInputFormatter.deny(
                                            RegExp(r'\s\s')),
                                        // Disallow multiple spaces
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
                                  padding: const EdgeInsets.only(right: 20),
                                  child: SizedBox(
                                    width: maxWidth * 0.2,
                                    height: 40,
                                    child: TextFormField(
                                      controller: contactNumberController,


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
                                    child:
                                    TextFormField(
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
                                        hintText: 'Enter Email Id',
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
                                            hintText: 'Enter Your Comments'


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
                  children: [
                    if (constraints.maxHeight <= 310) ...{
                      SingleChildScrollView(
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Container(
                            width: 200,
                            color: const Color(0xFFF7F6FA),
                            padding:
                            const EdgeInsets.only(left: 15, top: 10, right: 15),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: _buildMenuItems(context),
                            ),
                          ),
                        ),
                      )
                    } else ...{
                      Align(
                        alignment: Alignment.topLeft,
                        child: Container(
                          width: 200,
                          height: 984,
                          color: const Color(0xFFF7F6FA),
                          padding:
                          const EdgeInsets.only(left: 15, top: 10, right: 15),
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
                        width: 1.8, // Set the width to 1 for a vertical line
                        height: maxHeight, // Set the height to your liking
                        decoration: const BoxDecoration(
                          border: Border(left: BorderSide(width: 1, color: Colors.grey)),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 201,
                      right: 0,
                      top: 0,
                      bottom: 0,
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            color: Colors.white,
                            height: 50,
                            child: Row(
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(left: 30,top: 10,),
                                  child: Text(
                                    'Add to Cart',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                Align(
                                  alignment: Alignment.topLeft,
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 100,top: 10),
                                    child: OutlinedButton(
                                      onPressed: () async {
                                        if(widget.selectedProducts.isEmpty){
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('Please Select Product Item'),
                                            ),
                                          );
                                        }
                                        else if(EmailIdController.text.isEmpty || !RegExp(r'^[\w-]+(\.[\w-]+)*@[a-zA-Z0-9-]+\.(com|in|net)$').hasMatch(EmailIdController.text) ){  ScaffoldMessenger.of(context).showSnackBar(    SnackBar(content: Text(        'Enter Valid E-mail Address')),  );}
                                        else if(deliveryAddressController.text.isEmpty){
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('Please fill address'),
                                            ),
                                          );
                                        }
                                        else if(ShippingAddress.text.isEmpty){
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('Please enter shipping address'),
                                            ),
                                          );
                                        }
                                        else if(contactPersonController.text.isEmpty || contactPersonController.text.length <=2){
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('Please enter a contact person name'),
                                            ),
                                          );
                                        }
                                        else if(contactNumberController.text.isEmpty || contactNumberController.text.length !=10){
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('Please enter a valid phone number.'),
                                            ),
                                          );
                                        }
                                        else {
                                          await callApi();
                                        }
                                      },
                                      style: OutlinedButton.styleFrom(
                                        backgroundColor: Colors.blue[800], // Button background color
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(5), // Rounded corners
                                        ),
                                        side: BorderSide.none, // No outline
                                      ),
                                      child: const Text(
                                        ' Add to Cart',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
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
                            margin: const EdgeInsets.symmetric(
                                vertical: 1), // Space above/below the border
                            height: 0.3,
                            // width: 1000,
                            width: constraints.maxWidth,// Border height
                            color: Colors.black, // Border color
                          ),
    if(constraints.maxWidth >= 1300)...{
      Expanded(child: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 100),
              child: Container(
                  width: maxWidth,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Padding(
                        padding:  EdgeInsets.only(right: maxWidth * 0.08,top: 30),
                        child:  Text(' Order Date',style: TextStyle(fontSize: maxWidth * 0.010,color: Colors.black87),),
                      ),
                      // Padding(
                      //   padding:  EdgeInsets.only(top: 20,right: maxWidth * 0.085),
                      //   child: const Text(('Order Date')),
                      // ),
                      Padding(
                        padding:  const EdgeInsets.only( top:10),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: const Color(0xFFEBF3FF), width: 1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Container(
                            height: 39,
                            width: maxWidth *0.13,
                            child: Column(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _dateController,
                                    // Replace with your TextEditingController
                                    readOnly: true,
                                    decoration: InputDecoration(
                                      suffixIcon: Padding(
                                        padding: const EdgeInsets.only(right: 20),
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              top: 2, left: 10),
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
                                      hintText: '        Select Date',
                                      fillColor: Colors.grey.shade200,
                                      contentPadding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 8),
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
                  )
              ),
            ),
            //SizedBox(height: 20.h),
            Padding(
              padding: const EdgeInsets.only(left: 100,right: 100,top: 50),
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFFFFFFF), // background: #FFFFFF
                  boxShadow: [BoxShadow(
                    offset: Offset(0, 3),
                    blurRadius: 6,
                    color: Color(0x29000000), // box-shadow: 0px 3px 6px #00000029
                  )],
                  borderRadius: BorderRadius.all(Radius.circular(4)), // border-radius: 8px
                ),
                child: Table(
                  border: TableBorder.all(color: const Color(0xFFB2C2D3)),

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
            Padding(
              padding: const EdgeInsets.only(left: 100, top: 50,right: 100,bottom: 10),
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.81,
                child: Container(
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
                    borderRadius: const BorderRadius.all(Radius.circular(4)), // border-radius: 8px
                  ),                               child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 10, left: 30),
                      child: Text(
                        'Add Products',
                        style: TextStyle(
                          fontSize: 19,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
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
                            0: FlexColumnWidth(0.9),
                            1: FlexColumnWidth(2.7),
                            2: FlexColumnWidth(2),
                            3: FlexColumnWidth(1.8),
                            4: FlexColumnWidth(2),
                            5: FlexColumnWidth(1),
                            6: FlexColumnWidth(2),
                            7: FlexColumnWidth(1),
                            8: FlexColumnWidth(1),
                            9: FlexColumnWidth(1),
                            10: FlexColumnWidth(1),

                          },
                          children: const [
                            TableRow(
                              children: [
                                TableCell(
                                  child: Padding(
                                    padding: EdgeInsets.only(top: 10, bottom: 10),
                                    child: Center(
                                      child: Padding(
                                        padding: EdgeInsets.only(left: 12),
                                        child: Text(
                                          'SN',
                                          style: TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                TableCell(
                                  child: Padding(
                                    padding: EdgeInsets.only(top: 10, bottom: 10),
                                    child: Center(
                                      child: Text(
                                        'Product Name',
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                ),
                                TableCell(
                                  child: Padding(
                                    padding: EdgeInsets.only(top: 10, bottom: 10),
                                    child: Center(
                                      child: Text(
                                        'Category',
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                ),
                                TableCell(
                                  child: Padding(
                                    padding: EdgeInsets.only(top: 10, bottom: 10),
                                    child: Center(
                                      child: Text(
                                        'Sub Category',
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                ),
                                TableCell(
                                  child: Padding(
                                    padding: EdgeInsets.only(top: 10, bottom: 10),
                                    child: Center(
                                      child: Text(
                                        'Price',
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                ),
                                TableCell(
                                  child: Padding(
                                    padding: EdgeInsets.only(top: 10, bottom: 10),
                                    child: Center(
                                      child: Text(
                                        'QTY',
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                ),
                                TableCell(
                                  child: Padding(
                                    padding: EdgeInsets.only(top: 10, bottom: 10),
                                    child: Center(
                                      child: Text(
                                        'Amount',
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                ),
                                TableCell(
                                  child: Padding(
                                    padding: EdgeInsets.only(top: 10, bottom: 10),
                                    child: Center(
                                      child: Text(
                                        'Disc.',
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                ),
                                TableCell(
                                  child: Padding(
                                    padding: EdgeInsets.only(top: 10, bottom: 10),
                                    child: Center(
                                      child: Text(
                                        'TAX',
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                ),
                                TableCell(
                                  child: Padding(
                                    padding: EdgeInsets.only(top: 10, bottom: 10),
                                    child: Center(
                                      child: Text(
                                        'Total Amount',
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                ),
                                TableCell(
                                  child: Padding(
                                    padding: EdgeInsets.only(top: 10, bottom: 10),
                                    child: Center(
                                      child: Text(
                                        '    ',
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: widget.selectedProducts.length,
                      itemBuilder: (context, index) {
                        Product product = widget.selectedProducts[index];
                        return Table(
                          border: const TableBorder(
                            bottom: BorderSide(width:1 ,color: Colors.grey),
                            //   horizontalInside: BorderSide(width: 1,color: Colors.grey), // horizontal border inside the table
                            verticalInside: BorderSide(width: 1,color: Colors.grey),
                          ),
                          // border: TableBorder.all(color: const Color(0xFFB2C2D3)),
                          columnWidths: const {
                            0: FlexColumnWidth(1),
                            1: FlexColumnWidth(2.7),
                            2: FlexColumnWidth(2),
                            3: FlexColumnWidth(1.8),
                            4: FlexColumnWidth(2),
                            5: FlexColumnWidth(1),
                            6: FlexColumnWidth(2),
                            7: FlexColumnWidth(1),
                            8: FlexColumnWidth(1),
                            9: FlexColumnWidth(1),
                            10: FlexColumnWidth(1),

                          },
                          children: [
                            TableRow(
                              children: [
                                TableCell(
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 10, right: 10, top: 15, bottom: 5),
                                    child: Center(
                                      child: Text(
                                        (index + 1).toString(),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ),
                                TableCell(
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 10, right: 10, top: 10, bottom: 10),
                                    child: Container(
                                      height: 35,
                                      width: 150,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade200,
                                        borderRadius: BorderRadius.circular(4.0),
                                      ),
                                      child: Center(
                                        child: Text(
                                          product.productName,
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                TableCell(
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 10, right: 10, top: 10, bottom: 10),
                                    child: Container(
                                      height: 35,
                                      width: 150,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade200,
                                        borderRadius: BorderRadius.circular(4.0),
                                      ),
                                      child: Center(
                                        child: Text(
                                          product.category,
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                TableCell(
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 10, right: 10, top: 10, bottom: 10),
                                    child: Container(
                                      height: 35,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade200,
                                        borderRadius: BorderRadius.circular(4.0),
                                      ),
                                      child: Center(
                                        child: Text(
                                          product.subCategory,
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                TableCell(
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 10, right: 10, top: 10, bottom: 10),
                                    child: Container(
                                      height: 35,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade200,
                                        borderRadius: BorderRadius.circular(4.0),
                                      ),
                                      child: Center(
                                        child: Text(
                                          product.price.toString(),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                TableCell(
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 10, right: 10, top: 10, bottom: 10),
                                    child: Container(
                                      height: 35,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade200,
                                        borderRadius: BorderRadius.circular(4.0),
                                      ),
                                      child: Center(
                                        child: Text(
                                          product.quantity.toString(),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                TableCell(
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 10, right: 10, top: 10, bottom: 10),
                                    child: Container(
                                      height: 35,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade200,
                                        borderRadius: BorderRadius.circular(4.0),
                                      ),
                                      child: Center(
                                        child: Text(
                                          '${product.price * product.quantity}',
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                TableCell(
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 10, right: 10, top: 10, bottom: 10),
                                    child: Container(
                                      height: 35,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade200,
                                        borderRadius: BorderRadius.circular(4.0),
                                      ),
                                      child: Center(
                                        child: Text(
                                          '${product.discount}',
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                TableCell(
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 10, right: 10, top: 10, bottom: 10),
                                    child: Container(
                                      height: 35,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade200,
                                        borderRadius: BorderRadius.circular(4.0),
                                      ),
                                      child: Center(
                                        child: Text(
                                          '${product.tax}',
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                TableCell(
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 10, right: 10, top: 10, bottom: 10),
                                    child: Container(
                                      height: 35,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade200,
                                        borderRadius: BorderRadius.circular(4.0),
                                      ),
                                      child: Center(
                                        child: Text(
                                          '${(product.totalAmount * product.quantity).toStringAsFixed(2)}',
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                TableCell(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 20),
                                    child: InkWell(
                                      onTap: () {
                                        _deleteProduct(product);
                                      },
                                      child: const Icon(
                                        Icons.remove_circle_outline,
                                        size: 18,
                                        color: Colors.blue,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 30, top: 20),
                          child: OutlinedButton(
                            onPressed: () {
                              // List<Product> products = widget.selectedProducts;
                              Product? selectedProduct;
                              if (widget.selectedProducts.isNotEmpty) {
                                // selectedProduct = null;
                                print('No products selected');
                                for (var selectedProduct in widget.selectedProducts) {
                                  print('----yes');
                                  Map<String, dynamic> data = {
                                    'CusId':CusIdController.text,
                                    'deliveryLocation': EmailIdController.text,
                                    'ContactName': contactPersonController.text,
                                    'Address': deliveryAddressController.text,
                                    'ContactNumber': contactNumberController.text,
                                    'Comments': ShippingAddress.text,
                                    'date': _dateController.text,
                                    'actualamount': _total1,
                                  };
                                  data2 = data;
                                  print('----select');
                                  print(selectedProduct);
                                  print('data3');
                                  print(data2);
                                  print('products');
                                  print(products);
                                  //original
                                  context.go('/Add_Product_items',extra: {
                                    // 'product': Product(prodId: '',price: 0,productName: '',proId: '',category: '',selectedVariation: '',selectedUOM: '',subCategory: '',totalamount: 0,total: 0,tax: '',quantity: 0,discount: '',imageId: '',unit: '', totalAmount: 0.0,qty: 0), // You need to pass a Product object here
                                    'product': selectedProduct, // You need to pass a list of Product objects here
                                    'data': data2,
                                    'products': products,
                                    'selectedProducts': widget.selectedProducts,
                                    'inputText': '',
                                    'subText': 'hii',
                                    'notselect': 'selectedproduct',
                                  });
                                }
                              }
                              else {
                                print("object");
                                print(data2);
                                print('----yes');
                                Map<String, dynamic> data = {
                                  'deliveryLocation': EmailIdController.text,
                                  'CusId': CusIdController.text,
                                  'ContactName': contactPersonController
                                      .text,
                                  'Address': deliveryAddressController
                                      .text,
                                  'ContactNumber': contactNumberController
                                      .text,
                                  'Comments': ShippingAddress
                                      .text,
                                  'date': _dateController.text,
                                };
                                data2 = data;
                                print('details ');
                                print(data2);
                                // Navigate to the page with empty data or handle it as needed
                                context.go('/Add_Product_items',extra: {
                                  // 'product': Product(prodId: '',price: 0,productName: '',proId: '',category: '',selectedVariation: '',selectedUOM: '',subCategory: '',totalamount: 0,total: 0,tax: '',quantity: 0,discount: '',imageId: '',unit: '', totalAmount: 0.0,qty: 0), // You need to pass a Product object here
                                  'product': Product(
                                      prodId: '',
                                      price: 0,
                                      productName: '',
                                      proId: '',
                                      category: '',
                                      selectedVariation: '',
                                      selectedUOM: '',
                                      subCategory: '',
                                      totalamount: 0,
                                      total: 0,
                                      tax: '',
                                      quantity: 0,
                                      discount: '',
                                      imageId: '',
                                      unit: '',
                                      totalAmount: 0.0,
                                      qty: 0), // You need to pass a list of Product objects here
                                  'data': data2,
                                  'products': products,
                                  'selectedProducts': widget.selectedProducts,
                                  'inputText': '',
                                  'subText': 'hii',
                                  'notselect': 'selectedproduct',
                                });
                              }
                            },
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Colors.blue[800],
                              // Blue background color
                              //  minimumSize: MaterialStateProperty.all(Size(200, 50)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5), // Optional: Square corners
                              ),
                              side: BorderSide.none, // No  outline
                            ),
                            child: const Text(
                              '+ Add Products',
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Container(
                        // Space above/below the border
                        height: 1, // Border height
                        color: const Color(0xFFB2C2D3), // Border color
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top:9,bottom: 9),
                      child: Align(
                        alignment: const Alignment(0.74,0.8),
                        child: Container(
                          padding: const EdgeInsets.only(left: 15,right: 10,top: 2,bottom: 2),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.blue),
                            borderRadius: BorderRadius.circular(3),
                            color:  Colors.white,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 15,top: 15,left: 10,right: 10),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                RichText(text:
                                TextSpan(
                                  children: [
                                    const TextSpan(
                                      text:  'Total',
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
                                      text:
                                      data2['totalAmount'] =_total.toStringAsFixed(2),
                                      style: const TextStyle(
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                                ),
                                buildDataTable(),
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
            ),
          ],
        ),
      ))
    }
    else...{
      Expanded(child: AdaptiveScrollbar(

        position: ScrollbarPosition.bottom,controller: horizontalScroll,
        child: SingleChildScrollView(
          controller: horizontalScroll,
          scrollDirection: Axis.horizontal,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                    width: 1700,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Padding(
                          padding:  EdgeInsets.only(right: 230,top: 30),
                          child:  Text(' Order Date',style: TextStyle(fontSize: 15,color: Colors.black87),),
                        ),
                        Padding(
                          padding:  const EdgeInsets.only(right: 100, top:10),
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: const Color(0xFFEBF3FF), width: 1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Container(
                              height: 39,
                              width: 200,
                              child: Column(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: _dateController,
                                      // Replace with your TextEditingController
                                      readOnly: true,
                                      decoration: InputDecoration(
                                        suffixIcon: Padding(
                                          padding: const EdgeInsets.only(right: 20),
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                top: 2, left: 10),
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
                                        hintText: '        Select Date',
                                        fillColor: Colors.grey.shade200,
                                        contentPadding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 8),
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
                        Padding(
                          padding: const EdgeInsets.only(left: 100,right: 100,top: 50),
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Color(0xFFFFFFFF), // background: #FFFFFF
                              boxShadow: [BoxShadow(
                                offset: Offset(0, 3),
                                blurRadius: 6,
                                color: Color(0x29000000), // box-shadow: 0px 3px 6px #00000029
                              )],
                              borderRadius: BorderRadius.all(Radius.circular(4)), // border-radius: 8px
                            ),
                            child: Table(
                              border: TableBorder.all(color: const Color(0xFFB2C2D3)),

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
                        Padding(
                          padding: const EdgeInsets.only(left: 100, top: 50,right: 100,bottom: 10),
                          child: SizedBox(
                            width: 1700,
                            child: Container(
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
                                borderRadius: const BorderRadius.all(Radius.circular(4)), // border-radius: 8px
                              ),                               child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(top: 10, left: 30),
                                  child: Text(
                                    'Add Products',
                                    style: TextStyle(
                                      fontSize: 19,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
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
                                        0: FlexColumnWidth(0.9),
                                        1: FlexColumnWidth(2.7),
                                        2: FlexColumnWidth(2),
                                        3: FlexColumnWidth(1.8),
                                        4: FlexColumnWidth(2),
                                        5: FlexColumnWidth(1),
                                        6: FlexColumnWidth(2),
                                        7: FlexColumnWidth(1),
                                        8: FlexColumnWidth(1),
                                        9: FlexColumnWidth(1),
                                        10: FlexColumnWidth(1),

                                      },
                                      children: const [
                                        TableRow(
                                          children: [
                                            TableCell(
                                              child: Padding(
                                                padding: EdgeInsets.only(top: 10, bottom: 10),
                                                child: Center(
                                                  child: Padding(
                                                    padding: EdgeInsets.only(left: 12),
                                                    child: Text(
                                                      'SN',
                                                      style: TextStyle(fontWeight: FontWeight.bold),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            TableCell(
                                              child: Padding(
                                                padding: EdgeInsets.only(top: 10, bottom: 10),
                                                child: Center(
                                                  child: Text(
                                                    'Product Name',
                                                    style: TextStyle(fontWeight: FontWeight.bold),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            TableCell(
                                              child: Padding(
                                                padding: EdgeInsets.only(top: 10, bottom: 10),
                                                child: Center(
                                                  child: Text(
                                                    'Category',
                                                    style: TextStyle(fontWeight: FontWeight.bold),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            TableCell(
                                              child: Padding(
                                                padding: EdgeInsets.only(top: 10, bottom: 10),
                                                child: Center(
                                                  child: Text(
                                                    'Sub Category',
                                                    style: TextStyle(fontWeight: FontWeight.bold),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            TableCell(
                                              child: Padding(
                                                padding: EdgeInsets.only(top: 10, bottom: 10),
                                                child: Center(
                                                  child: Text(
                                                    'Price',
                                                    style: TextStyle(fontWeight: FontWeight.bold),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            TableCell(
                                              child: Padding(
                                                padding: EdgeInsets.only(top: 10, bottom: 10),
                                                child: Center(
                                                  child: Text(
                                                    'QTY',
                                                    style: TextStyle(fontWeight: FontWeight.bold),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            TableCell(
                                              child: Padding(
                                                padding: EdgeInsets.only(top: 10, bottom: 10),
                                                child: Center(
                                                  child: Text(
                                                    'Amount',
                                                    style: TextStyle(fontWeight: FontWeight.bold),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            TableCell(
                                              child: Padding(
                                                padding: EdgeInsets.only(top: 10, bottom: 10),
                                                child: Center(
                                                  child: Text(
                                                    'Disc.',
                                                    style: TextStyle(fontWeight: FontWeight.bold),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            TableCell(
                                              child: Padding(
                                                padding: EdgeInsets.only(top: 10, bottom: 10),
                                                child: Center(
                                                  child: Text(
                                                    'TAX',
                                                    style: TextStyle(fontWeight: FontWeight.bold),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            TableCell(
                                              child: Padding(
                                                padding: EdgeInsets.only(top: 10, bottom: 10),
                                                child: Center(
                                                  child: Text(
                                                    'Total Amount',
                                                    style: TextStyle(fontWeight: FontWeight.bold),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            TableCell(
                                              child: Padding(
                                                padding: EdgeInsets.only(top: 10, bottom: 10),
                                                child: Center(
                                                  child: Text(
                                                    '    ',
                                                    style: TextStyle(fontWeight: FontWeight.bold),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: widget.selectedProducts.length,
                                  itemBuilder: (context, index) {
                                    Product product = widget.selectedProducts[index];
                                    return Table(
                                      border: const TableBorder(
                                        bottom: BorderSide(width:1 ,color: Colors.grey),
                                        //   horizontalInside: BorderSide(width: 1,color: Colors.grey), // horizontal border inside the table
                                        verticalInside: BorderSide(width: 1,color: Colors.grey),
                                      ),
                                      // border: TableBorder.all(color: const Color(0xFFB2C2D3)),
                                      columnWidths: const {
                                        0: FlexColumnWidth(1),
                                        1: FlexColumnWidth(2.7),
                                        2: FlexColumnWidth(2),
                                        3: FlexColumnWidth(1.8),
                                        4: FlexColumnWidth(2),
                                        5: FlexColumnWidth(1),
                                        6: FlexColumnWidth(2),
                                        7: FlexColumnWidth(1),
                                        8: FlexColumnWidth(1),
                                        9: FlexColumnWidth(1),
                                        10: FlexColumnWidth(1),

                                      },
                                      children: [
                                        TableRow(
                                          children: [
                                            TableCell(
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 10, right: 10, top: 15, bottom: 5),
                                                child: Center(
                                                  child: Text(
                                                    (index + 1).toString(),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            TableCell(
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 10, right: 10, top: 10, bottom: 10),
                                                child: Container(
                                                  height: 35,
                                                  width: 150,
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey.shade200,
                                                    borderRadius: BorderRadius.circular(4.0),
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      product.productName,
                                                      textAlign: TextAlign.center,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            TableCell(
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 10, right: 10, top: 10, bottom: 10),
                                                child: Container(
                                                  height: 35,
                                                  width: 150,
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey.shade200,
                                                    borderRadius: BorderRadius.circular(4.0),
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      product.category,
                                                      textAlign: TextAlign.center,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            TableCell(
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 10, right: 10, top: 10, bottom: 10),
                                                child: Container(
                                                  height: 35,
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey.shade200,
                                                    borderRadius: BorderRadius.circular(4.0),
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      product.subCategory,
                                                      textAlign: TextAlign.center,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            TableCell(
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 10, right: 10, top: 10, bottom: 10),
                                                child: Container(
                                                  height: 35,
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey.shade200,
                                                    borderRadius: BorderRadius.circular(4.0),
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      product.price.toString(),
                                                      textAlign: TextAlign.center,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            TableCell(
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 10, right: 10, top: 10, bottom: 10),
                                                child: Container(
                                                  height: 35,
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey.shade200,
                                                    borderRadius: BorderRadius.circular(4.0),
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      product.quantity.toString(),
                                                      textAlign: TextAlign.center,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            TableCell(
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 10, right: 10, top: 10, bottom: 10),
                                                child: Container(
                                                  height: 35,
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey.shade200,
                                                    borderRadius: BorderRadius.circular(4.0),
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      '${product.price * product.quantity}',
                                                      textAlign: TextAlign.center,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            TableCell(
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 10, right: 10, top: 10, bottom: 10),
                                                child: Container(
                                                  height: 35,
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey.shade200,
                                                    borderRadius: BorderRadius.circular(4.0),
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      '${product.discount}',
                                                      textAlign: TextAlign.center,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            TableCell(
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 10, right: 10, top: 10, bottom: 10),
                                                child: Container(
                                                  height: 35,
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey.shade200,
                                                    borderRadius: BorderRadius.circular(4.0),
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      '${product.tax}',
                                                      textAlign: TextAlign.center,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            TableCell(
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 10, right: 10, top: 10, bottom: 10),
                                                child: Container(
                                                  height: 35,
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey.shade200,
                                                    borderRadius: BorderRadius.circular(4.0),
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      '${(product.totalAmount * product.quantity).toStringAsFixed(2)}',
                                                      textAlign: TextAlign.center,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            TableCell(
                                              child: Padding(
                                                padding: const EdgeInsets.symmetric(vertical: 20),
                                                child: InkWell(
                                                  onTap: () {
                                                    _deleteProduct(product);
                                                  },
                                                  child: const Icon(
                                                    Icons.remove_circle_outline,
                                                    size: 18,
                                                    color: Colors.blue,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    );
                                  },
                                ),
                                Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(left: 30, top: 20),
                                      child: OutlinedButton(
                                        onPressed: () {
                                          // List<Product> products = widget.selectedProducts;
                                          Product? selectedProduct;
                                          if (widget.selectedProducts.isNotEmpty) {
                                            // selectedProduct = null;
                                            print('No products selected');
                                            for (var selectedProduct in widget.selectedProducts) {
                                              print('----yes');
                                              Map<String, dynamic> data = {
                                                'CusId':CusIdController.text,
                                                'deliveryLocation': EmailIdController.text,
                                                'ContactName': contactPersonController.text,
                                                'Address': deliveryAddressController.text,
                                                'ContactNumber': contactNumberController.text,
                                                'Comments': ShippingAddress.text,
                                                'date': _dateController.text,
                                                'actualamount': _total1,
                                              };
                                              data2 = data;
                                              print('----select');
                                              print(selectedProduct);
                                              print('data3');
                                              print(data2);
                                              print('products');
                                              print(products);
                                              //original
                                              context.go('/Add_Product_items',extra: {
                                                // 'product': Product(prodId: '',price: 0,productName: '',proId: '',category: '',selectedVariation: '',selectedUOM: '',subCategory: '',totalamount: 0,total: 0,tax: '',quantity: 0,discount: '',imageId: '',unit: '', totalAmount: 0.0,qty: 0), // You need to pass a Product object here
                                                'product': selectedProduct, // You need to pass a list of Product objects here
                                                'data': data2,
                                                'products': products,
                                                'selectedProducts': widget.selectedProducts,
                                                'inputText': '',
                                                'subText': 'hii',
                                                'notselect': 'selectedproduct',
                                              });
                                            }
                                          }
                                          else {
                                            print("object");
                                            print(data2);
                                            print('----yes');
                                            Map<String, dynamic> data = {
                                              'deliveryLocation': EmailIdController.text,
                                              'CusId': CusIdController.text,
                                              'ContactName': contactPersonController
                                                  .text,
                                              'Address': deliveryAddressController
                                                  .text,
                                              'ContactNumber': contactNumberController
                                                  .text,
                                              'Comments': ShippingAddress
                                                  .text,
                                              'date': _dateController.text,
                                            };
                                            data2 = data;
                                            print('details ');
                                            print(data2);
                                            // Navigate to the page with empty data or handle it as needed
                                            context.go('/Add_Product_items',extra: {
                                              // 'product': Product(prodId: '',price: 0,productName: '',proId: '',category: '',selectedVariation: '',selectedUOM: '',subCategory: '',totalamount: 0,total: 0,tax: '',quantity: 0,discount: '',imageId: '',unit: '', totalAmount: 0.0,qty: 0), // You need to pass a Product object here
                                              'product': Product(
                                                  prodId: '',
                                                  price: 0,
                                                  productName: '',
                                                  proId: '',
                                                  category: '',
                                                  selectedVariation: '',
                                                  selectedUOM: '',
                                                  subCategory: '',
                                                  totalamount: 0,
                                                  total: 0,
                                                  tax: '',
                                                  quantity: 0,
                                                  discount: '',
                                                  imageId: '',
                                                  unit: '',
                                                  totalAmount: 0.0,
                                                  qty: 0), // You need to pass a list of Product objects here
                                              'data': data2,
                                              'products': products,
                                              'selectedProducts': widget.selectedProducts,
                                              'inputText': '',
                                              'subText': 'hii',
                                              'notselect': 'selectedproduct',
                                            });
                                          }
                                        },
                                        style: OutlinedButton.styleFrom(
                                          backgroundColor: Colors.blue[800],
                                          // Blue background color
                                          //  minimumSize: MaterialStateProperty.all(Size(200, 50)),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(5), // Optional: Square corners
                                          ),
                                          side: BorderSide.none, // No  outline
                                        ),
                                        child: const Text(
                                          '+ Add Products',
                                          style: TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 10),
                                  child: Container(
                                    // Space above/below the border
                                    height: 1, // Border height
                                    color: const Color(0xFFB2C2D3), // Border color
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top:9,bottom: 9),
                                  child: Align(
                                    alignment: const Alignment(0.74,0.8),
                                    child: Container(
                                      padding: const EdgeInsets.only(left: 15,right: 10,top: 2,bottom: 2),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.blue),
                                        borderRadius: BorderRadius.circular(3),
                                        color:  Colors.white,
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.only(bottom: 15,top: 15,left: 10,right: 10),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            RichText(text:
                                            TextSpan(
                                              children: [
                                                const TextSpan(
                                                  text:  'Total',
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
                                                  text:
                                                  data2['totalAmount'] =_total.toStringAsFixed(2),
                                                  style: const TextStyle(
                                                    color: Colors.black,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            ),
                                            buildDataTable(),
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
                        ),

                      ],
                    )
                ),
                //SizedBox(height: 20.h),

              ],
            ),
          ),
        ),
      ))
    }

                        ],
                      ),
                    )

                  ],
                );

              }
          )


      ),
    );
  }

  Widget buildDataTable() {
    return LayoutBuilder(builder: (context, constraints){
      double right = constraints.maxWidth;

      return FutureBuilder<List<detail>>(
        future: futureOrders,
        builder: (context, snapshot) {

          if (snapshot.hasData) {
            filteredData = snapshot.data!.where((element) {
              final matchesSearchText= element.orderId!.toLowerCase().contains(searchQuery.toLowerCase());
              print('-----');
              print(element.orderDate);
              String orderYear = '';
              if (element.orderDate.contains('/')) {
                final dateParts = element.orderDate.split('/');
                if (dateParts.length == 3) {
                  orderYear = dateParts[2]; // Extract the year
                }
              }
              // final orderYear = element.orderDate.substring(5,9);
              if (status.isEmpty && selectDate.isEmpty) {
                return matchesSearchText; // Include all products that match the search text
              }
              if(status == 'Status' && selectDate == 'SelectYear'){
                return matchesSearchText;
              }
              if(status == 'Status' &&  selectDate.isEmpty)
              {
                return matchesSearchText;
              }
              if(selectDate == 'SelectYear' &&  status.isEmpty)
              {
                return matchesSearchText;
              }
              if (status == 'Status' && selectDate.isNotEmpty) {
                return matchesSearchText && orderYear == selectDate; // Include all products
              }
              if (status.isNotEmpty && selectDate == 'SelectYear') {
                return matchesSearchText && element.status == status;// Include all products
              }
              if (status.isEmpty && selectDate.isNotEmpty) {
                return matchesSearchText && orderYear == selectDate; // Include all products
              }

              if (status.isNotEmpty && selectDate.isEmpty) {
                return matchesSearchText && element.status == status;// Include all products
              }
              return matchesSearchText &&
                  (element.status == _category && element.orderDate == selectDate);
              //  return false;
            }).toList();

            // Print the details in the console
            filteredData.forEach((detail) {
            });

            // Return an empty Container to not show anything in the UI
            return Container();
          } else if (snapshot.hasError) {
            return Center(child: Text("${snapshot.error}"));
          }

          return const Center(child: CircularProgressIndicator());
        },
      );
    });
  }
}

