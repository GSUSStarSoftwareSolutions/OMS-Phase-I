import 'dart:convert';
import 'dart:html';
import 'package:btb/admin/Api%20name.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../Product/product list.dart';
import '../customer login/home/homeresponsive.dart';
import '../sample/notifier.dart';
import '../sample/size.dart';
import '../widgets/confirmdialog.dart';
import '../widgets/layout size.dart';
import '../widgets/text_style.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => MenuProvider(),
      child: Createusr1(),
    ),
  );
}

class Createusr1 extends StatefulWidget {
  const Createusr1({super.key});

  @override
  State<Createusr1> createState() => _Createusr1State();
}

class _Createusr1State extends State<Createusr1> {
  bool _hasShownPopup = false;
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

  bool _obscureText = true;

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  Future<void> cusSave(BuildContext context) async {
    String url = "$apicall/user_master/add-usermaster";
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
      // if(token == " ") {
      //   showDialog(
      //     barrierDismissible: false,
      //     context: context,
      //     builder: (BuildContext context) {
      //       return
      //         AlertDialog(
      //           shape: RoundedRectangleBorder(
      //             borderRadius: BorderRadius.circular(15.0),
      //           ),
      //           contentPadding: EdgeInsets.zero,
      //           content: Column(
      //             mainAxisSize: MainAxisSize.min,
      //             children: [
      //               Padding(
      //                 padding: const EdgeInsets.all(16.0),
      //                 child: Column(
      //                   children: [
      //                     // Warning Icon
      //                     Icon(Icons.warning, color: Colors.orange, size: 50),
      //                     SizedBox(height: 16),
      //                     // Confirmation Message
      //                     Text(
      //                       'Session Expired',
      //                       style: TextStyle(
      //                         fontSize: 16,
      //                         fontWeight: FontWeight.bold,
      //                         color: Colors.black,
      //                       ),
      //                     ),
      //                     Text("Please log in again to continue",style: TextStyle(
      //                       fontSize: 12,
      //
      //                       color: Colors.black,
      //                     ),),
      //                     SizedBox(height: 20),
      //                     // Buttons
      //                     Row(
      //                       mainAxisAlignment: MainAxisAlignment.center,
      //                       children: [
      //                         ElevatedButton(
      //                           onPressed: () {
      //                             // Handle Yes action
      //                             context.go('/');
      //                             // Navigator.of(context).pop();
      //                           },
      //                           style: ElevatedButton.styleFrom(
      //                             backgroundColor: Colors.white,
      //                             side: BorderSide(color: Colors.blue),
      //                             shape: RoundedRectangleBorder(
      //                               borderRadius: BorderRadius.circular(10.0),
      //                             ),
      //                           ),
      //                           child: Text(
      //                             'ok',
      //                             style: TextStyle(
      //                               color: Colors.blue,
      //                             ),
      //                           ),
      //                         ),
      //                       ],
      //                     ),
      //                   ],
      //                 ),
      //               ),
      //             ],
      //           ),
      //         );
      //     },
      //   ).whenComplete(() {
      //     _hasShownPopup = false;
      //   });
      //
      // }
      // else{
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
                icon: const Icon(Icons.check_circle_rounded,
                    color: Colors.green, size: 25),
                title: const Text(
                  'Account created.',
                  style: TextStyle(fontSize: 15),
                ),
                content: const Row(
                  children: [
                    Text('Check your email for login details.!'),
                    //    SelectableText('$customerId'),
                  ],
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
      //}
    } catch (e) {
      print('Network error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Network error. Please try again.')),
      );
    }
  }

  void showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  void initState() {
    super.initState();
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
                width: maxWidth * 0.11,
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

  void validateAndSave(BuildContext context) {
    if (selectedValue == null || selectedValue == 'Select Role') {
      showSnackBar(context, 'Please select a Role');
    } else if (userNameController.text.isEmpty ||
        userNameController.text.length <= 2) {
      showSnackBar(context, 'Please fill user name');
    } else if (emailController.text.isEmpty ||
        !RegExp(r'^[\w-]+(\.[\w-]+)*@[a-zA-Z0-9-]+\.(com|in|net)$')
            .hasMatch(emailController.text)) {
      showSnackBar(context, 'Enter Valid Email Address');
    } else if (departmentController.text.isEmpty) {
      showSnackBar(context, 'Please fill Company Name');
    } else if (mobileController.text.isEmpty ||
        mobileController.text.length != 10) {
      showSnackBar(context, 'Please fill a valid mobile number');
    } else if (location.text.isEmpty) {
      showSnackBar(context, 'Please fill location');
    } else {
      cusSave(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: const Color(0xFFFFFFFF),
          title: Image.asset(
            "images/Final-Ikyam-Logo.png",
          ),
          elevation: 2.0,
          shadowColor: const Color(0xFFFFFFFF),
          actions: [
            AccountMenu(),
          ],
        ),
        key: context.read<MenuProvider>().scaffoldKey,
        drawer: CustomDrawer(),
        body: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (Responsive.isDesktop(context)) ...{
              Expanded(flex: 1, child: CustomDrawer()),
            },
            Expanded(
              flex: 5,
              child: RawScrollbar(
                controller: _scrollController,
                thumbVisibility: true,
                thickness: 8,
                radius: const Radius.circular(2),
                thumbColor: Colors.grey[400],
                trackColor: Colors.grey[900],
                trackRadius: const Radius.circular(2),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          if (!Responsive.isDesktop(context)) ...{
                            IconButton(
                              onPressed: () {
                                context.read<MenuProvider>().controlMenu;
                              },
                              // onPressed: context.read<MenuController>().controlMenu,
                              icon: Icon(Icons.menu_rounded),
                            )
                          },
                          if (Responsive.isDesktop(context)) ...{
                            Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 12),
                                child: IconButton(
                                  onPressed: () {
                                    context.go('/User_List');
                                  },
                                  icon: Icon(Icons.arrow_back),
                                )),
                          },
                          SizedBox(
                            width: 4,
                          ),
                          Text(
                            'User Create',
                            style: TextStyles.header1,
                          ),
                        ],
                      ),
                      // SizedBox(height: 5,),
                      if (Responsive.isDesktop(context)) ...{
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              height: 2,
                              width: width,
                              color: Colors.grey.shade300, // Border color
                            ),
                          ],
                        ),
                      },

                      Padding(
                        padding: const EdgeInsets.all(48.0),
                        child: Container(
                          //  padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            //   border: Border.all(color: Colors.grey),
                            color: Colors.white,
                            border: Border.all(color: Color(0x29000000)),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 20),
                                child: Text('User Details',
                                    style: TextStyles.header3),
                              ),
                              if (!Responsive.isMobile(context)) ...{
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: AnimatedContainer(
                                          duration:
                                              const Duration(milliseconds: 300),
                                          // Control animation duration
                                          curve: Curves.easeInOut,
                                          // Choose an animation curve
                                          child: DropdownButtonHideUnderline(
                                            child: Container(
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  // Outline border
                                                  color: Colors.grey,
                                                  // Customize outline color
                                                  width:
                                                      1.5, // Customize outline thickness
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                                // Rounded corners for the outline
                                                color: Colors
                                                    .white, // Background color for the dropdown
                                              ),
                                              child: DropdownButton2(
                                                isExpanded: true,
                                                hint: Padding(
                                                  padding: EdgeInsets.all(8.0),
                                                  child: Text(
                                                    'Select Role',
                                                    style: TextStyles.body1,
                                                  ),
                                                ),

                                                items: items
                                                    .map((item) =>
                                                        DropdownMenuItem<
                                                            String>(
                                                          value: item,
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(8.0),
                                                            child: Text(item,
                                                                style: GoogleFonts.inter(
                                                                    color: Colors
                                                                        .black,
                                                                    fontSize:
                                                                        13)),
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
                                                buttonStyleData:
                                                    ButtonStyleData(
                                                  height: 42,
                                                  width: 255,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
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
                                                      horizontal: 5,
                                                      vertical: 5),
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                        color: Colors.grey),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            6),
                                                    color: Colors
                                                        .white, // Dropdown background color
                                                  ),
                                                  elevation: 5,
                                                  offset: const Offset(0, -10),
                                                ),
                                                iconStyleData:
                                                    const IconStyleData(
                                                  icon: Padding(
                                                    padding: EdgeInsets.only(
                                                        right: 10),
                                                    child: Icon(
                                                        Icons.arrow_drop_down),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: TextFormField(
                                          controller: userNameController,
                                          style: GoogleFonts.inter(
                                              color: Colors.black,
                                              fontSize: 13),
                                          decoration: InputDecoration(
                                            hintText: 'User Name',
                                            hintStyle: TextStyles.body1,
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                    vertical: 5, horizontal: 8),
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(6)),
                                              borderSide: BorderSide(
                                                  color: Colors.grey.shade400,
                                                  width: 1.5),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(6)),
                                              borderSide: BorderSide(
                                                  color: Colors.blue,
                                                  width: 2.0),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(6)),
                                              borderSide: BorderSide(
                                                  color: Colors.grey.shade400,
                                                  width: 1.5),
                                            ),
                                            suffixIcon: Icon(
                                                Icons.account_circle,
                                                size: 20),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: TextFormField(
                                          controller: emailController,
                                          style: GoogleFonts.inter(
                                              color: Colors.black,
                                              fontSize: 13),
                                          decoration: InputDecoration(
                                            hintText: 'Email Address',
                                            hintStyle: TextStyles.body1,
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                    vertical: 5, horizontal: 8),
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(6)),
                                              borderSide: BorderSide(
                                                  color: Colors.grey.shade400,
                                                  width: 1.5),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(6)),
                                              borderSide: BorderSide(
                                                  color: Colors.blue,
                                                  width: 2.0),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(6)),
                                              borderSide: BorderSide(
                                                  color: Colors.grey.shade400,
                                                  width: 1.5),
                                            ),
                                            suffixIcon:
                                                Icon(Icons.mail, size: 20),
                                          ),
                                          inputFormatters: [
                                            FilteringTextInputFormatter.allow(
                                                RegExp(r'[a-z0-9@._]')),
                                          ],
                                          onChanged: (value) {
                                            emailController.value =
                                                TextEditingValue(
                                              text: value.toLowerCase(),
                                              selection:
                                                  emailController.selection,
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: TextFormField(
                                          controller: departmentController,
                                          style: GoogleFonts.inter(
                                              color: Colors.black,
                                              fontSize: 13),
                                          decoration: InputDecoration(
                                            hintText: 'Company Name',
                                            hintStyle: TextStyles.body1,
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                    vertical: 5, horizontal: 8),
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(6)),
                                              borderSide: BorderSide(
                                                  color: Colors.grey.shade400,
                                                  width: 1.5),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(6)),
                                              borderSide: BorderSide(
                                                  color: Colors.blue,
                                                  width: 2.0),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(6)),
                                              borderSide: BorderSide(
                                                  color: Colors.grey.shade400,
                                                  width: 1.5),
                                            ),
                                            suffixIcon:
                                                Icon(Icons.business, size: 20),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: TextFormField(
                                          controller: mobileController,
                                          style: GoogleFonts.inter(
                                              color: Colors.black,
                                              fontSize: 13),
                                          decoration: InputDecoration(
                                            hintText: 'Mobile No',
                                            hintStyle: TextStyles.body1,
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                    vertical: 5, horizontal: 8),
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(6)),
                                              borderSide: BorderSide(
                                                  color: Colors.grey.shade400,
                                                  width: 1.5),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(6)),
                                              borderSide: BorderSide(
                                                  color: Colors.blue,
                                                  width: 2.0),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(6)),
                                              borderSide: BorderSide(
                                                  color: Colors.grey.shade400,
                                                  width: 1.5),
                                            ),
                                            suffixIcon: Icon(
                                                Icons.phone_android_outlined,
                                                size: 20),
                                          ),
                                          keyboardType: TextInputType.number,
                                          inputFormatters: [
                                            FilteringTextInputFormatter
                                                .digitsOnly,
                                            LengthLimitingTextInputFormatter(
                                                10),
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: TextFormField(
                                          controller: location,
                                          style: GoogleFonts.inter(
                                              color: Colors.black,
                                              fontSize: 13),
                                          decoration: InputDecoration(
                                            hintText: 'Location',
                                            hintStyle: TextStyles.body1,
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                    vertical: 5, horizontal: 8),
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(6)),
                                              borderSide: BorderSide(
                                                  color: Colors.grey.shade400,
                                                  width: 1.5),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(6)),
                                              borderSide: BorderSide(
                                                  color: Colors.blue,
                                                  width: 2.0),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(6)),
                                              borderSide: BorderSide(
                                                  color: Colors.grey.shade400,
                                                  width: 1.5),
                                            ),
                                            suffixIcon: Icon(Icons.location_on,
                                                size: 20),
                                          ),
                                          onChanged: (value) {
                                            // Allow only alphabetic characters
                                            String filteredValue =
                                                value.replaceAll(
                                                    RegExp(r'[^a-zA-Z\s]'), '');

                                            if (filteredValue.isNotEmpty) {
                                              // Format the text: capitalize the first letter and make the rest lowercase
                                              String formattedText =
                                                  filteredValue[0]
                                                          .toUpperCase() +
                                                      filteredValue
                                                          .substring(1)
                                                          .toLowerCase();

                                              // Update the controller with the filtered and formatted text
                                              location.value =
                                                  location.value.copyWith(
                                                text: formattedText,
                                                selection:
                                                    TextSelection.collapsed(
                                                        offset: formattedText
                                                            .length),
                                              );
                                            } else {
                                              // Clear the text if filtered value is empty
                                              location.clear();
                                            }
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20),
                                  child: Align(
                                    alignment: Alignment.bottomRight,
                                    child: SizedBox(
                                      width: 120,
                                      child: OutlinedButton(
                                        onPressed: () {
                                          print('save click');
                                          validateAndSave(context);
                                        },
                                        style: OutlinedButton.styleFrom(
                                          backgroundColor: Colors.blue[900],
                                          padding: null,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(5),
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
                                SizedBox(
                                  height: 20,
                                ),
                              },
                              if (Responsive.isMobile(context)) ...{
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: AnimatedContainer(
                                          duration:
                                              const Duration(milliseconds: 300),
                                          // Control animation duration
                                          curve: Curves.easeInOut,
                                          // Choose an animation curve
                                          child: DropdownButtonHideUnderline(
                                            child: Container(
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  // Outline border
                                                  color: Colors.grey,
                                                  // Customize outline color
                                                  width:
                                                      1.5, // Customize outline thickness
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                                // Rounded corners for the outline
                                                color: Colors
                                                    .white, // Background color for the dropdown
                                              ),
                                              child: DropdownButton2(
                                                isExpanded: true,
                                                hint: Padding(
                                                  padding: EdgeInsets.all(8.0),
                                                  child: Text(
                                                    'Select Role',
                                                    style: TextStyles.body1,
                                                  ),
                                                ),

                                                items: items
                                                    .map((item) =>
                                                        DropdownMenuItem<
                                                            String>(
                                                          value: item,
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(8.0),
                                                            child: Text(item,
                                                                style: GoogleFonts.inter(
                                                                    color: Colors
                                                                        .black,
                                                                    fontSize:
                                                                        13)),
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
                                                buttonStyleData:
                                                    ButtonStyleData(
                                                  height: 42,
                                                  width: 255,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            4),
                                                    color: Colors
                                                        .white, // No border here
                                                  ),
                                                ),
                                                dropdownStyleData:
                                                    DropdownStyleData(
                                                  maxHeight: 155,
                                                  width: width * 0.43,
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 5,
                                                      vertical: 5),
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                        color: Colors.grey),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            6),
                                                    color: Colors
                                                        .white, // Dropdown background color
                                                  ),
                                                  elevation: 5,
                                                  offset: const Offset(0, -10),
                                                ),
                                                iconStyleData:
                                                    const IconStyleData(
                                                  icon: Padding(
                                                    padding: EdgeInsets.only(
                                                        right: 10),
                                                    child: Icon(
                                                        Icons.arrow_drop_down),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: TextFormField(
                                          controller: userNameController,
                                          style: GoogleFonts.inter(
                                              color: Colors.black,
                                              fontSize: 13),
                                          decoration: InputDecoration(
                                            hintText: 'User Name',
                                            hintStyle: TextStyles.body1,
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                    vertical: 5, horizontal: 8),
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(6)),
                                              borderSide: BorderSide(
                                                  color: Colors.grey.shade400,
                                                  width: 1.5),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(6)),
                                              borderSide: BorderSide(
                                                  color: Colors.blue,
                                                  width: 2.0),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(6)),
                                              borderSide: BorderSide(
                                                  color: Colors.grey.shade400,
                                                  width: 1.5),
                                            ),
                                            suffixIcon: Icon(
                                                Icons.account_circle,
                                                size: 20),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: TextFormField(
                                          controller: emailController,
                                          style: GoogleFonts.inter(
                                              color: Colors.black,
                                              fontSize: 13),
                                          decoration: InputDecoration(
                                            hintText: 'Email Address',
                                            hintStyle: TextStyles.body1,
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                    vertical: 5, horizontal: 8),
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(6)),
                                              borderSide: BorderSide(
                                                  color: Colors.grey.shade400,
                                                  width: 1.5),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(6)),
                                              borderSide: BorderSide(
                                                  color: Colors.blue,
                                                  width: 2.0),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(6)),
                                              borderSide: BorderSide(
                                                  color: Colors.grey.shade400,
                                                  width: 1.5),
                                            ),
                                            suffixIcon:
                                                Icon(Icons.mail, size: 20),
                                          ),
                                          inputFormatters: [
                                            FilteringTextInputFormatter.allow(
                                                RegExp(r'[a-z0-9@._]')),
                                          ],
                                          onChanged: (value) {
                                            emailController.value =
                                                TextEditingValue(
                                              text: value.toLowerCase(),
                                              selection:
                                                  emailController.selection,
                                            );
                                          },
                                        ),
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: TextFormField(
                                          controller: departmentController,
                                          style: GoogleFonts.inter(
                                              color: Colors.black,
                                              fontSize: 13),
                                          decoration: InputDecoration(
                                            hintText: 'Company Name',
                                            hintStyle: TextStyles.body1,
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                    vertical: 5, horizontal: 8),
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(6)),
                                              borderSide: BorderSide(
                                                  color: Colors.grey.shade400,
                                                  width: 1.5),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(6)),
                                              borderSide: BorderSide(
                                                  color: Colors.blue,
                                                  width: 2.0),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(6)),
                                              borderSide: BorderSide(
                                                  color: Colors.grey.shade400,
                                                  width: 1.5),
                                            ),
                                            suffixIcon:
                                                Icon(Icons.business, size: 20),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: TextFormField(
                                          controller: mobileController,
                                          style: GoogleFonts.inter(
                                              color: Colors.black,
                                              fontSize: 13),
                                          decoration: InputDecoration(
                                            hintText: 'Mobile No',
                                            hintStyle: TextStyles.body1,
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                    vertical: 5, horizontal: 8),
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(6)),
                                              borderSide: BorderSide(
                                                  color: Colors.grey.shade400,
                                                  width: 1.5),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(6)),
                                              borderSide: BorderSide(
                                                  color: Colors.blue,
                                                  width: 2.0),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(6)),
                                              borderSide: BorderSide(
                                                  color: Colors.grey.shade400,
                                                  width: 1.5),
                                            ),
                                            suffixIcon: Icon(
                                                Icons.phone_android_outlined,
                                                size: 20),
                                          ),
                                          keyboardType: TextInputType.number,
                                          inputFormatters: [
                                            FilteringTextInputFormatter
                                                .digitsOnly,
                                            LengthLimitingTextInputFormatter(
                                                10),
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: TextFormField(
                                          controller: location,
                                          style: GoogleFonts.inter(
                                              color: Colors.black,
                                              fontSize: 13),
                                          decoration: InputDecoration(
                                            hintText: 'Location',
                                            hintStyle: TextStyles.body1,
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                    vertical: 5, horizontal: 8),
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(6)),
                                              borderSide: BorderSide(
                                                  color: Colors.grey.shade400,
                                                  width: 1.5),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(6)),
                                              borderSide: BorderSide(
                                                  color: Colors.blue,
                                                  width: 2.0),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(6)),
                                              borderSide: BorderSide(
                                                  color: Colors.grey.shade400,
                                                  width: 1.5),
                                            ),
                                            suffixIcon: Icon(Icons.location_on,
                                                size: 20),
                                          ),
                                          onChanged: (value) {
                                            // Allow only alphabetic characters
                                            String filteredValue =
                                                value.replaceAll(
                                                    RegExp(r'[^a-zA-Z\s]'), '');

                                            if (filteredValue.isNotEmpty) {
                                              // Format the text: capitalize the first letter and make the rest lowercase
                                              String formattedText =
                                                  filteredValue[0]
                                                          .toUpperCase() +
                                                      filteredValue
                                                          .substring(1)
                                                          .toLowerCase();

                                              // Update the controller with the filtered and formatted text
                                              location.value =
                                                  location.value.copyWith(
                                                text: formattedText,
                                                selection:
                                                    TextSelection.collapsed(
                                                        offset: formattedText
                                                            .length),
                                              );
                                            } else {
                                              // Clear the text if filtered value is empty
                                              location.clear();
                                            }
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20),
                                  child: Align(
                                    alignment: Alignment.bottomRight,
                                    child: SizedBox(
                                      width: 100,
                                      child: OutlinedButton(
                                        onPressed: () async {
                                          if (selectedValue == null ||
                                              selectedValue == 'Select Role') {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                    'Please select a Role'),
                                              ),
                                            );
                                          } else if (userNameController
                                                  .text.isEmpty ||
                                              userNameController.text.length <=
                                                  2) {
                                            ScaffoldMessenger.of(context)
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
                                                      emailController.text)) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                    'Enter Valid Email Address'),
                                              ),
                                            );
                                          } else if (departmentController
                                              .text.isEmpty) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                    'Please fill Company Name.'),
                                              ),
                                            );
                                          } else if (mobileController
                                                  .text.isEmpty ||
                                              mobileController.text.length !=
                                                  10) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                    'Please fill a valid mobile number.'),
                                              ),
                                            );
                                          } else if (location.text.isEmpty) {
                                            ScaffoldMessenger.of(context)
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
                                          backgroundColor: Colors.blue[900],
                                          padding: null,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(5),
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
                                SizedBox(
                                  height: 20,
                                ),
                              },
                              // if(Responsive.isMobile(context))...{
                              //   Padding(
                              //     padding: const EdgeInsets.symmetric(horizontal: 20.0),
                              //     child: Row(
                              //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              //       children: [
                              //         Expanded(
                              //           flex: 3,
                              //           child: AnimatedContainer(
                              //             duration: const Duration(
                              //                 milliseconds: 300),
                              //             // Control animation duration
                              //             curve: Curves.easeInOut,
                              //             // Choose an animation curve
                              //             child: DropdownButtonHideUnderline(
                              //               child: Container(
                              //                 decoration: BoxDecoration(
                              //                   border: Border
                              //                       .all( // Outline border
                              //                     color: Colors.grey,
                              //                     // Customize outline color
                              //                     width: 1.5, // Customize outline thickness
                              //                   ),
                              //                   borderRadius: BorderRadius
                              //                       .circular(6),
                              //                   // Rounded corners for the outline
                              //                   color: Colors
                              //                       .white, // Background color for the dropdown
                              //                 ),
                              //                 child: DropdownButton2(
                              //                   isExpanded: true,
                              //                   hint: Padding(
                              //                     padding: EdgeInsets.all(8.0),
                              //                     child: Text(
                              //                       'Select Role',
                              //                       style: TextStyles.body1,
                              //                     ),
                              //                   ),
                              //
                              //                   items: items
                              //                       .map((item) =>
                              //                       DropdownMenuItem<String>(
                              //                         value: item,
                              //                         child: Padding(
                              //                           padding: const EdgeInsets
                              //                               .all(8.0),
                              //                           child: Text(
                              //                               item,
                              //                               style: GoogleFonts.inter(
                              //                                   color: Colors.black,
                              //                                   fontSize: 13)
                              //                           ),
                              //                         ),
                              //                       ))
                              //                       .toList(),
                              //                   value: selectedValue,
                              //                   onChanged: (value) {
                              //                     setState(() {
                              //                       selectedValue =
                              //                       value as String;
                              //                     });
                              //                   },
                              //                   // Updated properties as per the latest version of dropdown_button2
                              //                   buttonStyleData: ButtonStyleData(
                              //                     height: 42,
                              //                     width: 255,
                              //                     decoration: BoxDecoration(
                              //                       borderRadius: BorderRadius
                              //                           .circular(4),
                              //                       color: Colors
                              //                           .white, // No border here
                              //                     ),
                              //                   ),
                              //                   dropdownStyleData: DropdownStyleData(
                              //                     maxHeight: 155,
                              //                     width: 330,
                              //                     padding: const EdgeInsets
                              //                         .symmetric(horizontal: 5,
                              //                         vertical: 5),
                              //                     decoration: BoxDecoration(
                              //                       border: Border.all(
                              //                           color: Colors.grey),
                              //                       borderRadius: BorderRadius
                              //                           .circular(6),
                              //                       color: Colors
                              //                           .white, // Dropdown background color
                              //                     ),
                              //                     elevation: 5,
                              //                     offset: const Offset(0, -10),
                              //                   ),
                              //                   iconStyleData: const IconStyleData(
                              //                     icon: Padding(
                              //                       padding: EdgeInsets.only(
                              //                           right: 10),
                              //                       child: Icon(Icons
                              //                           .arrow_drop_down),
                              //                     ),
                              //                   ),
                              //                 ),
                              //               ),
                              //             ),
                              //           ),
                              //         ),
                              //       ],
                              //     ),
                              //   ),
                              //   SizedBox(height: 20,),
                              //   Padding(
                              //     padding: const EdgeInsets.symmetric(horizontal: 20.0),
                              //     child: Row(
                              //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              //       children: [
                              //         Expanded(flex: 3,
                              //           child: TextFormField(
                              //             controller: userNameController,
                              //             style: GoogleFonts.inter(
                              //                 color: Colors.black,
                              //                 fontSize: 13),
                              //             decoration: InputDecoration(
                              //               hintText: 'User Name',
                              //               hintStyle: TextStyles.body1,
                              //               contentPadding: EdgeInsets.symmetric(
                              //                   vertical: 5, horizontal: 8),
                              //               border: OutlineInputBorder(
                              //                 borderRadius: BorderRadius.all(
                              //                     Radius.circular(6)),
                              //                 borderSide: BorderSide(
                              //                     color: Colors.grey.shade400,
                              //                     width: 1.5),
                              //               ),
                              //               focusedBorder: OutlineInputBorder(
                              //                 borderRadius: BorderRadius.all(
                              //                     Radius.circular(6)),
                              //                 borderSide: BorderSide(
                              //                     color: Colors.blue, width: 2.0),
                              //               ),
                              //               enabledBorder: OutlineInputBorder(
                              //                 borderRadius: BorderRadius.all(
                              //                     Radius.circular(6)),
                              //                 borderSide: BorderSide(
                              //                     color: Colors.grey.shade400,
                              //                     width: 1.5),
                              //               ),
                              //               suffixIcon: Icon(
                              //                   Icons.account_circle, size: 20),
                              //             ),
                              //           ),
                              //         ),
                              //       ],
                              //     ),
                              //   ),
                              //   SizedBox(height: 20,),
                              //   Padding(
                              //     padding: const EdgeInsets.symmetric(horizontal: 20.0),
                              //     child: Row(
                              //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              //       children: [
                              //         Expanded(
                              //           flex: 3,
                              //           child: TextFormField(
                              //             controller: emailController,
                              //             style: GoogleFonts.inter(
                              //                 color: Colors.black,
                              //                 fontSize: 13),
                              //             decoration: InputDecoration(
                              //               hintText: 'Email Address',
                              //               hintStyle: TextStyles.body1,
                              //               contentPadding: EdgeInsets.symmetric(
                              //                   vertical: 5, horizontal: 8),
                              //               border: OutlineInputBorder(
                              //                 borderRadius: BorderRadius.all(
                              //                     Radius.circular(6)),
                              //                 borderSide: BorderSide(
                              //                     color: Colors.grey.shade400,
                              //                     width: 1.5),
                              //               ),
                              //               focusedBorder: OutlineInputBorder(
                              //                 borderRadius: BorderRadius.all(
                              //                     Radius.circular(6)),
                              //                 borderSide: BorderSide(
                              //                     color: Colors.blue, width: 2.0),
                              //               ),
                              //               enabledBorder: OutlineInputBorder(
                              //                 borderRadius: BorderRadius.all(
                              //                     Radius.circular(6)),
                              //                 borderSide: BorderSide(
                              //                     color: Colors.grey.shade400,
                              //                     width: 1.5),
                              //               ),
                              //               suffixIcon: Icon(Icons.mail, size: 20),
                              //             ),
                              //             inputFormatters: [
                              //               FilteringTextInputFormatter.allow(RegExp(
                              //                   r'[a-z0-9@._]')),
                              //             ],
                              //             onChanged: (value) {
                              //               emailController.value = TextEditingValue(
                              //                 text: value.toLowerCase(),
                              //                 selection: emailController.selection,
                              //               );
                              //             },
                              //           ),
                              //         ),
                              //       ],
                              //
                              //     ),
                              //   ),
                              //   Padding(
                              //     padding: const EdgeInsets.symmetric(horizontal: 20.0),
                              //     child: Row(
                              //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              //       children: [
                              //         Expanded(
                              //           flex:2,
                              //           child: TextFormField(
                              //             controller: departmentController,
                              //             style: GoogleFonts.inter(
                              //                 color: Colors.black,
                              //                 fontSize: 13),
                              //             decoration: InputDecoration(
                              //               hintText: 'Company Name',
                              //               hintStyle: TextStyles.body1,
                              //               contentPadding: EdgeInsets.symmetric(
                              //                   vertical: 5, horizontal: 8),
                              //               border: OutlineInputBorder(
                              //                 borderRadius: BorderRadius.all(
                              //                     Radius.circular(6)),
                              //                 borderSide: BorderSide(
                              //                     color: Colors.grey.shade400,
                              //                     width: 1.5),
                              //               ),
                              //               focusedBorder: OutlineInputBorder(
                              //                 borderRadius: BorderRadius.all(
                              //                     Radius.circular(6)),
                              //                 borderSide: BorderSide(
                              //                     color: Colors.blue, width: 2.0),
                              //               ),
                              //               enabledBorder: OutlineInputBorder(
                              //                 borderRadius: BorderRadius.all(
                              //                     Radius.circular(6)),
                              //                 borderSide: BorderSide(
                              //                     color: Colors.grey.shade400,
                              //                     width: 1.5),
                              //               ),
                              //               suffixIcon: Icon(
                              //                   Icons.business, size: 20),
                              //             ),
                              //           ),
                              //         ),
                              //       ],
                              //
                              //     ),
                              //   ),
                              //   Padding(
                              //     padding: const EdgeInsets.symmetric(horizontal: 20.0),
                              //     child: Row(
                              //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              //       children: [
                              //         Expanded(
                              //           flex: 2,
                              //           child: TextFormField(
                              //             controller: mobileController,
                              //             style: GoogleFonts.inter(
                              //                 color: Colors.black,
                              //                 fontSize: 13),
                              //             decoration: InputDecoration(
                              //               hintText: 'Mobile No',
                              //               hintStyle: TextStyles.body1,
                              //               contentPadding: EdgeInsets.symmetric(
                              //                   vertical: 5, horizontal: 8),
                              //               border: OutlineInputBorder(
                              //                 borderRadius: BorderRadius.all(
                              //                     Radius.circular(6)),
                              //                 borderSide: BorderSide(
                              //                     color: Colors.grey.shade400,
                              //                     width: 1.5),
                              //               ),
                              //               focusedBorder: OutlineInputBorder(
                              //                 borderRadius: BorderRadius.all(
                              //                     Radius.circular(6)),
                              //                 borderSide: BorderSide(
                              //                     color: Colors.blue, width: 2.0),
                              //               ),
                              //               enabledBorder: OutlineInputBorder(
                              //                 borderRadius: BorderRadius.all(
                              //                     Radius.circular(6)),
                              //                 borderSide: BorderSide(
                              //                     color: Colors.grey.shade400,
                              //                     width: 1.5),
                              //               ),
                              //               suffixIcon: Icon(
                              //                   Icons.phone_android_outlined,
                              //                   size: 20),
                              //             ),
                              //             keyboardType: TextInputType.number,
                              //             inputFormatters: [
                              //               FilteringTextInputFormatter.digitsOnly,
                              //               LengthLimitingTextInputFormatter(10),
                              //             ],
                              //           ),
                              //         ),
                              //       ],
                              //
                              //     ),
                              //   ),
                              //   Padding(
                              //     padding: const EdgeInsets.symmetric(horizontal: 20.0),
                              //     child: Row(
                              //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              //       children: [
                              //         Expanded(
                              //           flex: 2,
                              //           child: TextFormField(
                              //             controller: location,
                              //             style: GoogleFonts.inter(
                              //                 color: Colors.black,
                              //                 fontSize: 13),
                              //             decoration: InputDecoration(
                              //               hintText: 'Location',
                              //               hintStyle: TextStyles.body1,
                              //               contentPadding: EdgeInsets.symmetric(
                              //                   vertical: 5, horizontal: 8),
                              //               border: OutlineInputBorder(
                              //                 borderRadius: BorderRadius.all(
                              //                     Radius.circular(6)),
                              //                 borderSide: BorderSide(
                              //                     color: Colors.grey.shade400,
                              //                     width: 1.5),
                              //               ),
                              //               focusedBorder: OutlineInputBorder(
                              //                 borderRadius: BorderRadius.all(
                              //                     Radius.circular(6)),
                              //                 borderSide: BorderSide(
                              //                     color: Colors.blue, width: 2.0),
                              //               ),
                              //               enabledBorder: OutlineInputBorder(
                              //                 borderRadius: BorderRadius.all(
                              //                     Radius.circular(6)),
                              //                 borderSide: BorderSide(
                              //                     color: Colors.grey.shade400,
                              //                     width: 1.5),
                              //               ),
                              //               suffixIcon: Icon(
                              //                   Icons.location_on, size: 20),
                              //             ),
                              //             onChanged: (value) {
                              //               // Allow only alphabetic characters
                              //               String filteredValue = value.replaceAll(
                              //                   RegExp(r'[^a-zA-Z\s]'), '');
                              //
                              //               if (filteredValue.isNotEmpty) {
                              //                 // Format the text: capitalize the first letter and make the rest lowercase
                              //                 String formattedText = filteredValue[0]
                              //                     .toUpperCase() +
                              //                     filteredValue.substring(1)
                              //                         .toLowerCase();
                              //
                              //                 // Update the controller with the filtered and formatted text
                              //                 location.value =
                              //                     location.value.copyWith(
                              //                       text: formattedText,
                              //                       selection: TextSelection
                              //                           .collapsed(
                              //                           offset: formattedText.length),
                              //                     );
                              //               } else {
                              //                 // Clear the text if filtered value is empty
                              //                 location.clear();
                              //               }
                              //             },
                              //           ),
                              //         ),
                              //       ],
                              //
                              //     ),
                              //   ),
                              //
                              //
                              //
                              // },
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            )
          ],
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
