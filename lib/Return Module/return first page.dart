import 'dart:async';
import 'dart:convert';
import 'dart:html';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:adaptive_scrollbar/adaptive_scrollbar.dart';
import 'package:btb/admin/Api%20name.dart';
import 'package:btb/widgets/productclass.dart' as ord;
import 'package:btb/widgets/productclass.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'dart:html' as html;
import '../main.dart';
import '../pdf/credit memo pdf.dart';
import '../widgets/confirmdialog.dart';
import '../widgets/custom loading.dart';
import '../widgets/no datafound.dart';
import '../widgets/pagination.dart';
import '../Order Module/firstpage.dart';

void main() {
  runApp(const Returnpage());
}

class Returnpage extends StatefulWidget {
  const Returnpage({super.key});

  @override
  State<Returnpage> createState() => _ReturnpageState();
}

class _ReturnpageState extends State<Returnpage> with SingleTickerProviderStateMixin {
  Timer? _searchDebounceTimer;
  String _searchText = '';
  String status = '';
  String selectDate = '';
  bool isExpanded = true;
  ord.Product? product;
  ReturnMaster? _isselected;
  bool _isHovered1 = false;
  List<String> _sortOrder = List.generate(5, (index) => 'asc');
  List<String> columns = [
    'Return ID',
    'Created Date',
    'Reference Number',
    'Credit Amount',
    'Initiated By',
    ''
  ];
  List<double> columnWidths = [120, 130, 160, 135, 135,90];
  List<bool> columnSortState = [true, true, true, true, true, true, true];
  final String _category = '';
  bool isOrdersSelected = false;
  final ScrollController horizontalScroll = ScrollController();
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

  DateTime? _selectedDate;
  late AnimationController _controller;
  late Animation<double> _shakeAnimation;
  late Future<void> _futureReturnMasters;
  late TextEditingController _dateController;
  final String _subCategory = '';
  int startIndex = 0;
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


