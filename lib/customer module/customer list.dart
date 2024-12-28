import 'dart:async';
import 'dart:convert';
import 'dart:html';
import 'dart:math'as math;
import 'dart:typed_data';
import 'package:adaptive_scrollbar/adaptive_scrollbar.dart';
import 'package:btb/admin/Api%20name.dart';
import 'package:btb/customer%20module/create%20customer.dart';
import 'package:btb/widgets/confirmdialog.dart';
import 'package:btb/widgets/pagination.dart';
import 'package:btb/widgets/productclass.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import '../Order Module/firstpage.dart';
import '../dashboard/dashboard.dart';
import '../pdf/credit memo pdf.dart';
import '../pdf/delivery note pdf.dart';
import '../pdf/invoice pdf.dart';
import '../pdf/order bill pdf.dart';
import 'dart:html' as html;
import '../widgets/custom loading.dart';
import '../widgets/no datafound.dart';
import '../widgets/productsap.dart' as ord;
import '../widgets/text_style.dart';
import 'customer view.dart';

void main(){
  runApp( const CusList());
}


class CusList extends StatefulWidget {
  const CusList({super.key});
  @override
  State<CusList> createState() => _CusListState();
}
class _CusListState extends State<CusList> {
  bool _hasShownPopup = false;
  bool _isCustomerExpanded = false;
  List<String> statusOptions = ['Order', 'Invoice', 'Delivery', 'Payment'];
  Timer? _searchDebounceTimer;
  String _searchText = '';
  bool isOrdersSelected = false;
  bool _loading = false;
  detail? _selectedProduct;
  DateTime? _selectedDate;
  late TextEditingController _dateController;
  Map<String, dynamic> PaymentMap = {};
  int startIndex = 0;
  String location = '';
  String Name = '';
  List<Product> filteredProducts = [];
  int currentPage = 1;
  String? dropdownValue1 = 'Status';
  late Future<List<ord.BusinessPartnerData>> futureOrders;
  List<ord.BusinessPartnerData> productList = [];
  final ScrollController _scrollController = ScrollController();
  List<dynamic> detailJson = [];
  String searchQuery = '';
  List<ord.BusinessPartnerData>filteredData = [];
  String status = '';
  String selectDate = '';
  final ScrollController horizontalScroll = ScrollController();

  String token = window.sessionStorage["token"] ?? " ";
  String? dropdownValue2 = 'Select Year';
  List<String> _sortOrder = List.generate(6, (index) => 'asc');
  List<String> columns = ['Customer ID','Customer Name','City','Mobile Number','Email ID'];
  List<double> columnWidths = [130, 145, 139, 160, 135,];
  List<bool> columnSortState = [true, true, true,true,true];


