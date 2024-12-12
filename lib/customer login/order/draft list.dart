import 'dart:async';
import 'dart:convert';
import 'dart:html';
import 'dart:math' as math;
import 'package:adaptive_scrollbar/adaptive_scrollbar.dart';
import 'package:btb/admin/Api%20name.dart';
import 'package:btb/widgets/confirmdialog.dart';
import 'package:btb/widgets/pagination.dart';
import 'package:btb/widgets/productclass.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import '../../Order Module/firstpage.dart';
import '../../widgets/custom loading.dart';
import '../../widgets/no datafound.dart';



class CusDraftPage extends StatefulWidget {
  const CusDraftPage({super.key});

  @override
  State<CusDraftPage> createState() => _CusDraftPageState();
}

class _CusDraftPageState extends State<CusDraftPage> {
  final List<String> _sortOrder = List.generate(6, (index) => 'asc');
  List<String> columns = [
    'Draft ID',
    'Draft Date',
    'Shipping Address',
    'Total Amount',
    '',
  ];
  bool _hasShownPopup = false;
  final ScrollController horizontalScroll = ScrollController();
  int itemCount = 0;
  String userId = window.sessionStorage['userId'] ?? '';
  List<double> columnWidths = [95, 125, 155, 140, 100];
  List<bool> columnSortState = [true, true, true, true, true, true];
  Timer? _searchDebounceTimer;
  String _searchText = '';
  bool isOrdersSelected = false;
  bool loading = false;
  Map<String, dynamic> paymentMap = {};
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
  final Map<String, bool> _isHovered = {
    'Orders': false,
    'Invoice': false,
    'Delivery': false,
    'Payment': false,
    'Return': false,
    // 'Credit Notes': false,
  };
  List<Widget> _buildMenuItems(BuildContext context) {
    return [
      _buildMenuItem('Home', Icons.home_outlined, Colors.blue[900]!, '/Cus_Home'),
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
          ),child: _buildMenuItem('Orders', Icons.warehouse, Colors.white, '/Customer_Order_List')),
      _buildMenuItem('Delivery', Icons.fire_truck_outlined, Colors.blue[900]!, '/Customer_Delivery_List'),
      _buildMenuItem('Invoice', Icons.document_scanner_outlined, Colors.blue[900]!, '/Customer_Invoice_List'),

      _buildMenuItem('Payment', Icons.payment_rounded, Colors.blue[900]!, '/Customer_Payment_List'),
      _buildMenuItem('Return', Icons.keyboard_return, Colors.blue[900]!, '/Customer_Return_List'),
      // _buildMenuItem('Credit Notes', Icons.credit_card_outlined, Colors.blue[900]!, '/Customer_Credit_List'),
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


