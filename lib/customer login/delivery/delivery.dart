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
import '../../Order Module/firstpage.dart';
import '../../widgets/custom loading.dart';
import '../../widgets/no datafound.dart';


class CusDeliveryList extends StatefulWidget {
  const CusDeliveryList({super.key});

  @override
  State<CusDeliveryList> createState() => _CusDeliveryListState();
}

class _CusDeliveryListState extends State<CusDeliveryList> {
  List<String> _sortOrder = List.generate(6, (index) => 'asc');
  List<String> columns = [
    'Delivery Id',
    'Invoice ID',
    'Created Date',
    'Total Amount',
    'Delivery Status'
  ];
  List<double> columnWidths = [110, 110, 130, 125, 135];
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
  String searchQuery = '';
  List<detail> filteredData = [];
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

  Map<String, bool> _isHovered = {
    'Orders': false,
    'Invoice': false,
    'Delivery': false,
    'Payment': false,
    'Return': false,
    'Credit Notes': false,
  };


  List<Widget> _buildMenuItems(BuildContext context) {
    return [
      _buildMenuItem('Orders', Icons.warehouse, Colors.blue[900]!, '/Customer_Order_List'),
      _buildMenuItem('Invoice', Icons.document_scanner_rounded, Colors.blue[900]!, '/Customer_Invoice_List'),
      _buildMenuItem('Delivery', Icons.fire_truck_outlined, Colors.blueAccent, '/Customer_Delivery_List'),
      _buildMenuItem('Payment', Icons.payment_outlined, Colors.blue[900]!, '/Customer_Payment_List'),
      _buildMenuItem('Return', Icons.backspace_sharp, Colors.blue[900]!, '/Customer_Return_List'),
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
  int itemCount = 0;
  String userId = window.sessionStorage['userId'] ?? '';



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
          print('user');
          print(userId);

          // Check the data structure
          print('Product Customer IDs:');
          products.forEach((product) => print(product.CusId));

          // Apply filtering for CusId
          List<detail> matchedCustomers = products.where((customer) {
            return customer.CusId!.trim().toLowerCase() == userId.trim().toLowerCase();
          }).toList();

          if (matchedCustomers.isNotEmpty) {
            setState(() {
              totalPages = (matchedCustomers.length / itemsPerPage).ceil();
              print('pages');
              print(totalPages);
              productList = matchedCustomers;
              print(productList);
              _filterAndPaginateProducts();
            });
          }
          else {
            print('No matching customers found for userId: $userId');
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
//_filterAndPaginateProducts();
    }
  }
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
          List<detail> matchedCustomers = products.where((customer) {  return customer.CusId == userId;}).toList();

          if (matchedCustomers.isNotEmpty) {
            setState(() {

              print('pages');
              itemCount = products.length;

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
      }
    }
  }

  @override
  void initState() {
    super.initState();
    fetchCount();
    _dateController = TextEditingController();
    fetchProducts(currentPage,itemsPerPage);

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
          double maxHeight = constraints.maxHeight;
          return Stack(
            children: [
              Align(
// Added Align widget for the left side menu
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
                            'Delivery List',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
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
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: SizedBox(
                      width: maxWidth * 0.79,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          buildSearchField(),
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
                              hintText: 'Search by Delivery ID',
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

  Widget buildDataTable() {
    if (isLoading) {
      _loading = true;
      var width = MediaQuery.of(context).size.width;
      var Height = MediaQuery.of(context).size.height;
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
              width: right * 0.78,
              decoration: const BoxDecoration(
                  color: Color(0xFFF7F7F7),
                  border: Border.symmetric(
                      horizontal: BorderSide(color: Colors.grey, width: 0.5))),
              child:
              DataTable(
                  showCheckboxColumn: false,
                  headingRowHeight: 40,
                  columns: columns.map((column) {
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
                                    detail.invoiceNo!,
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
                            // onSelectChanged: (selected) {
                            //   if (selected != null && selected) {
                            //     if (filteredData.length <= 9) {
                            //       print(detail.deliveryStatus);
                            //       context.go('/Delivery_View', extra: {
                            //         'invoice': detail.invoiceNo,
                            //         'deliveryStatus': detail.deliveryStatus,
                            //         'deliveryId': detail.deliveryId,
                            //       });
                            //     } else {
                            //       context.go('/Delivery_View', extra: {
                            //         'invoice': detail.invoiceNo,
                            //         'deliveryStatus': detail.deliveryStatus,
                            //         'deliveryId': detail.deliveryId,
                            //       });
                            //     }
                            //
                            //   }
                            // }
                            );
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
          return a.contactPerson!.compareTo(b.contactPerson!);
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
          return b.contactPerson!.compareTo(a.contactPerson!);
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
