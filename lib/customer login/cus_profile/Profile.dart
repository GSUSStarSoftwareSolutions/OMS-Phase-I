
import 'dart:async';
import 'dart:convert';
import 'dart:html';
import 'package:adaptive_scrollbar/adaptive_scrollbar.dart';
import 'package:btb/admin/Api%20name.dart';
import 'package:btb/widgets/confirmdialog.dart';
import 'package:btb/widgets/productclass.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const UserProfile(Usr_detail: {},));
}

class UserProfile extends StatefulWidget {
  final Map<String, dynamic>? Usr_detail;
  const UserProfile({this.Usr_detail,
    super.key,
  });

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile>  with SingleTickerProviderStateMixin{
  bool isHomeSelected = false;
  final ScrollController _scrollController = ScrollController();
  Timer? _searchDebounceTimer;
  String _searchText = '';
  DateTime? _selectedDate;
  late TextEditingController _dateController;
  int startIndex = 0;
  bool _hasShownPopup = false;
  List<Product> filteredProducts = [];
  String status = '';
  String selectDate = '';
  bool isEditing = false;
  String deliverystatus = '';
  late AnimationController _controller;
  final ScrollController horizontalScroll = ScrollController();
  late Animation<double> _shakeAnimation;
  bool _isHovered1 = false;
  bool _isHovered2 = false;
  bool orderhover = false;
  Map<String, dynamic> PaymentMap = {};
  String? dropdownValue1 = 'Delivery Status';
  String searchQuery = '';
  String token = window.sessionStorage["token"] ?? " ";

  String userId = window.sessionStorage['userId'] ?? '';
  TextEditingController email = TextEditingController();
  TextEditingController userName = TextEditingController();
  TextEditingController roleController = TextEditingController();
  TextEditingController companyName = TextEditingController();
  TextEditingController mobileNumber = TextEditingController();
  TextEditingController location = TextEditingController();
  TextEditingController userRole = TextEditingController();


  TextEditingController shipadr1 = TextEditingController();
  TextEditingController shipadr2 = TextEditingController();
  String? dropdownValue2 = 'Select Year';
  String userName1 = '';
  String companyName1 = '';
  String email1 = '';
  String number = '';
  String location1 = '';
  String role = '';
  String shippingAddress1 = '';
  String shippingAddress2 = '';
  // late Future<DashboardCounts?> futureDashboardCounts;
  //Naveen code
  int currentPage = 1;
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
  int itemsPerPage = 10;
  int totalItems = 0;
  int totalPages = 0;
  bool isLoading = false;
  bool _loading = false;

  List<String> _sortOrder = List.generate(6, (index) => 'asc');
  List<String> columns = [
    'Order ID',
    'Created Date',
    'Delivery Date',
    'Total Amount',
    'Delivery Status',
    'Payment'
  ];
  List<double> columnWidths = [100, 130, 130, 139, 150, 135,];
  List<bool> columnSortState = [true, true, true, true, true, true];

  Product? product1;




  @override
  void initState() {
    super.initState();
    if(widget.Usr_detail!['text']=='testing'){
      mobileNumber.text = widget.Usr_detail!['Number'];
      location.text =widget.Usr_detail!['Billing'];
      email.text =widget.Usr_detail!['Email'];
      userName.text=widget.Usr_detail!['Name'];
      companyName.text= widget.Usr_detail!['CompanyName'];
      userRole.text = widget.Usr_detail!['Role'];
    }
    else{
      fetchUserDetails();
    }
    //fetchOrders();



  }


  Future<void> fetchUserDetails() async {
    try {
      final response = await http.get(
        Uri.parse('$apicall/email/get_all_user_master'),
        headers: {
          'Authorization': 'Bearer $token',
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

      }else{
        if (response.statusCode == 200) {
          final List<dynamic> users = json.decode(response.body);

          final matchedUser = users.firstWhere(
                (user) => user['userId'] == userId,
            orElse: () => null,
          );

          if (matchedUser != null) {
            setState(() {
              userName1 = matchedUser['userName'] ?? '';
              email1 = matchedUser['email'] ?? '';
              companyName1 = matchedUser['companyName'] ?? '';
              location1 = matchedUser['location'] ?? '';
              number = matchedUser['mobileNumber'] ?? '';
              role = matchedUser['role']?? '';
              shippingAddress1 =matchedUser['shippingAddress1']??'';
              shippingAddress2 =matchedUser['shippingAddress2']??'';
              //roleController.text = matchedUser['role'] ?? '';

              userName.text = userName1;
              email.text = email1;
              companyName.text = companyName1;
              location.text = location1;
              mobileNumber.text = number;
              shipadr1.text =shippingAddress1;
              shipadr2.text =shippingAddress2;
              userRole.text = role;
              //  roleController.text = matchedUser['role'] ?? '';
              isLoading = false;
            });
          } else {
            print('User not found');
          }
        } else {
          print('Failed to fetch data: ${response.statusCode}');
        }
      }


    } catch (error) {
      print('An error occurred: $error');
    }
  }

  void showError(String message) {
    setState(() {
      isLoading = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
  Future<void> userUpdate(BuildContext context) async {
    String url = "$apicall/user/edit-usermaster";
    Map<String, dynamic> data = {
      "active": true,
      "userId": userId,
      "companyName": companyName.text,
      "email": email.text,
      "location": location.text,
      "mobileNumber": mobileNumber.text,
      "role": userRole.text,
      "userName": userName.text,
      "shippingAddress1": shipadr1.text,
      "shippingAddress2":shipadr2.text,
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
      if(token == " ")
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
                        context.go('/Cus_Create_Order', extra: {'testing':'test'});
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


  @override
  void dispose() {
    _searchDebounceTimer
        ?.cancel();
    _controller.dispose();// Cancel the timer when the widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home:
      Scaffold(
        backgroundColor: Colors.white,
        //extendBodyBehindAppBar: true,
        // backgroundColor:  Color(0xFFEAF6FB),
        appBar: AppBar(
          leading: null,
          // toolbarOpacity: 0.8,
          automaticallyImplyLeading: false,
          backgroundColor: const Color(0xFFFFFFFF),

          // backgroundColor: const Color(0xffeeeeee),
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
              // Align(
              //   alignment: Alignment.topLeft,
              //   child: Padding(
              //     padding: const EdgeInsets.only(right: 35),
              //     child: PopupMenuButton<String>(
              //       icon: const Icon(Icons.account_circle),
              //       onSelected: (value) {
              //         if (!_hasShownPopup) {
              //           _hasShownPopup = true;
              //           if (value == 'logout') {
              //             window.sessionStorage.remove('token');
              //             showConfirmationDialog(context);
              //             //context.go('/');
              //           }
              //         }
              //       },
              //       itemBuilder: (BuildContext context) {
              //         return [
              //           const PopupMenuItem<String>(
              //             value: 'logout',
              //             child: Text('Logout'),
              //           ),
              //         ];
              //       },
              //       offset: const Offset(0, 40), // Adjust the offset to display the menu below the icon
              //     ),
              //
              //   ),
              // ),
            ),
          ],
        ),
        body:
        LayoutBuilder(builder: (context, constraints) {
          double maxHeight = constraints.maxHeight;
          double maxWidth = constraints.maxWidth;
          return Stack(
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: Row(
                  children: [
                    Container(
                      width: 200,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF7F6FA),
                      ),
                      // color: const Color(0xFFF7F6FA),
                      padding: const EdgeInsets.only(left: 15, top: 10,right: 15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: _buildMenuItems(context),

                      ),

                    ),
                    const Spacer(),

                  ],
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
              if(constraints.maxWidth >= 1336)...{
                Padding(
                    padding:  EdgeInsets.only(left: maxHeight * 0.40,right: maxWidth * 0.05,top: maxHeight * 0.05,bottom: maxHeight * 0.01),
                    child: Container(
                      color: Colors.white,
                      child:  Padding(
                        padding:  EdgeInsets.only(left: maxHeight * 0.10,right: maxWidth * 0.05,top: maxHeight * 0.10,bottom: maxHeight * 0.1),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: Container(
                            width: maxWidth * 1.300,
                            height: maxHeight * 0.80,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.1),
                                  blurRadius: 10,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Profile Header
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      const CircleAvatar(
                                        radius: 30,
                                        backgroundColor: Colors.grey,
                                        child: Icon(
                                          Icons.person,
                                          size: 40,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(width: 20),
                                      Text(
                                        '${userId}',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                      const Spacer(),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.blue[800],
                                          padding: const EdgeInsets.symmetric(horizontal: 20),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(5),
                                          ),
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            isEditing = !isEditing;
                                          });
                                        },
                                        child: const Text('Edit',style: TextStyle(color: Colors.white),),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 30),

                                  // Profile Details
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Column 1
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'User Name',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.black,
                                              ),
                                            ),
                                            const SizedBox(height: 10),
                                            SizedBox(
                                              height: 40,
                                              width: 180,
                                              child: TextFormField(
                                                enabled: isEditing,
                                                controller: userName,
                                                decoration:  InputDecoration(
                                                  hintText: 'User Name',

                                                  border: const OutlineInputBorder(),
                                                  hintStyle:  TextStyle(fontSize: 15,),
                                                  contentPadding: const EdgeInsets.symmetric(horizontal: 8,),
                                                  fillColor: Colors.grey[200],
                                                  enabledBorder: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(5.0),
                                                    borderSide: const BorderSide(color: Colors.grey), // Added blue border
                                                  ),
                                                  focusedBorder: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(5.0),
                                                    borderSide: const BorderSide(color: Colors.blue), // Added blue border
                                                  ),
                                                ),
                                                inputFormatters: [
                                                  FilteringTextInputFormatter
                                                      .digitsOnly,
                                                  // Allows only digits
                                                  LengthLimitingTextInputFormatter(
                                                      10),
                                                  // Limits input to 10 characters
                                                ],
                                                maxLines: 1,
                                                minLines: 1,
                                                style:  TextStyle(
                                                  fontSize: 16,
                                                  color:  isEditing? Colors.black : Colors.grey,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 20),
                                            const Text(
                                              'Billing Address',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.black,
                                              ),
                                            ),
                                            SizedBox(height: 10),
                                            SizedBox(
                                              height: 100,
                                              width: 250,
                                              child: TextFormField(
                                                enabled: isEditing,
                                                controller: location,
                                                decoration:  InputDecoration(
                                                  hintText: 'Billing Address',
                                                  border: const OutlineInputBorder(),
                                                  hintStyle: const TextStyle(fontSize: 15),
                                                  contentPadding: const EdgeInsets.symmetric(horizontal: 8,vertical: 8),
                                                  fillColor: Colors.grey[200],
                                                  enabledBorder: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(5.0),
                                                    borderSide: const BorderSide(color: Colors.grey), // Added blue border
                                                  ),
                                                  focusedBorder: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(5.0),
                                                    borderSide: const BorderSide(color: Colors.blue), // Added blue border
                                                  ),
                                                ),
                                                maxLines: null,
                                                minLines: 4,
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  color:  isEditing? Colors.black : Colors.grey,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      // Column 2
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Mobile Number',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.black,
                                              ),
                                            ),
                                            SizedBox(height: 10),
                                            SizedBox(
                                              height: 40,
                                              width: 250,
                                              child: TextFormField(
                                                enabled: isEditing,
                                                controller: mobileNumber,
                                                decoration:  InputDecoration(
                                                  hintText: 'Mobile Number',
                                                  border: const OutlineInputBorder(),
                                                  hintStyle: const TextStyle(fontSize: 15),
                                                  contentPadding: const EdgeInsets.symmetric(horizontal: 8,),
                                                  fillColor: Colors.grey[200],
                                                  enabledBorder: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(5.0),
                                                    borderSide: const BorderSide(color: Colors.grey), // Added blue border
                                                  ),
                                                  focusedBorder: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(5.0),
                                                    borderSide: const BorderSide(color: Colors.blue), // Added blue border
                                                  ),
                                                ),
                                                maxLines: 1,
                                                minLines: 1,
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  color:  isEditing? Colors.black : Colors.grey,
                                                ),
                                              ),
                                            ),
                                            SizedBox(height: 20),
                                            const Text(
                                              'Shipping Address 1',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.black,
                                              ),
                                            ),
                                            SizedBox(height: 10),
                                            SizedBox(
                                              height: 100,
                                              width: 250,
                                              child: TextFormField(
                                                enabled: isEditing,
                                                controller: shipadr1,
                                                decoration:  InputDecoration(
                                                  hintText: 'Shipping Address 1',
                                                  border: const OutlineInputBorder(),
                                                  hintStyle: const TextStyle(fontSize: 15),
                                                  contentPadding: const EdgeInsets.symmetric(horizontal: 8,vertical: 8),
                                                  fillColor: Colors.grey[200],
                                                  enabledBorder: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(5.0),
                                                    borderSide: const BorderSide(color: Colors.grey), // Added blue border
                                                  ),
                                                  focusedBorder: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(5.0),
                                                    borderSide: const BorderSide(color: Colors.blue), // Added blue border
                                                  ),
                                                ),
                                                maxLines: null,
                                                minLines: 4,
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  color:  isEditing? Colors.black : Colors.grey,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      // Column 3
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Email',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.black,
                                              ),
                                            ),
                                            SizedBox(height: 10),
                                            SizedBox(
                                              height: 40,
                                              width: 250,
                                              child: TextFormField(
                                                enabled: isEditing,
                                                controller: email,
                                                decoration:  InputDecoration(
                                                  hintText: 'Email ID',
                                                  border: const OutlineInputBorder(),
                                                  hintStyle: const TextStyle(fontSize: 15),
                                                  contentPadding: const EdgeInsets.symmetric(horizontal: 8,),
                                                  fillColor: Colors.grey[200],
                                                  enabledBorder: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(5.0),
                                                    borderSide: const BorderSide(color: Colors.grey), // Added blue border
                                                  ),
                                                  focusedBorder: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(5.0),
                                                    borderSide: const BorderSide(color: Colors.blue), // Added blue border
                                                  ),
                                                ),
                                                inputFormatters: [
                                                  FilteringTextInputFormatter
                                                      .allow(RegExp(
                                                      r'[a-z0-9@._]')),
                                                ],
                                                maxLines: 1,
                                                minLines: 1,
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  color: isEditing? Colors.black : Colors.grey,
                                                ),
                                              ),
                                            ),
                                            SizedBox(height: 20,),
                                            const Text(
                                              'Shipping Address 2',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.black,
                                              ),
                                            ),
                                            SizedBox(height: 10),
                                            SizedBox(
                                              height: 100,
                                              width: 250,
                                              child: TextFormField(
                                                enabled: isEditing,
                                                controller: shipadr2,
                                                decoration:  InputDecoration(
                                                  hintText: 'Shipping Address 2',
                                                  border: const OutlineInputBorder(),
                                                  hintStyle: const TextStyle(fontSize: 15),
                                                  contentPadding: const EdgeInsets.symmetric(horizontal: 8,vertical: 8),
                                                  fillColor: Colors.grey[200],
                                                  enabledBorder: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(5.0),
                                                    borderSide: const BorderSide(color: Colors.grey), // Added blue border
                                                  ),
                                                  focusedBorder: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(5.0),
                                                    borderSide: const BorderSide(color: Colors.blue), // Added blue border
                                                  ),
                                                ),
                                                maxLines: null,
                                                minLines:4,
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  color:  isEditing? Colors.black : Colors.grey,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height:38),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.blue[800],
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 30, vertical: 15),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(5),
                                          ),
                                        ),
                                        onPressed: () {
                                          userUpdate(context);
                                          // Save action
                                        },
                                        child: const Text('Save',style: TextStyle(color: Colors.white),),
                                      ),
                                      const SizedBox(width: 20),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.grey[300],
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 30, vertical: 15),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(5),
                                          ),
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            userName.text = userName1;
                                            email.text = email1;
                                            companyName.text = companyName1;
                                            location.text = location1;
                                            mobileNumber.text = number;
                                            shipadr1.text =shippingAddress1;
                                            shipadr2.text =shippingAddress2;
                                          });
                                        },
                                        child: const Text('Cancel',style: TextStyle(color: Colors.white),),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                )
              }else...{
                Padding(
                  padding: const EdgeInsets.only(left: 300,right: 100,top: 100,bottom: 100),
                  child: AdaptiveScrollbar(
                    position: ScrollbarPosition.bottom,
                    controller: horizontalScroll,
                    child: SingleChildScrollView(
                      controller: horizontalScroll,
                      scrollDirection: Axis.horizontal,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: Container(
                          height: 450,width: 1200,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                blurRadius: 10,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child:  Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Profile Header
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const CircleAvatar(
                                      radius: 30,
                                      backgroundColor: Colors.grey,
                                      child: Icon(
                                        Icons.person,
                                        size: 40,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(width: 20),
                                    Text(
                                      '${userId}',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                    const Spacer(),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blue[800],
                                        padding: const EdgeInsets.symmetric(horizontal: 20),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(5),
                                        ),
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          isEditing = !isEditing;
                                        });
                                      },
                                      child: const Text('Edit',style: TextStyle(color: Colors.white),),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 30),

                                // Profile Details
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Column 1
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'User Name',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.black,
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          SizedBox(
                                            height: 40,
                                            width: 180,
                                            child: TextFormField(
                                              enabled: isEditing,
                                              controller: userName,
                                              decoration:  InputDecoration(
                                                hintText: 'User Name',

                                                border: const OutlineInputBorder(),
                                                hintStyle:  TextStyle(fontSize: 15,),
                                                contentPadding: const EdgeInsets.symmetric(horizontal: 8,),
                                                fillColor: Colors.grey[200],
                                                enabledBorder: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(5.0),
                                                  borderSide: const BorderSide(color: Colors.grey), // Added blue border
                                                ),
                                                focusedBorder: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(5.0),
                                                  borderSide: const BorderSide(color: Colors.blue), // Added blue border
                                                ),
                                              ),
                                              inputFormatters: [
                                                FilteringTextInputFormatter
                                                    .digitsOnly,
                                                // Allows only digits
                                                LengthLimitingTextInputFormatter(
                                                    10),
                                                // Limits input to 10 characters
                                              ],
                                              maxLines: 1,
                                              minLines: 1,
                                              style:  TextStyle(
                                                fontSize: 16,
                                                color:  isEditing? Colors.black : Colors.grey,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 20),
                                          const Text(
                                            'Billing Address',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.black,
                                            ),
                                          ),
                                          SizedBox(height: 10),
                                          SizedBox(
                                            height: 100,
                                            width: 250,
                                            child: TextFormField(
                                              enabled: isEditing,
                                              controller: location,
                                              decoration:  InputDecoration(
                                                hintText: 'Billing Address',
                                                border: const OutlineInputBorder(),
                                                hintStyle: const TextStyle(fontSize: 15),
                                                contentPadding: const EdgeInsets.symmetric(horizontal: 8,vertical: 8),
                                                fillColor: Colors.grey[200],
                                                enabledBorder: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(5.0),
                                                  borderSide: const BorderSide(color: Colors.grey), // Added blue border
                                                ),
                                                focusedBorder: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(5.0),
                                                  borderSide: const BorderSide(color: Colors.blue), // Added blue border
                                                ),
                                              ),
                                              maxLines: null,
                                              minLines: 4,
                                              style: TextStyle(
                                                fontSize: 16,
                                                color:  isEditing? Colors.black : Colors.grey,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Column 2
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Mobile Number',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          SizedBox(height: 10),
                                          SizedBox(
                                            height: 40,
                                            width: 250,
                                            child: TextFormField(
                                              enabled: isEditing,
                                              controller: mobileNumber,
                                              decoration:  InputDecoration(
                                                hintText: 'Mobile Number',
                                                border: const OutlineInputBorder(),
                                                hintStyle: const TextStyle(fontSize: 15),
                                                contentPadding: const EdgeInsets.symmetric(horizontal: 8,),
                                                fillColor: Colors.grey[200],
                                                enabledBorder: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(5.0),
                                                  borderSide: const BorderSide(color: Colors.grey), // Added blue border
                                                ),
                                                focusedBorder: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(5.0),
                                                  borderSide: const BorderSide(color: Colors.blue), // Added blue border
                                                ),
                                              ),
                                              maxLines: 1,
                                              minLines: 1,
                                              style: TextStyle(
                                                fontSize: 16,
                                                color:  isEditing? Colors.black : Colors.grey,
                                              ),
                                            ),
                                          ),
                                          SizedBox(height: 20),
                                          const Text(
                                            'Shipping Address 1',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.black,
                                            ),
                                          ),
                                          SizedBox(height: 10),
                                          SizedBox(
                                            height: 100,
                                            width: 250,
                                            child: TextFormField(
                                              enabled: isEditing,
                                              controller: shipadr1,
                                              decoration:  InputDecoration(
                                                hintText: 'Shipping Address 1',
                                                border: const OutlineInputBorder(),
                                                hintStyle: const TextStyle(fontSize: 15),
                                                contentPadding: const EdgeInsets.symmetric(horizontal: 8,vertical: 8),
                                                fillColor: Colors.grey[200],
                                                enabledBorder: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(5.0),
                                                  borderSide: const BorderSide(color: Colors.grey), // Added blue border
                                                ),
                                                focusedBorder: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(5.0),
                                                  borderSide: const BorderSide(color: Colors.blue), // Added blue border
                                                ),
                                              ),
                                              maxLines: null,
                                              minLines: 4,
                                              style: TextStyle(
                                                fontSize: 16,
                                                color:  isEditing? Colors.black : Colors.grey,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Column 3
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Email',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.black,
                                            ),
                                          ),
                                          SizedBox(height: 10),
                                          SizedBox(
                                            height: 40,
                                            width: 250,
                                            child: TextFormField(
                                              enabled: isEditing,
                                              controller: email,
                                              decoration:  InputDecoration(
                                                hintText: 'Email ID',
                                                border: const OutlineInputBorder(),
                                                hintStyle: const TextStyle(fontSize: 15),
                                                contentPadding: const EdgeInsets.symmetric(horizontal: 8,),
                                                fillColor: Colors.grey[200],
                                                enabledBorder: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(5.0),
                                                  borderSide: const BorderSide(color: Colors.grey), // Added blue border
                                                ),
                                                focusedBorder: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(5.0),
                                                  borderSide: const BorderSide(color: Colors.blue), // Added blue border
                                                ),
                                              ),
                                              inputFormatters: [
                                                FilteringTextInputFormatter
                                                    .allow(RegExp(
                                                    r'[a-z0-9@._]')),
                                              ],
                                              maxLines: 1,
                                              minLines: 1,
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: isEditing? Colors.black : Colors.grey,
                                              ),
                                            ),
                                          ),
                                          SizedBox(height: 20,),
                                          const Text(
                                            'Shipping Address 2',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.black,
                                            ),
                                          ),
                                          SizedBox(height: 10),
                                          SizedBox(
                                            height: 100,
                                            width: 250,
                                            child: TextFormField(
                                              enabled: isEditing,
                                              controller: shipadr2,
                                              decoration:  InputDecoration(
                                                hintText: 'Shipping Address 2',
                                                border: const OutlineInputBorder(),
                                                hintStyle: const TextStyle(fontSize: 15),
                                                contentPadding: const EdgeInsets.symmetric(horizontal: 8,vertical: 8),
                                                fillColor: Colors.grey[200],
                                                enabledBorder: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(5.0),
                                                  borderSide: const BorderSide(color: Colors.grey), // Added blue border
                                                ),
                                                focusedBorder: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(5.0),
                                                  borderSide: const BorderSide(color: Colors.blue), // Added blue border
                                                ),
                                              ),
                                              maxLines: null,
                                              minLines:4,
                                              style: TextStyle(
                                                fontSize: 16,
                                                color:  isEditing? Colors.black : Colors.grey,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height:38),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blue[800],
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 30, vertical: 15),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(5),
                                        ),
                                      ),
                                      onPressed: () {
                                        userUpdate(context);
                                        // Save action
                                      },
                                      child: const Text('Save',style: TextStyle(color: Colors.white),),
                                    ),
                                    const SizedBox(width: 20),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.grey[300],
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 30, vertical: 15),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(5),
                                        ),
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          userName.text = userName1;
                                          email.text = email1;
                                          companyName.text = companyName1;
                                          location.text = location1;
                                          mobileNumber.text = number;
                                          shipadr1.text =shippingAddress1;
                                          shipadr2.text =shippingAddress2;
                                        });
                                      },
                                      child: const Text('Cancel',style: TextStyle(color: Colors.white),),
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
              }

            ],
          );
        }),
      ),
    );
  }




  List<Widget> _buildMenuItems(BuildContext context) {
    return [
      Column(
        children:  [
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
              ),child: _buildMenuItem('Home', Icons.home_outlined, Colors.blue[900]!, '/Cus_Home')),
          _buildMenuItem('Orders', Icons.warehouse_outlined, Colors.blue[900]!, '/Customer_Order_List'),
          _buildMenuItem('Delivery', Icons.fire_truck_outlined, Colors.white, '/Customer_Delivery_List'),
          _buildMenuItem('Invoice', Icons.document_scanner_outlined, Colors.blue[900]!, '/Customer_Invoice_List'),

          _buildMenuItem('Payment', Icons.payment_rounded, Colors.blue[900]!, '/Customer_Payment_List'),
          _buildMenuItem('Return', Icons.keyboard_return, Colors.blue[900]!, '/Customer_Return_List'),
        ],
      ),
    ];
  }

  Widget _buildMenuItem(String title, IconData icon, Color iconColor, String route) {
    iconColor = _isHovered[title] == true ? Colors.blue : Colors.black87;
    title == 'Home'? _isHovered[title] = false :  _isHovered[title] = false;
    title == 'Home'? iconColor = Colors.white : Colors.black;
    return
      MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _isHovered[title] = true,),
        onExit: (_) => setState(() => _isHovered[title] = false),
        child: GestureDetector(
          onTap: () {
            context.go(route);
          },
          child:

          Container(
            margin: const EdgeInsets.only(bottom:5,right: 20),
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: _isHovered[title]! ? Colors.black12 : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Padding(
              padding: const EdgeInsets.only(left: 5,top: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
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
}