  void _onSearchTextChanged(String text) {
    if (_searchDebounceTimer != null) {
      _searchDebounceTimer!.cancel(); //  Cancel the previous timer
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
  // Future downloadCreditMemoPdf(String orderId) async {
  //   final String orderId1 = orderId;
  //   try {
  //     final productMasterData = await _fetchAllpayProductMaster();
  //     final orderDetails = await _fetchpayOrderDetails(orderId1);
  //     for (var product in productMasterData) {
  //       for (var item in orderDetails!.items) {
  //         if (product['productName'] == item['productName']) {
  //           item['tax'] = product['tax'];
  //           item['discount'] = product['discount'];
  //           item['discountamount'] = (double.parse(item['totalAmount'].toString()) * double.parse(item['discount'].replaceAll('%', ''))) / 100;
  //           item['taxamount'] = ((double.parse(item['totalAmount'].toString()) -
  //               double.parse(item['discountamount'].toString())) *
  //               double.parse(item['tax'].replaceAll('%', '').toString())) / 100;
  //         }
  //       }
  //     }
  //
  //     if (orderDetails != null) {
  //       final Uint8List pdfBytes = await CreditMemoPdf(orderDetails);
  //       final blob = html.Blob([pdfBytes]);
  //       final url = html.Url.createObjectUrlFromBlob(blob);
  //       final anchor = html.AnchorElement(href: url)
  //         ..setAttribute('download', 'Credit_Memo.pdf')
  //         ..click();
  //       html.Url.revokeObjectUrl(url);
  //     } else {
  //     }
  //   } catch (e) {
  //   }
  // }

  Future downloadinvoicePdf(String orderId) async {
    final String orderId1 = orderId;
    try {
      final productMasterData = await _fetchAllinvoiceProductMaster();
      final orderDetails = await _fetchinvoiceOrderDetails(orderId1);
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
      }
    } catch (e) {
    }
  }
  Future<List<dynamic>> _fetchAllinvoiceProductMaster() async {
    //  final String token = 'eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJkaGFuYXNla2FyIiwiUm9sZXMiOlt7ImF1dGhvcml0eSI6ImRldmVsb3BlciJ9XSwiZXhwIjoxNzIzMTE0OTQ0LCJpYXQiOjE3MjMxMDc3NDR9.1UxLslHM3GivBHoBr8pS02OxD6dC5IRG4ryxiUdgzIJmFjSCwftf6Kme4rPLb-ZOjzOoAaxueSzKxiLmjnmSFg';
    try {
      final response = await http.get(
        Uri.parse('$apicall/productmaster/get_all_productmaster'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // print('discount');
        // print(data['discount']);
        return data;
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }
  Future<OrderDetail?> _fetchinvoiceOrderDetails(String orderId) async {
    // String token = 'eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJkaGFuYXNla2FyIiwiUm9sZXMiOlt7ImF1dGhvcml0eSI6ImRldmVsb3BlciJ9XSwiZXhwIjoxNzI1NjA2NjA5LCJpYXQiOjE3MjU1OTk0MDl9.a0XS5AykjKk62PBbfGessANRveTtU5wawjPRnHj73Zi1t-Xh3b2-2G_CksANLOaANHiy-4AlsCYwOZFY8GmExA';
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
        final jsonData = jsonDecode(responseBody);
        if (jsonData is List<dynamic>) {
          final jsonObject = jsonData.first;
          return OrderDetail.fromJson(jsonObject);
        }
        else {
        }
      } else {
      }
    } catch (e) {
    }
    return null;
  }


  Map<String, bool> _isHovered = {
    'Home': false,
    'Customer': false,
    'Products': false,
    'Orders': false,
  };


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
              child: _buildMenuItem(
                  'Customer', Icons.account_circle_outlined, Colors.white, '/Customer')),
          SizedBox(height: 6,),
          _buildMenuItem(
              'Orders', Icons.warehouse_outlined, Colors.blue[900]!, '/Order_List'),
        ],
      ),
      const SizedBox(
        height: 6,
      ),



    ];
  }

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


  Future downloaddelPdf(String orderId) async {
    final String orderId1 = orderId;

    final productMasterData = await _fetchAlldelProductMaster();
    final orderDetails = await _fetchdelOrderDetails(orderId1);
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
      final Uint8List pdfBytes = await Deliverypdf(orderDetails);
      final blob = html.Blob([pdfBytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download', 'Delivery_Note.pdf')
        ..click();
      html.Url.revokeObjectUrl(url);
    } else {
    }

  }
  Future<List<dynamic>> _fetchAlldelProductMaster() async {
    // final String token = 'eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJkaGFuYXNla2FyIiwiUm9sZXMiOlt7ImF1dGhvcml0eSI6ImRldmVsb3BlciJ9XSwiZXhwIjoxNzIzMjY4MDk4LCJpYXQiOjE3MjMyNjA4OTh9.GA66i8d7RzYDeZbElDpkHe0EdlBNCKZweQjwTcaMI3HPP1W_b43YKgSqomohzFXsYV-JAAVGY-6yfRT_B2l3sg';
    try {
      final response = await http.get(
        Uri.parse('$apicall/productmaster/get_all_productmaster'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // print('discount');
        // print(data['discount']);
        return data;
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }
  Future<OrderDetail?> _fetchdelOrderDetails(String orderId) async {
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
      final jsonData = jsonDecode(responseBody);
      if (jsonData is List<dynamic>) {
        final jsonObject = jsonData.first;
        return OrderDetail.fromJson(jsonObject);
      } else {
      }
    } else {
    }

    return null;
  }
  Future downloadPdf(String orderId) async {
    final String orderId1 = orderId;
    try {
      final productMasterData = await _fetchAllProductMaster();
      final orderDetails = await _fetchOrderDetails(orderId1);
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
        final Uint8List pdfBytes = await OrderBillPdf(orderDetails);
        final blob = html.Blob([pdfBytes]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute('download', 'Order Bill.pdf')
          ..click();
        html.Url.revokeObjectUrl(url);
      } else {
      }
    } catch (e) {
    }
  }

  Future<List<dynamic>> _fetchAllProductMaster() async {
    // final String token = 'eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJkaGFuYXNla2FyIiwiUm9sZXMiOlt7ImF1dGhvcml0eSI6ImRldmVsb3BlciJ9XSwiZXhwIjoxNzI0ODMyMjUzLCJpYXQiOjE3MjQ4MjUwNTN9.-HLZdMO9251y0hm5saV5EP4YBu6JKJgtZKiEahCLcw5OKNuSIUaTTZ1vtKnwYj4SgQMoHMpu8dZihvNUTYv3Ig';
    try {
      final response = await http.get(
        Uri.parse('$apicall/productmaster/get_all_productmaster'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // print('discount');
        // print(data['discount']);
        return data;
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  Future<OrderDetail?> _fetchOrderDetails(String orderId) async {
    // String token = 'eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJkaGFuYXNla2FyIiwiUm9sZXMiOlt7ImF1dGhvcml0eSI6ImRldmVsb3BlciJ9XSwiZXhwIjoxNzI0ODMyMjUzLCJpYXQiOjE3MjQ4MjUwNTN9.-HLZdMO9251y0hm5saV5EP4YBu6JKJgtZKiEahCLcw5OKNuSIUaTTZ1vtKnwYj4SgQMoHMpu8dZihvNUTYv3Ig';
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
        final jsonData = jsonDecode(responseBody);
        if (jsonData is List<dynamic>) {
          final jsonObject = jsonData.first;
          return OrderDetail.fromJson(jsonObject);
        } else {
        }
      } else {
      }
    } catch (e) {
    }
    return null;
  }


  Future<void> fetchProducts(int page, int itemsPerPage) async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse(
          '$apicall/public/customer_master/get_all_s4hana_customermaster?page=$page&limit=$itemsPerPage',
        ),
        headers: {
          "Content-type": "application/json",
          "Authorization": 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        List<ord.BusinessPartnerData> products = [];

        if (jsonData != null) {
          // Iterate over the response to map the products
          products = jsonData.map<ord.BusinessPartnerData>((item) {
            return ord.BusinessPartnerData(
              customerName: item['customerName'] ?? '',
              businessPartner: item['customer'] ?? '',
              businessPartnerName: '', // Placeholder as it's not in the response
              customer: item['customer'] ?? '',
              addressID: item['addressID'] ?? '',
              cityName: item['cityName'] ?? '',
              postalCode: item['postalCode'] ?? '',
              streetName: item['streetName'] ?? '',
              region: item['region'] ?? '',
              telephoneNumber1: item['telephoneNumber1'] ?? '',
              country: item['country'] ?? '',
              districtName: item['districtName'] ?? '',
              emailAddress: item['emailAddress'] ?? '',
              mobilePhoneNumber: item['mobilePhoneNumber'] ?? '',
            );
          }).toList();

          setState(() {
            productList = products;
            totalPages = (products.length / itemsPerPage).ceil(); // Update total pages
            print(totalPages); // Debugging output
            _filterAndPaginateProducts();
          });
        }
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
      // Optionally, show an error message to the user
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }



  void _filterAndPaginateProducts() {
    filteredData = productList.
    where((product) {
      final matchesSearchText= product.customer.toLowerCase().contains(_searchText.toLowerCase()) || product.customerName.toLowerCase().contains(_searchText.toLowerCase());
      return matchesSearchText;
    }).toList();
    totalPages = (filteredData.length / itemsPerPage).ceil();    setState(() {    currentPage = 1;  });}

  void _updateSearch(String searchText) {
    setState(() {
      _searchText = searchText;
      currentPage = 1;
      _filterAndPaginateProducts();
    });}

  void _updateSearch1(String searchText) {
    setState(() {
      location = searchText;
      currentPage = 1;
      _filterAndPaginateProducts();
    });}

  void _updateSearch2(String searchText) {
    setState(() {
      Name = searchText;
      currentPage = 1;
      _filterAndPaginateProducts();
    });}

  void _goToPreviousPage() {
    if (currentPage > 1) {
      if(filteredData.length > itemsPerPage) {
        setState(() {
          currentPage--;
        });
      }
    }
  }


  void _goToNextPage() {

    if (currentPage < totalPages) {
      if(filteredData.length > currentPage * itemsPerPage) {
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
        backgroundColor: Colors.grey[50],
        body: LayoutBuilder(
            builder: (context,constraints) {
              double maxWidth = constraints.maxWidth;
              double maxHeight = constraints.maxHeight;
              return
                Stack(
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
                    }else ...{
                      Align(
                        alignment: Alignment.topLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 62),
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
                      left: 201,
                      top: 60,
                      right: 0,
                      bottom: 0,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // Center(
                          //   child: Container(
                          //     padding: const EdgeInsets.symmetric(horizontal: 16),
                          //     color: Colors.white,
                          //     height: 50,
                          //     child: Row(
                          //       children: [
                          //         const Padding(
                          //           padding: EdgeInsets.only(left: 20),
                          //           child: Text(
                          //             'Customer List',
                          //             style: TextStyle(
                          //               color: Colors.black,
                          //                 fontSize: 20, fontWeight: FontWeight.bold),
                          //
                          //           ),
                          //         ),
                          //         const Spacer(),
                          //         Align(
                          //           alignment: Alignment.topRight,
                          //           child: Padding(
                          //             padding: const EdgeInsets.only(
                          //                 top: 10, right: 80),
                          //             child: OutlinedButton(
                          //               onPressed: () {
                          //                  context.go('/Create_Cus');
                          //
                          //                 //context.go('/Home/Orders/Create_Order');
                          //               },
                          //               style: OutlinedButton.styleFrom(
                          //                 backgroundColor:
                          //                 Colors.blue[800],
                          //                 // Button background color
                          //                 shape: RoundedRectangleBorder(
                          //                   borderRadius:
                          //                   BorderRadius.circular(
                          //                       5), // Rounded corners
                          //                 ),
                          //                 side: BorderSide.none, // No outline
                          //               ),
                          //               child: const Text(
                          //                 'Create',
                          //                 style: TextStyle(
                          //                   fontSize: 14,
                          //                   fontWeight: FontWeight.w100,
                          //                   color: Colors.white,
                          //                 ),
                          //               ),
                          //             ),
                          //           ),
                          //         ),
                          //         // Align(
                          //         //   alignment: Alignment.topRight,
                          //         //   child: Padding(
                          //         //     padding: const EdgeInsets.only(top: 10, right: 80),
                          //         //     child: MouseRegion(
                          //         //       onEnter: (_) {
                          //         //         setState(() {
                          //         //           _isHovered1 = true;
                          //         //           _controller.forward(); // Start shake animation when hovered
                          //         //         });
                          //         //       },
                          //         //       onExit: (_) {
                          //         //         setState(() {
                          //         //           _isHovered1 = false;
                          //         //           _controller.stop(); // Stop shake animation when not hovered
                          //         //         });
                          //         //       },
                          //         //       child: AnimatedBuilder(
                          //         //           animation: _controller,
                          //         //           builder: (context, child) {
                          //         //             return Transform.translate(offset: Offset(_isHovered1? _shakeAnimation.value : 0,0),
                          //         //               child: AnimatedContainer(
                          //         //                 duration: const Duration(milliseconds: 300),
                          //         //                 curve: Curves.easeInOut,
                          //         //                 decoration: BoxDecoration(
                          //         //                   color: _isHovered1
                          //         //                       ? Colors.blue[800]
                          //         //                       : Colors.blue[800], // Background color change on hover
                          //         //                   borderRadius: BorderRadius.circular(5),
                          //         //                   boxShadow: _isHovered1
                          //         //                       ? [
                          //         //                     const BoxShadow(
                          //         //                         color: Colors.black45,
                          //         //                         blurRadius: 6,
                          //         //                         spreadRadius: 2)
                          //         //                   ]
                          //         //                       : [],
                          //         //                 ),
                          //         //                 child: OutlinedButton(
                          //         //                   onPressed: () {
                          //         //                     context.go('/Create_New_Order');
                          //         //                     //context.go('/Home/Orders/Create_Order');
                          //         //                   },
                          //         //                   style: OutlinedButton.styleFrom(
                          //         //                     backgroundColor: Colors.blue[800],
                          //         //                     shape: RoundedRectangleBorder(
                          //         //                       borderRadius: BorderRadius.circular(
                          //         //                           5), // Rounded corners
                          //         //                     ),
                          //         //                     side: BorderSide.none, // No outline
                          //         //                   ),
                          //         //                   child: const Text(
                          //         //                     'Create',
                          //         //                     style: TextStyle(
                          //         //                       fontSize: 14,
                          //         //                       fontWeight: FontWeight.w100,
                          //         //                       color: Colors.white,
                          //         //                     ),
                          //         //                   ),
                          //         //                 ),
                          //         //               ),
                          //         //             );
                          //         //           }
                          //         //
                          //         //       ),
                          //         //     ),
                          //         //   ),
                          //         // ),
                          //       ],
                          //     ),
                          //   ),
                          // ),
                          // Container(
                          //   margin: const EdgeInsets.only(left: 0),
                          //   // Space above/below the border
                          //   height: 1,
                          //   // width: 10  00,
                          //   width: constraints.maxWidth,
                          //   // Border height
                          //   color: Colors.grey, // Border color
                          // ),
                          if(constraints.maxWidth >= 1350)...{
                            Expanded(
                                child: SingleChildScrollView(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(left: 30,top: 20),
                                            child: Text('Customer List',style: TextStyles.heading,),
                                          ),

                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 30,
                                                  top: 20,
                                                  right: 30,
                                                  bottom: 15,
                                              ),
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
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(left: 30,top: 20),
                                                child: Text('Customer List',style: TextStyles.heading,),
                                              ),

                                            ],
                                          ),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Padding(
                                                  padding: const EdgeInsets.only(
                                                      left: 30,
                                                      top: 20,
                                                      right: 30,
                                                      bottom: 15),
                                                  child: Container(
                                                    height: 755,
                                                    width: 1100,
                                                    decoration:BoxDecoration(
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
                          maxWidth: constraints.maxWidth * 0.265,
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
                            decoration:  InputDecoration(
                                hintText: 'Search by Customer ID or Customer Name',
                                hintStyle: const TextStyle(fontSize: 13,color: Colors.grey),
                                contentPadding: EdgeInsets.symmetric(vertical: 3,horizontal: 5),
                              //  contentPadding: const EdgeInsets.only(bottom: 20,left: 10), // adjusted padding
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
                    DataColumn(label: Text('Customer ID',style:TextStyles.subhead,)),
                    DataColumn(label: Text('Customer Name',style:TextStyles.subhead,)),
                    DataColumn(label: Text(
                      'City',style:TextStyles.subhead,)),
                    DataColumn(label: Text(
                      'Mobile Number',style:TextStyles.subhead,)),
                    DataColumn(label: Text(
                      'Email ID',style:TextStyles.subhead,)),


                  ],
                  rows: const []

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
          if (columnIndex == 0) {
            return a.customer.compareTo(b.customer);
          } else if (columnIndex == 1) {
            return a.businessPartner.compareTo(b.businessPartner);
          } else if (columnIndex == 2) {
            return a.cityName.compareTo(b.cityName);
          } else if (columnIndex == 3) {
            return a.telephoneNumber1.toLowerCase().compareTo(b.telephoneNumber1.toLowerCase());
          } else if (columnIndex == 4) {
            return a.emailAddress.compareTo(b.emailAddress);
          } else {
            return 0;
          }
        });
      } else {
        filteredData.sort((a, b) {
          if (columnIndex == 0) {
            return b.customer!.compareTo(a.customer!); // Reverse the comparison
          } else if (columnIndex == 1) {
            return b.businessPartner.compareTo(a.businessPartner); // Reverse the comparison
          } else if (columnIndex == 2) {
            return b.cityName!.compareTo(a.cityName!); // Reverse the comparison
          } else if (columnIndex == 3) {
            return b.telephoneNumber1!.toLowerCase().compareTo(a.telephoneNumber1!.toLowerCase()); // Reverse the comparison
          } else if (columnIndex == 4) {
            return b.emailAddress!.compareTo(a.emailAddress!); // Reverse the comparison
          } else {
            return 0;
          }
        });
      }
      setState(() {});
    }

    return LayoutBuilder(builder: (context, constraints){
      // double padding = constraints.maxWidth * 0.065;
      double right = MediaQuery.of(context).size.width * 0.92;

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
                                    style: TextStyles.subhead
                                ),

                                IconButton(
                                  icon: _sortOrder[columns.indexOf(column)] == 'asc'
                                      ? SizedBox(
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
                                      _sortOrder[columns.indexOf(column)] = _sortOrder[columns.indexOf(column)] == 'asc' ? 'desc' : 'asc';
                                      _sortProducts(columns.indexOf(column), _sortOrder[columns.indexOf(column)]);
                                    });
                                  },
                                ),
                                //SizedBox(width: 50,),
                                //Padding(
                                //  padding:  EdgeInsets.only(left: columnWidths[index]-50,),

                                // ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      onSort: (columnIndex, ascending){
                        _sortOrder;
                      },
                    );
                }).toList(),
                rows:
                List.generate(
                    math.min(itemsPerPage, filteredData.length - (currentPage - 1) * itemsPerPage),(index){
                  final detail = filteredData.skip((currentPage - 1) * itemsPerPage).elementAt(index);
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
                            Text(detail.customer,   style: TextStyles.body,)),
                        DataCell(
                          Text(detail.customerName,   style: TextStyles.body,),
                        ),
                        DataCell(
                          Text(detail.cityName,   style: TextStyles.body,),
                        ),
                        DataCell(
                          Container(
                            width: columnWidths[3],
                            child: Text(detail.telephoneNumber1.toString(),   style: TextStyles.body,),
                          ),
                        ),
                        DataCell(
                          Text(detail.emailAddress.toString(),   style: TextStyles.body,),
                        ),
                      ],
                      onSelectChanged: (selected){
                        if(selected != null && selected){
                          //final detail = filteredData[(currentPage - 1) * itemsPerPage + index];
                          if (filteredData.length <= 9) {
                            context.go('/Cus_Details',extra:{
                              'orderId': detail.customer
                            });
                          } else {
                            context.go('/Cus_Details',extra:{
                              'orderId': detail.customer
                            });

                          };
                        }
                      }

                  );
                }),
              ),
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
      double right = MediaQuery.of(context).size.width;
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
                    DataColumn(label: Text('Customer ID',style:TextStyles.subhead,)),
                    DataColumn(label: Text('Customer Name',style:TextStyles.subhead,)),
                    DataColumn(label: Text(
                      'City',style:TextStyles.subhead,)),
                    DataColumn(label: Text(
                      'Mobile Number',style:TextStyles.subhead,)),
                    DataColumn(label: Text(
                      'Email ID',style:TextStyles.subhead,)),


                  ],
                  rows: const []

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
          if (columnIndex == 0) {
            return a.customer!.compareTo(b.customer!);
          } else if (columnIndex == 1) {
            return a.businessPartner!.compareTo(b.businessPartner!);
          } else if (columnIndex == 2) {
            return a.cityName!.compareTo(b.cityName!);

          } else if (columnIndex == 3) {
            return a.telephoneNumber1!.compareTo(b.telephoneNumber1!);

          } else if (columnIndex == 4) {
            return a.emailAddress!.toLowerCase().compareTo(b.emailAddress!.toLowerCase());
          } else {
            return 0;
          }
        });
      } else {
        filteredData.sort((a, b) {
          if (columnIndex == 0) {
            return b.customer!.compareTo(a.customer!); // Reverse the comparison
          } else if (columnIndex == 1) {
            return b.businessPartner!.compareTo(a.businessPartner!); // Reverse the comparison
          } else if (columnIndex == 2) {
            return b.cityName!.compareTo(a.cityName!); // Reverse the comparison
          } else if (columnIndex == 3) {
            return b.telephoneNumber1!.toLowerCase().compareTo(a.telephoneNumber1!.toLowerCase()); // Reverse the comparison
          } else if (columnIndex == 4) {
            return b.emailAddress!.compareTo(a.emailAddress!); // Reverse the comparison
          } else {
            return 0;
          }
        });
      }
      setState(() {});
    }

    return LayoutBuilder(builder: (context, constraints){
      // double padding = constraints.maxWidth * 0.065;
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
                                    style: TextStyles.subhead
                                ),

                                IconButton(
                                  icon: _sortOrder[columns.indexOf(column)] == 'asc'
                                      ? SizedBox(
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
                                      _sortOrder[columns.indexOf(column)] = _sortOrder[columns.indexOf(column)] == 'asc' ? 'desc' : 'asc';
                                      _sortProducts(columns.indexOf(column), _sortOrder[columns.indexOf(column)]);
                                    });
                                  },
                                ),
                                //SizedBox(width: 50,),
                                //Padding(
                                //  padding:  EdgeInsets.only(left: columnWidths[index]-50,),

                                // ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      onSort: (columnIndex, ascending){
                        _sortOrder;
                      },
                    );
                }).toList(),
                rows:
                List.generate(
                    math.min(itemsPerPage, filteredData.length - (currentPage - 1) * itemsPerPage),(index){
                  final detail = filteredData.skip((currentPage - 1) * itemsPerPage).elementAt(index);
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
                            Text(detail.customer,   style: TextStyles.body,)),
                        DataCell(
                          Text(detail.customerName,   style: TextStyles.body,),
                        ),
                        DataCell(
                          Text(detail.cityName,   style: TextStyles.body,),
                        ),
                        DataCell(
                          Container(
                            width: columnWidths[3],
                            child: Text(detail.telephoneNumber1.toString(),   style: TextStyles.body,),
                          ),
                        ),
                        DataCell(
                          Text(detail.emailAddress.toString(),   style: TextStyles.body,),
                        ),
                      ],
                      onSelectChanged: (selected){
                        if(selected != null && selected){
                          //final detail = filteredData[(currentPage - 1) * itemsPerPage + index];
                          if (filteredData.length <= 9) {
                            context.go('/Cus_Details',extra:{
                              'orderId': detail.customer
                            });
                          } else {
                            context.go('/Cus_Details',extra:{
                              'orderId': detail.customer
                            });

                          };
                        }
                      }

                  );
                }),
              ),
            ),
          ],
        );
    });
  }

