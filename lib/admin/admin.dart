import 'dart:async';
import 'dart:convert';
import 'dart:html';
import 'dart:math' as math;
import 'package:adaptive_scrollbar/adaptive_scrollbar.dart';
import 'package:btb/admin/Api%20name.dart';
import 'package:btb/widgets/productclass.dart';
import 'package:btb/widgets/custom%20loading.dart';
import 'package:btb/widgets/pagination.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:btb/widgets/productclass.dart' as ord;
import 'package:btb/Order%20Module/firstpage.dart' as ors;
import '../dashboard/dashboard.dart';
import '../widgets/confirmdialog.dart';
import '../widgets/no datafound.dart';
import '../widgets/text_style.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: AdminList1(),
  ));
}

class AdminList1 extends StatefulWidget {
  const AdminList1({
    super.key,
  });

  @override
  State<AdminList1> createState() => _AdminList1State();
}

class _AdminList1State extends State<AdminList1> {
  String _Role = '';
  bool _hasShownPopup = false;
  bool isHomeSelected = false;
  final ScrollController _scrollController = ScrollController();
  Timer? _searchDebounceTimer;
  String _searchText = '';
  final ScrollController horizontalScroll = ScrollController();
  String _searchText1 = '';
  DashboardCounts? _dashboardCounts;
  DateTime? _selectedDate;
  late TextEditingController _dateController;
  int startIndex = 0;
  late Future<List<Dashboard1>> futureOrders;
  List<Product> filteredProducts = [];
  String status = '';
  String selectDate = '';
  String deliverystatus = '';
  Map<String, dynamic> PaymentMap = {};
  String? dropdownValue1 = 'Delivery Status';
  String searchQuery = '';
  String token = window.sessionStorage["token"] ?? " ";
  String? dropdownValue2 = 'Role';
  int currentPage = 1;
  ord.Product? _selectedProduct;
  int itemsPerPage = 10;
  int totalItems = 0;
  int totalPages = 0;
  bool isLoading = false;
  List<UserResponse> filteredData1 = [];
  List<ors.detail> filteredData = [];
  List<UserResponse> productList = [];

  List<String> _sortOrder = List.generate(6, (index) => 'asc');
  List<String> columns = [
    'User ID',
    'User Name',
    'Role',
    'Company Name',
    'Location',
    'Active',
    ' ',
  ];
  List<double> columnWidths = [
    110,
    120,
    90,
    139,
    145,
    110,
    30,
  ];

