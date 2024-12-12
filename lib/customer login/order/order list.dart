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
import '../../Order Module/firstpage.dart';
import '../../widgets/custom loading.dart';
import '../../widgets/no datafound.dart';



class CusOrderPage extends StatefulWidget {
  const CusOrderPage({super.key});

  @override
  State<CusOrderPage> createState() => _CusOrderPageState();
}

class _CusOrderPageState extends State<CusOrderPage> {
  List<String> _sortOrder = List.generate(6, (index) => 'asc');
  List<String> columns = [
    'Order ID',
    'Order Date',
    'Invoice No',
    'Total Amount',
    'Delivery Status',
        'Payment Status',
  ];
  final ScrollController horizontalScroll = ScrollController();
  String userId = window.sessionStorage['userId'] ?? '';
  List<double> columnWidths = [95, 125, 115, 150, 140, 140];
  List<bool> columnSortState = [true, true, true, true, true, true];
  Timer? _searchDebounceTimer;
  String _searchText = '';
  bool isOrdersSelected = false;
  bool _hasShownPopup = false;
  bool _loading = false;
  detail? _selectedProduct;
  DateTime? _selectedDate;
  late TextEditingController _dateController;
  Map<String, dynamic> PaymentMap = {};
  int startIndex = 0;
  List<Product> filteredProducts = [];
  int currentPage = 1;
  String? dropdownValue1 = 'Status';
  late Future<List<detail>> futureOrders;
  List<detail> productList = [];

  final ScrollController _scrollController = ScrollController();
  List<dynamic> detailJson = [];
  String searchQuery = '';
  List<detail> filteredData = [];
  String status = '';
  String selectDate = '';
  Map<String, bool> _isHovered = {
    'Home':false,
    'Orders': false,
    'Invoice': false,
    'Delivery': false,
    'Payment': false,
    'Return': false,
  };


