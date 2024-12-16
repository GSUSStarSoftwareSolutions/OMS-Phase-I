import 'dart:convert';
import 'dart:html';
import 'package:adaptive_scrollbar/adaptive_scrollbar.dart';
import 'package:btb/admin/Api%20name.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

import '../dashboard/dashboard.dart';
import '../widgets/confirmdialog.dart';
import '../widgets/sample.dart';
import '../widgets/text_style.dart';
void main()
{
  runApp(userEdit());
}

class userEdit extends StatefulWidget {
  final Map<String, dynamic>? EditUser;
  const userEdit({super.key,this.EditUser});

  @override
  State<userEdit> createState() => _userEditState();
}
class _userEditState extends State<userEdit> {
  bool _hasShownPopup = false;
  String token = window.sessionStorage["token"] ?? " ";
  final ScrollController _scrollController = ScrollController();
  late TextEditingController dateController;
  TextEditingController location = TextEditingController();
  TextEditingController userNameController = TextEditingController();
  TextEditingController userId = TextEditingController();
  TextEditingController ShippingAddress1 = TextEditingController();
  TextEditingController ShippingAddress2 = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController departmentController = TextEditingController();
  TextEditingController designationController = TextEditingController();
  TextEditingController mobileController = TextEditingController();
  DateTime? selectedDate;
  final ScrollController horizontalScroll = ScrollController();
  final formKey = GlobalKey<FormState>();
  List<String> items = [
    'Admin',
    'Employee',
    'Customer',
  ];
  String? selectedValue;

