import 'dart:async';
import 'dart:convert';
import 'dart:html';
import 'package:adaptive_scrollbar/adaptive_scrollbar.dart';
import 'package:btb/admin/Api%20name.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:btb/widgets/confirmdialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:textfield_search/textfield_search.dart';
import '../customer module/create customer.dart';
import '../delivery module/delivery detail.dart';

void main() => runApp(OrdersSecond());

class OrdersSecond extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(1920, 984),
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          home: CreateOrderPage(),
        );
      },
    );
  }
}

class CreateOrderPage extends StatefulWidget {
  @override
  State<CreateOrderPage> createState() => _CreateOrderPageState();
}


class _CreateOrderPageState extends State<CreateOrderPage> {
  Timer? timer;
  bool isLoading  = false;
  final ScrollController horizontalScroll = ScrollController();
  String? _selectedDeliveryLocation;
  late TextEditingController _dateController;
  List<dynamic> cusData = []; // Store fetched customer data
  List<dynamic> filteredData = [];
  // String? _selectedDeliveryLocation;
  final EmailIdController = TextEditingController();
  final deliveryLocationController = TextEditingController();
  final ContactPersonController = TextEditingController();
  final deliveryaddressController = TextEditingController();
  final TextEditingController ContactNumberController = TextEditingController();
  TextEditingController ShippingAddress = TextEditingController();
  String shippingAddress1 = "";
  String shippingAddress2 = "";
  DateTime? _selectedDate;
  bool _isLoading= false;
  final controller = TextEditingController();
  String token = window.sessionStorage["token"] ?? " ";

  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    isLoading = false;
    _focusNode.addListener(_onFocusChange);

    controller.addListener(() {
      if (controller.text.isEmpty || controller.text.length != 10) {
        setState(() {
          // _isEditing = false;
          // Status = '';
          //  selectedValue = 'Select Location'
          isLoading = false;

          deliveryaddressController.clear();
          ShippingAddress.clear();
          ContactPersonController.clear();
          ContactNumberController.clear();
          EmailIdController.clear();
          // isLoading = true;
          // TotalController.clear();
          // _orderDetails = [];
        });
      }
    });
    // TODO: implement initState
    super.initState();
    _dateController = TextEditingController();
    _selectedDate = DateTime.now();
    String formattedDate = DateFormat('dd/MM/yyyy').format(_selectedDate!);
    _dateController.text = formattedDate;
    print('date init');

