import 'dart:async';
import 'dart:convert';
import 'dart:html';
import 'dart:math' as math;
import 'package:btb/admin/Api%20name.dart';
import 'package:btb/widgets/confirmdialog.dart';
import 'package:btb/widgets/pagination.dart';
import 'package:btb/widgets/productclass.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../main.dart';
import '../widgets/custom loading.dart';
import '../widgets/no datafound.dart';

void main() {
  runApp(const Orderspage());
}

class Orderspage extends StatefulWidget {
  const Orderspage({super.key});

  @override
  State<Orderspage> createState() => _OrderspageState();
}

class _OrderspageState extends State<Orderspage> with SingleTickerProviderStateMixin {
  List<String> _sortOrder = List.generate(6, (index) => 'asc');
  List<String> columns = [
    'Order ID',
    'Order Date',
    'Invoice No',
    'Total',
    'Delivery Status',
    'Payment Status',
  ];
  List<double> columnWidths = [95, 110, 110, 95, 152, 140];
  List<bool> columnSortState = [true, true, true, true, true, true];
  Timer? _searchDebounceTimer;
  String _searchText = '';
  bool isOrdersSelected = false;
  bool _loading = false;
  detail? _selectedProduct;
  late TextEditingController _dateController;
  Map<String, dynamic> PaymentMap = {};
  int startIndex = 0;
  List<Product> filteredProducts = [];
  int currentPage = 1;
  String? dropdownValue1 = 'Status';
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
  late Future<List<detail>> futureOrders;
  List<detail> productList = [];

  final ScrollController _scrollController = ScrollController();
  List<dynamic> detailJson = [];
  String searchQuery = '';
  List<detail> filteredData = [];
  late AnimationController _controller;
  bool _isHovered1 = false;
  late Animation<double> _shakeAnimation;
  String status = '';
  String selectDate = '';

  String token = window.sessionStorage["token"] ?? " ";
  String? dropdownValue2 = 'Select Year';

