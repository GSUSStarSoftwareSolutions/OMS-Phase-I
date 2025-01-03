import 'dart:convert';
import 'dart:html';
import 'dart:io' as io;
import 'package:adaptive_scrollbar/adaptive_scrollbar.dart';
import 'package:btb/widgets/Api%20name.dart';
import 'package:btb/widgets/confirmdialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;

class CreateCustomer extends StatefulWidget {
  const CreateCustomer({
    super.key,
  });

  @override
  State<CreateCustomer> createState() => _CreateCustomerState();
}

class _CreateCustomerState extends State<CreateCustomer> {
  bool _hasShownPopup = false;
  String? pickedImagePath;
  String token = window.sessionStorage["token"] ?? " ";
  String? imagePath;
  io.File? selectedImage;
  final ScrollController horizontalScroll = ScrollController();
  bool isOrdersSelected = false;
  String? errorMessage;
  bool purchaseOrderError = false;
  final TextEditingController priceController = TextEditingController();
  final TextEditingController contactnoController = TextEditingController();
  final TextEditingController imageIdController = TextEditingController();
  final List<String> list = ['Select', 'Select 1', 'Select 2', 'Select 3'];
  String dropdownValue = 'Select';
  final List<String> list1 = ['Select', '12%', '18%', '28%', '10%'];
  String? selectedDropdownItem;
  String dropdownValue1 = 'Select';
  String imageName = '';
  List<Uint8List> selectedImages = [];
  String storeImage = '';
  final List<String> list2 = ['Select', 'PCS', 'NOS', 'PKT'];
  String dropdownValue2 = 'Select';
  final List<String> list3 = ['Select', 'Yes', 'No'];
  String dropdownValue3 = 'Select';
  final _validate = GlobalKey<FormState>();
  var result;
  final TextEditingController cusNameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController shippingAdd1 = TextEditingController();
  final TextEditingController shippingAdd2 = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController unitController = TextEditingController();
  bool isHomeSelected = false;
  final _formKey = GlobalKey<FormState>();

