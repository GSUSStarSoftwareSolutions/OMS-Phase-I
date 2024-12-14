import 'dart:async';
import 'dart:convert';
import 'dart:html';
import 'dart:math'as math;
import 'dart:typed_data';
import 'package:adaptive_scrollbar/adaptive_scrollbar.dart';
import 'package:btb/admin/Api%20name.dart';
import 'package:btb/widgets/confirmdialog.dart';
import 'package:btb/widgets/pagination.dart';
import 'package:btb/widgets/productclass.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_date_range_picker/flutter_date_range_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../Order Module/firstpage.dart';
import '../pdf/customer invoice details.dart';
import 'dart:html' as html;
import '../widgets/custom loading.dart';
import '../widgets/no datafound.dart';
import 'customer list.dart';

void main(){
  runApp( const CustomerDetails());
}


class CustomerDetails extends StatefulWidget {
  final String? orderId;
  const CustomerDetails({super.key,this.orderId});
  @override
  State<CustomerDetails> createState() => _CustomerDetailsState();
}
class _CustomerDetailsState extends State<CustomerDetails> {
  bool _hasShownPopup = false;
  List<String> statusOptions = ['Order', 'Invoice', 'Delivery', 'Payment'];
  Timer? _searchDebounceTimer;
  String _searchText = '';
  bool isOrdersSelected = false;
  DateRange? selectedDateRange;
  final _fromDateController = TextEditingController();
  final _toDateController = TextEditingController();
  DateTime _fromDate = DateTime.now();
  DateTime _toDate = DateTime.now().add(const Duration(days: 1));
  bool _loading = false;
  detail? _selectedProduct;
  DateTime? _selectedDate;
  late TextEditingController _dateController;
  Map<String, dynamic> PaymentMap = {};
  final ScrollController horizontalScroll = ScrollController();
  int startIndex = 0;
  List<Product> filteredProducts = [];
  int currentPage = 1;
  String? dropdownValue1 = 'Status';
  late Future<List<CusDetail>> futureOrders;
  List<detail> productList = [];
  final ScrollController _scrollController = ScrollController();
  List<dynamic> detailJson = [];
  String searchQuery = '';
  List<detail>filteredData = [];
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


