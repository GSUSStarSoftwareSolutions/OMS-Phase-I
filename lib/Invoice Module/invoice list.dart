import 'dart:async';
import 'dart:convert';
import 'dart:html';
import 'dart:math'as math;
import 'dart:html' as html;
import 'dart:typed_data';
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
import 'package:provider/provider.dart';
import '../../widgets/custom loading.dart';
import 'package:btb/Order Module/firstpage.dart';
import '../../widgets/no datafound.dart';
import '../main.dart';
import '../pdf/invoice pdf.dart';

void main(){
  runApp(const InvoiceList());
}


class InvoiceList extends StatefulWidget {
  const InvoiceList({super.key});
  @override
  State<InvoiceList> createState() => _InvoiceListState();
}

class _InvoiceListState extends State<InvoiceList> {
  final ScrollController horizontalScroll = ScrollController();
  Timer? _searchDebounceTimer;
  String _searchText = '';
  bool isOrdersSelected = false;
  bool _loading = false;
  OrderDetail? _selectedProduct;
  DateTime? _selectedDate;
  late TextEditingController _dateController;
  int startIndex = 0;
  String? orderId;
  List<Product> filteredProducts = [];
  List<String> _sortOrder = List.generate(7, (index) => 'asc');
  List<String> columns1 = ['','Invoice ID','Order ID','Order Date' ,'Delivery Status','Amount'];
  List<String> columns = ['Invoice No','Date','Order ID' ,'Status','Amount',''];
  List<double> columnWidths = [110, 110, 110, 135, 130,100];
  List<bool> columnSortState = [true, true, true,true,true,true,true];
  int currentPage = 1;
  String? dropdownValue1 = 'Status';
  late Future<List<detail>> futureOrders;
  List<OrderDetail> productList = [];
 // String? role = window.sessionStorage["role"];
  final ScrollController _scrollController = ScrollController();
  List<dynamic> detailJson = [];
  String searchQuery = '';
  List<OrderDetail>filteredData = [];
  String status = '';
  String selectDate = '';
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
      _buildMenuItem('Customer', Icons.account_circle_outlined, Colors.blue[900]!, '/Customer'),
      _buildMenuItem('Products', Icons.image_outlined, Colors.blue[900]!, '/Product_List'),
      _buildMenuItem('Orders', Icons.warehouse_outlined, Colors.blue[900]!, '/Order_List'),
      _buildMenuItem('Delivery', Icons.fire_truck_outlined, Colors.blue[900]!, '/Delivery_List'),
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
          child: _buildMenuItem('Invoice', Icons.document_scanner_outlined, Colors.white, '/Invoice')),

      _buildMenuItem('Payment', Icons.payment_rounded, Colors.blue[900]!, '/Payment_List'),
      _buildMenuItem('Return', Icons.keyboard_return, Colors.blue[900]!, '/Return_List'),
      _buildMenuItem('Reports', Icons.insert_chart_outlined, Colors.blue[900]!, '/Report_List'),
    ];
  }

  Widget _buildMenuItem(String title, IconData icon, Color iconColor, String route) {
    iconColor = _isHovered[title] == true ? Colors.blue : Colors.black87;
    title == 'Invoice'? _isHovered[title] = false :  _isHovered[title] = false;
    title == 'Invoice'? iconColor = Colors.white : Colors.black;
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
          '$apicall/invoice_master/get_all_invoice_master?page=$page&limit=$itemsPerPage',
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
        List<OrderDetail> products = [];
        if (jsonData != null) {
          if (jsonData is List) {
            products = jsonData.map((item) => OrderDetail.fromJson(item)).toList();
          } else if (jsonData is Map && jsonData.containsKey('body')) {
            products = (jsonData['body'] as List).map((item) => OrderDetail.fromJson(item)).toList();
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

  Future<List<dynamic>> _fetchAllProductMaster() async {
   // final String token = 'eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJkaGFuYXNla2FyIiwiUm9sZXMiOlt7ImF1dGhvcml0eSI6ImRldmVsb3BlciJ9XSwiZXhwIjoxNzIzMTE0OTQ0LCJpYXQiOjE3MjMxMDc3NDR9.1UxLslHM3GivBHoBr8pS02OxD6dC5IRG4ryxiUdgzIJmFjSCwftf6Kme4rPLb-ZOjzOoAaxueSzKxiLmjnmSFg';
    try {
      final response = await http.get(
        Uri.parse('$apicall/productmaster/get_all_productmaster'),
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
      final url = '$apicall/order_master/search_by_orderid/$orderId';
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

  Future downloadPdf(String orderId) async {
    try {
      final productMasterData = await _fetchAllProductMaster();
      final orderDetails = await _fetchOrderDetails(orderId);
      for (var product in productMasterData) {
        for (var item in orderDetails!.items) {
          if (product['productName'] == item['productName']) {
            item['tax'] = product['tax'];
            item['discount'] = product['discount'];
            item['discountamount'] = (double.parse(item['totalAmount'].toString()) * double.parse(item['discount'].replaceAll('%', ''))) / 100;
            item['taxamount'] = ((double.parse(item['totalAmount'].toString()) -
                double.parse(item['discountamount'].toString())) *
                double.parse(item['tax'].replaceAll('%', '').toString())) / 100;
          }
        }
      }

      if (orderDetails != null) {
        final Uint8List pdfBytes = await Invoicepdf1(orderDetails);
        final blob = html.Blob([pdfBytes]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute('download', 'Invoice.pdf')
          ..click();
        html.Url.revokeObjectUrl(url);
      } else {
        print('Failed to fetch order details.');
      }
    } catch (e) {
      print('Error generating PDF: $e');
    }
  }


  void _updateSearch(String searchText) {
    setState(() {
      _searchText = searchText;
      currentPage = 1;  // Reset to first page when searching
      _filterAndPaginateProducts();
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
      //_filterAndPaginateProducts();
    }
  }

  @override
  void initState() {
    super.initState();
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
    String? role = Provider.of<UserRoleProvider>(context).role;
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
                              child:const  Row(
                                children: [
                                   Padding(
                                    padding: EdgeInsets.only(left: 20),
                                    child: Text(
                                      'Invoice List',
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold
                                      ),
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
                            decoration:  InputDecoration(
                              hintText: 'Search by Invoice No',
                              hintStyle: const TextStyle(fontSize: 13,color: Colors.grey),
                              contentPadding: const EdgeInsets.only(bottom: 20,left: 10), // adjusted padding
                              border: InputBorder.none,
                              suffixIcon: Icon(Icons.search_outlined, color: Colors.blue[800]),
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
                              child: DropdownButtonFormField2<String>(
                                decoration: const InputDecoration(
                                  contentPadding: EdgeInsets.only(bottom: 15,left: 10),// adjusted padding
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
                                  'Not Started',
                                  'In Progress',
                                  'Delivered',
                                ].map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value, style: TextStyle(color: value == 'Status' ? Colors.grey : Colors.black,fontSize: 13)),
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
                              maxWidth: constraints.maxWidth * 0.128, // reduced width
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
                                  contentPadding: EdgeInsets.only(bottom: 22,left: 10),
                                  border: InputBorder.none,
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                                value: dropdownValue2,
                                //focusColor: const Color(0xFFF0F4F8),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    dropdownValue2 = newValue;
                                    selectDate = newValue ?? '';
                                    _filterAndPaginateProducts();
                                  });
                                },
                                items: <String>[
                                  'Select Year', '2023', '2024', '2025'
                                ].map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value, style: TextStyle(color: value == 'Select Year' ? Colors.grey : Colors.black,fontSize: 13)),
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
        padding: EdgeInsets.only(top: Height * 0.100,bottom: Height * 0.100,left: width * 0.300),
        child: CustomLoadingIcon(), // Replace this with your custom GIF widget
      );
    }

    if (filteredData.isEmpty) {
      //  String? role = Provider.of<UserRoleProvider>(context).role;
      double right = MediaQuery.of(context).size.width;
      return
        Column(
          children: [
            Container(
              width:right * 0.81,

              decoration:const BoxDecoration(
                  color: Color(0xFFF7F7F7),
                  border: Border.symmetric(horizontal: BorderSide(color: Colors.grey,width: 0.5))
              ),
              child:

              DataTable(
                  showCheckboxColumn: false,
                  headingRowHeight: 40,
                  columns: [
                    DataColumn(label: Container(child: const Text('      '))),
                    DataColumn(
                      label: Container(
                        child: Text(
                          'Invoice No',
                          style: TextStyle(
                            color: Colors.indigo[900],
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Container(
                        child: Text(
                          'Date',
                          style: TextStyle(
                            color: Colors.indigo[900],
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Container(
                        child: Text(
                          'Order ID',
                          style: TextStyle(
                            color: Colors.indigo[900],
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Container(
                        child: Text(
                          'Location',
                          style: TextStyle(
                            color: Colors.indigo[900],
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Container(
                        child: Text(
                          'Status',
                          style: TextStyle(
                            color: Colors.indigo[900],
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Container(
                        child: Text(
                          'Amount',
                          style: TextStyle(
                            color: Colors.indigo[900],
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                  rows: []

              ),

            ),
            Padding(
              padding: const EdgeInsets.only(top: 150,left: 130,bottom: 350,right: 150),
              child: CustomDatafound(),
            ),
          ],
        );

    }


    void _sortProducts(int columnIndex, String sortDirection) {
      if (sortDirection == 'asc') {
        filteredData.sort((a, b) {
          if (columnIndex == 1) {
            return a.InvNo!.compareTo(b.InvNo!);
          } else if (columnIndex == 2) {
            return a.orderDate!.compareTo(b.orderDate!);
          } else if (columnIndex == 3) {
            return a.orderId!.compareTo(b.orderId!);
          } else if (columnIndex == 4) {
            return a.deliveryLocation!.toLowerCase().compareTo(b.deliveryLocation!.toLowerCase());
          } else if (columnIndex == 5) {
            return a.status!.compareTo(b.status!);
          }
          else if (columnIndex == 6) {
            return a.total!.compareTo(b.total!);
          } else {
            return 0;
          }
        });
      } else {
        filteredData.sort((a, b) {
          if (columnIndex == 1) {
            return b.InvNo!.compareTo(a.InvNo!); // Reverse the comparison
          } else if (columnIndex == 2) {
            return b.orderDate!.compareTo(a.orderDate!); // Reverse the comparison
          } else if (columnIndex == 3) {
            return b.orderId!.compareTo(a.orderId!); // Reverse the comparison
          } else if (columnIndex == 4) {
            return b.deliveryLocation!.toLowerCase().compareTo(a.deliveryLocation!.toLowerCase()); // Reverse the comparison
          } else if (columnIndex == 5) {
            return b.status!.compareTo(a.status!); // Reverse the comparison
          }
          else if (columnIndex == 6) {
            return b.total!.compareTo(a.total!); // Reverse the comparison
          }else {
            return 0;
          }
        });
      }
      setState(() {});
    }


    return LayoutBuilder(builder: (context, constraints){
      // double padding = constraints.maxWidth * 0.065;
      //  String? role = Provider.of<UserRoleProvider>(context).role;
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
                child:
                DataTable(
                  showCheckboxColumn: false,
                  headingRowHeight: 40,
                  columnSpacing: 35,
                  columns: columns.map((column) {
                    return
                      DataColumn(
                        label: Stack(
                          children: [
                            Container(
                              //   padding: EdgeInsets.only(left: 5,right: 5),
                              width: columnWidths[columns.indexOf(column)], // Dynamic width based on user interaction
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
                                    icon: _sortOrder[columns.indexOf(column)] == 'asc'
                                        ? SizedBox(width: 12,
                                        child: Image.asset("images/sort.png",color: Colors.grey,))
                                        : SizedBox(width: 12,child: Image.asset("images/sort.png",color: Colors.blue,)),
                                    onPressed: () {
                                      setState(() {
                                        _sortOrder[columns.indexOf(column)] = _sortOrder[columns.indexOf(column)] == 'asc' ? 'desc' : 'asc';
                                        _sortProducts(columns.indexOf(column), _sortOrder[columns.indexOf(column)]);
                                      });
                                    },
                                  ),

                                  if (columns.indexOf(column) < columns.length - 1)
                                    Spacer(),
                                  if (columns.indexOf(column) < columns.length - 1)
                                  MouseRegion(
                                    cursor: SystemMouseCursors.resizeColumn,
                                    child: GestureDetector(
                                        onHorizontalDragUpdate: (details) {
                                          // Update column width dynamically as user drags
                                          setState(() {
                                            columnWidths[columns.indexOf(column)] += details.delta.dx;
                                            columnWidths[columns.indexOf(column)] =
                                                columnWidths[columns.indexOf(column)].clamp(136.0, 300.0);
                                          });
                                          // setState(() {
                                          //   columnWidths[columns.indexOf(column)] += details.delta.dx;
                                          //   if (columnWidths[columns.indexOf(column)] < 50) {
                                          //     columnWidths[columns.indexOf(column)] = 50; // Minimum width
                                          //   }
                                          // });
                                        },
                                        child: const Padding(
                                          padding: EdgeInsets.only(top: 10,bottom: 10),
                                          child: Row(
                                            children: [
                                              VerticalDivider(
                                                width: 5,
                                                thickness: 4,
                                                color: Colors.grey,

                                              )
                                            ],
                                          ),
                                        )
                                    ),
                                  ),
                                  // ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        onSort: (columnIndex, ascending){
                          _sortOrder;
                        },
                      ) ;
                  }).toList(),
                  rows: List.generate(
                    math.min(itemsPerPage, filteredData.length - (currentPage - 1) * itemsPerPage),
                        (index) {

                      final detail = filteredData.skip((currentPage - 1) * itemsPerPage).elementAt(index);
                      print('detail');
                      print(detail);
                      final isSelected = _selectedProduct == detail;
                      return DataRow(
                        color: MaterialStateProperty.resolveWith<Color>((states) {
                          if (states.contains(MaterialState.hovered)) {
                            return Colors.blue.shade500.withOpacity(0.8); // Dark blue with opacity
                          } else if (isSelected) {
                            return Colors.blue.shade100.withOpacity(0.8); // Green with opacity for selected row
                          } else {
                            return Colors.white.withOpacity(0.9);
                          }
                        }),
                        cells: [
                          DataCell(
                            Text(
                              detail.InvNo!,
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ),
                          DataCell(
                            Text(
                              detail.orderDate!,
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ),
                          DataCell(
                            Text(
                              detail.orderId!,
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ),
                          DataCell(
                            Text(
                              detail.status.toString(),
                              style: TextStyle(
                                  color: detail.status == "In Progress" ? Colors.orange : detail.status == "Delivered" ? Colors.green : Colors.red
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              detail.total.toString(),
                              style: const TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                          ),
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
                                    downloadPdf(detail.orderId!);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],

                      );
                    },
                  ),
                )

              // DataTable(
              //     showCheckboxColumn: false,
              //     headingRowHeight: 40,
              //     columns: [
              //       DataColumn(label: Container(child: Padding(
              //         padding: const EdgeInsets.only(left: 10),
              //         child: Text('Order ID',style:TextStyle(
              //             color: Colors.indigo[900],
              //             fontSize: 13,
              //             fontWeight: FontWeight.bold
              //         ),),
              //       ))),
              //       DataColumn(label: Container(
              //           child: Padding(
              //             padding: const EdgeInsets.only(left: 20),
              //             child: Text('Delivered Date',style:TextStyle(
              //                 color: Colors.indigo[900],
              //                 fontSize: 13,
              //                 fontWeight: FontWeight.bold
              //             ),),
              //           ))),
              //       DataColumn(label: Container(child: Text(
              //         'Invoice Number',style:TextStyle(
              //           color: Colors.indigo[900],
              //           fontSize: 13,
              //           fontWeight: FontWeight.bold
              //       ),))),
              //       DataColumn(label: Container(child: Text(
              //         'Payment Date',style:TextStyle(
              //           color: Colors.indigo[900],
              //           fontSize: 13,
              //           fontWeight: FontWeight.bold
              //       ),))),
              //       DataColumn(label: Container(child: Text(
              //         'Payment Mode',style:  TextStyle(
              //
              //           color: Colors.indigo[900],
              //           fontSize: 13,
              //           fontWeight: FontWeight.bold
              //       ),))),
              //       DataColumn(label: Container(child: Text(
              //         'Payment Status',style:  TextStyle(
              //
              //           color: Colors.indigo[900],
              //           fontSize: 13,
              //           fontWeight: FontWeight.bold
              //       ),))),
              //       DataColumn(label: Container(child: Padding(
              //         padding: const EdgeInsets.only(right: 50),
              //         child: Text(
              //           'Amount',style:  TextStyle(
              //
              //             color: Colors.indigo[900],
              //             fontSize: 13,
              //             fontWeight: FontWeight.bold
              //         ),),
              //       ))),
              //
              //     ],
              //     rows:
              //     List.generate(
              //         math.min(itemsPerPage, filteredData.length - (currentPage - 1) * itemsPerPage),(index){
              //       final detail = filteredData.skip((currentPage - 1) * itemsPerPage).elementAt(index);
              //       final isSelected = _selectedProduct == detail;
              //       // final isSelected = _selectedProduct == detail;
              //       //final product = filteredData[(currentPage - 1) * itemsPerPage + index];
              //       return DataRow(
              //           color: MaterialStateProperty.resolveWith<Color>((states) {
              //             if (states.contains(MaterialState.hovered)) {
              //               return Colors.blue.shade500.withOpacity(0.8); // Add some opacity to the dark blue
              //             } else {
              //               return Colors.white.withOpacity(0.9);
              //             }
              //           }),
              //           cells:
              //           [
              //             DataCell(
              //                 Padding(
              //                   padding: const EdgeInsets.only(left: 5),
              //                   child: Text(detail.deliveryId!,style:
              //                   TextStyle(
              //                     // fontSize: 16,
              //                       color: Colors.grey),),
              //                 )),
              //             DataCell(
              //                 Text(detail.contactPerson!, style: TextStyle(
              //                   //fontSize: 16,
              //                   color:Colors.grey,),)),
              //
              //             DataCell(
              //               Padding(
              //                 padding: const EdgeInsets.only(left: 2),
              //                 child: Text(detail.modifiedAt!,style: TextStyle(
              //                   // fontSize: 16,
              //                     color: Colors.grey)),
              //               ),
              //             ),
              //
              //             DataCell(
              //               Padding(
              //                 padding: const EdgeInsets.only(left: 13),
              //                 child: Text(detail.total.toString(),style: TextStyle(
              //                   // fontSize: 16,
              //                     color: Colors.grey)),
              //               ),
              //             ),
              //             DataCell(
              //               Padding(
              //                 padding: const EdgeInsets.only(left: 10),
              //                 child: Text(detail.deliveryStatus,style: TextStyle(
              //                   //fontSize: 16,
              //                     color: detail.deliveryStatus == "In Progress" ? Colors.orange
              //                         :
              //                     detail.deliveryStatus == "Delivered" ? Colors.green: Colors.grey)),
              //               ),
              //             ),
              //
              //             DataCell(
              //               Padding(
              //                 padding: const EdgeInsets.only(left: 10),
              //                 child: Text(detail.deliveryStatus,style: TextStyle(
              //                   //fontSize: 16,
              //                     color: detail.deliveryStatus == "In Progress" ? Colors.orange
              //                         :
              //                     detail.deliveryStatus == "Delivered" ? Colors.green: Colors.grey)),
              //               ),
              //             ),
              //             DataCell(
              //               Padding(
              //                 padding: const EdgeInsets.only(left: 10),
              //                 child: Text(detail.deliveryStatus,style: TextStyle(
              //                   //fontSize: 16,
              //                     color: detail.deliveryStatus == "In Progress" ? Colors.orange
              //                         :
              //                     detail.deliveryStatus == "Delivered" ? Colors.green: Colors.grey)),
              //               ),
              //             ),
              //
              //           ],
              //           onSelectChanged: (selected){
              //             if(selected != null && selected){
              //               //final detail = filteredData[(currentPage - 1) * itemsPerPage + index];
              //
              //               if (filteredData.length <= 9) {
              //                 print(detail.deliveryStatus);
              //                 // Navigator.push(
              //                 //   context,
              //                 //   PageRouteBuilder(
              //                 //     pageBuilder:
              //                 //         (context, animation, secondaryAnimation) =>
              //                 //         DeliveryConfirm(
              //                 //           deliverystatus: detail.deliveryStatus,
              //                 //           deliveryId: detail.deliveryId,),
              //                 //     transitionDuration:
              //                 //     const Duration(milliseconds: 50),
              //                 //     transitionsBuilder: (context, animation,
              //                 //         secondaryAnimation, child) {
              //                 //       return FadeTransition(
              //                 //         opacity: animation,
              //                 //         child: child,
              //                 //       );
              //                 //     },
              //                 //   ),
              //                 // );
              //                 // context.go('/OrdersList', extra: {
              //                 //   'product': detail,
              //                 //   'item': [], // pass an empty list of maps
              //                 //   'body': {},
              //                 //   'itemsList': [], // pass an empty list of maps
              //                 //   'orderDetails': productList.map((detail) => OrderDetail(
              //                 //     orderId: detail.orderId,
              //                 //     orderDate: detail.orderDate, items: [],
              //                 //     // Add other fields as needed
              //                 //   )).toList(),
              //                 // });
              //               } else {
              //                 // Navigator.push(
              //                 //   context,
              //                 //   PageRouteBuilder(
              //                 //     pageBuilder:
              //                 //         (context, animation, secondaryAnimation) => DeliveryConfirm(
              //                 //       deliverystatus: detail.deliveryStatus,
              //                 //       deliveryId: detail.deliveryId,),
              //                 //     transitionDuration:
              //                 //     const Duration(milliseconds: 50),
              //                 //     transitionsBuilder: (context, animation,
              //                 //         secondaryAnimation, child) {
              //                 //       return FadeTransition(
              //                 //         opacity: animation,
              //                 //         child: child,
              //                 //       );
              //                 //     },
              //                 //   ),
              //                 // );
              //
              //
              //               };
              //               // context.go('/OrdersList', extra: {
              //               //   'product': detail,
              //               //   'item': [], // pass an empty list of maps
              //               //   'body': {},
              //               //   'itemsList': [], // pass an empty list of maps
              //               //   'orderDetails':filteredData.map((detail) => OrderDetail(
              //               //     orderId: detail.orderId,
              //               //     orderDate: detail.orderDate, items: [],
              //               //     // Add other fields as needed
              //               //   )).toList(),
              //               // });
              //             }
              //           }
              //       );
              //     })
              //   // List.generate(
              //   //   5, // number of rows
              //   //       (index) {
              //   //     return DataRow(
              //   //       cells: [
              //   //         DataCell(Text('ORD_000 ${index + 1}')),
              //   //         DataCell(Padding(
              //   //           padding: const EdgeInsets.only(left: 25),
              //   //           child: Text('26/08/2024'),
              //   //         )),
              //   //         DataCell(Padding(
              //   //           padding: const EdgeInsets.only(left: 15),
              //   //           child: Text('INV_000${index + 1}'),
              //   //         )),
              //   //         DataCell(Padding(
              //   //           padding: const EdgeInsets.only(left: 5),
              //   //           child: Text('26/08/2024'),
              //   //         )),
              //   //         DataCell(Padding(
              //   //           padding: const EdgeInsets.only(left: 25),
              //   //           child: Text('UPI'),
              //   //         )),
              //   //         DataCell(Padding(
              //   //           padding: const EdgeInsets.only(left: 15),
              //   //           child: Text('Success'),
              //   //         )),
              //   //         DataCell(Padding(
              //   //           padding: const EdgeInsets.only(left: 5),
              //   //           child: Text('10000'),
              //   //         )),
              //   //       ],
              //   //     );
              //   //   },
              //   // ),
              //
              // ),
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
        padding: EdgeInsets.only(top: Height * 0.100,bottom: Height * 0.100,left: width * 0.300),
        child: CustomLoadingIcon(), // Replace this with your custom GIF widget
      );
    }

    if (filteredData.isEmpty) {
    //  String? role = Provider.of<UserRoleProvider>(context).role;
      double right = MediaQuery.of(context).size.width;
      return
        Column(
          children: [
            Container(
              width: right * 0.81,

              decoration:const BoxDecoration(
                  color: Color(0xFFF7F7F7),
                  border: Border.symmetric(horizontal: BorderSide(color: Colors.grey,width: 0.5))
              ),
              child:

              DataTable(
                  showCheckboxColumn: false,
                  headingRowHeight: 40,
                  columns: [
                    DataColumn(label: Container(child: const Text('      '))),
                    DataColumn(
                      label: Container(
                        child: Text(
                          'Invoice No',
                          style: TextStyle(
                            color: Colors.indigo[900],
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Container(
                        child: Text(
                          'Date',
                          style: TextStyle(
                            color: Colors.indigo[900],
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Container(
                        child: Text(
                          'Order ID',
                          style: TextStyle(
                            color: Colors.indigo[900],
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Container(
                        child: Text(
                          'Location',
                          style: TextStyle(
                            color: Colors.indigo[900],
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Container(
                        child: Text(
                          'Status',
                          style: TextStyle(
                            color: Colors.indigo[900],
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Container(
                        child: Text(
                          'Amount',
                          style: TextStyle(
                            color: Colors.indigo[900],
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                  rows: []

              ),

            ),
            Padding(
              padding: const EdgeInsets.only(top: 150,left: 130,bottom: 350,right: 150),
              child: CustomDatafound(),
            ),
          ],
        );

    }


    void _sortProducts(int columnIndex, String sortDirection) {
      if (sortDirection == 'asc') {
        filteredData.sort((a, b) {
          if (columnIndex == 1) {
            return a.InvNo!.compareTo(b.InvNo!);
          } else if (columnIndex == 2) {
            return a.orderDate!.compareTo(b.orderDate!);
          } else if (columnIndex == 3) {
            return a.orderId!.compareTo(b.orderId!);
          } else if (columnIndex == 4) {
            return a.deliveryLocation!.toLowerCase().compareTo(b.deliveryLocation!.toLowerCase());
          } else if (columnIndex == 5) {
            return a.status!.compareTo(b.status!);
          }
          else if (columnIndex == 6) {
            return a.total!.compareTo(b.total!);
          } else {
            return 0;
          }
        });
      } else {
        filteredData.sort((a, b) {
          if (columnIndex == 1) {
            return b.InvNo!.compareTo(a.InvNo!); // Reverse the comparison
          } else if (columnIndex == 2) {
            return b.orderDate!.compareTo(a.orderDate!); // Reverse the comparison
          } else if (columnIndex == 3) {
            return b.orderId!.compareTo(a.orderId!); // Reverse the comparison
          } else if (columnIndex == 4) {
            return b.deliveryLocation!.toLowerCase().compareTo(a.deliveryLocation!.toLowerCase()); // Reverse the comparison
          } else if (columnIndex == 5) {
            return b.status!.compareTo(a.status!); // Reverse the comparison
          }
          else if (columnIndex == 6) {
            return b.total!.compareTo(a.total!); // Reverse the comparison
          }else {
            return 0;
          }
        });
      }
      setState(() {});
    }


    return LayoutBuilder(builder: (context, constraints){
      // double padding = constraints.maxWidth * 0.065;
    //  String? role = Provider.of<UserRoleProvider>(context).role;
      double right = MediaQuery.of(context).size.width;

      return
        Column(
          children: [
            Container(
                width: right - 200,

              decoration:const BoxDecoration(
                  color: Color(0xFFF7F7F7),
                  border: Border.symmetric(horizontal: BorderSide(color: Colors.grey,width: 0.5))
              ),
              child:
              DataTable(
                showCheckboxColumn: false,
                headingRowHeight: 40,
                columnSpacing: 35,
                columns: columns.map((column) {
                  return
                 DataColumn(
                      label: Stack(
                        children: [
                          Container(
                            //   padding: EdgeInsets.only(left: 5,right: 5),
                            width: columnWidths[columns.indexOf(column)], // Dynamic width based on user interaction
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
                                      icon: _sortOrder[columns.indexOf(column)] == 'asc'
                                          ? SizedBox(width: 12,
                                          child: Image.asset("images/sort.png",color: Colors.grey,))
                                          : SizedBox(width: 12,child: Image.asset("images/sort.png",color: Colors.blue,)),
                                      onPressed: () {
                                        setState(() {
                                          _sortOrder[columns.indexOf(column)] = _sortOrder[columns.indexOf(column)] == 'asc' ? 'desc' : 'asc';
                                          _sortProducts(columns.indexOf(column), _sortOrder[columns.indexOf(column)]);
                                        });
                                      },
                                    ),

                                if (columns.indexOf(column) < columns.length - 1)
                                  Spacer(),
                                if (columns.indexOf(column) < columns.length - 1)
                                  MouseRegion(
                                    cursor: SystemMouseCursors.resizeColumn,
                                    child: GestureDetector(
                                        onHorizontalDragUpdate: (details) {
                                          // Update column width dynamically as user drags
                                          setState(() {
                                            columnWidths[columns.indexOf(column)] += details.delta.dx;
                                            columnWidths[columns.indexOf(column)] =
                                                columnWidths[columns.indexOf(column)].clamp(136.0, 300.0);
                                          });
                                        },
                                        child: const Padding(
                                          padding: EdgeInsets.only(top: 10,bottom: 10),
                                          child: Row(
                                            children: [
                                              VerticalDivider(
                                                width: 5,
                                                thickness: 4,
                                                color: Colors.grey,

                                              )
                                            ],
                                          ),
                                        )
                                    ),
                                  ),
                                // ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      onSort: (columnIndex, ascending){
                        _sortOrder;
                      },
                    ) ;
                }).toList(),
                rows: List.generate(
                  math.min(itemsPerPage, filteredData.length - (currentPage - 1) * itemsPerPage),
                      (index) {

                    final detail = filteredData.skip((currentPage - 1) * itemsPerPage).elementAt(index);
                    print('detail');
                    print(detail);
                    final isSelected = _selectedProduct == detail;
                    return DataRow(
                      color: MaterialStateProperty.resolveWith<Color>((states) {
                        if (states.contains(MaterialState.hovered)) {
                          return Colors.blue.shade500.withOpacity(0.8); // Dark blue with opacity
                        } else if (isSelected) {
                          return Colors.blue.shade100.withOpacity(0.8); // Green with opacity for selected row
                        } else {
                          return Colors.white.withOpacity(0.9);
                        }
                      }),
                      cells: [
                        DataCell(
                          Text(
                            detail.InvNo!,
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ),
                        DataCell(
                          Text(
                            detail.orderDate!,
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ),
                        DataCell(
                          Text(
                            detail.orderId!,
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ),
                        DataCell(
                          Text(
                            detail.status.toString(),
                            style: TextStyle(
                                color: detail.status == "In Progress" ? Colors.orange : detail.status == "Delivered" ? Colors.green : Colors.red
                            ),
                          ),
                        ),
                        DataCell(
                          Text(
                            detail.total.toString(),
                            style: const TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                        ),
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
                                  downloadPdf(detail.orderId!);
                                },
                              ),
                            ],
                          ),
                        ),
                      ],

                    );
                  },
                ),
              )

              // DataTable(
              //     showCheckboxColumn: false,
              //     headingRowHeight: 40,
              //     columns: [
              //       DataColumn(label: Container(child: Padding(
              //         padding: const EdgeInsets.only(left: 10),
              //         child: Text('Order ID',style:TextStyle(
              //             color: Colors.indigo[900],
              //             fontSize: 13,
              //             fontWeight: FontWeight.bold
              //         ),),
              //       ))),
              //       DataColumn(label: Container(
              //           child: Padding(
              //             padding: const EdgeInsets.only(left: 20),
              //             child: Text('Delivered Date',style:TextStyle(
              //                 color: Colors.indigo[900],
              //                 fontSize: 13,
              //                 fontWeight: FontWeight.bold
              //             ),),
              //           ))),
              //       DataColumn(label: Container(child: Text(
              //         'Invoice Number',style:TextStyle(
              //           color: Colors.indigo[900],
              //           fontSize: 13,
              //           fontWeight: FontWeight.bold
              //       ),))),
              //       DataColumn(label: Container(child: Text(
              //         'Payment Date',style:TextStyle(
              //           color: Colors.indigo[900],
              //           fontSize: 13,
              //           fontWeight: FontWeight.bold
              //       ),))),
              //       DataColumn(label: Container(child: Text(
              //         'Payment Mode',style:  TextStyle(
              //
              //           color: Colors.indigo[900],
              //           fontSize: 13,
              //           fontWeight: FontWeight.bold
              //       ),))),
              //       DataColumn(label: Container(child: Text(
              //         'Payment Status',style:  TextStyle(
              //
              //           color: Colors.indigo[900],
              //           fontSize: 13,
              //           fontWeight: FontWeight.bold
              //       ),))),
              //       DataColumn(label: Container(child: Padding(
              //         padding: const EdgeInsets.only(right: 50),
              //         child: Text(
              //           'Amount',style:  TextStyle(
              //
              //             color: Colors.indigo[900],
              //             fontSize: 13,
              //             fontWeight: FontWeight.bold
              //         ),),
              //       ))),
              //
              //     ],
              //     rows:
              //     List.generate(
              //         math.min(itemsPerPage, filteredData.length - (currentPage - 1) * itemsPerPage),(index){
              //       final detail = filteredData.skip((currentPage - 1) * itemsPerPage).elementAt(index);
              //       final isSelected = _selectedProduct == detail;
              //       // final isSelected = _selectedProduct == detail;
              //       //final product = filteredData[(currentPage - 1) * itemsPerPage + index];
              //       return DataRow(
              //           color: MaterialStateProperty.resolveWith<Color>((states) {
              //             if (states.contains(MaterialState.hovered)) {
              //               return Colors.blue.shade500.withOpacity(0.8); // Add some opacity to the dark blue
              //             } else {
              //               return Colors.white.withOpacity(0.9);
              //             }
              //           }),
              //           cells:
              //           [
              //             DataCell(
              //                 Padding(
              //                   padding: const EdgeInsets.only(left: 5),
              //                   child: Text(detail.deliveryId!,style:
              //                   TextStyle(
              //                     // fontSize: 16,
              //                       color: Colors.grey),),
              //                 )),
              //             DataCell(
              //                 Text(detail.contactPerson!, style: TextStyle(
              //                   //fontSize: 16,
              //                   color:Colors.grey,),)),
              //
              //             DataCell(
              //               Padding(
              //                 padding: const EdgeInsets.only(left: 2),
              //                 child: Text(detail.modifiedAt!,style: TextStyle(
              //                   // fontSize: 16,
              //                     color: Colors.grey)),
              //               ),
              //             ),
              //
              //             DataCell(
              //               Padding(
              //                 padding: const EdgeInsets.only(left: 13),
              //                 child: Text(detail.total.toString(),style: TextStyle(
              //                   // fontSize: 16,
              //                     color: Colors.grey)),
              //               ),
              //             ),
              //             DataCell(
              //               Padding(
              //                 padding: const EdgeInsets.only(left: 10),
              //                 child: Text(detail.deliveryStatus,style: TextStyle(
              //                   //fontSize: 16,
              //                     color: detail.deliveryStatus == "In Progress" ? Colors.orange
              //                         :
              //                     detail.deliveryStatus == "Delivered" ? Colors.green: Colors.grey)),
              //               ),
              //             ),
              //
              //             DataCell(
              //               Padding(
              //                 padding: const EdgeInsets.only(left: 10),
              //                 child: Text(detail.deliveryStatus,style: TextStyle(
              //                   //fontSize: 16,
              //                     color: detail.deliveryStatus == "In Progress" ? Colors.orange
              //                         :
              //                     detail.deliveryStatus == "Delivered" ? Colors.green: Colors.grey)),
              //               ),
              //             ),
              //             DataCell(
              //               Padding(
              //                 padding: const EdgeInsets.only(left: 10),
              //                 child: Text(detail.deliveryStatus,style: TextStyle(
              //                   //fontSize: 16,
              //                     color: detail.deliveryStatus == "In Progress" ? Colors.orange
              //                         :
              //                     detail.deliveryStatus == "Delivered" ? Colors.green: Colors.grey)),
              //               ),
              //             ),
              //
              //           ],
              //           onSelectChanged: (selected){
              //             if(selected != null && selected){
              //               //final detail = filteredData[(currentPage - 1) * itemsPerPage + index];
              //
              //               if (filteredData.length <= 9) {
              //                 print(detail.deliveryStatus);
              //                 // Navigator.push(
              //                 //   context,
              //                 //   PageRouteBuilder(
              //                 //     pageBuilder:
              //                 //         (context, animation, secondaryAnimation) =>
              //                 //         DeliveryConfirm(
              //                 //           deliverystatus: detail.deliveryStatus,
              //                 //           deliveryId: detail.deliveryId,),
              //                 //     transitionDuration:
              //                 //     const Duration(milliseconds: 50),
              //                 //     transitionsBuilder: (context, animation,
              //                 //         secondaryAnimation, child) {
              //                 //       return FadeTransition(
              //                 //         opacity: animation,
              //                 //         child: child,
              //                 //       );
              //                 //     },
              //                 //   ),
              //                 // );
              //                 // context.go('/OrdersList', extra: {
              //                 //   'product': detail,
              //                 //   'item': [], // pass an empty list of maps
              //                 //   'body': {},
              //                 //   'itemsList': [], // pass an empty list of maps
              //                 //   'orderDetails': productList.map((detail) => OrderDetail(
              //                 //     orderId: detail.orderId,
              //                 //     orderDate: detail.orderDate, items: [],
              //                 //     // Add other fields as needed
              //                 //   )).toList(),
              //                 // });
              //               } else {
              //                 // Navigator.push(
              //                 //   context,
              //                 //   PageRouteBuilder(
              //                 //     pageBuilder:
              //                 //         (context, animation, secondaryAnimation) => DeliveryConfirm(
              //                 //       deliverystatus: detail.deliveryStatus,
              //                 //       deliveryId: detail.deliveryId,),
              //                 //     transitionDuration:
              //                 //     const Duration(milliseconds: 50),
              //                 //     transitionsBuilder: (context, animation,
              //                 //         secondaryAnimation, child) {
              //                 //       return FadeTransition(
              //                 //         opacity: animation,
              //                 //         child: child,
              //                 //       );
              //                 //     },
              //                 //   ),
              //                 // );
              //
              //
              //               };
              //               // context.go('/OrdersList', extra: {
              //               //   'product': detail,
              //               //   'item': [], // pass an empty list of maps
              //               //   'body': {},
              //               //   'itemsList': [], // pass an empty list of maps
              //               //   'orderDetails':filteredData.map((detail) => OrderDetail(
              //               //     orderId: detail.orderId,
              //               //     orderDate: detail.orderDate, items: [],
              //               //     // Add other fields as needed
              //               //   )).toList(),
              //               // });
              //             }
              //           }
              //       );
              //     })
              //   // List.generate(
              //   //   5, // number of rows
              //   //       (index) {
              //   //     return DataRow(
              //   //       cells: [
              //   //         DataCell(Text('ORD_000 ${index + 1}')),
              //   //         DataCell(Padding(
              //   //           padding: const EdgeInsets.only(left: 25),
              //   //           child: Text('26/08/2024'),
              //   //         )),
              //   //         DataCell(Padding(
              //   //           padding: const EdgeInsets.only(left: 15),
              //   //           child: Text('INV_000${index + 1}'),
              //   //         )),
              //   //         DataCell(Padding(
              //   //           padding: const EdgeInsets.only(left: 5),
              //   //           child: Text('26/08/2024'),
              //   //         )),
              //   //         DataCell(Padding(
              //   //           padding: const EdgeInsets.only(left: 25),
              //   //           child: Text('UPI'),
              //   //         )),
              //   //         DataCell(Padding(
              //   //           padding: const EdgeInsets.only(left: 15),
              //   //           child: Text('Success'),
              //   //         )),
              //   //         DataCell(Padding(
              //   //           padding: const EdgeInsets.only(left: 5),
              //   //           child: Text('10000'),
              //   //         )),
              //   //       ],
              //   //     );
              //   //   },
              //   // ),
              //
              // ),
            ),
          ],
        );
    });
  }

  void _filterAndPaginateProducts() {
    filteredData = productList.where((product) {
      final matchesSearchText= product.orderId!.toLowerCase().contains(_searchText.toLowerCase());
      print('-----');
      print(product.orderDate);
      String orderYear = '';
      if (product.orderDate!.contains('/')) {
        final dateParts = product.orderDate!.split('/');
        if (dateParts.length == 3) {
          orderYear = dateParts[2]; // Extract the year
        }
      }
      // final orderYear = element.orderDate.substring(5,9);
      if (status.isEmpty && selectDate.isEmpty) {
        return matchesSearchText; // Include all products that match the search text
      }
      if(status == 'Status' && selectDate == 'Select Year'){
        return matchesSearchText;
      }
      if(status == 'Status' &&  selectDate.isEmpty)
      {
        return matchesSearchText;
      }
      if(selectDate == 'Select Year' &&  status.isEmpty)
      {
        return matchesSearchText;
      }
      if (status == 'Status' && selectDate.isNotEmpty) {
        return matchesSearchText && orderYear == selectDate; // Include all products
      }
      if (status.isNotEmpty && selectDate == 'Select Year') {
        return matchesSearchText && product.status == status;// Include all products
      }
      if (status.isEmpty && selectDate.isNotEmpty) {
        return matchesSearchText && orderYear == selectDate; // Include all products
      }//this one

      if (status.isNotEmpty && selectDate.isEmpty) {
        return matchesSearchText && product.status == status;// Include all products
      }
      return matchesSearchText &&
          (product.status == status && orderYear == selectDate);
      //  return false;
    }).toList();
    totalPages = (filteredData.length / itemsPerPage).ceil();

    //   filteredData.sort((a, b) => a.orderId)
    setState(() {
      currentPage = 1;
    });

  }

}



// class OrderDetail {
//   String? orderId;
//   String? orderDate;
//   String? referenceNumber;
//   double? total;
//   String? deliveryStatus;
//   String? status;
//   String? orderCategory;
//   final String? deliveryLocation;
//   final String? deliveryAddress;
//   final String? contactPerson;
//   final String? contactNumber;
//   final String? comments;
//   final List<dynamic> items;
//   String? InvNo;
//
//   OrderDetail({
//     this.orderId,
//     this.orderDate,
//     this.orderCategory,
//     this.referenceNumber,
//     this.total,
//     this.deliveryStatus,
//     this.status,
//     this.deliveryLocation,
//     this.deliveryAddress,
//     this.contactPerson,
//     this.contactNumber,
//     this.comments,
//     this.InvNo,
//     required this.items,
//   });
//
//   factory OrderDetail.fromJson(Map<String, dynamic> json) {
//     return OrderDetail(
//       orderId: json['orderId'] ?? '',
//       orderCategory: json['orderCategory'] ?? '',
//       orderDate: json['orderDate'] ?? 'Unknown date',
//       total: json['total'].round() ?? 0.0,
//       status: json['status'] ?? '',
//       // Dummy value
//       deliveryStatus: 'Not Started' ?? '',
//       // Dummy value
//       referenceNumber: '  ', // Dummy value
//       deliveryLocation: json['deliveryLocation'],
//       deliveryAddress: json['deliveryAddress'],
//       contactPerson: json['contactPerson'],
//       contactNumber: json['contactNumber'],
//       comments: json['comments'],
//       items: json['items'],
//       InvNo: json['invoiceNo'],
//     );
//   }
//
//   factory OrderDetail.fromString(String jsonString) {
//     final jsonMap = jsonDecode(jsonString);
//     return OrderDetail.fromJson(jsonMap);
//   }
//
//   @override
//   String toString() {
//     return 'Order ID: $orderId, Order Date: $orderDate, Total: $total, Status: $status, Delivery Status: $deliveryStatus, Reference Number: $referenceNumber';
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
//
//     });
//   }
// }