  Future<void> deleteRowAPI(String typeId) async {
    try {
      String apiUri =

    '$apicall/email/delete_ordermaster_by_id/$typeId';

      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      };
      final http.Response response = await http.delete(
        Uri.parse(apiUri),
        headers: headers,
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

      }
      else{
        if (response.statusCode == 200) {
         Navigator.pop(context);
         fetchProducts(currentPage, itemsPerPage);
        } else {
          print('Failed to delete customer: ${response.statusCode}');
        }
      }

    } catch (e) {
      print('Error: $e');
    }
  }
  int itemsPerPage = 10;
  int totalItems = 0;
  int totalPages = 0;
  bool isLoading = false;

  Future<void> fetchProducts(int page, int itemsPerPage) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$apicall/order_master/get_all_draft_master?page=$page&limit=$itemsPerPage', // Changed limit to 10
        ),
        headers: {
          "Content-type": "application/json",
          "Authorization": 'Bearer $token',
        },
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

          final jsonData = jsonDecode(response.body);

          List<detail> products = [];
          if (jsonData != null) {
            if (jsonData is List) {
              products = jsonData.map((item) => detail.fromJson(item)).toList();
            }
            else if (jsonData is Map && jsonData.containsKey('body')) {
              products = (jsonData['body'] as List)
                  .map((item) => detail.fromJson(item))
                  .toList();
              totalItems =
                  jsonData['totalItems'] ?? 0;

            }
            List<detail> matchedCustomers = products.where((customer) {  return customer.CusId == userId;}).toList();

            if (matchedCustomers.isNotEmpty) {
              setState(() {
                totalPages = (products.length / itemsPerPage).ceil();

                itemCount = products.length;

                productList = products;

                _filterAndPaginateProducts();
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
      if (filteredData.length > itemsPerPage) {
        setState(() {
          currentPage--;
        });
      }
    }
  }

  void _goToNextPage() {

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
                        decoration: const BoxDecoration(
                          color: Colors.red, // Background color of the badge
                          shape: BoxShape.circle,
                        ),
                        child:  Text(
                          '$itemCount', // The text field value (like a badge count)
                          style: const TextStyle(
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
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        color: Colors.white,
                        height: 50,
                        child: const Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left: 20),
                              child: Text(
                                'Draft List',
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
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
                              hintText: 'Search by Draft ID',
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

              ],
            ),
          ),
        );
      },
    );
  }
  Widget buildDataTable2() {
    if (isLoading) {
      loading = true;
      var width = MediaQuery.of(context).size.width;
      var height = MediaQuery.of(context).size.height;
// Show loading indicator while data is being fetched
      return Padding(
        padding: EdgeInsets.only(
            top: height * 0.100, bottom: height * 0.100, left: width * 0.300),
        child: CustomLoadingIcon(), // Replace this with your custom GIF widget
      );
    }

    if (filteredData.isEmpty) {
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
                rows: const []),
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
                              if (columns.indexOf(column) < columns.length - 1)
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
                              if (columns.indexOf(column) < columns.length - 1)
                                const

                                Spacer(),
                              if (columns.indexOf(column) < columns.length - 1)
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
                                  detail.draftId.toString(),
                                  style: const TextStyle(
                                    color: Color(0xFFA6A6A6),
                                  ),
                                ),
                              ),
                            ),
                            DataCell(
                              SizedBox(
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
                              SizedBox(
                                width: columnWidths[2],
                                child: Text(
                                  detail.comments!,
                                  style: const TextStyle(
                                    color: Color(0xFFA6A6A6),
                                  ),
                                ),
                              ),
                            ),
                            DataCell(
                              SizedBox(
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
                              IconButton(
                                icon: const Icon(Icons.delete,
                                    color: Colors.pinkAccent),
                                onPressed: () {
                                  showDialog(
                                    barrierDismissible: false,
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(

                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius.circular(
                                              15.0),
                                        ),
                                        contentPadding: EdgeInsets.zero,
                                        content: Column(
                                          mainAxisSize:
                                          MainAxisSize.min,
                                          children: [
                                            Padding(
                                              padding:
                                              const EdgeInsets.all(
                                                  16.0),
                                              child: Column(
                                                children: [
                                                  const Icon(
                                                      Icons.warning,
                                                      color:
                                                      Colors.orange,
                                                      size: 50),
                                                  const SizedBox(
                                                      height: 16),
                                                  const Text(
                                                    'Are You Sure',
                                                    style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                      FontWeight
                                                          .bold,
                                                      color:
                                                      Colors.black,
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                      height: 20),
                                                  Row(
                                                    mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                    children: [
                                                      ElevatedButton(
                                                        onPressed: () {
                                                          deleteRowAPI(
                                                              detail.orderId!);
                                                        },
                                                        style: ElevatedButton
                                                            .styleFrom(
                                                          backgroundColor:
                                                          Colors
                                                              .green,
                                                          side: const BorderSide(
                                                              color: Colors
                                                                  .green),
                                                          shape:
                                                          RoundedRectangleBorder(
                                                            borderRadius:
                                                            BorderRadius.circular(
                                                                10.0),
                                                          ),
                                                        ),
                                                        child:
                                                        const Text(
                                                          'Yes',
                                                          style: TextStyle(
                                                              color: Colors
                                                                  .white),
                                                        ),
                                                      ),
                                                      ElevatedButton(
                                                        onPressed: () {
                                                          Navigator.of(
                                                              context)
                                                              .pop();
                                                        },
                                                        style: ElevatedButton
                                                            .styleFrom(
                                                          backgroundColor:
                                                          Colors
                                                              .red,
                                                          side: const BorderSide(
                                                              color: Colors
                                                                  .red),
                                                          shape:
                                                          RoundedRectangleBorder(
                                                            borderRadius:
                                                            BorderRadius.circular(
                                                                10.0),
                                                          ),
                                                        ),
                                                        child:
                                                        const Text(
                                                          'No',
                                                          style: TextStyle(
                                                              color: Colors
                                                                  .white),
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
                            ),

                          ],
                          onSelectChanged: (selected) {
                            if (selected != null && selected) {

                              if (filteredData.length <= 9) {
                                paymentMap = {
                                  'paymentId': detail.paymentDate,
                                  'paymentmode': detail.paymentMode,
                                  'paymentStatus': detail.paymentStatus,
                                  'paymentdate': detail.paymentDate,
                                  'paidamount': detail.paidAmount,
                                };
                                context.go('/Draft_Placed_List1', extra: {
                                  'product': detail,
                                  'item': [], // pass an empty list of maps
                                  'body': {},
                                  'status': detail.deliveryStatus,
                                  'InvNo': detail.invoiceNo,
                                  'paymentStatus': paymentMap,
                                  'itemsList': [], // pass an empty list of maps
                                  'orderDetails': productList
                                      .map((detail) => OrderDetail(
                                    orderId: detail.draftId,
                                    orderDate: detail.orderDate, items: [],
                                    deliveryStatus: detail.deliveryStatus,
// Add other fields as needed
                                  ))
                                      .toList(),
                                });

                              } else {
                                paymentMap = {
                                  'paymentId': detail.paymentDate,
                                  'paymentmode': detail.paymentMode,
                                  'paymentStatus': detail.paymentStatus,
                                  'paymentdate': detail.paymentDate,
                                  'paidamount': detail.paidAmount,
                                };
                                context.go('/Draft_Placed_List1', extra: {
                                  'product': detail,
                                  'item': [], // pass an empty list of maps
                                  'status': detail.deliveryStatus,
                                  'InvNo': detail.invoiceNo,
                                  'paymentStatus': paymentMap,
                                  'body': {},
                                  'itemsList': [], // pass an empty list of maps
                                  'orderDetails': filteredData
                                      .map((detail) => OrderDetail(
                                    orderId: detail.draftId,
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
      loading = true;
      var width = MediaQuery.of(context).size.width;
      var height = MediaQuery.of(context).size.height;
// Show loading indicator while data is being fetched
      return Padding(
        padding: EdgeInsets.only(
            top: height * 0.100, bottom: height * 0.100, left: width * 0.300),
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
                rows: const []),
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
                              if (columns.indexOf(column) < columns.length - 1)
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
                              if (columns.indexOf(column) < columns.length - 1)
                                const

                                Spacer(),
                              if (columns.indexOf(column) < columns.length - 1)
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
                                  detail.draftId.toString(),
                                  style: const TextStyle(
                                    color: Color(0xFFA6A6A6),
                                  ),
                                ),
                              ),
                            ),
                            DataCell(
                              SizedBox(
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
                              SizedBox(
                                width: columnWidths[2],
                                child: Text(
                                  detail.comments!,
                                  style: const TextStyle(
                                    color: Color(0xFFA6A6A6),
                                  ),
                                ),
                              ),
                            ),
                            DataCell(
                              SizedBox(
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
                              IconButton(
                                icon: const Icon(Icons.delete,
                                    color: Colors.pinkAccent),
                                onPressed: () {
                                  showDialog(
                                    barrierDismissible: false,
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(

                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius.circular(
                                              15.0),
                                        ),
                                        contentPadding: EdgeInsets.zero,
                                        content: Column(
                                          mainAxisSize:
                                          MainAxisSize.min,
                                          children: [
                                            Padding(
                                              padding:
                                              const EdgeInsets.all(
                                                  16.0),
                                              child: Column(
                                                children: [
                                                  const Icon(
                                                      Icons.warning,
                                                      color:
                                                      Colors.orange,
                                                      size: 50),
                                                  const SizedBox(
                                                      height: 16),
                                                  const Text(
                                                    'Are You Sure',
                                                    style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                      FontWeight
                                                          .bold,
                                                      color:
                                                      Colors.black,
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                      height: 20),
                                                  Row(
                                                    mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                    children: [
                                                      ElevatedButton(
                                                        onPressed: () {

                                                          deleteRowAPI(
                                                              detail.orderId!);


                                                        },
                                                        style: ElevatedButton
                                                            .styleFrom(
                                                          backgroundColor:
                                                          Colors
                                                              .green,
                                                          side: const BorderSide(
                                                              color: Colors
                                                                  .green),
                                                          shape:
                                                          RoundedRectangleBorder(
                                                            borderRadius:
                                                            BorderRadius.circular(
                                                                10.0),
                                                          ),
                                                        ),
                                                        child:
                                                        const Text(
                                                          'Yes',
                                                          style: TextStyle(
                                                              color: Colors
                                                                  .white),
                                                        ),
                                                      ),
                                                      ElevatedButton(
                                                        onPressed: () {
                                                          Navigator.of(
                                                              context)
                                                              .pop();
                                                        },
                                                        style: ElevatedButton
                                                            .styleFrom(
                                                          backgroundColor:
                                                          Colors
                                                              .red,
                                                          side: const BorderSide(
                                                              color: Colors
                                                                  .red),
                                                          shape:
                                                          RoundedRectangleBorder(
                                                            borderRadius:
                                                            BorderRadius.circular(
                                                                10.0),
                                                          ),
                                                        ),
                                                        child:
                                                        const Text(
                                                          'No',
                                                          style: TextStyle(
                                                              color: Colors
                                                                  .white),
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
                            ),

                          ],
                          onSelectChanged: (selected) {
                            if (selected != null && selected) {

                              if (filteredData.length <= 9) {
                                paymentMap = {
                                  'paymentId': detail.paymentDate,
                                  'paymentmode': detail.paymentMode,
                                  'paymentStatus': detail.paymentStatus,
                                  'paymentdate': detail.paymentDate,
                                  'paidamount': detail.paidAmount,
                                };
                                context.go('/Draft_Placed_List1', extra: {
                                  'product': detail,
                                  'item': [], // pass an empty list of maps
                                  'body': {},
                                  'status': detail.deliveryStatus,
                                  'InvNo': detail.invoiceNo,
                                  'paymentStatus': paymentMap,
                                  'itemsList': [], // pass an empty list of maps
                                  'orderDetails': productList
                                      .map((detail) => OrderDetail(
                                    orderId: detail.draftId,
                                    orderDate: detail.orderDate, items: [],
                                    deliveryStatus: detail.deliveryStatus,
// Add other fields as needed
                                  ))
                                      .toList(),
                                });

                              } else {
                                paymentMap = {
                                  'paymentId': detail.paymentDate,
                                  'paymentmode': detail.paymentMode,
                                  'paymentStatus': detail.paymentStatus,
                                  'paymentdate': detail.paymentDate,
                                  'paidamount': detail.paidAmount,
                                };
                                context.go('/Draft_Placed_List1', extra: {
                                  'product': detail,
                                  'item': [], // pass an empty list of maps
                                  'status': detail.deliveryStatus,
                                  'InvNo': detail.invoiceNo,
                                  'paymentStatus': paymentMap,
                                  'body': {},
                                  'itemsList': [], // pass an empty list of maps
                                  'orderDetails': filteredData
                                      .map((detail) => OrderDetail(
                                    orderId: detail.draftId,
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
          return a.draftId!.compareTo(b.draftId!);
        } else if (columnIndex == 1) {
          return a.orderDate.compareTo(b.orderDate);
        } else if (columnIndex == 2) {
          return a.deliveryAddress!.compareTo(b.deliveryAddress!);
        }  else if (columnIndex == 3) {
          return a.total.compareTo(b.total);
        }else {
          return 0;
        }
      });
    } else {
      filteredData.sort((a, b) {
        if (columnIndex == 0) {
          return b.draftId!.compareTo(a.draftId!);
        } else if (columnIndex == 1) {
          return b.orderDate.compareTo(a.orderDate);
        } else if (columnIndex == 2) {
          return b.deliveryAddress!.compareTo(a.deliveryAddress!);
        }else if (columnIndex == 3) {
          return b.total.compareTo(a.total);
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
      product.draftId!.toLowerCase().contains(_searchText.toLowerCase());
      return matchesSearchText;
//  return false;
    }).toList();
    totalPages = (filteredData.length / itemsPerPage).ceil();
//totalPages = (productList.length / itemsPerPage).ceil();
    setState(() {
      currentPage = 1;
    });
  }
}