  final Map<String, bool> _isHovered = {
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
      Container(
          decoration: BoxDecoration(
            color: Colors.blue[800],
            // border: Border(  left: BorderSide(    color: Colors.blue,    width: 5.0,  ),),
            // color: Color.fromRGBO(224, 59, 48, 1.0),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8), // Radius for top-left corner
              topRight: Radius.circular(8), // No radius for top-right corner
              bottomLeft: Radius.circular(8), // Radius for bottom-left corner
              bottomRight:
                  Radius.circular(8), // No radius for bottom-right corner
            ),
          ),
          child: _buildMenuItem('Customer', Icons.account_circle_outlined,
              Colors.blueAccent, '/Customer')),
      _buildMenuItem(
          'Orders', Icons.warehouse_outlined, Colors.blue[900]!, '/Order_List'),
    ];
  }

  Widget _buildMenuItem(
      String title, IconData icon, Color iconColor, String route) {
    iconColor = _isHovered[title] == true ? Colors.blue : Colors.black87;
    title == 'Customer' ? _isHovered[title] = false : _isHovered[title] = false;
    title == 'Customer' ? iconColor = Colors.white : Colors.black;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered[title] = true),
      onExit: (_) => setState(() => _isHovered[title] = false),
      child: GestureDetector(
        onTap: () {
          context.go(route);
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 5, right: 10),
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

  // Function to check if all required fields are filled
  Future<void> cusSave() async {
    print('hello');

    String url = "$apicall/customer_master/add_customer_master";
    Map<String, dynamic> data = {
      "contactNo": contactnoController.text,
      "customerName": cusNameController.text,
      "billingAddress": addressController.text,
      "deliveryLocation": addressController.text,
      "email": emailController.text,
      "shippingAddress1": shippingAdd1.text,
      "shippingAddress2": shippingAdd2.text,
      "returnCredit": 0
    };
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token'
    };

    final response = await http.post(Uri.parse(url),
        headers: headers, body: jsonEncode(data));
    if (token == " ") {
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
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
                      const Icon(Icons.warning, color: Colors.orange, size: 50),
                      const SizedBox(height: 16),
                      // Confirmation Message
                      const Text(
                        'Session Expired',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const Text(
                        "Please log in again to continue",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 20),
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
                              side: const BorderSide(color: Colors.blue),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                            child: const Text(
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
    } else {
      if (response.statusCode == 200) {
        // Parse response body
        final addResponseBody = jsonDecode(response.body);

        if (addResponseBody['status'] == 'success') {
          // Payment successful
          print('hello api');
          final customerId = addResponseBody['id'];
          showDialog(
            barrierDismissible: false,
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                icon: const Icon(
                  Icons.check_circle_rounded,
                  color: Colors.green,
                  size: 25,
                ),
                title: const Padding(
                  padding: EdgeInsets.only(left: 12),
                  child: Text(
                    'Customer registered successfully!',
                    style: TextStyle(fontSize: 15),
                  ),
                ),
                content: Padding(
                    padding: const EdgeInsets.only(left: 25),
                    child: Row(
                      children: [
                        const Text('Your Customer ID is: '),
                        SelectableText('$customerId'),
                      ],
                    )),
                actions: <Widget>[
                  ElevatedButton(
                    onPressed: () {
                      context.go('/Customer');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      side: const BorderSide(color: Colors.blue),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    child: const Text(
                      'OK',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              );
            },
          );
        } else if (addResponseBody['status'] == 'failed' &&
            addResponseBody['code'] == '508') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Customer name already exists'),
            ),
          );
        } else if (addResponseBody['status'] == 'failed' &&
            addResponseBody['code'] == '509') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('This email id already exists'),
            ),
          );
        } else {
          // Handle other cases
          print('Unexpected response: $addResponseBody');
        }
      } else {
        // If the response code is not 200, print the error
        print('Error: ${response.statusCode}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xFFFFFFFF),
        appBar: AppBar(
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
            const Padding(
              padding: EdgeInsets.only(top: 10),
              child: AccountMenu(),
            ),
          ],
        ),
        body: LayoutBuilder(builder: (context, constraints) {
          double maxWidth = constraints.maxWidth;
          double maxHeight = constraints.maxHeight;
          return Stack(children: [
            if (constraints.maxHeight <= 500) ...{
              SingleChildScrollView(
                child: Align(
                  // Added Align widget for the left side menu
                  alignment: Alignment.topLeft,
                  child: Container(
                    height: 1400,
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
              ),
            } else ...{
              Align(
                // Added Align widget for the left side menu
                alignment: Alignment.topLeft,
                child: Container(
                  height: 1400,
                  width: 200,
                  color: const Color(0xFFF7F6FA),
                  padding: const EdgeInsets.only(left: 15, top: 10, right: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _buildMenuItems(context),
                  ),
                ),
              ),
            },
            Padding(
              padding: const EdgeInsets.only(left: 190),
              child: Container(
                margin: const EdgeInsets.symmetric(
                    horizontal: 10), // Space above/below the border
                width: 1, // Border height
                color: Colors.grey, // Border color
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.only(left: 205),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  color: Colors.white,
                  height: 60,
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back), // Back button icon
                        onPressed: () {
                          context.go('/Customer');
                        },
                      ),
                      const Padding(
                        padding: EdgeInsets.only(left: 20),
                        child: Text(
                          'Create Customer',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 43, left: 200),
              child: Container(
                margin: const EdgeInsets.symmetric(
                    vertical: 10), // Space above/below the border
                height: 1, // Border height
                color: Colors.grey, // Border color
              ),
            ),
            if (constraints.maxWidth >= 1350) ...{
              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding:
                          const EdgeInsets.only(left: 350, right: 120, top: 80),
                      child: Container(
                        color: Colors.white,
                        width: 800,
                        height: 800,
                        child: SingleChildScrollView(
                          child: Container(
                            width: 1200,
                            margin: EdgeInsets.only(
                                left: maxWidth * 0.19,
                                top: 10,
                                bottom: maxHeight * 0.02,
                                right: maxWidth * 0.19),
                            color: Colors.white,
                            // elevation: 0.0,
                            child: Form(
                              key: _validate,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TextFormField(
                                    controller: cusNameController,
                                    decoration: const InputDecoration(
                                      labelText: 'Customer Name *',
                                      labelStyle: TextStyle(
                                          fontSize: 16, color: Colors.black87),
                                      border: OutlineInputBorder(),
                                      hintText: 'Enter Customer Name',
                                      hintStyle: TextStyle(color: Colors.grey),
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
                                      if (cusNameController.text != null &&
                                          cusNameController.text
                                              .trim()
                                              .isEmpty) {
                                        return 'Please enter a customer name';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  // Email
                                  TextFormField(
                                    controller: emailController,
                                    decoration: const InputDecoration(
                                      labelText: 'Email *',
                                      labelStyle: TextStyle(
                                          fontSize: 16, color: Colors.black87),
                                      border: OutlineInputBorder(),
                                      hintText: 'Enter Email',
                                      hintStyle: TextStyle(color: Colors.grey),
                                    ),
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(
                                          RegExp("[a-zA-Z,0-9,@.-]")),
                                      FilteringTextInputFormatter.deny(
                                          RegExp(r'^\s')),
                                      FilteringTextInputFormatter.deny(
                                          RegExp(r'\s\s')),
                                    ],
                                    onChanged: (value) {
                                      emailController.value = TextEditingValue(
                                        text: value.toLowerCase(),
                                        selection: emailController.selection,
                                      );
                                    },
                                    validator: (value) {
                                      if (value != null &&
                                          value.trim().isEmpty) {
                                        return 'Please enter an email';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),

                                  // Contact Number
          TextFormField(
          controller: contactnoController,
          decoration: const InputDecoration(
          labelText: 'Mobile Number *',
          labelStyle: TextStyle(fontSize: 16, color: Colors.black87),
          border: OutlineInputBorder(),
          hintText: 'Enter Mobile Number',
          hintStyle: TextStyle(color: Colors.grey),
          prefixText: '+91 ',
          prefixStyle: TextStyle(color: Colors.black87, fontSize: 16),
          ),
          keyboardType: TextInputType.phone,
          inputFormatters: [LengthLimitingTextInputFormatter(10),
          FilteringTextInputFormatter.allow(RegExp(r'[0-9]')), // Allow only numbers
          FilteringTextInputFormatter.deny(RegExp(r'^\s')), // Disallow starting with a space
          FilteringTextInputFormatter.deny(RegExp(r'\s\s')), // Disallow multiple spaces
          ],
          validator: (value) {
          if (value == null || value.trim().isEmpty) {
          return 'Please enter a mobile number';
          }
          if (value.trim().length != 10) {
          return 'Please enter a valid 10-digit mobile number';
          }
          return null;
          },
          ),

          // TextFormField(
                                  //   controller: ContactnoController,
                                  //   keyboardType: TextInputType.number,
                                  //   inputFormatters: [
                                  //     FilteringTextInputFormatter.digitsOnly,
                                  //     LengthLimitingTextInputFormatter(10),
                                  //   ],
                                  //   decoration: const InputDecoration(
                                  //     labelText: 'Contact Number *',
                                  //     labelStyle: TextStyle(
                                  //         fontSize: 16, color: Colors.black87),
                                  //     border: OutlineInputBorder(),
                                  //     hintText: 'Enter Contact Number',
                                  //     hintStyle: TextStyle(color: Colors.grey),
                                  //   ),
                                  //   validator: (value) {
                                  //     if (value != null &&
                                  //         value.trim().isEmpty) {
                                  //       return 'Please enter a contact number';
                                  //     }
                                  //     return null;
                                  //   },
                                  // ),
                                  const SizedBox(height: 16),
                                  // Address
                                  TextFormField(
                                    controller: addressController,
                                    maxLines: 3,
                                    decoration: const InputDecoration(
                                      labelText: ' Billing Address *',
                                      labelStyle: TextStyle(
                                          fontSize: 16, color: Colors.black87),
                                      border: OutlineInputBorder(),
                                      hintText: 'Enter Address',
                                      hintStyle: TextStyle(color: Colors.grey),
                                    ),
                                    validator: (value) {
                                      if (value != null &&
                                          value.trim().isEmpty) {
                                        return 'Please enter an address';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextFormField(
                                          controller: shippingAdd1,
                                          maxLines: 3,
                                          decoration: const InputDecoration(
                                            labelText: 'Shipping Address 1 *',
                                            labelStyle: TextStyle(
                                                fontSize: 16,
                                                color: Colors.black87),
                                            border: OutlineInputBorder(),
                                            hintText: 'Enter Address',
                                            hintStyle:
                                                TextStyle(color: Colors.grey),
                                          ),
                                          validator: (value) {
                                            if (value != null &&
                                                value.trim().isEmpty) {
                                              return 'Please enter an address';
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: TextFormField(
                                          controller: shippingAdd2,
                                          maxLines: 3,
                                          decoration: const InputDecoration(
                                            labelText: 'Shipping Address 2 *',
                                            labelStyle: TextStyle(
                                                fontSize: 16,
                                                color: Colors.black87),
                                            border: OutlineInputBorder(),
                                            hintText: 'Enter Address',
                                            hintStyle:
                                                TextStyle(color: Colors.grey),
                                          ),
                                          validator: (value) {
                                            if (value != null &&
                                                value.trim().isEmpty) {
                                              return 'Please enter an address';
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),

                                  // Buttons
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      OutlinedButton(
                                        onPressed: () {
                                          contactnoController.clear();
                                          cusNameController.clear();
                                          addressController.clear();
                                          emailController.clear();
                                          shippingAdd1.clear();
                                          shippingAdd2.clear();
                                          // Clear form
                                        },
                                        style: OutlinedButton.styleFrom(
                                          backgroundColor: Colors.grey[300],
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                          ),
                                          side: BorderSide.none,
                                        ),
                                        child: Text(
                                          'Cancel',
                                          style: TextStyle(
                                            fontSize: 15,
                                            color: Colors.indigo[900],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      OutlinedButton(
                                        onPressed: () async {
                                          if (cusNameController.text.isEmpty ||
                                              cusNameController.text.length <=
                                                  2) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                    'Please fill  Customer name'),
                                              ),
                                            );
                                          } else if (emailController
                                                  .text.isEmpty ||
                                              !RegExp(r'^[\w-]+(\.[\w-]+)*@[a-zA-Z0-9-]+\.(com|in|net)$')
                                                  .hasMatch(
                                                      emailController.text)) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                  content: Text(
                                                      'Enter Valid E-mail Address')),
                                            );
                                          } else if (contactnoController
                                                  .text.isEmpty ||
                                              contactnoController.text.length !=
                                                  10) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                    'Please enter a valid phone number.'),
                                              ),
                                            );
                                          } else if (addressController
                                              .text.isEmpty) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                    'Please fill  address '),
                                              ),
                                            );
                                          } else {
                                            cusSave();
                                          } // Save form
                                        },
                                        style: OutlinedButton.styleFrom(
                                          backgroundColor: Colors.blue[800],
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                          ),
                                          side: BorderSide.none,
                                        ),
                                        child: const Text(
                                          'Save',
                                          style: TextStyle(
                                            fontSize: 15,
                                            color: Colors.white,
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
                      ),
                    ),
                  ),
                ],
              ),
            } else ...{
              Padding(
                  padding: const EdgeInsets.only(
                      left: 450, right: 30, top: 100, bottom: 30),
                  child: Container(
                    color: Colors.white,
                    width: 900,
                    height: 800,
                    child: AdaptiveScrollbar(
                      controller: horizontalScroll,
                      position: ScrollbarPosition.bottom,
                      child: SingleChildScrollView(
                        controller: horizontalScroll,
                        scrollDirection: Axis.horizontal,
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 600,
                                    height: 800,
                                    // margin: EdgeInsets.only(
                                    //     left: 350,
                                    //     top: 120,
                                    //     bottom: 80,
                                    //     right: 30
                                    // ),
                                    color: Colors.white,
                                    // elevation: 0.0,
                                    child: Form(
                                      key: _validate,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(
                                            height: 40,
                                          ),
                                          SizedBox(
                                            width: 300,
                                            child: TextFormField(
                                              controller: cusNameController,
                                              decoration: const InputDecoration(
                                                labelText: 'Customer Name *',
                                                labelStyle: TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.black87),
                                                border: OutlineInputBorder(),
                                                hintText: 'Enter Customer Name',
                                                hintStyle: TextStyle(
                                                    color: Colors.grey),
                                              ),
                                              inputFormatters: [
                                                FilteringTextInputFormatter
                                                    .allow(RegExp("[a-zA-Z ]")),
                                                // Allow only letters, numbers, and single space
                                                FilteringTextInputFormatter
                                                    .deny(RegExp(r'^\s')),
                                                // Disallow starting with a space
                                                FilteringTextInputFormatter
                                                    .deny(RegExp(r'\s\s')),
                                                // Disallow multiple spaces
                                              ],
                                              validator: (value) {
                                                if (cusNameController.text !=
                                                        null &&
                                                    cusNameController.text
                                                        .trim()
                                                        .isEmpty) {
                                                  return 'Please enter a customer name';
                                                }
                                                return null;
                                              },
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                          // Email
                                          TextFormField(
                                            controller: emailController,
                                            decoration: const InputDecoration(
                                              labelText: 'Email *',
                                              labelStyle: TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.black87),
                                              border: OutlineInputBorder(),
                                              hintText: 'Enter Email',
                                              hintStyle:
                                                  TextStyle(color: Colors.grey),
                                            ),
                                            inputFormatters: [
                                              FilteringTextInputFormatter.allow(
                                                  RegExp("[a-zA-Z,0-9,@.-]")),
                                              FilteringTextInputFormatter.deny(
                                                  RegExp(r'^\s')),
                                              FilteringTextInputFormatter.deny(
                                                  RegExp(r'\s\s')),
                                            ],
                                            onChanged: (value) {
                                              emailController.value = TextEditingValue(
                                                text: value.toLowerCase(),
                                                selection: emailController.selection,
                                              );
                                            },
                                            validator: (value) {
                                              if (value != null &&
                                                  value.trim().isEmpty) {
                                                return 'Please enter an email';
                                              }
                                              return null;
                                            },
                                          ),
                                          const SizedBox(height: 16),

                                          // Contact Number
                                          TextFormField(
                                            controller: contactnoController,
                                            keyboardType: TextInputType.number,
                                            inputFormatters: [
                                              FilteringTextInputFormatter
                                                  .digitsOnly,
                                              LengthLimitingTextInputFormatter(
                                                  10),
                                            ],
                                            decoration: const InputDecoration(
                                              labelText: 'Contact Number *',
                                              labelStyle: TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.black87),
                                              border: OutlineInputBorder(),
                                              hintText: 'Enter Contact Number',
                                              hintStyle:
                                                  TextStyle(color: Colors.grey),
                                            ),
                                            validator: (value) {
                                              if (value != null &&
                                                  value.trim().isEmpty) {
                                                return 'Please enter a contact number';
                                              }
                                              return null;
                                            },
                                          ),
                                          const SizedBox(height: 16),
                                          // Address
                                          TextFormField(
                                            controller: addressController,
                                            maxLines: 3,
                                            decoration: const InputDecoration(
                                              labelText: ' Billing Address *',
                                              labelStyle: TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.black87),
                                              border: OutlineInputBorder(),
                                              hintText: 'Enter Address',
                                              hintStyle:
                                                  TextStyle(color: Colors.grey),
                                            ),
                                            validator: (value) {
                                              if (value != null &&
                                                  value.trim().isEmpty) {
                                                return 'Please enter an address';
                                              }
                                              return null;
                                            },
                                          ),
                                          const SizedBox(height: 16),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: TextFormField(
                                                  controller: shippingAdd1,
                                                  maxLines: 3,
                                                  decoration:
                                                      const InputDecoration(
                                                    labelText:
                                                        'Shipping Address 1 *',
                                                    labelStyle: TextStyle(
                                                        fontSize: 16,
                                                        color: Colors.black87),
                                                    border:
                                                        OutlineInputBorder(),
                                                    hintText: 'Enter Address',
                                                    hintStyle: TextStyle(
                                                        color: Colors.grey),
                                                  ),
                                                  validator: (value) {
                                                    if (value != null &&
                                                        value.trim().isEmpty) {
                                                      return 'Please enter an address';
                                                    }
                                                    return null;
                                                  },
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              Expanded(
                                                child: TextFormField(
                                                  controller: shippingAdd2,
                                                  maxLines: 3,
                                                  decoration:
                                                      const InputDecoration(
                                                    labelText:
                                                        'Shipping Address 2 *',
                                                    labelStyle: TextStyle(
                                                        fontSize: 16,
                                                        color: Colors.black87),
                                                    border:
                                                        OutlineInputBorder(),
                                                    hintText: 'Enter Address',
                                                    hintStyle: TextStyle(
                                                        color: Colors.grey),
                                                  ),
                                                  validator: (value) {
                                                    if (value != null &&
                                                        value.trim().isEmpty) {
                                                      return 'Please enter an address';
                                                    }
                                                    return null;
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 16),

                                          // Buttons
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              OutlinedButton(
                                                onPressed: () {
                                                  contactnoController.clear();
                                                  cusNameController.clear();
                                                  addressController.clear();
                                                  emailController.clear();
                                                  // Clear form
                                                },
                                                style: OutlinedButton.styleFrom(
                                                  backgroundColor:
                                                      Colors.grey[300],
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5),
                                                  ),
                                                  side: BorderSide.none,
                                                ),
                                                child: Text(
                                                  'Cancel',
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                    color: Colors.indigo[900],
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 16),
                                              OutlinedButton(
                                                onPressed: () async {
                                                  if (cusNameController
                                                          .text.isEmpty ||
                                                      cusNameController
                                                              .text.length <=
                                                          2) {
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                      const SnackBar(
                                                        content: Text(
                                                            'Please fill  Customer name'),
                                                      ),
                                                    );
                                                  } else if (emailController
                                                          .text.isEmpty ||
                                                      !RegExp(r'^[\w-]+(\.[\w-]+)*@[a-zA-Z0-9-]+\.(com|in|net)$')
                                                          .hasMatch(
                                                              emailController
                                                                  .text)) {
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                      const SnackBar(
                                                          content: Text(
                                                              'Enter Valid E-mail Address')),
                                                    );
                                                  } else if (contactnoController
                                                          .text.isEmpty ||
                                                      contactnoController
                                                              .text.length !=
                                                          10) {
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                      const SnackBar(
                                                        content: Text(
                                                            'Please enter a valid phone number.'),
                                                      ),
                                                    );
                                                  } else if (addressController
                                                      .text.isEmpty) {
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                      const SnackBar(
                                                        content: Text(
                                                            'Please fill  address '),
                                                      ),
                                                    );
                                                  } else {
                                                    cusSave();
                                                  } // Save form
                                                },
                                                style: OutlinedButton.styleFrom(
                                                  backgroundColor:
                                                      Colors.blue[800],
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5),
                                                  ),
                                                  side: BorderSide.none,
                                                ),
                                                child: const Text(
                                                  'Save',
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
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
                  ))
            }
          ]);
        })); // Use the ProductForm widget here
  }
}

bool isNumeric(String value) {
  return double.tryParse(value) != null;
}

customerFieldDecoration(
    {required String hintText, required bool error, Function? onTap}) {
  return InputDecoration(
    constraints: BoxConstraints(maxHeight: error == true ? 50 : 30),
    hintText: hintText,
    hintStyle: const TextStyle(fontSize: 11),
    border:
        const OutlineInputBorder(borderSide: BorderSide(color: Colors.blue)),
    counterText: '',
    contentPadding: const EdgeInsets.fromLTRB(12, 00, 0, 0),
    enabledBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Color(0xff9FB3C8))),
    focusedBorder:
        const OutlineInputBorder(borderSide: BorderSide(color: Colors.blue)),
  );
}