  void _onSearchTextChanged(String text) {
    if (_searchDebounceTimer != null) {
      _searchDebounceTimer!.cancel(); // Cancel the previous timer
    }
    _searchDebounceTimer = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        _searchText = text;
      });
    });
  }

  int itemsPerPage = 10;
  int totalItems = 0;
  int totalPages = 0;
  bool isLoading = false;

  Future<void> fetchProducts(int page, int itemsPerPage) async {
    if (isLoading) return;
    if (!mounted) return;
    setState(() {
      isLoading = true;
    });
    try {
      final response = await http.get(
        Uri.parse(
          '$apicall/order_master/get_all_ordermaster?page=$page&limit=$itemsPerPage', // Changed limit to 10
        ),
        headers: {
          "Content-type": "application/json",
          "Authorization": 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
// print('json data');
// print(jsonData);
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
// _clearSearch();
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
//_filterAndPaginateProducts();
  }


  List<Widget> _buildMenuItems(BuildContext context) {
    return [
      _buildMenuItem('Home', Icons.dashboard, Colors.blue[900]!, '/Home'),
      _buildMenuItem('Customer', Icons.account_circle, Colors.blue[900]!, '/Customer'),
      _buildMenuItem('Products', Icons.image_outlined, Colors.blue[900]!, '/Product_List'),
      _buildMenuItem('Orders', Icons.warehouse, Colors.blueAccent, '/Order_List'),
      _buildMenuItem('Invoice', Icons.document_scanner_rounded, Colors.blue[900]!, '/Invoice'),
      _buildMenuItem('Delivery', Icons.fire_truck_outlined, Colors.blue[900]!, '/Delivery_List'),
      _buildMenuItem('Payment', Icons.payment_outlined, Colors.blue[900]!, '/Payment_List'),
      _buildMenuItem('Return', Icons.backspace_sharp, Colors.blue[900]!, '/Return_List'),
      _buildMenuItem('Reports', Icons.insert_chart, Colors.blue[900]!, '/Report_List'),
    ];
  }

  Widget _buildMenuItem(String title, IconData icon, Color iconColor, String route) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered[title] = true),
      onExit: (_) => setState(() => _isHovered[title] = false),
      child: GestureDetector(
        onTap: () {
          context.go(route);
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 10,right: 20),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: _isHovered[title]! ? Colors.black12 : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
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
    );
  }

  @override
  void initState() {
    super.initState();
    _dateController = TextEditingController();
    fetchProducts(currentPage, itemsPerPage);
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
    //String? role = Provider.of<UserRoleProvider>(context).role;
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
        body: LayoutBuilder(builder: (context, constraints) {
          double maxWidth = constraints.maxWidth;
          double maxHeight = constraints.maxHeight;
          return Stack(
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: Container(
                  height: 1400,
                  width: 200,
                  color: const Color(0xFFF7F6FA),
                  padding: const EdgeInsets.only(left: 20, top: 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _buildMenuItems(context),

                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 200, top: 0),
                child: Container(
                  width: 1, // Set the width to 1 for a vertical line
                  height: 1400, // Set the height to your liking
                  decoration: BoxDecoration(
                    border:
                        Border(left: BorderSide(width: 1, color: Colors.grey)),
                  ),
                ),
              ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Padding(
                  padding: const EdgeInsets.only(left: 201),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    color: Colors.white,
                    height: 50,
                    child: Row(
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(left: 20),
                          child: Text(
                            'Orders List',
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
                                            BoxShadow(
                                                color: Colors.black45,
                                                blurRadius: 6,
                                                spreadRadius: 2)
                                          ]
                                              : [],
                                        ),
                                        child: OutlinedButton(
                                          onPressed: () {
                                            context.go('/Create_New_Order');
//context.go('/Home/Orders/Create_Order');
                                          },
                                          style: OutlinedButton.styleFrom(
                                            backgroundColor: Colors.blue[800],
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
              ),
              Padding(
                padding: const EdgeInsets.only(top: 40, left: 200),
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 10),
// Space above/below the border
                  height: 0.3, // Border height
                  color: Colors.black, // Border color
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                    left: 300, top: 120, right: maxWidth * 0.062, bottom: 15),
                child: Container(
                  width: maxWidth,
                  height: 700,
// decoration: BoxDecoration(
//   color: Colors.white, // or any other color that fits your design
//   borderRadius: BorderRadius.all(Radius.circular(10.0)), // adds a subtle rounded corner
//   border: Border.all(
//     color: Color(0xFFE5E5E5), // a light grey border
//     width: 1.0,
//   ),
//   boxShadow: [
//     BoxShadow(
//       color: Color(0xFFC7C5B8).withOpacity(0.2), // a soft, warm shadow
//       spreadRadius: 0.5,
//       blurRadius: 4, // increased blur radius for a softer shadow
//       offset: Offset(0, 4), // increased offset for a more pronounced shadow
//     ),
//   ],
// ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
// boxShadow: [
//   BoxShadow(
//     color: Colors.blue.withOpacity(0.1), // Soft grey shadow
//     spreadRadius: 1,
//     blurRadius: 3,
//     offset: const Offset(0, 1),
//   ),
// ],
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: SizedBox(
                      width: maxWidth * 0.79,
// padding: EdgeInsets.only(),
// margin: EdgeInsets.only(left: 400, right: 100),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          buildSearchField(),
// buildSearchField(),
                          const SizedBox(height: 10),
                          Scrollbar(
                            controller: _scrollController,
                            thickness: 6,
                            thumbVisibility: true,
                            child: SingleChildScrollView(
                              controller: _scrollController,
                              scrollDirection: Axis.horizontal,
                              child: buildDataTable(),
                            ),
                          ),
//Divider(color: Colors.grey,height: 1,)
                          SizedBox(),
                          Padding(
                            padding: const EdgeInsets.only(right: 30),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                PaginationControls(
                                  currentPage: currentPage,
                                  totalPages: filteredData.length > itemsPerPage
                                      ? totalPages
                                      : 1,
                                  // totalPages,
                                  onPreviousPage: _goToPreviousPage,
                                  onNextPage: _goToNextPage,
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
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
                              hintText: 'Search by Order ID',
                              hintStyle:
                                  TextStyle(fontSize: 13, color: Colors.grey),
                              contentPadding:
                                  EdgeInsets.only(bottom: 20, left: 10),
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
                                  'Not Started',
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
                                isExpanded: true,
                               // focusColor: Color(0xFFF0F4F8),
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
                               // focusColor: Color(0xFFF0F4F8),
                                isExpanded: true,
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
      double right = MediaQuery.of(context).size.width;
      return Column(
        children: [
          Container(
            width: right * 0.78,
            decoration: const BoxDecoration(
                color: Color(0xFFF7F7F7),
                border: Border.symmetric(
                    horizontal: BorderSide(color: Colors.grey, width: 0.5))),
            child: DataTable(
                showCheckboxColumn: false,
                headingRowHeight: 40,
                columns:  columns.map((column) {
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
                                    ? Icon(
                                  Icons.arrow_circle_up,
                                  size: 20,
                                )
                                    : Icon(
                                  Icons.arrow_circle_down,
                                  size: 20,
                                ),
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
                              Spacer(),
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
                                                .clamp(50.0, 300.0);
                                      });
// setState(() {
//   columnWidths[columns.indexOf(column)] += details.delta.dx;
//   if (columnWidths[columns.indexOf(column)] < 50) {
//     columnWidths[columns.indexOf(column)] = 50; // Minimum width
//   }
// });
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.only(
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
                rows: []),
          ),
          Padding(
            padding:
                EdgeInsets.only(top: 150, left: 130, bottom: 350, right: 150),
            child: CustomDatafound(),
          ),
        ],
      );
    }
    return LayoutBuilder(builder: (context, constraints) {
// double padding = constraints.maxWidth * 0.065;
      double right = MediaQuery.of(context).size.width;

      return Column(
        children: [
          Container(
            width: right * 0.78,

            decoration: const BoxDecoration(
                color: Color(0xFFF7F7F7),
                border: Border.symmetric(
                    horizontal: BorderSide(color: Colors.grey, width: 0.5))),
            child: DataTable(
                showCheckboxColumn: false,
                headingRowHeight: 40,
// List.generate(5, (index)
                columns:
                columns.map((column) {
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
                              Spacer(),
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
                                                .clamp(50.0, 300.0);
                                      });
// setState(() {
//   columnWidths[columns.indexOf(column)] += details.delta.dx;
//   if (columnWidths[columns.indexOf(column)] < 50) {
//     columnWidths[columns.indexOf(column)] = 50; // Minimum width
//   }
// });
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.only(
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
                              detail.orderId.toString(),
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
                              detail.orderDate!,
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
                              detail.invoiceNo!,
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
                            child: Text(
                              detail.deliveryStatus.toString(),
                              style:  TextStyle(
                                color: detail.deliveryStatus == "In Progress" ? Colors.orange : detail.deliveryStatus == "Delivered" ? Colors.green : Colors.red,
                              ),
                            ),
                          ),
                        ),
                        DataCell(
                          Container(
                            width: columnWidths[4],
                            child: Text(
                              detail.paymentStatus.toString(),
                              style: const TextStyle(
                                color: Color(0xFFA6A6A6),
                              ),
                            ),
                          ),
                        ),

                      ],
                      onSelectChanged: (selected) {
                        if (selected != null && selected) {
                          print('what is this');
                          print(detail.invoiceNo);
                          print(productList);
                          print(detail.paymentStatus);
//final detail = filteredData[(currentPage - 1) * itemsPerPage + index];

                          if (filteredData.length <= 9) {
                            PaymentMap = {
                              'paymentId': detail.paymentDate,
                              'paymentmode': detail.paymentMode,
                              'paymentStatus': detail.paymentStatus,
                              'paymentdate': detail.paymentDate,
                              'paidamount': detail.paidAmount,
                            };
                            context.go('/Order_Placed_List', extra: {
                              'product': detail,
                              'item': [], // pass an empty list of maps
                              'body': {},
                              'status': detail.deliveryStatus,
                              'InvNo': detail.invoiceNo,
                              'paymentStatus': PaymentMap,
                              'itemsList': [], // pass an empty list of maps
                              'orderDetails': productList
                                  .map((detail) => OrderDetail(
                                        orderId: detail.orderId,
                                        orderDate: detail.orderDate, items: [],
                                        deliveryStatus: detail.deliveryStatus,
// Add other fields as needed
                                      ))
                                  .toList(),
                            });
                          } else {
                            PaymentMap = {
                              'paymentId': detail.paymentDate,
                              'paymentmode': detail.paymentMode,
                              'paymentStatus': detail.paymentStatus,
                              'paymentdate': detail.paymentDate,
                              'paidamount': detail.paidAmount,
                            };
                            context.go('/Order_Placed_List', extra: {
                              'product': detail,
                              'item': [], // pass an empty list of maps
                              'status': detail.deliveryStatus,
                              'InvNo': detail.invoiceNo,
                              'paymentStatus': PaymentMap,
                              'body': {},
                              'itemsList': [], // pass an empty list of maps
                              'orderDetails': filteredData
                                  .map((detail) => OrderDetail(
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

  void _sortProducts(int columnIndex, String sortDirection) {
    if (sortDirection == 'asc') {
      filteredData.sort((a, b) {
        if (columnIndex == 0) {
          return a.paymentStatus!.toLowerCase().compareTo(b.paymentStatus!.toLowerCase());
        } else if (columnIndex == 1) {
          return a.orderId!.compareTo(b.orderId!);
        } else if (columnIndex == 2) {
          return a.orderDate.compareTo(b.orderDate);
        } else if (columnIndex == 3) {
          return a.invoiceNo!.compareTo(b.invoiceNo!);
        } else if (columnIndex == 4) {
          return a.total.compareTo(b.total);
        } else if (columnIndex == 5) {
          return a.deliveryStatus.compareTo(b.deliveryStatus);
        } else {
          return 0;
        }
      });
    } else {
      filteredData.sort((a, b) {
        if (columnIndex == 0) {
          return b.paymentStatus!.toLowerCase().compareTo(a.paymentStatus!.toLowerCase());
        } else if (columnIndex == 1) {
          return b.orderId!.compareTo(a.orderId!);
        } else if (columnIndex == 2) {
          return b.orderDate.compareTo(a.orderDate);
        } else if (columnIndex == 3) {
          return b.invoiceNo!.compareTo(a.invoiceNo!);
        } else if (columnIndex == 4) {
          return b.total.compareTo(a.total);
        } else if (columnIndex == 5) {
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
          product.orderId!.toLowerCase().contains(_searchText.toLowerCase());
// print('-----');
// print(product.orderDate);
      String orderYear = '';
      if (product.orderDate.contains('/')) {
        final dateParts = product.orderDate.split('/');
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
      }

      if (status.isNotEmpty && selectDate.isEmpty) {
        return matchesSearchText &&
            product.deliveryStatus == status; // Include all products
      }
      return matchesSearchText &&
          (product.deliveryStatus == status && orderYear == selectDate);
//  return false;
    }).toList();
    totalPages = (filteredData.length / itemsPerPage).ceil();
//totalPages = (productList.length / itemsPerPage).ceil();
    setState(() {
      currentPage = 1;
    });
  }
}

class detail {
  final String? orderId;
  final String? draftId;
  final String? prodId;
  final String? deliveryId;
  final String? productName;
  final String? category;
  final String? paidBy;
  final String? value;
  final String orderDate;
  final String? CusId;
  final String? invoiceNo;
  final double? creditUsed;
  final String? modifiedAt;
  bool isSelected = false;
  final double total;
  String status;
  final String deliveryStatus;
  final String referenceNumber;
  final String? deliveryLocation;
  final String? deliveryAddress;
  final String? contactPerson;
  final String? contactNumber;
  final String? comments;
  final List<dynamic> items;
  final double? totalAmount;
  final double? grossAmount;
  final double? payableAmount;
  final double? paidAmount;
  final double? exactPaidAmount;
  final String? createdDate;
  final String? deliveredDate;
  final String? paymentStatus;
  final String? transactionsId;
  final String? paymentDate;
  final String? paymentMode;
  final String? paymentId;

  final String? customerName;

  detail({
    this.paidBy,
    this.orderId,
    this.paymentStatus,
    this.invoiceNo,
    this.customerName,
    required this.orderDate,
    this.creditUsed,
    required this.total,
    this.prodId,
    this.paidAmount,
    this.CusId,
    this.exactPaidAmount,
    this.paymentDate,
    this.payableAmount,
    this.draftId,
    this.transactionsId,
    this.modifiedAt,
    this.grossAmount,
    this.deliveredDate,
    this.totalAmount,
    this.createdDate,
    this.productName,
    this.category,
    this.paymentId,
    required this.status,
    this.deliveryId,
    required this.deliveryStatus,
    this.paymentMode,
    this.value,
    required this.referenceNumber,
    this.deliveryLocation,
    this.deliveryAddress,
    this.contactPerson,
    this.contactNumber,
    this.comments,
    required this.items,
  });

  factory detail.fromJson(Map<String, dynamic> json) {
    return detail(
      exactPaidAmount: json['exactPaidAmount'] ?? 0.0,
      customerName: json['customerName'] ?? '',
      paidBy: json['paidBy'] ?? '',
      paymentStatus: json['paymentStatus'] ?? '',
      CusId: json['customerId'] ?? '',
      creditUsed: json['returnCreditUsed'] ?? 0.0,
      transactionsId: json['transactionsId'] ?? '',
      paymentDate: json['paymentDate'] ?? '',
      deliveredDate: json['deliveredDate'] ?? '',
      paidAmount: json['paidAmount'] ?? 0.0,
      draftId: json['draftId'] ?? '',
      invoiceNo: json['invoiceNo'] ?? '',
      orderId: json['orderId'] ?? '',
      createdDate: json['createdDate'] ?? '',
      paymentId: json['paymentId'] ?? '',
      paymentMode: json['paymentMode'] ?? '',
      payableAmount: json['payableAmount'] ?? 0.0,
      grossAmount: json['grossAmount'] ?? 0.0,
      deliveryId: json['deliveryId'] ?? '',
      orderDate: json['orderDate'] ?? 'Unknown date',
      modifiedAt: json['modifiedAt'] ?? 'Unknown date',
      totalAmount: json['totalAmount'] ?? 0.0,
      //totalAmount: (json['totalAmount'] ?? 0.0).round(),
//totalAmount: json['totalAmount'] != null ? int.parse(json['totalAmount'].toString()) : 0,
      total: json['total'] ?? 0,
      status: json['status'] ??'',
      deliveryStatus: json['status'] ?? '',
      referenceNumber: '  ',
      prodId: json['prodId'] ?? '',
      productName: json['productName'] ?? '',
      category: json['category'] ?? '',
      deliveryLocation: json['deliveryLocation'] ?? '',
      deliveryAddress: json['deliveryAddress'] ?? '',
      contactPerson: json['contactPerson'] ?? '',
      contactNumber: json['contactNumber'] ?? '',
      comments: json['comments'] ?? '',
      items: json['items'] ?? [],
    );
  }

  factory detail.fromString(String jsonString) {
    final jsonMap = jsonDecode(jsonString);
    return detail.fromJson(jsonMap);
  }

  @override
  String toString() {
    return 'Order ID: $orderId,Invoice Number: $invoiceNo,Total Amount: $total,Payable Amount: $payableAmount,Delivery Date: $deliveredDate, Order Date: $orderDate, Total: $grossAmount, Status: $status, Delivery Status: $deliveryStatus, Reference Number: $referenceNumber';
  }

  String toJson() {
    return jsonEncode({
      "orderId": orderId,
      "orderDate": orderDate,
      "total": total,
      "paidBy": paidBy,
      "status": status,
      "deliveryStatus": deliveryStatus,
      "referenceNumber": referenceNumber,
      "items": items,
      "deliveryLocation": deliveryLocation,
      "deliveryAddress": deliveryAddress,
      "contactPerson": contactPerson,
      "contactNumber": contactNumber,
      "comments": comments,
    });
  }
}
// class detail {
//   final String? orderId;
//   final String? prodId;
//   final String? productName;
//   final String? category;
//   final int? totalAmount;
//   final String? value;
//   final String? deliveredDate;
//   final String orderDate;
//   bool isSelected = false;
//   final double total;
//   final String? payment;
//   final String? status;
//   final String? deliveryStatus;
//   final String referenceNumber;
//   final String? createdDate;
//   final String? deliveryLocation;
//   final String? deliveryAddress;
//   final String? contactPerson;
//   final String? contactNumber;
//   final String? comments;
//   final List<dynamic> items;
//
//   detail({
//     this.orderId,
//     required this.orderDate,
//     required this.total,
//     this.prodId,
//     this.totalAmount,
//     this.productName,
//     this.payment,
//     this.createdDate,
//     this.deliveredDate,
//     this.category,
//     required this.status,
//     required this.deliveryStatus,
//     this.value,
//     required this.referenceNumber,
//     this.deliveryLocation,
//     this.deliveryAddress,
//     this.contactPerson,
//     this.contactNumber,
//     this.comments,
//     required this.items,
//
//   });
//
//   factory detail.fromJson(Map<String, dynamic> json) {
//     return detail(
//       orderId: json['orderId'] ?? '',
//       payment: 'To be Done',
//       orderDate: json['orderDate'] ?? 'Unknown date',
//       total: json['total'] ?? 0,
//       deliveredDate: json['deliveredDate'] ?? '',
//       status: json['status'] ?? '',
//       totalAmount: json['totalAmount'] != null ? int.parse(json['totalAmount'].toString()) : 0,
//       // Dummy value
//       deliveryStatus: json['status'] ?? 'Unknown',
//       // Dummy value
//       referenceNumber: '  ', // Dummy value
//       prodId: json['prodId'],
//       createdDate: json['createdDate'] ?? '',
//       productName: json['productName'],
//       category: json['category'],
//       deliveryLocation: json['deliveryLocation'],
//       deliveryAddress: json['deliveryAddress'],
//       contactPerson: json['contactPerson'],
//       contactNumber: json['contactNumber'],
//       comments: json['comments'],
//       items: json['items'] ?? [],
//     );
//   }
//
//   factory detail.fromString(String jsonString) {
//     final jsonMap = jsonDecode(jsonString);
//     return detail.fromJson(jsonMap);
//   }
//
//   @override
//   String toString() {
//     return 'Order ID: $orderId, Order Date: $orderDate, Total: $total, Status: $status, Delivery Status: $deliveryStatus, Reference Number: $referenceNumber, items: $items';
//   }
//
//   String toJson() {
//     return jsonEncode({
//       "orderId": orderId,
//       "orderDate": orderDate,
//       "total": total,
//       "status": status,
//       "deliveryStatus": deliveryStatus,
//       "referenceNumber": referenceNumber,
//       "items": items,
//       "deliveryLocation": deliveryLocation,
//       "deliveryAddress": deliveryAddress,
//       "contactPerson": contactPerson,
//       "contactNumber": contactNumber,
//       "comments": comments,
//     });
//   }
// }

class OrderDetail {
  String? draftId;
  String? customerId;
  String? orderId;
  String? orderDate;
  String? referenceNumber;
  double? total;
  String? deliveryStatus;
  String? Status;
  double? paidAmount;
  double? payableAmount;
  String? status;
  String? Payment;
  String? paymentId;
  String? orderCategory;
  String? deliveredDate;
  String? paymentMode;
  String? paymentDate;
  String? deliveryId;
  final String? deliveryLocation;
  final String? deliveryAddress;
  final String? contactPerson;
  final String? contactNumber;
  final String? comments;
  final List<dynamic> items;
  String? InvNo;

  OrderDetail({
    this.customerId,
    this.draftId,
    this.orderId,
    this.orderDate,
    this.deliveredDate,
    this.paymentDate,
    this.paymentMode,
    this.orderCategory,
    this.paidAmount,
    this.payableAmount,
    this.referenceNumber,
    this.deliveryId,
    this.total,
    this.InvNo,
    this.deliveryStatus,
    this.Status,
    this.status,
    this.deliveryLocation,
    this.paymentId,
    this.deliveryAddress,
    this.contactPerson,
    this.contactNumber,
    this.comments,
    this.Payment,
    required this.items,
  });

  factory OrderDetail.fromJson(Map<String, dynamic> json) {
    return OrderDetail(
      customerId: json['customerId'] ?? '',
      draftId: json['draftId'] ?? '',
      orderId: json['orderId'] ?? '',
      payableAmount: json['payableAmount'] ?? 0.0,
      paymentDate: json['paymentDate'] ?? '',
      paymentMode: json['paymentMode'] ?? '',
      paidAmount: json['paidAmount'] ?? 0.0,
      orderCategory: json['orderCategory'] ?? '',
      deliveryId: json['deliveryId'] ?? '',
      orderDate: json['orderDate'] ?? 'Unknown date',
      total: json['total'] ?? 0.0,
      deliveredDate: json['deliveredDate'] ?? '',
      Status: 'In preparation',
      status: json['status'] ?? '',
      paymentId: json['paymentId'] ?? '',
      Payment: json['paymentStatus'] ?? '',
// Dummy value
      deliveryStatus: 'Not Started' ?? '',
// Dummy value
      referenceNumber: '  ',
      // Dummy value
      deliveryLocation: json['deliveryLocation'],
      deliveryAddress: json['deliveryAddress'],
      contactPerson: json['contactPerson'],
      contactNumber: json['contactNumber'],
      comments: json['comments'],
      items: json['items'],
      InvNo: json['invoiceNo'] ?? '',
    );
  }

  factory OrderDetail.fromString(String jsonString) {
    final jsonMap = jsonDecode(jsonString);
    return OrderDetail.fromJson(jsonMap);
  }

  @override
  String toString() {
    return 'Order ID: $orderId, Draft ID: $draftId, Order Date: $orderDate, Total: $total, Status: $Status, Delivery Status: $deliveryStatus, Reference Number: $referenceNumber';
  }

  String toJson() {
    return jsonEncode({
      "customerId": customerId,
      "draftId": draftId,
      "orderId": orderId,
      "orderDate": orderDate,
      "total": total,
      "status": Status,
      "deliveryStatus": deliveryStatus,
      "referenceNumber": referenceNumber,
      "items": items,
      "deliveryLocation": deliveryLocation,
      "deliveryAddress": deliveryAddress,
      "contactPerson": contactPerson,
      "contactNumber": contactNumber,
      "comments": comments,
    });
  }
}
