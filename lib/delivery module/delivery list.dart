import 'dart:async';
import 'dart:convert';
import 'dart:html';
import 'dart:math' as math;
import 'package:adaptive_scrollbar/adaptive_scrollbar.dart';
import 'package:btb/admin/Api%20name.dart';
import 'package:btb/widgets/confirmdialog.dart';
import 'package:btb/widgets/pagination.dart';
import 'package:btb/widgets/productclass.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import '../Order Module/firstpage.dart';
import '../widgets/custom loading.dart';
import '../widgets/no datafound.dart';


class DeliveryList extends StatefulWidget {
  const DeliveryList({super.key});

  @override
  State<DeliveryList> createState() => _DeliveryListState();
}

class _DeliveryListState extends State<DeliveryList> with SingleTickerProviderStateMixin{
  final ScrollController horizontalScroll = ScrollController();
  List<String> _sortOrder = List.generate(6, (index) => 'asc');
  List<String> columns = [
    'Delivery Id',
    'Name',
    'Created Date',
    'Total Amount',
    'Delivery Status'
  ];
  List<double> columnWidths = [110, 90, 130, 125, 135];
  List<bool> columnSortState = [true, true, true, true, true];
  Timer? _searchDebounceTimer;
  String _searchText = '';
  bool isOrdersSelected = false;
  bool _loading = false;
  detail? _selectedProduct;
  DateTime? _selectedDate;
  late TextEditingController _dateController;
  int startIndex = 0;
  List<Product> filteredProducts = [];
  int currentPage = 1;
  String? dropdownValue1 = 'Status';
  late Future<List<detail>> futureOrders;
  List<detail> productList = [];
  final ScrollController _scrollController = ScrollController();
  List<dynamic> detailJson = [];
  late AnimationController _controller;
  bool _isHovered1 = false;
  late Animation<double> _shakeAnimation;
  String searchQuery = '';
  List<detail> filteredData = [];
  String status = '';

  String selectDate = '';

