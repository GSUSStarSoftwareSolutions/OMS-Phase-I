import 'dart:async';
import 'dart:convert';
import 'dart:html';
import 'dart:math' as math;
import 'package:adaptive_scrollbar/adaptive_scrollbar.dart';
import 'package:btb/widgets/Api%20name.dart';
import 'package:btb/widgets/productclass.dart';
import 'package:btb/widgets/custom%20loading.dart';
import 'package:btb/widgets/pagination.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:btb/Order%20Module/firstpage.dart' as ors;
import '../../widgets/confirmdialog.dart';
import '../../widgets/no datafound.dart';
import '../../widgets/text_style.dart';


void main() {
  runApp(const DashboardPage1());
}

class DashboardPage1 extends StatefulWidget {
  const DashboardPage1({
    super.key,
  });

  @override
  State<DashboardPage1> createState() => _DashboardPage1State();
}

class _DashboardPage1State extends State<DashboardPage1>
    with SingleTickerProviderStateMixin {
  bool isHomeSelected = false;
  final ScrollController horizontalScroll = ScrollController();
  final ScrollController _scrollController = ScrollController();
  Timer? _searchDebounceTimer;
  String companyName = window.sessionStorage["company Name"] ?? " ";
  String userId = window.sessionStorage["userId"] ?? " ";
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
  bool _isHovered2 = false;
  bool _isHovered5 = false;
  bool orderhover = false;
  bool orderhover2 = false;
  Map<String, dynamic> paymentMap = {};
  String? dropdownValue1 = 'Delivery Status';
  String searchQuery = '';
  String token = window.sessionStorage["token"] ?? " ";
  String? role = window.sessionStorage["role"];
  String? dropdownValue2 = 'Select Year';

  int currentPage = 1;
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
  int itemsPerPage = 10;
  int totalItems = 0;
  int totalPages = 0;
  bool isLoading = false;
  List<ors.detail> filteredData1 = [];
  List<ors.detail> filteredData = [];
  List<ors.detail> productList = [];

  final List<String> _sortOrder = List.generate(5, (index) => 'asc');
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
          '$apicall/$companyName/order_master/get_all_ordermaster?page=$page&limit=$itemsPerPage',
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
                        const Icon(Icons.warning,
                            color: Colors.orange, size: 50),
                        const SizedBox(height: 16),
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
                                context.go('/');
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
            products = jsonData
                .map((item) => ors.detail.fromJson(item))
                .where((product) => product.CusId == userId)
                .toList();
          } else if (jsonData is Map && jsonData.containsKey('body')) {
            final body = jsonData['body'];
            if (body != null) {
              products = (body as List)
                  .map((item) => ors.detail.fromJson(item))
                  .where((product) => product.CusId == userId)
                  .toList();

              totalItems =
                  jsonData['totalItems'] ?? 0; // Get the total number of items
            }
          }

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
          '$apicall/$companyName/order_master/get_all_ordermaster',
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
                        const Icon(Icons.warning,
                            color: Colors.orange, size: 50),
                        const SizedBox(height: 16),
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
                                context.go('/');
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
      currentPage = 1;
      _filterAndPaginateProducts();
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
          orderYear = dateParts[2];
        }
      }

      if (status.isEmpty && selectDate.isEmpty) {
        return matchesSearchText;
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
            orderYear == selectDate;
      }
      if (status.isNotEmpty && selectDate == 'Select Year') {
        return matchesSearchText &&
            product.deliveryStatus == status;
      }
      if (status.isEmpty && selectDate.isNotEmpty) {
        return matchesSearchText &&
            orderYear == selectDate;
      }

      if (status.isNotEmpty && selectDate.isEmpty) {
        return matchesSearchText &&
            product.deliveryStatus == status;
      }
      return matchesSearchText &&
          (product.deliveryStatus == status && orderYear == selectDate);
    }).toList();
    totalPages = (filteredData1.length / itemsPerPage).ceil();
    setState(() {
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
          '$apicall/$companyName/order_master/get_customer_order_counts/$userId'),
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
                      const Icon(Icons.warning, color: Colors.orange, size: 50),
                      const SizedBox(height: 16),
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              context.go('/');
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
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.grey[50],
        body: LayoutBuilder(builder: (context, constraints) {
          double maxWidth = constraints.maxWidth;
          double maxHeight = constraints.maxHeight;
          return Stack(
            children: [
              Container(
                color: Colors.white,
                height: 60.0,
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
                            SizedBox(width: 10),
                            Padding(
                              padding: EdgeInsets.only(right: 10, top: 10),
                              child: AccountMenu(),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 7,
                    ),
                    const Divider(
                      height: 3.0,
                      thickness: 3.0,
                      color: Color(0x29000000),
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
                        padding: const EdgeInsets.only(top: 2),
                        child: Container(
                          height: 1400,
                          width: 200,
                          color: Colors.white,
                          padding: const EdgeInsets.only(
                              left: 15, top: 10, right: 15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: _buildMenuItems(context),
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
                    padding: const EdgeInsets.only(top: 62),
                    child: Container(
                      height: 1400,
                      width: 200,
                      color: Colors.white,
                      padding:
                          const EdgeInsets.only(left: 15, top: 10, right: 15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: _buildMenuItems(context),
                      ),
                    ),
                  ),
                ),
                VerticalDividerWidget(
                  height: maxHeight,
                  color: const Color(0x29000000),
                ),
              },
              Positioned(
                left: 200,
                top: 64,
                right: 0,
                bottom: 40,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 30),
                      child: Container(
                        decoration: const BoxDecoration(),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        height: 50,
                        child: Row(
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
                      ),
                    ),
                    Expanded(
                        // flex: 1,
                        child: Padding(
                      padding: const EdgeInsets.only(left: 30),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            if (constraints.maxWidth >= 1350) ...{
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 35, right: 50, top: 5),
                                child: SizedBox(
                                  width: maxWidth,
                                  child: Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 1, right: 1, top: 5),
                                        child: Container(
                                          child: Column(
                                            children: [
                                              Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 10,
                                                              bottom: 10,
                                                              left: 10),
                                                      child: MouseRegion(
                                                        onEnter: (_) {
                                                          setState(() {
                                                            _isHovered2 = true;
                                                          });
                                                        },
                                                        onExit: (_) {
                                                          setState(() {
                                                            _isHovered2 = false;
                                                          });
                                                        },
                                                        child: AnimatedScale(
                                                          scale: _isHovered2
                                                              ? 1.05
                                                              : 1.0,
                                                          duration:
                                                              const Duration(
                                                                  milliseconds:
                                                                      200),
                                                          child: InkWell(
                                                            onTap: () {

                                                            },
                                                            child: Container(
                                                              height: 115,
                                                              width: maxWidth *
                                                                  0.15,
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(16),
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: Colors
                                                                    .white,
                                                                border:
                                                                    Border.all(
                                                                  color: const Color(
                                                                      0x29000000),
                                                                ),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            15),
                                                              ),
                                                              child: Row(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  Padding(
                                                                    padding: const EdgeInsets
                                                                        .only(
                                                                        top: 3),
                                                                    child:
                                                                        Container(
                                                                      width: 60,
                                                                      height:
                                                                          60,
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        shape: BoxShape
                                                                            .circle,
                                                                        border:
                                                                            Border.all(
                                                                          color:
                                                                              const Color(0xffffac8c),
                                                                          // Border color
                                                                          width:
                                                                              1.5,
                                                                        ),
                                                                        color: const Color(0xffffac8c)
                                                                            .withOpacity(0.2),
                                                                        boxShadow: [
                                                                          BoxShadow(
                                                                            color:
                                                                                const Color(0xffffac8c).withOpacity(0.1),
                                                                            spreadRadius:
                                                                                1,
                                                                            blurRadius:
                                                                                3,
                                                                            offset:
                                                                                const Offset(0, 1),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                      child: SizedBox(
                                                                          width: 10,
                                                                          height: 10,
                                                                          child: Image.asset(
                                                                            "images/openorders.png",
                                                                          )),
                                                                    ),
                                                                  ),
                                                                  const SizedBox(
                                                                    height: 5,
                                                                  ),
                                                                  Column(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                        const SizedBox(
                                                                            height:
                                                                                10),
                                                                        Padding(
                                                                          padding: const EdgeInsets
                                                                              .only(
                                                                              left: 10),
                                                                          child:
                                                                              Text(
                                                                            _dashboardCounts != null
                                                                                ? _dashboardCounts!.openOrders.toString()
                                                                                : '0',
                                                                            style:
                                                                                const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                                                                          ),
                                                                        ),
                                                                        Padding(
                                                                          padding: const EdgeInsets
                                                                              .only(
                                                                              left: 10),
                                                                          child:
                                                                              Text(
                                                                            'Open Orders',
                                                                            style:
                                                                                TextStyle(
                                                                              fontSize: maxWidth * 0.01,
                                                                              color: const Color(0xFF455A64),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ])
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 10,
                                                              bottom: 10),
                                                      child: MouseRegion(
                                                        onEnter: (_) {
                                                          setState(() {
                                                            _isHovered5 = true;
                                                          });
                                                        },
                                                        onExit: (_) {
                                                          setState(() {
                                                            _isHovered5 = false;
                                                          });
                                                        },
                                                        child: AnimatedScale(
                                                          scale: _isHovered5
                                                              ? 1.05
                                                              : 1.0,
                                                          duration:
                                                              const Duration(
                                                                  milliseconds:
                                                                      200),
                                                          child: InkWell(
                                                            onTap: () {
                                                            },
                                                            child: Container(
                                                              height: 115,
                                                              width: maxWidth *
                                                                  0.15,
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(16),
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: Colors
                                                                    .white,
                                                                border:
                                                                    Border.all(
                                                                  color: const Color(
                                                                      0x29000000),
                                                                ),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            15),
                                                              ),
                                                              child: Row(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  Padding(
                                                                    padding: const EdgeInsets
                                                                        .only(
                                                                        top: 3),
                                                                    child:
                                                                        Container(
                                                                      width: 60,
                                                                      height:
                                                                          60,
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        shape: BoxShape
                                                                            .circle,
                                                                        border: Border.all(
                                                                            color:
                                                                                const Color(0xFF9F86FF),
                                                                            width: 1.5),
                                                                        color: const Color(0xFF9F86FF)
                                                                            .withOpacity(0.1),
                                                                        boxShadow: [
                                                                          BoxShadow(
                                                                            color:
                                                                                const Color(0xFF9F86FF).withOpacity(0.1),
                                                                            // Soft grey shadow
                                                                            spreadRadius:
                                                                                1,
                                                                            blurRadius:
                                                                                3,
                                                                            offset:
                                                                                const Offset(0, 1),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                      child: Image.asset(
                                                                          "images/file.png",
                                                                          fit: BoxFit
                                                                              .scaleDown),
                                                                    ),
                                                                  ),
                                                                  const SizedBox(
                                                                    height: 5,
                                                                  ),
                                                                  Column(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                        const SizedBox(
                                                                            height:
                                                                                10),
                                                                        Padding(
                                                                          padding: const EdgeInsets
                                                                              .only(
                                                                              left: 10),
                                                                          child:
                                                                              Text(
                                                                            _dashboardCounts != null
                                                                                ? _dashboardCounts!.picked.toString()
                                                                                : '0',
                                                                            style:
                                                                                const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                                                                          ),
                                                                        ),
                                                                        Padding(
                                                                          padding: const EdgeInsets
                                                                              .only(
                                                                              left: 10),
                                                                          child:
                                                                              Text(
                                                                            'Picked Orders',
                                                                            style:
                                                                                TextStyle(
                                                                              fontSize: maxWidth * 0.01,
                                                                              color: const Color(0xFF455A64),
                                                                            ),
                                                                          ),
                                                                        )
                                                                      ])
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 10,
                                                              bottom: 10),
                                                      child: MouseRegion(
                                                        onEnter: (_) {
                                                          setState(() {
                                                            orderhover2 = true;
                                                          });
                                                        },
                                                        onExit: (_) {
                                                          setState(() {
                                                            orderhover2 = false;
                                                          });
                                                        },
                                                        child: AnimatedScale(
                                                          scale: orderhover2
                                                              ? 1.05
                                                              : 1.0,
                                                          duration:
                                                              const Duration(
                                                                  milliseconds:
                                                                      200),
                                                          child: InkWell(
                                                            onTap: () {
                                                            },
                                                            child: Container(
                                                              height: 115,
                                                              width: maxWidth *
                                                                  0.15,
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(16),
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: Colors
                                                                    .white,
                                                                border:
                                                                    Border.all(
                                                                  color: const Color(
                                                                      0x29000000),
                                                                ),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            15),
                                                              ),
                                                              child: Row(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  Padding(
                                                                    padding: const EdgeInsets
                                                                        .only(
                                                                        top: 3),
                                                                    child:
                                                                        Container(
                                                                      width: 60,
                                                                      height:
                                                                          60,
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        shape: BoxShape
                                                                            .circle,
                                                                        border: Border.all(
                                                                            color:
                                                                                const Color(0xFF0388AB),
                                                                            width: 1.5),
                                                                        color: const Color(0xffB8EFFC)
                                                                            .withOpacity(0.1),
                                                                        boxShadow: [
                                                                          BoxShadow(
                                                                            color:
                                                                                const Color(0xFF0388AB).withOpacity(0.1),
                                                                            spreadRadius:
                                                                                1,
                                                                            blurRadius:
                                                                                3,
                                                                            offset:
                                                                                const Offset(0, 1),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                      child: Image.asset(
                                                                          "images/dash.png",
                                                                          fit: BoxFit
                                                                              .scaleDown),
                                                                    ),
                                                                  ),
                                                                  const SizedBox(
                                                                    height: 5,
                                                                  ),
                                                                  Column(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                        const SizedBox(
                                                                            height:
                                                                                10),
                                                                        Padding(
                                                                          padding: const EdgeInsets
                                                                              .only(
                                                                              left: 10),
                                                                          child:
                                                                              Text(
                                                                            _dashboardCounts != null
                                                                                ? _dashboardCounts!.delivered.toString()
                                                                                : '0',
                                                                            style:
                                                                                const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                                                                          ),
                                                                        ),
                                                                        Padding(
                                                                          padding: const EdgeInsets
                                                                              .only(
                                                                              left: 10),
                                                                          child:
                                                                              Text(
                                                                            'Order Delivered',
                                                                            style:
                                                                                TextStyle(
                                                                              fontSize: maxWidth * 0.01,
                                                                              color: const Color(0xFF455A64),
                                                                              fontWeight: FontWeight.w500,
                                                                              letterSpacing: 0.5,
                                                                            ),
                                                                          ),
                                                                        )
                                                                      ])
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 10,
                                                              bottom: 10,
                                                              right: 10),
                                                      child: MouseRegion(
                                                        onEnter: (_) {
                                                          setState(() {
                                                            orderhover = true;
                                                          });
                                                        },
                                                        onExit: (_) {
                                                          setState(() {
                                                            orderhover = false;
                                                          });
                                                        },
                                                        child: AnimatedScale(
                                                          scale: orderhover
                                                              ? 1.05
                                                              : 1.0,
                                                          duration:
                                                              const Duration(
                                                                  milliseconds:
                                                                      200),
                                                          child: InkWell(
                                                            onTap: () {
                                                            },
                                                            child: Container(
                                                              height: 115,
                                                              width: maxWidth *
                                                                  0.155,
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(16),
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: Colors
                                                                    .white,
                                                                border:
                                                                    Border.all(
                                                                  color: const Color(
                                                                      0x29000000),
                                                                ),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            15),
                                                              ),
                                                              child: Row(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  Padding(
                                                                    padding: const EdgeInsets
                                                                        .only(
                                                                        top: 1),
                                                                    child:
                                                                        Container(
                                                                      width: 60,
                                                                      height:
                                                                          60,
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        shape: BoxShape
                                                                            .circle,
                                                                        border: Border.all(
                                                                            color:
                                                                                const Color(0xFF19C92F),
                                                                            width: 1.5),
                                                                        color: const Color(
                                                                            0xFFBFFFC7),
                                                                        boxShadow: [
                                                                          BoxShadow(
                                                                            color:
                                                                                const Color(0xFF418CFC33).withOpacity(0.1),
                                                                            spreadRadius:
                                                                                1,
                                                                            blurRadius:
                                                                                3,
                                                                            offset:
                                                                                const Offset(0, 1),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                      child: Image
                                                                          .asset(
                                                                        "images/nk1.png",
                                                                        width:
                                                                            35,
                                                                        height:
                                                                            35,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  const SizedBox(
                                                                    height: 5,
                                                                  ),
                                                                  Column(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                        const SizedBox(
                                                                            height:
                                                                                10),
                                                                        Padding(
                                                                          padding: const EdgeInsets
                                                                              .only(
                                                                              left: 10),
                                                                          child:
                                                                              Text(
                                                                            _dashboardCounts != null
                                                                                ? _dashboardCounts!.cleard.toString()
                                                                                : '0',
                                                                            style:
                                                                                const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                                                                          ),
                                                                        ),
                                                                        const Padding(
                                                                          padding:
                                                                              EdgeInsets.only(left: 10),
                                                                          child:
                                                                              Text(
                                                                            'Order Completed',
                                                                            style:
                                                                                TextStyle(
                                                                              fontSize: 15,
                                                                              color: Color(0xFF455A64),
                                                                            ),
                                                                          ),
                                                                        )
                                                                      ])
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ])
                                            ],
                                          ),
                                        ),
                                      ),
                                      Padding(
                                          padding: const EdgeInsets.only(
                                              left: 1,
                                              top: 20,
                                              right: 1,
                                              bottom: 10),
                                          child: Container(
                                            height: 650,
                                            width: maxWidth,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(2),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.grey
                                                      .withOpacity(0.1),
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
                                                  const SizedBox(height: 20),
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
                                                            buildDataTable1(),
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
                                ),
                              ),
                            } else ...{
                              SizedBox(
                                height: 874,
                                child: AdaptiveScrollbar(
                                    position: ScrollbarPosition.bottom,
                                    controller: horizontalScroll,
                                    child: SingleChildScrollView(
                                      controller: horizontalScroll,
                                      scrollDirection: Axis.horizontal,
                                      child: SizedBox(
                                        width: 1200,
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              left: 35, right: 50, top: 5),
                                          child: Column(
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 1, right: 1, top: 5),
                                                child: SizedBox(
                                                  width: 1200,
                                                  child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  top: 10,
                                                                  bottom: 10,
                                                                  left: 10),
                                                          child: MouseRegion(
                                                            onEnter: (_) {
                                                              setState(() {
                                                                _isHovered2 =
                                                                    true;
                                                              });
                                                            },
                                                            onExit: (_) {
                                                              setState(() {
                                                                _isHovered2 =
                                                                    false;
                                                              });
                                                            },
                                                            child:
                                                                AnimatedScale(
                                                              scale: _isHovered2
                                                                  ? 1.05
                                                                  : 1.0,
                                                              duration:
                                                                  const Duration(
                                                                      milliseconds:
                                                                          200),
                                                              child: InkWell(
                                                                onTap: () {},
                                                                child:
                                                                    Container(
                                                                  height: 115,
                                                                  width: 200,
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .all(
                                                                          16),
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: Colors
                                                                        .white,
                                                                    border:
                                                                        Border
                                                                            .all(
                                                                      color: const Color(
                                                                          0x29000000),
                                                                    ),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            15),
                                                                  ),
                                                                  child: Column(
                                                                    children: [
                                                                      Row(
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.center,
                                                                        children: [
                                                                          Padding(
                                                                            padding:
                                                                                const EdgeInsets.only(top: 3),
                                                                            child:
                                                                                Container(
                                                                              width: 60,
                                                                              height: 60,
                                                                              decoration: BoxDecoration(
                                                                                shape: BoxShape.circle,
                                                                                border: Border.all(
                                                                                  color: const Color(0xffffac8c),
                                                                                  // Border color
                                                                                  width: 1.5,
                                                                                ),
                                                                                color: const Color(0xffffac8c).withOpacity(0.2),
                                                                                boxShadow: [
                                                                                  BoxShadow(
                                                                                    color: const Color(0xffffac8c).withOpacity(0.1),
                                                                                    spreadRadius: 1,
                                                                                    blurRadius: 3,
                                                                                    offset: const Offset(0, 1),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                              child: Image.asset("images/openorders.png"),
                                                                            ),
                                                                          ),
                                                                          const SizedBox(
                                                                            height:
                                                                                5,
                                                                          ),
                                                                          Column(
                                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                                              children: [
                                                                                const SizedBox(height: 10),
                                                                                Padding(
                                                                                  padding: const EdgeInsets.only(left: 10),
                                                                                  child: Text(
                                                                                    _dashboardCounts != null ? _dashboardCounts!.openOrders.toString() : '0',
                                                                                    style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                                                                                  ),
                                                                                ),
                                                                                const Padding(
                                                                                  padding: EdgeInsets.only(left: 10),
                                                                                  child: Text(
                                                                                    'Open Orders',
                                                                                    style: TextStyle(
                                                                                      fontSize: 13,
                                                                                      color: Color(0xFF455A64),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ])
                                                                        ],
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  top: 10,
                                                                  bottom: 10),
                                                          child: MouseRegion(
                                                            onEnter: (_) {
                                                              setState(() {
                                                                _isHovered5 =
                                                                    true;
                                                              });
                                                            },
                                                            onExit: (_) {
                                                              setState(() {
                                                                _isHovered5 =
                                                                    false;
                                                              });
                                                            },
                                                            child:
                                                                AnimatedScale(
                                                              scale: _isHovered5
                                                                  ? 1.05
                                                                  : 1.0,
                                                              duration:
                                                                  const Duration(
                                                                      milliseconds:
                                                                          200),
                                                              child: InkWell(
                                                                onTap: () {
                                                                },
                                                                child:
                                                                    Container(
                                                                  height: 115,
                                                                  width: 200,
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .all(
                                                                          16),
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: Colors
                                                                        .white,
                                                                    border:
                                                                        Border
                                                                            .all(
                                                                      color: const Color(
                                                                          0x29000000),
                                                                    ),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            15),
                                                                  ),
                                                                  child: Row(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .center,
                                                                    children: [
                                                                      Padding(
                                                                        padding: const EdgeInsets
                                                                            .only(
                                                                            top:
                                                                                3),
                                                                        child:
                                                                            Container(
                                                                          width:
                                                                              60,
                                                                          height:
                                                                              60,
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            shape:
                                                                                BoxShape.circle,
                                                                            border:
                                                                                Border.all(color: const Color(0xFF9F86FF), width: 1.5),
                                                                            color:
                                                                                const Color(0xFF9F86FF).withOpacity(0.1),
                                                                            boxShadow: [
                                                                              BoxShadow(
                                                                                color: const Color(0xFF9F86FF).withOpacity(0.1),
                                                                                spreadRadius: 1,
                                                                                blurRadius: 3,
                                                                                offset: const Offset(0, 1),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                          child: Image.asset(
                                                                              "images/file.png",
                                                                              fit: BoxFit.scaleDown),
                                                                        ),
                                                                      ),
                                                                      const SizedBox(
                                                                        height:
                                                                            5,
                                                                      ),
                                                                      Column(
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.start,
                                                                          children: [
                                                                            const SizedBox(height: 10),
                                                                            Padding(
                                                                              padding: const EdgeInsets.only(left: 10),
                                                                              child: Text(
                                                                                _dashboardCounts != null ? _dashboardCounts!.picked.toString() : '0',
                                                                                style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                                                                              ),
                                                                            ),
                                                                            const Padding(
                                                                              padding: EdgeInsets.only(left: 10),
                                                                              child: Text(
                                                                                'Picked Orders',
                                                                                style: TextStyle(
                                                                                  fontSize: 13,
                                                                                  color: Color(0xFF455A64),
                                                                                ),
                                                                              ),
                                                                            )
                                                                          ])
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  top: 10,
                                                                  bottom: 10),
                                                          child: MouseRegion(
                                                            onEnter: (_) {
                                                              setState(() {
                                                                orderhover2 =
                                                                    true;
                                                              });
                                                            },
                                                            onExit: (_) {
                                                              setState(() {
                                                                orderhover2 =
                                                                    false;
                                                              });
                                                            },
                                                            child:
                                                                AnimatedScale(
                                                              scale: orderhover2
                                                                  ? 1.05
                                                                  : 1.0,
                                                              duration:
                                                                  const Duration(
                                                                      milliseconds:
                                                                          200),
                                                              child: InkWell(
                                                                onTap: () {
                                                                },
                                                                child:
                                                                    Container(
                                                                  height: 115,
                                                                  width: 200,
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .all(
                                                                          16),
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: Colors
                                                                        .white,
                                                                    border:
                                                                        Border
                                                                            .all(
                                                                      color: const Color(
                                                                          0x29000000),
                                                                    ),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            15),
                                                                  ),
                                                                  child: Row(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .center,
                                                                    children: [
                                                                      Padding(
                                                                        padding: const EdgeInsets
                                                                            .only(
                                                                            top:
                                                                                3),
                                                                        child:
                                                                            Container(
                                                                          width:
                                                                              60,
                                                                          height:
                                                                              60,
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            shape:
                                                                                BoxShape.circle,
                                                                            border:
                                                                                Border.all(color: const Color(0xFF0388AB), width: 1.5),
                                                                            color:
                                                                                const Color(0xffB8EFFC).withOpacity(0.1),
                                                                            boxShadow: [
                                                                              BoxShadow(
                                                                                color: const Color(0xFF0388AB).withOpacity(0.1),
                                                                                spreadRadius: 1,
                                                                                blurRadius: 3,
                                                                                offset: const Offset(0, 1),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                          child: Image.asset(
                                                                              "images/dash.png",
                                                                              fit: BoxFit.scaleDown),
                                                                        ),
                                                                      ),
                                                                      const SizedBox(
                                                                        height:
                                                                            5,
                                                                      ),
                                                                      Column(
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.start,
                                                                          children: [
                                                                            const SizedBox(height: 10),
                                                                            Padding(
                                                                              padding: const EdgeInsets.only(left: 10),
                                                                              child: Text(
                                                                                _dashboardCounts != null ? _dashboardCounts!.delivered.toString() : '0',
                                                                                style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                                                                              ),
                                                                            ),
                                                                            const Padding(
                                                                              padding: EdgeInsets.only(left: 10),
                                                                              child: Text(
                                                                                'Order Delivered',
                                                                                style: TextStyle(
                                                                                  fontSize: 12,
                                                                                  color: Color(0xFF455A64),
                                                                                  // Dark grey-blue
                                                                                  fontWeight: FontWeight.w500,
                                                                                  letterSpacing: 0.5,
                                                                                ),
                                                                              ),
                                                                            )
                                                                          ])
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  top: 10,
                                                                  bottom: 10,
                                                                  right: 10),
                                                          child: MouseRegion(
                                                            onEnter: (_) {
                                                              setState(() {
                                                                orderhover =
                                                                    true;
                                                              });
                                                            },
                                                            onExit: (_) {
                                                              setState(() {
                                                                orderhover =
                                                                    false;
                                                              });
                                                            },
                                                            child:
                                                                AnimatedScale(
                                                              scale: orderhover
                                                                  ? 1.05
                                                                  : 1.0,
                                                              duration:
                                                                  const Duration(
                                                                      milliseconds:
                                                                          200),
                                                              child: InkWell(
                                                                onTap: () {
                                                                },
                                                                child:
                                                                    Container(
                                                                  height: 115,
                                                                  width: 200,
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .all(
                                                                          16),
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: Colors
                                                                        .white,
                                                                    border:
                                                                        Border
                                                                            .all(
                                                                      color: const Color(
                                                                          0x29000000),
                                                                    ),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            15),
                                                                  ),
                                                                  child: Row(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .center,
                                                                    children: [
                                                                      Padding(
                                                                        padding: const EdgeInsets
                                                                            .only(
                                                                            top:
                                                                                1),
                                                                        child:
                                                                            Container(
                                                                          width:
                                                                              60,
                                                                          height:
                                                                              60,
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            shape:
                                                                                BoxShape.circle,
                                                                            border:
                                                                                Border.all(color: const Color(0xFF19C92F), width: 1.5),
                                                                            color:
                                                                                const Color(0xFFBFFFC7),
                                                                            boxShadow: [
                                                                              BoxShadow(
                                                                                color: const Color(0xFF418CFC33).withOpacity(0.1),
                                                                                spreadRadius: 1,
                                                                                blurRadius: 3,
                                                                                offset: const Offset(0, 1),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                          child:
                                                                              Image.asset(
                                                                            "images/nk1.png",
                                                                            width:
                                                                                35,
                                                                            height:
                                                                                35,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      const SizedBox(
                                                                        height:
                                                                            5,
                                                                      ),
                                                                      Column(
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.start,
                                                                          children: [
                                                                            const SizedBox(height: 10),
                                                                            Padding(
                                                                              padding: const EdgeInsets.only(left: 10),
                                                                              child: Text(
                                                                                _dashboardCounts != null ? _dashboardCounts!.cleard.toString() : '0',
                                                                                style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                                                                              ),
                                                                            ),
                                                                            const Padding(
                                                                              padding: EdgeInsets.only(left: 10),
                                                                              child: Text(
                                                                                'Order Completed',
                                                                                style: TextStyle(
                                                                                  fontSize: 13,
                                                                                  color: Color(0xFF455A64),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ]),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ]),
                                                ),
                                              ),
                                              Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 1,
                                                          top: 20,
                                                          right: 1,
                                                          bottom: 50),
                                                  child: Container(
                                                    height: 650,
                                                    width: 1100,
                                                    decoration: BoxDecoration(
                                                      //   border: Border.all(color: Colors.grey),
                                                      color: Colors.white,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              2),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors.grey
                                                              .withOpacity(0.1),
                                                          // Soft grey shadow
                                                          spreadRadius: 3,
                                                          blurRadius: 3,
                                                          offset: const Offset(
                                                              0, 3),
                                                        ),
                                                      ],
                                                    ),
                                                    child: SizedBox(
                                                      //width: maxWidth * 0.8,
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          buildSearchField1(),
                                                          const SizedBox(
                                                              height: 20),
                                                          Expanded(
                                                            child: Scrollbar(
                                                              controller:
                                                                  _scrollController,
                                                              thickness: 6,
                                                              thumbVisibility:
                                                                  true,
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
                                                                const EdgeInsets
                                                                    .only(
                                                                    right: 30),
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .end,
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
                                        ),
                                      ),
                                    )),
                              ),
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
          const SizedBox(
            height: 10,
          ),
          Container(
              height: 42,
              decoration: BoxDecoration(
                color: Colors.blue[800],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                  bottomLeft: Radius.circular(8),
                  bottomRight:
                      Radius.circular(8),
                ),
              ),
              child: _buildMenuItem(
                  'Home', Icons.home, Colors.white, '/Cus_Home')),
        ],
      ),
      const SizedBox(
        height: 6,
      ),
      _buildMenuItem('Orders', Icons.warehouse_outlined, Colors.blue[900]!,
          '/Customer_Order_List'),
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

  Widget buildSearchField2() {
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
                  padding: const EdgeInsets.only(top: 20, left: 30),
                  child: Container(
                    width: 310,
                    height: 35,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(2),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: TextFormField(
                      style:
                          GoogleFonts.inter(color: Colors.black, fontSize: 13),
                      decoration: InputDecoration(
                          hintText: 'Search by Order ID',
                          hintStyle: TextStyles.body,
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 3, horizontal: 5),
                          border: InputBorder.none,
                          suffixIcon: Padding(
                            padding: const EdgeInsets.only(left: 10, right: 5),
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
            const SizedBox(height: 8),
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
                    Padding(
                      padding: const EdgeInsets.only(top: 20, left: 30),
                      child: Container(
                        width: maxWidth1 * 0.2,
                        height: 35,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(2),
                          border: Border.all(color: Colors.grey),
                        ),
                        child: TextFormField(
                          style: GoogleFonts.inter(
                              color: Colors.black, fontSize: 13),
                          decoration: InputDecoration(
                              hintText: 'Search by Order ID',
                              hintStyle: TextStyles.body,
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 3, horizontal: 5),
                              border: InputBorder.none,
                              suffixIcon: Padding(
                                padding: const EdgeInsets.only(
                                    left: 10, right: 5),
                                child: Image.asset(
                                  'images/search.png',
                                ),
                              )),
                          onChanged: _updateSearch,
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
      var width = MediaQuery.of(context).size.width;
      var height = MediaQuery.of(context).size.height;
      return Padding(
        padding: EdgeInsets.only(
            top: height * 0.100, bottom: height * 0.100, left: width * 0.300),
        child: CustomLoadingIcon(), // Replace this with your custom GIF widget
      );
    }

    if (filteredData1.isEmpty) {
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
                columnSpacing: 50,
                columns: [
                  DataColumn(
                      label: Text('Order ID', style: TextStyles.subhead)),
                  DataColumn(
                      label: Text('Customer Name', style: TextStyles.subhead)),
                  DataColumn(
                      label: Text(
                                          'Order Date',
                                          style: TextStyles.subhead,
                                        )),
                  DataColumn(
                      label: Container(
                          child: Text(
                    'Total Amount',
                    style: TextStyles.subhead,
                  ))),
                  DataColumn(
                      label: Text(
                                          'Status',
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
          } else {
            return 0;
          }
        });
      } else {
        filteredData1.sort((a, b) {
          if (columnIndex == 0) {
            return b.orderId!.compareTo(a.orderId!);
          } else if (columnIndex == 1) {
            return b.contactPerson!
                .compareTo(a.contactPerson!);
          } else if (columnIndex == 2) {
            return b.createdDate!
                .compareTo(a.createdDate!);
          } else if (columnIndex == 3) {
            return b.total.compareTo(a.total);
          } else if (columnIndex == 4) {
            return b.deliveryStatus
                .compareTo(a.deliveryStatus);
          } else {
            return 0;
          }
        });
      }
      setState(() {});
    }

    return LayoutBuilder(builder: (context, constraints) {
      // double padding = constraints.maxWidth * 0.065;
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
                        SizedBox(
                          width: columnWidths[columns.indexOf(column)],
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(column,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyles.subhead),
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
                  return DataRow(
                    color: MaterialStateProperty.resolveWith<Color>((states) {
                      if (states.contains(MaterialState.hovered)) {
                        return Colors.blue.shade500.withOpacity(
                            0.8);
                      } else {
                        return Colors.white.withOpacity(0.9);
                      }
                    }),
                    cells: [
                      DataCell(
                        SizedBox(
                          width: columnWidths[0],
                          child: Text(
                            detail.orderId.toString(),
                            style: TextStyles.body,
                          ),
                        ),
                      ),
                      DataCell(
                        SizedBox(
                          width: columnWidths[1],
                          child: Text(
                            detail.contactPerson!,
                            style: TextStyles.body,
                          ),
                        ),
                      ),
                      DataCell(
                        SizedBox(
                          width: columnWidths[2],
                          child: Text(
                            detail.orderDate,
                            style: TextStyles.body,
                          ),
                        ),
                      ),
                      DataCell(
                        SizedBox(
                          width: columnWidths[3],
                          child: Text(
                            detail.total.toString(),
                            style: TextStyles.body,
                          ),
                        ),
                      ),
                      DataCell(
                        SizedBox(
                          width: columnWidths[4],
                          child: Text(
                            detail.deliveryStatus.toString(),
                            style: TextStyles.body,
                          ),
                        ),
                      ),
                    ],

                  );
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
      return Padding(
        padding: EdgeInsets.only(
            top: height * 0.100, bottom: height * 0.100, left: width * 0.300),
        child: CustomLoadingIcon(),
      );
    }
    if (filteredData1.isEmpty) {
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
                columnSpacing: 50,
                columns: [
                  DataColumn(
                      label: Text('Order ID', style: TextStyles.subhead)),
                  DataColumn(
                      label: Text('Customer Name', style: TextStyles.subhead)),
                  DataColumn(
                      label: Text(
                                          'Order Date',
                                          style: TextStyles.subhead,
                                        )),
                  DataColumn(
                      label: Text(
                                          'Total Amount',
                                          style: TextStyles.subhead,
                                        )),
                  DataColumn(
                      label: Text(
                                          'Status',
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
            return a.orderId!.compareTo(b.orderId!);
          } else if (columnIndex == 1) {
            return a.contactPerson!.compareTo(b.contactPerson!);
          } else if (columnIndex == 2) {
            return a.createdDate!.compareTo(b.createdDate!);
          } else if (columnIndex == 3) {
            return a.total.compareTo(b.total);
          } else if (columnIndex == 4) {
            return a.deliveryStatus.compareTo(b.deliveryStatus);
          } else {
            return 0;
          }
        });
      } else {
        filteredData1.sort((a, b) {
          if (columnIndex == 0) {
            return b.orderId!.compareTo(a.orderId!);
          } else if (columnIndex == 1) {
            return b.contactPerson!
                .compareTo(a.contactPerson!);
          } else if (columnIndex == 2) {
            return b.createdDate!
                .compareTo(a.createdDate!);
          } else if (columnIndex == 3) {
            return b.total.compareTo(a.total);
          } else if (columnIndex == 4) {
            return b.deliveryStatus
                .compareTo(a.deliveryStatus);
          } else {
            return 0;
          }
        });
      }
      setState(() {});
    }

    return LayoutBuilder(builder: (context, constraints) {
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
                        SizedBox(
                          width: columnWidths[columns.indexOf(column)],
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(column,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyles.subhead),
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
                                    sortProducts(columns.indexOf(column),
                                        _sortOrder[columns.indexOf(column)]);
                                  });
                                },
                              ),
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
                  return DataRow(
                    color: MaterialStateProperty.resolveWith<Color>((states) {
                      if (states.contains(MaterialState.hovered)) {
                        return Colors.blue.shade500.withOpacity(
                            0.8);
                      } else {
                        return Colors.white.withOpacity(0.9);
                      }
                    }),
                    cells: [
                      DataCell(
                        SizedBox(
                          width: columnWidths[0],
                          child: Text(
                            detail.orderId.toString(),
                            style: TextStyles.body,
                          ),
                        ),
                      ),
                      DataCell(
                        SizedBox(
                          width: columnWidths[1],
                          child: Text(
                            detail.contactPerson!,
                            style: TextStyles.body,
                          ),
                        ),
                      ),
                      DataCell(
                        SizedBox(
                          width: columnWidths[2],
                          child: Text(
                            detail.orderDate,
                            style: TextStyles.body,
                          ),
                        ),
                      ),
                      DataCell(
                        SizedBox(
                          width: columnWidths[3],
                          child: Text(
                            detail.total.toString(),
                            style: TextStyles.body,
                          ),
                        ),
                      ),
                      DataCell(
                        SizedBox(
                          width: columnWidths[4],
                          child: Text(
                            detail.deliveryStatus.toString(),
                            style: TextStyles.body,
                          ),
                        ),
                      ),
                    ],
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
  final int cleard;
  final int inprepare;
  final int picked;
  final double totalAmount;
  final int delivered;

  DashboardCounts(
      {required this.openOrders,
      required this.cleard,
      required this.inprepare,
      required this.picked,
      required this.totalAmount,
      required this.delivered});

  factory DashboardCounts.fromJson(Map<String, dynamic> json) {
    return DashboardCounts(
      picked: json['Picked'] ?? 0,
      openOrders: json['Not Started'] ?? 0.0,
      cleard: json['Cleared'] ?? 0.0,
      inprepare: json['In Progress'] ?? 0.0,
      totalAmount: json['totalAmount'] ?? 0.0,
      delivered: json['Delivered'] ?? 0.0,
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
    this.width = 100,
    this.color = Colors.grey,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 200, top: 61),
      child: Container(
        width: 4,
        height: height,
        color: color,
      ),
    );
  }
}

