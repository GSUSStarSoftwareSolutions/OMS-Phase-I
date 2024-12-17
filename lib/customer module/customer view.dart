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
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import '../Order Module/firstpage.dart';
import '../dashboard/dashboard.dart';
import '../main.dart';
import '../widgets/custom loading.dart';
import '../widgets/no datafound.dart';
import '../widgets/text_style.dart';

void main() {
  runApp(const CustomerDetails());
}

class CustomerDetails extends StatefulWidget {
  final String? orderId;
  const CustomerDetails({super.key,this.orderId});

  @override
  State<CustomerDetails> createState() => _CustomerDetailsState();
}

class _CustomerDetailsState extends State<CustomerDetails> with SingleTickerProviderStateMixin {
  List<String> _sortOrder = List.generate(5, (index) => 'asc');
  List<String> columns = [
    'Order ID',
    'Customer Name',
    'Order Date',
    'Total',
    'Status',
  ];
  bool _hasShownPopup = false;
  List<double> columnWidths = [110, 150, 120, 95, 140];
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
  final ScrollController horizontalScroll = ScrollController();

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
            print(widget.orderId);

            // Check the data structure
            print('Product Customer IDs:');
            products.forEach((product) => print(product.CusId));

            // Apply filtering for CusId
            List<detail> matchedCustomers = products.where((customer) {
              return customer.CusId!.trim().toLowerCase() ==
                  widget.orderId!.trim().toLowerCase();
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
              print('No matching customers found for userId: ${widget.orderId}');
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

  Map<String, bool> _isHovered = {
    'Home': false,
    'Customer': false,
    'Products': false,
    'Orders': false,
  };


  Widget _buildMenuItem(
      String title, IconData icon, Color iconColor, String route) {
    iconColor = _isHovered[title] == true ? Colors.blue : Colors.black87;
    title == 'Customer' ? _isHovered[title] = false : _isHovered[title] = false;
    title == 'Customer' ? iconColor = Colors.white : Colors.black;
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
                  style: TextStyle(
                    color: iconColor,
                    fontSize: 15,
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
  List<Widget> _buildMenuItems(BuildContext context) {
    return [
      Column(
        children: [
          const SizedBox(
            height: 10,
          ),
          _buildMenuItem('Home', Icons.home_outlined,
              Colors.blue[900]!, '/Home'),
          _buildMenuItem('Product', Icons.production_quantity_limits,
              Colors.blue[900]!, '/Product_List'),
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
              child:  _buildMenuItem(
    'Customer', Icons.account_circle_outlined, Colors.white, '/Customer')
    ),
    _buildMenuItem(
    'Orders', Icons.warehouse_outlined, Colors.blue[900]!, '/Order_List')

        ],
      ),
      const SizedBox(
        height: 6,
      ),



    ];
  }
  List<Widget> _buildMenuItems1(BuildContext context) {
    return [
      Column(
        children: [
          const SizedBox(
            height: 10,
          ),
          _buildMenuItem1(Icons.home_outlined,
              Colors.blue[900]!, '/Home'),
          _buildMenuItem1(Icons.production_quantity_limits,
              Colors.blue[900]!, '/Product_List'),
          _buildMenuItem1(Icons.account_circle_outlined, Colors.white, '/Customer'),
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
              child: _buildMenuItem1(Icons.production_quantity_limits, Colors.blue[900]!, '/Order_List')),

        ],
      ),
      const SizedBox(
        height: 6,
      ),



    ];
  }
  Widget _buildMenuItem1(IconData icon, Color iconColor, String route) {
    iconColor = _isHovered[route] == true ? Colors.blue : Colors.black87;
    route == '/Order_List' ? _isHovered[route] = false : _isHovered[route] = false;
    route == '/Order_List' ? iconColor = Colors.white : Colors.black;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(
            () => _isHovered[route] = true,
      ),
      onExit: (_) => setState(() => _isHovered[route] = false),
      child: GestureDetector(
        onTap: () {
          context.go(route);
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 5, right: 20),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: _isHovered[route]! ? Colors.black12 : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.only(left: 10,top:2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(icon, color: iconColor,size: 20,),

              ],
            ),
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
        backgroundColor: Colors.grey[50],

        body: LayoutBuilder(builder: (context, constraints) {
          double maxWidth = constraints.maxWidth;
          double maxHeight = constraints.maxHeight;
          return Stack(
            children: [
              Container(
                color: Colors.white, // White background color
                height: 60.0, // Total height including bottom shadow
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
                            // Adjusted to better match proportions
                          ),
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            const SizedBox(width: 10),
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
                    const SizedBox(
                      height: 7,
                    ),
                    const Divider(
                      height: 3.0,
                      thickness: 3.0, // Thickness of the shadow
                      color: Color(0x29000000), // Shadow color (#00000029)
                    ),
                  ],
                ),
              ),
              if (constraints.maxHeight <= 500) ...{
                Positioned(
                  top:60,
                  left:0,
                  right:0,
                  bottom: 0,child:   SingleChildScrollView(
                  child: Align(
                    // Added Align widget for the left side menu
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 2),
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

                ),),

                VerticalDividerWidget(
                  height: maxHeight,
                  color: Color(0x29000000),
                ),
              }
              else ...{
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 60),
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
                  color: Color(0x29000000),
                ),
              },

              Positioned(
                left:201,
                // left: constraints.maxWidth <= 600 ? 101: 201,
                top: 60,
                right: 0,
                bottom: 0,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [

                    if(constraints.maxWidth >= 1350)...{
                      Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(left: 30,top: 20),
                                      child: Text('Customer Order List',style: TextStyles.heading,),
                                    ),

                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Padding(
                                        padding: const EdgeInsets.only(
                                            left: 30,
                                            top:20,
                                            right: 30,
                                            bottom: 15),
                                        child: Container(
                                          height: 640,
                                          width: maxWidth * 0.8,
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      // crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(left: 30,top: 20),
                                          child: Text('Customer Order List',style: TextStyles.heading,),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Padding(
                                            padding: const EdgeInsets.only(
                                                left: 30,
                                                top: 25,
                                                right: 30,
                                                bottom: 15),
                                            child: Container(
                                              height: 640,
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

//    const SizedBox(height: 8),
                Row(
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
                                style: GoogleFonts.inter(    color: Colors.black,    fontSize: 13),
                                decoration: InputDecoration(
                                    hintText: 'Search by Order ID or Customer Name',
                                    hintStyle:
                                    TextStyle(fontSize: 13, color: Colors.grey),
                                    contentPadding:
                                    EdgeInsets.only(bottom: 20, left: 10),
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
                        ),
                      ],
                    ),
//                     Spacer(),
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
// // const SizedBox(height: 8),
//                         Padding(
//                           padding: const EdgeInsets.all(8.0),
//                           child: ConstrainedBox(
//                             constraints: BoxConstraints(
//                               maxWidth: constraints.maxWidth * 0.12,
//                               // reduced width
//                               maxHeight: 30, // reduced height
//                             ),
//                             child: Container(
//                               height: 35,
//                               decoration: BoxDecoration(
//                                 color: Colors.white,
//                                 borderRadius: BorderRadius.circular(2),
//                                 border: Border.all(color: Colors.grey),
//                               ),
//                               child: DropdownButtonFormField2<String>(
//                                 decoration: const InputDecoration(
//                                   contentPadding:
//                                   EdgeInsets.only(bottom: 15, left: 10),
//                                   // adjusted padding
//                                   border: InputBorder.none,
//                                   filled: true,
//                                   fillColor: Colors.white,
//                                   hintText: 'Category',
//                                   hintStyle: TextStyle(color: Colors.grey),
//                                 ),
//                                 value: dropdownValue1,
//                                 onChanged: (String? newValue) {
//                                   setState(() {
//                                     dropdownValue1 = newValue;
//                                     status = newValue ?? '';
//                                     _filterAndPaginateProducts();
//                                   });
//                                 },
//                                 items: <String>[
//                                   'Status',
//                                   'Not Started',
//                                   'Created',
//                                   'Picked',
//                                   'Delivered',
//                                 ].map<DropdownMenuItem<String>>((String value) {
//                                   return DropdownMenuItem<String>(
//                                     value: value,
//                                     child: Text(value,
//                                         style: TextStyle(
//                                             color: value == 'Status'
//                                                 ? Colors.grey
//                                                 : Colors.black,
//                                             fontSize: 13)),
//                                   );
//                                 }).toList(),
//                                 iconStyleData: const IconStyleData(
//                                   icon: Icon(
//                                     Icons.keyboard_arrow_down,
//                                     color: Colors.indigo,
//                                     size: 16,
//                                   ),
//                                   iconSize: 16,
//                                 ),
//                                 buttonStyleData: const ButtonStyleData(
//                                   height: 50, // Button height
//                                   padding: EdgeInsets.only(left: 10, right: 10), // Button padding
//                                 ),
//                                 dropdownStyleData: DropdownStyleData(
//                                   decoration: BoxDecoration(
//                                     borderRadius: BorderRadius.circular(7), // Rounded corners
//                                     color: Colors.white, // Dropdown background color
//                                   ),
//                                   maxHeight: 200, // Max height for dropdown items
//                                   width: constraints.maxWidth * 0.12, // Dropdown width
//                                   offset:  const Offset(0, -10),
//                                 ),
//                                 isExpanded: true,
//                                 // focusColor: Color(0xFFF0F4F8),
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),

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
            width:  1100,
            decoration: const BoxDecoration(
                color: Color(0xFFF7F7F7),
                border: Border.symmetric(
                    horizontal: BorderSide(color: Colors.grey, width: 0.5))),
            child: DataTable(
                showCheckboxColumn: false,
                headingRowHeight: 40,
                columnSpacing: 35,
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
                                  style: TextStyles.subhead
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
// double padding = constraints.maxWidth * 0.065;
      double right = MediaQuery.of(context).size.width * 0.92;

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
                                  style: TextStyles.subhead
                              ),
                              IconButton(
                                icon:
                                _sortOrder[columns.indexOf(column)] == 'asc'
                                    ?  SizedBox(
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
//Padding(
//  padding:  EdgeInsets.only(left: columnWidths[index]-50,),
//  child:
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
                                  style: TextStyles.body,
                                ),
                              ),
                            ),
                            DataCell(
                              Container(
                                width: columnWidths[2],
                                child: Text(
                                  detail.contactPerson!,
                                  style: TextStyles.body,
                                ),
                              ),
                            ),
                            DataCell(
                              Container(
                                width: columnWidths[1],
                                child: Text(
                                  detail.orderDate,
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
                            // DataCell(
                            //   Container(
                            //     width: columnWidths[4],
                            //     child: Text(
                            //       detail.paymentStatus.toString(),
                            //       style: TextStyles.body,
                            //     ),
                            //   ),
                            // ),

                          ],
                          onSelectChanged: (selected) {
                            if (selected != null && selected) {
                              print('what is this');
                              print(detail.invoiceNo);
                              print(productList);
                              print(detail.paymentStatus);
//final detail = filteredData[(currentPage - 1) * itemsPerPage + index];


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
            width:  right-100,
            decoration: const BoxDecoration(
                color: Color(0xFFF7F7F7),
                border: Border.symmetric(
                    horizontal: BorderSide(color: Colors.grey, width: 0.5))),
            child: DataTable(
                showCheckboxColumn: false,
                headingRowHeight: 40,
                columnSpacing: 35,
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
                                  style: TextStyles.subhead
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
// double padding = constraints.maxWidth * 0.065;
      double right = MediaQuery.of(context).size.width * 0.92;

      return Column(
        children: [
          Container(
            width: right - 100,

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
                                  style: TextStyles.subhead
                              ),
                              IconButton(
                                icon:
                                _sortOrder[columns.indexOf(column)] == 'asc'
                                    ?  SizedBox(
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
//Padding(
//  padding:  EdgeInsets.only(left: columnWidths[index]-50,),
//  child:
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
                                  style: TextStyles.body,
                                ),
                              ),
                            ),
                            DataCell(
                              Container(
                                width: columnWidths[2],
                                child: Text(
                                  detail.contactPerson!,
                                  style: TextStyles.body,
                                ),
                              ),
                            ),
                            DataCell(
                              Container(
                                width: columnWidths[1],
                                child: Text(
                                  detail.orderDate,
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
                            // DataCell(
                            //   Container(
                            //     width: columnWidths[4],
                            //     child: Text(
                            //       detail.paymentStatus.toString(),
                            //       style: TextStyles.body,
                            //     ),
                            //   ),
                            // ),

                          ],
                          onSelectChanged: (selected) {
                            if (selected != null && selected) {
                              print('what is this');
                              print(detail.invoiceNo);
                              print(productList);
                              print(detail.paymentStatus);
//final detail = filteredData[(currentPage - 1) * itemsPerPage + index];

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
          return a.orderId!.toLowerCase().compareTo(b.orderId!.toLowerCase());
        } else if (columnIndex == 1) {
          return a.contactPerson!.compareTo(b.contactPerson!);
        } else if (columnIndex == 2) {
          return a.orderDate.compareTo(b.orderDate);
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
          return b.orderId!.toLowerCase().compareTo(a.orderId!.toLowerCase());
        } else if (columnIndex == 1) {
          return b.contactPerson!.compareTo(a.contactPerson!);
        } else if (columnIndex == 2) {
          return b.orderDate.compareTo(a.orderDate);
        } else if (columnIndex == 3) {
          return b.total.compareTo(a.total);
        } else if (columnIndex == 4) {
          return b.deliveryStatus.compareTo(a.deliveryStatus);
        }  else {
          return 0;
        }
      });
    }
    setState(() {});
  }

  void _filterAndPaginateProducts() {
    filteredData = productList.where((product) {
      final matchesSearchText =
          product.orderId!.toLowerCase().contains(_searchText.toLowerCase()) || product.contactPerson!.toLowerCase().contains(_searchText.toLowerCase()) ;
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


 