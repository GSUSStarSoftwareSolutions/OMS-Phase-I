import 'dart:async';
import 'dart:convert';
import 'dart:html';
import 'dart:ui' as ord;
import 'dart:math' as math;
import 'package:adaptive_scrollbar/adaptive_scrollbar.dart';
import 'package:btb/admin/Api%20name.dart';
import 'package:btb/widgets/productclass.dart';
import 'package:btb/widgets/custom%20loading.dart';
import 'package:btb/widgets/pagination.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:btb/widgets/productclass.dart' as ord;
import 'package:btb/Order%20Module/firstpage.dart' as ors;
import 'package:responsive_framework/responsive_framework.dart';

import '../../widgets/confirmdialog.dart';
import '../../widgets/no datafound.dart';
import '../../widgets/text_style.dart';


void main() {
  runApp(const Dashboardbody());
}

class Dashboardbody extends StatefulWidget {
  const Dashboardbody({
    super.key,
  });

  @override
  State<Dashboardbody> createState() => _DashboardbodyState();
}

class _DashboardbodyState extends State<Dashboardbody>
    with SingleTickerProviderStateMixin {
  bool isHomeSelected = false;
  final ScrollController horizontalScroll = ScrollController();
  final ScrollController _scrollController = ScrollController();
  Timer? _searchDebounceTimer;
  String _searchText = '';
  DashboardCounts? _dashboardCounts;
  DateTime? _selectedDate;
  late TextEditingController _dateController;
  int startIndex = 0;
  late Future<List<Dashboard1>> futureOrders;
  bool _hasShownPopup = false;
  List<Product> filteredProducts = [];
  String status = '';
  String selectDate = '';
  String deliverystatus = '';
  late AnimationController _controller;
  late Animation<double> _shakeAnimation;
  bool _isHovered1 = false;
  bool _isHovered2 = false;
  bool _isHovered5 = false;
  bool orderhover = false;
  bool orderhover2 = false;
  Map<String, dynamic> PaymentMap = {};
  String? dropdownValue1 = 'Delivery Status';
  String searchQuery = '';
  String token = window.sessionStorage["token"] ?? " ";
  String? role = window.sessionStorage["role"];
  String? dropdownValue2 = 'Select Year';

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
  ord.Product? _selectedProduct;
  int itemsPerPage = 10;
  int totalItems = 0;
  int totalPages = 0;
  bool isLoading = false;
  bool _loading = false;
  List<ors.detail> filteredData1 = [];
  List<ors.detail> filteredData = [];
  List<ors.detail> productList = [];

  List<String> _sortOrder = List.generate(5, (index) => 'asc');
  List<String> columns = [
    'Order ID',
    'Customer Name',
    'Order Date',
    'Total Amount',
    'Status'
  ];
  List<double> columnWidths = [
    140,
    150,
    110,
    119,
    140,
    135,
  ];
  List<bool> columnSortState = [true, true, true, true, true, true];

  Product? product1;

  Future<void> fetchProducts(int page, int itemsPerPage) async {
    if (isLoading) return;
    if (!mounted) return;
    setState(() {
      isLoading = true;
    });
    try {
      //https://ordermanagement-industrious-dugong-ig.cfapps.us10-001.hana.ondemand.com/api/order_master/get_all_ordermaster
      final response = await http.get(
        Uri.parse(
          '$apicall/order_master/get_all_ordermaster?page=$page&limit=$itemsPerPage', // Changed limit to 10
        ),
        headers: {
          "Content-type": "application/json",
          "Authorization": 'Bearer $token',
        },
      );
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
                        const Icon(Icons.warning,
                            color: Colors.orange, size: 50),
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
          final jsonData = jsonDecode(response.body);
          List<ors.detail> products = [];
          if (jsonData is List) {
            products =
                jsonData.map((item) => ors.detail.fromJson(item)).toList();
          } else if (jsonData is Map && jsonData.containsKey('body')) {
            final body = jsonData['body'];
            if (body != null) {
              products = (body as List)
                  .map((item) => ors.detail.fromJson(item))
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

  Future<void> fetchOrders() async {
    try {
      final response = await http.get(
        Uri.parse(
          '$apicall/order_master/get_all_ordermaster',
        ),
        headers: {
          "Content-type": "application/json",
          "Authorization": 'Bearer $token',
        },
      );
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
                        const Icon(Icons.warning,
                            color: Colors.orange, size: 50),
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
          final jsonData = jsonDecode(response.body);
          if (jsonData == null) {
            return;
          }
          // List<detail> filteredData = [];
          if (jsonData is List) {
            filteredData =
                jsonData.map((item) => ors.detail.fromJson(item)).toList();
          } else if (jsonData is Map && jsonData.containsKey('body')) {
            final body = jsonData['body'];
            if (body != null) {
              filteredData = (body as List)
                  .map((item) => ors.detail.fromJson(item))
                  .toList();
            } else {}
          } else {}

          if (mounted) {
            setState(() {
              filteredData = filteredData; // Update the filteredData list
            });
          }
        } else {
          throw Exception('Failed to load data');
        }
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

  void _filterAndPaginateProducts() {
    filteredData1 = productList.where((product) {
      final matchesSearchText =
      product.orderId!.toLowerCase().contains(_searchText.toLowerCase());
      String orderYear = '';
      if (product.deliveredDate!.contains('/') ||
          product.deliveredDate!.contains('-')) {
        String separator = product.deliveredDate!.contains('/') ? '/' : '-';
        final dateParts = product.deliveredDate!.split(separator);
        if (dateParts.length == 3) {
          orderYear = dateParts[2]; // Extract the year
          //Extract the day
        }
      }
      // print(product.deliveredDate);
      // if (product.deliveredDate!.contains('/')) {
      //   final dateParts = product.deliveredDate!.split('/');
      //   if (dateParts.length == 3) {
      //     orderYear = dateParts[0]; // Extract the year
      //   }
      // }
      if (status.isEmpty && selectDate.isEmpty) {
        return matchesSearchText; // Include all products that match the search text
      }
      if (status == 'Delivery Status' && selectDate == 'Select Year') {
        return matchesSearchText;
      }
      if (status == 'Delivery Status' && selectDate.isEmpty) {
        return matchesSearchText;
      }
      if (selectDate == 'Select Year' && status.isEmpty) {
        return matchesSearchText;
      }
      if (status == 'Delivery Status' && selectDate.isNotEmpty) {
        return matchesSearchText &&
            orderYear == selectDate; // Include all products
      }
      if (status.isNotEmpty && selectDate == 'Select Year') {
        return matchesSearchText &&
            product.deliveryStatus == status; // Include all products
      }
      if (status.isEmpty && selectDate.isNotEmpty) {
        return matchesSearchText &&
            orderYear == selectDate; // Include all products
      }

      if (status.isNotEmpty && selectDate.isEmpty) {
        return matchesSearchText &&
            product.deliveryStatus == status; // Include all products
      }
      return matchesSearchText &&
          (product.deliveryStatus == status && orderYear == selectDate);
      //  return false;
    }).toList();
    totalPages = (filteredData1.length / itemsPerPage).ceil();
    setState(() {
      // print('fileterpaginate');
      // print(_filteredData);
      currentPage = 1;
    });
  }

  @override
  void initState() {
    super.initState();
    _getDashboardCounts();
    fetchOrders();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

// Define the shake animation (values will oscillate between -5.0 and 5.0)
    _shakeAnimation = Tween<double>(begin: 0, end: 5)
        .chain(CurveTween(curve: Curves.elasticIn))
        .animate(_controller)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _controller.reverse();
        } else if (status == AnimationStatus.dismissed) {
          _controller.forward();
        }
      });
    _dateController = TextEditingController();
    _selectedDate = DateTime.now();
    String formattedDate = DateFormat('dd/MM/yyyy').format(_selectedDate!);
    _dateController.text = formattedDate;
    fetchProducts(currentPage, itemsPerPage);
  }

  Future<void> _getDashboardCounts() async {
    final response = await http.get(
      Uri.parse('$apicall/order_master/get_order_counts'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
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
        final jsonData = jsonDecode(response.body);
        setState(() {
          _dashboardCounts = DashboardCounts.fromJson(jsonData);
        });
      } else {
        throw Exception('Failed to load dashboard counts');
      }
    }
  }

  @override
  void dispose() {
    _searchDebounceTimer?.cancel();
    _controller.dispose(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: SingleChildScrollView(
           child: Column(
           // crossAxisAlignment: CrossAxisAlignment.start,
             children: [
               Row(
                 children: [
                   Padding(
                             padding: const EdgeInsets.only(left: 10),
                             child: Text(
                               'Dashboard',
                               style: TextStyles.heading,
                             ),
                           ),
                 ],
               ),
               Row(
                 children: [
                   Expanded(
                       child: Container(
                     height: 300,
                     color: Colors.green,)),
                 ],
               ),
               Row(
                 children: [
                   Expanded(child: Container(
                     height: 200,
                     color: Colors.red,))
                 ],
               ),
             ],
           ),
        ),
        // child: Scaffold(
        //   backgroundColor: Colors.grey[50],
        //   body: LayoutBuilder(builder: (context, constraints) {
        //     double maxWidth = constraints.maxWidth;
        //     double maxHeight = constraints.maxHeight;
        //     return Row(
        //       children: [
        //         Padding(
        //           padding: const EdgeInsets.only(left: 10),
        //           child: Text(
        //             'Dashboard',
        //             style: TextStyles.heading,
        //           ),
        //         ),
        //         Row(
        //           children: [
        //             Expanded(
        //               flex: 5,
        //                 child:Container(color: Colors.green,
        //                 height: 400,
        //                 width: 600,),
        //             ),
        //             Expanded(
        //               flex: 2,
        //                 child:Container(color: Colors.red,),
        //             ),
        //
        //           ]
        //         ),
        //         // Expanded(
        //         //   flex:6,
        //         //   child: Column(
        //         //     children: [
        //         //       Padding(
        //         //         padding: const EdgeInsets.only(left: 30),
        //         //         child: Container(
        //         //           decoration: const BoxDecoration(),
        //         //           padding: const EdgeInsets.symmetric(horizontal: 16),
        //         //           height: 50,
        //         //           child: Row(
        //         //             children: [
        //         //
        //         //               Column(
        //         //                   mainAxisAlignment: MainAxisAlignment.start,
        //         //                   children: [
        //         //                     Expanded(
        //         //                       child: Padding(
        //         //                         padding: const EdgeInsets.only(
        //         //                             left: 1, right: 1, top: 5),
        //         //                         child: Container(
        //         //                           //   color: Colors.grey[50],
        //         //                           child: Column(
        //         //                             children: [
        //         //                               Row(
        //         //                                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //         //                                   children: [
        //         //                                     Padding(
        //         //                                       padding:
        //         //                                       const EdgeInsets.only(top: 10,bottom: 10,left: 10),
        //         //                                       child: MouseRegion(
        //         //                                         onEnter: (_){
        //         //                                           setState(() {
        //         //                                             _isHovered2 = true;
        //         //                                           });
        //         //                                         },
        //         //                                         onExit: (_){
        //         //                                           setState(() {
        //         //                                             _isHovered2 = false;
        //         //                                           });
        //         //                                         },
        //         //
        //         //                                         child: AnimatedScale  (
        //         //                                           scale: _isHovered2 ? 1.05: 1.0,
        //         //                                           duration:  const Duration(milliseconds: 200),
        //         //                                           child: InkWell(
        //         //                                             onTap: () {
        //         //                                               // context.go('/Open_Order');
        //         //                                               // Navigator.push(
        //         //                                               //   context,
        //         //                                               //   MaterialPageRoute(
        //         //                                               //       builder: (context) =>
        //         //                                               //           OpenorderList()),
        //         //                                               // );
        //         //                                             },
        //         //                                             // splashColor: Colors.grey.withOpacity(0.2),
        //         //                                             child: Container(
        //         //                                               height: 115,
        //         //                                               width: maxWidth * 0.15,
        //         //                                               padding:
        //         //                                               const EdgeInsets.all(16),
        //         //                                               decoration: BoxDecoration(
        //         //                                                 color: Colors.white,
        //         //                                                 border: Border.all(color: Color(0x29000000),),
        //         //                                                 borderRadius: BorderRadius.circular(15),
        //         //                                               ),
        //         //                                               child: Row(
        //         //                                                 crossAxisAlignment:
        //         //                                                 CrossAxisAlignment.center,
        //         //                                                 children: [
        //         //                                                   Padding(
        //         //                                                     padding:
        //         //                                                     const EdgeInsets.only(
        //         //                                                         top: 3),
        //         //                                                     child:Container(
        //         //                                                       width: 60,
        //         //                                                       height: 60,
        //         //                                                       decoration: BoxDecoration(
        //         //                                                         shape: BoxShape.circle,
        //         //                                                         border: Border.all(
        //         //                                                           color: const Color(0xFFF33C3DB), // Border color
        //         //                                                           width: 1.5,
        //         //                                                         ),
        //         //                                                         color: const Color(0xFFB3F9FF), // Set the background color to match the border
        //         //                                                         boxShadow: [
        //         //                                                           BoxShadow(
        //         //                                                             color: const Color(0xFF418CFC33).withOpacity(0.1), // Soft grey shadow
        //         //                                                             spreadRadius: 1,
        //         //                                                             blurRadius: 3,
        //         //                                                             offset: const Offset(0, 1),
        //         //                                                           ),
        //         //                                                         ],
        //         //                                                       ),
        //         //                                                       child: SizedBox(
        //         //                                                           width: 10,
        //         //                                                           height: 10,
        //         //
        //         //                                                           child: Image.asset("images/open_order1.png",)),
        //         //                                                     ),
        //         //                                                   ),
        //         //                                                   const SizedBox(
        //         //                                                     height: 5,
        //         //                                                   ),
        //         //                                                   Column(
        //         //                                                       crossAxisAlignment:
        //         //                                                       CrossAxisAlignment.start,
        //         //                                                       children: [
        //         //                                                         SizedBox(height: 10),
        //         //                                                         Padding(
        //         //                                                           padding:
        //         //                                                           const EdgeInsets.only(
        //         //                                                               left: 10),
        //         //                                                           child: Text(
        //         //                                                             _dashboardCounts != null
        //         //                                                                 ? _dashboardCounts!
        //         //                                                                 .openOrders
        //         //                                                                 .toString()
        //         //                                                                 : '0',
        //         //                                                             style: const TextStyle(
        //         //                                                                 fontSize: 25,
        //         //                                                                 fontWeight:
        //         //                                                                 FontWeight
        //         //                                                                     .bold),
        //         //                                                           ),
        //         //                                                         ),
        //         //                                                         Padding(
        //         //                                                           padding:const  EdgeInsets.only(
        //         //                                                               left: 10),
        //         //                                                           child: Text(
        //         //                                                             'Open Orders1',
        //         //                                                             style: TextStyle(
        //         //                                                               fontSize: maxWidth * 0.01,
        //         //                                                               color: Color(0xFF455A64),),
        //         //                                                           ),
        //         //                                                         ),
        //         //                                                       ]
        //         //                                                   )
        //         //
        //         //                                                 ],
        //         //                                               ),
        //         //                                             ),
        //         //                                           ),
        //         //                                         ),
        //         //                                       ),
        //         //                                     ),
        //         //                                     Padding(
        //         //                                       padding:
        //         //                                       const EdgeInsets.only(top: 10,bottom: 10),
        //         //                                       child: MouseRegion(
        //         //                                         onEnter: (_) {
        //         //                                           setState(() {
        //         //                                             _isHovered5 = true;
        //         //                                           });
        //         //                                         },
        //         //                                         onExit: (_) {
        //         //                                           setState(() {
        //         //                                             _isHovered5 = false;
        //         //                                           });
        //         //                                         },
        //         //                                         child: AnimatedScale(scale: _isHovered5 ? 1.05 : 1.0,
        //         //                                           duration:
        //         //                                           const Duration(
        //         //                                               milliseconds:
        //         //                                               200),
        //         //                                           child: InkWell(
        //         //                                             onTap: () {
        //         //                                               // context.go(
        //         //                                               //     '/Picked_order');
        //         //                                             },
        //         //                                             child: Container(
        //         //                                               height: 115,
        //         //                                               width: maxWidth * 0.15,
        //         //                                               padding: const EdgeInsets.all(16),
        //         //                                               decoration: BoxDecoration(
        //         //                                                 color: Colors.white,
        //         //                                                 border: Border.all(color: Color(0x29000000),),
        //         //                                                 borderRadius: BorderRadius.circular(15),
        //         //                                               ),
        //         //                                               child: Row(
        //         //                                                 crossAxisAlignment:
        //         //                                                 CrossAxisAlignment.center,
        //         //                                                 children: [
        //         //                                                   Padding(
        //         //                                                     padding:
        //         //                                                     const EdgeInsets.only(
        //         //                                                         top: 3),
        //         //                                                     child: Container(
        //         //                                                       width: 60,
        //         //                                                       height: 60,
        //         //                                                       decoration: BoxDecoration(
        //         //                                                         shape: BoxShape.circle,
        //         //                                                         border: Border.all(
        //         //                                                             color: const Color(
        //         //                                                                 0xFF9F86FF),
        //         //                                                             width: 1.5),
        //         //                                                         color: const Color(
        //         //                                                             0xFFFFF9F7),
        //         //
        //         //                                                         boxShadow: [
        //         //                                                           BoxShadow(
        //         //                                                             color: const Color(
        //         //                                                                 0xFF418CFC33)
        //         //                                                                 .withOpacity(
        //         //                                                                 0.1),
        //         //                                                             // Soft grey shadow
        //         //                                                             spreadRadius: 1,
        //         //                                                             blurRadius: 3,
        //         //                                                             offset:
        //         //                                                             const Offset(
        //         //                                                                 0, 1),
        //         //                                                           ),
        //         //                                                         ],
        //         //                                                       ),
        //         //                                                       child: Image.asset(
        //         //                                                           "images/file.png",
        //         //                                                           fit:
        //         //                                                           BoxFit.scaleDown),
        //         //                                                     ),
        //         //                                                   ),
        //         //                                                   const SizedBox(
        //         //                                                     height: 5,
        //         //                                                   ),
        //         //                                                   Column(
        //         //                                                       crossAxisAlignment:
        //         //                                                       CrossAxisAlignment.start,
        //         //                                                       children: [
        //         //                                                         SizedBox(height: 10),
        //         //                                                         Padding(
        //         //                                                           padding: const EdgeInsets.only(
        //         //                                                               left: 10),
        //         //                                                           child: Text(
        //         //                                                             _dashboardCounts != null
        //         //                                                                 ? _dashboardCounts!
        //         //                                                                 .Picked
        //         //                                                                 .toString()
        //         //                                                                 : '0',
        //         //                                                             style: const TextStyle(
        //         //                                                                 fontSize: 25,
        //         //                                                                 fontWeight:
        //         //                                                                 FontWeight
        //         //                                                                     .bold),
        //         //                                                           ),
        //         //                                                         ),
        //         //                                                         Padding(
        //         //                                                           padding: EdgeInsets.only(
        //         //                                                               left: 10),
        //         //                                                           child: Text(
        //         //                                                             'Picked Orders',
        //         //                                                             style: TextStyle(
        //         //                                                               fontSize: maxWidth * 0.01,
        //         //                                                               color: Color(0xFF455A64),),
        //         //                                                           ),
        //         //                                                         )
        //         //                                                       ]
        //         //                                                   )
        //         //
        //         //                                                 ],
        //         //                                               ),
        //         //                                             ),
        //         //                                           ),
        //         //                                         ),
        //         //                                       ),
        //         //                                     ),
        //         //                                     Padding(
        //         //                                       padding:
        //         //                                       const EdgeInsets.only(top: 10,bottom: 10),
        //         //                                       child: MouseRegion(
        //         //                                         onEnter: (_){setState(() {
        //         //                                           orderhover2 = true;
        //         //                                         });
        //         //                                         },
        //         //                                         onExit: (_){setState(() {
        //         //                                           orderhover2 = false;
        //         //                                         });
        //         //                                         },
        //         //                                         child: AnimatedScale(
        //         //                                           scale: orderhover2 ? 1.05: 1.0,
        //         //                                           duration:  const Duration(milliseconds: 200),
        //         //                                           child: InkWell(
        //         //                                             onTap: () {
        //         //
        //         //                                               //context.go('/Order_Complete');
        //         //                                             },
        //         //                                             child: Container(
        //         //                                               height: 115,
        //         //                                               width: maxWidth * 0.15,
        //         //                                               padding: const EdgeInsets.all(16),
        //         //                                               decoration: BoxDecoration(
        //         //                                                 color: Colors.white,
        //         //                                                 border: Border.all(color: Color(0x29000000),),
        //         //                                                 borderRadius: BorderRadius.circular(15),
        //         //                                               ),
        //         //                                               child: Row(
        //         //                                                 crossAxisAlignment:
        //         //                                                 CrossAxisAlignment.center,
        //         //                                                 children: [
        //         //                                                   Padding(
        //         //                                                     padding:
        //         //                                                     const EdgeInsets.only(
        //         //                                                         top: 3),
        //         //                                                     child: Container(
        //         //                                                       width: 60,
        //         //                                                       height: 60,
        //         //                                                       decoration: BoxDecoration(
        //         //                                                         shape: BoxShape.circle,
        //         //                                                         border: Border.all(
        //         //                                                             color: const Color(
        //         //                                                                 0xFF0388AB),
        //         //                                                             width: 1.5),
        //         //                                                         color: const Color(
        //         //                                                             0xFFF8F6FF),
        //         //
        //         //                                                         boxShadow: [
        //         //                                                           BoxShadow(
        //         //                                                             color: const Color(
        //         //                                                                 0xFF418CFC33)
        //         //                                                                 .withOpacity(
        //         //                                                                 0.1),
        //         //                                                             // Soft grey shadow
        //         //                                                             spreadRadius: 1,
        //         //                                                             blurRadius: 3,
        //         //                                                             offset:
        //         //                                                             const Offset(
        //         //                                                                 0, 1),
        //         //                                                           ),
        //         //                                                         ],
        //         //                                                       ),
        //         //                                                       child: Image.asset(
        //         //                                                           "images/dash.png",
        //         //                                                           fit:
        //         //                                                           BoxFit.scaleDown),
        //         //                                                     ),
        //         //                                                   ),
        //         //                                                   const SizedBox(
        //         //                                                     height: 5,
        //         //                                                   ),
        //         //                                                   Column(
        //         //                                                       crossAxisAlignment:
        //         //                                                       CrossAxisAlignment.start,
        //         //                                                       children: [
        //         //                                                         SizedBox(height: 10),
        //         //                                                         Padding(
        //         //                                                           padding:
        //         //                                                           const EdgeInsets.only(
        //         //                                                               left: 10),
        //         //                                                           child: Text(
        //         //                                                             _dashboardCounts != null
        //         //                                                                 ? _dashboardCounts!
        //         //                                                                 .Delivered
        //         //                                                                 .toString()
        //         //                                                                 : '0',
        //         //                                                             style: const TextStyle(
        //         //                                                                 fontSize: 25,
        //         //                                                                 fontWeight:
        //         //                                                                 FontWeight.bold),
        //         //                                                           ),
        //         //                                                         ),
        //         //                                                         Padding(
        //         //                                                           padding:const EdgeInsets.only(
        //         //                                                               left: 10),
        //         //                                                           child: Text(
        //         //                                                             'Order Delivered',
        //         //                                                             style: TextStyle(
        //         //                                                               fontSize: maxWidth * 0.01,
        //         //                                                               color: Color(0xFF455A64), // Dark grey-blue
        //         //                                                               fontWeight: FontWeight.w500,
        //         //                                                               letterSpacing: 0.5,
        //         //                                                             ),
        //         //                                                           ),
        //         //                                                         )
        //         //                                                       ]
        //         //                                                   )
        //         //                                                 ],
        //         //                                               ),
        //         //                                             ),
        //         //                                           ),
        //         //                                         ),
        //         //                                       ),
        //         //                                     ),
        //         //                                     Padding(
        //         //                                       padding: const EdgeInsets.only(
        //         //                                           top: 10,bottom:10,right: 10
        //         //                                       ),
        //         //                                       child: MouseRegion(
        //         //                                         onEnter: (_){setState(() {
        //         //                                           orderhover = true;
        //         //                                         });
        //         //                                         },
        //         //                                         onExit: (_){setState(() {
        //         //                                           orderhover = false;
        //         //                                         });
        //         //                                         },
        //         //                                         child: AnimatedScale(
        //         //                                           scale: orderhover ? 1.05: 1.0,
        //         //                                           duration:  const Duration(milliseconds: 200),
        //         //                                           child: InkWell(
        //         //                                             onTap: () {
        //         //
        //         //                                               //  context.go('/Pay_Complete');
        //         //                                             },
        //         //                                             child: Container(
        //         //                                               height: 115,
        //         //                                               width: maxWidth * 0.155,
        //         //                                               padding:
        //         //                                               const EdgeInsets.all(16),
        //         //                                               decoration: BoxDecoration(
        //         //                                                 color: Colors.white,
        //         //                                                 border: Border.all(color: Color(0x29000000),),
        //         //                                                 borderRadius: BorderRadius.circular(15),
        //         //                                               ),
        //         //                                               child: Row(
        //         //                                                 crossAxisAlignment:
        //         //                                                 CrossAxisAlignment.center,
        //         //                                                 children: [
        //         //                                                   Padding(
        //         //                                                     padding:
        //         //                                                     const EdgeInsets.only(
        //         //                                                         top: 1),
        //         //                                                     child: Container(
        //         //                                                       width: 60,
        //         //                                                       height: 60,
        //         //                                                       decoration:
        //         //                                                       BoxDecoration(
        //         //                                                         shape: BoxShape.circle,
        //         //                                                         border: Border.all(
        //         //                                                             color: const Color(
        //         //                                                                 0xFF19C92F),
        //         //                                                             width: 1.5),
        //         //                                                         color: const Color(
        //         //                                                             0xFFBFFFC7),
        //         //
        //         //                                                         boxShadow: [
        //         //                                                           BoxShadow(
        //         //                                                             color: const Color(
        //         //                                                                 0xFF418CFC33)
        //         //                                                                 .withOpacity(
        //         //                                                                 0.1),
        //         //                                                             // Soft grey shadow
        //         //                                                             spreadRadius: 1,
        //         //                                                             blurRadius: 3,
        //         //                                                             offset:
        //         //                                                             const Offset(
        //         //                                                                 0, 1),
        //         //                                                           ),
        //         //                                                         ],
        //         //                                                       ),
        //         //                                                       child: Image.asset(
        //         //                                                         "images/nk1.png",
        //         //                                                         width: 35,
        //         //                                                         height: 35,
        //         //                                                       ),
        //         //                                                     ),
        //         //                                                   ),
        //         //                                                   const SizedBox(
        //         //                                                     height: 5,
        //         //                                                   ),
        //         //                                                   Column(
        //         //                                                       crossAxisAlignment:
        //         //                                                       CrossAxisAlignment.start,
        //         //                                                       children: [
        //         //                                                         SizedBox(height: 10),
        //         //                                                         Padding(
        //         //                                                           padding:
        //         //                                                           const EdgeInsets.only(
        //         //                                                               left: 10),
        //         //                                                           child: Text(
        //         //                                                             _dashboardCounts != null
        //         //                                                                 ? _dashboardCounts!
        //         //                                                                 .Cleard
        //         //                                                                 .toString()
        //         //                                                                 : '0',
        //         //                                                             style: const TextStyle(
        //         //                                                                 fontSize: 25,
        //         //                                                                 fontWeight:
        //         //                                                                 FontWeight
        //         //                                                                     .bold),
        //         //                                                           ),
        //         //                                                         ),
        //         //                                                         const Padding(
        //         //                                                           padding: EdgeInsets.only(
        //         //                                                               left: 10),
        //         //                                                           child: Text(
        //         //                                                             'Order Completed',
        //         //                                                             style: TextStyle(
        //         //                                                               fontSize: 15,
        //         //                                                               color: Color(0xFF455A64),),
        //         //                                                           ),
        //         //                                                         )
        //         //                                                       ]
        //         //                                                   )
        //         //
        //         //                                                 ],
        //         //                                               ),
        //         //                                             ),
        //         //                                           ),
        //         //                                         ),
        //         //                                       ),
        //         //                                     ),
        //         //                                   ]
        //         //
        //         //                               )],
        //         //                           ),
        //         //                         ),
        //         //                       ),
        //         //                     ),
        //         //                     Expanded(
        //         //                       child:   Padding(
        //         //                           padding: const EdgeInsets.only(
        //         //                               left: 1,
        //         //                               top: 20,
        //         //                               right: 1,
        //         //                               bottom: 10),
        //         //                           child: Container(
        //         //                             height: 650,
        //         //                             width: maxWidth,
        //         //                             decoration: BoxDecoration(
        //         //                               //   border: Border.all(color: Colors.grey),
        //         //                               color: Colors.white,
        //         //                               borderRadius: BorderRadius.circular(2),
        //         //                               boxShadow: [
        //         //                                 BoxShadow(
        //         //                                   color: Colors.grey.withOpacity(0.1),
        //         //                                   // Soft grey shadow
        //         //                                   spreadRadius: 3,
        //         //                                   blurRadius: 3,
        //         //                                   offset: const Offset(0, 3),
        //         //                                 ),
        //         //                               ],
        //         //                             ),
        //         //                             child: SizedBox(
        //         //                               //width: maxWidth * 0.8,
        //         //                               child: Column(
        //         //                                 crossAxisAlignment:
        //         //                                 CrossAxisAlignment.start,
        //         //                                 children: [
        //         //                                   buildSearchField1(),
        //         //                                   const SizedBox(height: 20),
        //         //                                   Expanded(
        //         //                                     child: Scrollbar(
        //         //                                       controller:
        //         //                                       _scrollController,
        //         //                                       thickness: 6,
        //         //                                       thumbVisibility: true,
        //         //                                       child:
        //         //                                       SingleChildScrollView(
        //         //                                         controller:
        //         //                                         _scrollController,
        //         //                                         scrollDirection:
        //         //                                         Axis.horizontal,
        //         //                                         child: buildDataTable1(),
        //         //                                       ),
        //         //                                     ),
        //         //                                   ),
        //         //                                   const SizedBox(
        //         //                                     height: 1,
        //         //                                   ),
        //         //                                   Padding(
        //         //                                     padding:
        //         //                                     const EdgeInsets.only(
        //         //                                         right: 30),
        //         //                                     child: Row(
        //         //                                       mainAxisAlignment:
        //         //                                       MainAxisAlignment.end,
        //         //                                       children: [
        //         //                                         PaginationControls(
        //         //                                           currentPage:
        //         //                                           currentPage,
        //         //                                           totalPages: filteredData1
        //         //                                               .length >
        //         //                                               itemsPerPage
        //         //                                               ? totalPages
        //         //                                               : 1,
        //         //                                           //totalPages//totalPages,
        //         //                                           // onFirstPage: _goToFirstPage,
        //         //                                           onPreviousPage:
        //         //                                           _goToPreviousPage,
        //         //                                           onNextPage:
        //         //                                           _goToNextPage,
        //         //                                           // onLastPage: _goToLastPage,
        //         //                                         ),
        //         //                                       ],
        //         //                                     ),
        //         //                                   )
        //         //                                 ],
        //         //                               ),
        //         //                             ),
        //         //                           )),
        //         //                     )
        //         //                   ]
        //         //               ),
        //         //               // Expanded(
        //         //               //   // flex: 1,
        //         //               //     child: Padding(
        //         //               //       padding: const EdgeInsets.only(left: 30),
        //         //               //       child: SingleChildScrollView(
        //         //               //         child: Column(
        //         //               //           children: [
        //         //               //             Padding(
        //         //               //               padding: const EdgeInsets.only(
        //         //               //                   left: 35, right: 50, top: 5),
        //         //               //               child: Container(
        //         //               //                 width: maxWidth,
        //         //               //                 child: Column(
        //         //               //                   children: [
        //         //               //
        //         //               //
        //         //               //
        //         //               //
        //         //               //                   ],
        //         //               //                 ),
        //         //               //               ),),
        //         //               //
        //         //               //
        //         //               //           ],
        //         //               //         ),
        //         //               //       ),
        //         //               //     ))
        //         //             ],
        //         //           ),
        //         //         ),
        //         //       ),
        //         //
        //         //     ],
        //         //   ),
        //         // ),
        //
        //       ],
        //     );
        //   }),
        // ),
      );
  }

  List<Widget> _buildMenuItems(BuildContext context) {
    return [
      Column(
        children: [
          const SizedBox(
            height: 10,
          ),
          Container(
              height: 42,
              decoration: BoxDecoration(
                color: Colors.blue[800],
                // border: Border(  left: BorderSide(    color: Colors.blue,    width: 5.0,  ),),
                // color: Color.fromRGBO(224, 59, 48, 1.0),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  // Radius for top-left corner
                  topRight: Radius.circular(8),
                  // No radius for top-right corner
                  bottomLeft: Radius.circular(8),
                  // Radius for bottom-left corner
                  bottomRight:
                  Radius.circular(8), // No radius for bottom-right corner
                ),
              ),
              child: _buildMenuItem(
                  'Home', Icons.home, Colors.white, '/Cus_Home')),
        ],
      ),
      const SizedBox(
        height: 6,
      ),
      _buildMenuItem(
          'Orders', Icons.warehouse_outlined, Colors.blue[900]!, '/Customer_Order_List'),
    ];
  }

  Widget _buildMenuItem(
      String title, IconData icon, Color iconColor, String route) {
    iconColor = _isHovered[title] == true ? Colors.blue : Colors.black87;
    title == 'Home' ? _isHovered[title] = false : _isHovered[title] = false;
    title == 'Home' ? iconColor = Colors.white : Colors.black;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(
            () => _isHovered[title] = true,
      ),
      onExit: (_) => setState(() => _isHovered[title] = false),
      child: GestureDetector(
        onTap: () {
          context.go(route);
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 5, right: 20),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: _isHovered[title]! ? Colors.black12 : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.only(left: 10,top:2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(icon, color: iconColor,size: 20,),
                const SizedBox(width: 10),
                Text(
                  title,
                  style:
                  GoogleFonts.inter(
                    textStyle: TextStyle(
                      color: iconColor,
                      fontSize: 15,
                      decoration: TextDecoration.none,  // Remove underline
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildSearchField2() {
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
                // const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.only(top: 20, left: 30),
                  child: Container(
                    width: 310, // reduced width
                    height: 35, // reduced height
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(2),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: TextFormField(
                      style: GoogleFonts.inter(    color: Colors.black,    fontSize: 13),
                      decoration:  InputDecoration(
                        hintText: 'Search by Order ID',
                        hintStyle: TextStyles.body,
                        contentPadding: EdgeInsets.symmetric(vertical: 3,horizontal: 5),
                        // adjusted padding
                        border: InputBorder.none,
                        suffixIcon: Padding(
                          padding: EdgeInsets.only(right: 2),
                          child: Icon(
                            Icons.search_outlined,
                            color: Colors.indigo,
                            size: 20,
                          ),
                        ),
                      ),
                      onChanged: _updateSearch,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Row(
            //   children: [
            //     Column(
            //       crossAxisAlignment: CrossAxisAlignment.start,
            //       children: [
            //         //  const SizedBox(height: 8),
            //         Padding(
            //           padding: const EdgeInsets.only(left: 30),
            //           child: Container(
            //             width: 150, // reduced width
            //             height: 35, // reduced height
            //             decoration: BoxDecoration(
            //               color: Colors.white,
            //               borderRadius: BorderRadius.circular(2),
            //               border: Border.all(color: Colors.grey),
            //             ),
            //             child: DropdownButtonFormField2<String>(
            //               decoration: const InputDecoration(
            //                 contentPadding: EdgeInsets.only(
            //                     bottom: 15, left: 9), // Custom padding
            //                 border: InputBorder.none, // No default border
            //                 filled: true,
            //                 fillColor: Colors.white, // Background color
            //               ),
            //               isExpanded: true,
            //               // Ensures dropdown takes full width
            //               value: dropdownValue1,
            //               onChanged: (String? newValue) {
            //                 setState(() {
            //                   dropdownValue1 = newValue;
            //                   status = newValue ?? '';
            //                   _filterAndPaginateProducts();
            //                 });
            //               },
            //               items: <String>[
            //                 'Delivery Status',
            //                 'Not Started',
            //                 'In Progress',
            //                 'Delivered',
            //               ].map<DropdownMenuItem<String>>((String value) {
            //                 return DropdownMenuItem<String>(
            //                   value: value,
            //                   child: Text(
            //                     value,
            //                     style: TextStyle(
            //                       fontSize: 13,
            //                       color: value == 'Delivery Status'
            //                           ? Colors.grey
            //                           : Colors.black,
            //                     ),
            //                   ),
            //                 );
            //               }).toList(),
            //               iconStyleData: const IconStyleData(
            //                 icon: Icon(
            //                   Icons.arrow_drop_down_circle_rounded,
            //                   color: Colors.indigo,
            //                   size: 16,
            //                 ),
            //                 iconSize: 16,
            //               ),
            //               buttonStyleData: const ButtonStyleData(
            //                 height: 50, // Button height
            //                 padding: EdgeInsets.only(
            //                     left: 10, right: 10), // Button padding
            //               ),
            //               dropdownStyleData: DropdownStyleData(
            //                 decoration: BoxDecoration(
            //                   borderRadius: BorderRadius.circular(7),
            //                   // Rounded corners
            //                   color: Colors.white, // Dropdown background color
            //                 ),
            //                 maxHeight: 200, // Max height for dropdown items
            //                 width: maxWidth1 * 0.1, // Dropdown width
            //                 offset: const Offset(0, -20),
            //               ),
            //             ),
            //           ),
            //         ),
            //       ],
            //     ),
            //     // const SizedBox(width: 16),
            //     Column(
            //       crossAxisAlignment: CrossAxisAlignment.start,
            //       children: [
            //         // const SizedBox(height: 8),
            //         Padding(
            //           padding: const EdgeInsets.all(8.0),
            //           child: Container(
            //             width: 150, // reduced width
            //             height: 35, // reduced height
            //             decoration: BoxDecoration(
            //               color: Colors.white,
            //               borderRadius: BorderRadius.circular(2),
            //               border: Border.all(color: Colors.grey),
            //             ),
            //             child: DropdownButtonFormField2<String>(
            //               decoration: const InputDecoration(
            //                 contentPadding:
            //                 EdgeInsets.only(bottom: 15, left: 10),
            //                 // adjusted padding
            //                 border: InputBorder.none,
            //                 filled: true,
            //                 fillColor: Colors.white,
            //               ),
            //               //icon: Container(),
            //               value: dropdownValue2,
            //               onChanged: (String? newValue) {
            //                 setState(() {
            //                   selectDate = newValue ?? '';
            //                   dropdownValue2 = newValue;
            //                   _filterAndPaginateProducts();
            //                 });
            //               },
            //               items: <String>['Select Year', '2023', '2024', '2025']
            //                   .map<DropdownMenuItem<String>>((String value) {
            //                 return DropdownMenuItem<String>(
            //                   value: value,
            //                   child: Text(
            //                     value,
            //                     style: TextStyle(
            //                       fontSize: 13,
            //                       color: value == 'Select Year'
            //                           ? Colors.grey
            //                           : Colors.black,
            //                     ),
            //                   ),
            //                 );
            //               }).toList(),
            //               iconStyleData: const IconStyleData(
            //                 icon: Icon(
            //                   Icons.arrow_drop_down_circle_rounded,
            //                   color: Colors.indigo,
            //                   size: 16,
            //                 ),
            //                 iconSize: 16,
            //               ),
            //               buttonStyleData: const ButtonStyleData(
            //                 height: 50, // Button height
            //                 padding: EdgeInsets.only(
            //                     left: 10, right: 10), // Button padding
            //               ),
            //               dropdownStyleData: DropdownStyleData(
            //                 decoration: BoxDecoration(
            //                   borderRadius: BorderRadius.circular(7),
            //                   // Rounded corners
            //                   color: Colors.white, // Dropdown background color
            //                 ),
            //                 maxHeight: 200, // Max height for dropdown items
            //                 width: maxWidth1 * 0.1, // Dropdown width
            //                 offset: const Offset(0, -20),
            //               ),
            //             ),
            //           ),
            //         ),
            //       ],
            //     ),
            //   ],
            // ),
          ],
        ),
      );
    });
  }

  Widget buildSearchField1() {
    double maxWidth1 = MediaQuery.of(context).size.width;
    return LayoutBuilder(builder: (context, constraints) {
      return ConstrainedBox(
        constraints: const BoxConstraints(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const SizedBox(height: 8),
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.only(top: 20, left: 30),
                      child: Container(
                        width: maxWidth1 * 0.2, // reduced width
                        height: 35, // reduced height
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(2),
                          border: Border.all(color: Colors.grey),
                        ),
                        child: TextFormField(
                          style: GoogleFonts.inter(    color: Colors.black,    fontSize: 13),
                          decoration:  InputDecoration(
                              hintText: 'Search by Order ID',
                              hintStyle: TextStyles.body,
                              //hintStyle: TextStyle(color: Colors.grey, fontSize: 13),
                              contentPadding: EdgeInsets.symmetric(vertical: 3,horizontal: 5),
                              // adjusted padding
                              border: InputBorder.none,
                              suffixIcon: Padding(
                                padding: const EdgeInsets.only(left: 10, right: 5), // Adjust image padding
                                child: Image.asset(
                                  'images/search.png', // Replace with your image asset path
                                ),
                              )
                          ),
                          onChanged: _updateSearch,
                        ),
                      ),
                    ),
                  ],
                ),
                // Spacer(),
                // Padding(
                //   padding: const EdgeInsets.only(right: 30),
                //   child: Column(
                //     crossAxisAlignment: CrossAxisAlignment.start,
                //     children: [
                //       //  const SizedBox(height: 8),
                //       Padding(
                //         padding: const EdgeInsets.only(left: 30,top: 20),
                //         child: Container(
                //           width: maxWidth1 * 0.1, // reduced width
                //           height: 35, // reduced height
                //           decoration: BoxDecoration(
                //             color: Colors.white,
                //             borderRadius: BorderRadius.circular(2),
                //             border: Border.all(color: Colors.grey),
                //           ),
                //           child: DropdownButtonFormField2<String>(
                //             decoration: const InputDecoration(
                //               contentPadding: EdgeInsets.only(
                //                   bottom: 15, left: 9), // Custom padding
                //               border: InputBorder.none, // No default border
                //               filled: true,
                //               fillColor: Colors.white, // Background color
                //             ),
                //             isExpanded: true,
                //             // Ensures dropdown takes full width
                //             value: dropdownValue1,
                //             onChanged: (String? newValue) {
                //               setState(() {
                //                 dropdownValue1 = newValue;
                //                 status = newValue ?? '';
                //                 _filterAndPaginateProducts();
                //               });
                //             },
                //             items: <String>[
                //               'Delivery Status',
                //               'Not Started',
                //               'In Progress',
                //               'Delivered',
                //             ].map<DropdownMenuItem<String>>((String value) {
                //               return DropdownMenuItem<String>(
                //                 value: value,
                //                 child: Text(
                //                   value,
                //                   style: TextStyle(
                //                     fontSize: 13,
                //                     color: value == 'Delivery Status'
                //                         ? Colors.grey
                //                         : Colors.black,
                //                   ),
                //                 ),
                //               );
                //             }).toList(),
                //             iconStyleData: const IconStyleData(
                //               icon: Icon(
                //                 Icons.keyboard_arrow_down,
                //                 color: Colors.indigo,
                //                 size: 16,
                //               ),
                //               iconSize: 16,
                //             ),
                //             buttonStyleData: const ButtonStyleData(
                //               height: 50, // Button height
                //               padding: EdgeInsets.only(
                //                   left: 10, right: 10), // Button padding
                //             ),
                //             dropdownStyleData: DropdownStyleData(
                //               decoration: BoxDecoration(
                //                 borderRadius: BorderRadius.circular(7),
                //                 // Rounded corners
                //                 color: Colors.white, // Dropdown background color
                //               ),
                //               maxHeight: 200, // Max height for dropdown items
                //               width: maxWidth1 * 0.1, // Dropdown width
                //               offset: const Offset(0, -20),
                //             ),
                //           ),
                //         ),
                //       ),
                //     ],
                //   ),
                // ),

              ],
            ),
          ],
        ),
      );
    });
  }

  Widget buildDataTable2() {
    if (isLoading) {
      _loading = true;
      var width = MediaQuery.of(context).size.width;
      var Height = MediaQuery.of(context).size.height;
      // Show loading indicator while data is being fetched
      return Padding(
        padding: EdgeInsets.only(
            top: Height * 0.100, bottom: Height * 0.100, left: width * 0.300),
        child: CustomLoadingIcon(), // Replace this with your custom GIF widget
      );
    }

    if (filteredData1.isEmpty) {
      double right = MediaQuery.of(context).size.width;
      return Column(
        children: [
          Container(
            width: 1200,
            decoration:  BoxDecoration(
                color: Color(0xFFF7F7F7),
                border: Border.symmetric(
                    horizontal: BorderSide(color: Colors.grey, width: 0.5))),
            child: DataTable(
                showCheckboxColumn: false,
                headingRowHeight: 40,
                columnSpacing: 50,
                columns: [
                  DataColumn(
                      label: Container(
                          child: Text(
                              'Order ID',
                              style: TextStyles.subhead))),
                  DataColumn(
                      label: Text(
                          'Customer Name',
                          style: TextStyles.subhead
                      )),
                  DataColumn(
                      label: Container(
                          child: Text(
                            'Order Date',
                            style: TextStyles.subhead,
                          ))),
                  DataColumn(
                      label: Container(
                          child: Text(
                            'Total Amount',
                            style: TextStyles.subhead,
                          ))),
                  DataColumn(
                      label: Container(
                          child: Text(
                            'Status',
                            style: TextStyles.subhead,
                          ))),
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

    void _sortProducts(int columnIndex, String sortDirection) {
      if (sortDirection == 'asc') {
        filteredData1.sort((a, b) {
          if (columnIndex == 0) {
            return a.orderId!.compareTo(b.orderId!);
          } else if (columnIndex == 1) {
            return a.contactPerson!.compareTo(b.contactPerson!);
          } else if (columnIndex == 2) {
            return a.createdDate!.compareTo(b.createdDate!);
          } else if (columnIndex == 3) {
            return a.total.compareTo(b.total);
          } else if (columnIndex == 4) {
            return a.deliveryStatus.compareTo(b.deliveryStatus);
          }  else {
            return 0;
          }
        });
      } else {
        filteredData1.sort((a, b) {
          if (columnIndex == 0) {
            return b.orderId!.compareTo(a.orderId!); // Reverse the comparison
          } else if (columnIndex == 1) {
            return b.contactPerson!
                .compareTo(a.contactPerson!); // Reverse the comparison
          } else if (columnIndex == 2) {
            return b.createdDate!
                .compareTo(a.createdDate!); // Reverse the comparison
          } else if (columnIndex == 3) {
            return b.total
                .compareTo(a.total); // Reverse the comparison
          } else if (columnIndex == 4) {
            return b.deliveryStatus
                .compareTo(a.deliveryStatus); // Reverse the comparison
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
            width: 1200,
            decoration: const BoxDecoration(
                color: Color(0xFFF7F7F7),
                border: Border.symmetric(
                    horizontal: BorderSide(color: Colors.grey, width: 0.5))),
            child: DataTable(
                showCheckboxColumn: false,
                headingRowHeight: 40,
                columnSpacing: 35,
                columns: columns.map((column) {
                  return DataColumn(
                    label: Stack(
                      children: [
                        Container(
                          //   padding: EdgeInsets.only(left: 5,right: 5),
                          width: columnWidths[columns.indexOf(column)],
                          // Dynamic width based on user interaction
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            //crossAxisAlignment: CrossAxisAlignment.end,
                            //   mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                  column,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyles.subhead
                              ),
                              //  if (columns.indexOf(column) > 0)
                              IconButton(
                                icon:
                                _sortOrder[columns.indexOf(column)] == 'asc'
                                    ? SizedBox(
                                    width: 12,
                                    child: Image.asset(
                                      "images/ix_sort.png",
                                      color: Colors.blue,
                                    ))
                                    : SizedBox(
                                    width: 12,
                                    child: Image.asset(
                                      "images/ix_sort.png",
                                      color: Colors.blue,
                                    )),
                                onPressed: () {
                                  setState(() {
                                    _sortOrder[columns.indexOf(column)] =
                                    _sortOrder[columns.indexOf(column)] ==
                                        'asc'
                                        ? 'desc'
                                        : 'asc';
                                    _sortProducts(columns.indexOf(column),
                                        _sortOrder[columns.indexOf(column)]);
                                  });
                                },
                              ),
                              //SizedBox(width: 50,),
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
                  // final detail1 = filteredData.skip((currentPage - 1) * itemsPerPage).elementAt(index);
                  final detail = filteredData1
                      .skip((currentPage - 1) * itemsPerPage)
                      .elementAt(index);
                  final isSelected = _selectedProduct == detail;
                  // final isSelected = _selectedProduct == detail;
                  //final product = filteredData[(currentPage - 1) * itemsPerPage + index];
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
                      DataCell(
                        Container(
                          width: columnWidths[0],
                          // Same dynamic width as column headers
                          child: Text(
                            detail.orderId.toString(),
                            style: TextStyles.body,
                          ),
                        ),
                      ),
                      DataCell(
                        Container(
                          width: columnWidths[1],
                          child: Text(
                            detail.contactPerson!,
                            style: TextStyles.body,
                          ),
                        ),
                      ),
                      DataCell(
                        Container(
                          width: columnWidths[2],
                          child: Text(
                            detail.orderDate!,
                            style: TextStyles.body,
                          ),
                        ),
                      ),
                      DataCell(
                        Container(
                          width: columnWidths[3],
                          child: Text(
                            detail.total.toString(),
                            style: TextStyles.body,
                          ),
                        ),
                      ),
                      DataCell(
                        Container(
                          width: columnWidths[4],
                          child: Text(
                            detail.deliveryStatus.toString(),
                            style: TextStyles.body,
                          ),
                        ),
                      ),
                    ],
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
                    //       //fetchOrders();
                    //       PaymentMap = {
                    //         'paymentmode': detail.paymentMode,
                    //         'paymentStatus': detail.paymentStatus,
                    //         'paymentdate': detail.paymentDate,
                    //         'paidamount': detail.paidAmount,
                    //       };
                    //
                    //       context.go('/Order_Placed_List', extra: {
                    //         'product': detail1,
                    //         'item': [], // pass an empty list of maps
                    //         'arrow': 'Home',
                    //         'status': detail.deliveryStatus,
                    //         'paymentStatus': PaymentMap,
                    //         'body': {},
                    //         // 'status': detail.deliveryStatus,
                    //         'itemsList': [], // pass an empty list of maps
                    //         'orderDetails': filteredData
                    //             .map((detail) => ors.OrderDetail(
                    //                   orderId: detail.orderId,
                    //                   orderDate: detail.orderDate, items: [],
                    //                   // Add other fields as needed
                    //                 ))
                    //             .toList(),
                    //       });
                    //     } else {
                    //       PaymentMap = {
                    //         'paymentmode': detail.paymentMode,
                    //         'paymentStatus': detail.paymentStatus,
                    //         'paymentdate': detail.paymentDate,
                    //         'paidamount': detail.paidAmount,
                    //       };
                    //       context.go('/Order_Placed_List', extra: {
                    //         'product': detail1,
                    //         'arrow': 'Home',
                    //         'item': [], // pass an empty list of maps
                    //         'status': detail.deliveryStatus,
                    //         'paymentStatus': PaymentMap,
                    //         'body': {},
                    //         'itemsList': [], // pass an empty list of maps
                    //         'orderDetails': filteredData
                    //             .map((detail) => ors.OrderDetail(
                    //                   orderId: detail.orderId,
                    //                   orderDate: detail.orderDate, items: [],
                    //                   // Add other fields as needed
                    //                 ))
                    //             .toList(),
                    //       });
                    //
                    //     }
                    //   }
                    // }
                  );
                })),
          ),
        ],
      );
    });
  }

  Widget buildDataTable1() {
    if (isLoading) {
      _loading = true;
      var width = MediaQuery.of(context).size.width;
      var Height = MediaQuery.of(context).size.height;
      // Show loading indicator while data is being fetched
      return Padding(
        padding: EdgeInsets.only(
            top: Height * 0.100, bottom: Height * 0.100, left: width * 0.300),
        child: CustomLoadingIcon(), // Replace this with your custom GIF widget
      );
    }
    if (filteredData1.isEmpty) {
      double right = MediaQuery.of(context).size.width;
      return Column(
        children: [
          Container(
            width: right - 200,
            decoration:  BoxDecoration(
                color: Color(0xFFF7F7F7),
                border: Border.symmetric(
                    horizontal: BorderSide(color: Colors.grey, width: 0.5))),
            child: DataTable(
                showCheckboxColumn: false,
                headingRowHeight: 40,
                columnSpacing: 50,
                columns: [
                  DataColumn(
                      label: Container(
                          child: Text(
                              'Order ID',
                              style: TextStyles.subhead))),
                  DataColumn(
                      label: Text(
                          'Customer Name',
                          style: TextStyles.subhead
                      )),
                  DataColumn(
                      label: Container(
                          child: Text(
                            'Order Date',
                            style: TextStyles.subhead,
                          ))),
                  DataColumn(
                      label: Container(
                          child: Text(
                            'Total Amount',
                            style: TextStyles.subhead,
                          ))),
                  DataColumn(
                      label: Container(
                          child: Text(
                            'Status',
                            style: TextStyles.subhead,
                          ))),

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

    void _sortProducts(int columnIndex, String sortDirection) {
      if (sortDirection == 'asc') {
        filteredData1.sort((a, b) {
          if (columnIndex == 0) {
            return a.orderId!.compareTo(b.orderId!);
          } else if (columnIndex == 1) {
            return a.contactPerson!.compareTo(b.contactPerson!);
          } else if (columnIndex == 2) {
            return a.createdDate!.compareTo(b.createdDate!);
          } else if (columnIndex == 3) {
            return a.total.compareTo(b.total);
          } else if (columnIndex == 4) {
            return a.deliveryStatus.compareTo(b.deliveryStatus);
          }  else {
            return 0;
          }
        });
      } else {
        filteredData1.sort((a, b) {
          if (columnIndex == 0) {
            return b.orderId!.compareTo(a.orderId!); // Reverse the comparison
          } else if (columnIndex == 1) {
            return b.contactPerson!
                .compareTo(a.contactPerson!); // Reverse the comparison
          } else if (columnIndex == 2) {
            return b.createdDate!
                .compareTo(a.createdDate!); // Reverse the comparison
          } else if (columnIndex == 3) {
            return b.total
                .compareTo(a.total); // Reverse the comparison
          } else if (columnIndex == 4) {
            return b.deliveryStatus
                .compareTo(a.deliveryStatus); // Reverse the comparison
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
            width: right - 200,
            decoration: const BoxDecoration(
                color: Color(0xFFF7F7F7),
                border: Border.symmetric(
                    horizontal: BorderSide(color: Colors.grey, width: 0.5))),
            child: DataTable(
                showCheckboxColumn: false,
                headingRowHeight: 40,
                columnSpacing: 35,
                columns: columns.map((column) {
                  return DataColumn(
                    label: Stack(
                      children: [
                        Container(
                          //   padding: EdgeInsets.only(left: 5,right: 5),
                          width: columnWidths[columns.indexOf(column)],
                          // Dynamic width based on user interaction
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            //crossAxisAlignment: CrossAxisAlignment.end,
                            //   mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                  column,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyles.subhead
                              ),
                              //  if (columns.indexOf(column) > 0)
                              IconButton(
                                icon:
                                _sortOrder[columns.indexOf(column)] == 'asc'
                                    ? SizedBox(
                                    width: 12,
                                    child: Image.asset(
                                      "images/ix_sort.png",
                                      color: Colors.blue,
                                    ))
                                    : SizedBox(
                                    width: 12,
                                    child: Image.asset(
                                      "images/ix_sort.png",
                                      color: Colors.blue,
                                    )),
                                onPressed: () {
                                  setState(() {
                                    _sortOrder[columns.indexOf(column)] =
                                    _sortOrder[columns.indexOf(column)] ==
                                        'asc'
                                        ? 'desc'
                                        : 'asc';
                                    _sortProducts(columns.indexOf(column),
                                        _sortOrder[columns.indexOf(column)]);
                                  });
                                },
                              ),
                              //SizedBox(width: 50,),
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
                  // final detail1 = filteredData.skip((currentPage - 1) * itemsPerPage).elementAt(index);
                  final detail = filteredData1
                      .skip((currentPage - 1) * itemsPerPage)
                      .elementAt(index);
                  final isSelected = _selectedProduct == detail;
                  // final isSelected = _selectedProduct == detail;
                  //final product = filteredData[(currentPage - 1) * itemsPerPage + index];
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
                      DataCell(
                        Container(
                          width: columnWidths[0],
                          // Same dynamic width as column headers
                          child: Text(
                            detail.orderId.toString(),
                            style: TextStyles.body,
                          ),
                        ),
                      ),
                      DataCell(
                        Container(
                          width: columnWidths[1],
                          child: Text(
                            detail.contactPerson!,
                            style: TextStyles.body,
                          ),
                        ),
                      ),
                      DataCell(
                        Container(
                          width: columnWidths[2],
                          child: Text(
                            detail.orderDate!,
                            style: TextStyles.body,
                          ),
                        ),
                      ),
                      DataCell(
                        Container(
                          width: columnWidths[3],
                          child: Text(
                            detail.total.toString(),
                            style: TextStyles.body,
                          ),
                        ),
                      ),
                      DataCell(
                        Container(
                          width: columnWidths[4],
                          child: Text(
                            detail.deliveryStatus.toString(),
                            style: TextStyles.body,
                          ),
                        ),
                      ),

                    ],
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
                    //       //fetchOrders();
                    //       PaymentMap = {
                    //         'paymentmode': detail.paymentMode,
                    //         'paymentStatus': detail.paymentStatus,
                    //         'paymentdate': detail.paymentDate,
                    //         'paidamount': detail.paidAmount,
                    //       };
                    //
                    //       context.go('/Order_Placed_List', extra: {
                    //         'product': detail1,
                    //         'item': [], // pass an empty list of maps
                    //         'arrow': 'Home',
                    //         'status': detail.deliveryStatus,
                    //         'paymentStatus': PaymentMap,
                    //         'body': {},
                    //         // 'status': detail.deliveryStatus,
                    //         'itemsList': [], // pass an empty list of maps
                    //         'orderDetails': filteredData
                    //             .map((detail) => ors.OrderDetail(
                    //                   orderId: detail.orderId,
                    //                   orderDate: detail.orderDate, items: [],
                    //                   // Add other fields as needed
                    //                 ))
                    //             .toList(),
                    //       });
                    //     } else {
                    //       PaymentMap = {
                    //         'paymentmode': detail.paymentMode,
                    //         'paymentStatus': detail.paymentStatus,
                    //         'paymentdate': detail.paymentDate,
                    //         'paidamount': detail.paidAmount,
                    //       };
                    //       context.go('/Order_Placed_List', extra: {
                    //         'product': detail1,
                    //         'arrow': 'Home',
                    //         'item': [], // pass an empty list of maps
                    //         'status': detail.deliveryStatus,
                    //         'paymentStatus': PaymentMap,
                    //         'body': {},
                    //         'itemsList': [], // pass an empty list of maps
                    //         'orderDetails': filteredData
                    //             .map((detail) => ors.OrderDetail(
                    //                   orderId: detail.orderId,
                    //                   orderDate: detail.orderDate, items: [],
                    //                   // Add other fields as needed
                    //                 ))
                    //             .toList(),
                    //       });
                    //
                    //     }
                    //   }
                    // }
                  );
                })),
          ),
        ],
      );
    });
  }
}

class Dashboard {
  String dashBoardId;
  String status;
  String orderId;
  String createdDate;
  int referenceNumber;
  int totalAmount;
  String deliveryStatus;

  Dashboard({
    required this.dashBoardId,
    required this.status,
    required this.orderId,
    required this.createdDate,
    required this.referenceNumber,
    required this.totalAmount,
    required this.deliveryStatus,
  });

  factory Dashboard.fromJson(Map<String, dynamic> json) {
    return Dashboard(
      dashBoardId: json['dashBoardId'],
      status: json['status'],
      orderId: json['orderId'],
      createdDate: json['createdDate'],
      referenceNumber: json['referenceNumber'],
      totalAmount: json['totalAmount'],
      deliveryStatus: json['deliveryStatus'],
    );
  }
}

class Dashboard1 {
  final String dashBoardId;
  final String status;
  final String orderId;
  final String deliveredDate;
  final String payment;
  final String createdDate;
  final String customerId;
  final int referenceNumber;
  final int totalAmount;
  final String deliveryStatus;

  Dashboard1({
    required this.dashBoardId,
    required this.status,
    required this.payment,
    required this.orderId,
    required this.createdDate,
    required this.referenceNumber,
    required this.deliveredDate,
    required this.totalAmount,
    required this.customerId,
    required this.deliveryStatus,
  });

  factory Dashboard1.fromJson(Map<String, dynamic> json) {
    return Dashboard1(
      dashBoardId: json['dashBoardId'] ?? '',
      status: json['status'] ?? '',
      payment: json['paymentStatus'] ?? '',
      deliveredDate: json['deliveredDate'] ?? '',
      orderId: json['orderId'] ?? '',
      customerId: json['customerId'] ?? '',
      createdDate: json['createdDate'] ?? '',
      referenceNumber: json['referenceNumber'] != null
          ? int.parse(json['referenceNumber'].toString())
          : 0,
      totalAmount: json['totalAmount'] != null
          ? int.parse(json['totalAmount'].toString())
          : 0,
      deliveryStatus: json['deliveryStatus'] ?? '',
    );
  }

  @override
  String toString() {
    return 'Dashboard1('
        'dashBoardId: $dashBoardId, '
        'status: $status, '
        'deliveredDate: $deliveredDate,'
        'orderId: $orderId,'
        ' createdDate: $createdDate, '
        'referenceNumber: $referenceNumber,'
        ' totalAmount: $totalAmount, '
        'deliveryStatus: $deliveryStatus)';
  }
}

class DashboardCounts {
  final int openOrders;
  final int Cleard;
  final int Inprepare;
  final int Picked;

  //final int? openInvoices;
  final double totalAmount;
  final int Delivered;

  DashboardCounts(
      {required this.openOrders,
        required this.Cleard,
        required this.Inprepare,
        required this.Picked,

        //   required this.openInvoices,
        required this.totalAmount,
        required this.Delivered});

  factory DashboardCounts.fromJson(Map<String, dynamic> json) {
    return DashboardCounts(
      Picked: json['Picked'] ?? 0,
      openOrders: json['Not Started'] ?? 0.0,
      Cleard: json['Cleared'] ?? 0.0,
      Inprepare: json['In Progress'] ?? 0.0,

      //    openInvoices: json['Open Invoices'],
      totalAmount: json['totalAmount'] ?? 0.0,
      Delivered: json['Delivered'] ?? 0.0,
    );
  }
}


class VerticalDividerWidget extends StatelessWidget {
  final double height;
  final Color color;
  final double width;

  const VerticalDividerWidget({
    Key? key,
    this.height = 100,
    this.width =100,

    this.color = Colors.grey,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 200,top: 61),
      child: Container(
        width: 4, // Thickness of the vertical divider
        height: height, // Height of the divider
        color: color, // Color of the divider
      ),
    );
  }
}



class CustomDrawer extends StatelessWidget {
  final Map<String, bool> _isHovered = {};

  CustomDrawer({super.key});

  // Define menu items as a list of maps for better scalability
  final List<Map<String, dynamic>> menuItems = [
    {
      'title': 'Home',
      'icon': Icons.home,
      'route': '/Cus_Home',
      'isPrimary': true,
    },
    {
      'title': 'Orders',
      'icon': Icons.warehouse_outlined,
      'route': '/Customer_Order_List',
      'isPrimary': false,
    },
    // Add more items as needed
  ];

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          ...menuItems.map((item) => _buildMenuItem(
            context,
            item['title'],
            item['icon'],
            item['route'],
            item['isPrimary'],
          )),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
      BuildContext context,
      String title,
      IconData icon,
      String route,
      bool isPrimary,
      ) {
    // Initialize hover state if not already present
    _isHovered[title] = _isHovered[title] ?? false;

    Color iconColor = isPrimary
        ? Colors.white
        : (_isHovered[title] == true ? Colors.blue : Colors.black87);
    Color backgroundColor = isPrimary
        ? Colors.blue[800]!
        : (_isHovered[title] == true ? Colors.black12 : Colors.transparent);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => _updateHoverState(title, true),
      onExit: (_) => _updateHoverState(title, false),
      child: GestureDetector(
        onTap: () {
          context.go(route); // Navigate to the route
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 5, right: 20),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.only(left: 10, top: 2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(icon, color: iconColor, size: 20),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: GoogleFonts.inter(
                    textStyle: TextStyle(
                      color: iconColor,
                      fontSize: 15,
                      decoration: TextDecoration.none, // Remove underline
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _updateHoverState(String title, bool isHovered) {
    _isHovered[title] = isHovered;
  }
}