  Future<void> fetchProducts(String orderId,int page, int itemsPerPage) async {

    if (isLoading) return;
    if (!mounted) return;
    setState(() {
      isLoading = true;
    });

    //
    try {
      final response = await http.get(
        Uri.parse(
          '$apicall/order_master/get_all_ordermaster_by_customer/${orderId}?page=$page&limit=$itemsPerPage', // Changed limit to 10
        ),
        headers: {
          "Content-type": "application/json",
          "Authorization": 'Bearer $token',
        },
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
          final jsonData = jsonDecode(response.body);
          // print('json data');
          // print(jsonData);
          List<detail> products = [];
          if (jsonData != null) {
            if (jsonData is List) {
              products = jsonData.map((item) => detail.fromJson(item)).toList();
            } else if (jsonData is Map && jsonData.containsKey('body')) {
              products = (jsonData['body'] as List).map((item) => detail.fromJson(item)).toList();
              totalItems = jsonData['totalItems'] ?? 0; // Get the total number of items
            }

            if(mounted){
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
      }
    } catch (e) {
      print('Error decoding JSON: $e');
      // Optionally, show an error message to the user
    } finally {
      if(mounted){
        setState(() {
          isLoading = false;
        });
      }

    }
  }
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
          child: _buildMenuItem('Customer', Icons.account_circle_outlined, Colors.blueAccent, '/Customer')),
      _buildMenuItem('Orders', Icons.warehouse_outlined, Colors.blue[900]!, '/Order_List'),
    ];
  }

  Widget _buildMenuItem(String title, IconData icon, Color iconColor, String route) {
    iconColor = _isHovered[title] == true ? Colors.blue : Colors.black87;
    title == 'Customer'? _isHovered[title] = false :  _isHovered[title] = false;
    title == 'Customer'? iconColor = Colors.white : Colors.black;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered[title] = true),
      onExit: (_) => setState(() => _isHovered[title] = false),
      child: GestureDetector(
        onTap: () {
          context.go(route);
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 5,right: 10),
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




  Future<List<dynamic>> fetchProducts1(String orderId) async {
    try {
      // Validate token before making the API call
      if (token == " ") {
        // Show session expired dialog
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
                        Icon(Icons.warning, color: Colors.orange, size: 50),
                        SizedBox(height: 16),
                        Text(
                          'Session Expired',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          "Please log in again to continue",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                context.go('/'); // Navigate to login
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                side: BorderSide(color: Colors.blue),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                              ),
                              child: Text(
                                'OK',
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
        );

        // Return an empty list as the function must return a List<dynamic>
        return [];
      }

      // API Call
      final response = await http.get(
        Uri.parse(
          '$apicall/order_master/get_all_ordermaster_by_customer/$orderId',
        ),
        headers: {
          "Content-type": "application/json",
          "Authorization": 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        print('Response Body: ${response.body}');
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Error decoding JSON: $e');
      // Return an empty list on exception to handle gracefully
      return [];
    }
  }




  Future<void> downloadPdf(String orderId1) async {
    String orderId = orderId1;
    try {
      final orderDetails = await fetchProducts1(orderId);

      if (orderDetails != null) {
        print('hi');
        print(orderDetails);
        final orderDetailJson = orderDetails.first;
        final orderDetail = OrderDetail.fromJson(orderDetailJson);
        final Uint8List pdfBytes = await CustomerInvoiceList(orderDetails);
        final blob = html.Blob([pdfBytes]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute('download', 'Customer_Invoice.pdf')
          ..click();
        html.Url.revokeObjectUrl(url);
      } else {
        print('Failed to fetch order details.');
      }
    } catch (e) {
      print('Error generating PDF: $e');
    }
  }


  void _filterAndPaginateProducts() {
    filteredData = productList.where((product) {
      final matchesSearchText= product.deliveryId!.toLowerCase().contains(_searchText.toLowerCase());
      print('-----');
      //print(product.paymentDate);
      String orderYear = '';
      bool matchesDateRange = true;
      DateTime? paymentDate;

      if (product.paymentDate != null && product.paymentDate!.isNotEmpty) {
        try {
          // Try 'dd/MM/yyyy' first
          paymentDate = DateFormat('dd/MM/yyyy').parse(product.paymentDate!);
        } catch (e) {
          try {
            // If that fails, try 'yyyy-MM-dd'
            paymentDate = DateFormat('yyyy-MM-dd').parse(product.paymentDate!);
          } catch (e) {
            print('Error parsing date with both formats: $e');
          }
        }
      }

      if (status.isEmpty && selectedDateRange == null) {
        return matchesSearchText; // Include all products that match the search text
      }
      if(status == 'Status' && selectedDateRange == null){
        return matchesSearchText;
      }
      if(status == 'Status' &&  selectedDateRange == null)
      {
        return matchesSearchText;
      }
      if( selectedDateRange == null &&  status.isEmpty)
      {
        return matchesSearchText;
      }
      if (status == 'Status' &&  selectedDateRange != null) {
        return matchesSearchText && orderYear == selectDate; // Include all products
      }
      if ((selectedDateRange != null && selectedDateRange!.start != null && selectedDateRange!.end != null && paymentDate != null)) {
        final DateTime startDate = selectedDateRange!.start;
        final DateTime endDate = selectedDateRange!.end;

        matchesDateRange = paymentDate.isAfter(startDate.subtract(const Duration(days: 1))) &&
            paymentDate.isBefore(endDate.add(const Duration(days: 1)));
      }
      if (status.isNotEmpty && selectedDateRange == null) {
        return matchesSearchText && product.paymentStatus == status;// Include all products
      }
      if (status.isNotEmpty && selectedDateRange != null) {
        return matchesSearchText && product.paymentStatus == status && matchesDateRange; // Match both status and date range
      }
      // if (status.isEmpty && selectedDateRange != null) {
      //   return matchesSearchText && orderYear == selectDate; // Include all products
      // }//this one
      if (status.isEmpty && selectedDateRange != null) {
        return matchesSearchText && matchesDateRange; // Filter based on search text and date range
      }
      if (status.isNotEmpty && selectedDateRange == null) {
        return matchesSearchText && product.paymentStatus == status;// Include all products
      }
      return matchesSearchText &&
          (product.paymentStatus == status && orderYear == selectDate);
      //  return false;
    }).toList();
    totalPages = (filteredData.length / itemsPerPage).ceil();

    //   filteredData.sort((a, b) => a.orderId)
    setState(() {
      currentPage = 1;
    });

  }

  void _updateSearch(String searchText) {
    setState(() {
      _searchText = searchText;
      currentPage = 1;  // Reset to first page when searching
      // _filterAndPaginateProducts();
      // _clearSearch();
    });
  }

  void _goToPreviousPage() {
    print("previos");
    if (currentPage > 1) {
      if(filteredData.length > itemsPerPage) {
        setState(() {
          currentPage--;
        });
      }
    }
  }


  void _goToNextPage() {
    print('nextpage');

    if (currentPage < totalPages) {
      if(filteredData.length > currentPage * itemsPerPage) {
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
    print(widget.orderId);
    _dateController.text = '';
    String orderId = widget.orderId!;
    fetchProducts(orderId,currentPage, itemsPerPage);
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
        appBar:
        AppBar(
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
            const SizedBox(width: 10,),
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: AccountMenu(),

            ),
          ],
        ),
        body: LayoutBuilder(
            builder: (context,constraints) {
              double maxWidth = constraints.maxWidth;
              double maxHeight = constraints.maxHeight;
              return
                Stack(
                  children: [
                    if(constraints.maxHeight <= 500)...{
                      SingleChildScrollView(
                        child:  Align(
                          // Added Align widget for the left side menu
                          alignment: Alignment.topLeft,
                          child: Container(
                            height: 1400,
                            width: 200,
                            color: const Color(0xFFF7F6FA),
                            padding: const EdgeInsets.only(left: 15, top: 10,right: 15),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: _buildMenuItems(context),

                            ),
                          ),
                        ),
                      ),
                    }
                    else...{
                      Align(
                        // Added Align widget for the left side menu
                        alignment: Alignment.topLeft,
                        child: Container(
                          height: 1400,
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
                      padding: const EdgeInsets.only(left: 200,top: 0),
                      child: Container(
                        width: 1, // Set the width to 1 for a vertical line
                        height: 1400, // Set the height to your liking
                        decoration: const BoxDecoration(
                          border: Border(left: BorderSide(width: 1, color: Colors.grey)),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 201,
                      top: 0,
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
                                  Padding(padding:EdgeInsets.only(left: 5),
                                  child:IconButton(icon: Icon(Icons.arrow_back,),
         onPressed: () {
                                    context.go('/Customer');
         },
                                  )
                                  ),
                                  SizedBox(width: 20,),
                                  Text(
                                    'Customer',
                                    style: TextStyle(
                                      color: Colors.black,
                                        fontSize: 20, fontWeight: FontWeight.bold),

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
                    // Positioned(
                    //   top: 0,
                    //   left: 0,
                    //   right: 0,
                    //   child: Padding(
                    //     padding: const EdgeInsets.only(left: 201),
                    //     child: Container(
                    //       padding: const EdgeInsets.symmetric(horizontal: 16),
                    //       color: Colors.white,
                    //       height: 50,
                    //       child: Row(
                    //         children: [
                    //           IconButton(onPressed: (){
                    //             Navigator.push(
                    //               context,
                    //               PageRouteBuilder(
                    //                 pageBuilder: (context, animation,
                    //                     secondaryAnimation) =>
                    //                     const CusList(),
                    //                 transitionDuration:
                    //                 const Duration(milliseconds: 200),
                    //                 transitionsBuilder: (context, animation,
                    //                     secondaryAnimation, child) {
                    //                   return FadeTransition(
                    //                     opacity: animation,
                    //                     child: child,
                    //                   );
                    //                 },
                    //               ),
                    //             );
                    //           }, icon: const Icon(Icons.arrow_back)),
                    //           const Padding(
                    //             padding: EdgeInsets.only(left: 20),
                    //             child: Text(
                    //               'Customer',
                    //               style: TextStyle(
                    //                   fontSize: 20,
                    //                   fontWeight: FontWeight.bold
                    //               ),
                    //               textAlign: TextAlign.center,
                    //             ),
                    //           ),
                    //         ],
                    //       ),
                    //     ),
                    //   ),
                    // ),
                    // Padding(
                    //   padding: const EdgeInsets.only(top: 40, left: 200),
                    //   child: Container(
                    //     margin: const EdgeInsets.symmetric(
                    //         vertical: 10),
                    //     // Space above/below the border
                    //     height: 0.3, // Border height
                    //     color: Colors.black, // Border color
                    //   ),
                    // ),
                    // Padding(
                    //   padding:  EdgeInsets.only(
                    //       left:
                    //       300, top: 120, right: maxWidth * 0.062,bottom: 15),
                    //   child: Container(
                    //     width: maxWidth,
                    //     height: 700,
                    //     decoration: BoxDecoration(
                    //       border: Border.all(color: Colors.grey),
                    //       color: Colors.white,
                    //       borderRadius: BorderRadius.circular(8),
                    //     ),
                    //     child: SingleChildScrollView(
                    //       scrollDirection: Axis.vertical,
                    //       child: SizedBox(
                    //         width: maxWidth * 0.79,
                    //         child: Column(
                    //           crossAxisAlignment: CrossAxisAlignment.start,
                    //           children: [
                    //             buildSearchField(),
                    //             // buildSearchField(),
                    //             const SizedBox(height: 10),
                    //             Scrollbar(
                    //               controller: _scrollController,
                    //               thickness: 6,
                    //               thumbVisibility: true,
                    //               child: SingleChildScrollView(
                    //                 controller: _scrollController,
                    //                 scrollDirection: Axis.horizontal,
                    //                 child: buildDataTable(),
                    //               ),
                    //             ),
                    //             //Divider(color: Colors.grey,height: 1,)
                    //             const SizedBox(),
                    //             Padding(
                    //               padding: const EdgeInsets.only(right:30),
                    //               child: Row(
                    //                 mainAxisAlignment: MainAxisAlignment.end,
                    //                 children: [
                    //                   PaginationControls(
                    //                     currentPage: currentPage,
                    //                     totalPages: filteredData.length > itemsPerPage ? totalPages : 1,// totalPages,
                    //                     onPreviousPage: _goToPreviousPage,
                    //                     onNextPage: _goToNextPage,
                    //                   ),
                    //                 ],
                    //               ),
                    //             )
                    //           ],
                    //         ),
                    //       ),
                    //     ),
                    //   ),
                    // ),
                  ],
                );
            }
        ),
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
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                              maxWidth: constraints.maxWidth * 0.12, // reduced width
                              maxHeight: 30, // reduced height
                            ),
                            child: Container(
                              height: 35,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(2),
                                border: Border.all(color: Colors.grey),
                              ),
                              child:
                              DropdownButtonFormField<String>(
                                decoration: const InputDecoration(
                                  contentPadding: EdgeInsets.only(bottom: 15,left: 10),// adjusted padding
                                  border: InputBorder.none,
                                  filled: true,
                                  fillColor: Colors.white,
                                  //hintText: 'Category',
                                  hintStyle: TextStyle(color: Colors.grey),
                                ),
                                icon: Padding(
                                  padding: const EdgeInsets.only(right: 10),
                                  child: Icon(Icons.arrow_drop_down_circle_rounded, color: Colors.blue[800], size: 16),
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
                                  'partial payment',
                                  'cleared',
                                ].map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value, style: TextStyle(color: value == 'Status' ? Colors.grey : Colors.black,fontSize: 13)),
                                  );
                                }).toList(),
                                isExpanded: true,
                                focusColor: const Color(0xFFF0F4F8),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 300),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  width: 209,
                                  height: 45,
                                  child: DateRangeField(
                                    //  initialValue:null ,
                                    decoration: InputDecoration(
                                      hintText: "Select a date",
                                      hintStyle: const TextStyle(fontSize: 13),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(5),
                                        borderSide: const BorderSide(color: Colors.grey),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(5),
                                        borderSide: const BorderSide(color: Colors.grey),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(5),
                                        borderSide: const BorderSide(color: Colors.blue),
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 12,vertical: 5), // Add this line
                                    ),
                                    selectedDateRange: selectedDateRange,
                                    pickerBuilder: datePickerBuilder,
                                    onDateRangeSelected: (DateRange? value){
                                      setState(() {
                                        selectedDateRange =value;
                                        // _dateController.text = value.toString();
                                        //print(_dateController.text);
                                        _filterAndPaginateProducts();
                                      });
                                    },
                                  ),
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    Align(
                      alignment: Alignment.topRight,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 280),
                        child: SizedBox(
                          height: 30,
                          child: OutlinedButton(
                              onPressed: () {
                                downloadPdf(widget.orderId!);
                                //context.go('/Create_New_Product');
                              },
                              style: OutlinedButton.styleFrom(
                                padding: EdgeInsets.zero,
                                backgroundColor: Colors.blue[800],
                                // Button background color
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.circular(5), // Rounded corners
                                ),
                                side: BorderSide.none, // No outline
                              ),
                              child:Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  IconButton(onPressed: (){}, icon: const Icon(Icons.download_for_offline,color: Colors.white,size: 15,)
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.only(right: 20),
                                    child: Text('Export',style: TextStyle(color: Colors.white),),
                                  )
                                ],
                              )
                          ),
                        ),
                      ),
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


  Widget datePickerBuilder(
      BuildContext context, dynamic Function(DateRange?) onDateRangeChanged,
      [bool doubleMonth = false]) =>
      DateRangePickerWidget(
        doubleMonth: doubleMonth,
        maximumDateRangeLength: 30,
        quickDateRanges: [
          QuickDateRange(dateRange: null, label: "Select Date"),
          QuickDateRange(
            label: 'Yesterday',
            dateRange: DateRange(
              DateTime.now().subtract(const Duration(days: 1)),
              DateTime.now(),
            ),
          ),
          QuickDateRange(
            label: 'Last Week',
            dateRange: DateRange(
              DateTime.now().subtract(const Duration(days: 7)),
              DateTime.now(),
            ),
          ),
          QuickDateRange(
            label: 'Last Month',
            dateRange: DateRange(
              DateTime.now().subtract(const Duration(days: 30)),
              DateTime.now(),
            ),
          ),
        ],
        minimumDateRangeLength: 3,
        initialDateRange: null,
        disabledDates: [DateTime(2023, 11, 20)],
        initialDisplayedDate: null,
        // initialDisplayedDate: selectedDateRange?.start ?? DateTime(2023, 11, 20),
        onDateRangeChanged: onDateRangeChanged,
        height: 350,
        theme: const CalendarTheme(
          selectedColor: Colors.blue,
          dayNameTextStyle: TextStyle(color: Colors.black45, fontSize: 10),
          inRangeColor: Color(0xFFD9EDFA),
          inRangeTextStyle: TextStyle(color: Colors.blue),
          selectedTextStyle: TextStyle(color: Colors.white),
          todayTextStyle: TextStyle(fontWeight: FontWeight.bold),
          defaultTextStyle: TextStyle(color: Colors.black, fontSize: 12),
          radius: 10,
          tileSize: 40,
          disabledTextStyle: TextStyle(color: Colors.grey),
          quickDateRangeBackgroundColor: Color(0xFFFFF9F9),
          selectedQuickDateRangeColor: Colors.blue,
        ),
      );


  Widget buildDataTable() {
    if (isLoading) {
      _loading = true;
      var width = MediaQuery.of(context).size.width;
      var Height = MediaQuery.of(context).size.height;
      // Show loading indicator while data is being fetched
      return Padding(
        padding: EdgeInsets.only(top: Height * 0.100,bottom: Height * 0.100,left: width * 0.300),
        child: CustomLoadingIcon(), // Replace this with your custom GIF widget
      );
    }

    if (filteredData.isEmpty) {
      double right = MediaQuery.of(context).size.width;
      return
        Column(
          children: [
            Container(
              width: right * 0.82,

              decoration:const BoxDecoration(
                  color: Color(0xFFF7F7F7),
                  border: Border.symmetric(horizontal: BorderSide(color: Colors.grey,width: 0.5))
              ),
              child: DataTable(
                showCheckboxColumn: false,
                headingRowHeight: 40,
                columns: [
                  DataColumn(label: Container(
                      child: Text('Invoice ID',style:TextStyle(
                          color: Colors.indigo[900],
                          fontSize: 13,
                          fontWeight: FontWeight.bold
                      ),))),
                  DataColumn(label: Container(child: Text('Payment ID',style:TextStyle(
                      color: Colors.indigo[900],
                      fontSize: 13,
                      fontWeight: FontWeight.bold
                  ),))),
                  DataColumn(label: Container(child: Text(
                    'Date',style:TextStyle(
                      color: Colors.indigo[900],
                      fontSize: 13,
                      fontWeight: FontWeight.bold
                  ),))),
                  DataColumn(label: Container(child: Text(
                    'Amount',style:TextStyle(
                      color: Colors.indigo[900],
                      fontSize: 13,
                      fontWeight: FontWeight.bold
                  ),))),
                  DataColumn(label: Container(child: Text(
                    'Paid Amount',style:TextStyle(
                      color: Colors.indigo[900],
                      fontSize: 13,
                      fontWeight: FontWeight.bold
                  ),))),
                  DataColumn(label: Container(child: Text(
                    'Status',style:TextStyle(
                      color: Colors.indigo[900],
                      fontSize: 13,
                      fontWeight: FontWeight.bold
                  ),))),

                ],
                rows: [],

              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 150,left: 130,bottom: 350,right: 150),
              child: CustomDatafound(),
            ),
          ],

        );

    }
    return LayoutBuilder(builder: (context, constraints){
      // double padding = constraints.maxWidth * 0.065;
      //double right = MediaQuery.of(context).size.width;
      double right = MediaQuery.of(context).size.width * 0.92;


      return
        Column(
          children: [
            Container(
              width: right - 100,

              decoration:const BoxDecoration(
                  color: Color(0xFFF7F7F7),
                  border: Border.symmetric(horizontal: BorderSide(color: Colors.grey,width: 0.5))
              ),
              child: DataTable(
                showCheckboxColumn: false,
                headingRowHeight: 40,
                columns: [
                  DataColumn(label: Container(child: Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Text('Invoice Number',style:TextStyle(
                        color: Colors.indigo[900],
                        fontSize: 13,
                        fontWeight: FontWeight.bold
                    ),),
                  ))),
                  DataColumn(label: Container(child: Text(
                    'Payment ID',style:TextStyle(
                      color: Colors.indigo[900],
                      fontSize: 13,
                      fontWeight: FontWeight.bold
                  ),))),
                  DataColumn(label: Container(child: Text(
                    'Date',style:TextStyle(
                      color: Colors.indigo[900],
                      fontSize: 13,
                      fontWeight: FontWeight.bold
                  ),))),
                  DataColumn(label: Container(child: Text(
                    'Amount',style:TextStyle(
                      color: Colors.indigo[900],
                      fontSize: 13,
                      fontWeight: FontWeight.bold
                  ),))),
                  // DataColumn(label: Container(child: Text(
                  //   'Paid Amount',style:  TextStyle(
                  //
                  //     color: Colors.indigo[900],
                  //     fontSize: 13,
                  //     fontWeight: FontWeight.bold
                  // ),))),
                  DataColumn(label: Container(child: Text(
                    'Status',style:  TextStyle(

                      color: Colors.indigo[900],
                      fontSize: 13,
                      fontWeight: FontWeight.bold
                  ),))),
                ],
                rows:
                List.generate(
                    math.min(itemsPerPage, filteredData.length - (currentPage - 1) * itemsPerPage),(index){
                  final detail = filteredData.skip((currentPage - 1) * itemsPerPage).elementAt(index);
                  final isSelected = _selectedProduct == detail;
                  // final isSelected = _selectedProduct == detail;
                  //final product = filteredData[(currentPage - 1) * itemsPerPage + index];
                  return DataRow(
                    color: MaterialStateProperty.resolveWith<Color>((states) {
                      if (states.contains(MaterialState.hovered)) {
                        return Colors.blue.shade500.withOpacity(0.8); // Add some opacity to the dark blue
                      } else {
                        return Colors.white.withOpacity(0.9);
                      }
                    }),
                    cells:
                    [

                      DataCell(
                          Text(detail.invoiceNo!,style:
                          const TextStyle(
                            // fontSize: 16,
                              color: Colors.grey),)),
                      DataCell(
                        Padding(
                          padding: const EdgeInsets.only(left: 2),
                          child: Text(detail.paymentId!,style: const TextStyle(
                            // fo ntSize: 16,
                              color: Colors.grey)),
                        ),
                      ),
                      DataCell(
                        Text(detail.paymentDate!.toString(),style: const TextStyle(
                          //fontSize: 16,
                            color: Colors.grey)),
                      ),
                      DataCell(
                        Padding(
                          padding: const EdgeInsets.only(left: 13),
                          child: Text(detail.total.toString(),style: const TextStyle(
                            // fontSize: 16,
                              color: Colors.grey)),
                        ),
                      ),
                      DataCell(
                        Padding(
                          padding: const EdgeInsets.only(left: 5),
                          child: Text(detail.paymentStatus.toString(),style: const TextStyle(
                            //fontSize: 16,
                              color: Colors.grey)),
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ],
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
        padding: EdgeInsets.only(top: Height * 0.100,bottom: Height * 0.100,left: width * 0.300),
        child: CustomLoadingIcon(), // Replace this with your custom GIF widget
      );
    }

    if (filteredData.isEmpty) {
      double right = MediaQuery.of(context).size.width;
      return
        Column(
          children: [
            Container(
              width: 1100,

              decoration:const BoxDecoration(
                  color: Color(0xFFF7F7F7),
                  border: Border.symmetric(horizontal: BorderSide(color: Colors.grey,width: 0.5))
              ),
              child: DataTable(
                showCheckboxColumn: false,
                headingRowHeight: 40,
                columns: [
                  DataColumn(label: Container(
                      child: Text('Invoice ID',style:TextStyle(
                          color: Colors.indigo[900],
                          fontSize: 13,
                          fontWeight: FontWeight.bold
                      ),))),
                  DataColumn(label: Container(child: Text('Payment ID',style:TextStyle(
                      color: Colors.indigo[900],
                      fontSize: 13,
                      fontWeight: FontWeight.bold
                  ),))),
                  DataColumn(label: Container(child: Text(
                    'Date',style:TextStyle(
                      color: Colors.indigo[900],
                      fontSize: 13,
                      fontWeight: FontWeight.bold
                  ),))),
                  DataColumn(label: Container(child: Text(
                    'Amount',style:TextStyle(
                      color: Colors.indigo[900],
                      fontSize: 13,
                      fontWeight: FontWeight.bold
                  ),))),
                  DataColumn(label: Container(child: Text(
                    'Paid Amount',style:TextStyle(
                      color: Colors.indigo[900],
                      fontSize: 13,
                      fontWeight: FontWeight.bold
                  ),))),
                  DataColumn(label: Container(child: Text(
                    'Status',style:TextStyle(
                      color: Colors.indigo[900],
                      fontSize: 13,
                      fontWeight: FontWeight.bold
                  ),))),

                ],
                rows: [],

              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 150,left: 130,bottom: 350,right: 150),
              child: CustomDatafound(),
            ),
          ],

        );

    }
    return LayoutBuilder(builder: (context, constraints){
      // double padding = constraints.maxWidth * 0.065;
      double right = MediaQuery.of(context).size.width;


      return
        Column(
          children: [
            Container(
              width:1100,

              decoration:const BoxDecoration(
                  color: Color(0xFFF7F7F7),
                  border: Border.symmetric(horizontal: BorderSide(color: Colors.grey,width: 0.5))
              ),
              child: DataTable(
                showCheckboxColumn: false,
                headingRowHeight: 40,
                columns: [
                  DataColumn(label: Container(child: Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Text('Invoice Number',style:TextStyle(
                        color: Colors.indigo[900],
                        fontSize: 13,
                        fontWeight: FontWeight.bold
                    ),),
                  ))),
                  DataColumn(label: Container(child: Text(
                    'Payment ID',style:TextStyle(
                      color: Colors.indigo[900],
                      fontSize: 13,
                      fontWeight: FontWeight.bold
                  ),))),
                  DataColumn(label: Container(child: Text(
                    'Date',style:TextStyle(
                      color: Colors.indigo[900],
                      fontSize: 13,
                      fontWeight: FontWeight.bold
                  ),))),
                  DataColumn(label: Container(child: Text(
                    'Amount',style:TextStyle(
                      color: Colors.indigo[900],
                      fontSize: 13,
                      fontWeight: FontWeight.bold
                  ),))),
                  // DataColumn(label: Container(child: Text(
                  //   'Paid Amount',style:  TextStyle(
                  //
                  //     color: Colors.indigo[900],
                  //     fontSize: 13,
                  //     fontWeight: FontWeight.bold
                  // ),))),
                  DataColumn(label: Container(child: Text(
                    'Status',style:  TextStyle(

                      color: Colors.indigo[900],
                      fontSize: 13,
                      fontWeight: FontWeight.bold
                  ),))),
                ],
                rows:
                List.generate(
                    math.min(itemsPerPage, filteredData.length - (currentPage - 1) * itemsPerPage),(index){
                  final detail = filteredData.skip((currentPage - 1) * itemsPerPage).elementAt(index);
                  final isSelected = _selectedProduct == detail;
                  // final isSelected = _selectedProduct == detail;
                  //final product = filteredData[(currentPage - 1) * itemsPerPage + index];
                  return DataRow(
                    color: MaterialStateProperty.resolveWith<Color>((states) {
                      if (states.contains(MaterialState.hovered)) {
                        return Colors.blue.shade500.withOpacity(0.8); // Add some opacity to the dark blue
                      } else {
                        return Colors.white.withOpacity(0.9);
                      }
                    }),
                    cells:
                    [

                      DataCell(
                          Text(detail.invoiceNo!,style:
                          const TextStyle(
                            // fontSize: 16,
                              color: Colors.grey),)),
                      DataCell(
                        Padding(
                          padding: const EdgeInsets.only(left: 2),
                          child: Text(detail.paymentId!,style: const TextStyle(
                            // fo ntSize: 16,
                              color: Colors.grey)),
                        ),
                      ),
                      DataCell(
                        Text(detail.paymentDate!.toString(),style: const TextStyle(
                          //fontSize: 16,
                            color: Colors.grey)),
                      ),
                      DataCell(
                        Padding(
                          padding: const EdgeInsets.only(left: 13),
                          child: Text(detail.total.toString(),style: const TextStyle(
                            // fontSize: 16,
                              color: Colors.grey)),
                        ),
                      ),
                      DataCell(
                        Padding(
                          padding: const EdgeInsets.only(left: 5),
                          child: Text(detail.paymentStatus.toString(),style: const TextStyle(
                            //fontSize: 16,
                              color: Colors.grey)),
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ],
        );
    });
  }



}