  Future<void> deleteRowAPI(String TypeId) async {
    try {
      String apiUri = '$apicall/user/delete_usermaster_by_id/$TypeId';

      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      };

      final http.Response response = await http.delete(
        Uri.parse(apiUri),
        headers: headers,
      );
      // if(token == " "){
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
      //  else{
      if (response.statusCode == 200) {
        Navigator.pop(context);
        fetchProducts(currentPage, itemsPerPage);
      } else {
        print('Failed to delete customer: ${response.statusCode}');
        //}
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  // List<bool> columnSortState = [true, true, true, true, true, true];
  // Product? product1;

  Future<void> fetchProducts(int page, int itemsPerPage) async {
    if (isLoading) return;
    if (!mounted) return;
    setState(() {
      isLoading = true;
    });
    try {
      final response = await http.get(
        Uri.parse(
          '$apicall/email/get_all_user_master?page=$page&limit=$itemsPerPage', // Changed limit to 10
        ),
        headers: {
          "Content-type": "application/json",
          "Authorization": 'Bearer $token',
        },
      );
      // if(token == " "){
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
      // }else{
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        List<UserResponse> products = [];
        if (jsonData is List) {
          products =
              jsonData.map((item) => UserResponse.fromJson(item)).toList();
        } else if (jsonData is Map && jsonData.containsKey('body')) {
          final body = jsonData['body'];
          if (body != null) {
            products = (body as List)
                .map((item) => UserResponse.fromJson(item))
                .toList();
            totalItems =
                jsonData['totalItems'] ?? 0; // Get the total number of items
          } else {}
        } else {}

        if (mounted) {
          setState(() {
            totalPages = (products.length / itemsPerPage).ceil();
            productList = products;
            _filterAndPaginateProducts();
          });
        }
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      if (mounted) {
        if (context.findAncestorWidgetOfExactType<Scaffold>() != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        } else {}
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void _updateSearch(String searchText) {
    setState(() {
      _searchText = searchText;
      currentPage = 1; // Reset to first page when searching
      _filterAndPaginateProducts();
      // _clearSearch();
    });
  }

  void _goToPreviousPage() {
    if (currentPage > 1) {
      if (filteredData1.length > itemsPerPage) {
        setState(() {
          currentPage--;
        });
      }
    }
  }

  void _goToNextPage() {
    if (currentPage < totalPages) {
      if (filteredData1.length > currentPage * itemsPerPage) {
        setState(() {
          currentPage++;
        });
      }
    }
  }

  Future<void> updateRequestStatus(String userId, String status) async {
    bool? isActive = (status == 'Active')
        ? true
        : (status == 'In Active')
            ? false
            : null;
    //  bool isActive = status == 'Active';

    //  String status = 'false';
    final String apiUrl =
        '$apicall/user_master/update_user_status/$userId/$isActive';
    try {
      final response = await http.put(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
      );
      // if(token == " "){
      //
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
        if (status == 'Completed') {
          // _getCustomers(currentPage, itemsPerPage);
        }
      } else {}
    } catch (e) {
      print('Error: $e');
    }
  }

  void _filterAndPaginateProducts() {
    filteredData1 = productList.where((product) {
      final matchesSearchText = product.userId
              .toLowerCase()
              .contains(_searchText.toLowerCase()) ||
          product.userName.toLowerCase().contains(_searchText.toLowerCase());
      if (_Role.isEmpty) {
        return matchesSearchText;
      }
      if (_Role == 'Role') {
        return matchesSearchText;
      }
      if (_Role.isNotEmpty) {
        return matchesSearchText && product.role == _Role;
      }

      return matchesSearchText && product.role == _Role;
    }).toList();
    setState(() {
      currentPage = 1;
    });
  }

  @override
  void initState() {
    super.initState();
    _dateController = TextEditingController();
    _selectedDate = DateTime.now();
    String formattedDate = DateFormat('dd/MM/yyyy').format(_selectedDate!);
    _dateController.text = formattedDate;
    fetchProducts(currentPage, itemsPerPage);
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
          backgroundColor: Colors.grey[50],
          // appBar: AppBar(
          //   leading: null,
          //   automaticallyImplyLeading: false,
          //   backgroundColor: const Color(0xFFFFFFFF),
          //   title: Image.asset("images/Final-Ikyam-Logo.png"),
          //   // Set background color to white
          //   elevation: 2.0,
          //   shadowColor: const Color(0xFFFFFFFF),
          //   // Set shadow color to black
          //   actions: [
          //     Padding(
          //       padding: const EdgeInsets.only(top: 10),
          //       child: Align(
          //         alignment: Alignment.topLeft,
          //         child: IconButton(
          //           icon: const Icon(Icons.notifications),
          //           onPressed: () {
          //             // Handle notification icon press
          //           },
          //         ),
          //       ),
          //     ),
          //     const SizedBox(
          //       width: 10,
          //     ),
          //     Padding(
          //       padding: const EdgeInsets.only(top: 10),
          //       child: AccountMenu(),
          //     ),
          //   ],
          // ),
          body: LayoutBuilder(builder: (context, BoxConstraints constraints) {
            double maxWidth = constraints.maxWidth;
            double maxHeight = constraints.maxHeight;
            return Stack(
              children: [
                Container(
                  width: maxWidth,
                  height: 60.0,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        bottom: BorderSide(
                          color: Color(0x29000000), // Bottom border color
                          width: 3.0, // Thickness of the bottom border
                        ),
                      )),
                  // White background color
                  //height: 62.0, // Total height including bottom shadow
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        // crossAxisAlignment:CrossAxisAlignment.center,
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
                                padding:
                                    const EdgeInsets.only(right: 10, top: 10),
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
                    top: 60,
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: SingleChildScrollView(
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Padding(
                          padding: EdgeInsets.only(top: 0),
                          child: Container(
                            height: 1400,
                            padding: const EdgeInsets.only(
                                left: 15, top: 10, right: 15),
                            width: 200,
                            color: Colors.white,
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
                    color: Color(0x29000000),
                  ),
                } else ...{
                  Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: EdgeInsets.only(top: 62),
                      child: Container(
                        height: maxHeight,
                        padding:
                            const EdgeInsets.only(left: 15, top: 10, right: 15),
                        width: 200,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border(
                              left: BorderSide(
                                color: Color(0x29000000),
                                // Bottom border color
                                width: 1.0, // Thickness of the bottom border
                              ),
                            )),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: _buildMenuItems(context, constraints),
                        ),
                      ),
                    ),
                  ),
                  VerticalDividerWidget(
                    height: maxHeight,
                    color: Color(0x29000000),
                  ),
                },
                Positioned(
                  left: 201,
                  top: 62,
                  right: 0,
                  bottom: 0,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (constraints.maxWidth >= 1320) ...{
                        Expanded(
                            child: SingleChildScrollView(
                          child: Column(
                            children: [
                              SizedBox(height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 69, top: 10),
                                    child: Text(
                                      'User Management',
                                      style: TextStyles.heading,
                                    ),
                                  ),
                                  Spacer(),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        right: 50, top: 10),
                                    child: OutlinedButton(
                                      style: OutlinedButton.styleFrom(
                                        backgroundColor: Colors.blue[800],
                                        // Button background color
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              5), // Rounded corners
                                        ),
                                        side: BorderSide.none, // No outline
                                      ),
                                      onPressed: () {
                                        context.go('/Create_User');
                                      },
                                      child: Text(
                                        'New User',
                                        style: TextStyles.button,
                                      ), // add your button press logic here
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Padding(
                                      padding: const EdgeInsets.only(
                                          left: 30,
                                          top: 20,
                                          right: 30,
                                          bottom: 15),
                                      child: Container(
                                        height: 755,
                                        width: maxWidth * 0.8,
                                        decoration: BoxDecoration(
                                          //   border: Border.all(color: Colors.grey),
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(2),
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.grey.withOpacity(0.1),
                                              // Soft grey shadow
                                              spreadRadius: 3,
                                              blurRadius: 3,
                                              offset: const Offset(0, 3),
                                            ),
                                          ],
                                        ),
                                        child: SizedBox(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              buildSearchField1(),
                                              const SizedBox(height: 10),
                                              Expanded(
                                                child: Scrollbar(
                                                  controller: _scrollController,
                                                  thickness: 6,
                                                  thumbVisibility: true,
                                                  child: SingleChildScrollView(
                                                    controller:
                                                        _scrollController,
                                                    scrollDirection:
                                                        Axis.horizontal,
                                                    child: buildDataTable1(),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(
                                                height: 1,
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    right: 30),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  children: [
                                                    PaginationControls(
                                                      currentPage: currentPage,
                                                      totalPages:
                                                          filteredData1.length >
                                                                  itemsPerPage
                                                              ? totalPages
                                                              : 1,
                                                      onPreviousPage:
                                                          _goToPreviousPage,
                                                      onNextPage: _goToNextPage,
                                                      // onLastPage: _goToLastPage,
                                                    ),
                                                  ],
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      )),
                                ],
                              ),
                            ],
                          ),
                        )),
                      } else ...{
                        Expanded(
                            child: AdaptiveScrollbar(
                          position: ScrollbarPosition.bottom,
                          controller: horizontalScroll,
                          child: SingleChildScrollView(
                            controller: horizontalScroll,
                            scrollDirection: Axis.horizontal,
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  SizedBox(height: 20),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(left: 75, top: 10),
                                        child: Text(
                                          'User Management',
                                          style: TextStyles.heading,
                                        ),
                                      ),

                                      Padding(
                                        padding: const EdgeInsets.only(left: 795, top: 10,right: 55),
                                        child: OutlinedButton(
                                          style: OutlinedButton.styleFrom(
                                            backgroundColor: Colors.blue[800],
                                            // Button background color
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(
                                                  5), // Rounded corners
                                            ),
                                            side: BorderSide.none, // No outline
                                          ),
                                          onPressed: () {
                                            context.go('/Create_User');
                                          },
                                          child:  Text(
                                            'New User',
                                            style: TextStyles.button,
                                          ), // add your button press logic here
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Padding(
                                          padding: const EdgeInsets.only(
                                              left: 30,
                                              top: 20,
                                              right: 30,
                                              bottom: 15),
                                          child: Container(
                                            height: 755,
                                            width: 1100,
                                            decoration: BoxDecoration(
                                              //   border: Border.all(color: Colors.grey),
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(2),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.grey.withOpacity(0.1),
                                                  // Soft grey shadow
                                                  spreadRadius: 3,
                                                  blurRadius: 3,
                                                  offset: const Offset(0, 3),
                                                ),
                                              ],
                                            ),
                                            child: SizedBox(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  buildSearchField1(),
                                                  const SizedBox(height: 10),
                                                  Expanded(
                                                    child: Scrollbar(
                                                      controller:
                                                          _scrollController,
                                                      thickness: 6,
                                                      thumbVisibility: true,
                                                      child:
                                                          SingleChildScrollView(
                                                        controller:
                                                            _scrollController,
                                                        scrollDirection:
                                                            Axis.horizontal,
                                                        child:
                                                            buildDataTable2(),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    height: 1,
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            right: 30),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment.end,
                                                      children: [
                                                        PaginationControls(
                                                          currentPage:
                                                              currentPage,
                                                          totalPages: filteredData1
                                                                      .length >
                                                                  itemsPerPage
                                                              ? totalPages
                                                              : 1,
                                                          onPreviousPage:
                                                              _goToPreviousPage,
                                                          onNextPage:
                                                              _goToNextPage,
                                                          // onLastPage: _goToLastPage,
                                                        ),
                                                      ],
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          )),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )),
                      }
                    ],
                  ),
                )
              ],
            );
          })),
    );
  }

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
                //width: maxWidth * 0.11,
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

  Widget buildSearchField1() {
    double maxWidth1 = MediaQuery.of(context).size.width;
    return LayoutBuilder(builder: (context, constraints) {
      return ConstrainedBox(
        constraints: const BoxConstraints(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 15, left: 20),
                  child: Container(
                    width: maxWidth1 * 0.2, // reduced width
                    height: 30, // reduced height
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(3),
                      border: Border.all(color: Colors.grey.shade400),
                    ),
                    child: TextFormField(
                      // style:
                      //     GoogleFonts.inter(color: Colors.black, fontSize: 13),
                      decoration: InputDecoration(
                          hintText: 'Search by User ID and User Name',
                          hintStyle: TextStyles.body1,
                          contentPadding: EdgeInsets.symmetric(vertical: 8,horizontal: 5),
                          // adjusted padding
                          border: InputBorder.none,
                          suffixIcon: Padding(
                            padding: const EdgeInsets.only(left: 10, right: 5),
                            // Adjust image padding
                            child: Image.asset(
                              'images/search.png', // Replace with your image asset path
                            ),
                          )),
                      onChanged: _updateSearch,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //  const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: Container(
                        height: 30,
                        width: maxWidth1 * 0.2,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(2),
                          border: Border.all(color: Colors.grey.shade400),
                        ),
                        child: DropdownButtonFormField2<String>(
                          decoration: InputDecoration(
                            contentPadding:
                                EdgeInsets.only(bottom: 20, left: 2),
                            // adjusted padding
                            border: InputBorder.none,
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          //   icon: Container(),
                          value: dropdownValue2,
                          onChanged: (String? newValue) {
                            setState(() {
                              dropdownValue2 = newValue;
                              _Role = newValue ?? '';
                              _filterAndPaginateProducts();
                            });
                          },
                          items: <String>[
                            'Role',
                            'Admin',
                            'Employee',
                            'Customer',
                          ].map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value,
                                  style: GoogleFonts.jost(
                                      color: value == 'Role'
                                          ? Colors.grey
                                          : Colors.black,
                                      fontSize: 13)
                                  // TextStyle(
                                  //     color: value == 'Role'
                                  //         ? Colors.grey
                                  //         : Colors.black,
                                  //     fontSize: 12)
                                  ),
                            );
                          }).toList(),
                          isExpanded: true,
                          iconStyleData: const IconStyleData(
                            icon: Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: Colors.grey,
                              size: 16,
                            ),
                            iconSize: 16,
                          ),
                          buttonStyleData: const ButtonStyleData(
                            // overlayColor: C,
                            //focusColor: Color(0xFFF0F4F8),
                            height: 50, // Button height
                            padding: EdgeInsets.only(
                                left: 10, right: 10), // Button padding
                          ),
                          dropdownStyleData: DropdownStyleData(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(7),
                              // Rounded corners
                              color: Colors.white, // Dropdown background color
                            ),
                            maxHeight: 200,
                            width: constraints.maxWidth * 0.235,
                            // Dropdown width
                            offset: const Offset(0, -10),
                          ),
                          // focusColor: Color(0xFFF0F4F8),
                        ),
                      ),
                    ),
                  ],
                ),
                // const SizedBox(width: 16),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget buildDataTable2() {
    if (isLoading) {
      var width = MediaQuery.of(context).size.width;
      var height = MediaQuery.of(context).size.height;
      // Show loading indicator while data is being fetched
      return Padding(
        padding: EdgeInsets.only(
            top: height * 0.100, bottom: height * 0.100, left: width * 0.300),
        child: CustomLoadingIcon(), // Replace this with your custom GIF widget
      );
    }

    if (filteredData1.isEmpty) {
      double right = MediaQuery.of(context).size.width;
      return Column(
        children: [
          Container(
            width: 1100,
            // width: right * 0.78,
            decoration: const BoxDecoration(
                color: Color(0xFFF7F7F7),
                border: Border.symmetric(
                    horizontal: BorderSide(color: Colors.grey, width: 0.5))),
            child: DataTable(
                showCheckboxColumn: false,
                headingRowHeight: 40,
                columnSpacing: 50,
                columns: [
                  DataColumn(
                      label: Text(
                    'User ID',
                    style: TextStyles.subhead,
                  )),
                  DataColumn(
                      label: Text(
                    'User Name',
                        style: TextStyles.subhead,
                  )),
                  DataColumn(
                      label: Text(
                    'Role',
                        style: TextStyles.subhead,
                  )),
                  DataColumn(
                      label: Text(
                    'Company Name',
                        style: TextStyles.subhead,
                  )),
                  DataColumn(
                      label: Text(
                    'Location',
                        style: TextStyles.subhead,
                  )),
                  DataColumn(
                      label: Text(
                    'Active',
                        style: TextStyles.subhead,
                  )),
                ],
                rows: const []),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 80, left: 130, right: 150),
            child: CustomDatafound(),
          ),
        ],
      );
    }

    void sortProducts(int columnIndex, String sortDirection) {
      if (sortDirection == 'asc') {
        filteredData1.sort((a, b) {
          if (columnIndex == 0) {
            return a.userId.compareTo(b.userId);
          } else if (columnIndex == 1) {
            return a.userName.compareTo(b.userName);
          } else if (columnIndex == 2) {
            return a.role.compareTo(b.role);
          } else if (columnIndex == 3) {
            return a.companyName.compareTo(b.companyName!);
          } else if (columnIndex == 4) {
            return a.location.compareTo(b.location);
          } else {
            return 0;
          }
        });
      } else {
        filteredData1.sort((a, b) {
          if (columnIndex == 0) {
            return b.userId.compareTo(a.userId); // Reverse the comparison
          } else if (columnIndex == 1) {
            return b.userName.compareTo(a.userName); // Reverse the comparison
          } else if (columnIndex == 2) {
            return b.role.compareTo(a.role); // Reverse the comparison
          } else if (columnIndex == 3) {
            return b.companyName
                .compareTo(a.companyName); // Reverse the comparison
          } else if (columnIndex == 4) {
            return b.location.compareTo(a.location); // Reverse the comparison
          } else {
            return 0;
          }
        });
      }
      setState(() {});
    }

    return LayoutBuilder(builder: (context, constraints) {
      // double padding = constraints.maxWidth * 0.065;
      double right = MediaQuery.of(context).size.width;
      return Column(
        children: [
          Container(
            width: 1100,
            decoration: const BoxDecoration(
                color: Color(0xFFF7F7F7),
                border: Border.symmetric(
                    horizontal: BorderSide(color: Colors.grey, width: 0.5))),
            child: DataTable(
                showCheckboxColumn: false,
                headingRowHeight: 35,
                columnSpacing: 20,
                columns: columns.map((column) {
                  return  DataColumn(
                    label: Stack(
                      children: [
                        SizedBox(
                          //   padding: EdgeInsets.only(left: 5,right: 5),
                          width: columnWidths[columns.indexOf(column)],
                          // Dynamic width based on user interaction
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            //crossAxisAlignment: CrossAxisAlignment.end,
                            //   mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(column,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyles.subhead
                                // TextStyle(
                                //   fontWeight: FontWeight.bold,
                                //   color: Color.fromRGBO(0, 83, 176, 1),
                                //   fontSize: 13,
                                // ),
                              ),
                              if (columns.indexOf(column) < columns.length - 1)
                              // if (columns.indexOf(column) < 0)
                                IconButton(
                                  icon: _sortOrder[columns.indexOf(column)] ==
                                      'asc'
                                      ? SizedBox(
                                      width: 12,
                                      child: Image.asset(
                                        "images/ix_sort.png",
                                        color:
                                        Color.fromRGBO(0, 83, 176, 1),
                                      ))
                                      : SizedBox(
                                      width: 12,
                                      child: Image.asset(
                                        "images/ix_sort.png",
                                        color:
                                        Color.fromRGBO(0, 83, 176, 1),
                                      )),
                                  onPressed: () {
                                    setState(() {
                                      _sortOrder[columns.indexOf(column)] =
                                      _sortOrder[columns.indexOf(column)] ==
                                          'asc'
                                          ? 'desc'
                                          : 'asc';
                                      sortProducts(columns.indexOf(column),
                                          _sortOrder[columns.indexOf(column)]);
                                    });
                                  },
                                ),

                              // ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    onSort: (columnIndex, ascending) {
                      _sortOrder;
                    },
                  );
                }).toList(),
                rows: List.generate(
                    math.min(
                        itemsPerPage,
                        filteredData1.length -
                            (currentPage - 1) * itemsPerPage), (index) {
                  final detail = filteredData1
                      .skip((currentPage - 1) * itemsPerPage)
                      .elementAt(index);
                  final customerIndex =
                      (currentPage - 1) * itemsPerPage + index;
                  final isSelected = _selectedProduct == detail;
                  return DataRow(
                    color: MaterialStateProperty.resolveWith<Color>((states) {
                      if (states.contains(MaterialState.hovered)) {
                        return Colors.blue.shade500.withOpacity(
                            0.8); // Add some opacity to the dark blue
                      } else {
                        return Colors.white.withOpacity(0.9);
                      }
                    }),
                    cells: [
                      DataCell(Text(
                        detail.userId.toString(),
                        style: TextStyles.body,
                      )),
                      DataCell(Text(
                        detail.userName,
                        style: TextStyles.body,
                      )),
                      DataCell(
                        Text(
                          detail.role,
                          style: TextStyles.body,
                        ),
                      ),
                      DataCell(
                        Text(
                          detail.companyName.toString(),
                          style: TextStyles.body,
                        ),
                      ),
                      DataCell(
                        Text(
                          detail.location.toString(),
                          style: TextStyles.body,
                        ),
                      ),
                      DataCell(
                        Padding(
                          padding: const EdgeInsets.only(top: 12, bottom: 7),
                          child: Container(
                            width: 98,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: DropdownButtonFormField2<String>(
                              value: detail.active ? 'Active' : 'In Active', // Ensure value is set correctly
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.only(bottom: 15),
                                hintText: detail.active ? 'Active' : 'In Active',
                                hintStyle: TextStyles.body,
                                border: InputBorder.none,
                              ),
                              items: [
                                DropdownMenuItem<String>(
                                  value: 'Active',
                                  child: Text(
                                    'Active',
                                    style: TextStyles.body,
                                  ),
                                ),
                                DropdownMenuItem<String>(
                                  value: 'In Active',
                                  child: Text(
                                    'In Active',
                                    style: TextStyles.body,
                                  ),
                                ),
                              ],
                              onChanged: (String? newValue) {
                                if (newValue != null) {
                                  setState(() {
                                    detail.active = (newValue == 'Active'); // Convert String to bool
                                    updateRequestStatus(detail.userId, newValue);
                                  });
                                }
                              },
                              dropdownStyleData: DropdownStyleData(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(7),
                                  color: Colors.white, // Dropdown background color
                                ),
                                maxHeight: 200,
                                width: 98,
                                offset: const Offset(0, -10),
                                padding: EdgeInsets.zero,
                              ),
                              iconStyleData: const IconStyleData(
                                icon: Padding(
                                  padding: EdgeInsets.only(right: 9, bottom: 3),
                                  child: Icon(
                                    Icons.arrow_drop_down,
                                    color: Colors.indigo,
                                    size: 17,
                                  ),
                                ),
                                iconSize: 17,
                              ),
                            ),
                          ),
                        ),
                      ),
                      // DataCell(Text(
                      //   detail.active.toString(),
                      //   style: const TextStyle(
                      //     // fontSize: 16,
                      //       color: Colors.grey),
                      // )),
                      DataCell(Row(children: [
                        IconButton(
                            icon: Image.asset(
                              "images/edit_icon.png",
                              color: Color.fromRGBO(0, 83, 176, 1),
                            ),
                            onPressed: () {
                              var selectedCustomer =
                              filteredData1[customerIndex].toJson();
                              print('select');
                              print(selectedCustomer);
                              context.go('/Edit_User', extra: {
                                'EditUser': selectedCustomer,
                              });
                            }),
                        SizedBox(
                          width: 10,
                        ),
                        IconButton(
                          icon: Image.asset(
                            "images/delete.png",
                            color: Color.fromRGBO(250, 0, 0, 1),
                          ),
                          onPressed: () {
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
                                            const Icon(Icons.warning,
                                                color: Colors.orange, size: 50),
                                            const SizedBox(height: 16),
                                            const Text(
                                              'Are You Sure',
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                            ),
                                            const SizedBox(height: 20),
                                            Row(
                                              mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                              children: [
                                                ElevatedButton(
                                                  onPressed: () {
                                                    deleteRowAPI(detail.userId);
                                                  },
                                                  style:
                                                  ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                    Colors.green,
                                                    side: const BorderSide(
                                                        color: Colors.green),
                                                    shape:
                                                    RoundedRectangleBorder(
                                                      borderRadius:
                                                      BorderRadius.circular(
                                                          10.0),
                                                    ),
                                                  ),
                                                  child: const Text(
                                                    'Yes',
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  ),
                                                ),
                                                ElevatedButton(
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                  style:
                                                  ElevatedButton.styleFrom(
                                                    backgroundColor: Colors.red,
                                                    side: const BorderSide(
                                                        color: Colors.red),
                                                    shape:
                                                    RoundedRectangleBorder(
                                                      borderRadius:
                                                      BorderRadius.circular(
                                                          10.0),
                                                    ),
                                                  ),
                                                  child: const Text(
                                                    'No',
                                                    style: TextStyle(
                                                        color: Colors.white),
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
                          },
                        ),
                      ])),
                    ],
                  );
                  // onSelectChanged: (selected) {
                  //   if (selected != null && selected) {
                  //     final orderId = detail
                  //         .orderId; // Capture the orderId of the selected row
                  //     final detail1 = filteredData.firstWhere(
                  //         (element) => element.orderId == orderId);
                  //     //final detail1 = filteredData.skip((currentPage - 1) * itemsPerPage).elementAt(index);
                  //     //final detail = filteredData[(currentPage - 1) * itemsPerPage + index];
                  //
                  //     if (filteredData1.length <= 9) {
                  //
                  //     } else {
                  //
                  //     }
                  //   }
                  // });
                })),
          ),
        ],
      );
    });
  }

  Widget buildDataTable1() {
    if (isLoading) {
      var width = MediaQuery.of(context).size.width;
      var height = MediaQuery.of(context).size.height;
      // Show loading indicator while data is being fetched
      return Padding(
        padding: EdgeInsets.only(
            top: height * 0.100, bottom: height * 0.100, left: width * 0.300),
        child: CustomLoadingIcon(), // Replace this with your custom GIF widget
      );
    }

    if (filteredData1.isEmpty) {
      double right = MediaQuery.of(context).size.width;
      return Column(
        children: [
          Container(
            width: right - 270,
            decoration: const BoxDecoration(
                color: Color(0xFFF7F7F7),
                border: Border.symmetric(
                    horizontal: BorderSide(color: Colors.grey, width: 0.5))),
            child: DataTable(
                showCheckboxColumn: false,
                headingRowHeight: 40,
                columnSpacing: 50,
                columns: [
                  DataColumn(label: Text('User ID', style: TextStyles.subhead)),
                  DataColumn(
                      label: Text('User Name', style: TextStyles.subhead)),
                  DataColumn(label: Text('Role', style: TextStyles.subhead)),
                  DataColumn(
                      label: Text('Company Name', style: TextStyles.subhead)),
                  DataColumn(
                      label: Text('Location', style: TextStyles.subhead)),
                  DataColumn(label: Text('', style: TextStyles.subhead)),
                ],
                rows: const []),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 80, left: 130, right: 150),
            child: CustomDatafound(),
          ),
        ],
      );
    }

    void sortProducts(int columnIndex, String sortDirection) {
      if (sortDirection == 'asc') {
        filteredData1.sort((a, b) {
          if (columnIndex == 0) {
            return a.userId.compareTo(b.userId);
          } else if (columnIndex == 1) {
            return a.userName.compareTo(b.userName);
          } else if (columnIndex == 2) {
            return a.role.compareTo(b.role);
          } else if (columnIndex == 3) {
            return a.companyName.compareTo(b.companyName!);
          } else if (columnIndex == 4) {
            return a.location.compareTo(b.location);
          } else {
            return 0;
          }
        });
      } else {
        filteredData1.sort((a, b) {
          if (columnIndex == 0) {
            return b.userId.compareTo(a.userId); // Reverse the comparison
          } else if (columnIndex == 1) {
            return b.userName.compareTo(a.userName); // Reverse the comparison
          } else if (columnIndex == 2) {
            return b.role.compareTo(a.role); // Reverse the comparison
          } else if (columnIndex == 3) {
            return b.companyName
                .compareTo(a.companyName); // Reverse the comparison
          } else if (columnIndex == 4) {
            return b.location.compareTo(a.location); // Reverse the comparison
          } else {
            return 0;
          }
        });
      }
      setState(() {});
    }

    return LayoutBuilder(builder: (context, constraints) {
      // double padding = constraints.maxWidth * 0.065;
      double right = MediaQuery.of(context).size.width;
      return Column(
        children: [
          Container(
            width: right - 270,
            decoration: const BoxDecoration(
                color: Color(0xFFF7F7F7),
                border: Border.symmetric(
                    horizontal: BorderSide(color: Colors.grey, width: 0.5))),
            child: DataTable(
                showCheckboxColumn: false,
                headingRowHeight: 35,
                columnSpacing: 20,
                columns: columns.map((column) {
                  return DataColumn(
                    label: Stack(
                      children: [
                        SizedBox(
                          //   padding: EdgeInsets.only(left: 5,right: 5),
                          width: columnWidths[columns.indexOf(column)],
                          // Dynamic width based on user interaction
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            //crossAxisAlignment: CrossAxisAlignment.end,
                            //   mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(column,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyles.subhead
                                  // TextStyle(
                                  //   fontWeight: FontWeight.bold,
                                  //   color: Color.fromRGBO(0, 83, 176, 1),
                                  //   fontSize: 13,
                                  // ),
                                  ),
                              if (columns.indexOf(column) < columns.length - 1)
                                // if (columns.indexOf(column) < 0)
                                IconButton(
                                  icon: _sortOrder[columns.indexOf(column)] ==
                                          'asc'
                                      ? SizedBox(
                                          width: 12,
                                          child: Image.asset(
                                            "images/ix_sort.png",
                                            color:
                                                Color.fromRGBO(0, 83, 176, 1),
                                          ))
                                      : SizedBox(
                                          width: 12,
                                          child: Image.asset(
                                            "images/ix_sort.png",
                                            color:
                                                Color.fromRGBO(0, 83, 176, 1),
                                          )),
                                  onPressed: () {
                                    setState(() {
                                      _sortOrder[columns.indexOf(column)] =
                                          _sortOrder[columns.indexOf(column)] ==
                                                  'asc'
                                              ? 'desc'
                                              : 'asc';
                                      sortProducts(columns.indexOf(column),
                                          _sortOrder[columns.indexOf(column)]);
                                    });
                                  },
                                ),

                              // ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    onSort: (columnIndex, ascending) {
                      _sortOrder;
                    },
                  );
                }).toList(),
                rows: List.generate(
                    math.min(
                        itemsPerPage,
                        filteredData1.length -
                            (currentPage - 1) * itemsPerPage), (index) {
                  final detail = filteredData1
                      .skip((currentPage - 1) * itemsPerPage)
                      .elementAt(index);
                  final customerIndex =
                      (currentPage - 1) * itemsPerPage + index;
                  final isSelected = _selectedProduct == detail;
                  return DataRow(
                    color: MaterialStateProperty.resolveWith<Color>((states) {
                      if (states.contains(MaterialState.hovered)) {
                        return Colors.blue.shade500.withOpacity(
                            0.8); // Add some opacity to the dark blue
                      } else {
                        return Colors.white.withOpacity(0.9);
                      }
                    }),
                    cells: [
                      DataCell(Text(
                        detail.userId.toString(),
                        style: TextStyles.body,
                      )),
                      DataCell(Text(
                        detail.userName,
                        style: TextStyles.body,
                      )),
                      DataCell(
                        Text(
                          detail.role,
                          style: TextStyles.body,
                        ),
                      ),
                      DataCell(
                        Text(
                          detail.companyName.toString(),
                          style: TextStyles.body,
                        ),
                      ),
                      DataCell(
                        Text(
                          detail.location.toString(),
                          style: TextStyles.body,
                        ),
                      ),
                      DataCell(
                        Padding(
                          padding: const EdgeInsets.only(top: 12, bottom: 7),
                          child: Container(
                            width: 98,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: DropdownButtonFormField2<String>(
                              value: detail.active ? 'Active' : 'In Active',
                              // Ensure value is set correctly
                              decoration: InputDecoration(
                                contentPadding:
                                    const EdgeInsets.only(bottom: 15),
                                hintText:
                                    detail.active ? 'Active' : 'In Active',
                                hintStyle: TextStyles.body,
                                border: InputBorder.none,
                              ),
                              items: [
                                DropdownMenuItem<String>(
                                  value: 'Active',
                                  child: Text(
                                    'Active',
                                    style: TextStyles.body,
                                  ),
                                ),
                                DropdownMenuItem<String>(
                                  value: 'In Active',
                                  child: Text(
                                    'In Active',
                                    style: TextStyles.body,
                                  ),
                                ),
                              ],
                              onChanged: (String? newValue) {
                                if (newValue != null) {
                                  setState(() {
                                    detail.active = (newValue ==
                                        'Active'); // Convert String to bool
                                    updateRequestStatus(
                                        detail.userId, newValue);
                                  });
                                }
                              },
                              dropdownStyleData: DropdownStyleData(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(7),
                                  color:
                                      Colors.white, // Dropdown background color
                                ),
                                maxHeight: 200,
                                width: 98,
                                offset: const Offset(0, -10),
                                padding: EdgeInsets.zero,
                              ),
                              iconStyleData: const IconStyleData(
                                icon: Padding(
                                  padding: EdgeInsets.only(right: 9, bottom: 3),
                                  child: Icon(
                                    Icons.arrow_drop_down,
                                    color: Colors.indigo,
                                    size: 17,
                                  ),
                                ),
                                iconSize: 17,
                              ),
                            ),
                          ),
                        ),
                      ),
                      // DataCell(Text(
                      //   detail.active.toString(),
                      //   style: const TextStyle(
                      //     // fontSize: 16,
                      //       color: Colors.grey),
                      // )),
                      DataCell(Row(children: [
                        IconButton(
                            icon: Image.asset(
                              "images/edit_icon.png",
                              color: Color.fromRGBO(0, 83, 176, 1),
                            ),
                            onPressed: () {
                              var selectedCustomer =
                                  filteredData1[customerIndex].toJson();
                              print('select');
                              print(selectedCustomer);
                              context.go('/Edit_User', extra: {
                                'EditUser': selectedCustomer,
                              });
                            }),
                        SizedBox(
                          width: 10,
                        ),
                        IconButton(
                          icon: Image.asset(
                            "images/delete.png",
                            color: Color.fromRGBO(250, 0, 0, 1),
                          ),
                          onPressed: () {
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
                                            const Icon(Icons.warning,
                                                color: Colors.orange, size: 50),
                                            const SizedBox(height: 16),
                                            const Text(
                                              'Are You Sure',
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                            ),
                                            const SizedBox(height: 20),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                ElevatedButton(
                                                  onPressed: () {
                                                    deleteRowAPI(detail.userId);
                                                  },
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        Colors.green,
                                                    side: const BorderSide(
                                                        color: Colors.green),
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10.0),
                                                    ),
                                                  ),
                                                  child: const Text(
                                                    'Yes',
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  ),
                                                ),
                                                ElevatedButton(
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor: Colors.red,
                                                    side: const BorderSide(
                                                        color: Colors.red),
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10.0),
                                                    ),
                                                  ),
                                                  child: const Text(
                                                    'No',
                                                    style: TextStyle(
                                                        color: Colors.white),
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
                          },
                        ),
                      ])),
                    ],
                  );
                  // onSelectChanged: (selected) {
                  //   if (selected != null && selected) {
                  //     final orderId = detail
                  //         .orderId; // Capture the orderId of the selected row
                  //     final detail1 = filteredData.firstWhere(
                  //         (element) => element.orderId == orderId);
                  //     //final detail1 = filteredData.skip((currentPage - 1) * itemsPerPage).elementAt(index);
                  //     //final detail = filteredData[(currentPage - 1) * itemsPerPage + index];
                  //
                  //     if (filteredData1.length <= 9) {
                  //
                  //     } else {
                  //
                  //     }
                  //   }
                  // });
                })),
          ),
        ],
      );
    });
  }
}

