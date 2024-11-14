import 'dart:async';
import 'dart:convert';
import 'dart:html';
import 'package:adaptive_scrollbar/adaptive_scrollbar.dart';
import 'package:btb/Order%20Module/firstpage.dart';
import 'package:btb/admin/Api%20name.dart';
import 'package:btb/admin/admin%20list.dart';
import 'package:btb/widgets/confirmdialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:http/http.dart' as http;


void main() => runApp(MaterialApp(
  debugShowCheckedModeBanner: false,
  home:CusCreateOrderPage() ,));



class CusCreateOrderPage extends StatefulWidget {
  @override
  State<CusCreateOrderPage> createState() => _CusCreateOrderPageState();
}


class _CusCreateOrderPageState extends State<CusCreateOrderPage> {
  Timer? timer;
  String? _selectedDeliveryLocation;
  late TextEditingController _dateController;

  // String? _selectedDeliveryLocation;
  final EmailIdController = TextEditingController();
  final deliveryLocationController = TextEditingController();
  final ContactPersonController = TextEditingController();
  final deliveryaddressController = TextEditingController();
  final TextEditingController ContactNumberController = TextEditingController();
  final ShippingAddress = TextEditingController();
  DateTime? _selectedDate;
  bool _isLoading= false;
  final controller = TextEditingController();
  String token = window.sessionStorage["token"] ?? " ";
  String userId = window.sessionStorage['userId'] ?? '';
  final ScrollController horizontalScroll = ScrollController();

  final FocusNode _focusNode = FocusNode();
  Map<String, bool> _isHovered = {
    'Orders': false,
    'Invoice': false,
    'Delivery': false,
    'Payment': false,
    'Return': false,
  };
  int itemCount = 0;