  String token = window.sessionStorage["token"] ?? " ";
  String? dropdownValue2 = 'Select Year';

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
      _buildMenuItem('Home', Icons.home_outlined, Colors.blue[900]!, '/Home'),
      _buildMenuItem('Customer', Icons.account_circle, Colors.blue[900]!, '/Customer'),
      _buildMenuItem('Products', Icons.image_outlined, Colors.blue[900]!, '/Product_List'),
      _buildMenuItem('Orders', Icons.warehouse_outlined, Colors.blue[900]!, '/Order_List'),
      _buildMenuItem('Invoice', Icons.document_scanner_outlined, Colors.blue[900]!, '/Invoice'),
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
          ),child: _buildMenuItem('Delivery', Icons.fire_truck_outlined, Colors.blueAccent, '/Delivery_List')),
      _buildMenuItem('Payment', Icons.payment_rounded, Colors.blue[900]!, '/Payment_List'),
      _buildMenuItem('Return', Icons.keyboard_return, Colors.blue[900]!, '/Return_List'),
      _buildMenuItem('Reports', Icons.insert_chart_outlined, Colors.blue[900]!, '/Report_List'),
    ];
  }

  Widget _buildMenuItem(String title, IconData icon, Color iconColor, String route) {
    iconColor = _isHovered[title] == true ? Colors.blue : Colors.black87;
    title == 'Delivery'? _isHovered[title] = false :  _isHovered[title] = false;
    title == 'Delivery'? iconColor = Colors.white : Colors.black;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered[title] = true),
      onExit: (_) => setState(() => _isHovered[title] = false),
      child: GestureDetector(
        onTap: () {
          context.go(route);
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 5,right: 20),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: _isHovered[title]! ? Colors.black12 : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.only(left: 5,top: 5),
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
      ),
    );
  }


  int itemsPerPage = 10;
  int totalItems = 0;
  int totalPages = 0;
  bool isLoading = false;

  Future<void> fetchProducts() async {
    if (isLoading) return;
    if (!mounted) return;
    setState(() {
      isLoading = true;
    });
    try {
      final response = await http.get(
        Uri.parse(
          '$apicall/delivery_master/get_all_deliverymaster', // Changed limit to 10
        ),
        headers: {
          "Content-type": "application/json",
          "Authorization": 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        print('json data');
        print(jsonData);
        List<detail> products = [];
        if (jsonData != null) {
          if (jsonData is List) {
            products = jsonData.map((item) => detail.fromJson(item)).toList();
          } else if (jsonData is Map && jsonData.containsKey('body')) {
            products = (jsonData['body'] as List)
                .map((item) => detail.fromJson(item))
                .toList();
            totalItems =
                jsonData['totalItems'] ?? 0; // Get the total number of items
          }

          if (mounted) {
            setState(() {
              totalPages = (products.length / itemsPerPage).ceil();
              print('pages');
              print(totalPages);
              productList = products;
              print(productList);
              _filterAndPaginateProducts();
            });
          }
        }
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Error decoding JSON: $e');
// Optionally, show an error message to the user
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

    });
  }

  void _goToPreviousPage() {
    print("previos");

    if (currentPage > 1) {
      if (filteredData.length > itemsPerPage) {
        setState(() {
          currentPage--;
        });
      }
    }
  }

  void _goToNextPage() {
    print('nextpage');

    if (currentPage < totalPages) {
      if (filteredData.length > currentPage * itemsPerPage) {
        setState(() {
          currentPage++;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _dateController = TextEditingController();
    fetchProducts();
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
        backgroundColor: const Color(0xFFF0F4F8),
        appBar: AppBar(
          backgroundColor: const Color(0xFFFFFFFF),
          title: Image.asset("images/Final-Ikyam-Logo.png"),
// Set background color to white
          elevation: 2.0,
          shadowColor: const Color(0xFFFFFFFF),

          actions: [
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  icon: const Icon(Icons.notifications),
                  onPressed: () {
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
                padding: const EdgeInsets.only(left: 200, top: 0),
                child: Container(
                  width: 1, // Set the width to 1 for a vertical line
                  height: 1400, // Set the height to your liking
                  decoration: const BoxDecoration(
                    border:
                        Border(left: BorderSide(width: 1, color: Colors.grey)),
                  ),
                ),
              ),
              Positioned(
                top: 0,
                left: 201,
                right: 0,
                bottom: 0,
                child: Column(
                  children: [
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        color: Colors.white,
                        height: 50,
                        child: Row(
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(left: 20),
                              child: Text(
                                'Delivery List',
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const Spacer(),
                            Align(
                              alignment: Alignment.topRight,
                              child: Padding(
                                padding: const EdgeInsets.only(top: 10, right: 80),
                                child: MouseRegion(
                                  onEnter: (_) {
                                    setState(() {
                                      _isHovered1 = true;
                                      _controller.forward(); // Start shake animation when hovered
                                    });
                                  },
                                  onExit: (_) {
                                    setState(() {
                                      _isHovered1 = false;
                                      _controller.stop(); // Stop shake animation when not hovered
                                    });
                                  },
                                  child: AnimatedBuilder(
                                      animation: _controller,
                                      builder: (context, child) {
                                        return Transform.translate(offset: Offset(_isHovered1? _shakeAnimation.value : 0,0),
                                          child: AnimatedContainer(
                                            duration: const Duration(milliseconds: 300),
                                            curve: Curves.easeInOut,
                                            decoration: BoxDecoration(
                                              color: _isHovered1
                                                  ? Colors.blue[800]
                                                  : Colors.blue[800], // Background color change on hover
                                              borderRadius: BorderRadius.circular(5),
                                              boxShadow: _isHovered1
                                                  ? [
                                                const BoxShadow(
                                                    color: Colors.black45,
                                                    blurRadius: 6,
                                                    spreadRadius: 2)
                                              ]
                                                  : [],
                                            ),
                                            child: OutlinedButton(
                                              onPressed: () {
                                                context.go('/Create_Delivery');
                      //  context.go('/Create_New_Order');
                      //context.go('/Home/Orders/Create_Order');
                                              },
                                              style: OutlinedButton.styleFrom(
                                                backgroundColor: Colors.blue[800],
                      // Button background color
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(
                                                      5), // Rounded corners
                                                ),
                                                side: BorderSide.none, // No outline
                                              ),
                                              child: const Text(
                                                'Create',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w100,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      }

                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    Container(
                      margin: const EdgeInsets.only(left: 0),
                      // Space above/below the border
                      height: 1,
                      // width: 10  00,
                      width: constraints.maxWidth,
                      // Border height
                      color: Colors.grey, // Border color
                    ),
                    if(constraints.maxWidth >= 1140)...{
                      Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Padding(
                                        padding: const EdgeInsets.only(
                                            left: 30,
                                            top: 50,
                                            right: 30,
                                            bottom: 15),
                                        child: Container(
                                          height: 755,
                                          width: maxWidth * 0.8,
                                          decoration:BoxDecoration(
                                            //   border: Border.all(color: Colors.grey),
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(8),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(0.3), // Soft grey shadow
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
                                                buildSearchField(),
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
                                                      child: buildDataTable(),
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
                                                        totalPages: filteredData
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
                          )),
                    }
                    else...{
                      Expanded(
                          child: AdaptiveScrollbar(
      position: ScrollbarPosition.bottom,controller: horizontalScroll,
                            child: SingleChildScrollView(
                              controller: horizontalScroll,
                              scrollDirection: Axis.horizontal,
                              child: SingleChildScrollView(
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Padding(
                                            padding: const EdgeInsets.only(
                                                left: 30,
                                                top: 50,
                                                right: 30,
                                                bottom: 15),
                                            child: Container(
                                              height: 755,
                                              width: 1100,
                                              decoration:BoxDecoration(
                                                //   border: Border.all(color: Colors.grey),
                                                color: Colors.white,
                                                borderRadius: BorderRadius.circular(8),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black.withOpacity(0.3), // Soft grey shadow
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
                                                    buildSearchField(),
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
                                                            totalPages: filteredData
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
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget buildSearchField() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return ConstrainedBox(
          constraints: const BoxConstraints(),
          child: Container(
            padding: const EdgeInsets.only(
              left: 20,
              right: 20,
              top: 10,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
//  const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: constraints.maxWidth * 0.261,
                          maxHeight: 39,
                        ),
                        child: Container(
// width: constraints.maxWidth * 0.252, // reduced width
                          height: 35, // reduced height
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(2),
                            border: Border.all(color: Colors.grey),
                          ),
                          child: TextFormField(
                            decoration: InputDecoration(
                              hintText: 'Search by Delivery ID',
                              hintStyle:
                                  const TextStyle(fontSize: 13, color: Colors.grey),
                              contentPadding:
                                  const EdgeInsets.only(bottom: 20, left: 10),
                              // adjusted padding
                              border: InputBorder.none,
                              suffixIcon: Icon(Icons.search_outlined,
                                  color: Colors.blue[800]),
                            ),
                            onChanged: _updateSearch,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
//    const SizedBox(height: 8),
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
// const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: constraints.maxWidth * 0.12,
                              // reduced width
                              maxHeight: 30, // reduced height
                            ),
                            child: Container(
                              height: 35,
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
                                  focusColor: Color(0xFFF0F4F8),
                                  fillColor: Colors.white,
                                  hintText: 'Category',
                                  hintStyle: TextStyle(color: Colors.grey),
                                ),
                                value: dropdownValue1,
                                onChanged: (String? newValue) {
                                  setState(() {
                                    dropdownValue1 = newValue;
                                    status = newValue ?? '';
                                    _filterAndPaginateProducts();
                                  });
                                },
                                items: <String>[
                                  'Status',
                                  'In Progress',
                                  'Delivered',
                                ].map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value,
                                        style: TextStyle(
                                            color: value == 'Status'
                                                ? Colors.grey
                                                : Colors.black,
                                            fontSize: 13)),
                                  );
                                }).toList(),
                                isExpanded: true,
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
                                  width: constraints.maxWidth * 0.12, // Dropdown width
                                  offset:  const Offset(0, -10),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
//  const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: constraints.maxWidth * 0.128,
                              // reduced width
                              maxHeight: 30, // reduced height
                            ),
                            child: Container(
                              height: 35,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(2),
                                border: Border.all(color: Colors.grey),
                              ),
                              child: DropdownButtonFormField2<String>(
                                decoration: const InputDecoration(
                                  contentPadding:
                                      EdgeInsets.only(bottom: 22, left: 10),
                                  border: InputBorder.none,
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                                value: dropdownValue2,
                                //focusColor: Color(0xFFF0F4F8),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    dropdownValue2 = newValue;
                                    selectDate = newValue ?? '';
                                    _filterAndPaginateProducts();
                                  });
                                },
                                items: <String>[
                                  'Select Year',
                                  '2023',
                                  '2024',
                                  '2025'
                                ].map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value,
                                        style: TextStyle(
                                            color: value == 'Select Year'
                                                ? Colors.grey
                                                : Colors.black,
                                            fontSize: 13)),
                                  );
                                }).toList(),
                                isExpanded: true,
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
                                  width: constraints.maxWidth * 0.128, // Dropdown width
                                  offset:  const Offset(0, -10),
                                ),
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
          ),
        );
      },
    );
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

    if (filteredData.isEmpty) {
      //String? role = Provider.of<UserRoleProvider>(context).role;
      double right = MediaQuery.of(context).size.width;
      return Column(
        children: [
          Container(
              width: 1100,
              decoration: const BoxDecoration(
                  color: Color(0xFFF7F7F7),
                  border: Border.symmetric(
                      horizontal: BorderSide(color: Colors.grey, width: 0.5))),
              child:

              DataTable(
                  showCheckboxColumn: false,
                  headingRowHeight: 40,
                  columns: [
                    DataColumn(
                        label: Container(
                            child: Text(
                              'Delivery ID',
                              style: TextStyle(
                                  color: Colors.indigo[900],
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold),
                            ))),
                    DataColumn(
                        label: Container(
                            child: Text(
                              'Name',
                              style: TextStyle(
                                  color: Colors.indigo[900],
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold),
                            ))),
                    DataColumn(
                        label: Container(
                            child: Text(
                              'Created Date',
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
                  ],
                  rows: [])
          ),
          Padding(
            padding:
            const EdgeInsets.only(top: 150, left: 130, bottom: 350, right: 150),
            child: CustomDatafound(),
          ),
        ],
      );
    }
    return LayoutBuilder(builder: (context, constraints) {
// double padding = constraints.maxWidth * 0.065;
      double right = MediaQuery.of(context).size.width;
      //String? role = Provider.of<UserRoleProvider>(context).role;

      return Column(
        children: [
          Container(
              width: 1100,
              decoration: const BoxDecoration(
                  color: Color(0xFFF7F7F7),
                  border: Border.symmetric(
                      horizontal: BorderSide(color: Colors.grey, width: 0.5))),
              child:
              //  role == "Customer" ?
              DataTable(
                  showCheckboxColumn: false,
                  headingRowHeight: 40,
// List.generate(5, (index)
                  columns: columns.map((column) {
                    return DataColumn(
                      label: Stack(
                        children: [
                          Container(
                            padding: null,
                            width: columnWidths[columns.indexOf(column)],
                            // Dynamic width based on user interaction
                            child: Row(
//crossAxisAlignment: CrossAxisAlignment.end,
//   mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  column,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.indigo[900],
                                    fontSize: 13,
                                  ),
                                ),
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
                                                  .clamp(136.0, 300.0);
                                        });
                                      },
                                      child: const Padding(
                                        padding: EdgeInsets.only(
                                            top: 10, bottom: 10),
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
                      math.min(itemsPerPage,
                          filteredData.length - (currentPage - 1) * itemsPerPage),
                          (index) {
                        final detail =
                        filteredData[(currentPage - 1) * itemsPerPage + index];
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
                              DataCell(
                                Container(
                                  width: columnWidths[0],
                                  // Same dynamic width as column headers
                                  child: Text(
                                    detail.deliveryId!.toString(),
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.deepOrange[200]
                                          : const Color(0xFFFFB315),
                                    ),
                                  ),
                                ),
                              ),
                              DataCell(
                                Container(
                                  width: columnWidths[1],
                                  child: Text(
                                    detail.contactPerson!,
                                    style: const TextStyle(
                                      color: Color(0xFFA6A6A6),
                                    ),
                                  ),
                                ),
                              ),
                              DataCell(
                                Container(
                                  width: columnWidths[2],
                                  child: Text(
                                    detail.modifiedAt!,
                                    style: const TextStyle(
                                      color: Color(0xFFA6A6A6),
                                    ),
                                  ),
                                ),
                              ),
                              DataCell(
                                Container(
                                  width: columnWidths[3],
                                  child: Text(
                                    detail.total.toString(),
                                    style: const TextStyle(
                                      color: Color(0xFFA6A6A6),
                                    ),
                                  ),
                                ),
                              ),
                              DataCell(
                                Container(
                                  width: columnWidths[4],
                                  child: Text(detail.deliveryStatus,
                                      style: TextStyle(
//fontSize: 16,
                                          color: detail.deliveryStatus ==
                                              "In Progress"
                                              ? Colors.orange
                                              : detail.deliveryStatus == "Delivered"
                                              ? Colors.green
                                              : Colors.grey)),
                                ),
                              ),
                            ],
                            onSelectChanged: (selected) {
                              if (selected != null && selected) {
                                if (filteredData.length <= 9) {
                                  print(detail.deliveryStatus);
                                  context.go('/Delivery_View', extra: {
                                    'invoice': detail.invoiceNo,
                                    'deliveryStatus': detail.deliveryStatus,
                                    'deliveryId': detail.deliveryId,
                                  });
                                } else {
                                  context.go('/Delivery_View', extra: {
                                    'invoice': detail.invoiceNo,
                                    'deliveryStatus': detail.deliveryStatus,
                                    'deliveryId': detail.deliveryId,
                                  });
                                }
                              }
                            });
                      }))

          ),
        ],
      );
    });
  }
  Widget buildDataTable() {
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

    if (filteredData.isEmpty) {
      //String? role = Provider.of<UserRoleProvider>(context).role;
      double right = MediaQuery.of(context).size.width;
      return Column(
        children: [
          Container(
            width: right -200,
            decoration: const BoxDecoration(
                color: Color(0xFFF7F7F7),
                border: Border.symmetric(
                    horizontal: BorderSide(color: Colors.grey, width: 0.5))),
            child:

            DataTable(
                showCheckboxColumn: false,
                headingRowHeight: 40,
                columns: [
                  DataColumn(
                      label: Container(
                          child: Text(
                    'Delivery ID',
                    style: TextStyle(
                        color: Colors.indigo[900],
                        fontSize: 13,
                        fontWeight: FontWeight.bold),
                  ))),
                  DataColumn(
                      label: Container(
                          child: Text(
                    'Name',
                    style: TextStyle(
                        color: Colors.indigo[900],
                        fontSize: 13,
                        fontWeight: FontWeight.bold),
                  ))),
                  DataColumn(
                      label: Container(
                          child: Text(
                    'Created Date',
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
                ],
                rows: [])
          ),
          Padding(
            padding:
                const EdgeInsets.only(top: 150, left: 130, bottom: 350, right: 150),
            child: CustomDatafound(),
          ),
        ],
      );
    }
    return LayoutBuilder(builder: (context, constraints) {
// double padding = constraints.maxWidth * 0.065;
      double right = MediaQuery.of(context).size.width;
      //String? role = Provider.of<UserRoleProvider>(context).role;

      return Column(
        children: [
          Container(
            width: right -200,
            decoration: const BoxDecoration(
                color: Color(0xFFF7F7F7),
                border: Border.symmetric(
                    horizontal: BorderSide(color: Colors.grey, width: 0.5))),
            child:
              //  role == "Customer" ?
            DataTable(
                showCheckboxColumn: false,
                headingRowHeight: 40,
// List.generate(5, (index)
                columns: columns.map((column) {
                  return DataColumn(
                    label: Stack(
                      children: [
                        Container(
                          padding: null,
                          width: columnWidths[columns.indexOf(column)],
                          // Dynamic width based on user interaction
                          child: Row(
//crossAxisAlignment: CrossAxisAlignment.end,
//   mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                column,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.indigo[900],
                                  fontSize: 13,
                                ),
                              ),
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
                                                .clamp(136.0, 300.0);
                                      });
                                    },
                                    child: const Padding(
                                      padding: EdgeInsets.only(
                                          top: 10, bottom: 10),
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
                    math.min(itemsPerPage,
                        filteredData.length - (currentPage - 1) * itemsPerPage),
                    (index) {
                  final detail =
                      filteredData[(currentPage - 1) * itemsPerPage + index];
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
                        DataCell(
                          Container(
                            width: columnWidths[0],
                            // Same dynamic width as column headers
                            child: Text(
                              detail.deliveryId!.toString(),
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.deepOrange[200]
                                    : const Color(0xFFFFB315),
                              ),
                            ),
                          ),
                        ),
                        DataCell(
                          Container(
                            width: columnWidths[1],
                            child: Text(
                              detail.contactPerson!,
                              style: const TextStyle(
                                color: Color(0xFFA6A6A6),
                              ),
                            ),
                          ),
                        ),
                        DataCell(
                          Container(
                            width: columnWidths[2],
                            child: Text(
                              detail.modifiedAt!,
                              style: const TextStyle(
                                color: Color(0xFFA6A6A6),
                              ),
                            ),
                          ),
                        ),
                        DataCell(
                          Container(
                            width: columnWidths[3],
                            child: Text(
                              detail.total.toString(),
                              style: const TextStyle(
                                color: Color(0xFFA6A6A6),
                              ),
                            ),
                          ),
                        ),
                        DataCell(
                          Container(
                            width: columnWidths[4],
                            child: Text(detail.deliveryStatus,
                                style: TextStyle(
//fontSize: 16,
                                    color: detail.deliveryStatus ==
                                            "In Progress"
                                        ? Colors.orange
                                        : detail.deliveryStatus == "Delivered"
                                            ? Colors.green
                                            : Colors.grey)),
                          ),
                        ),
                      ],
                      onSelectChanged: (selected) {
                        if (selected != null && selected) {
                          if (filteredData.length <= 9) {
                            print(detail.deliveryStatus);
                            context.go('/Delivery_View', extra: {
                              'invoice': detail.invoiceNo,
                              'deliveryStatus': detail.deliveryStatus,
                              'deliveryId': detail.deliveryId,
                            });
                          } else {
                            context.go('/Delivery_View', extra: {
                              'invoice': detail.invoiceNo,
                              'deliveryStatus': detail.deliveryStatus,
                              'deliveryId': detail.deliveryId,
                            });
                          }
                        }
                      });
                }))

          ),
        ],
      );
    });
  }

  void _sortProducts(int columnIndex, String sortDirection) {
    if (sortDirection == 'asc') {
      filteredData.sort((a, b) {
        if (columnIndex == 0) {
          return a.deliveryId!.compareTo(b.deliveryId!);
        } else if (columnIndex == 1) {
          return a.contactPerson!.toLowerCase().compareTo(b.contactPerson!.toLowerCase());
        } else if (columnIndex == 2) {
          return a.modifiedAt!.compareTo(b.modifiedAt!);
        } else if (columnIndex == 3) {
          return a.total.compareTo(b.total);
        } else if (columnIndex == 4) {
          return a.deliveryStatus.compareTo(b.deliveryStatus);
        } else {
          return 0;
        }
      });
    } else {
      filteredData.sort((a, b) {
        if (columnIndex == 0) {
          return b.deliveryId!.compareTo(a.deliveryId!);
        } else if (columnIndex == 1) {
          return b.contactPerson!.toLowerCase().compareTo(a.contactPerson!.toLowerCase());
        } else if (columnIndex == 2) {
          return b.modifiedAt!.compareTo(a.modifiedAt!);
        } else if (columnIndex == 3) {
          return b.total.compareTo(a.total);
        } else if (columnIndex == 4) {
          return b.deliveryStatus.compareTo(a.deliveryStatus);
        } else {
          return 0;
        }
      });
    }
    setState(() {});
  }

  void _filterAndPaginateProducts() {
    filteredData = productList.where((product) {
      final matchesSearchText =
          product.deliveryId!.toLowerCase().contains(_searchText.toLowerCase());
      print('-----');
      print(product.modifiedAt);
      String orderYear = '';
      if (product.modifiedAt!.contains('/')) {
        final dateParts = product.modifiedAt!.split('/');
        if (dateParts.length == 3) {
          orderYear = dateParts[2]; // Extract the year
        }
      }
// final orderYear = element.orderDate.substring(5,9);
      if (status.isEmpty && selectDate.isEmpty) {
        return matchesSearchText; // Include all products that match the search text
      }
      if (status == 'Status' && selectDate == 'Select Year') {
        return matchesSearchText;
      }
      if (status == 'Status' && selectDate.isEmpty) {
        return matchesSearchText;
      }
      if (selectDate == 'Select Year' && status.isEmpty) {
        return matchesSearchText;
      }
      if (status == 'Status' && selectDate.isNotEmpty) {
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
      } //this one

      if (status.isNotEmpty && selectDate.isEmpty) {
        return matchesSearchText &&
            product.deliveryStatus == status; // Include all products
      }
      return matchesSearchText &&
          (product.deliveryStatus == status && orderYear == selectDate);
//  return false;
    }).toList();
    totalPages = (filteredData.length / itemsPerPage).ceil();

//   filteredData.sort((a, b) => a.orderId)
    setState(() {
      currentPage = 1;
    });
  }
}
