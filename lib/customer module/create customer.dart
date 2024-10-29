import 'dart:convert';
import 'dart:html';
import 'dart:io' as io;
import 'package:btb/admin/Api%20name.dart';
import 'package:btb/widgets/confirmdialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'customer list.dart';



class CreateCustomer extends StatefulWidget {
  const CreateCustomer({
    super.key,
  });

  @override
  State<CreateCustomer> createState() => _CreateCustomerState();
}

class _CreateCustomerState extends State<CreateCustomer> {
  String? pickedImagePath;
  String token = window.sessionStorage["token"] ?? " ";
  String? imagePath;
  io.File? selectedImage;
  bool isOrdersSelected = false;
  String? errorMessage;
  bool purchaseOrderError = false;
  final TextEditingController priceController = TextEditingController();
  final TextEditingController ContactnoController = TextEditingController();
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
  final TextEditingController EmailController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController unitController = TextEditingController();
  bool isHomeSelected = false;
  final _formKey = GlobalKey<FormState>();



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
      _buildMenuItem('Home', Icons.dashboard, Colors.blue[900]!, '/Home'),
      _buildMenuItem('Customer', Icons.account_circle, Colors.blueAccent, '/Customer'),
      _buildMenuItem('Products', Icons.image_outlined, Colors.blue[900]!, '/Product_List'),
      _buildMenuItem('Orders', Icons.warehouse, Colors.blue[900]!, '/Order_List'),
      _buildMenuItem('Invoice', Icons.document_scanner_rounded, Colors.blue[900]!, '/Invoice'),
      _buildMenuItem('Delivery', Icons.fire_truck_outlined, Colors.blue[900]!, '/Delivery_List'),
      _buildMenuItem('Payment', Icons.payment_outlined, Colors.blue[900]!, '/Payment_List'),
      _buildMenuItem('Return', Icons.backspace_sharp, Colors.blue[900]!, '/Return_List'),
      _buildMenuItem('Reports', Icons.insert_chart, Colors.blue[900]!, '/Report_List'),
    ];
  }

  Widget _buildMenuItem(String title, IconData icon, Color iconColor, String route) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered[title] = true),
      onExit: (_) => setState(() => _isHovered[title] = false),
      child: GestureDetector(
        onTap: () {
          context.go(route);
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 10,right: 20),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: _isHovered[title]! ? Colors.black12 : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
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
    );
  }

  // Function to check if all required fields are filled
  Future<void> cusSave() async {
    print('hello');

    String url =
        "$apicall/customer_master/add_customer_master";
    Map<String, dynamic> data = {
      "contactNo": ContactnoController.text,
      "customerName": cusNameController.text,
      "billingAddress": addressController.text,
      "deliveryLocation": addressController.text,
      "email": EmailController.text,
      "shippingAddress": "string",
      "returnCredit": 0
    };
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token'
    };

    final response = await http.post(Uri.parse(url),
        headers: headers, body: jsonEncode(data));

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
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            const CusList(),
                        transitionDuration: const Duration(milliseconds: 200),
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
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
                  child: const Text(
                    'OK',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
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
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: AccountMenu(),
            ),
          ],
        ),
        body: LayoutBuilder(builder: (context, constraints) {
          double maxWidth = constraints.maxWidth;
          double maxHeight = constraints.maxHeight;
          return Stack(children: [
            Align(
              // Added Align widget for the left side menu
              alignment: Alignment.topLeft,
              child: Container(
                height: 1400,
                width: 200,
                color: const Color(0xFFF7F6FA),
                padding: const EdgeInsets.only(left: 20, top: 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _buildMenuItems(context),
                ),
              ),
            ),
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
                          Navigator.of(context).push(PageRouteBuilder(
                            pageBuilder:
                                (context, animation, secondaryAnimation) =>
                                    const CusList(),
                          ));
                        },
                      ),
                      const Padding(
                        padding: EdgeInsets.only(left: 20),
                        child: Text(
                          'Create Customer',
                          style: TextStyle(
                            fontSize: 20,
                            // fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
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
            Row(
              children: [
                Expanded(
                  child: Card(
                    margin: EdgeInsets.only(
                        left: maxWidth * 0.4,
                        top: maxHeight * 0.15,
                        right: maxWidth * 0.3),
                    color: Colors.white,
                    elevation: 0.0,
                    child: Form(
                      key: _validate,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.account_circle,
                              size: 100,
                            ),
                            const SizedBox(
                              height: 16,
                            ),
                            // Customer Name
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
                                    cusNameController.text.trim().isEmpty) {
                                  return 'Please enter a customer name';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            // Email
                            TextFormField(
                              controller: EmailController,
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
                                    RegExp("[a-zA-Z,0-9,@.]")),
                                FilteringTextInputFormatter.deny(
                                    RegExp(r'^\s')),
                                FilteringTextInputFormatter.deny(
                                    RegExp(r'\s\s')),
                              ],
                              validator: (value) {
                                if (value != null && value.trim().isEmpty) {
                                  return 'Please enter an email';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Contact Number
                            TextFormField(
                              controller: ContactnoController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(10),
                              ],
                              decoration: const InputDecoration(
                                labelText: 'Contact Number *',
                                labelStyle: TextStyle(
                                    fontSize: 16, color: Colors.black87),
                                border: OutlineInputBorder(),
                                hintText: 'Enter Contact Number',
                                hintStyle: TextStyle(color: Colors.grey),
                              ),
                              validator: (value) {
                                if (value != null && value.trim().isEmpty) {
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
                                    fontSize: 16, color: Colors.black87),
                                border: OutlineInputBorder(),
                                hintText: 'Enter Address',
                                hintStyle: TextStyle(color: Colors.grey),
                              ),
                              validator: (value) {
                                if (value != null && value.trim().isEmpty) {
                                  return 'Please enter an address';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            const SizedBox(height: 40),
                            // Buttons
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                OutlinedButton(
                                  onPressed: () {
                                    ContactnoController.clear();
                                    cusNameController.clear();
                                    addressController.clear();
                                    EmailController.clear();
                                    // Clear form
                                  },
                                  style: OutlinedButton.styleFrom(
                                    backgroundColor: Colors.grey[300],
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5),
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
                                        cusNameController.text.length <= 2) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              'Please fill  Customer name'),
                                        ),
                                      );
                                    } else if (EmailController.text.isEmpty ||
                                        !RegExp(r'^[\w-]+(\.[\w-]+)*@gmail\.com$')
                                            .hasMatch(EmailController.text)) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              'Please fill Email Address Format @gmail.com'),
                                        ),
                                      );
                                    } else if (ContactnoController
                                            .text.isEmpty ||
                                        ContactnoController.text.length != 10) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              'Please enter a valid phone number.'),
                                        ),
                                      );
                                    } else if (addressController.text.isEmpty) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content:
                                              Text('Please fill  address '),
                                        ),
                                      );
                                    } else {
                                      cusSave();
                                    } // Save form
                                  },
                                  style: OutlinedButton.styleFrom(
                                    backgroundColor: Colors.blue[800],
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5),
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
              ],
            )
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