  List<Widget> _buildMenuItems(BuildContext context) {
    return [
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
          ),child: _buildMenuItem('Orders', Icons.warehouse_outlined, Colors.blueAccent, '/Customer_Order_List')),
      _buildMenuItem('Invoice', Icons.document_scanner_outlined, Colors.blue[900]!, '/Customer_Invoice_List'),
      _buildMenuItem('Delivery', Icons.fire_truck_outlined, Colors.blue[900]!, '/Customer_Delivery_List'),
      _buildMenuItem('Payment', Icons.payment_outlined, Colors.blue[900]!, '/Customer_Payment_List'),
      _buildMenuItem('Return', Icons.keyboard_return, Colors.blue[900]!, '/Customer_Return_List'),
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
  Future<void> fetchProducts() async {

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
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
// print('json data');
// print(jsonData);
        List<detail> products = [];
        if (jsonData != null) {
          if (jsonData is List) {
            products = jsonData.map((item) => detail.fromJson(item)).toList();
          }
          else if (jsonData is Map && jsonData.containsKey('body')) {
            products = (jsonData['body'] as List)
                .map((item) => detail.fromJson(item))
                .toList();

          }
          List<detail> matchedCustomers = products.where((customer) {  return customer.CusId == userId;}).toList();

          if (matchedCustomers.isNotEmpty) {
            setState(() {

              print('pages');
              itemCount = products.length;

            });
          }
        }
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Error decoding JSON: $e');
// Optionally, show an error message to the user
    } finally {
      if (mounted) {
      }
    }
  }
  Future<void> _getCusRecord() async {
    try {
      final response = await http.get(
        Uri.parse(
          '$apicall/email/get_all_user_master',
        ),
        headers: {
          "Content-type": "application/json",
          "Authorization": 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        List<UserResponse> employees = [];

        if (jsonData != null) {
          if (jsonData is List) {
            employees = jsonData.map((item) => UserResponse.fromJson(item)).toList();
          } else if (jsonData is Map && jsonData.containsKey('body')) {
            employees = (jsonData['body'] as List)
                .map((item) => UserResponse.fromJson(item))
                .toList();
          }


          // Instead of returning null, we ensure that we have a valid employee or handle it
          UserResponse foundEmployee = employees.firstWhere(
                (employee) => employee.userId == userId,
            orElse: () => UserResponse.empty(), // Return an empty Employee object if not found
          );

          if (foundEmployee.userId.isNotEmpty) {
            setState(() {
              // deliveryLocationController.text = foundEmployee.location;
              ContactNumberController.text = foundEmployee.mobileNumber;
              ContactPersonController.text = foundEmployee.userName;
              EmailIdController.text = foundEmployee.email;
              deliveryaddressController.text = foundEmployee.location;

              // = foundEmployee.empId;
              // Date.text = foundEmployee.joiningDate;
              // role.text = foundEmployee.role;
              // department.text= foundEmployee.department;
            });
            // Print the specific field, e.g., employee's name or any field
            print('Employee found: ${foundEmployee.userId}');
          } else {
            print('Employee with username "hari" not found.');
          }

          setState(() {
            // Update UI if needed
          });
        }
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Error decoding JSON: $e');
    } finally {
      setState(() {
        // Update UI if needed
      });
    }
  }




  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getCusRecord();
    fetchProducts();
    print(userId);

    _dateController = TextEditingController();
    _selectedDate = DateTime.now();
    String formattedDate = DateFormat('dd/MM/yyyy').format(_selectedDate!);
    _dateController.text = formattedDate;
    print('date init');
    print(_dateController.text);
    // _selectedDate = _dateController.text as DateTime?;
  }




  final List<String> list = ['  Name 1', '  Name 2', '  Name3'];






  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
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
                      padding: const  EdgeInsets.only(left: 30),
                      child: SizedBox(
                        width: screenWidth * 0.2,
                        // width: 370,
                        height: 40,
                        child: TextFormField(
                          controller: ContactPersonController,
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
                      height: 984,
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
                                        context.go('/Customer_Order_List');
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              // mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding:  EdgeInsets.only(right: maxWidth * 0.08,top: 30),
                  child:  Text(' Order Date',style: TextStyle(fontSize: maxWidth * 0.010,color: Colors.black87),),
                ),
                const SizedBox(height: 5,),
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
                        width: screenWidth * 0.15,
                        child: OutlinedButton(
                          // onPressed: handleButtonPress,
                          //my copy
                          onPressed: ()

                          {
                            String validateFields() {
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
                                'CusId':userId,
                                'deliveryLocation': EmailIdController.text,
                                'ContactName': ContactPersonController.text,
                                'Address': deliveryaddressController.text,
                                'ContactNumber': ContactNumberController.text,
                                'Comments': ShippingAddress.text,
                                'date': _dateController.text,
                              };
                              context.go('/Search_products',extra: data);
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
      Expanded(child: AdaptiveScrollbar(

        position: ScrollbarPosition.bottom,controller: horizontalScroll,
        child: SingleChildScrollView(
          controller: horizontalScroll,
          scrollDirection: Axis.horizontal,
          child: SingleChildScrollView(
            child: Column(children: [
            SizedBox(
              width: 1700,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                // mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding:  EdgeInsets.only(right: 220,top: 30),
                    child:  Text(' Order Date',style: TextStyle(fontSize:15,color: Colors.black87),),
                  ),
                  const SizedBox(height: 5,),
                  Padding(
                    padding:  EdgeInsets.only(right: 100),
                    child: SizedBox(
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
                  //  ),
                  // SizedBox(height: 20.h),


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
                        columnSpacing: 118.5,
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
                            width: screenWidth * 0.1,
                            child: OutlinedButton(
                              // onPressed: handleButtonPress,
                              //my copy
                              onPressed: ()

                              {
                                String validateFields() {
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
                                    'CusId':userId,
                                    'deliveryLocation': EmailIdController.text,
                                    'ContactName': ContactPersonController.text,
                                    'Address': deliveryaddressController.text,
                                    'ContactNumber': ContactNumberController.text,
                                    'Comments': ShippingAddress.text,
                                    'date': _dateController.text,
                                  };
                                  context.go('/Search_products',extra: data);
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