  List<Widget> _buildMenuItems(BuildContext context) {
    return [
    _buildMenuItem('Home', Icons.home_outlined, Colors.blue[900]!, '/Cus_Home'),
      Container( decoration: BoxDecoration(
        color: Colors.blue[800],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(8), // Radius for top-left corner
          topRight: Radius.circular(8), // No radius for top-right corner
          bottomLeft: Radius.circular(8), // Radius for bottom-left corner
          bottomRight: Radius.circular(8), // No radius for bottom-right corner
        ),
      ),
          child: _buildMenuItem('Orders', Icons.warehouse_outlined, Colors.blueAccent, '/Customer_Order_List')),
      _buildMenuItem('Delivery', Icons.fire_truck_outlined, Colors.blue[900]!, '/Customer_Delivery_List'),
      _buildMenuItem('Invoice', Icons.document_scanner_outlined, Colors.blue[900]!, '/Customer_Invoice_List'),

      _buildMenuItem('Payment', Icons.payment_outlined, Colors.blue[900]!, '/Customer_Payment_List'),
      _buildMenuItem('Return', Icons.keyboard_return, Colors.blue[900]!, '/Customer_Return_List')
    ];
  }

  Widget _buildMenuItem(String title, IconData icon, Color iconColor, String route) {
    iconColor = _isHovered[title] == true ? Colors.blue : Colors.black87;
    title == 'Orders'? _isHovered[title] = false :  _isHovered[title] = false;
    title == 'Orders'? iconColor = Colors.white : Colors.black;
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
  int itemCount = 0;
  bool isLoading = false;
  Future<void> fetchCount() async {

    try {
      final response = await http.get(
        Uri.parse(
            '$apicall/order_master/get_all_draft_master'
        ),
        headers: {
          "Content-type": "application/json",
          "Authorization": 'Bearer $token',
        },
      );
      if(token == " ") {
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
                          Text(
                            "Please log in again to continue", style: TextStyle(
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
      else {
        if (response.statusCode == 200) {
          final jsonData = jsonDecode(response.body);
// print('json data');
// print(jsonData);
          List<detail> products = [];
          if (jsonData != null) {
            if (jsonData is List) {
              products = jsonData.map((item) => detail.fromJson(item)).toList();
            }
            else if (jsonData is Map && jsonData.containsKey('body')) {
              products = (jsonData['body'] as List)
                  .map((item) => detail.fromJson(item))
                  .toList();
            }
            List<detail> matchedCustomers = products.where((customer) {
              return customer.CusId == userId;
            }).toList();

            if (matchedCustomers.isNotEmpty) {
              setState(() {
                print('pages');
                itemCount = products.length;
                print(itemCount);
              });
            }
          }
        } else {
          throw Exception('Failed to load data');
        }
      }
    } catch (e) {
      print('Error decoding JSON: $e');
// Optionally, show an error message to the user
    } finally {
      if (mounted) {
      }
    }
  }

  Future<void> fetchProducts(int page, int itemsPerPage) async {
    if (isLoading) return;
    if (!mounted) return;

    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse(
            '$apicall/order_master/get_all_ordermaster?page=$page&limit=$itemsPerPage'
        ),
        headers: {
          "Content-type": "application/json",
          "Authorization": 'Bearer $token',
        },
      );
      if(token == " ") {
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
                          Text(
                            "Please log in again to continue", style: TextStyle(
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
      else {
        if (response.statusCode == 200) {
          final jsonData = jsonDecode(response.body);
          List<detail> products = [];

          if (jsonData != null) {
            if (jsonData is List) {
              products = jsonData.map((item) => detail.fromJson(item)).toList();
            } else if (jsonData is Map && jsonData.containsKey('body')) {
              products = (jsonData['body'] as List)
                  .map((item) => detail.fromJson(item))
                  .toList();
              totalItems = jsonData['totalItems'] ?? 0;
            }

            print('user');
            print(userId);

            // Check the data structure
            print('Product Customer IDs:');
            products.forEach((product) => print(product.CusId));

            // Apply filtering for CusId
            List<detail> matchedCustomers = products.where((customer) {
              return customer.CusId!.trim().toLowerCase() ==
                  userId.trim().toLowerCase();
            }).toList();

            if (matchedCustomers.isNotEmpty) {
              setState(() {
                totalPages = (matchedCustomers.length / itemsPerPage).ceil();
                print('pages');
                print(totalPages);
                productList = matchedCustomers; // Use matchedCustomers
                print(productList);
                _filterAndPaginateProducts();
              });
            } else {
              print('No matching customers found for userId: $userId');
            }
          }
        } else {
          throw Exception('Failed to load data');
        }
      }
    } catch (e) {
      print('Error decoding JSON: $e');
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

  @override
  void initState() {
    super.initState();
    print(userId);
    fetchCount();

    _dateController = TextEditingController();
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
        backgroundColor: const Color(0xFFF0F4F8),
        appBar: AppBar(
          backgroundColor: const Color(0xFFFFFFFF),
          title: Image.asset("images/Final-Ikyam-Logo.png"),
          elevation: 2.0,
          shadowColor: const Color(0xFFFFFFFF),
          actions: [
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Align(
                alignment: Alignment.topLeft,
                child: Stack(
                  clipBehavior: Clip.none, // This ensures the badge can be positioned outside the icon bounds
                  children: [
                    IconButton(
                      icon: const Icon(Icons.shopping_cart),
                      onPressed: () {
                        context.go('/Customer_Draft_List');
                        // Handle notification icon press
                      },
                    ),
                    Positioned(
                      right: 0,
                      top: -5, // Adjust this value to move the text field
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.red, // Background color of the badge
                          shape: BoxShape.circle,
                        ),
                        child:  Text(
                          '${itemCount}', // The text field value (like a badge count)
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12, // Adjust the font size as needed
                          ),
                        ),
                      ),
                    ),
                  ],
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
              if (constraints.maxHeight <= 310) ...{
                SingleChildScrollView(
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Container(
                      width: 200,
                      color: const Color(0xFFF7F6FA),
                      padding:
                      const EdgeInsets.only(left: 15, top: 10, right: 15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: _buildMenuItems(context),
                      ),
                    ),
                  ),
                )
              } else ...{
                Align(
                  alignment: Alignment.topLeft,
                  child: Container(
                    width: 200,
                    height: 984,
                    color: const Color(0xFFF7F6FA),
                    padding:
                    const EdgeInsets.only(left: 15, top: 10, right: 15),
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
                  decoration: BoxDecoration(
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
                  mainAxisAlignment: MainAxisAlignment.end,
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
                                child: OutlinedButton(
                                  onPressed: () {
                                    context.go('/Cus_Create_Order',extra: {'testing': 'hi'});
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
                    if(constraints.maxWidth >= 1350)...{
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
                                  'Created',
                                  'Picked',
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
                                  height: 100, // Button height
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
      double right = MediaQuery.of(context).size.width;
      return Column(
        children: [
          Container(
            width: 1170,
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
      double right = MediaQuery.of(context).size.width;

      return Column(
        children: [
          Container(
            width: 1170,

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
                                    ?SizedBox(width: 12,
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
                              Spacer(),
                              MouseRegion(
                                cursor: SystemMouseCursors.resizeColumn,
                                child: GestureDetector(
                                    onHorizontalDragUpdate: (details) {
                                      setState(() {
                                        columnWidths[columns.indexOf(column)] +=
                                            details.delta.dx;
                                        columnWidths[columns.indexOf(column)] =
                                            columnWidths[
                                            columns.indexOf(column)]
                                                .clamp(50.0, 300.0);
                                      });
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
                  // Filter the data to only include rows where draftId is empty
                    math.min(
                      itemsPerPage,
                      filteredData.length - (currentPage - 1) * itemsPerPage,
                    ),
                        (index) {
                      // Get the filtered list

                      final detail = filteredData.skip((currentPage - 1) * itemsPerPage).elementAt(index);
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
                                  style: const TextStyle(
                                    color: Color(0xFFA6A6A6),
                                  ),
                                ),
                              ),
                            ),
                            DataCell(
                              Container(
                                width: columnWidths[1],
                                child: Text(
                                  detail.orderDate,
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
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.deepOrange[200]
                                        : const Color(0xFFFFB315),
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
                              if (filteredData.length <= 9) {
                                PaymentMap = {
                                  'paymentId': detail.paymentDate,
                                  'paymentmode': detail.paymentMode,
                                  'paymentStatus': detail.paymentStatus,
                                  'paymentdate': detail.paymentDate,
                                  'paidamount': detail.paidAmount,
                                };
                                context.go('/Draft_Placed_List', extra: {
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
                                context.go('/Draft_Placed_List', extra: {
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
// Add other fields as neede
                                  )).toList(),
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
            width: right - 200,
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
                                    ?SizedBox(width: 12,
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
                              Spacer(),
                              MouseRegion(
                                cursor: SystemMouseCursors.resizeColumn,
                                child: GestureDetector(
                                    onHorizontalDragUpdate: (details) {
                                      setState(() {
                                        columnWidths[columns.indexOf(column)] +=
                                            details.delta.dx;
                                        columnWidths[columns.indexOf(column)] =
                                            columnWidths[
                                            columns.indexOf(column)]
                                                .clamp(50.0, 300.0);
                                      });
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
                  // Filter the data to only include rows where draftId is empty
                    math.min(
                      itemsPerPage,
                      filteredData.length - (currentPage - 1) * itemsPerPage,
                    ),
                        (index) {
                      // Get the filtered list

                          final detail = filteredData.skip((currentPage - 1) * itemsPerPage).elementAt(index);
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
                                  style: const TextStyle(
                                    color: Color(0xFFA6A6A6),
                                  ),
                                ),
                              ),
                            ),
                            DataCell(
                              Container(
                                width: columnWidths[1],
                                child: Text(
                                  detail.orderDate,
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
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.deepOrange[200]
                                        : const Color(0xFFFFB315),
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
                              if (filteredData.length <= 9) {
                                PaymentMap = {
                                  'paymentId': detail.paymentDate,
                                  'paymentmode': detail.paymentMode,
                                  'paymentStatus': detail.paymentStatus,
                                  'paymentdate': detail.paymentDate,
                                  'paidamount': detail.paidAmount,
                                };
                                context.go('/Draft_Placed_List', extra: {
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
                                context.go('/Draft_Placed_List', extra: {
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
// Add other fields as neede
                                  )).toList(),
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
          return a.paymentStatus!.compareTo(b.paymentStatus!);
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
          return b.paymentStatus!.compareTo(a.paymentStatus!);
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


