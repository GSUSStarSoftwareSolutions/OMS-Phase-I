import 'dart:convert';
import 'dart:html';
import 'package:adaptive_scrollbar/adaptive_scrollbar.dart';
import 'package:btb/widgets/Api%20name.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import '../dashboard/dashboard.dart';
import '../widgets/confirmdialog.dart';
import '../widgets/text_style.dart';
import 'admin edit.dart';

void main() {
  runApp(const Createuser());
}

class Createuser extends StatefulWidget {
  const Createuser({super.key});

  @override
  State<Createuser> createState() => CreateuserState();
}

class CreateuserState extends State<Createuser> {
  String companyName = window.sessionStorage["company"] ?? " ";
  String token = window.sessionStorage["token"] ?? " ";
  final ScrollController _scrollController = ScrollController();
  late TextEditingController dateController;
  TextEditingController location = TextEditingController();
  TextEditingController userNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController departmentController = TextEditingController();
  TextEditingController designationController = TextEditingController();
  TextEditingController mobileController = TextEditingController();
  final ScrollController horizontalScroll = ScrollController();
  DateTime? selectedDate;
  final formKey = GlobalKey<FormState>();
  List<String> items = [
    'Admin',
    'Employee',
    'Customer',
  ];
  String? selectedValue;