  List<Widget> _buildMenuItems(BuildContext context) {
    return [
      _buildMenuItem('Home', Icons.home_outlined, Colors.blue[900]!, '/Home'),
      _buildMenuItem('Customer', Icons.account_circle_outlined, Colors.blue[900]!, '/Customer'),
      _buildMenuItem('Products', Icons.image_outlined, Colors.blue[900]!, '/Product_List'),
      _buildMenuItem('Orders', Icons.warehouse_outlined, Colors.blue[900]!, '/Order_List'),
      _buildMenuItem('Delivery', Icons.fire_truck_outlined, Colors.blue[900]!, '/Delivery_List'),
      _buildMenuItem('Invoice', Icons.document_scanner_outlined, Colors.blue[900]!, '/Invoice'),

      _buildMenuItem('Payment', Icons.payment_rounded, Colors.blue[900]!, '/Payment_List'),
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
          ),child: _buildMenuItem('Return', Icons.keyboard_return, Colors.blueAccent, '/Return_List')),
      _buildMenuItem('Reports', Icons.insert_chart_outlined, Colors.blue[900]!, '/Report_List'),
    ];
  }

  Widget _buildMenuItem(String title, IconData icon, Color iconColor, String route) {
    iconColor = _isHovered[title] == true ? Colors.blue : Colors.black87;
    title == 'Return'? _isHovered[title] = false :  _isHovered[title] = false;
    title == 'Return'? iconColor = Colors.white : Colors.black;
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

  @override
  void initState() {
    super.initState();
    _dateController = TextEditingController();
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

  Future<List<dynamic>> _fetchAllProductMaster() async {
    //final String token = 'eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJkaGFuYXNla2FyIiwiUm9sZXMiOlt7ImF1dGhvcml0eSI6ImRldmVsb3BlciJ9XSwiZXhwIjoxNzIzMTE0OTQ0LCJpYXQiOjE3MjMxMDc3NDR9.1UxLslHM3GivBHoBr8pS02OxD6dC5IRG4ryxiUdgzIJmFjSCwftf6Kme4rPLb-ZOjzOoAaxueSzKxiLmjnmSFg';
    try {
      final response = await http.get(
        Uri.parse(
            '$apicall/productmaster/get_all_productmaster'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Product Master Data:');
        print(data);
        // print('discount');
        // print(data['discount']);
        return data;
      } else {
        print('Failed to fetch product master data.');
        return [];
      }
    } catch (e) {
      print('Error fetching product master data: $e');
      return [];
    }
  }

  Future<OrderDetail?> _fetchOrderDetails(String orderId) async {
    //String token = 'eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJkaGFuYXNla2FyIiwiUm9sZXMiOlt7ImF1dGhvcml0eSI6ImRldmVsb3BlciJ9XSwiZXhwIjoxNzI1NjA2NjA5LCJpYXQiOjE3MjU1OTk0MDl9.a0XS5AykjKk62PBbfGessANRveTtU5wawjPRnHj73Zi1t-Xh3b2-2G_CksANLOaANHiy-4AlsCYwOZFY8GmExA';
    try {
      final url =
          '$apicall/order_master/search_by_orderid/$orderId';
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final responseBody = response.body;
        print('onTap');
        print(responseBody);
        if (responseBody != null) {
          final jsonData = jsonDecode(responseBody);
          if (jsonData is List<dynamic>) {
            final jsonObject = jsonData.first;
            return OrderDetail.fromJson(jsonObject);
          } else {
            print('Failed to load order details');
          }
        } else {
          print('Failed to load order details');
        }
      } else {
        print('Failed to load order details');
      }
    } catch (e) {
      print('Error: $e');
    }
    return null;
  }

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
          //  fetchPskioroducts(currentPage, itemsPerPage);
        });
      }
      //fetchProducts(page: currentPage);
      // _filterAndPaginateProducts();
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
        // fetchProducts(page: currentPage);
        //  _filterAndPaginateProducts();
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
                bottom:0,
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
                                            context.go('/Create_return');
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
                                    );
                                  }

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
                    if(constraints.maxWidth >= 1250)...{
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
  Widget buildDataTable2() {
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
            width: 1100,
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
            return a.returnId!.compareTo(b.returnId!);
          } else if (columnIndex == 1) {
            return a.returnDate!.compareTo(b.returnDate!);
          } else if (columnIndex == 2) {
            return a.reason!.compareTo(b.reason!);
          } else if (columnIndex == 3) {
            return a.returnCredit!.compareTo(b.returnCredit!);
          }
          else if (columnIndex == 4) {
            return a.initiatedBy!.compareTo(b.initiatedBy!);
          }else {
            return 0;
          }
        });
      } else {
        filteredData.sort((a, b) {
          if (columnIndex == 0) {
            return b.returnId!.compareTo(a.returnId!);
          } else if (columnIndex == 1) {
            return b.returnDate!.compareTo(a.returnDate!);
          } else if (columnIndex == 2) {
            return b.reason!.compareTo(a.reason!);
          } else if (columnIndex == 3) {
            return b.returnCredit!.compareTo(a.returnCredit!);
          }
          else if (columnIndex == 4) {
            return b.initiatedBy!.compareTo(a.initiatedBy!);
          }else {
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
            width: 1100,
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
                              //SizedBox(width: 50,),
                              //Padding(
                              //  padding:  EdgeInsets.only(left: columnWidths[index]-50,),
                              //  child:
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
                // [
                //
                //   DataColumn(label: Container(
                //       child: Text('Status',style:TextStyle(
                //           color: Colors.indigo[900],
                //           fontSize: 13,
                //           fontWeight: FontWeight.bold
                //       ),))),
                //   DataColumn(label: Container(child: Text('Return ID',style:TextStyle(
                //       color: Colors.indigo[900],
                //       fontSize: 13,
                //       fontWeight: FontWeight.bold
                //   ),))),
                //   DataColumn(label: Container(child:
                //   Text('Created Date',
                //     style:TextStyle(
                //         color: Colors.indigo[900],
                //         fontSize: 13,
                //         fontWeight: FontWeight.bold
                //     ),))),
                //   DataColumn(label: Container(child: Text(
                //     'Reference Number',style:TextStyle(
                //       color: Colors.indigo[900],
                //       fontSize: 13,
                //       fontWeight: FontWeight.bold
                //   ),))),
                //   DataColumn(label: Container(child: Text(
                //     'Credit Amount',style:TextStyle(
                //       color: Colors.indigo[900],
                //       fontSize: 13,
                //       fontWeight: FontWeight.bold
                //   ),))),
                //   DataColumn(label: Container(child: Text(
                //     '',style:TextStyle(
                //       color: Colors.indigo[900],
                //       fontSize: 13,
                //       fontWeight: FontWeight.bold
                //   ),))),
                // ],
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
                            DataCell(Text(
                              returnMaster.initiatedBy.toString(),
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
                              context.go('/return-view', extra: returnMaster);
                            }
                          });
                    })

              // filteredData
              //     .skip((currentPage - 1) * itemsPerPage)
              //     .take(itemsPerPage)
              //     .map((returnMaster) {
              //    //var isSelected = false;
              //    final isSelected = _isselected == returnMaster;
              //   //final isSelected = _selectedProduct == product;
              //   return DataRow(
              //       color: MaterialStateColor.resolveWith(
              //               (states) => isSelected ? Colors.lightBlue.shade100 : Colors.white),
              //       cells: [
              //         DataCell(
              //             MouseRegion(
              //               cursor: SystemMouseCursors.click,
              //               onEnter: (event) {
              //                 setState(() {
              //                   _isselected = returnMaster;
              //                 });
              //               },
              //               onExit: (event) {
              //                 _isselected = null;
              //               },
              //               child: GestureDetector(
              //
              //                 onTap:() {
              //                   context.go('/return-view', extra: returnMaster);
              //                   // Navigator.push(
              //                   //   context,
              //                   //   MaterialPageRoute(
              //                   //       builder: (context) => ReturnView(returnMaster: returnMaster,)
              //                   //   )
              //                   //   , // pass the selected product here
              //                   // );
              //
              //                 },
              //                 child: Container(
              //
              //                   // padding: EdgeInsets.only(left: 40),
              //                     child: Text(returnMaster.status, style: TextStyle(fontSize: 15,color:isSelected ? Colors.deepOrange[200] : const Color(0xFFFFB315) ,),)),
              //               ),
              //             )
              //         ),
              //         DataCell(
              //   MouseRegion(
              //   cursor: SystemMouseCursors.click,
              //   onEnter: (event) {
              //   setState(() {
              //   _isselected = returnMaster;
              //   });
              //   },
              //   onExit: (event) {
              //   _isselected = null;
              //   },
              //   child: GestureDetector(
              //
              //   onTap:() {
              //   context.go('/return-view', extra: returnMaster);
              //   // Navigator.push(
              //   //   context,
              //   //   MaterialPageRoute(
              //   //       builder: (context) => ReturnView(returnMaster: returnMaster,)
              //   //   )
              //   //   , // pass the selected product here
              //   // );
              //
              //   },
              //   child: Container( child: Text(returnMaster.returnId!)),
              //   ),
              //   )
              //   ),
              //         DataCell(
              //   MouseRegion(
              //   cursor: SystemMouseCursors.click,
              //   onEnter: (event) {
              //   setState(() {
              //   _isselected = returnMaster;
              //   });
              //   },
              //   onExit: (event) {
              //   _isselected = null;
              //   },
              //   child: GestureDetector(
              //
              //   onTap:() {
              //   context.go('/return-view', extra: returnMaster);
              //   // Navigator.push(
              //   //   context,
              //   //   MaterialPageRoute(
              //   //       builder: (context) => ReturnView(returnMaster: returnMaster,)
              //   //   )
              //   //   , // pass the selected product here
              //   // );
              //
              //   },
              //   child:  Container( child: Padding(
              //     padding: const EdgeInsets.only(left: 10),
              //     child: Text(returnMaster.returnDate!.toString()),
              //   )),
              //   ),
              //   )
              //            ),
              //         DataCell(
              //   MouseRegion(
              //   cursor: SystemMouseCursors.click,
              //   onEnter: (event) {
              //   setState(() {
              //   _isselected = returnMaster;
              //   });
              //   },
              //   onExit: (event) {
              //   _isselected = null;
              //   },
              //   child: GestureDetector(
              //
              //   onTap:() {
              //   context.go('/return-view', extra: returnMaster);
              //   // Navigator.push(
              //   //   context,
              //   //   MaterialPageRoute(
              //   //       builder: (context) => ReturnView(returnMaster: returnMaster,)
              //   //   )
              //   //   , // pass the selected product here
              //   // );
              //
              //   },
              //   child:   Container(child: Padding(
              //     padding: const EdgeInsets.only(left:40),
              //     child: Text(returnMaster.reason!),
              //   ))
              //   ),
              //   )
              //           ),
              //         DataCell(
              //   MouseRegion(
              //   cursor: SystemMouseCursors.click,
              //   onEnter: (event) {
              //   setState(() {
              //   _isselected = returnMaster;
              //   });
              //   },
              //   onExit: (event) {
              //   _isselected = null;
              //   },
              //   child: GestureDetector(
              //
              //   onTap:() {
              //   context.go('/return-view', extra: returnMaster);
              //   // Navigator.push(
              //   //   context,
              //   //   MaterialPageRoute(
              //   //       builder: (context) => ReturnView(returnMaster: returnMaster,)
              //   //   )
              //   //   , // pass the selected product here
              //   // );
              //
              //   },
              //   child:    Container(child: Padding(
              //     padding: const EdgeInsets.only(left: 40),
              //     child: Text(returnMaster.totalCredit.toString()),
              //   ))
              //   ),
              //   )
              //            ),
              //         // DataCell(Container(child: Padding(
              //         //   padding: const EdgeInsets.only(left: 10),
              //         //   child: Text(returnMaster.notes!),
              //         // ))),
              //
              //       ]);
              // }).toList(),
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
            width: _mediaQuery - 200,
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
            return a.returnId!.compareTo(b.returnId!);
          } else if (columnIndex == 1) {
            return a.returnDate!.compareTo(b.returnDate!);
          } else if (columnIndex == 2) {
            return a.reason!.compareTo(b.reason!);
          } else if (columnIndex == 3) {
            return a.returnCredit!.compareTo(b.returnCredit!);
          }
          else if (columnIndex == 4) {
            return a.initiatedBy!.compareTo(b.initiatedBy!);
          }else {
            return 0;
          }
        });
      } else {
        filteredData.sort((a, b) {
          if (columnIndex == 0) {
            return b.returnId!.compareTo(a.returnId!);
          } else if (columnIndex == 1) {
            return b.returnDate!.compareTo(a.returnDate!);
          } else if (columnIndex == 2) {
            return b.reason!.compareTo(a.reason!);
          } else if (columnIndex == 3) {
            return b.returnCredit!.compareTo(a.returnCredit!);
          }
          else if (columnIndex == 4) {
            return b.initiatedBy!.compareTo(a.initiatedBy!);
          }else {
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
            width: _mediaQuery - 200,
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
                              //SizedBox(width: 50,),
                              //Padding(
                              //  padding:  EdgeInsets.only(left: columnWidths[index]-50,),
                              //  child:
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
                // [
                //
                //   DataColumn(label: Container(
                //       child: Text('Status',style:TextStyle(
                //           color: Colors.indigo[900],
                //           fontSize: 13,
                //           fontWeight: FontWeight.bold
                //       ),))),
                //   DataColumn(label: Container(child: Text('Return ID',style:TextStyle(
                //       color: Colors.indigo[900],
                //       fontSize: 13,
                //       fontWeight: FontWeight.bold
                //   ),))),
                //   DataColumn(label: Container(child:
                //   Text('Created Date',
                //     style:TextStyle(
                //         color: Colors.indigo[900],
                //         fontSize: 13,
                //         fontWeight: FontWeight.bold
                //     ),))),
                //   DataColumn(label: Container(child: Text(
                //     'Reference Number',style:TextStyle(
                //       color: Colors.indigo[900],
                //       fontSize: 13,
                //       fontWeight: FontWeight.bold
                //   ),))),
                //   DataColumn(label: Container(child: Text(
                //     'Credit Amount',style:TextStyle(
                //       color: Colors.indigo[900],
                //       fontSize: 13,
                //       fontWeight: FontWeight.bold
                //   ),))),
                //   DataColumn(label: Container(child: Text(
                //     '',style:TextStyle(
                //       color: Colors.indigo[900],
                //       fontSize: 13,
                //       fontWeight: FontWeight.bold
                //   ),))),
                // ],
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
                        DataCell(Text(
                          returnMaster.initiatedBy.toString(),
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
                          context.go('/return-view', extra: returnMaster);
                        }
                      });
                })

                // filteredData
                //     .skip((currentPage - 1) * itemsPerPage)
                //     .take(itemsPerPage)
                //     .map((returnMaster) {
                //    //var isSelected = false;
                //    final isSelected = _isselected == returnMaster;
                //   //final isSelected = _selectedProduct == product;
                //   return DataRow(
                //       color: MaterialStateColor.resolveWith(
                //               (states) => isSelected ? Colors.lightBlue.shade100 : Colors.white),
                //       cells: [
                //         DataCell(
                //             MouseRegion(
                //               cursor: SystemMouseCursors.click,
                //               onEnter: (event) {
                //                 setState(() {
                //                   _isselected = returnMaster;
                //                 });
                //               },
                //               onExit: (event) {
                //                 _isselected = null;
                //               },
                //               child: GestureDetector(
                //
                //                 onTap:() {
                //                   context.go('/return-view', extra: returnMaster);
                //                   // Navigator.push(
                //                   //   context,
                //                   //   MaterialPageRoute(
                //                   //       builder: (context) => ReturnView(returnMaster: returnMaster,)
                //                   //   )
                //                   //   , // pass the selected product here
                //                   // );
                //
                //                 },
                //                 child: Container(
                //
                //                   // padding: EdgeInsets.only(left: 40),
                //                     child: Text(returnMaster.status, style: TextStyle(fontSize: 15,color:isSelected ? Colors.deepOrange[200] : const Color(0xFFFFB315) ,),)),
                //               ),
                //             )
                //         ),
                //         DataCell(
                //   MouseRegion(
                //   cursor: SystemMouseCursors.click,
                //   onEnter: (event) {
                //   setState(() {
                //   _isselected = returnMaster;
                //   });
                //   },
                //   onExit: (event) {
                //   _isselected = null;
                //   },
                //   child: GestureDetector(
                //
                //   onTap:() {
                //   context.go('/return-view', extra: returnMaster);
                //   // Navigator.push(
                //   //   context,
                //   //   MaterialPageRoute(
                //   //       builder: (context) => ReturnView(returnMaster: returnMaster,)
                //   //   )
                //   //   , // pass the selected product here
                //   // );
                //
                //   },
                //   child: Container( child: Text(returnMaster.returnId!)),
                //   ),
                //   )
                //   ),
                //         DataCell(
                //   MouseRegion(
                //   cursor: SystemMouseCursors.click,
                //   onEnter: (event) {
                //   setState(() {
                //   _isselected = returnMaster;
                //   });
                //   },
                //   onExit: (event) {
                //   _isselected = null;
                //   },
                //   child: GestureDetector(
                //
                //   onTap:() {
                //   context.go('/return-view', extra: returnMaster);
                //   // Navigator.push(
                //   //   context,
                //   //   MaterialPageRoute(
                //   //       builder: (context) => ReturnView(returnMaster: returnMaster,)
                //   //   )
                //   //   , // pass the selected product here
                //   // );
                //
                //   },
                //   child:  Container( child: Padding(
                //     padding: const EdgeInsets.only(left: 10),
                //     child: Text(returnMaster.returnDate!.toString()),
                //   )),
                //   ),
                //   )
                //            ),
                //         DataCell(
                //   MouseRegion(
                //   cursor: SystemMouseCursors.click,
                //   onEnter: (event) {
                //   setState(() {
                //   _isselected = returnMaster;
                //   });
                //   },
                //   onExit: (event) {
                //   _isselected = null;
                //   },
                //   child: GestureDetector(
                //
                //   onTap:() {
                //   context.go('/return-view', extra: returnMaster);
                //   // Navigator.push(
                //   //   context,
                //   //   MaterialPageRoute(
                //   //       builder: (context) => ReturnView(returnMaster: returnMaster,)
                //   //   )
                //   //   , // pass the selected product here
                //   // );
                //
                //   },
                //   child:   Container(child: Padding(
                //     padding: const EdgeInsets.only(left:40),
                //     child: Text(returnMaster.reason!),
                //   ))
                //   ),
                //   )
                //           ),
                //         DataCell(
                //   MouseRegion(
                //   cursor: SystemMouseCursors.click,
                //   onEnter: (event) {
                //   setState(() {
                //   _isselected = returnMaster;
                //   });
                //   },
                //   onExit: (event) {
                //   _isselected = null;
                //   },
                //   child: GestureDetector(
                //
                //   onTap:() {
                //   context.go('/return-view', extra: returnMaster);
                //   // Navigator.push(
                //   //   context,
                //   //   MaterialPageRoute(
                //   //       builder: (context) => ReturnView(returnMaster: returnMaster,)
                //   //   )
                //   //   , // pass the selected product here
                //   // );
                //
                //   },
                //   child:    Container(child: Padding(
                //     padding: const EdgeInsets.only(left: 40),
                //     child: Text(returnMaster.totalCredit.toString()),
                //   ))
                //   ),
                //   )
                //            ),
                //         // DataCell(Container(child: Padding(
                //         //   padding: const EdgeInsets.only(left: 10),
                //         //   child: Text(returnMaster.notes!),
                //         // ))),
                //
                //       ]);
                // }).toList(),
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

class ReturnMaster {
  final String? returnId;
  final String? returnDate;
  final String? invoiceNumber;
  final String? reason;
  final String? contactPerson;
  final String? orderId;
  final String? ContactNumber;
  final String? ShippAddress;
  final String status;
  final String? email;
  final String? initiatedBy;
  final double? returnCredit;
  final String? customerId;


  // final double totalCredit;
  final String? notes;
  final List<ReturnItem> items;

  ReturnMaster({
    required this.customerId,
    required this.initiatedBy,
    required this.returnId,
    required this.returnDate,
    required this.invoiceNumber,
    required this.reason,
    required this.contactPerson,
    required this.orderId,
    required this.ContactNumber,
    required this.ShippAddress,
    required this.email,
    required this.status,
    required this.returnCredit,
    // required this.totalCredit,
    required this.notes,
    required this.items,
  });

  factory ReturnMaster.fromJson(Map<String, dynamic> json) {
    return ReturnMaster(
      customerId: json['customerId'] ?? '',
      initiatedBy: json['initiatedBy'] ?? '',
      returnId: json['returnId'] ?? '',
      returnDate: json['returnDate'] ?? '',
      invoiceNumber: json['invoiceNumber'] ?? '',
      reason: json['reason'] ?? '',
      status: 'In preparation',
      ContactNumber: json['contactNumber'] ?? '',
      orderId: json['orderId'] ?? '',
      ShippAddress: json['shippingAddress'] ?? '',
      contactPerson: json['contactPerson'] ?? '',
      email: json['email'] ?? '',
      returnCredit: json['returnCredit'].toDouble() ?? 0.0,
      //totalCredit: json['totalCredit'].toDouble() ?? '',
      notes: json['notes'] ?? '',
      items: (json['items'] as List)
          .map((item) => ReturnItem.fromJson(item))
          .toList(),
    );
  }

  @override
  String toString() {
    return 'ReturnMaster{'
        'customerId: $customerId, '

        'initiatedBy: $initiatedBy, '
        'returnId: $returnId, '
        'returnDate: $returnDate, '
        'invoiceNumber: $invoiceNumber, '
        'reason: $reason, '
        'contactPerson: $contactPerson, '
        'email: $email, '
        'returnCredit: $returnCredit, '
        'notes: $notes, '
        // 'customerId: $customerId, '
        'items: $items}';
  }

  factory ReturnMaster.fromString(String jsonString) {
    final jsonMap = jsonDecode(jsonString);
    return ReturnMaster.fromJson(jsonMap);
  }
}

class ReturnItem {
  final String? returnMasterItemId;
  final String? productName;
  final String? category;
  final String? subCategory;
  final double price;
  final int qty;
  final int returnQty;
  final double invoiceAmount;
  final double creditRequest;
  final String? imageId;
  final String? returnId;

  ReturnItem({
    required this.returnMasterItemId,
    required this.productName,
    required this.category,
    required this.subCategory,
    required this.price,
    required this.qty,
    required this.returnQty,
    required this.invoiceAmount,
    required this.creditRequest,
    required this.imageId,
    required this.returnId,
  });

  factory ReturnItem.fromJson(Map<String, dynamic> json) {
    return ReturnItem(
      returnMasterItemId: json['returnMasterItemId'] ?? '',
      productName: json['productName'] ?? '',
      category: json['category'] ?? '',
      subCategory: json['subCategory'] ?? '',
      price: json['price'].toDouble() ?? '',
      qty: json['qty'] ?? '',
      returnQty: json['returnQty'] ?? '',
      invoiceAmount: json['invoiceAmount'].toDouble() ?? '',
      creditRequest: json['creditRequest'].toDouble() ?? '',
      imageId: json['imageId'] ?? '',
      returnId: json['returnId'] ?? '',
    );
  }

  factory ReturnItem.fromString(String jsonString) {
    final jsonMap = jsonDecode(jsonString);
    return ReturnItem.fromJson(jsonMap);
  }
}
