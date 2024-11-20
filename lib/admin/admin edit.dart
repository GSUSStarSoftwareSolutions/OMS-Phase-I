import 'dart:convert';
import 'dart:html';
import 'package:btb/admin/Api%20name.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
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
  String token = window.sessionStorage["token"] ?? " ";
  final ScrollController _scrollController = ScrollController();
  late TextEditingController dateController;
  TextEditingController location = TextEditingController();
  TextEditingController userNameController = TextEditingController();
  TextEditingController userId = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController departmentController = TextEditingController();
  TextEditingController designationController = TextEditingController();
  TextEditingController mobileController = TextEditingController();
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
    dateController = TextEditingController();
    dateController.text = 'Joining Date';
  }

  void dispose() {
    location.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color(0xFFF0F4F8),
        appBar: AppBar(
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
            const Padding(
              padding: EdgeInsets.only(top: 10),
              // child:
              // AccountMenu(),
            ),
          ],
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: [
                const Sidebar(),
                Padding(
                  padding: const EdgeInsets.only(left: 200, top: 0),
                  child: Container(
                    width: 1, // Set the width to 1 for a vertical line
                    height: 1400, // Set the height to your liking
                    decoration: const BoxDecoration(
                      border: Border(left: BorderSide(width: 1, color: Colors
                          .grey)),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 201),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    color: Colors.white,
                    height: 52,
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                              Icons.arrow_back), // Back button icon
                          onPressed: () {
                            context.go(
                                '/User_List');
                          },
                        ),
                        const Padding(
                          padding: EdgeInsets.only(left: 20),
                          child: Text(
                            'Edit User',
                            style: TextStyle(
                              fontSize: 18,
                              // fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
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
                Padding(
                  padding: const EdgeInsets.only(top: 80),
                  child: Center(
                    child: RawScrollbar(
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
                        child: Row(mainAxisAlignment: MainAxisAlignment.center,

                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 200),
                              child: Container(
                                height: 520,
                                width: 400,
                                padding: const EdgeInsets.all(16.0),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.5),
                                      spreadRadius: 2,
                                      blurRadius: 5,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Form(
                                  key: formKey,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment
                                        .center,
                                    children: [
                                      const Text('User Edit',
                                        style: TextStyle(fontSize: 15,
                                          fontWeight: FontWeight.bold,),),


                                      const SizedBox(height: 26,),
                                      const Divider(
                                        height: 3,
                                        color: Colors.grey,
                                      ),
                                      const SizedBox(height: 8,),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            top: 10, bottom: 8),
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
                                                hint: const Padding(
                                                  padding: EdgeInsets.all(8.0),
                                                  child: Text(
                                                    'Select Role',
                                                    style: TextStyle(
                                                        fontSize: 16),
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
                                                          style: const TextStyle(
                                                            fontSize: 14,
                                                          ),
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
                                                  width: 285,
                                                  decoration: BoxDecoration(
                                                    borderRadius: BorderRadius
                                                        .circular(4),
                                                    color: Colors
                                                        .white, // No border here
                                                  ),
                                                ),
                                                dropdownStyleData: DropdownStyleData(
                                                  maxHeight: 100,
                                                  width: 285,
                                                  padding: const EdgeInsets
                                                      .symmetric(horizontal: 5,
                                                      vertical: 5),
                                                  decoration: BoxDecoration(
                                                    borderRadius: BorderRadius
                                                        .circular(15),
                                                    color: Colors
                                                        .grey[200], // Dropdown background color
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
                                      const SizedBox(height: 6),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 40, right: 40),
                                        child: SizedBox(
                                          height: 45,
                                          child: TextFormField(
                                            controller: userNameController,
                                            decoration: const InputDecoration(
                                              hintText: 'User Name',
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

                                      const SizedBox(height: 14,),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 40, right: 40),
                                        child: SizedBox(
                                          height: 45,
                                          child:TextFormField(
                                            controller: emailController,
                                            decoration: const InputDecoration(
                                              hintText: 'Email Address',
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
                                      // const SizedBox(height: 11,),
                                      // Padding(
                                      //   padding: const EdgeInsets.only(
                                      //       left: 40, right: 40),
                                      //   child: SizedBox(
                                      //     height: 45,
                                      //     child: TextFormField(
                                      //       controller: passwordController,
                                      //       obscureText: _obscureText,
                                      //       decoration: InputDecoration(
                                      //         hintText: 'Create Password',
                                      //         contentPadding: const EdgeInsets
                                      //             .symmetric(
                                      //             vertical: 5, horizontal: 8),
                                      //         border: const OutlineInputBorder(
                                      //           borderRadius: BorderRadius.all(
                                      //               Radius.circular(6)),
                                      //           // Set border radius for all sides
                                      //           borderSide: BorderSide(
                                      //               color: Colors.grey,
                                      //               width: 1.5), // Set border color and width
                                      //         ),
                                      //         focusedBorder: const OutlineInputBorder(
                                      //           borderRadius: BorderRadius.all(
                                      //               Radius.circular(6)),
                                      //           // Same border radius when focused
                                      //           borderSide: BorderSide(
                                      //               color: Colors.blue,
                                      //               width: 2.0), // Customize focused border color and width
                                      //         ),
                                      //         enabledBorder: const OutlineInputBorder(
                                      //           borderRadius: BorderRadius.all(
                                      //               Radius.circular(6)),
                                      //           // Same border radius when enabled
                                      //           borderSide: BorderSide(
                                      //               color: Colors.grey,
                                      //               width: 1.5), // Customize enabled border color and width
                                      //         ),
                                      //         suffixIcon: IconButton(
                                      //           icon: Icon(
                                      //             _obscureText ? Icons
                                      //                 .visibility_off : Icons
                                      //                 .visibility,
                                      //           ),
                                      //           onPressed: _togglePasswordVisibility,
                                      //         ), // Icon at the end
                                      //       ),
                                      //     ),
                                      //   ),
                                      // ),
                                      const SizedBox(height: 14,),

                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 40, right: 40),
                                        child: SizedBox(
                                          height: 45,
                                          child: TextFormField(
                                            controller: departmentController,
                                            decoration: const InputDecoration(
                                              hintText: 'Company Name',
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

                                      const SizedBox(height: 14,),

                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 40, right: 40),
                                        child: SizedBox(
                                          height: 45,
                                          child: TextFormField(
                                            controller: mobileController,
                                            decoration: const InputDecoration(
                                              hintText: 'Mobile No',
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
                                      const SizedBox(height: 14,),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 40, right: 40),
                                        child: TextFormField(
                                          controller: location,
                                          onChanged: (value) {
                                            if (value.isNotEmpty) {
                                              String formattedText = value[0]
                                                  .toUpperCase() +
                                                  value.substring(1)
                                                      .toLowerCase();
                                              location.value =
                                                  location.value.copyWith(
                                                    text: formattedText,
                                                    selection: TextSelection
                                                        .collapsed(
                                                        offset: formattedText
                                                            .length),
                                                  );
                                            }
                                          },
                                          decoration: const InputDecoration(
                                            hintText: 'Location',
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
                                            suffixIcon: Icon(Icons.location_on,
                                                size: 20), // Icon at the end
                                          ),
                                        ),
                                      ),

                                      const SizedBox(height: 13,),
                                      SizedBox(
                                        width: 150,
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
                                            else
                                            if (emailController.text.isEmpty ||
                                                !RegExp(
                                                    r'^[\w-]+(\.[\w-]+)*@gmail\.com$')
                                                    .hasMatch(
                                                    emailController.text)) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                      'Please fill Email Address Format @gmail.com'),
                                                ),
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
                                            // Button background color
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius
                                                  .circular(
                                                  15), // Rounded corners
                                            ),
                                            side: const BorderSide( // Set border color to red
                                              color: Colors.blue,
                                              width: 1, // You can adjust the border width as needed
                                            ), // No outline
                                          ),
                                          child: const Text(
                                            'Update',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
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

class Sidebar extends StatefulWidget {
  const Sidebar({super.key});

  @override
  _SidebarState createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  // bool isMinimized = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      color:const Color(0xFFF7F6FA),
      child:  Padding(
        padding: const EdgeInsets.only(left: 15, top: 30,right: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 150,
              height: 45,
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
              ),
              child: TextButton.icon(
                onPressed: () {
                  context.go('/User_List');
                },
                icon: const Icon(
                    Icons.home_outlined, color: Colors.white),
                label: const Text(
                  'Home',
                  style: TextStyle(color: Colors.white,fontSize: 16),
                ),
              ),
            ),
          ],
        ),

      ),
    );
  }
}