  Future<void> cusSave(BuildContext context) async {
    String url = "$apicall/public/user_master/add-usermaster";
    Map<String, dynamic> data = {
      "active": true,
      "companyName": departmentController.text,
      "email": emailController.text,
      "location": location.text,
      "mobileNumber": mobileController.text,
      "role": selectedValue,
      "userName": userNameController.text,
      "returnCredit": 0.00,
    };
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token'
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(data),
      );
      if (response.statusCode == 200) {
        final addResponseBody = jsonDecode(response.body);
        if (addResponseBody['status'] == 'success') {
          showDialog(
            barrierDismissible: false,
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                icon: const Icon(Icons.check_circle_rounded,
                    color: Colors.green, size: 25),
                title: const Text(
                  'Account created Successfully',
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
                    child:
                        const Text('OK', style: TextStyle(color: Colors.white)),
                  ),
                ],
              );
            },
          );
        } else if (addResponseBody['status'] == 'failed' &&
            addResponseBody['error'] == 'email already exists') {
          // Display the SnackBar for existing email error
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('email already exists'),
              duration: Duration(seconds: 2), // Optional duration
            ),
          );
        } else if (addResponseBody['status'] == 'failed' &&
            addResponseBody['error'] == 'mobile number already exists') {
          // Display the SnackBar for existing email error
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('This mobile number already exists.'),
              duration: Duration(seconds: 2), // Optional duration
            ),
          );
        } else {
          print('Unexpected response: $addResponseBody');
        }
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Network error. Please try again.')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    departmentController.text = companyName;
    dateController = TextEditingController();
    dateController.text = 'Joining Date';
  }

  @override
  void dispose() {
    location.dispose();
    super.dispose();
  }

  List<Widget> _buildMenuItems(BuildContext context, constraints) {
    return [
      Column(
        children: [
          const SizedBox(
            height: 10,
          ),
          Container(
            padding: const EdgeInsets.all(8.0),
            child: Container(
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
                  style: TextStyles.button1,
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
            double maxHeight = constraints.maxHeight;
            double maxWidth = constraints.maxWidth;
            double containerWidth = maxWidth > 700 ? 600 : maxWidth * 0.9;
            return Stack(
              children: [
                Container(
                  width: maxWidth,
                  height: 60.0,
                  decoration: const BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        bottom: BorderSide(
                          color: Color(0x29000000), // Bottom border color
                          width: 3.0, // Thickness of the bottom border
                        ),
                      )),
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
                            ),
                          ),
                          const Spacer(),
                          const Row(
                            children: [
                              Padding(
                                padding: EdgeInsets.only(right: 10, top: 10),
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
                    top: 60,
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: SingleChildScrollView(
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 0),
                          child: Container(
                            height: 1400,
                            width: 200,
                            color: Colors.white,
                            padding: const EdgeInsets.only(
                                left: 15, top: 10, right: 15),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: _buildMenuItems(context, constraints),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  VerticalDividerWidget(
                    height: maxHeight,
                    color: const Color(0x29000000),
                  ),
                } else ...{
                  Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 60),
                      child: Container(
                        height: maxHeight,
                        width: 200,
                        padding:
                            const EdgeInsets.only(left: 15, top: 10, right: 15),
                        color: Colors.white,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: _buildMenuItems(context, constraints),
                        ),
                      ),
                    ),
                  ),
                  VerticalDividerWidget1(
                    height: maxHeight,
                    color: const Color(0x29000000),
                  ),
                },
                if (constraints.maxWidth >= 800) ...{
                  Positioned(
                    left: 202,
                    right: 0,
                    top: 10,
                    bottom: 0,
                    child: Padding(
                      padding: const EdgeInsets.only(
                        top: 40,
                      ),
                      child: RawScrollbar(
                        controller: _scrollController,
                        thumbVisibility: true,
                        thickness: 15,
                        radius: const Radius.circular(2),
                        thumbColor: Colors.grey[400],
                        trackColor: Colors.grey[900],
                        trackRadius: const Radius.circular(2),
                        child: SingleChildScrollView(
                          controller: _scrollController,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 30, top: 10),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    IconButton(
                                        onPressed: () {
                                          context.go('/User_List');
                                        },
                                        icon: const Icon(
                                          Icons.arrow_back,
                                          size: 16,
                                        )),
                                    Text(
                                      'Create User',
                                      style: TextStyles.header1,
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(left: 0),
                                    height: 1,
                                    width: maxWidth,
                                    color: Colors.grey.shade300, // Border color
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 55, top: 20, right: 20),
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left: 15, top: 30),
                                          child: Text('User Details',
                                              style: TextStyles.header3),
                                        ),
                                        const SizedBox(height: 26),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            const SizedBox(
                                              width: 15,
                                            ),
                                            Expanded(
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 10,
                                                    bottom: 8,
                                                    right: 10),
                                                child: AnimatedContainer(
                                                  duration: const Duration(
                                                      milliseconds: 300),
                                                  curve: Curves.easeInOut,
                                                  child:
                                                      DropdownButtonHideUnderline(
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        border: Border.all(
                                                          color: Colors.grey,
                                                          width: 1.5,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(6),
                                                        color: Colors.white,
                                                      ),
                                                      child: DropdownButton2(
                                                        isExpanded: true,
                                                        hint: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: Text(
                                                            'Select Role',
                                                            style: TextStyles
                                                                .body1,
                                                          ),
                                                        ),
                                                        items: items
                                                            .map((item) =>
                                                                DropdownMenuItem<
                                                                    String>(
                                                                  value: item,
                                                                  child:
                                                                      Padding(
                                                                    padding:
                                                                        const EdgeInsets
                                                                            .all(
                                                                            8.0),
                                                                    child: Text(
                                                                        item,
                                                                        style: GoogleFonts.inter(
                                                                            color:
                                                                                Colors.black,
                                                                            fontSize: 13)),
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
                                                        buttonStyleData:
                                                            ButtonStyleData(
                                                          height: 42,
                                                          width: 255,
                                                          decoration:
                                                              BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        4),
                                                            color: Colors
                                                                .white, // No border here
                                                          ),
                                                        ),
                                                        dropdownStyleData:
                                                            DropdownStyleData(
                                                          maxHeight: 155,
                                                          width: 330,
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal: 5,
                                                                  vertical: 5),
                                                          decoration:
                                                              BoxDecoration(
                                                            border: Border.all(
                                                                color: Colors
                                                                    .grey),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        6),
                                                            color: Colors
                                                                .white, // Dropdown background color
                                                          ),
                                                          elevation: 5,
                                                          offset: const Offset(
                                                              0, -10),
                                                        ),
                                                        iconStyleData:
                                                            const IconStyleData(
                                                          icon: Padding(
                                                            padding:
                                                                EdgeInsets.only(
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
                                            const SizedBox(
                                              width: 15,
                                            ),
                                            Expanded(
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    right: 8.0),
                                                child: TextFormField(
                                                  controller:
                                                      userNameController,
                                                  style: GoogleFonts.inter(
                                                      color: Colors.black,
                                                      fontSize: 13),
                                                  decoration: InputDecoration(
                                                    hintText: 'User Name',
                                                    hintStyle: TextStyles.body1,
                                                    contentPadding:
                                                        const EdgeInsets
                                                            .symmetric(
                                                            vertical: 5,
                                                            horizontal: 8),
                                                    border: OutlineInputBorder(
                                                      borderRadius:
                                                          const BorderRadius
                                                              .all(
                                                              Radius.circular(
                                                                  6)),
                                                      borderSide: BorderSide(
                                                          color: Colors
                                                              .grey.shade400,
                                                          width: 1.5),
                                                    ),
                                                    focusedBorder:
                                                        const OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  6)),
                                                      borderSide: BorderSide(
                                                          color: Colors.blue,
                                                          width: 2.0),
                                                    ),
                                                    enabledBorder:
                                                        OutlineInputBorder(
                                                      borderRadius:
                                                          const BorderRadius
                                                              .all(
                                                              Radius.circular(
                                                                  6)),
                                                      borderSide: BorderSide(
                                                          color: Colors
                                                              .grey.shade400,
                                                          width: 1.5),
                                                    ),
                                                    suffixIcon: const Icon(
                                                        Icons.account_circle,
                                                        size: 20),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 15,
                                            ),
                                            Expanded(
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    right: 8.0),
                                                child: TextFormField(
                                                  controller: emailController,
                                                  style: GoogleFonts.inter(
                                                      color: Colors.black,
                                                      fontSize: 13),
                                                  decoration: InputDecoration(
                                                    hintText: 'Email Address',
                                                    hintStyle: TextStyles.body1,
                                                    contentPadding:
                                                        const EdgeInsets
                                                            .symmetric(
                                                            vertical: 5,
                                                            horizontal: 8),
                                                    border: OutlineInputBorder(
                                                      borderRadius:
                                                          const BorderRadius
                                                              .all(
                                                              Radius.circular(
                                                                  6)),
                                                      borderSide: BorderSide(
                                                          color: Colors
                                                              .grey.shade400,
                                                          width: 1.5),
                                                    ),
                                                    focusedBorder:
                                                        const OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  6)),
                                                      borderSide: BorderSide(
                                                          color: Colors.blue,
                                                          width: 2.0),
                                                    ),
                                                    enabledBorder:
                                                        OutlineInputBorder(
                                                      borderRadius:
                                                          const BorderRadius
                                                              .all(
                                                              Radius.circular(
                                                                  6)),
                                                      borderSide: BorderSide(
                                                          color: Colors
                                                              .grey.shade400,
                                                          width: 1.5),
                                                    ),
                                                    suffixIcon: const Icon(
                                                        Icons.mail,
                                                        size: 20),
                                                  ),
                                                  inputFormatters: [
                                                    FilteringTextInputFormatter
                                                        .allow(RegExp(
                                                            r'[a-z0-9@._]')),
                                                  ],
                                                  onChanged: (value) {
                                                    emailController.value =
                                                        TextEditingValue(
                                                      text: value.toLowerCase(),
                                                      selection: emailController
                                                          .selection,
                                                    );
                                                  },
                                                ),
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 15,
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 22),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            const SizedBox(
                                              width: 15,
                                            ),
                                            Expanded(
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    right: 8.0),
                                                child: TextFormField(
                                                  enabled: false,
                                                  controller:
                                                      departmentController,
                                                  style: GoogleFonts.inter(
                                                      color: Colors.grey,
                                                      fontSize: 13),
                                                  decoration: InputDecoration(
                                                    hintText: 'Company Name',
                                                    hintStyle: TextStyles.body1,
                                                    contentPadding:
                                                        const EdgeInsets
                                                            .symmetric(
                                                            vertical: 5,
                                                            horizontal: 8),
                                                    border: OutlineInputBorder(
                                                      borderRadius:
                                                          const BorderRadius
                                                              .all(
                                                              Radius.circular(
                                                                  6)),
                                                      borderSide: BorderSide(
                                                          color: Colors
                                                              .grey.shade400,
                                                          width: 1.5),
                                                    ),
                                                    focusedBorder:
                                                        const OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  6)),
                                                      borderSide: BorderSide(
                                                          color: Colors.blue,
                                                          width: 2.0),
                                                    ),
                                                    enabledBorder:
                                                        OutlineInputBorder(
                                                      borderRadius:
                                                          const BorderRadius
                                                              .all(
                                                              Radius.circular(
                                                                  6)),
                                                      borderSide: BorderSide(
                                                          color: Colors
                                                              .grey.shade400,
                                                          width: 1.5),
                                                    ),
                                                    suffixIcon: const Icon(
                                                        Icons.business,
                                                        size: 20),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 15,
                                            ),
                                            Expanded(
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    right: 8.0),
                                                child: TextFormField(
                                                  controller: mobileController,
                                                  style: GoogleFonts.inter(
                                                      color: Colors.black,
                                                      fontSize: 13),
                                                  decoration: InputDecoration(
                                                    hintText: 'Mobile No',
                                                    hintStyle: TextStyles.body1,
                                                    contentPadding:
                                                        const EdgeInsets
                                                            .symmetric(
                                                            vertical: 5,
                                                            horizontal: 8),
                                                    border: OutlineInputBorder(
                                                      borderRadius:
                                                          const BorderRadius
                                                              .all(
                                                              Radius.circular(
                                                                  6)),
                                                      borderSide: BorderSide(
                                                          color: Colors
                                                              .grey.shade400,
                                                          width: 1.5),
                                                    ),
                                                    focusedBorder:
                                                        const OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  6)),
                                                      borderSide: BorderSide(
                                                          color: Colors.blue,
                                                          width: 2.0),
                                                    ),
                                                    enabledBorder:
                                                        OutlineInputBorder(
                                                      borderRadius:
                                                          const BorderRadius
                                                              .all(
                                                              Radius.circular(
                                                                  6)),
                                                      borderSide: BorderSide(
                                                          color: Colors
                                                              .grey.shade400,
                                                          width: 1.5),
                                                    ),
                                                    suffixIcon: const Icon(
                                                        Icons
                                                            .phone_android_outlined,
                                                        size: 20),
                                                  ),
                                                  keyboardType:
                                                      TextInputType.number,
                                                  inputFormatters: [
                                                    FilteringTextInputFormatter
                                                        .digitsOnly,
                                                    LengthLimitingTextInputFormatter(
                                                        10),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 15,
                                            ),
                                            Expanded(
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    right: 8.0),
                                                child: TextFormField(
                                                  controller: location,
                                                  style: GoogleFonts.inter(
                                                      color: Colors.black,
                                                      fontSize: 13),
                                                  decoration: InputDecoration(
                                                    hintText: 'Location',
                                                    hintStyle: TextStyles.body1,
                                                    contentPadding:
                                                        const EdgeInsets
                                                            .symmetric(
                                                            vertical: 5,
                                                            horizontal: 8),
                                                    border: OutlineInputBorder(
                                                      borderRadius:
                                                          const BorderRadius
                                                              .all(
                                                              Radius.circular(
                                                                  6)),
                                                      borderSide: BorderSide(
                                                          color: Colors
                                                              .grey.shade400,
                                                          width: 1.5),
                                                    ),
                                                    focusedBorder:
                                                        const OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  6)),
                                                      borderSide: BorderSide(
                                                          color: Colors.blue,
                                                          width: 2.0),
                                                    ),
                                                    enabledBorder:
                                                        OutlineInputBorder(
                                                      borderRadius:
                                                          const BorderRadius
                                                              .all(
                                                              Radius.circular(
                                                                  6)),
                                                      borderSide: BorderSide(
                                                          color: Colors
                                                              .grey.shade400,
                                                          width: 1.5),
                                                    ),
                                                    suffixIcon: const Icon(
                                                        Icons.location_on,
                                                        size: 20),
                                                  ),
                                                  onChanged: (value) {
                                                    // Allow only alphabetic characters
                                                    String filteredValue =
                                                        value.replaceAll(
                                                            RegExp(
                                                                r'[^a-zA-Z\s]'),
                                                            '');

                                                    if (filteredValue
                                                        .isNotEmpty) {
                                                      String formattedText =
                                                          filteredValue[0]
                                                                  .toUpperCase() +
                                                              filteredValue
                                                                  .substring(1)
                                                                  .toLowerCase();
                                                      location.value = location
                                                          .value
                                                          .copyWith(
                                                        text: formattedText,
                                                        selection: TextSelection
                                                            .collapsed(
                                                                offset:
                                                                    formattedText
                                                                        .length),
                                                      );
                                                    } else {
                                                      location.clear();
                                                    }
                                                  },
                                                ),
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 15,
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 20),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(right: 20),
                                          child: Align(
                                            alignment: Alignment.bottomRight,
                                            child: SizedBox(
                                              width: 120,
                                              child: OutlinedButton(
                                                onPressed: () async {
                                                  if (selectedValue == null ||
                                                      selectedValue ==
                                                          'Select Role') {
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                      const SnackBar(
                                                        content: Text(
                                                            'Please select a Role'),
                                                      ),
                                                    );
                                                  } else if (userNameController
                                                          .text.isEmpty ||
                                                      userNameController
                                                              .text.length <=
                                                          2) {
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                      const SnackBar(
                                                        content: Text(
                                                            'Please fill user name'),
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
                                                            'Enter Valid Email Address'),
                                                      ),
                                                    );
                                                  } else if (departmentController
                                                      .text.isEmpty) {
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                      const SnackBar(
                                                        content: Text(
                                                            'Please fill Company Name.'),
                                                      ),
                                                    );
                                                  } else if (mobileController
                                                          .text.isEmpty ||
                                                      mobileController
                                                              .text.length !=
                                                          10) {
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                      const SnackBar(
                                                        content: Text(
                                                            'Please fill a valid mobile number.'),
                                                      ),
                                                    );
                                                  } else if (location
                                                      .text.isEmpty) {
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                      const SnackBar(
                                                        content: Text(
                                                            'Please fill location '),
                                                      ),
                                                    );
                                                  } else {
                                                    cusSave(context);
                                                  }

                                                  // Save form
                                                },
                                                style: OutlinedButton.styleFrom(
                                                  backgroundColor:
                                                      Colors.blue[900],
                                                  padding: null,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5),
                                                  ),
                                                  side: const BorderSide(
                                                    color: Colors.blue,
                                                    width: 1,
                                                  ),
                                                ),
                                                child: Text(
                                                  '  Save  ',
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
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
                } else ...{
                  Positioned(
                    left: 202,
                    right: 0,
                    top: 10,
                    bottom: 0,
                    child: Padding(
                      padding: const EdgeInsets.only(
                        top: 40,
                      ),
                      child: RawScrollbar(
                        controller: _scrollController,
                        thumbVisibility: true,
                        thickness: 15,
                        radius: const Radius.circular(2),
                        thumbColor: Colors.grey[400],
                        trackColor: Colors.grey[900],
                        trackRadius: const Radius.circular(2),
                        child: SingleChildScrollView(
                          controller: _scrollController,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 30, top: 10),
                                child: Row(
                                  children: [
                                    IconButton(
                                        onPressed: () {
                                          context.go('/User_List');
                                        },
                                        icon: const Icon(
                                          Icons.arrow_back,
                                          size: 16,
                                        )),
                                    Text(
                                      'Create User',
                                      style: TextStyles.header1,
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.only(left: 0),

                                height: 1,
                                width: containerWidth,

                                color: Colors.grey.shade300, // Border color
                              ),
                              SizedBox(
                                height: 600,
                                child: AdaptiveScrollbar(
                                  position: ScrollbarPosition.bottom,
                                  controller: horizontalScroll,
                                  child: SingleChildScrollView(
                                    controller: horizontalScroll,
                                    scrollDirection: Axis.horizontal,
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          left: 55, top: 20, right: 20),
                                      child: Container(
                                        height: 350,
                                        width: 1200,
                                        padding: const EdgeInsets.all(16.0),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        child: Form(
                                          key: formKey,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 15, top: 30),
                                                child: Text('User Details',
                                                    style: TextStyles.header3),
                                              ),
                                              const SizedBox(height: 26),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  const SizedBox(
                                                    width: 15,
                                                  ),
                                                  Expanded(
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 10,
                                                              bottom: 8,
                                                              right: 10),
                                                      child: AnimatedContainer(
                                                        duration:
                                                            const Duration(
                                                                milliseconds:
                                                                    300),
                                                        curve: Curves.easeInOut,
                                                        child:
                                                            DropdownButtonHideUnderline(
                                                          child: Container(
                                                            decoration:
                                                                BoxDecoration(
                                                              border:
                                                                  Border.all(
                                                                color:
                                                                    Colors.grey,
                                                                width: 1.5,
                                                              ),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          6),
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                            child:
                                                                DropdownButton2(
                                                              isExpanded: true,
                                                              hint: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(
                                                                        8.0),
                                                                child: Text(
                                                                  'Select Role',
                                                                  style:
                                                                      TextStyles
                                                                          .body1,
                                                                ),
                                                              ),
                                                              items: items
                                                                  .map((item) =>
                                                                      DropdownMenuItem<
                                                                          String>(
                                                                        value:
                                                                            item,
                                                                        child:
                                                                            Padding(
                                                                          padding: const EdgeInsets
                                                                              .all(
                                                                              8.0),
                                                                          child: Text(
                                                                              item,
                                                                              style: GoogleFonts.inter(color: Colors.black, fontSize: 13)),
                                                                        ),
                                                                      ))
                                                                  .toList(),
                                                              value:
                                                                  selectedValue,
                                                              onChanged:
                                                                  (value) {
                                                                setState(() {
                                                                  selectedValue =
                                                                      value
                                                                          as String;
                                                                });
                                                              },
                                                              buttonStyleData:
                                                                  ButtonStyleData(
                                                                height: 42,
                                                                width: 255,
                                                                decoration:
                                                                    BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              4),
                                                                  color: Colors
                                                                      .white, // No border here
                                                                ),
                                                              ),
                                                              dropdownStyleData:
                                                                  DropdownStyleData(
                                                                maxHeight: 155,
                                                                width: 330,
                                                                padding: const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        5,
                                                                    vertical:
                                                                        5),
                                                                decoration:
                                                                    BoxDecoration(
                                                                  border: Border.all(
                                                                      color: Colors
                                                                          .grey),
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              6),
                                                                  color: Colors
                                                                      .white, // Dropdown background color
                                                                ),
                                                                elevation: 5,
                                                                offset:
                                                                    const Offset(
                                                                        0, -10),
                                                              ),
                                                              iconStyleData:
                                                                  const IconStyleData(
                                                                icon: Padding(
                                                                  padding: EdgeInsets
                                                                      .only(
                                                                          right:
                                                                              10),
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
                                                  const SizedBox(
                                                    width: 15,
                                                  ),
                                                  Expanded(
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              right: 8.0),
                                                      child: TextFormField(
                                                        controller:
                                                            userNameController,
                                                        style:
                                                            GoogleFonts.inter(
                                                                color: Colors
                                                                    .black,
                                                                fontSize: 13),
                                                        decoration:
                                                            InputDecoration(
                                                          hintText: 'User Name',
                                                          hintStyle:
                                                              TextStyles.body1,
                                                          contentPadding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  vertical: 5,
                                                                  horizontal:
                                                                      8),
                                                          border:
                                                              OutlineInputBorder(
                                                            borderRadius:
                                                                const BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            6)),
                                                            borderSide: BorderSide(
                                                                color: Colors
                                                                    .grey
                                                                    .shade400,
                                                                width: 1.5),
                                                          ),
                                                          focusedBorder:
                                                              const OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            6)),
                                                            borderSide:
                                                                BorderSide(
                                                                    color: Colors
                                                                        .blue,
                                                                    width: 2.0),
                                                          ),
                                                          enabledBorder:
                                                              OutlineInputBorder(
                                                            borderRadius:
                                                                const BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            6)),
                                                            borderSide: BorderSide(
                                                                color: Colors
                                                                    .grey
                                                                    .shade400,
                                                                width: 1.5),
                                                          ),
                                                          suffixIcon: const Icon(
                                                              Icons
                                                                  .account_circle,
                                                              size: 20),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    width: 15,
                                                  ),
                                                  Expanded(
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              right: 8.0),
                                                      child: TextFormField(
                                                        controller:
                                                            emailController,
                                                        style:
                                                            GoogleFonts.inter(
                                                                color: Colors
                                                                    .black,
                                                                fontSize: 13),
                                                        decoration:
                                                            InputDecoration(
                                                          hintText:
                                                              'Email Address',
                                                          hintStyle:
                                                              TextStyles.body1,
                                                          contentPadding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  vertical: 5,
                                                                  horizontal:
                                                                      8),
                                                          border:
                                                              OutlineInputBorder(
                                                            borderRadius:
                                                                const BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            6)),
                                                            borderSide: BorderSide(
                                                                color: Colors
                                                                    .grey
                                                                    .shade400,
                                                                width: 1.5),
                                                          ),
                                                          focusedBorder:
                                                              const OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            6)),
                                                            borderSide:
                                                                BorderSide(
                                                                    color: Colors
                                                                        .blue,
                                                                    width: 2.0),
                                                          ),
                                                          enabledBorder:
                                                              OutlineInputBorder(
                                                            borderRadius:
                                                                const BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            6)),
                                                            borderSide: BorderSide(
                                                                color: Colors
                                                                    .grey
                                                                    .shade400,
                                                                width: 1.5),
                                                          ),
                                                          suffixIcon:
                                                              const Icon(
                                                                  Icons.mail,
                                                                  size: 20),
                                                        ),
                                                        inputFormatters: [
                                                          FilteringTextInputFormatter
                                                              .allow(RegExp(
                                                                  r'[a-z0-9@._]')),
                                                        ],
                                                        onChanged: (value) {
                                                          emailController
                                                                  .value =
                                                              TextEditingValue(
                                                            text: value
                                                                .toLowerCase(),
                                                            selection:
                                                                emailController
                                                                    .selection,
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    width: 15,
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 22),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  const SizedBox(
                                                    width: 15,
                                                  ),
                                                  Expanded(
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              right: 8.0),
                                                      child: TextFormField(
                                                        controller:
                                                            departmentController,
                                                        style:
                                                            GoogleFonts.inter(
                                                                color: Colors
                                                                    .black,
                                                                fontSize: 13),
                                                        decoration:
                                                            InputDecoration(
                                                          hintText:
                                                              'Company Name',
                                                          hintStyle:
                                                              TextStyles.body1,
                                                          contentPadding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  vertical: 5,
                                                                  horizontal:
                                                                      8),
                                                          border:
                                                              OutlineInputBorder(
                                                            borderRadius:
                                                                const BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            6)),
                                                            borderSide: BorderSide(
                                                                color: Colors
                                                                    .grey
                                                                    .shade400,
                                                                width: 1.5),
                                                          ),
                                                          focusedBorder:
                                                              const OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            6)),
                                                            borderSide:
                                                                BorderSide(
                                                                    color: Colors
                                                                        .blue,
                                                                    width: 2.0),
                                                          ),
                                                          enabledBorder:
                                                              OutlineInputBorder(
                                                            borderRadius:
                                                                const BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            6)),
                                                            borderSide: BorderSide(
                                                                color: Colors
                                                                    .grey
                                                                    .shade400,
                                                                width: 1.5),
                                                          ),
                                                          suffixIcon:
                                                              const Icon(
                                                                  Icons
                                                                      .business,
                                                                  size: 20),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    width: 15,
                                                  ),
                                                  Expanded(
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              right: 8.0),
                                                      child: TextFormField(
                                                        controller:
                                                            mobileController,
                                                        style:
                                                            GoogleFonts.inter(
                                                                color: Colors
                                                                    .black,
                                                                fontSize: 13),
                                                        decoration:
                                                            InputDecoration(
                                                          hintText: 'Mobile No',
                                                          hintStyle:
                                                              TextStyles.body1,
                                                          contentPadding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  vertical: 5,
                                                                  horizontal:
                                                                      8),
                                                          border:
                                                              OutlineInputBorder(
                                                            borderRadius:
                                                                const BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            6)),
                                                            borderSide: BorderSide(
                                                                color: Colors
                                                                    .grey
                                                                    .shade400,
                                                                width: 1.5),
                                                          ),
                                                          focusedBorder:
                                                              const OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            6)),
                                                            borderSide:
                                                                BorderSide(
                                                                    color: Colors
                                                                        .blue,
                                                                    width: 2.0),
                                                          ),
                                                          enabledBorder:
                                                              OutlineInputBorder(
                                                            borderRadius:
                                                                const BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            6)),
                                                            borderSide: BorderSide(
                                                                color: Colors
                                                                    .grey
                                                                    .shade400,
                                                                width: 1.5),
                                                          ),
                                                          suffixIcon: const Icon(
                                                              Icons
                                                                  .phone_android_outlined,
                                                              size: 20),
                                                        ),
                                                        keyboardType:
                                                            TextInputType
                                                                .number,
                                                        inputFormatters: [
                                                          FilteringTextInputFormatter
                                                              .digitsOnly,
                                                          LengthLimitingTextInputFormatter(
                                                              10),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    width: 15,
                                                  ),
                                                  Expanded(
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              right: 8.0),
                                                      child: TextFormField(
                                                        controller: location,
                                                        style:
                                                            GoogleFonts.inter(
                                                                color: Colors
                                                                    .black,
                                                                fontSize: 13),
                                                        decoration:
                                                            InputDecoration(
                                                          hintText: 'Location',
                                                          hintStyle:
                                                              TextStyles.body1,
                                                          contentPadding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  vertical: 5,
                                                                  horizontal:
                                                                      8),
                                                          border:
                                                              OutlineInputBorder(
                                                            borderRadius:
                                                                const BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            6)),
                                                            borderSide: BorderSide(
                                                                color: Colors
                                                                    .grey
                                                                    .shade400,
                                                                width: 1.5),
                                                          ),
                                                          focusedBorder:
                                                              const OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            6)),
                                                            borderSide:
                                                                BorderSide(
                                                                    color: Colors
                                                                        .blue,
                                                                    width: 2.0),
                                                          ),
                                                          enabledBorder:
                                                              OutlineInputBorder(
                                                            borderRadius:
                                                                const BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            6)),
                                                            borderSide: BorderSide(
                                                                color: Colors
                                                                    .grey
                                                                    .shade400,
                                                                width: 1.5),
                                                          ),
                                                          suffixIcon: const Icon(
                                                              Icons.location_on,
                                                              size: 20),
                                                        ),
                                                        onChanged: (value) {
                                                          String filteredValue =
                                                              value.replaceAll(
                                                                  RegExp(
                                                                      r'[^a-zA-Z\s]'),
                                                                  '');

                                                          if (filteredValue
                                                              .isNotEmpty) {
                                                            String
                                                                formattedText =
                                                                filteredValue[0]
                                                                        .toUpperCase() +
                                                                    filteredValue
                                                                        .substring(
                                                                            1)
                                                                        .toLowerCase();
                                                            location.value =
                                                                location.value
                                                                    .copyWith(
                                                              text:
                                                                  formattedText,
                                                              selection: TextSelection
                                                                  .collapsed(
                                                                      offset: formattedText
                                                                          .length),
                                                            );
                                                          } else {
                                                            location.clear();
                                                          }
                                                        },
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    width: 15,
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 20),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    right: 20),
                                                child: Align(
                                                  alignment:
                                                      Alignment.bottomRight,
                                                  child: SizedBox(
                                                    width: 120,
                                                    child: OutlinedButton(
                                                      onPressed: () async {
                                                        if (selectedValue ==
                                                                null ||
                                                            selectedValue ==
                                                                'Select Role') {
                                                          ScaffoldMessenger.of(
                                                                  context)
                                                              .showSnackBar(
                                                            const SnackBar(
                                                              content: Text(
                                                                  'Please select a Role'),
                                                            ),
                                                          );
                                                        } else if (userNameController
                                                                .text.isEmpty ||
                                                            userNameController
                                                                    .text
                                                                    .length <=
                                                                2) {
                                                          ScaffoldMessenger.of(
                                                                  context)
                                                              .showSnackBar(
                                                            const SnackBar(
                                                              content: Text(
                                                                  'Please fill user name'),
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
                                                                  'Enter Valid Email Address'),
                                                            ),
                                                          );
                                                        } else if (departmentController
                                                            .text.isEmpty) {
                                                          ScaffoldMessenger.of(
                                                                  context)
                                                              .showSnackBar(
                                                            const SnackBar(
                                                              content: Text(
                                                                  'Please fill Company Name.'),
                                                            ),
                                                          );
                                                        } else if (mobileController
                                                                .text.isEmpty ||
                                                            mobileController
                                                                    .text
                                                                    .length !=
                                                                10) {
                                                          ScaffoldMessenger.of(
                                                                  context)
                                                              .showSnackBar(
                                                            const SnackBar(
                                                              content: Text(
                                                                  'Please fill a valid mobile number.'),
                                                            ),
                                                          );
                                                        } else if (location
                                                            .text.isEmpty) {
                                                          ScaffoldMessenger.of(
                                                                  context)
                                                              .showSnackBar(
                                                            const SnackBar(
                                                              content: Text(
                                                                  'Please fill location '),
                                                            ),
                                                          );
                                                        } else {
                                                          cusSave(context);
                                                        }

                                                        // Save form
                                                      },
                                                      style: OutlinedButton
                                                          .styleFrom(
                                                        backgroundColor:
                                                            Colors.blue[900],
                                                        padding: null,
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(5),
                                                        ),
                                                        side: const BorderSide(
                                                          color: Colors.blue,
                                                          width: 1,
                                                        ),
                                                      ),
                                                      child: Text(
                                                        '  Save  ',
                                                        style:
                                                            TextStyles.button1,
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
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
                }
              ],
            );
          },
        ),
      ),
    );
  }
}