    print(_dateController.text);
    // _selectedDate = _dateController.text as DateTime?;
  }

  void _filterCustomerSuggestions(String query) {
    if (query.isNotEmpty) {
      setState(() {
        filteredData = cusData
            .where((customer) => customer['customerName']
            .toLowerCase()
            .contains(query.toLowerCase()))
            .toList();
      });
    } else {
      setState(() {
        filteredData = [];
      });
    }
  }


  void _onFocusChange() {
    if (!_focusNode.hasFocus) {
      _fetchOrderDetails(controller.text);
      _isLoading = true;
      timer = Timer(Duration(seconds: 2), () {
        setState(() {
          _isLoading = false;
        });
      });
    }

  }

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


  void _showAddressDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0), // Rounded corners
          ),
          child: IntrinsicWidth(
            child: IntrinsicHeight(
              child: Container(
                width: 500,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15.0),
                  color: Colors.white,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.max, // Adjust height to content
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: const Center(child: Text("Select Shipping Address",style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),),),
                    ),
                    // Close Icon
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0, right: 8.0),
                      child: Align(
                        alignment: Alignment.topRight,
                        child: IconButton(
                          icon: Icon(Icons.close, color: Colors.grey),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        // Addresses Row
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Left Address
                            Expanded(
                              child: MouseRegion(
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      ShippingAddress.text = shippingAddress1;
                                    });
                                    Navigator.pop(context);
                                  },
                                  child: Column(
                                    children: [
                                      const SizedBox(height: 10),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Container(

                                          decoration:BoxDecoration(
                                            //   border: Border.all(color: Colors.grey),
                                            color: Colors.greenAccent,
                                            borderRadius: BorderRadius.circular(8),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(0.3), // Soft grey shadow
                                                spreadRadius: 3,
                                                blurRadius: 3,
                                                offset: const Offset(0, 3),
                                              ),
                                            ],
                                          ),
                                          child: Center(
                                            child: Text(
                                              shippingAddress1,
                                              textAlign: TextAlign.left,
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.black87,
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
                            // Divider
                            Container(
                              width: 1,
                              height: 120,
                              color: Colors.grey.shade300,
                            ),
                            // Right Address
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    ShippingAddress.text = shippingAddress2;
                                  });
                                  Navigator.pop(context);
                                },
                                child: Column(
                                  children: [
                                    const SizedBox(height: 10),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Container(
                                        decoration:BoxDecoration(
                                          //   border: Border.all(color: Colors.grey),
                                          color: Colors.yellow,
                                          borderRadius: BorderRadius.circular(8),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.3), // Soft grey shadow
                                              spreadRadius: 3,
                                              blurRadius: 3,
                                              offset: const Offset(0, 3),
                                            ),
                                          ],
                                        ),

                                        child: Center(
                                          child: Text(
                                            shippingAddress2,
                                            textAlign: TextAlign.left,
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.black87,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }





  List<Widget> _buildMenuItems(BuildContext context) {
    return [
      _buildMenuItem('Home', Icons.home_outlined, Colors.blue[900]!, '/Home'),
      _buildMenuItem('Customer', Icons.account_circle, Colors.blue[900]!, '/Customer'),
      _buildMenuItem('Products', Icons.image_outlined, Colors.blue[900]!, '/Product_List'),
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
          child: _buildMenuItem('Orders', Icons.warehouse_outlined, Colors.white, '/Order_List')),
      _buildMenuItem('Invoice', Icons.document_scanner_outlined, Colors.blue[900]!, '/Invoice'),
      _buildMenuItem('Delivery', Icons.fire_truck_outlined, Colors.blue[900]!, '/Delivery_List'),
      _buildMenuItem('Payment', Icons.payment_outlined, Colors.blue[900]!, '/Payment_List'),
      _buildMenuItem('Return', Icons.keyboard_return, Colors.blue[900]!, '/Return_List'),
      _buildMenuItem('Reports', Icons.insert_chart_outlined, Colors.blue[900]!, '/Report_List'),
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


  Future<void> _fetchOrderDetails(String cusId) async {
    final customerId = controller.text;


    print(customerId);

    final cusMasterUrl ="$apicall/customer_master/get_all_customermaster";

    final cusMasterResponse = await http.get(
      Uri.parse(cusMasterUrl),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    if(cusMasterResponse.statusCode == 200){
      final cusData = jsonDecode(cusMasterResponse.body);
      print(cusData);
      bool isMatched = cusData.any((invoice) => invoice['customerName'] == customerId);
      if(isMatched){
        var matchedCustomer = cusData.firstWhere((customer) => customer['customerName'] == customerId);
        setState(() {
          ContactPersonController.text = matchedCustomer['customerName'] ?? ''; // Safely assign the value
          ContactNumberController.text = matchedCustomer['contactNo']?.toString() ?? ''; // Convert to string and safely assign
          deliveryaddressController.text = matchedCustomer['billingAddress'] ?? '';
          EmailIdController.text = matchedCustomer['email'] ?? '';
          shippingAddress1 = matchedCustomer['shippingAddress1'] ?? '';
          shippingAddress2 = matchedCustomer['shippingAddress2'] ?? '';
          print(shippingAddress1);
          print(shippingAddress2);
          ShippingAddress.text = shippingAddress1;
          print(ShippingAddress.text);
          isLoading = true;

        });
      }
      else{
        showDialog(
          barrierDismissible: false,
          context: context,
          builder: (BuildContext context) {
            return  AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              contentPadding: EdgeInsets.zero,
              content:
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Close Button
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        // Warning Icon
                        Icon(Icons.check_circle_rounded, color: Colors.green, size: 50),
                        SizedBox(height: 16),
                        // Confirmation Message
                        Text(
                          'Create Customer',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 20),
                        // Buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [

                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  PageRouteBuilder(
                                    pageBuilder: (context, animation, secondaryAnimation) =>
                                    const CreateCustomer(),
                                    transitionDuration: const Duration(milliseconds: 50),
                                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                      return FadeTransition(opacity: animation, child: child);
                                    },
                                  ),
                                );
                                // Handle No action
                                // Navigator.of(context).pop();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                side: BorderSide(color: Colors.blue),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                              ),
                              child: Text(
                                'OK',
                                style: TextStyle(
                                  color: Colors.white,
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
        );
      }

    }

  }

  final List<String> list = ['  Name 1', '  Name 2', '  Name3'];






  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    TableRow row1 =  TableRow(
      children: [
        TableCell(
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
              padding:   EdgeInsets.only(
                  top: 10, right: 30),
              child:OutlinedButton(
                onPressed: (){
                  print('paaa');
                  _showAddressDialog(context);


                },
                style: OutlinedButton.styleFrom(
                  backgroundColor : Colors.blue[800],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  side: BorderSide.none,
                ),
                child: Text("Change Address",style: TextStyle(color: Colors.white),),
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
          child: Row(
            children: [
              Padding(
                padding: EdgeInsets.only(left: 10,top: 10,bottom: 10),
                child: Text('Shipping Address',style: TextStyle(fontSize: 16),),
              ),
            ],
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
                      padding: const  EdgeInsets.only(left: 30),
                      child: SizedBox(
                        width: screenWidth * 0.2,
                        // width: 370,
                        height: 40,
                        child: TextFormField(
                          controller: ContactPersonController,
                          enabled: isLoading,
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
                            if (ContactPersonController.text != null && ContactPersonController.text.trim().isEmpty) {
                              return 'Please enter a product name';
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                    //delivery loction
                    // Padding(
                    //   padding:  const EdgeInsets.only(left: 30),
                    //   child: SizedBox(
                    //     width:  screenWidth * 0.35,
                    //     height: 40,
                    //     child: DropdownButtonFormField<String>(
                    //       value: _selectedDeliveryLocation,
                    //       decoration: InputDecoration(
                    //         filled: true,
                    //         fillColor: Colors.grey.shade100, // Changed to white
                    //         border: OutlineInputBorder(
                    //           borderRadius: BorderRadius.circular(5.0),
                    //           borderSide: const BorderSide(color: Color(0xFFBBDEFB)), // Added blue border
                    //         ),
                    //         enabledBorder: OutlineInputBorder(
                    //           borderRadius: BorderRadius.circular(5.0),
                    //           borderSide: const BorderSide(color: Colors.grey), // Added blue border
                    //         ),
                    //         focusedBorder: OutlineInputBorder(
                    //           borderRadius: BorderRadius.circular(5.0),
                    //           borderSide: const BorderSide(color: Colors.blue), // Added blue border
                    //         ),
                    //         hintText: 'Select Location',
                    //         contentPadding:const EdgeInsets.symmetric(
                    //             horizontal: 8, vertical: 8),
                    //         suffixIcon: Icon(Icons.arrow_drop_down_circle_rounded,color: Colors.blue[800],size: 16,)
                    //       ),
                    //       icon: Container(),
                    //       onChanged: (String? value) {
                    //         setState(() {
                    //           _selectedDeliveryLocation = value!;
                    //         });
                    //       },
                    //       items: list.map<DropdownMenuItem<String>>((String value) {
                    //         return DropdownMenuItem<String>(
                    //           value: value,
                    //           child: Text(value),
                    //         );
                    //       }).toList(),
                    //       isExpanded: true,
                    //     ),
                    //   ),
                    // ),
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
                        width: screenWidth * 0.35,
                        height: 120,
                        child: TextField(
                          controller: deliveryaddressController,
                          enabled: isLoading,
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
                        width: screenWidth * 0.2,
                        // width: 370,
                        height: 40,
                        child: TextFormField(
                          controller: ContactNumberController,
                          enabled: isLoading,
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
                            hintText: 'Contact Number',
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
                          validator: (value) {
                            if (ContactPersonController.text != null && ContactPersonController.text.trim().isEmpty) {
                              return 'Please enter a product name';
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
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
                        width: screenWidth * 0.2,
                        height: 40,
                        child: TextField(
                          controller: EmailIdController,
                          enabled: isLoading,
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
                            hintText: 'Email id',
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
                            enabled: isLoading,
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

    return ResponsiveBuilder(
      builder: (context, sizingInformation) {
        double screenWidth = MediaQuery.of(context).size.width;
        double screenHeight = MediaQuery.of(context).size.height;

        return Scaffold(
          // backgroundColor: const Color(0xFFFFFDFF),
          appBar:
          AppBar(
            backgroundColor: const Color(0xFFFFFFFF),
            title: Image.asset("images/Final-Ikyam-Logo.png"),
            // Set background color to white
            elevation: 2.0,
            shadowColor: const Color(0xFFFFFFFF),
            // Set shadow color to black
            actions: [
              Padding(
                padding:  const EdgeInsets.only(top: 10),
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
                child: AccountMenu(),
              ),
            ],
          ),
          body: LayoutBuilder(
            builder: (context, constraints){
              double maxHeight = constraints.maxHeight;
              double maxWidth = constraints.maxWidth;
              return Stack(
                children: [
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
                      top: 0,
                      right: 0,
                      bottom: 0,
                      child:
                      Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              color: const Color(0xFFFFFDFF),
                              height: 50,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 5),
                                    child: IconButton(
                                      icon:
                                      const Icon(Icons.arrow_back), // Back button icon
                                      onPressed: () {
                                        context.go(
                                            '/Order_List');
                                      },
                                    ),
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.only(left: 30,top: 12),
                                    child: Text(
                                      'Create Order',
                                      style: TextStyle(
                                        fontSize: 20,

                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 0, left: 0),
                            child: Container(
                              margin: const EdgeInsets.symmetric(
                                  vertical: 1), // Space above/below the border
                              height: 0.5,
                              // width: 1000,
                              width: constraints.maxWidth,// Border height
                              color: Colors.black, // Border color
                            ),
                          ),
                          if(constraints.maxWidth >= 1300)...{
                            Expanded(child: SingleChildScrollView(child: Column(children: [
                              Padding(
                                padding: const EdgeInsets.only(right:100),
                                child: SizedBox(
                                  width: screenWidth,
                                  child: Stack(
                                    //crossAxisAlignment: CrossAxisAlignment.end,
                                    // mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            flex: 1,
                                            child: Padding(
                                              padding: const EdgeInsets.only(left: 30,top: 20),
                                              child: Padding(
                                                padding: const EdgeInsets.only(left: 65),
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
                                                                  Text('Customer Name'),
                                                                  SizedBox(width: 5,),
                                                                  Text('*', style: TextStyle(color: Colors.red),),
                                                                ],
                                                              ),

                                                              const SizedBox(height: 5,),
                                                              SizedBox(
                                                                height: 40,
                                                                width: maxWidth * 0.12,
                                                                child: TextFormField(
                                                                  controller: controller,
                                                                  focusNode: _focusNode,
                                                                  //onEditingComplete: _fetchOrderDetails,
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
                                                                        // borderSide: BorderSide.none,
                                                                      ),

                                                                      hintText: 'CUS-Name'

                                                                  ),
                                                                  inputFormatters: [

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
                                                                  // validator: (value) {
                                                                  //   if (_controller.text != null && _controller.text.trim().isEmpty) {
                                                                  //     return 'Please enter a product name';
                                                                  //   }
                                                                  //   return null;
                                                                  // },

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
                                            padding:  EdgeInsets.only(right: 5),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Padding(
                                                  padding: EdgeInsets.only(right: maxWidth * 0.08, top: 20),
                                                  child: Text('Order Date', style: TextStyle(fontSize: 13),),
                                                ),
                                                SizedBox(height: 5,),
                                                DecoratedBox(
                                                  decoration: BoxDecoration(
                                                    border: Border.all(color: const Color(0xFFEBF3FF), width: 1),
                                                    borderRadius: BorderRadius.circular(10),
                                                  ),
                                                  child:
                                                  SizedBox(
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
                                                              fillColor: Colors.grey.shade100,
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
                                              ],
                                            ),
                                          ),

                                        ],
                                      ),

                                      //  ),
                                      // SizedBox(height: 20.h),

                                    ],
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


                              Padding(
                                padding: const EdgeInsets.only(top: 60,left: 100,right: 100,bottom: 30),
                                child: Container(
                                  //width: screenWidth * 0.8,
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
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Padding(
                                        padding: EdgeInsets.only(top: 10, left: 30),
                                        child: Text(
                                          'Add Products',
                                          style: TextStyle(fontSize: 19,color: Colors.black),
                                        ),



                                      ),
                                      const SizedBox(height: 10),
                                      SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child:

                                        DataTable(
                                          border: const TableBorder(
                                            top: BorderSide(width:1 ,color: Colors.grey),
                                            bottom: BorderSide(width:1 ,color: Colors.grey),
                                            horizontalInside: BorderSide(width: 1,color: Colors.grey), // horizontal border inside the table
                                            verticalInside: BorderSide(width: 1,color: Colors.grey),
                                          ),
                                          // border: TableBorder.all(color: const Color(0xFFB2C2D3)),
                                          columnSpacing: screenWidth * 0.066,
                                          headingRowHeight: 40,
                                          columns: const [
                                            DataColumn(label: Text('Product Name')),
                                            DataColumn(label: Text('Category')),
                                            DataColumn(label: Text('Sub Category')),
                                            DataColumn(label: Text('Price')),
                                            DataColumn(label: Text('Qty')),
                                            DataColumn(label: Text('Amount')),
                                            DataColumn(label: Text('TAX')),
                                            DataColumn(label: Text('Discount')),
                                            DataColumn(label: Text('Total Amount')),
                                          ],
                                          rows: const [],
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(left: 30, top: 25),
                                            child: SizedBox(
                                              width: screenWidth * 0.13,
                                              child: OutlinedButton(
                                                // onPressed: handleButtonPress,
                                                //my copy
                                                onPressed: ()

                                                {
                                                  String validateFields() {
                                                    if ( controller.text.isEmpty) {
                                                      return 'Please Enter Customer Name.';
                                                    }
                                                    if (ContactPersonController.text.isEmpty || ContactPersonController.text.length <= 2) {
                                                      return 'Please enter a contact person name';
                                                    }
                                                    if (ContactNumberController.text.isEmpty || ContactNumberController.text.length != 10) {
                                                      return 'Please enter a valid phone number.';
                                                    }
                                                    if (deliveryaddressController.text.isEmpty) {
                                                      return 'Please fill delivery address.';
                                                    }
                                                    if(EmailIdController.text.isEmpty ||!RegExp(r'^[\w-]+(\.[\w-]+)*@gmail\.com$').hasMatch(EmailIdController.text)){
                                                      return 'Please fill Email Address Format @gmail.com';
                                                    }
                                                    if (ShippingAddress.text.isEmpty) {
                                                      return 'Please fill Shipping address ';
                                                    }


                                                    return '';
                                                  }
                                                  String validationMessage = validateFields();
                                                  if (validationMessage == '') {
                                                    Map<String, dynamic> data = {
                                                      'CusId': controller.text,
                                                      'deliveryLocation': EmailIdController.text,
                                                      'ContactName': ContactPersonController.text,
                                                      'Address': deliveryaddressController.text,
                                                      'ContactNumber': ContactNumberController.text,
                                                      'Comments': ShippingAddress.text,
                                                      'date': _dateController.text,
                                                    };
                                                    context.go('/Search_For_Products',extra: data);
                                                    //   context.go('/Home/Orders/Create_Order/Add_Product',extra: data);

                                                  } else {
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      SnackBar(
                                                        content: Text(validationMessage),
                                                      ),
                                                    );
                                                  }
                                                },

                                                style: OutlinedButton.styleFrom(
                                                  backgroundColor: Colors.blue[800],
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(4),
                                                  ),
                                                  side: BorderSide.none,
                                                ),
                                                child: const Center(
                                                  child: Text(
                                                    '+ Add Products',
                                                    style: TextStyle(color: Colors.white),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(top: 10),
                                        child: Container(
                                          height: 1,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],),))
                          }
                          else...{
                            Expanded(child:AdaptiveScrollbar(

                              position: ScrollbarPosition.bottom,controller: horizontalScroll,
                              child: SingleChildScrollView(
                                controller: horizontalScroll,
                                scrollDirection: Axis.horizontal,
                                child: SingleChildScrollView(child: Column(children: [
                                  SizedBox(
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
                                                  padding: const EdgeInsets.only(left: 65),
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
                                                                    Text('Customer NamD'),
                                                                    SizedBox(width: 5,),
                                                                    Text('*', style: TextStyle(color: Colors.red),),
                                                                  ],
                                                                ),

                                                                const SizedBox(height: 5,),
                                                                SizedBox(
                                                                  height: 40,
                                                                  width: 200,
                                                                  child: TextFormField(
                                                                    controller: controller,
                                                                    focusNode: _focusNode,
                                                                    //onEditingComplete: _fetchOrderDetails,
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
                                                                          // borderSide: BorderSide.none,
                                                                        ),

                                                                        hintText: 'CUS - Name'

                                                                    ),

                                                                    inputFormatters: [
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
                                                                    // validator: (value) {
                                                                    //   if (_controller.text != null && _controller.text.trim().isEmpty) {
                                                                    //     return 'Please enter a product name';
                                                                    //   }
                                                                    //   return null;
                                                                    // },

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
                                              padding:  EdgeInsets.only(right: 100),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Padding(
                                                    padding: EdgeInsets.only(right: maxWidth * 0.08, top: 20),
                                                    child: Text('Order Date', style: TextStyle(fontSize: 13),),
                                                  ),
                                                  SizedBox(height: 5,),
                                                  DecoratedBox(
                                                    decoration: BoxDecoration(
                                                      border: Border.all(color: const Color(0xFFEBF3FF), width: 1),
                                                      borderRadius: BorderRadius.circular(10),
                                                    ),
                                                    child:
                                                    SizedBox(
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
                                                                fillColor: Colors.grey.shade100,
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
                                                ],
                                              ),
                                            ),

                                          ],
                                        ),

                                        //  ),
                                        // SizedBox(height: 20.h),

                                        Padding(
                                          padding: const EdgeInsets.only(left: 100,right: 100,top: 150),
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


                                        Padding(
                                          padding: const EdgeInsets.only(top: 600,left: 100,right: 100,bottom: 30),
                                          child: Container(
                                            //width: screenWidth * 0.8,
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
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                const Padding(
                                                  padding: EdgeInsets.only(top: 10, left: 30),
                                                  child: Text(
                                                    'Add Products',
                                                    style: TextStyle(fontSize: 19,color: Colors.black),
                                                  ),



                                                ),
                                                const SizedBox(height: 10),
                                                DataTable(
                                                  border: const TableBorder(
                                                    top: BorderSide(width:1 ,color: Colors.grey),
                                                    bottom: BorderSide(width:1 ,color: Colors.grey),
                                                    horizontalInside: BorderSide(width: 1,color: Colors.grey), // horizontal border inside the table
                                                    verticalInside: BorderSide(width: 1,color: Colors.grey),
                                                  ),
                                                  // border: TableBorder.all(color: const Color(0xFFB2C2D3)),
                                                  columnSpacing: 119,
                                                  headingRowHeight: 40,
                                                  columns: const [
                                                    DataColumn(label: Text('Product Name')),
                                                    DataColumn(label: Text('Category')),
                                                    DataColumn(label: Text('Sub Category')),
                                                    DataColumn(label: Text('Price')),
                                                    DataColumn(label: Text('Qty')),
                                                    DataColumn(label: Text('Amount')),
                                                    DataColumn(label: Text('TAX')),
                                                    DataColumn(label: Text('Discount')),
                                                    DataColumn(label: Text('Total Amount')),
                                                  ],
                                                  rows: const [],
                                                ),
                                                Row(
                                                  children: [
                                                    Padding(
                                                      padding: const EdgeInsets.only(left: 30, top: 25),
                                                      child: SizedBox(
                                                        width: 200,
                                                        child: OutlinedButton(
                                                          // onPressed: handleButtonPress,
                                                          //my copy
                                                          onPressed: ()

                                                          {
                                                            String validateFields() {
                                                              if ( controller.text.isEmpty) {
                                                                return 'Please Enter Customer Name.';
                                                              }
                                                              if (ContactPersonController.text.isEmpty || ContactPersonController.text.length <= 2) {
                                                                return 'Please enter a contact person name';
                                                              }
                                                              if (ContactNumberController.text.isEmpty || ContactNumberController.text.length != 10) {
                                                                return 'Please enter a valid phone number.';
                                                              }
                                                              if (deliveryaddressController.text.isEmpty) {
                                                                return 'Please fill delivery address.';
                                                              }
                                                              if(EmailIdController.text.isEmpty ||!RegExp(r'^[\w-]+(\.[\w-]+)*@gmail\.com$').hasMatch(EmailIdController.text)){
                                                                return 'Please fill Email Address Format @gmail.com';
                                                              }
                                                              if (ShippingAddress.text.isEmpty) {
                                                                return 'Please fill Shipping address ';
                                                              }


                                                              return '';
                                                            }
                                                            String validationMessage = validateFields();
                                                            if (validationMessage == '') {
                                                              Map<String, dynamic> data = {
                                                                'CusId': controller.text,
                                                                'deliveryLocation': EmailIdController.text,
                                                                'ContactName': ContactPersonController.text,
                                                                'Address': deliveryaddressController.text,
                                                                'ContactNumber': ContactNumberController.text,
                                                                'Comments': ShippingAddress.text,
                                                                'date': _dateController.text,
                                                              };
                                                              context.go('/Search_For_Products',extra: data);
                                                              //   context.go('/Home/Orders/Create_Order/Add_Product',extra: data);

                                                            } else {
                                                              ScaffoldMessenger.of(context).showSnackBar(
                                                                SnackBar(
                                                                  content: Text(validationMessage),
                                                                ),
                                                              );
                                                            }
                                                          },

                                                          style: OutlinedButton.styleFrom(
                                                            backgroundColor: Colors.blue[800],
                                                            shape: RoundedRectangleBorder(
                                                              borderRadius: BorderRadius.circular(4),
                                                            ),
                                                            side: BorderSide.none,
                                                          ),
                                                          child: const Center(
                                                            child: Text(
                                                              '+ Add Products',
                                                              style: TextStyle(color: Colors.white),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.only(top: 10),
                                                  child: Container(
                                                    height: 1,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                ],),),
                              ),
                            ))
                          }



                          // SizedBox(height: 900.h),
                        ],
                      ))
                ],
              );
            },

          ),
        );
      },
    );
  }
}




