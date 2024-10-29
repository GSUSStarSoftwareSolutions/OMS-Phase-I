import 'dart:async';
import 'dart:convert';
import 'dart:html';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:btb/admin/Api%20name.dart';
import 'package:btb/widgets/productclass.dart' as ord;
import 'package:btb/widgets/productclass.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'dart:html' as html;
import '../../Order Module/firstpage.dart';
import '../../Return Module/return first page.dart';
import '../../pdf/credit memo pdf.dart';
import '../../widgets/confirmdialog.dart';
import '../../widgets/custom loading.dart';
import '../../widgets/no datafound.dart';
import '../../widgets/pagination.dart';



class CusReturnpage extends StatefulWidget {
  const CusReturnpage({super.key});

  @override
  State<CusReturnpage> createState() => _CusReturnpageState();
}

class _CusReturnpageState extends State<CusReturnpage> {
  Timer? _searchDebounceTimer;
  String _searchText = '';
  String status = '';
  String selectDate = '';
  bool isExpanded = true;
  ord.Product? product;
  ReturnMaster? _isselected;
  List<String> _sortOrder = List.generate(6, (index) => 'asc');
  List<String> columns = [
    'Status',
    'Return ID',
    'Created Date',
    'Reference Number',
    'Credit Amount',
    ''
  ];
  List<double> columnWidths = [100, 120, 130, 160, 135, 120];
  List<bool> columnSortState = [true, true, true, true, true, true];
  final String _category = '';
  bool isOrdersSelected = false;
  DateTime? _selectedDate;
  late Future<void> _futureReturnMasters;
  late TextEditingController _dateController;
  final String _subCategory = '';
  int startIndex = 0;
  int itemCount = 0;
  final ScrollController _scrollController = ScrollController();
  List<Product> filteredProducts = [];
  int currentPage = 1;
  String? dropdownValue1 = 'Status';
  late Future<List<detail>> futureOrders;
  List<ReturnMaster> filteredData = [];
  bool _loading = false;
  List<ReturnMaster> productList = [];
  //String? role = window.sessionStorage["role"];

  String token = window.sessionStorage["token"] ?? " ";
  String? dropdownValue2 = 'Select Year';
  String userId = window.sessionStorage['userId'] ?? '';


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
      _buildMenuItem('Delivery', Icons.fire_truck_outlined, Colors.blue[900]!, '/Customer_Delivery_List'),
      _buildMenuItem('Payment', Icons.payment_outlined, Colors.blue[900]!, '/Customer_Payment_List'),
      _buildMenuItem('Return', Icons.backspace_sharp, Colors.blueAccent, '/Customer_Return_List'),
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
    // Check if currentPage and itemsPerPage are not null
    if (currentPage != null && itemsPerPage != null) {
      fetchReturnMasters(currentPage, itemsPerPage);
    } else {
      // Handle the case where values are null (e.g., show an error message)
      print('currentPage or itemsPerPage is null!');
    }