// void _filterAndPaginateProducts() {
//   filteredData = productList.where((product) {
//     final matchesSearchText= product.customer!.toLowerCase().contains(_searchText.toLowerCase());
//     // print('-----');
//     // print(product.orderDate);
//     String orderYear = '';
//     // if (product..contains('/')) {
//     //   final dateParts = product.orderDate.split('/');
//     //   if (dateParts.length == 3) {
//     //     orderYear = dateParts[2]; // Extract the year
//     //   }
//     // }
//     // final orderYear = element.orderDate.substring(5,9);
//     if (status.isEmpty && selectDate.isEmpty) {
//       return matchesSearchText; // Include all products that match the search text
//     }
//     if(status == 'Status' && selectDate == 'Select Year'){
//       return matchesSearchText;
//     }
//     if(status == 'Status' &&  selectDate.isEmpty)
//     {
//       return matchesSearchText;
//     }
//     if(selectDate == 'Select Year' &&  status.isEmpty)
//     {
//       return matchesSearchText;
//     }
//     if (status == 'Status' && selectDate.isNotEmpty) {
//       return matchesSearchText && orderYear == selectDate; // Include all products
//     }
//     // if (status.isNotEmpty && selectDate == 'Select Year') {
//     //   return matchesSearchText && product.status == status;// Include all products
//     // }
//     if (status.isEmpty && selectDate.isNotEmpty) {
//       return matchesSearchText && orderYear == selectDate; // Include all products
//     }
//
//     // if (status.isNotEmpty && selectDate.isEmpty) {
//     //   return matchesSearchText && product.status == status;// Include all products
//     // }
//     return matchesSearchText &&
//         (product. == status && orderYear == selectDate);
//     //  return false;
//   }).toList();
//   totalPages = (filteredData.length / itemsPerPage).ceil();
//   //totalPages = (productList.length / itemsPerPage).ceil();
//   setState(() {
//     currentPage = 1;
//   });
// }

}
class CusDetail {
  String? customer;
  String? businessPartnerName;
  String? telephoneNumber1;
  String? location;
  String? email;
  double? postalCode;


  CusDetail({
    this.customer,
    this.businessPartnerName,
    this.telephoneNumber1,
    this.location,
    this.email,
    this.postalCode
  });

  factory CusDetail.fromJson(Map<String, dynamic> json) {
    return CusDetail(
      customer: json['customerId'] ?? '',
      businessPartnerName: json['customerName'] ?? '',
      email: json['email'] ?? '',
      telephoneNumber1: json['telephoneNumber1No'] ?? '',
      location: json['deliveryLocation'] ?? '',
      postalCode: json['returnCredit'] ?? 0.0,

    );
  }

  factory CusDetail.fromString(String jsonString) {
    final jsonMap = jsonDecode(jsonString);
    return CusDetail.fromJson(jsonMap);
  }


  @override
  String toString() {
    return 'cus ID: $customer, Order Date: $businessPartnerName, Total: $telephoneNumber1, Status: $Location, Delivery Status: $postalCode';
  }

  String toJson() {
    return jsonEncode({
      "customer": customer,
      "businessPartnerName": businessPartnerName,
      "email": email,
      "telephoneNumber1": telephoneNumber1,
      "Location": location,
      "postalCode": postalCode,

    });
  }


}


 