class UserResponse {
  final String userId;
  final String userName;
  final String password;
  bool active;
  final String role;
  final String email;

  final String companyName;
  final String mobileNumber;
  final String location;
  final String shippingAddress1;
  final String shippingAddress2;

  UserResponse({
    required this.userId,
    required this.userName,
    required this.password,
    required this.active,
    required this.role,
    required this.email,
    required this.companyName,
    required this.mobileNumber,
    required this.location,
    required this.shippingAddress1,
    required this.shippingAddress2,
  });

  factory UserResponse.fromJson(Map<String, dynamic> json) {
    return UserResponse(
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? '',
      password: json['password'] ?? '',
      active: json['active'] ?? '',
      role: json['role'] ?? '',
      email: json['email'] ?? '',
      companyName: json['companyName'] ?? '',
      mobileNumber: json['mobileNumber'] ?? '',
      location: json['location'] ?? '',
      shippingAddress1: json['shippingAddress1'] ?? '',
      shippingAddress2: json['shippingAddress2'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'userName': userName,
      'password': password,
      'active': active,
      'role': role,
      'email': email,
      'companyName': companyName,
      'mobileNumber': mobileNumber,
      'location': location,
      'shippingAddress1': shippingAddress1,
      'shippingAddress2': shippingAddress2,
    };
  }

  static empty() {}
}