    //  futureOrders = fetchOrders() as Future<List<detail>>;
  }

  int itemsPerPage = 10;
  int totalItems = 0;
  int totalPages = 0;
  bool isLoading = false;



  Future<List<ReturnMaster>> _fetchAllReturnMaster(String orderId) async {
    String orderId1 = orderId;
    //  const String token = 'eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJkaGFuYXNla2FyIiwiUm9sZXMiOlt7ImF1dGhvcml0eSI6ImRldmVsb3BlciJ9XSwiZXhwIjoxNzI3MTg1NDYyLCJpYXQiOjE3MjcxNzgyNjJ9.gtSeEeobAvwxkJfChTs4W4NJHMIq6Sung7XEZTwnhLbAOgqHGROtmn6YSJS7g5smNXlWQmUNAMMh91cFAoe9OA';
    try {
      final response = await http.get(
        Uri.parse(
            '$apicall/return_master/get_all_returnmaster'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Return Master Data:');
        print(data);

        final returnMaster = data.firstWhere(
                (returnMaster) => returnMaster['returnId'] == orderId1,
            orElse: () => null);

        if (returnMaster != null) {
          // Convert the matched data to a ReturnMaster object
          final returnMasterObject =
          ReturnMaster.fromJson(returnMaster as Map<String, dynamic>);
          print(returnMasterObject);
          return [
            returnMasterObject
          ]; // Return a list containing the matched data
        } else {
          return []; // Return an empty list if no matched data is found
        }
        //orderId == response['returnId'] that specific data will be return
        //return data.map<ReturnMaster>((returnMaster) => ReturnMaster.fromJson(returnMaster as Map<String, dynamic>)).toList();
      } else {
        print('Failed to fetch return master data.');
        return [];
      }
    } catch (e) {
      print('Error fetching return master data: $e');
      return [];
    }
  }

  Future<void> downloadCreditMemoPdf(String orderId) async {
    // final String orderId2 = 'RTRN_04365';
    try {
      final returnMasters = await _fetchAllReturnMaster(orderId);

      print(returnMasters);

      final orderDetails = returnMasters.toList().cast<ReturnMaster>();
      //final orderDetails = returnMasters.map<ReturnMaster>((returnMaster) => ReturnMaster.fromJson(returnMaster as Map<String, dynamic>)).toList().cast<ReturnMaster>();
      if (orderDetails.isNotEmpty) {
        final Uint8List pdfBytes = await CreditMemoPdf(orderDetails);
        final blob = html.Blob([pdfBytes]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute('download', 'Credit_Memo.pdf')
          ..click();
        html.Url.revokeObjectUrl(url);
      } else {
        print('Failed to generate order details.');
      }
    } catch (e) {
      print('Error generating PDF: $e');
    }
  }

  Future<void> fetchReturnMasters(int page, int itemsPerPage) async {
    if (isLoading) return;
    if (!mounted) return;
    setState(() {
      isLoading = true;
    });
    try {
      final response = await http.get(
        Uri.parse(
          '$apicall/return_master/get_all_returnmaster?page=$page&limit=$itemsPerPage', // Changed limit to 10
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
        List<ReturnMaster> products = [];
        if (jsonData != null) {
          if (jsonData is List) {
            products =
                jsonData.map((item) => ReturnMaster.fromJson(item)).toList();
          } else if (jsonData is Map && jsonData.containsKey('body')) {
            products = (jsonData['body'] as List)
                .map((item) => ReturnMaster.fromJson(item))
                .toList();
            totalItems =
                jsonData['totalItems'] ?? 0; // Get the total number of items
          }
          print('Product Customer IDs:');
          products.forEach((product) => print(product.customerId));

          // Apply filtering for CusId
          List<ReturnMaster> matchedCustomers = products.where((customer) {
            return customer.customerId!.trim().toLowerCase() == userId.trim().toLowerCase();
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
          //  fetchPskioroducts(currentPage, itemsPerPage);
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
          //  fetchProducts(currentPage, itemsPerPage);
        });
      }
    }
  }

  @override
  void dispose() {
    _searchDebounceTimer
        ?.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //  String? role = Provider.of<UserRoleProvider>(context).role;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color(0xFFF0F4F8),
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: null,
          elevation: 2.0,

          backgroundColor: const Color(0xFFFFFFFF),
          title: Image.asset("images/Final-Ikyam-Logo.png"),
          // Set background color to white
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
                  decoration: const BoxDecoration(
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
                            'Return Order List',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
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
                                context.go('/Create_return_request');
                                //   context.go('/Return/Create_return');
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
                                  // fontWeight: FontWeight.w100,
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
                    //
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
                          Padding(
                            padding: const EdgeInsets.only(right: 30),
                            child: Container(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  PaginationControls(
                                    currentPage: currentPage,
                                    totalPages:
                                    filteredData.length > itemsPerPage
                                        ? totalPages
                                        : 1,
                                    //totalPages//totalPages,
                                    onPreviousPage: _goToPreviousPage,
                                    onNextPage: _goToNextPage,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
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
          constraints: const BoxConstraints(
            // maxWidth: constraints.maxWidth,
            // maxHeight: constraints.maxHeight,
          ),
          child: Container(
            padding: const EdgeInsets.only(
              left: 20,
              top: 10,
              right: 20, // changed from 800 to 20
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: constraints.maxWidth * 0.261,
                          maxHeight: 39,
                          // maxWidth: constraints.maxWidth * 0.27, // 80% of screen width
                        ),
                        child: Container(
                          height: 35,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(2),
                            border:
                            Border.all(color: const Color(0xFFA6A6A6), width: 1),
                          ),
                          child: TextFormField(
                            decoration: const InputDecoration(
                              hintText: 'Search by Return ID',
                              hintStyle:
                              TextStyle(fontSize: 13, color: Colors.grey),
                              //   icon: Container(),
                              contentPadding:
                              EdgeInsets.only(bottom: 20, left: 10),
                              border: InputBorder.none,
                              suffixIcon: Icon(
                                Icons.search_outlined,
                                color: Colors.indigo,
                              ),
                            ),
                            onChanged: _updateSearch,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                //const SizedBox(height: 8),
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
                                maxHeight: 30 // 40% of screen width
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
                                    EdgeInsets.only(left: 10, bottom: 20),
                                    border: InputBorder.none,
                                    // hintText: 'Status',
                                    hintStyle: TextStyle(color: Colors.grey),
                                    filled: true,
                                    fillColor: Colors.white,
                                  ),
                                  // change the size of the icon
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
                                    'In preparation',
                                    'Completed',
                                    'Cancelled'
                                  ].map<DropdownMenuItem<String>>(
                                          (String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(
                                            value,
                                            style: TextStyle(
                                                color: value == 'Status'
                                                    ? Colors.grey
                                                    : Colors.black,
                                                fontSize: 13),
                                          ),
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
                                )),
                          ),
                        ),
                      ],
                    ),
                    //SizedBox(width: constraints.maxWidth * 0.01),// 5% of screen width
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: constraints.maxWidth * 0.128,
                              maxHeight: 30, // 40% of screen width
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
                                  EdgeInsets.only(left: 10, bottom: 20),
                                  border: InputBorder.none,
                                  filled: true,
                                  fillColor: Colors.white,
                                  focusColor: Color(0xFFF0F4F8),
                                ), // default icon
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
      // Show loading indicator while data is being fetched
      return Padding(
        padding: EdgeInsets.only(bottom: Height * 0.100, left: width * 0.300),
        child: CustomLoadingIcon(), // Replace this with your custom GIF widget
      );
    }

    if (filteredData.isEmpty) {
      var _mediaQuery = MediaQuery.of(context).size.width;
      return Column(
        children: [
          Container(
            decoration: const BoxDecoration(
                color: Color(0xFFF7F7F7),
                border: Border.symmetric(
                    horizontal: BorderSide(color: Colors.grey, width: 0.5))),
            width: _mediaQuery * 0.78,
            child: DataTable(
              showCheckboxColumn: false,
              headingRowHeight: 40,
              columns: [
                DataColumn(
                    label: Text(
                      'Status',
                      style: TextStyle(
                          color: Colors.indigo[900],
                          fontSize: 13,
                          fontWeight: FontWeight.bold),
                    )),
                DataColumn(
                    label: Text(
                      'Return ID',
                      style: TextStyle(
                          color: Colors.indigo[900],
                          fontSize: 13,
                          fontWeight: FontWeight.bold),
                    )),
                DataColumn(
                    label: Text(
                      'Created Date',
                      style: TextStyle(
                          color: Colors.indigo[900],
                          fontSize: 13,
                          fontWeight: FontWeight.bold),
                    )),
                DataColumn(
                    label: Text(
                      'Reference Number',
                      style: TextStyle(
                          color: Colors.indigo[900],
                          fontSize: 13,
                          fontWeight: FontWeight.bold),
                    )),
                DataColumn(
                    label: Text(
                      'Credit Amount',
                      style: TextStyle(
                          color: Colors.indigo[900],
                          fontSize: 13,
                          fontWeight: FontWeight.bold),
                    )),
              ],
              rows: [],
            ),
          ),
          Padding(
            padding:
            const EdgeInsets.only(top: 150, left: 130, bottom: 350, right: 150),
            child: CustomDatafound(),
          ),
          const Divider(
            color: Colors.grey,
            height: 1,
          ),
        ],
      );
    }

    void _sortProducts(int columnIndex, String sortDirection) {
      if (sortDirection == 'asc') {
        filteredData.sort((a, b) {
          if (columnIndex == 0) {
            return a.status.compareTo(b.status);
          } else if (columnIndex == 1) {
            return a.returnId!.compareTo(b.returnId!);
          } else if (columnIndex == 2) {
            return a.returnDate!.compareTo(b.returnDate!);
          } else if (columnIndex == 3) {
            return a.reason!.compareTo(b.reason!);
          } else if (columnIndex == 4) {
            return a.returnCredit!.compareTo(b.returnCredit!);
          } else {
            return 0;
          }
        });
      } else {
        filteredData.sort((a, b) {
          if (columnIndex == 0) {
            return b.status.compareTo(a.status);
          } else if (columnIndex == 1) {
            return b.returnId!.compareTo(a.returnId!);
          } else if (columnIndex == 2) {
            return b.returnDate!.compareTo(a.returnDate!);
          } else if (columnIndex == 3) {
            return b.reason!.compareTo(a.reason!);
          } else if (columnIndex == 4) {
            return b.returnCredit!.compareTo(a.returnCredit!);
          } else {
            return 0;
          }
        });
      }
      setState(() {});
    }

    return LayoutBuilder(builder: (context, constraints) {
      var _mediaQuery = MediaQuery.of(context).size.width;
      return Column(
        children: [
          Container(
            decoration: const BoxDecoration(
                color: Color(0xFFF7F7F7),
                border: Border.symmetric(
                    horizontal: BorderSide(color: Colors.grey, width: 0.5))),
            width: _mediaQuery * 0.78,
            child: DataTable(
                showCheckboxColumn: false,
                headingRowHeight: 40,
                columns: columns.map((column) {
                  return DataColumn(
                    label: Stack(
                      children: [
                        Container(
                          width: columnWidths[columns.indexOf(column)],
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
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
                              if (columns.indexOf(column) < columns.length - 1)
                                IconButton(
                                  icon: _sortOrder[columns.indexOf(column)] ==
                                      'asc'
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
                                const Spacer(),
                              if (columns.indexOf(column) < columns.length - 1)
                                MouseRegion(
                                  cursor: SystemMouseCursors.resizeColumn,
                                  child: GestureDetector(
                                      onHorizontalDragUpdate: (details) {
                                        // Update column width dynamically as user drags
                                        setState(() {
                                          columnWidths[
                                          columns.indexOf(column)] +=
                                              details.delta.dx;
                                          columnWidths[columns
                                              .indexOf(column)] = columnWidths[
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
                      //   final isSelected = _isselected == ReturnMaster;
                      //  final product = filteredData[(currentPage - 1) * itemsPerPage + index];

                      final returnMaster = filteredData
                          .skip((currentPage - 1) * itemsPerPage)
                          .elementAt(index);
                      final isSelected = _isselected == returnMaster;
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
                              returnMaster.status,
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.deepOrange[200]
                                    : const Color(0xFFFFB315),
                              ),
                            )),
                            DataCell(Text(
                              returnMaster.returnId!,
                              style: const TextStyle(color: Colors.grey),
                            )),
                            DataCell(Text(
                              returnMaster.returnDate!.toString(),
                              style: const TextStyle(color: Colors.grey),
                            )),
                            DataCell(Text(
                              returnMaster.reason!,
                              style: const TextStyle(color: Colors.grey),
                            )),
                            DataCell(Text(
                              returnMaster.returnCredit.toString(),
                              style: const TextStyle(color: Colors.grey),
                            )),
                            DataCell(
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.picture_as_pdf_outlined,
                                      color: Colors.red,
                                    ),
                                    // replace with your desired icon
                                    onPressed: () {
                                      // add your onPressed event code here
                                      downloadCreditMemoPdf(returnMaster.returnId!);
                                    },
                                  ),
                                ],
                              ),
                            )
                          ],
                          onSelectChanged: (selected) {
                            if (selected != null && selected) {
                              //context.go('/return-view', extra: returnMaster);
                            }
                          });
                    })
            ),
          ),
          const Divider(
            color: Colors.grey,
            height: 1,
          ),
        ],
      );
    });
  }

  void _filterAndPaginateProducts() {
    filteredData = productList.where((product) {
      final matchesSearchText =
      product.returnId!.toLowerCase().contains(_searchText.toLowerCase());
      print('-----');
      print(product.returnDate);
      String orderYear = '';
      if (product.returnDate!.contains('/')) {
        final dateParts = product.returnDate!.split('/');
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
            product.status == status; // Include all products
      }
      if (status.isEmpty && selectDate.isNotEmpty) {
        return matchesSearchText &&
            orderYear == selectDate; // Include all products
      }

      if (status.isNotEmpty && selectDate.isEmpty) {
        return matchesSearchText &&
            product.status == status; // Include all products
      }
      return matchesSearchText &&
          (product.status == status && orderYear == selectDate);
      return false;
    }).toList();
    totalPages = (filteredData.length / itemsPerPage).ceil();
    setState(() {
      currentPage = 1;
    });
  }
}