  bool _obscureText = true;

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }
  Future<void> cusUpdate(BuildContext context) async {
    String url = "$apicall/user/edit-usermaster";
    Map<String, dynamic> data = {
      "active": true,
      "userId": userId.text,
      "companyName": departmentController.text,
      "email": emailController.text,
      "location": location.text,
      "mobileNumber": mobileController.text,
      "role": selectedValue,
      "userName": userNameController.text,
      "ShippingAddress1": ShippingAddress1.text,
      "ShippingAddress2": ShippingAddress2.text,
    };
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token'
    };

    try {
      final response = await http.put(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(data),
      );
      if(token == " "){
        {
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
      }
      else{
        if (response.statusCode == 200) {
          final addResponseBody = jsonDecode(response.body);

          if (addResponseBody['status'] == 'success') {
            // Show success dialog
            final customerId = addResponseBody['id'];
            showDialog(
              barrierDismissible: false,
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  icon: const Icon(Icons.check_circle_rounded, color: Colors.green, size: 25),
                  title: const Text(
                    'Updated Successfully!.',
                    style: TextStyle(fontSize: 15),
                  ),

                  actions: [
                    ElevatedButton(
                      onPressed: () {
                        context.go('/User_List');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      child: const Text('OK', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                );
              },
            );
          } else if (addResponseBody['status'] == 'failed' &&
              addResponseBody['error'] == 'email already exist') {
            // Display the SnackBar for existing email error
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('This email already exists.'),
                duration: Duration(seconds: 2), // Optional duration
              ),
            );
          }
          else if (addResponseBody['status'] == 'failed' &&
              addResponseBody['error'] == 'mobile number already exists') {
            // Display the SnackBar for existing email error
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('This mobile number already exists.'),
                duration: Duration(seconds: 2), // Optional duration
              ),
            );
          }
          else {
            print('Unexpected response: $addResponseBody');
          }
        } else {
          print('Error: ${response.statusCode}');
        }
      }


    } catch (e) {
      print('Network error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Network error. Please try again.')),
      );
    }
  }



  void initState() {
    super.initState();
    print('hdkndkc');
    print(widget.EditUser);
    userId.text = widget.EditUser!['userId'];
    selectedValue = widget.EditUser!['role'];
    userNameController.text = widget.EditUser!['userName'] ?? '';
    emailController.text = widget.EditUser!['email']?? '';
    departmentController.text = widget.EditUser!['companyName']?? '';
    mobileController.text = widget.EditUser!['mobileNumber']?? '';
    location.text = widget.EditUser!['location']?? '';
    ShippingAddress1.text = widget.EditUser!['shippingAddress1']?? '';
    ShippingAddress2.text = widget.EditUser!['shippingAddress2']?? '';
    dateController = TextEditingController();
    dateController.text = 'Joining Date';
  }

  void dispose() {
    location.dispose();
    super.dispose();
  }


  Map<String, bool> _isHovered = {
    'Home': false,
  };

  List<Widget> _buildMenuItems(BuildContext context, constraints) {
    double maxWidth = constraints.maxWidth;
    return [
      Column(
        children: [
          const SizedBox(
            height: 10,
          ),
          Container(
            padding: const EdgeInsets.all(8.0),
            child: Container(
               // width: maxWidth * 0.11,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.blue[800],
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                    bottomLeft: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ),
                ),
                child: _buildMenuItem(
                    context, 'Home', Icons.home, Colors.white, '/User_List')),
          ),
        ],
      ),
      const SizedBox(
        height: 6,
      ),
    ];
  }

  Widget _buildMenuItem(BuildContext context, String title, IconData icon,
      Color iconColor, String route) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => {},
      onExit: (_) => {},
      child: GestureDetector(
        onTap: () {
          context.go(route);
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 5, right: 20),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.only(left: 10, top: 2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(
                  icon,
                  color: iconColor,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style:  TextStyles.button1,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.grey[50],

        body: LayoutBuilder(
          builder: (context, constraints) {
            double maxWidth = constraints.maxWidth;
            double maxHeight = constraints.maxHeight;
            return Stack(
              children: [
                Container(
                  width: maxWidth,
                  // White background color
                  height: 60,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        bottom: BorderSide(
                          color: Color(0x29000000), // Bottom border color
                          width: 3.0, // Thickness of the bottom border
                        ),
                      )
                  ), // // Total height including bottom shadow
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 15, top: 10),
                            child: Image.asset(
                              "images/Final-Ikyam-Logo.png",
                              height: 35.0,
                              // Adjusted to better match proportions
                            ),
                          ),
                          const Spacer(),
                          Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                  right: 10,top: 10
                                ),
                                // Adjust padding for better spacing
                                child: AccountMenu(),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (constraints.maxHeight <= 500) ...{
                  Positioned(
                    top:60,
                    left:0,
                    right:0,
                    bottom: 0,child:   SingleChildScrollView(
                    child: Align(
                      // Added Align widget for the left side menu
                      alignment: Alignment.topLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Container(
                          height: 1400,
                          width: 200,
                          color: Colors.white,
                          padding:
                          const EdgeInsets.only(left: 15, top: 10, right: 15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: _buildMenuItems(context,constraints),
                          ),
                        ),
                      ),
                    ),
                  ),),
                  VerticalDividerWidget(
                    height: maxHeight,
                    color: Color(0x29000000),
                  ),
                } else ...{
                  Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding:  EdgeInsets.only(top:59),
                      child: Container(
                        height: maxHeight,
                        width: 200,
                        color: Colors.white,
                        padding:
                        const EdgeInsets.only(left: 15, top: 10, right: 15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: _buildMenuItems(context,constraints),
                        ),
                      ),
                    ),
                  ),
                  VerticalDividerWidget1(
                    height: maxHeight,
                    color: Color(0x29000000),
                  ),

                },

                if(constraints.maxWidth >= 800)...{
                  Positioned(
                    left: 202,
                    right: 0,
                    top: 10,
                    bottom: 0,
                    child:   Padding(
                      padding: const EdgeInsets.only(top: 40),
                      child:RawScrollbar(
                        controller: _scrollController,
                        thumbVisibility: true,
                        // Always show scrollbar
                        thickness: 15,
                        // Thickness of the scrollbar
                        radius: const Radius.circular(2),
                        // Rounded corners for scrollbar
                        thumbColor: Colors.grey[400],
                        // Custom thumb color
                        trackColor: Colors.grey[900],
                        // Custom track color
                        trackRadius: const Radius.circular(2),
                        child: SingleChildScrollView(
                          controller: _scrollController,
                          child:Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left:30,top: 10),
                                child: Row(
                                  children: [
                                    IconButton(onPressed: (){
                                      context.go(
                                          '/User_List');
                                    }, icon: Icon(Icons.arrow_back,size: 16,)),
                                    Text('Edit User',style: TextStyles.header1,),
                                  ],
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.only(left: 0),
                                // Space above/below the border
                                height: 1,
                                // width: 1000,
                                width: constraints.maxWidth,
                                // Border height
                                color: Colors.grey.shade300, // Border color
                              ),
                              Container(
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 55,top: 20,right: 20),
                                  child: Container(
                                    height: 350,
                                    width: 1200,
                                    padding: const EdgeInsets.all(16.0),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Form(
                                      key: formKey,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment
                                            .start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(left: 15,top: 30),
                                            child:  Text('User Edit',
                                              style: TextStyles.header3,),
                                          ),


                                          const SizedBox(height: 26,),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              SizedBox(width: 15,),
                                              Expanded(
                                                child:  Padding(
                                                  padding: const EdgeInsets.only(
                                                      top: 10, bottom: 8,right: 14),
                                                  child: AnimatedContainer(
                                                    duration: const Duration(
                                                        milliseconds: 300),
                                                    // Control animation duration
                                                    curve: Curves.easeInOut,
                                                    // Choose an animation curve
                                                    child: DropdownButtonHideUnderline(
                                                      child: Container(
                                                        decoration: BoxDecoration(
                                                          border: Border
                                                              .all( // Outline border
                                                            color: Colors.grey,
                                                            // Customize outline color
                                                            width: 1.5, // Customize outline thickness
                                                          ),
                                                          borderRadius: BorderRadius
                                                              .circular(6),
                                                          // Rounded corners for the outline
                                                          color: Colors
                                                              .white, // Background color for the dropdown
                                                        ),
                                                        child: DropdownButton2(
                                                          isExpanded: true,
                                                          hint:  Padding(
                                                            padding: EdgeInsets.all(8.0),
                                                            child: Text(
                                                              'Select Role',
                                                              style: TextStyles.body1,
                                                            ),
                                                          ),

                                                          items: items
                                                              .map((item) =>
                                                              DropdownMenuItem<String>(
                                                                value: item,
                                                                child: Padding(
                                                                  padding: const EdgeInsets
                                                                      .all(8.0),
                                                                  child: Text(
                                                                    item,
                                                                    style:GoogleFonts.inter(
                                                                        color: Colors.black,
                                                                        fontSize: 13),
                                                                  ),
                                                                ),
                                                              ))
                                                              .toList(),
                                                          value: selectedValue,
                                                          onChanged: (value) {
                                                            setState(() {
                                                              selectedValue =
                                                              value as String;
                                                            });
                                                          },
                                                          // Updated properties as per the latest version of dropdown_button2
                                                          buttonStyleData: ButtonStyleData(
                                                            height: 42,
                                                            width: 255,
                                                            decoration: BoxDecoration(
                                                              borderRadius: BorderRadius
                                                                  .circular(4),
                                                              color: Colors
                                                                  .white, // No border here
                                                            ),
                                                          ),
                                                          dropdownStyleData: DropdownStyleData(
                                                            maxHeight: 154,
                                                            width: 330,
                                                            padding: const EdgeInsets
                                                                .symmetric(horizontal: 5,
                                                                vertical: 5),
                                                            decoration: BoxDecoration(
                                                              borderRadius: BorderRadius
                                                                  .circular(6),
                                                              border: Border.all(color: Colors.grey.shade400, ),
                                                              color: Colors
                                                                  .white, // Dropdown background color
                                                            ),
                                                            elevation: 5,
                                                            offset: const Offset(0, -10),
                                                          ),
                                                          iconStyleData: const IconStyleData(
                                                            icon: Padding(
                                                              padding: EdgeInsets.only(
                                                                  right: 10),
                                                              child: Icon(Icons
                                                                  .arrow_drop_down),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(width: 15,),
                                              Expanded(
                                                child: Padding(
                                                  padding: const EdgeInsets.only(
                                                      right: 8),
                                                  child: TextFormField(
                                                    controller: userNameController,
                                                    style:GoogleFonts.inter(
                                                        color: Colors.black,
                                                        fontSize: 13),
                                                    decoration:  InputDecoration(
                                                      hintText: 'User Name',
                                                      hintStyle:  TextStyles.body1,
                                                      contentPadding: EdgeInsets
                                                          .symmetric(
                                                          vertical: 5, horizontal: 8),
                                                      border: OutlineInputBorder(
                                                        borderRadius: BorderRadius.all(
                                                            Radius.circular(6)),
                                                        // Set border radius for all sides
                                                        borderSide: BorderSide(
                                                            color: Colors.grey,
                                                            width: 1.5), // Set border color and width
                                                      ),
                                                      focusedBorder: OutlineInputBorder(
                                                        borderRadius: BorderRadius.all(
                                                            Radius.circular(6)),
                                                        // Same border radius when focused
                                                        borderSide: BorderSide(
                                                            color: Colors.blue,
                                                            width: 2.0), // Customize focused border color and width
                                                      ),
                                                      enabledBorder: OutlineInputBorder(
                                                        borderRadius: BorderRadius.all(
                                                            Radius.circular(6)),
                                                        // Same border radius when enabled
                                                        borderSide: BorderSide(
                                                            color: Colors.grey,
                                                            width: 1.5), // Customize enabled border color and width
                                                      ),
                                                      suffixIcon: Icon(
                                                          Icons.account_circle,
                                                          size: 20), // Icon at the end
                                                    ),
                                                  ),
                                                ),

                                              ),

                                              SizedBox(width: 15,),

                                              Expanded(
                                                child:  Padding(
                                                  padding: const EdgeInsets.only(
                                                      right: 8),
                                                  child: TextFormField(
                                                    controller: emailController,
                                                    style:GoogleFonts.inter(
                                                        color: Colors.black,
                                                        fontSize: 13),
                                                    decoration:  InputDecoration(
                                                      hintText: 'Email Address',
                                                      hintStyle:  TextStyles.body1,
                                                      contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                                                      border: OutlineInputBorder(
                                                        borderRadius: BorderRadius.all(Radius.circular(6)),
                                                        borderSide: BorderSide(color: Colors.grey, width: 1.5),
                                                      ),
                                                      focusedBorder: OutlineInputBorder(
                                                        borderRadius: BorderRadius.all(Radius.circular(6)),
                                                        borderSide: BorderSide(color: Colors.blue, width: 2.0),
                                                      ),
                                                      enabledBorder: OutlineInputBorder(
                                                        borderRadius: BorderRadius.all(Radius.circular(6)),
                                                        borderSide: BorderSide(color: Colors.grey, width: 1.5),
                                                      ),
                                                      suffixIcon: Icon(Icons.mail, size: 20),
                                                    ),
                                                    inputFormatters: [
                                                      FilteringTextInputFormatter.allow(RegExp(r'[a-z0-9@._]')), // Allows lowercase, digits, and common email symbols
                                                    ],
                                                    onChanged: (value) {
                                                      emailController.value = TextEditingValue(
                                                        text: value.toLowerCase(),
                                                        selection: emailController.selection,
                                                      );
                                                    },
                                                  ),
                                                ),
                                              ),
                                              SizedBox(width: 15,),
                                            ],
                                          ),
                                          const SizedBox(height: 22),

                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              SizedBox(width: 15,),
                                              Expanded(
                                                child:  Padding(
                                                  padding: const EdgeInsets.only(
                                                      right: 8),
                                                  child: SizedBox(
                                                    child: TextFormField(
                                                      controller: departmentController,
                                                      style:GoogleFonts.inter(
                                                          color: Colors.black,
                                                          fontSize: 13),
                                                      decoration:  InputDecoration(
                                                        hintText: 'Company Name',
                                                        hintStyle:  TextStyles.body1,
                                                        contentPadding: EdgeInsets
                                                            .symmetric(
                                                            vertical: 5, horizontal: 8),
                                                        border: OutlineInputBorder(
                                                          borderRadius: BorderRadius.all(
                                                              Radius.circular(6)),
                                                          // Set border radius for all sides
                                                          borderSide: BorderSide(
                                                              color: Colors.grey,
                                                              width: 1.5), // Set border color and width
                                                        ),
                                                        focusedBorder: OutlineInputBorder(
                                                          borderRadius: BorderRadius.all(
                                                              Radius.circular(6)),
                                                          // Same border radius when focused
                                                          borderSide: BorderSide(
                                                              color: Colors.blue,
                                                              width: 2.0), // Customize focused border color and width
                                                        ),
                                                        enabledBorder: OutlineInputBorder(
                                                          borderRadius: BorderRadius.all(
                                                              Radius.circular(6)),
                                                          // Same border radius when enabled
                                                          borderSide: BorderSide(
                                                              color: Colors.grey,
                                                              width: 1.5), // Customize enabled border color and width
                                                        ),
                                                        suffixIcon: Icon(Icons.business,
                                                            size: 20), // Icon at the end
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(width: 15,),
                                              Expanded(
                                                child: Padding(
                                                  padding: const EdgeInsets.only(
                                                      right: 8.0),
                                                  child: TextFormField(
                                                    controller: mobileController,
                                                    style:GoogleFonts.inter(
                                                        color: Colors.black,
                                                        fontSize: 13),
                                                    decoration:  InputDecoration(
                                                      hintText: 'Mobile No',
                                                      hintStyle:  TextStyles.body1,
                                                      contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                                                      border: OutlineInputBorder(
                                                        borderRadius: BorderRadius.all(Radius.circular(6)),
                                                        borderSide: BorderSide(color: Colors.grey, width: 1.5),
                                                      ),
                                                      focusedBorder: OutlineInputBorder(
                                                        borderRadius: BorderRadius.all(Radius.circular(6)),
                                                        borderSide: BorderSide(color: Colors.blue, width: 2.0),
                                                      ),
                                                      enabledBorder: OutlineInputBorder(
                                                        borderRadius: BorderRadius.all(Radius.circular(6)),
                                                        borderSide: BorderSide(color: Colors.grey, width: 1.5),
                                                      ),
                                                      suffixIcon: Icon(Icons.phone_android_outlined, size: 20),
                                                    ),
                                                    keyboardType: TextInputType.number, // Shows numeric keyboard
                                                    inputFormatters: [
                                                      FilteringTextInputFormatter.digitsOnly, // Allows only digits
                                                      LengthLimitingTextInputFormatter(10), // Limits input to 10 characters
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              SizedBox(width: 15,),
                                              Expanded(
                                                child: Padding(
                                                  padding: const EdgeInsets.only(
                                                      right: 8.0),
                                                  child: TextFormField(
                                                    controller: location,
                                                    style:GoogleFonts.inter(
                                                        color: Colors.black,
                                                        fontSize: 13),
                                                    onChanged: (value) {
                                                      // Allow only alphabetic characters and spaces
                                                      String filteredValue = value.replaceAll(RegExp(r'[^a-zA-Z\s]'), '');

                                                      if (filteredValue.isNotEmpty) {
                                                        // Capitalize the first letter and convert the rest to lowercase
                                                        String formattedText = filteredValue[0].toUpperCase() +
                                                            filteredValue.substring(1).toLowerCase();

                                                        // Update the controller with the filtered and formatted text
                                                        location.value = location.value.copyWith(
                                                          text: formattedText,
                                                          selection: TextSelection.collapsed(offset: formattedText.length),
                                                        );
                                                      } else {
                                                        // Clear the controller if the filtered value is empty
                                                        location.clear();
                                                      }
                                                    },
                                                    decoration:  InputDecoration(
                                                      hintText: 'Location',
                                                      hintStyle:  TextStyles.body1,
                                                      contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                                                      border: OutlineInputBorder(
                                                        borderRadius: BorderRadius.all(Radius.circular(6)),
                                                        borderSide: BorderSide(color: Colors.grey, width: 1.5),
                                                      ),
                                                      focusedBorder: OutlineInputBorder(
                                                        borderRadius: BorderRadius.all(Radius.circular(6)),
                                                        borderSide: BorderSide(color: Colors.blue, width: 2.0),
                                                      ),
                                                      enabledBorder: OutlineInputBorder(
                                                        borderRadius: BorderRadius.all(Radius.circular(6)),
                                                        borderSide: BorderSide(color: Colors.grey, width: 1.5),
                                                      ),
                                                      suffixIcon: Icon(Icons.location_on, size: 20),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(width: 15,),
                                            ],

                                          ),
                                          const SizedBox(height: 20),
                                          Padding(
                                            padding: const EdgeInsets.only(right: 20),
                                            child: Align(
                                              alignment: Alignment.bottomRight,
                                              child: SizedBox(
                                                width: 120,
                                                child: OutlinedButton(
                                                  onPressed: () async {

                                                    if (selectedValue == null ||
                                                        selectedValue ==
                                                            'Select Role') {
                                                      ScaffoldMessenger.of(context)
                                                          .showSnackBar(
                                                        const SnackBar(
                                                          content: Text(
                                                              'Please select a Role'),
                                                        ),
                                                      );
                                                    }

                                                    else if (userNameController.text
                                                        .isEmpty ||
                                                        userNameController.text
                                                            .length <= 2) {
                                                      ScaffoldMessenger.of(context)
                                                          .showSnackBar(
                                                        const SnackBar(
                                                          content: Text(
                                                              'Please fill user name'),
                                                        ),
                                                      );
                                                    }
                                                    if (emailController
                                                        .text.isEmpty ||
                                                        !RegExp(r'^[\w-]+(\.[\w-]+)*@[a-zA-Z0-9-]+\.(com|in|net)$')
                                                            .hasMatch(
                                                            emailController
                                                                .text)) {
                                                      ScaffoldMessenger.of(
                                                          context)
                                                          .showSnackBar(
                                                        SnackBar(
                                                            content: Text(
                                                                'Enter Valid E-mail Address')),
                                                      );
                                                    }
                                                    else
                                                    if (departmentController.text.isEmpty) {
                                                      ScaffoldMessenger.of(context)
                                                          .showSnackBar(
                                                        const SnackBar(
                                                          content: Text(
                                                              'Please fill Company Name.'),
                                                        ),
                                                      );
                                                    }

                                                    else
                                                    if (mobileController.text.isEmpty ||
                                                        mobileController.text.length !=
                                                            10) {
                                                      ScaffoldMessenger.of(context)
                                                          .showSnackBar(
                                                        const SnackBar(
                                                          content: Text(
                                                              'Please fill a valid mobile number.'),
                                                        ),
                                                      );
                                                    }
                                                    else if (location.text.isEmpty) {
                                                      ScaffoldMessenger.of(context)
                                                          .showSnackBar(
                                                        const SnackBar(
                                                          content: Text(
                                                              'Please fill location '),
                                                        ),
                                                      );
                                                    }
                                                    else {
                                                      cusUpdate(context);
                                                    }

                                                    // Save form
                                                  },
                                                  style: OutlinedButton.styleFrom(
                                                    backgroundColor: Colors.blue[900],
                                                    padding: null,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(5),
                                                    ),
                                                    side: const BorderSide(
                                                      color: Colors.blue,
                                                      width: 1,
                                                    ),
                                                  ),
                                                  child:  Text(
                                                    'Update',
                                                    style: TextStyles.button1,
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
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
                }
                else...{
                  Positioned(
                    left: 202,
                    right: 0,
                    top: 10,
                    bottom: 0,
                    child: Padding(
                        padding: EdgeInsets.only(top:40,),
                        child:RawScrollbar(
                          controller: _scrollController,
                          thumbVisibility: true,
                          // Always show scrollbar
                          thickness: 15,
                          // Thickness of the scrollbar
                          radius: const Radius.circular(2),
                          // Rounded corners for scrollbar
                          thumbColor: Colors.grey[400],
                          // Custom thumb color
                          trackColor: Colors.grey[900],
                          // Custom track color
                          trackRadius: const Radius.circular(2),
                          child: SingleChildScrollView(
                            controller: _scrollController,
                            child:Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 10),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      IconButton(onPressed: (){
                                        context.go(
                                            '/User_List');
                                      }, icon: Icon(Icons.arrow_back,size: 16,)),
                                      Text('User Edit',style: TextStyles.header1,),
                                    ],
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.only(left: 5),
                                  // Space above/below the border
                                  height: 1,

                                  width: constraints.maxWidth,

                                  color: Colors.grey.shade300, // Border color
                                ),
                                SizedBox(
                                  height: 600,
                                  child: AdaptiveScrollbar(
                                    position: ScrollbarPosition.bottom,controller: horizontalScroll,
                                    child: SingleChildScrollView(
                                      controller: horizontalScroll,
                                      scrollDirection: Axis.horizontal,
                                      child: Container(
                                        child: Padding(
                                          padding: const EdgeInsets.only(left: 55,top: 20,right: 20),
                                          child: Container(
                                            height: 350,
                                            width: 1200,
                                            padding: const EdgeInsets.all(16.0),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Form(
                                              key: formKey,
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment
                                                    .start,
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets.only(left: 15,top: 30),
                                                    child:  Text('User Edit',
                                                      style: TextStyles.header3,),
                                                  ),
                                                  const SizedBox(height: 26,),
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      SizedBox(width: 15,),
                                                      Expanded(
                                                        child:  Padding(
                                                          padding: const EdgeInsets.only(
                                                              top: 10, bottom: 8,right: 14),
                                                          child: AnimatedContainer(
                                                            duration: const Duration(
                                                                milliseconds: 300),
                                                            // Control animation duration
                                                            curve: Curves.easeInOut,
                                                            // Choose an animation curve
                                                            child: DropdownButtonHideUnderline(
                                                              child: Container(
                                                                decoration: BoxDecoration(
                                                                  border: Border
                                                                      .all( // Outline border
                                                                    color: Colors.grey,
                                                                    // Customize outline color
                                                                    width: 1.5, // Customize outline thickness
                                                                  ),
                                                                  borderRadius: BorderRadius
                                                                      .circular(6),
                                                                  // Rounded corners for the outline
                                                                  color: Colors
                                                                      .white, // Background color for the dropdown
                                                                ),
                                                                child: DropdownButton2(
                                                                  isExpanded: true,
                                                                  hint:  Padding(
                                                                    padding: EdgeInsets.all(8.0),
                                                                    child: Text(
                                                                      'Select Role',
                                                                      style: TextStyles.body1,
                                                                    ),
                                                                  ),

                                                                  items: items
                                                                      .map((item) =>
                                                                      DropdownMenuItem<String>(
                                                                        value: item,
                                                                        child: Padding(
                                                                          padding: const EdgeInsets
                                                                              .all(8.0),
                                                                          child: Text(
                                                                            item,
                                                                            style:GoogleFonts.inter(
                                                                                color: Colors.black,
                                                                                fontSize: 13),
                                                                          ),
                                                                        ),
                                                                      ))
                                                                      .toList(),
                                                                  value: selectedValue,
                                                                  onChanged: (value) {
                                                                    setState(() {
                                                                      selectedValue =
                                                                      value as String;
                                                                    });
                                                                  },
                                                                  // Updated properties as per the latest version of dropdown_button2
                                                                  buttonStyleData: ButtonStyleData(
                                                                    height: 42,
                                                                    width: 255,
                                                                    decoration: BoxDecoration(
                                                                      borderRadius: BorderRadius
                                                                          .circular(4),
                                                                      color: Colors
                                                                          .white, // No border here
                                                                    ),
                                                                  ),
                                                                  dropdownStyleData: DropdownStyleData(
                                                                    maxHeight: 154,
                                                                    width: 330,
                                                                    padding: const EdgeInsets
                                                                        .symmetric(horizontal: 5,
                                                                        vertical: 5),
                                                                    decoration: BoxDecoration(
                                                                      borderRadius: BorderRadius
                                                                          .circular(6),
                                                                      border: Border.all(color: Colors.grey.shade400, ),
                                                                      color: Colors
                                                                          .white, // Dropdown background color
                                                                    ),
                                                                    elevation: 5,
                                                                    offset: const Offset(0, -10),
                                                                  ),
                                                                  iconStyleData: const IconStyleData(
                                                                    icon: Padding(
                                                                      padding: EdgeInsets.only(
                                                                          right: 10),
                                                                      child: Icon(Icons
                                                                          .arrow_drop_down),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(width: 15,),
                                                      Expanded(
                                                        child: Padding(
                                                          padding: const EdgeInsets.only(
                                                              right: 8),
                                                          child: TextFormField(
                                                            controller: userNameController,
                                                            style:GoogleFonts.inter(
                                                                color: Colors.black,
                                                                fontSize: 13),
                                                            decoration:  InputDecoration(
                                                              hintText: 'User Name',
                                                              hintStyle:  TextStyles.body1,
                                                              contentPadding: EdgeInsets
                                                                  .symmetric(
                                                                  vertical: 5, horizontal: 8),
                                                              border: OutlineInputBorder(
                                                                borderRadius: BorderRadius.all(
                                                                    Radius.circular(6)),
                                                                // Set border radius for all sides
                                                                borderSide: BorderSide(
                                                                    color: Colors.grey,
                                                                    width: 1.5), // Set border color and width
                                                              ),
                                                              focusedBorder: OutlineInputBorder(
                                                                borderRadius: BorderRadius.all(
                                                                    Radius.circular(6)),
                                                                // Same border radius when focused
                                                                borderSide: BorderSide(
                                                                    color: Colors.blue,
                                                                    width: 2.0), // Customize focused border color and width
                                                              ),
                                                              enabledBorder: OutlineInputBorder(
                                                                borderRadius: BorderRadius.all(
                                                                    Radius.circular(6)),
                                                                // Same border radius when enabled
                                                                borderSide: BorderSide(
                                                                    color: Colors.grey,
                                                                    width: 1.5), // Customize enabled border color and width
                                                              ),
                                                              suffixIcon: Icon(
                                                                  Icons.account_circle,
                                                                  size: 20), // Icon at the end
                                                            ),
                                                          ),
                                                        ),

                                                      ),

                                                      SizedBox(width: 15,),

                                                      Expanded(
                                                        child:  Padding(
                                                          padding: const EdgeInsets.only(
                                                              right: 8),
                                                          child: TextFormField(
                                                            controller: emailController,
                                                            style:GoogleFonts.inter(
                                                                color: Colors.black,
                                                                fontSize: 13),
                                                            decoration:  InputDecoration(
                                                              hintText: 'Email Address',
                                                              hintStyle:  TextStyles.body1,
                                                              contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                                                              border: OutlineInputBorder(
                                                                borderRadius: BorderRadius.all(Radius.circular(6)),
                                                                borderSide: BorderSide(color: Colors.grey, width: 1.5),
                                                              ),
                                                              focusedBorder: OutlineInputBorder(
                                                                borderRadius: BorderRadius.all(Radius.circular(6)),
                                                                borderSide: BorderSide(color: Colors.blue, width: 2.0),
                                                              ),
                                                              enabledBorder: OutlineInputBorder(
                                                                borderRadius: BorderRadius.all(Radius.circular(6)),
                                                                borderSide: BorderSide(color: Colors.grey, width: 1.5),
                                                              ),
                                                              suffixIcon: Icon(Icons.mail, size: 20),
                                                            ),
                                                            inputFormatters: [
                                                              FilteringTextInputFormatter.allow(RegExp(r'[a-z0-9@._]')), // Allows lowercase, digits, and common email symbols
                                                            ],
                                                            onChanged: (value) {
                                                              emailController.value = TextEditingValue(
                                                                text: value.toLowerCase(),
                                                                selection: emailController.selection,
                                                              );
                                                            },
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(width: 15,),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 22),

                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      SizedBox(width: 15,),
                                                      Expanded(
                                                        child:  Padding(
                                                          padding: const EdgeInsets.only(
                                                              right: 8),
                                                          child: SizedBox(
                                                            child: TextFormField(
                                                              controller: departmentController,
                                                              style:GoogleFonts.inter(
                                                                  color: Colors.black,
                                                                  fontSize: 13),
                                                              decoration:  InputDecoration(
                                                                hintText: 'Company Name',
                                                                hintStyle:  TextStyles.body1,
                                                                contentPadding: EdgeInsets
                                                                    .symmetric(
                                                                    vertical: 5, horizontal: 8),
                                                                border: OutlineInputBorder(
                                                                  borderRadius: BorderRadius.all(
                                                                      Radius.circular(6)),
                                                                  // Set border radius for all sides
                                                                  borderSide: BorderSide(
                                                                      color: Colors.grey,
                                                                      width: 1.5), // Set border color and width
                                                                ),
                                                                focusedBorder: OutlineInputBorder(
                                                                  borderRadius: BorderRadius.all(
                                                                      Radius.circular(6)),
                                                                  // Same border radius when focused
                                                                  borderSide: BorderSide(
                                                                      color: Colors.blue,
                                                                      width: 2.0), // Customize focused border color and width
                                                                ),
                                                                enabledBorder: OutlineInputBorder(
                                                                  borderRadius: BorderRadius.all(
                                                                      Radius.circular(6)),
                                                                  // Same border radius when enabled
                                                                  borderSide: BorderSide(
                                                                      color: Colors.grey,
                                                                      width: 1.5), // Customize enabled border color and width
                                                                ),
                                                                suffixIcon: Icon(Icons.business,
                                                                    size: 20), // Icon at the end
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(width: 15,),
                                                      Expanded(
                                                        child: Padding(
                                                          padding: const EdgeInsets.only(
                                                              right: 8.0),
                                                          child: TextFormField(
                                                            controller: mobileController,
                                                            style:GoogleFonts.inter(
                                                                color: Colors.black,
                                                                fontSize: 13),
                                                            decoration:  InputDecoration(
                                                              hintText: 'Mobile No',
                                                              hintStyle:  TextStyles.body1,
                                                              contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                                                              border: OutlineInputBorder(
                                                                borderRadius: BorderRadius.all(Radius.circular(6)),
                                                                borderSide: BorderSide(color: Colors.grey, width: 1.5),
                                                              ),
                                                              focusedBorder: OutlineInputBorder(
                                                                borderRadius: BorderRadius.all(Radius.circular(6)),
                                                                borderSide: BorderSide(color: Colors.blue, width: 2.0),
                                                              ),
                                                              enabledBorder: OutlineInputBorder(
                                                                borderRadius: BorderRadius.all(Radius.circular(6)),
                                                                borderSide: BorderSide(color: Colors.grey, width: 1.5),
                                                              ),
                                                              suffixIcon: Icon(Icons.phone_android_outlined, size: 20),
                                                            ),
                                                            keyboardType: TextInputType.number, // Shows numeric keyboard
                                                            inputFormatters: [
                                                              FilteringTextInputFormatter.digitsOnly, // Allows only digits
                                                              LengthLimitingTextInputFormatter(10), // Limits input to 10 characters
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(width: 15,),
                                                      Expanded(
                                                        child: Padding(
                                                          padding: const EdgeInsets.only(
                                                              right: 8.0),
                                                          child: TextFormField(
                                                            controller: location,
                                                            style:GoogleFonts.inter(
                                                                color: Colors.black,
                                                                fontSize: 13),
                                                            onChanged: (value) {
                                                              // Allow only alphabetic characters and spaces
                                                              String filteredValue = value.replaceAll(RegExp(r'[^a-zA-Z\s]'), '');

                                                              if (filteredValue.isNotEmpty) {
                                                                // Capitalize the first letter and convert the rest to lowercase
                                                                String formattedText = filteredValue[0].toUpperCase() +
                                                                    filteredValue.substring(1).toLowerCase();

                                                                // Update the controller with the filtered and formatted text
                                                                location.value = location.value.copyWith(
                                                                  text: formattedText,
                                                                  selection: TextSelection.collapsed(offset: formattedText.length),
                                                                );
                                                              } else {
                                                                // Clear the controller if the filtered value is empty
                                                                location.clear();
                                                              }
                                                            },
                                                            decoration:  InputDecoration(
                                                              hintText: 'Location',
                                                              hintStyle:  TextStyles.body1,
                                                              contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                                                              border: OutlineInputBorder(
                                                                borderRadius: BorderRadius.all(Radius.circular(6)),
                                                                borderSide: BorderSide(color: Colors.grey, width: 1.5),
                                                              ),
                                                              focusedBorder: OutlineInputBorder(
                                                                borderRadius: BorderRadius.all(Radius.circular(6)),
                                                                borderSide: BorderSide(color: Colors.blue, width: 2.0),
                                                              ),
                                                              enabledBorder: OutlineInputBorder(
                                                                borderRadius: BorderRadius.all(Radius.circular(6)),
                                                                borderSide: BorderSide(color: Colors.grey, width: 1.5),
                                                              ),
                                                              suffixIcon: Icon(Icons.location_on, size: 20),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(width: 15,),
                                                    ],

                                                  ),
                                                  const SizedBox(height: 20),
                                                  Padding(
                                                    padding: const EdgeInsets.only(right: 20),
                                                    child: Align(
                                                      alignment: Alignment.bottomRight,
                                                      child: SizedBox(
                                                        width: 120,
                                                        child: OutlinedButton(
                                                          onPressed: () async {

                                                            if (selectedValue == null ||
                                                                selectedValue ==
                                                                    'Select Role') {
                                                              ScaffoldMessenger.of(context)
                                                                  .showSnackBar(
                                                                const SnackBar(
                                                                  content: Text(
                                                                      'Please select a Role'),
                                                                ),
                                                              );
                                                            }

                                                            else if (userNameController.text
                                                                .isEmpty ||
                                                                userNameController.text
                                                                    .length <= 2) {
                                                              ScaffoldMessenger.of(context)
                                                                  .showSnackBar(
                                                                const SnackBar(
                                                                  content: Text(
                                                                      'Please fill user name'),
                                                                ),
                                                              );
                                                            }
                                                            if (emailController
                                                                .text.isEmpty ||
                                                                !RegExp(r'^[\w-]+(\.[\w-]+)*@[a-zA-Z0-9-]+\.(com|in|net)$')
                                                                    .hasMatch(
                                                                    emailController
                                                                        .text)) {
                                                              ScaffoldMessenger.of(
                                                                  context)
                                                                  .showSnackBar(
                                                                SnackBar(
                                                                    content: Text(
                                                                        'Enter Valid E-mail Address')),
                                                              );
                                                            }
                                                            else
                                                            if (departmentController.text.isEmpty) {
                                                              ScaffoldMessenger.of(context)
                                                                  .showSnackBar(
                                                                const SnackBar(
                                                                  content: Text(
                                                                      'Please fill Company Name.'),
                                                                ),
                                                              );
                                                            }

                                                            else
                                                            if (mobileController.text.isEmpty ||
                                                                mobileController.text.length !=
                                                                    10) {
                                                              ScaffoldMessenger.of(context)
                                                                  .showSnackBar(
                                                                const SnackBar(
                                                                  content: Text(
                                                                      'Please fill a valid mobile number.'),
                                                                ),
                                                              );
                                                            }
                                                            else if (location.text.isEmpty) {
                                                              ScaffoldMessenger.of(context)
                                                                  .showSnackBar(
                                                                const SnackBar(
                                                                  content: Text(
                                                                      'Please fill location '),
                                                                ),
                                                              );
                                                            }
                                                            else {
                                                              cusUpdate(context);
                                                            }

                                                            // Save form
                                                          },
                                                          style: OutlinedButton.styleFrom(
                                                            backgroundColor: Colors.blue[900],
                                                            padding: null,
                                                            shape: RoundedRectangleBorder(
                                                              borderRadius: BorderRadius.circular(5),
                                                            ),
                                                            side: const BorderSide(
                                                              color: Colors.blue,
                                                              width: 1,
                                                            ),
                                                          ),
                                                          child:  Text(
                                                            'Update',
                                                            style: TextStyles.button1,
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
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )),
                  )

                },

              ],
            );
          },
        ),
      ),
    );
  }

  String? validatePassword(String password) {
    // Password must be at least 8 characters long, include upper, lower, digit, and special character
    if (password.isEmpty) {
      return 'Password cannot be empty';
    } else if (password.length < 8) {
      return 'Password must be at least 8 characters long';
    } else if (!RegExp(r'[A-Z]').hasMatch(password)) {
      return 'Password must contain at least one uppercase letter';
    } else if (!RegExp(r'[a-z]').hasMatch(password)) {
      return 'Password must contain at least one lowercase letter';
    } else if (!RegExp(r'[0-9]').hasMatch(password)) {
      return 'Password must contain at least one digit';
    } else if (!RegExp(r'[!@#\$&*~]').hasMatch(password)) {
      return 'Password must contain at least one special character';
    }
    return null; // Password is valid
  }
}

// class Sidebar extends StatefulWidget {
//   const Sidebar({super.key});
//
//   @override
//   _SidebarState createState() => _SidebarState();
// }
//
// class _SidebarState extends State<Sidebar> {
//   // bool isMinimized = false;
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: 200,
//       color:const Color(0xFFF7F6FA),
//       child:  Padding(
//         padding: const EdgeInsets.only(left: 15, top: 30,right: 15),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Container(
//               width: 150,
//               height: 45,
//               decoration: BoxDecoration(
//                 color: Colors.blue[800],
//                 // border: Border(  left: BorderSide(    color: Colors.blue,    width: 5.0,  ),),
//                 // color: Color.fromRGBO(224, 59, 48, 1.0),
//                 borderRadius: const BorderRadius.only(
//                   topLeft: Radius.circular(8), // Radius for top-left corner
//                   topRight: Radius.circular(8), // No radius for top-right corner
//                   bottomLeft: Radius.circular(8), // Radius for bottom-left corner
//                   bottomRight: Radius.circular(8), // No radius for bottom-right corner
//                 ),
//               ),
//               child: TextButton.icon(
//                 onPressed: () {
//                   context.go('/User_List');
//                 },
//                 icon: const Icon(
//                     Icons.home_outlined, color: Colors.white),
//                 label:  Text(
//                   'Home',
//                   style: TextStyles.button1
//                 ),
//               ),
//             ),
//           ],
//         ),
//
//       ),
//     );
//   }
// }

 