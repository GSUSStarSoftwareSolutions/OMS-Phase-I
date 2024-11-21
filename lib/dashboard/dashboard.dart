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
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:btb/widgets/productclass.dart' as ord;
import 'package:btb/Order%20Module/firstpage.dart' as ors;
import '../Order Module/firstpage.dart' as ors;
import '../customer module/customer list.dart';
import '../widgets/confirmdialog.dart';
import '../widgets/no datafound.dart';

void main() {
  runApp(const DashboardPage());
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({
    super.key,
  });

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>  with SingleTickerProviderStateMixin{
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
  bool orderhover = false;
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

  List<String> _sortOrder = List.generate(6, (index) => 'asc');
  List<String> columns = [
    'Order ID',
    'Created Date',
    'Delivery Date',
    'Total Amount',
    'Delivery Status',
    'Payment'
  ];
  List<double> columnWidths = [
    100,
    130,
    130,
    139,
    160,
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
      final response = await http.get(
        Uri.parse(
          '$apicall/dashboard/get_all_dashboard?page=$page&limit=$itemsPerPage', // Changed limit to 10
        ),
        headers: {
          "Content-type": "application/json",
          "Authorization": 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        List<ors.detail> products = [];
        if (jsonData is List) {
          products = jsonData.map((item) => ors.detail.fromJson(item)).toList();
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

  // void sortColumn(int index) {
  //   setState(() {
  //     columnSortState[index] = !columnSortState[index];
  //     filteredData1.sort((a, b) {
  //       if (columnSortState[index]) {
  //         return a[[index]].toString().compareTo(b[columns[index]].toString());
  //       } else {
  //         return b[[index]].toString().compareTo(a[columns[index]].toString());
  //       }
  //     });
  //   });
  // }
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
      Uri.parse(
          '$apicall/dashboard/get_dashboard_counts'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      setState(() {
        _dashboardCounts = DashboardCounts.fromJson(jsonData);
      });
    } else {
      throw Exception('Failed to load dashboard counts');
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
              ),
            ],
          ),
          body:
          LayoutBuilder(builder: (context, constraints) {
              double maxWidth = constraints.maxWidth;
              return Stack(
                children: [
                  if(constraints.maxHeight <= 500)...{
                    SingleChildScrollView(
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Container(
                          width: 200,
                          color: const Color(0xFFF7F6FA),
                          padding: const EdgeInsets.only(left: 15, top: 10,right: 15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: _buildMenuItems(context),
                          ),
                        ),
                      ),
                    )

                  }
                  else...{
                    Align(
                      alignment: Alignment.topLeft,
                      child: Container(
                        width: 200,
                        color: const Color(0xFFF7F6FA),
                        padding: const EdgeInsets.only(left: 15, top: 10,right: 15),
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
                    left: 180,
                    top: 0,
                    right: 0,
                    bottom: 0,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 30),
                          child: Container(
            decoration: BoxDecoration(
                color: Color(0xFFFDFEFF),
              // gradient: LinearGradient(
              //     colors: [
              //       Color.fromRGBO(236, 233, 230, 1.0),
              //       Color.fromRGBO(255, 255, 255, 1.0)
              //     ]
              // )
            ),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                           // color: const Color(0xFFFFFDFF),

                            height: 50,
                            child: Row(
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(left: 10),
                                  child: Text(
                                    'Dashboard',
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                // const Spacer(),
                                // Align(
                                //   alignment: Alignment.topRight,
                                //   child: Padding(
                                //     padding: const EdgeInsets.only(top: 10, right: 30),
                                //     child: MouseRegion(
                                //       onEnter: (_) {
                                //         setState(() {
                                //           _isHovered1 = true;
                                //           _controller.forward(); // Start shake animation when hovered
                                //         });
                                //       },
                                //       onExit: (_) {
                                //         setState(() {
                                //           _isHovered1 = false;
                                //           _controller.stop(); // Stop shake animation when not hovered
                                //         });
                                //       },
                                //       child: AnimatedBuilder(
                                //         animation: _controller,
                                //         builder: (context, child) {
                                //           return Transform.translate(
                                //             offset: Offset(
                                //               _isHovered1 ? _shakeAnimation.value : 0, // Shake horizontally
                                //               0, // No vertical translation
                                //             ),
                                //             child: AnimatedContainer(
                                //               duration: const Duration(milliseconds: 300),
                                //               curve: Curves.easeInOut,
                                //               decoration: BoxDecoration(
                                //                 color: _isHovered1
                                //                     ? Colors.blue[800]
                                //                     : Colors.blue[800], // Background color change on hover
                                //                 borderRadius: BorderRadius.circular(5),
                                //                 boxShadow: _isHovered1
                                //                     ? [
                                //                   BoxShadow(
                                //                       color: Colors.black45,
                                //                       blurRadius: 6,
                                //                       spreadRadius: 2)
                                //                 ]
                                //                     : [],
                                //               ),
                                //               child: OutlinedButton(
                                //                 onPressed: () {
                                //                   // Button pressed action
                                //                   context.go('/Create_New_Product');
                                //                 },
                                //                 style: OutlinedButton.styleFrom(
                                //                   backgroundColor: Colors.transparent,
                                //                   shape: RoundedRectangleBorder(
                                //                     borderRadius: BorderRadius.circular(5),
                                //                   ),
                                //                   side: BorderSide.none,
                                //                   padding: const EdgeInsets.symmetric(
                                //                       vertical: 12, horizontal: 24),
                                //                 ),
                                //                 child: Text(
                                //                   'Create',
                                //                   style: TextStyle(
                                //                     fontSize: 16,
                                //                     color: _isHovered1
                                //                         ? Colors.white
                                //                         : Colors.white, // Text color change on hover
                                //
                                //                   ),
                                //                 ),
                                //               ),
                                //             ),
                                //           );
                                //         },
                                //       ),
                                //     ),
                                //   ),
                                // ),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(left: 22),
                          // Space above/below the border
                          height: 1,
                          // width: 1000,
                          width: constraints.maxWidth,
                          // Border height
                          color: Colors.grey.shade300, // Border color
                        ),
                        Expanded(
                            // flex: 1,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 30),
                              child: SingleChildScrollView(
                                                        child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 30, right: 50),
                                      child: Container(
                                        height: 39,
                                        width: maxWidth * 0.11,
                                        decoration: BoxDecoration(
                                          // border: Border.all(color: Colors.grey),
                                          borderRadius: BorderRadius.circular(4),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.blue.withOpacity(0.1),
                                              // Soft grey shadow
                                              spreadRadius: 1,
                                              blurRadius: 3,
                                              offset: const Offset(0, 1),
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          children: [
                                            Expanded(
                                              child: TextFormField(
                                                controller: _dateController,
                                                // Replace with your TextEditingController
                                                readOnly: true,
                                                decoration: InputDecoration(
                                                  suffixIcon: Padding(
                                                    padding: const EdgeInsets.only(
                                                        top: 2, right: 10),
                                                    child: IconButton(
                                                      icon: const Padding(
                                                        padding: EdgeInsets.only(
                                                          bottom: 16,
                                                        ),
                                                        child: Icon(
                                                          Icons.calendar_month,
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                      iconSize: 20,
                                                      onPressed: () {
                                                        //  _showDatePicker(context);
                                                      },
                                                    ),
                                                  ),
                                                  //    hintText: '      Select Date',
                                                  fillColor: Colors.white,
                                                  contentPadding:
                                                      const EdgeInsets.symmetric(
                                                          horizontal: 4,
                                                          vertical: 4),
                                                  border: InputBorder.none,
                                                  filled: true,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                if(constraints.maxWidth >= 1350)...{
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 50, right: 50, top: 30),
                                    child: Container(
                                      color: Colors.white
                                      ,
                                      width: maxWidth,
                                      child: Column(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 1, right: 1, top: 5),
                                            child: Container(
                                              color: Colors.grey[50],
                                              child: Column(
                                                children: [Row(
                                                    mainAxisAlignment:
                                                    MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Padding(
                                                        padding:
                                                        EdgeInsets.only(top: 10,bottom: 10,left: 10),
                                                        child: MouseRegion(
                                                          onEnter: (_){
                                                            setState(() {
                                                              _isHovered2 = true;
                                                            });
                                                          },
                                                          onExit: (_){
                                                            setState(() {
                                                              _isHovered2 = false;
                                                            });
                                                          },

                                                          child: AnimatedScale  (
                                                            scale: _isHovered2 ? 1.05: 1.0,
                                                            duration:  const Duration(milliseconds: 200),
                                                            child: InkWell(
                                                              onTap: () {
                                                                context.go('/Open_Order');
                                                                // Navigator.push(
                                                                //   context,
                                                                //   MaterialPageRoute(
                                                                //       builder: (context) =>
                                                                //           OpenorderList()),
                                                                // );
                                                              },
                                                              // splashColor: Colors.grey.withOpacity(0.2),
                                                              child: Card(
                                                                //  margin:  const EdgeInsets.only(left: 1, top: 20,),
                                                                shape: RoundedRectangleBorder(
                                                                  borderRadius:
                                                                  BorderRadius.circular(10),
                                                                ),
                                                                color: Colors.grey,
                                                                elevation: 2,
                                                                // equivalent to the boxShadow in the original code
                                                                child: Container(
                                                                  // height: 140,
                                                                  width: maxWidth * 0.15,
                                                                  padding:
                                                                  const EdgeInsets.all(16),
                                                                  decoration: BoxDecoration(
                                                                    // color: Colors.white10,
                                                                    gradient: LinearGradient(
                                                                      colors: [
                                                                        const Color(0xFFFFE5B4).withOpacity(0.9),
                                                                        //Color(0xFFFFCCBC),
                                                                        const Color(0xFFFFFFFF),
                                                                        // Your color
                                                                        // Slightly darker shade of your color
                                                                      ],
                                                                      begin: Alignment.topLeft,
                                                                      end: Alignment.bottomRight,
                                                                    ),
                                                                    borderRadius: BorderRadius.circular(8),
                                                                    boxShadow: [
                                                                      BoxShadow(
                                                                        color: const Color(0xFFFFD7BE).withOpacity(0.1),
                                                                        spreadRadius: 0,
                                                                        blurRadius: 3,
                                                                        offset: const Offset(0, 2),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  child: Column(
                                                                    crossAxisAlignment:
                                                                    CrossAxisAlignment.start,
                                                                    children: [
                                                                      Padding(
                                                                        padding:
                                                                        const EdgeInsets.only(
                                                                            top: 3),
                                                                        child: Container(
                                                                            width: 34,
                                                                            height: 34,
                                                                            decoration:
                                                                            BoxDecoration(
                                                                              border: Border.all(
                                                                                  color: const Color(
                                                                                      0xFFFFAE8F),
                                                                                  width: 1.5),
                                                                              color: const Color(
                                                                                  0xFFFFF9F7),
                                                                              borderRadius:
                                                                              BorderRadius
                                                                                  .circular(
                                                                                  4),
                                                                              boxShadow: [
                                                                                BoxShadow(
                                                                                  color: const Color(
                                                                                      0xFF418CFC33)
                                                                                      .withOpacity(
                                                                                      0.1),
                                                                                  // Soft grey shadow
                                                                                  spreadRadius: 1,
                                                                                  blurRadius: 3,
                                                                                  offset:
                                                                                  const Offset(
                                                                                      0, 1),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                            child: Image.asset(
                                                                              "images/open.png",
                                                                              width: 20,
                                                                              // Replace with your desired width
                                                                              height: 20,
                                                                              // Replace with your desired height
                                                                              fit: BoxFit
                                                                                  .contain, // This will maintain the aspect ratio
                                                                            )),
                                                                      ),
                                                                      const SizedBox(
                                                                        height: 5,
                                                                      ),
                                                                      Padding(
                                                                        padding:
                                                                        const EdgeInsets.only(
                                                                            left: 10),
                                                                        child: Text(
                                                                          _dashboardCounts != null
                                                                              ? _dashboardCounts!
                                                                              .openOrders
                                                                              .toString()
                                                                              : '0',
                                                                          style: const TextStyle(
                                                                              fontSize: 25,
                                                                              fontWeight:
                                                                              FontWeight
                                                                                  .bold),
                                                                        ),
                                                                      ),
                                                                      const Padding(
                                                                        padding: EdgeInsets.only(
                                                                            left: 10),
                                                                        child: Text(
                                                                          'Open Orders',
                                                                          style: TextStyle(
                                                                            fontSize: 15,
                                                                            color: Color(0xFF455A64),),
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
                                                      Padding(
                                                        padding:
                                                        const EdgeInsets.only(top: 10,bottom: 10),
                                                        child: Card(
                                                          // margin:  EdgeInsets.only(left: 600, top: 150),
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                            BorderRadius.circular(10),
                                                          ),
                                                          color: Colors.white,
                                                          // Set the color to white
                                                          elevation: 2,
                                                          // equivalent to the boxShadow in the original code
                                                          child: Container(
                                                            // height: 140,
                                                            width: maxWidth * 0.15,
                                                            padding: const EdgeInsets.all(16),
                                                            decoration: BoxDecoration(
                                                              gradient: LinearGradient(
                                                                colors: [
                                                                  const Color.fromRGBO(218, 180, 255, 0.8).withOpacity(0.1),
                                                                  //Color.fromRGBO(159, 134, 255, 0.8),
                                                                  // Color(0xFF9F86FF),
                                                                  const Color(0xFFFFFFFF),
                                                                  // Icon background color
                                                                  // Slightly darker shade of the icon background color
                                                                ],
                                                                begin: Alignment.topLeft,
                                                                end: Alignment.bottomRight,
                                                              ),
                                                              borderRadius: BorderRadius.circular(8),
                                                              boxShadow: [
                                                                BoxShadow(
                                                                  color: const Color(0xFFE5D8F2).withOpacity(0.1),
                                                                  spreadRadius: 2,
                                                                  blurRadius: 3,
                                                                  offset: const Offset(0, 1),
                                                                ),
                                                              ],
                                                            ),
                                                            child: Column(
                                                              crossAxisAlignment:
                                                              CrossAxisAlignment.start,
                                                              children: [
                                                                Padding(
                                                                  padding:
                                                                  const EdgeInsets.only(
                                                                      top: 3),
                                                                  child: Container(
                                                                    width: 34,
                                                                    height: 34,
                                                                    decoration: BoxDecoration(
                                                                      border: Border.all(
                                                                          color: const Color(
                                                                              0xFF9F86FF),
                                                                          width: 1.5),
                                                                      color: const Color(
                                                                          0xFFF8F6FF),
                                                                      borderRadius:
                                                                      BorderRadius
                                                                          .circular(4),
                                                                      boxShadow: [
                                                                        BoxShadow(
                                                                          color: const Color(
                                                                              0xFF418CFC33)
                                                                              .withOpacity(
                                                                              0.1),
                                                                          // Soft grey shadow
                                                                          spreadRadius: 1,
                                                                          blurRadius: 3,
                                                                          offset:
                                                                          const Offset(
                                                                              0, 1),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    child: Image.asset(
                                                                        "images/file.png",
                                                                        fit:
                                                                        BoxFit.scaleDown),
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                  height: 5,
                                                                ),
                                                                const Padding(
                                                                  padding: EdgeInsets.only(
                                                                      left: 10),
                                                                  child: Text(
                                                                    '0',
                                                                    style: TextStyle(
                                                                        fontSize: 25,
                                                                        fontWeight:
                                                                        FontWeight.bold),
                                                                  ),
                                                                ),
                                                                const Padding(
                                                                  padding: EdgeInsets.only(
                                                                      left: 10),
                                                                  child: Text(
                                                                    'Open Invoices',
                                                                    style: TextStyle(
                                                                      fontSize: 15,
                                                                      color: Color(0xFF455A64),),
                                                                  ),
                                                                )
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                        const EdgeInsets.only(top: 10,bottom: 10),
                                                        child: Card(
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                            BorderRadius.circular(10),
                                                          ),
                                                          color: Colors.white,
                                                          // Set the color to white
                                                          elevation: 2,
                                                          // equivalent to the boxShadow in the original code
                                                          child: Container(
                                                            // height: 140,
                                                            width: maxWidth * 0.15,
                                                            padding: const EdgeInsets.all(16),
                                                            decoration: BoxDecoration(
                                                              gradient: LinearGradient(
                                                                colors: [
                                                                  Colors.blue.shade100.withOpacity(0.1),// Light blue
                                                                  const Color(0xFFFFFFFF), // Grey
                                                                ],
                                                                begin: Alignment.topLeft,
                                                                end: Alignment.bottomRight,
                                                              ),
                                                              borderRadius: BorderRadius.circular(4),
                                                              boxShadow: [
                                                                BoxShadow(
                                                                  color: const Color(0xFFE5E5EA).withOpacity(0.1),
                                                                  spreadRadius: 1,
                                                                  blurRadius: 3,
                                                                  offset: const Offset(0, 1),
                                                                ),
                                                              ],
                                                            ),
                                                            child: Column(
                                                              crossAxisAlignment:
                                                              CrossAxisAlignment.start,
                                                              children: [
                                                                Padding(
                                                                  padding:
                                                                  const EdgeInsets.only(
                                                                      top: 3),
                                                                  child: Container(
                                                                    width: 34,
                                                                    height: 34,
                                                                    decoration: BoxDecoration(
                                                                      border: Border.all(
                                                                          color: const Color(
                                                                              0xFF0388AB),
                                                                          width: 1.5),
                                                                      color: const Color(
                                                                          0xFFF8F6FF),
                                                                      borderRadius:
                                                                      BorderRadius
                                                                          .circular(4),
                                                                      boxShadow: [
                                                                        BoxShadow(
                                                                          color: const Color(
                                                                              0xFF418CFC33)
                                                                              .withOpacity(
                                                                              0.1),
                                                                          // Soft grey shadow
                                                                          spreadRadius: 1,
                                                                          blurRadius: 3,
                                                                          offset:
                                                                          const Offset(
                                                                              0, 1),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    child: Image.asset(
                                                                        "images/dash.png",
                                                                        fit:
                                                                        BoxFit.scaleDown),
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                  height: 5,
                                                                ),
                                                                Padding(
                                                                  padding:
                                                                  const EdgeInsets.only(
                                                                      left: 10),
                                                                  child: Text(
                                                                    _dashboardCounts != null
                                                                        ? _dashboardCounts!
                                                                        .totalAmount
                                                                        .toString()
                                                                        : '0',
                                                                    style: const TextStyle(
                                                                        fontSize: 25,
                                                                        fontWeight:
                                                                        FontWeight.bold),
                                                                  ),
                                                                ),
                                                                const Padding(
                                                                  padding: EdgeInsets.only(
                                                                      left: 10),
                                                                  child: Text(
                                                                    'Available Credit Limit',
                                                                    style: TextStyle(
                                                                      fontSize: 15,
                                                                      color: Color(0xFF455A64), // Dark grey-blue
                                                                      fontWeight: FontWeight.w500,
                                                                      letterSpacing: 0.5,
                                                                    ),
                                                                  ),
                                                                )
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding: const EdgeInsets.only(
                                                            top: 10,bottom:10,right: 10
                                                        ),
                                                        child: MouseRegion(
                                                          onEnter: (_){setState(() {
                                                            orderhover = true;
                                                          });
                                                          },
                                                          onExit: (_){setState(() {
                                                            orderhover = false;
                                                          });
                                                          },
                                                          child: AnimatedScale(
                                                            scale: orderhover ? 1.05: 1.0,
                                                            duration:  const Duration(milliseconds: 200),
                                                            child: InkWell(
                                                              onTap: () {
                                                                context.go('/Order_Complete');
                                                                // Navigator.push(
                                                                //   context,
                                                                //   MaterialPageRoute(
                                                                //       builder: (context) =>
                                                                //           OrderList()),
                                                                // );
                                                              },
                                                              child: Card(
                                                                shape: RoundedRectangleBorder(
                                                                  borderRadius:
                                                                  BorderRadius.circular(10),
                                                                ),
                                                                color: Colors.white,
                                                                // Set the color to white
                                                                elevation: 2,
                                                                // equivalent to the boxShadow in the original code
                                                                child: Container(
                                                                  // height: 140,
                                                                  width: maxWidth * 0.15,
                                                                  padding:
                                                                  const EdgeInsets.all(16),
                                                                  decoration: BoxDecoration(
                                                                    gradient: const  LinearGradient(
                                                                      colors: [
                                                                        Color(0xFFC6F4B6), // Light green
                                                                        Color(0xFFFFFFFF), // White
                                                                      ],
                                                                      begin: Alignment.topLeft,
                                                                      end: Alignment.bottomRight,
                                                                    ),
                                                                    borderRadius: BorderRadius.circular(8),
                                                                    boxShadow: [
                                                                      BoxShadow(
                                                                        color: Colors.white.withOpacity(0.1),
                                                                        spreadRadius: 0,
                                                                        blurRadius: 3,
                                                                        offset: const Offset(0, 2),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  child: Column(
                                                                    crossAxisAlignment:
                                                                    CrossAxisAlignment.start,
                                                                    children: [
                                                                      Padding(
                                                                        padding:
                                                                        const EdgeInsets.only(
                                                                            top: 1),
                                                                        child: Container(
                                                                          width: 34,
                                                                          height: 34,
                                                                          decoration:
                                                                          BoxDecoration(
                                                                            border: Border.all(
                                                                                color: const Color(
                                                                                    0xFF19C92F),
                                                                                width: 1.5),
                                                                            color: const Color(
                                                                                0xFFBFFFC7),
                                                                            borderRadius:
                                                                            BorderRadius
                                                                                .circular(4),
                                                                            boxShadow: [
                                                                              BoxShadow(
                                                                                color: const Color(
                                                                                    0xFF418CFC33)
                                                                                    .withOpacity(
                                                                                    0.1),
                                                                                // Soft grey shadow
                                                                                spreadRadius: 1,
                                                                                blurRadius: 3,
                                                                                offset:
                                                                                const Offset(
                                                                                    0, 1),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                          child: Image.asset(
                                                                            "images/nk1.png",
                                                                            width: 35,
                                                                            height: 35,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      const SizedBox(
                                                                        height: 5,
                                                                      ),
                                                                      Padding(
                                                                        padding:
                                                                        const EdgeInsets.only(
                                                                            left: 10),
                                                                        child: Text(
                                                                          _dashboardCounts != null
                                                                              ? _dashboardCounts!
                                                                              .Delivered
                                                                              .toString()
                                                                              : '0',
                                                                          style: const TextStyle(
                                                                              fontSize: 25,
                                                                              fontWeight:
                                                                              FontWeight
                                                                                  .bold),
                                                                        ),
                                                                      ),
                                                                      const Padding(
                                                                        padding: EdgeInsets.only(
                                                                            left: 10),
                                                                        child: Text(
                                                                          'Order Completed',
                                                                          style: TextStyle(
                                                                            fontSize: 15,
                                                                            color: Color(0xFF455A64),),
                                                                        ),
                                                                      )
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ]

                                                )],
                                              ),
                                            ),
                                          ),
                                          if(constraints.maxWidth >= 1350)...{
                                            Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 1,
                                                    top: 50,
                                                    right: 1,
                                                    bottom: 10),
                                                child: Container(
                                                  height: 690,
                                                  width: maxWidth,
                                                  decoration: BoxDecoration(


                                                    color: Colors.white,
                                                    borderRadius:
                                                    BorderRadius.circular(8),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.black
                                                            .withOpacity(0.3),
                                                        // Soft grey shadow
                                                        spreadRadius: 3,
                                                        blurRadius: 3,
                                                        offset: const Offset(0, 3),
                                                      ),
                                                    ],
                                                  ),
                                                  child: SizedBox(
                                                    //width: maxWidth * 0.8,
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
                                                              child: buildDataTable1(),
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
                                                                //totalPages//totalPages,
                                                                // onFirstPage: _goToFirstPage,
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
                                          }
                                          else...{
                                            AdaptiveScrollbar(
                                              position: ScrollbarPosition.bottom,controller: horizontalScroll,
                                              child: SingleChildScrollView(
                                                controller: horizontalScroll,
                                                scrollDirection: Axis.horizontal,
                                                child: Padding(
                                                    padding: const EdgeInsets.only(
                                                        left: 1,
                                                        top: 50,
                                                        right: 1,
                                                        bottom: 10),
                                                    child: Container(
                                                      height: 690,
                                                      width: 1200,
                                                      decoration: BoxDecoration(


                                                        color: Colors.white,
                                                        borderRadius:
                                                        BorderRadius.circular(8),
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: Colors.black
                                                                .withOpacity(0.3),
                                                            // Soft grey shadow
                                                            spreadRadius: 3,
                                                            blurRadius: 3,
                                                            offset: const Offset(0, 3),
                                                          ),
                                                        ],
                                                      ),
                                                      child: SizedBox(
                                                        //width: maxWidth * 0.8,
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
                                                                  child: buildDataTable2(),
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
                                                                    //totalPages//totalPages,
                                                                    // onFirstPage: _goToFirstPage,
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
                                              ),

                                            ),


                                          }

                                        ],
                                      ),
                                    ),
                                  ),
                                } else...{
                                 AdaptiveScrollbar(
                                 position: ScrollbarPosition.bottom,controller: horizontalScroll,
                                   child: SingleChildScrollView(
                                       controller: horizontalScroll,
                                       scrollDirection: Axis.horizontal,
                                     child:  Padding(
                                       padding: const EdgeInsets.only(
                                           left: 50, right: 50, top: 10),
                                       child: Container(
                                         color: Colors.white
                                         ,
                                         width: 1200,
                                         child: Column(
                                           children: [
                                             Padding(
                                               padding: const EdgeInsets.only(
                                                   left: 1, right: 1, top: 5),
                                               child: Container(
                                                 color: Colors.grey[50],
                                                 child: Column(
                                                   children: [Row(
                                                       mainAxisAlignment:
                                                       MainAxisAlignment.spaceBetween,
                                                       children: [
                                                         Padding(
                                                           padding:
                                                           EdgeInsets.only(top: 10,bottom: 10,left: 10),
                                                           child: MouseRegion(
                                                             onEnter: (_){
                                                               setState(() {
                                                                 _isHovered2 = true;
                                                               });
                                                             },
                                                             onExit: (_){
                                                               setState(() {
                                                                 _isHovered2 = false;
                                                               });
                                                             },

                                                             child: AnimatedScale  (
                                                               scale: _isHovered2 ? 1.05: 1.0,
                                                               duration:  const Duration(milliseconds: 200),
                                                               child: InkWell(
                                                                 onTap: () {
                                                                   context.go('/Open_Order');
                                                                   // Navigator.push(
                                                                   //   context,
                                                                   //   MaterialPageRoute(
                                                                   //       builder: (context) =>
                                                                   //           OpenorderList()),
                                                                   // );
                                                                 },
                                                                 // splashColor: Colors.grey.withOpacity(0.2),
                                                                 child: Card(
                                                                   //  margin:  const EdgeInsets.only(left: 1, top: 20,),
                                                                   shape: RoundedRectangleBorder(
                                                                     borderRadius:
                                                                     BorderRadius.circular(10),
                                                                   ),
                                                                   color: Colors.grey,
                                                                   elevation: 2,
                                                                   // equivalent to the boxShadow in the original code
                                                                   child: Container(
                                                                     // height: 140,
                                                                     width: 200,
                                                                     padding:
                                                                     const EdgeInsets.all(16),
                                                                     decoration: BoxDecoration(
                                                                       // color: Colors.white10,
                                                                       gradient: LinearGradient(
                                                                         colors: [
                                                                           const Color(0xFFFFE5B4).withOpacity(0.9),
                                                                           //Color(0xFFFFCCBC),
                                                                           const Color(0xFFFFFFFF),
                                                                           // Your color
                                                                           // Slightly darker shade of your color
                                                                         ],
                                                                         begin: Alignment.topLeft,
                                                                         end: Alignment.bottomRight,
                                                                       ),
                                                                       borderRadius: BorderRadius.circular(8),
                                                                       boxShadow: [
                                                                         BoxShadow(
                                                                           color: const Color(0xFFFFD7BE).withOpacity(0.1),
                                                                           spreadRadius: 0,
                                                                           blurRadius: 3,
                                                                           offset: const Offset(0, 2),
                                                                         ),
                                                                       ],
                                                                     ),
                                                                     child: Column(
                                                                       crossAxisAlignment:
                                                                       CrossAxisAlignment.start,
                                                                       children: [
                                                                         Padding(
                                                                           padding:
                                                                           const EdgeInsets.only(
                                                                               top: 3),
                                                                           child: Container(
                                                                               width: 34,
                                                                               height: 34,
                                                                               decoration:
                                                                               BoxDecoration(
                                                                                 border: Border.all(
                                                                                     color: const Color(
                                                                                         0xFFFFAE8F),
                                                                                     width: 1.5),
                                                                                 color: const Color(
                                                                                     0xFFFFF9F7),
                                                                                 borderRadius:
                                                                                 BorderRadius
                                                                                     .circular(
                                                                                     4),
                                                                                 boxShadow: [
                                                                                   BoxShadow(
                                                                                     color: const Color(
                                                                                         0xFF418CFC33)
                                                                                         .withOpacity(
                                                                                         0.1),
                                                                                     // Soft grey shadow
                                                                                     spreadRadius: 1,
                                                                                     blurRadius: 3,
                                                                                     offset:
                                                                                     const Offset(
                                                                                         0, 1),
                                                                                   ),
                                                                                 ],
                                                                               ),
                                                                               child: Image.asset(
                                                                                 "images/open.png",
                                                                                 width: 20,
                                                                                 // Replace with your desired width
                                                                                 height: 20,
                                                                                 // Replace with your desired height
                                                                                 fit: BoxFit
                                                                                     .contain, // This will maintain the aspect ratio
                                                                               )),
                                                                         ),
                                                                         const SizedBox(
                                                                           height: 5,
                                                                         ),
                                                                         Padding(
                                                                           padding:
                                                                           const EdgeInsets.only(
                                                                               left: 10),
                                                                           child: Text(
                                                                             _dashboardCounts != null
                                                                                 ? _dashboardCounts!
                                                                                 .openOrders
                                                                                 .toString()
                                                                                 : '0',
                                                                             style: const TextStyle(
                                                                                 fontSize: 25,
                                                                                 fontWeight:
                                                                                 FontWeight
                                                                                     .bold),
                                                                           ),
                                                                         ),
                                                                         const Padding(
                                                                           padding: EdgeInsets.only(
                                                                               left: 10),
                                                                           child: Text(
                                                                             'Open Orders',
                                                                             style: TextStyle(
                                                                               fontSize: 15,
                                                                               color: Color(0xFF455A64),),
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
                                                         Padding(
                                                           padding:
                                                           const EdgeInsets.only(top: 10,bottom: 10),
                                                           child: Card(
                                                             // margin:  EdgeInsets.only(left: 600, top: 150),
                                                             shape: RoundedRectangleBorder(
                                                               borderRadius:
                                                               BorderRadius.circular(10),
                                                             ),
                                                             color: Colors.white,
                                                             // Set the color to white
                                                             elevation: 2,
                                                             // equivalent to the boxShadow in the original code
                                                             child: Container(
                                                               // height: 140,
                                                               width: 200,
                                                               padding: const EdgeInsets.all(16),
                                                               decoration: BoxDecoration(
                                                                 gradient: LinearGradient(
                                                                   colors: [
                                                                     const Color.fromRGBO(218, 180, 255, 0.8).withOpacity(0.1),
                                                                     //Color.fromRGBO(159, 134, 255, 0.8),
                                                                     // Color(0xFF9F86FF),
                                                                     const Color(0xFFFFFFFF),
                                                                     // Icon background color
                                                                     // Slightly darker shade of the icon background color
                                                                   ],
                                                                   begin: Alignment.topLeft,
                                                                   end: Alignment.bottomRight,
                                                                 ),
                                                                 borderRadius: BorderRadius.circular(8),
                                                                 boxShadow: [
                                                                   BoxShadow(
                                                                     color: const Color(0xFFE5D8F2).withOpacity(0.1),
                                                                     spreadRadius: 2,
                                                                     blurRadius: 3,
                                                                     offset: const Offset(0, 1),
                                                                   ),
                                                                 ],
                                                               ),
                                                               child: Column(
                                                                 crossAxisAlignment:
                                                                 CrossAxisAlignment.start,
                                                                 children: [
                                                                   Padding(
                                                                     padding:
                                                                     const EdgeInsets.only(
                                                                         top: 3),
                                                                     child: Container(
                                                                       width: 34,
                                                                       height: 34,
                                                                       decoration: BoxDecoration(
                                                                         border: Border.all(
                                                                             color: const Color(
                                                                                 0xFF9F86FF),
                                                                             width: 1.5),
                                                                         color: const Color(
                                                                             0xFFF8F6FF),
                                                                         borderRadius:
                                                                         BorderRadius
                                                                             .circular(4),
                                                                         boxShadow: [
                                                                           BoxShadow(
                                                                             color: const Color(
                                                                                 0xFF418CFC33)
                                                                                 .withOpacity(
                                                                                 0.1),
                                                                             // Soft grey shadow
                                                                             spreadRadius: 1,
                                                                             blurRadius: 3,
                                                                             offset:
                                                                             const Offset(
                                                                                 0, 1),
                                                                           ),
                                                                         ],
                                                                       ),
                                                                       child: Image.asset(
                                                                           "images/file.png",
                                                                           fit:
                                                                           BoxFit.scaleDown),
                                                                     ),
                                                                   ),
                                                                   const SizedBox(
                                                                     height: 5,
                                                                   ),
                                                                   const Padding(
                                                                     padding: EdgeInsets.only(
                                                                         left: 10),
                                                                     child: Text(
                                                                       '0',
                                                                       style: TextStyle(
                                                                           fontSize: 25,
                                                                           fontWeight:
                                                                           FontWeight.bold),
                                                                     ),
                                                                   ),
                                                                   const Padding(
                                                                     padding: EdgeInsets.only(
                                                                         left: 10),
                                                                     child: Text(
                                                                       'Open Invoices',
                                                                       style: TextStyle(
                                                                         fontSize: 15,
                                                                         color: Color(0xFF455A64),),
                                                                     ),
                                                                   )
                                                                 ],
                                                               ),
                                                             ),
                                                           ),
                                                         ),
                                                         Padding(
                                                           padding:
                                                           const EdgeInsets.only(top: 10,bottom: 10),
                                                           child: Card(
                                                             shape: RoundedRectangleBorder(
                                                               borderRadius:
                                                               BorderRadius.circular(10),
                                                             ),
                                                             color: Colors.white,
                                                             // Set the color to white
                                                             elevation: 2,
                                                             // equivalent to the boxShadow in the original code
                                                             child: Container(
                                                               // height: 140,
                                                               width: 200,
                                                               padding: const EdgeInsets.all(16),
                                                               decoration: BoxDecoration(
                                                                 gradient: LinearGradient(
                                                                   colors: [
                                                                     Colors.blue.shade100.withOpacity(0.1),// Light blue
                                                                     const Color(0xFFFFFFFF), // Grey
                                                                   ],
                                                                   begin: Alignment.topLeft,
                                                                   end: Alignment.bottomRight,
                                                                 ),
                                                                 borderRadius: BorderRadius.circular(4),
                                                                 boxShadow: [
                                                                   BoxShadow(
                                                                     color: const Color(0xFFE5E5EA).withOpacity(0.1),
                                                                     spreadRadius: 1,
                                                                     blurRadius: 3,
                                                                     offset: const Offset(0, 1),
                                                                   ),
                                                                 ],
                                                               ),
                                                               child: Column(
                                                                 crossAxisAlignment:
                                                                 CrossAxisAlignment.start,
                                                                 children: [
                                                                   Padding(
                                                                     padding:
                                                                     const EdgeInsets.only(
                                                                         top: 3),
                                                                     child: Container(
                                                                       width: 34,
                                                                       height: 34,
                                                                       decoration: BoxDecoration(
                                                                         border: Border.all(
                                                                             color: const Color(
                                                                                 0xFF0388AB),
                                                                             width: 1.5),
                                                                         color: const Color(
                                                                             0xFFF8F6FF),
                                                                         borderRadius:
                                                                         BorderRadius
                                                                             .circular(4),
                                                                         boxShadow: [
                                                                           BoxShadow(
                                                                             color: const Color(
                                                                                 0xFF418CFC33)
                                                                                 .withOpacity(
                                                                                 0.1),
                                                                             // Soft grey shadow
                                                                             spreadRadius: 1,
                                                                             blurRadius: 3,
                                                                             offset:
                                                                             const Offset(
                                                                                 0, 1),
                                                                           ),
                                                                         ],
                                                                       ),
                                                                       child: Image.asset(
                                                                           "images/dash.png",
                                                                           fit:
                                                                           BoxFit.scaleDown),
                                                                     ),
                                                                   ),
                                                                   const SizedBox(
                                                                     height: 5,
                                                                   ),
                                                                   Padding(
                                                                     padding:
                                                                     const EdgeInsets.only(
                                                                         left: 10),
                                                                     child: Text(
                                                                       _dashboardCounts != null
                                                                           ? _dashboardCounts!
                                                                           .totalAmount
                                                                           .toString()
                                                                           : '0',
                                                                       style: const TextStyle(
                                                                           fontSize: 25,
                                                                           fontWeight:
                                                                           FontWeight.bold),
                                                                     ),
                                                                   ),
                                                                   const Padding(
                                                                     padding: EdgeInsets.only(
                                                                         left: 10),
                                                                     child: Text(
                                                                       'Available Credit Limit',
                                                                       style: TextStyle(
                                                                         fontSize: 15,
                                                                         color: Color(0xFF455A64), // Dark grey-blue
                                                                         fontWeight: FontWeight.w500,
                                                                         letterSpacing: 0.5,
                                                                       ),
                                                                     ),
                                                                   )
                                                                 ],
                                                               ),
                                                             ),
                                                           ),
                                                         ),
                                                         Padding(
                                                           padding: const EdgeInsets.only(
                                                               top: 10,bottom:10,right: 10
                                                           ),
                                                           child: MouseRegion(
                                                             onEnter: (_){setState(() {
                                                               orderhover = true;
                                                             });
                                                             },
                                                             onExit: (_){setState(() {
                                                               orderhover = false;
                                                             });
                                                             },
                                                             child: AnimatedScale(
                                                               scale: orderhover ? 1.05: 1.0,
                                                               duration:  const Duration(milliseconds: 200),
                                                               child: InkWell(
                                                                 onTap: () {
                                                                   context.go('/Order_Complete');
                                                                   // Navigator.push(
                                                                   //   context,
                                                                   //   MaterialPageRoute(
                                                                   //       builder: (context) =>
                                                                   //           OrderList()),
                                                                   // );
                                                                 },
                                                                 child: Card(
                                                                   shape: RoundedRectangleBorder(
                                                                     borderRadius:
                                                                     BorderRadius.circular(10),
                                                                   ),
                                                                   color: Colors.white,
                                                                   // Set the color to white
                                                                   elevation: 2,
                                                                   // equivalent to the boxShadow in the original code
                                                                   child: Container(
                                                                     // height: 140,
                                                                     width: 200,
                                                                     padding:
                                                                     const EdgeInsets.all(16),
                                                                     decoration: BoxDecoration(
                                                                       gradient: const  LinearGradient(
                                                                         colors: [
                                                                           Color(0xFFC6F4B6), // Light green
                                                                           Color(0xFFFFFFFF), // White
                                                                         ],
                                                                         begin: Alignment.topLeft,
                                                                         end: Alignment.bottomRight,
                                                                       ),
                                                                       borderRadius: BorderRadius.circular(8),
                                                                       boxShadow: [
                                                                         BoxShadow(
                                                                           color: Colors.white.withOpacity(0.1),
                                                                           spreadRadius: 0,
                                                                           blurRadius: 3,
                                                                           offset: const Offset(0, 2),
                                                                         ),
                                                                       ],
                                                                     ),
                                                                     child: Column(
                                                                       crossAxisAlignment:
                                                                       CrossAxisAlignment.start,
                                                                       children: [
                                                                         Padding(
                                                                           padding:
                                                                           const EdgeInsets.only(
                                                                               top: 1),
                                                                           child: Container(
                                                                             width: 34,
                                                                             height: 34,
                                                                             decoration:
                                                                             BoxDecoration(
                                                                               border: Border.all(
                                                                                   color: const Color(
                                                                                       0xFF19C92F),
                                                                                   width: 1.5),
                                                                               color: const Color(
                                                                                   0xFFBFFFC7),
                                                                               borderRadius:
                                                                               BorderRadius
                                                                                   .circular(4),
                                                                               boxShadow: [
                                                                                 BoxShadow(
                                                                                   color: const Color(
                                                                                       0xFF418CFC33)
                                                                                       .withOpacity(
                                                                                       0.1),
                                                                                   // Soft grey shadow
                                                                                   spreadRadius: 1,
                                                                                   blurRadius: 3,
                                                                                   offset:
                                                                                   const Offset(
                                                                                       0, 1),
                                                                                 ),
                                                                               ],
                                                                             ),
                                                                             child: Image.asset(
                                                                               "images/nk1.png",
                                                                               width: 35,
                                                                               height: 35,
                                                                             ),
                                                                           ),
                                                                         ),
                                                                         const SizedBox(
                                                                           height: 5,
                                                                         ),
                                                                         Padding(
                                                                           padding:
                                                                           const EdgeInsets.only(
                                                                               left: 10),
                                                                           child: Text(
                                                                             _dashboardCounts != null
                                                                                 ? _dashboardCounts!
                                                                                 .Delivered
                                                                                 .toString()
                                                                                 : '0',
                                                                             style: const TextStyle(
                                                                                 fontSize: 25,
                                                                                 fontWeight:
                                                                                 FontWeight
                                                                                     .bold),
                                                                           ),
                                                                         ),
                                                                         const Padding(
                                                                           padding: EdgeInsets.only(
                                                                               left: 10),
                                                                           child: Text(
                                                                             'Order Completed',
                                                                             style: TextStyle(
                                                                               fontSize: 15,
                                                                               color: Color(0xFF455A64),),
                                                                           ),
                                                                         )
                                                                       ],
                                                                     ),
                                                                   ),
                                                                 ),
                                                               ),
                                                             ),
                                                           ),
                                                         ),
                                                       ]

                                                   )],
                                                 ),
                                               ),
                                             ),
                                             if(constraints.maxWidth >= 1350)...{
                                               Padding(
                                                   padding: const EdgeInsets.only(
                                                       left: 1,
                                                       top: 50,
                                                       right: 1,
                                                       bottom: 10),
                                                   child: Container(
                                                     height: 690,
                                                     width: maxWidth,
                                                     decoration: BoxDecoration(


                                                       color: Colors.white,
                                                       borderRadius:
                                                       BorderRadius.circular(8),
                                                       boxShadow: [
                                                         BoxShadow(
                                                           color: Colors.black
                                                               .withOpacity(0.3),
                                                           // Soft grey shadow
                                                           spreadRadius: 3,
                                                           blurRadius: 3,
                                                           offset: const Offset(0, 3),
                                                         ),
                                                       ],
                                                     ),
                                                     child: SizedBox(
                                                       //width: maxWidth * 0.8,
                                                       child: Column(
                                                         crossAxisAlignment:
                                                         CrossAxisAlignment.start,
                                                         children: [
                                                           buildSearchField2(),
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
                                                                 child: buildDataTable1(),
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
                                                                   //totalPages//totalPages,
                                                                   // onFirstPage: _goToFirstPage,
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
                                             }
                                             else...{
                                               Padding(
                                                   padding: const EdgeInsets.only(
                                                       left: 1,
                                                       top: 50,
                                                       right: 1,
                                                       bottom: 10),
                                                   child: Container(
                                                     height: 690,
                                                     width: 1000,
                                                     decoration: BoxDecoration(


                                                       color: Colors.white,
                                                       borderRadius:
                                                       BorderRadius.circular(8),
                                                       boxShadow: [
                                                         BoxShadow(
                                                           color: Colors.black
                                                               .withOpacity(0.3),
                                                           // Soft grey shadow
                                                           spreadRadius: 3,
                                                           blurRadius: 3,
                                                           offset: const Offset(0, 3),
                                                         ),
                                                       ],
                                                     ),
                                                     child: SizedBox(
                                                       //width: maxWidth * 0.8,
                                                       child: Column(
                                                         crossAxisAlignment:
                                                         CrossAxisAlignment.start,
                                                         children: [
                                                           buildSearchField2(),
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
                                                                 child: buildDataTable2(),
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
                                                                   //totalPages//totalPages,
                                                                   // onFirstPage: _goToFirstPage,
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


                                             }

                                           ],
                                         ),
                                       ),
                                     )
                                 ),),



                                }

                              ],
                                                        ),
                                                      ),
                            ))
                      ],
                    ),
                  )
                ],
              );
            }),
          ),
    );
  }




  List<Widget> _buildMenuItems(BuildContext context) {
    return [
      Column(
        children: [

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
              ),
              child: _buildMenuItem('Home', Icons.home_outlined, Colors.white, '/Home')),
        ],
      ),
      // _buildMenuItem('Home', Icons.dashboard, Colors.blueAccent, '/Home'),
      _buildMenuItem('Customer', Icons.account_circle, Colors.blue[900]!, '/Customer'),
      _buildMenuItem('Products', Icons.image_outlined, Colors.blue[900]!, '/Product_List'),
      _buildMenuItem('Orders', Icons.warehouse_outlined, Colors.blue[900]!, '/Order_List'),
      _buildMenuItem('Invoice', Icons.document_scanner_outlined, Colors.blue[900]!, '/Invoice'),
      _buildMenuItem('Delivery', Icons.fire_truck_outlined, Colors.blue[900]!, '/Delivery_List'),
      _buildMenuItem('Payment', Icons.payment_rounded, Colors.blue[900]!, '/Payment_List'),
      _buildMenuItem('Return', Icons.keyboard_return, Colors.blue[900]!, '/Return_List'),
      _buildMenuItem('Reports', Icons.insert_chart_outlined, Colors.blue[900]!, '/Report_List'),
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
                      decoration: const InputDecoration(
                        hintText: 'Search by Order ID',
                        hintStyle: TextStyle(color: Colors.grey, fontSize: 13),
                        contentPadding: EdgeInsets.only(bottom: 20, left: 10),
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
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //  const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.only(left: 30),
                      child: Container(
                        width: 150, // reduced width
                        height: 35, // reduced height
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(2),
                          border: Border.all(color: Colors.grey),
                        ),
                        child:
                        DropdownButtonFormField2<String>(
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.only(bottom: 15, left: 9), // Custom padding
                            border: InputBorder.none, // No default border
                            filled: true,
                            fillColor: Colors.white, // Background color
                          ),
                          isExpanded: true, // Ensures dropdown takes full width
                          value: dropdownValue1,
                          onChanged: (String? newValue) {
                            setState(() {
                              dropdownValue1 = newValue;
                              status = newValue ?? '';
                              _filterAndPaginateProducts();
                            });
                          },
                          items: <String>[
                            'Delivery Status',
                            'Not Started',
                            'In Progress',
                            'Delivered',
                          ].map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                value,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: value == 'Delivery Status' ? Colors.grey : Colors.black,
                                ),
                              ),
                            );
                          }).toList(),
                          iconStyleData: const IconStyleData(
                            icon: Icon(
                              Icons.arrow_drop_down_circle_rounded,
                              color: Colors.indigo,
                              size: 16,
                            ),
                            iconSize: 16,
                          ),
                          buttonStyleData: const ButtonStyleData(
                            height: 50, // Button height
                            padding: EdgeInsets.only(left: 10, right: 10), // Button padding
                          ),
                          dropdownStyleData: DropdownStyleData(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(7), // Rounded corners
                              color: Colors.white, // Dropdown background color
                            ),
                            maxHeight: 200, // Max height for dropdown items
                            width: maxWidth1 * 0.1, // Dropdown width
                            offset:  const Offset(0, -20),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                // const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        width: 150, // reduced width
                        height: 35, // reduced height
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(2),
                          border: Border.all(color: Colors.grey),
                        ),
                        child: DropdownButtonFormField2<String>(
                          decoration: const InputDecoration(
                            contentPadding:
                            EdgeInsets.only(bottom: 15, left: 10),
                            // adjusted padding
                            border: InputBorder.none,
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          //icon: Container(),
                          value: dropdownValue2,
                          onChanged: (String? newValue) {
                            setState(() {
                              selectDate = newValue ?? '';
                              dropdownValue2 = newValue;
                              _filterAndPaginateProducts();
                            });
                          },
                          items: <String>['Select Year', '2023', '2024', '2025']
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                value,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: value == 'Select Year'
                                      ? Colors.grey
                                      : Colors.black,
                                ),
                              ),
                            );
                          }).toList(),
                          iconStyleData: const IconStyleData(
                            icon: Icon(
                              Icons.arrow_drop_down_circle_rounded,
                              color: Colors.indigo,
                              size: 16,
                            ),
                            iconSize: 16,
                          ),
                          buttonStyleData: const ButtonStyleData(
                            height: 50, // Button height
                            padding: EdgeInsets.only(left: 10, right: 10), // Button padding
                          ),
                          dropdownStyleData: DropdownStyleData(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(7), // Rounded corners
                              color: Colors.white, // Dropdown background color
                            ),
                            maxHeight: 200, // Max height for dropdown items
                            width: maxWidth1 * 0.1, // Dropdown width
                            offset:  const Offset(0, -20),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
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
                      decoration: const InputDecoration(
                        hintText: 'Search by Order ID',
                        hintStyle: TextStyle(color: Colors.grey, fontSize: 13),
                        contentPadding: EdgeInsets.only(bottom: 20, left: 10),
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
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //  const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.only(left: 30),
                      child: Container(
                        width: maxWidth1 * 0.1, // reduced width
                        height: 35, // reduced height
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(2),
                          border: Border.all(color: Colors.grey),
                        ),
                        child:
                        DropdownButtonFormField2<String>(
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.only(bottom: 15, left: 9), // Custom padding
                            border: InputBorder.none, // No default border
                            filled: true,
                            fillColor: Colors.white, // Background color
                          ),
                          isExpanded: true, // Ensures dropdown takes full width
                          value: dropdownValue1,
                          onChanged: (String? newValue) {
                            setState(() {
                              dropdownValue1 = newValue;
                              status = newValue ?? '';
                              _filterAndPaginateProducts();
                            });
                          },
                          items: <String>[
                            'Delivery Status',
                            'Not Started',
                            'In Progress',
                            'Delivered',
                          ].map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                value,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: value == 'Delivery Status' ? Colors.grey : Colors.black,
                                ),
                              ),
                            );
                          }).toList(),
                          iconStyleData: const IconStyleData(
                            icon: Icon(
                              Icons.arrow_drop_down_circle_rounded,
                              color: Colors.indigo,
                              size: 16,
                            ),
                            iconSize: 16,
                          ),
                          buttonStyleData: const ButtonStyleData(
                            height: 50, // Button height
                            padding: EdgeInsets.only(left: 10, right: 10), // Button padding
                          ),
                          dropdownStyleData: DropdownStyleData(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(7), // Rounded corners
                              color: Colors.white, // Dropdown background color
                            ),
                            maxHeight: 200, // Max height for dropdown items
                            width: maxWidth1 * 0.1, // Dropdown width
                            offset:  const Offset(0, -20),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                // const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        width: maxWidth1 * 0.095, // reduced width
                        height: 35, // reduced height
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(2),
                          border: Border.all(color: Colors.grey),
                        ),
                        child: DropdownButtonFormField2<String>(
                          decoration: const InputDecoration(
                            contentPadding:
                                EdgeInsets.only(bottom: 15, left: 10),
                            // adjusted padding
                            border: InputBorder.none,
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          //icon: Container(),
                          value: dropdownValue2,
                          onChanged: (String? newValue) {
                            setState(() {
                              selectDate = newValue ?? '';
                              dropdownValue2 = newValue;
                              _filterAndPaginateProducts();
                            });
                          },
                          items: <String>['Select Year', '2023', '2024', '2025']
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                value,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: value == 'Select Year'
                                      ? Colors.grey
                                      : Colors.black,
                                ),
                              ),
                            );
                          }).toList(),
                          iconStyleData: const IconStyleData(
                            icon: Icon(
                              Icons.arrow_drop_down_circle_rounded,
                              color: Colors.indigo,
                              size: 16,
                            ),
                            iconSize: 16,
                          ),
                          buttonStyleData: const ButtonStyleData(
                            height: 50, // Button height
                            padding: EdgeInsets.only(left: 10, right: 10), // Button padding
                          ),
                          dropdownStyleData: DropdownStyleData(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(7), // Rounded corners
                              color: Colors.white, // Dropdown background color
                            ),
                            maxHeight: 200, // Max height for dropdown items
                            width: maxWidth1 * 0.1, // Dropdown width
                            offset:  const Offset(0, -20),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
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
            width: right -200,
            decoration: const BoxDecoration(
                color: Color(0xFFF7F7F7),
                border: Border.symmetric(
                    horizontal: BorderSide(color: Colors.grey, width: 0.5))),
            child: DataTable(
                showCheckboxColumn: false,
                headingRowHeight: 40,
                columns: [
                  DataColumn(
                      label: Container(
                          child: Text(
                            'Order ID',
                            style: TextStyle(
                                color: Colors.indigo[900],
                                fontSize: 13,
                                fontWeight: FontWeight.bold),
                          ))),
                  DataColumn(
                      label: Text(
                        'Created Date',
                        style: TextStyle(
                            color: Colors.indigo[900],
                            fontSize: 13,
                            fontWeight: FontWeight.bold),
                      )),
                  DataColumn(
                      label: Container(
                          child: Text(
                            'Delivery Date',
                            style: TextStyle(
                                color: Colors.indigo[900],
                                fontSize: 13,
                                fontWeight: FontWeight.bold),
                          ))),
                  DataColumn(
                      label: Container(
                          child: Text(
                            'Total Amount',
                            style: TextStyle(
                                color: Colors.indigo[900],
                                fontSize: 13,
                                fontWeight: FontWeight.bold),
                          ))),
                  DataColumn(
                      label: Container(
                          child: Text(
                            'Delivery Status',
                            style: TextStyle(
                                color: Colors.indigo[900],
                                fontSize: 13,
                                fontWeight: FontWeight.bold),
                          ))),
                  DataColumn(
                      label: Container(
                          child: Text(
                            'Payment',
                            style: TextStyle(
                                color: Colors.indigo[900],
                                fontSize: 13,
                                fontWeight: FontWeight.bold),
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
            return a.createdDate!.compareTo(b.createdDate!);
          } else if (columnIndex == 2) {
            return a.deliveredDate!.compareTo(b.deliveredDate!);
          } else if (columnIndex == 3) {
            return a.totalAmount!.compareTo(b.totalAmount!);
          } else if (columnIndex == 4) {
            return a.deliveryStatus.compareTo(b.deliveryStatus);
          } else if (columnIndex == 5) {
            return a.paymentStatus!.toLowerCase().compareTo(b.paymentStatus!.toLowerCase());
          } else {
            return 0;
          }
        });
      } else {
        filteredData1.sort((a, b) {
          if (columnIndex == 0) {
            return b.orderId!.compareTo(a.orderId!); // Reverse the comparison
          } else if (columnIndex == 1) {
            return b.createdDate!
                .compareTo(a.createdDate!); // Reverse the comparison
          } else if (columnIndex == 2) {
            return b.deliveredDate!
                .compareTo(a.deliveredDate!); // Reverse the comparison
          } else if (columnIndex == 3) {
            return b.totalAmount!
                .compareTo(a.totalAmount!); // Reverse the comparison
          } else if (columnIndex == 4) {
            return b.deliveryStatus
                .compareTo(a.deliveryStatus); // Reverse the comparison
          } else if (columnIndex == 5) {
            return b.paymentStatus!.toLowerCase()
                .compareTo(a.paymentStatus!.toLowerCase()); // Reverse the comparison
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
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.indigo[900],
                                  fontSize: 13,
                                ),
                              ),
                              //  if (columns.indexOf(column) > 0)
                              IconButton(
                                icon:
                                _sortOrder[columns.indexOf(column)] == 'asc'
                                    ? SizedBox(width: 12,
                                    child: Image.asset("images/sort.png",color: Colors.grey,))
                                    : SizedBox(width: 12,child: Image.asset("images/sort.png",color: Colors.blue,)),
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
                              //Padding(
                              //  padding:  EdgeInsets.only(left: columnWidths[index]-50,),
                              //  child:

                              const Spacer(),
                              MouseRegion(
                                cursor: SystemMouseCursors.resizeColumn,
                                child: GestureDetector(
                                    onHorizontalDragUpdate: (details) {
                                      // Update column width dynamically as user drags
                                      setState(() {
                                        columnWidths[columns.indexOf(column)] +=
                                            details.delta.dx;
                                        columnWidths[columns.indexOf(column)] =
                                            columnWidths[
                                            columns.indexOf(column)]
                                                .clamp(161.0, 300.0);
                                      });
                                      // setState(() {
                                      //   columnWidths[columns.indexOf(column)] += details.delta.dx;
                                      //   if (columnWidths[columns.indexOf(column)] < 50) {
                                      //     columnWidths[columns.indexOf(column)] = 50; // Minimum width
                                      //   }
                                      // });
                                    },
                                    child: const Padding(
                                      padding:
                                      EdgeInsets.only(top: 10, bottom: 10),
                                      child: Row(
                                        children: [
                                          VerticalDivider(
                                            width: 5,
                                            thickness: 4,
                                            color: Colors.grey,
                                          )
                                        ],
                                      ),
                                    )),
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
                        DataCell(Text(
                          detail.orderId.toString(),
                          style: TextStyle(
                            //fontSize: 16,
                            color: isSelected
                                ? Colors.deepOrange[200]
                                : const Color(0xFFFFB315),
                          ),
                        )),
                        DataCell(Text(
                          detail.createdDate!,
                          style: const TextStyle(
                            // fontSize: 16,
                              color: Colors.grey),
                        )),
                        DataCell(
                          Text(detail.deliveredDate!,
                              style: const TextStyle(
                                // fontSize: 16,
                                  color: Colors.grey)),
                        ),
                        DataCell(
                          Text(detail.totalAmount.toString(),
                              style: const TextStyle(
                                //fontSize: 16,
                                  color: Colors.grey)),
                        ),
                        DataCell(
                          Text(detail.deliveryStatus.toString(),
                              style: TextStyle(
                                // fontSize: 16,
                                  color: detail.deliveryStatus == "In Progress"
                                      ? Colors.orange
                                      : detail.deliveryStatus == "Delivered"
                                      ? Colors.green
                                      : Colors.red)),
                        ),
                        DataCell(
                          Text(detail.paymentStatus.toString(),
                              style: const TextStyle(
                                //fontSize: 16,
                                  color: Colors.grey)),
                        ),
                      ],
                      onSelectChanged: (selected) {
                        if (selected != null && selected) {
                          final orderId = detail
                              .orderId; // Capture the orderId of the selected row
                          final detail1 = filteredData.firstWhere(
                                  (element) => element.orderId == orderId);
                          //final detail1 = filteredData.skip((currentPage - 1) * itemsPerPage).elementAt(index);
                          //final detail = filteredData[(currentPage - 1) * itemsPerPage + index];

                          if (filteredData1.length <= 9) {
                            //fetchOrders();
                            PaymentMap = {
                              'paymentmode': detail.paymentMode,
                              'paymentStatus': detail.paymentStatus,
                              'paymentdate': detail.paymentDate,
                              'paidamount': detail.paidAmount,
                            };

                            context.go('/Order_Placed_List', extra: {
                              'product': detail1,
                              'item': [], // pass an empty list of maps
                              'arrow': 'Home',
                              'status': detail.deliveryStatus,
                              'paymentStatus': PaymentMap,
                              'body': {},
                              // 'status': detail.deliveryStatus,
                              'itemsList': [], // pass an empty list of maps
                              'orderDetails': filteredData
                                  .map((detail) => ors.OrderDetail(
                                orderId: detail.orderId,
                                orderDate: detail.orderDate, items: [],
                                // Add other fields as needed
                              ))
                                  .toList(),
                            });
                          } else {
                            PaymentMap = {
                              'paymentmode': detail.paymentMode,
                              'paymentStatus': detail.paymentStatus,
                              'paymentdate': detail.paymentDate,
                              'paidamount': detail.paidAmount,
                            };
                            context.go('/Order_Placed_List', extra: {
                              'product': detail1,
                              'arrow': 'Home',
                              'item': [], // pass an empty list of maps
                              'status': detail.deliveryStatus,
                              'paymentStatus': PaymentMap,
                              'body': {},
                              'itemsList': [], // pass an empty list of maps
                              'orderDetails': filteredData
                                  .map((detail) => ors.OrderDetail(
                                orderId: detail.orderId,
                                orderDate: detail.orderDate, items: [],
                                // Add other fields as needed
                              ))
                                  .toList(),
                            });

                          }
                        }
                      });
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
            width: right ,
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
                      label: Container(
                          child: Text(
                    'Order ID',
                    style: TextStyle(
                        color: Colors.indigo[900],
                        fontSize: 13,
                        fontWeight: FontWeight.bold),
                  ))),
                  DataColumn(
                      label: Text(
                    'Created Date',
                    style: TextStyle(
                        color: Colors.indigo[900],
                        fontSize: 13,
                        fontWeight: FontWeight.bold),
                  )),
                  DataColumn(
                      label: Container(
                          child: Text(
                    'Delivery Date',
                    style: TextStyle(
                        color: Colors.indigo[900],
                        fontSize: 13,
                        fontWeight: FontWeight.bold),
                  ))),
                  DataColumn(
                      label: Container(
                          child: Text(
                    'Total Amount',
                    style: TextStyle(
                        color: Colors.indigo[900],
                        fontSize: 13,
                        fontWeight: FontWeight.bold),
                  ))),
                  DataColumn(
                      label: Container(
                          child: Text(
                    'Delivery Status',
                    style: TextStyle(
                        color: Colors.indigo[900],
                        fontSize: 13,
                        fontWeight: FontWeight.bold),
                  ))),
                  DataColumn(
                      label: Container(
                          child: Text(
                    'Payment',
                    style: TextStyle(
                        color: Colors.indigo[900],
                        fontSize: 13,
                        fontWeight: FontWeight.bold),
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
            return a.createdDate!.compareTo(b.createdDate!);
          } else if (columnIndex == 2) {
            return a.deliveredDate!.compareTo(b.deliveredDate!);
          } else if (columnIndex == 3) {
            return a.totalAmount!.compareTo(b.totalAmount!);
          } else if (columnIndex == 4) {
            return a.deliveryStatus.compareTo(b.deliveryStatus);
          } else if (columnIndex == 5) {
            return a.paymentStatus!.toLowerCase().compareTo(b.paymentStatus!.toLowerCase());
          } else {
            return 0;
          }
        });
      } else {
        filteredData1.sort((a, b) {
          if (columnIndex == 0) {
            return b.orderId!.compareTo(a.orderId!); // Reverse the comparison
          } else if (columnIndex == 1) {
            return b.createdDate!
                .compareTo(a.createdDate!); // Reverse the comparison
          } else if (columnIndex == 2) {
            return b.deliveredDate!
                .compareTo(a.deliveredDate!); // Reverse the comparison
          } else if (columnIndex == 3) {
            return b.totalAmount!
                .compareTo(a.totalAmount!); // Reverse the comparison
          } else if (columnIndex == 4) {
            return b.deliveryStatus
                .compareTo(a.deliveryStatus); // Reverse the comparison
          } else if (columnIndex == 5) {
            return b.paymentStatus!.toLowerCase()
                .compareTo(a.paymentStatus!.toLowerCase()); // Reverse the comparison
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
            width: right- 200,
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
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.indigo[900],
                                  fontSize: 13,
                                ),
                              ),
                              //  if (columns.indexOf(column) > 0)
                              IconButton(
                                icon:
                                    _sortOrder[columns.indexOf(column)] == 'asc'
                                        ? SizedBox(width: 12,
                                        child: Image.asset("images/sort.png",color: Colors.grey,))
                                        : SizedBox(width: 12,child: Image.asset("images/sort.png",color: Colors.blue,)),
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
                              //Padding(
                              //  padding:  EdgeInsets.only(left: columnWidths[index]-50,),
                              //  child:

                              const Spacer(),
                              MouseRegion(
                                cursor: SystemMouseCursors.resizeColumn,
                                child: GestureDetector(
                                    onHorizontalDragUpdate: (details) {
                                      // Update column width dynamically as user drags
                                      setState(() {
                                        columnWidths[columns.indexOf(column)] +=
                                            details.delta.dx;
                                        columnWidths[columns.indexOf(column)] =
                                            columnWidths[
                                                    columns.indexOf(column)]
                                                .clamp(161.0, 300.0);
                                      });
                                      // setState(() {
                                      //   columnWidths[columns.indexOf(column)] += details.delta.dx;
                                      //   if (columnWidths[columns.indexOf(column)] < 50) {
                                      //     columnWidths[columns.indexOf(column)] = 50; // Minimum width
                                      //   }
                                      // });
                                    },
                                    child: const Padding(
                                      padding:
                                          EdgeInsets.only(top: 10, bottom: 10),
                                      child: Row(
                                        children: [
                                          VerticalDivider(
                                            width: 5,
                                            thickness: 4,
                                            color: Colors.grey,
                                          )
                                        ],
                                      ),
                                    )),
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
                        DataCell(Text(
                          detail.orderId.toString(),
                          style: TextStyle(
                            //fontSize: 16,
                            color: isSelected
                                ? Colors.deepOrange[200]
                                : const Color(0xFFFFB315),
                          ),
                        )),
                        DataCell(Text(
                          detail.createdDate!,
                          style: const TextStyle(
                              // fontSize: 16,
                              color: Colors.grey),
                        )),
                        DataCell(
                          Text(detail.deliveredDate!,
                              style: const TextStyle(
                                  // fontSize: 16,
                                  color: Colors.grey)),
                        ),
                        DataCell(
                          Text(detail.totalAmount.toString(),
                              style: const TextStyle(
                                  //fontSize: 16,
                                  color: Colors.grey)),
                        ),
                        DataCell(
                          Text(detail.deliveryStatus.toString(),
                              style: TextStyle(
                                  // fontSize: 16,
                                  color: detail.deliveryStatus == "In Progress"
                                      ? Colors.orange
                                      : detail.deliveryStatus == "Delivered"
                                          ? Colors.green
                                          : Colors.red)),
                        ),
                        DataCell(
                          Text(detail.paymentStatus.toString(),
                              style: const TextStyle(
                                  //fontSize: 16,
                                  color: Colors.grey)),
                        ),
                      ],
                      onSelectChanged: (selected) {
                        if (selected != null && selected) {
                          final orderId = detail
                              .orderId; // Capture the orderId of the selected row
                          final detail1 = filteredData.firstWhere(
                              (element) => element.orderId == orderId);
                          //final detail1 = filteredData.skip((currentPage - 1) * itemsPerPage).elementAt(index);
                          //final detail = filteredData[(currentPage - 1) * itemsPerPage + index];

                          if (filteredData1.length <= 9) {
                            //fetchOrders();
                            PaymentMap = {
                              'paymentmode': detail.paymentMode,
                              'paymentStatus': detail.paymentStatus,
                              'paymentdate': detail.paymentDate,
                              'paidamount': detail.paidAmount,
                            };

                            context.go('/Order_Placed_List', extra: {
                              'product': detail1,
                              'item': [], // pass an empty list of maps
                              'arrow': 'Home',
                              'status': detail.deliveryStatus,
                              'paymentStatus': PaymentMap,
                              'body': {},
                              // 'status': detail.deliveryStatus,
                              'itemsList': [], // pass an empty list of maps
                              'orderDetails': filteredData
                                  .map((detail) => ors.OrderDetail(
                                        orderId: detail.orderId,
                                        orderDate: detail.orderDate, items: [],
                                        // Add other fields as needed
                                      ))
                                  .toList(),
                            });
                          } else {
                            PaymentMap = {
                              'paymentmode': detail.paymentMode,
                              'paymentStatus': detail.paymentStatus,
                              'paymentdate': detail.paymentDate,
                              'paidamount': detail.paidAmount,
                            };
                            context.go('/Order_Placed_List', extra: {
                              'product': detail1,
                              'arrow': 'Home',
                              'item': [], // pass an empty list of maps
                              'status': detail.deliveryStatus,
                              'paymentStatus': PaymentMap,
                              'body': {},
                              'itemsList': [], // pass an empty list of maps
                              'orderDetails': filteredData
                                  .map((detail) => ors.OrderDetail(
                                        orderId: detail.orderId,
                                        orderDate: detail.orderDate, items: [],
                                        // Add other fields as needed
                                      ))
                                  .toList(),
                            });

                          }
                        }
                      });
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

  //final int? openInvoices;
  final int totalAmount;
  final int Delivered;

  DashboardCounts(
      {required this.openOrders,
      //   required this.openInvoices,
      required this.totalAmount,
      required this.Delivered});

  factory DashboardCounts.fromJson(Map<String, dynamic> json) {
    return DashboardCounts(
      openOrders: json['Not Started'],
      //    openInvoices: json['Open Invoices'],
      totalAmount: json['totalAmount'],
      Delivered: json['Delivered'],
    );
  }
}
