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
import 'package:http/http.dart' as http;
import '../Order Module/firstpage.dart';
import '../pdf/credit memo pdf.dart';
import '../pdf/delivery note pdf.dart';
import '../pdf/invoice pdf.dart';
import '../pdf/order bill pdf.dart';
import 'dart:html' as html;
import '../widgets/custom loading.dart';
import '../widgets/no datafound.dart';
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
  late Future<List<CusDetail>> futureOrders;
  List<CusDetail> productList = [];
  final ScrollController _scrollController = ScrollController();
  List<dynamic> detailJson = [];
  String searchQuery = '';
  List<CusDetail>filteredData = [];
  String status = '';
  String selectDate = '';
  final ScrollController horizontalScroll = ScrollController();

  String token = window.sessionStorage["token"] ?? " ";
  String? dropdownValue2 = 'Select Year';
  List<String> _sortOrder = List.generate(6, (index) => 'asc');
  List<String> columns = ['Customer ID','Customer Name','Contact','Email Address' ,'Credit Amount'];
  List<double> columnWidths = [130, 145, 139, 160, 135,];
  List<bool> columnSortState = [true, true, true,true,true];


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
  Future<List<dynamic>> _fetchAllpayProductMaster() async {
    //  final String token = 'eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJkaGFuYXNla2FyIiwiUm9sZXMiOlt7ImF1dGhvcml0eSI6ImRldmVsb3BlciJ9XSwiZXhwIjoxNzI1NjA3Nzc3LCJpYXQiOjE3MjU2MDA1Nzd9.stF0hO6T4ue3A_ayQw8BVgBg2Nov1k2_uwrc1BdlyJcWwEl8ycxIedJrTAuMCLJD8o7K7k6PQkWb1IFrD-hSqA';
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
  Future<OrderDetail?> _fetchpayOrderDetails(String orderId) async {
    //  String token = 'eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJkaGFuYXNla2FyIiwiUm9sZXMiOlt7ImF1dGhvcml0eSI6ImRldmVsb3BlciJ9XSwiZXhwIjoxNzI1NjA3Nzc3LCJpYXQiOjE3MjU2MDA1Nzd9.stF0hO6T4ue3A_ayQw8BVgBg2Nov1k2_uwrc1BdlyJcWwEl8ycxIedJrTAuMCLJD8o7K7k6PQkWb1IFrD-hSqA';
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
    'Invoice': false,
    'Delivery': false,
    'Payment': false,
    'Return': false,
    'Reports': false,
  };


  List<Widget> _buildMenuItems(BuildContext context) {
    return [
      _buildMenuItem('Home', Icons.dashboard, Colors.blue[900]!, '/Home'),
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
          child: _buildMenuItem('Customer', Icons.account_circle, Colors.white, '/Customer')),
      _buildMenuItem('Products', Icons.image_outlined, Colors.blue[900]!, '/Product_List'),
      _buildMenuItem('Orders', Icons.warehouse, Colors.blue[900]!, '/Order_List'),
      _buildMenuItem('Invoice', Icons.document_scanner_rounded, Colors.blue[900]!, '/Invoice'),
      _buildMenuItem('Delivery', Icons.fire_truck_outlined, Colors.blue[900]!, '/Delivery_List'),
      _buildMenuItem('Payment', Icons.payment_outlined, Colors.blue[900]!, '/Payment_List'),
      _buildMenuItem('Return', Icons.backspace_sharp, Colors.blue[900]!, '/Return_List'),
      _buildMenuItem('Reports', Icons.insert_chart, Colors.blue[900]!, '/Report_List'),
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
    if (!mounted) return;
    setState(() {
      isLoading = true;
    });
    try {
      final response = await http.get(
        Uri.parse(
          '$apicall/customer_master/get_all_customermaster?page=$page&limit=$itemsPerPage', // Changed limit to 10
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
        List<CusDetail> products = [];
        if (jsonData != null) {
          if (jsonData is List) {
            products = jsonData.map((item) => CusDetail.fromJson(item)).toList();
          } else if (jsonData is Map && jsonData.containsKey('body')) {
            products = (jsonData['body'] as List).map((item) => CusDetail.fromJson(item)).toList();
            totalItems = jsonData['totalItems'] ?? 0; // Get the total number of items
          }

          if(mounted){
            setState(() {
              totalPages = (products.length / itemsPerPage).ceil();
              productList = products;
              _filterAndPaginateProducts();
            });
          }
        }
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      // Optionally, show an error message to the user
    } finally {
      if(mounted){
        setState(() {
          isLoading = false;
        });
      }

    }
  }


  void _filterAndPaginateProducts() {
    filteredData = productList.
    where((product) {
      final matchesSearchText= product.cusId!.toLowerCase().contains(_searchText.toLowerCase());
      final matchlocation = product.location!.toLowerCase().contains(location.toLowerCase());
      final MatchName = product.cusName!.toLowerCase().contains(Name.toLowerCase());
      return matchesSearchText && matchlocation && MatchName;
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
                      padding: const EdgeInsets.only(left: 190),
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 10),
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
                                  const Padding(
                                    padding: EdgeInsets.only(left: 20),
                                    child: Text(
                                      'Customer List',
                                      style: TextStyle(
                                          fontSize: 20, fontWeight: FontWeight.bold),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  const Spacer(),
                                  Align(
                                    alignment: Alignment.topRight,
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          top: 10, right: 80),
                                      child: OutlinedButton(
                                        onPressed: () {
                                           context.go('/Create_Cus');

                                          //context.go('/Home/Orders/Create_Order');
                                        },
                                        style: OutlinedButton.styleFrom(
                                          backgroundColor:
                                          Colors.blue[800],
                                          // Button background color
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                            BorderRadius.circular(
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
                                  // Align(
                                  //   alignment: Alignment.topRight,
                                  //   child: Padding(
                                  //     padding: const EdgeInsets.only(top: 10, right: 80),
                                  //     child: MouseRegion(
                                  //       onEnter: (_) {
                                  //         setState(() {
                                  //           _isHovered1 = true;
                                  //           _controller.forward(); // Start shake animation when hovered
                                  //         });
                                  //       },
                                  //       onExit: (_) {
                                  //         setState(() {
                                  //           _isHovered1 = false;
                                  //           _controller.stop(); // Stop shake animation when not hovered
                                  //         });
                                  //       },
                                  //       child: AnimatedBuilder(
                                  //           animation: _controller,
                                  //           builder: (context, child) {
                                  //             return Transform.translate(offset: Offset(_isHovered1? _shakeAnimation.value : 0,0),
                                  //               child: AnimatedContainer(
                                  //                 duration: const Duration(milliseconds: 300),
                                  //                 curve: Curves.easeInOut,
                                  //                 decoration: BoxDecoration(
                                  //                   color: _isHovered1
                                  //                       ? Colors.blue[800]
                                  //                       : Colors.blue[800], // Background color change on hover
                                  //                   borderRadius: BorderRadius.circular(5),
                                  //                   boxShadow: _isHovered1
                                  //                       ? [
                                  //                     const BoxShadow(
                                  //                         color: Colors.black45,
                                  //                         blurRadius: 6,
                                  //                         spreadRadius: 2)
                                  //                   ]
                                  //                       : [],
                                  //                 ),
                                  //                 child: OutlinedButton(
                                  //                   onPressed: () {
                                  //                     context.go('/Create_New_Order');
                                  //                     //context.go('/Home/Orders/Create_Order');
                                  //                   },
                                  //                   style: OutlinedButton.styleFrom(
                                  //                     backgroundColor: Colors.blue[800],
                                  //                     shape: RoundedRectangleBorder(
                                  //                       borderRadius: BorderRadius.circular(
                                  //                           5), // Rounded corners
                                  //                     ),
                                  //                     side: BorderSide.none, // No outline
                                  //                   ),
                                  //                   child: const Text(
                                  //                     'Create',
                                  //                     style: TextStyle(
                                  //                       fontSize: 14,
                                  //                       fontWeight: FontWeight.w100,
                                  //                       color: Colors.white,
                                  //                     ),
                                  //                   ),
                                  //                 ),
                                  //               ),
                                  //             );
                                  //           }
                                  //
                                  //       ),
                                  //     ),
                                  //   ),
                                  // ),
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
                              hintText: 'Search by Customer ID',
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
                              child:
                              TextFormField(  decoration:  InputDecoration(    hintText: 'Search by Name',    hintStyle: const TextStyle(fontSize: 13,color: Colors.grey),    contentPadding: const EdgeInsets.only(bottom: 20,left: 10),   border: InputBorder.none,  ),  onChanged: _updateSearch2,),
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
                              child:
                              TextFormField(  decoration:  InputDecoration(    hintText: 'Search by Location',    hintStyle: const TextStyle(fontSize: 13,color: Colors.grey),    contentPadding: const EdgeInsets.only(bottom: 20,left: 10), border: InputBorder.none,  ),  onChanged: _updateSearch1,),
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
                    DataColumn(label: Text('Customer ID',style:TextStyle(
                        color: Colors.indigo[900],
                        fontSize: 13,
                        fontWeight: FontWeight.bold
                    ),)),
                    DataColumn(label: Text('Customer Name',style:TextStyle(
                        color: Colors.indigo[900],
                        fontSize: 13,
                        fontWeight: FontWeight.bold
                    ),)),
                    DataColumn(label: Text(
                      'Contact',style:TextStyle(
                        color: Colors.indigo[900],
                        fontSize: 13,
                        fontWeight: FontWeight.bold
                    ),)),
                    DataColumn(label: Text(
                      'Location',style:TextStyle(
                        color: Colors.indigo[900],
                        fontSize: 13,
                        fontWeight: FontWeight.bold
                    ),)),
                    DataColumn(label: Text(
                      'Credit Amount',style:TextStyle(
                        color: Colors.indigo[900],
                        fontSize: 13,
                        fontWeight: FontWeight.bold
                    ),)),

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
            return a.cusId!.compareTo(b.cusId!);
          } else if (columnIndex == 1) {
            return a.cusName!.compareTo(b.cusName!);
          } else if (columnIndex == 2) {
            return a.contact!.compareTo(b.contact!);
          } else if (columnIndex == 3) {
            return a.email!.toLowerCase().compareTo(b.email!.toLowerCase());
          } else if (columnIndex == 4) {
            return a.creditAmount!.compareTo(b.creditAmount!);
          } else {
            return 0;
          }
        });
      } else {
        filteredData.sort((a, b) {
          if (columnIndex == 0) {
            return b.cusId!.compareTo(a.cusId!); // Reverse the comparison
          } else if (columnIndex == 1) {
            return b.cusName!.compareTo(a.cusName!); // Reverse the comparison
          } else if (columnIndex == 2) {
            return b.contact!.compareTo(a.contact!); // Reverse the comparison
          } else if (columnIndex == 3) {
            return b.email!.toLowerCase().compareTo(a.email!.toLowerCase()); // Reverse the comparison
          } else if (columnIndex == 4) {
            return b.creditAmount!.compareTo(a.creditAmount!); // Reverse the comparison
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
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.indigo[900],
                                    fontSize: 13,
                                  ),
                                ),

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
                                          columnWidths[columns.indexOf(column)] += details.delta.dx;
                                          columnWidths[columns.indexOf(column)] =
                                              columnWidths[columns.indexOf(column)].clamp(50.0, 300.0);
                                        });
                                        // setState(() {
                                        //   columnWidths[columns.indexOf(column)] += details.delta.dx;
                                        //   if (columnWidths[columns.indexOf(column)] < 50) {
                                        //     columnWidths[columns.indexOf(column)] = 50; // Minimum width
                                        //   }
                                        // });
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.only(top: 10,bottom: 10),
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
                            Text(detail.cusId!,style:
                            const TextStyle(
                              // fontSize: 16,
                                color: Colors.grey),)),
                        DataCell(
                          Text(detail.cusName!,style: const TextStyle(
                            // fontSize: 16,
                              color: Colors.grey)),
                        ),
                        DataCell(
                          Text(detail.contact!,style: const TextStyle(
                            //fontSize: 16,
                              color: Colors.grey)),
                        ),
                        DataCell(
                          Container(
                            width: columnWidths[3],
                            child: Text(detail.email.toString(),style: const TextStyle(
                              // fontSize: 16,
                                color: Colors.grey)),
                          ),
                        ),
                        DataCell(
                          Text(detail.creditAmount!.toStringAsFixed(2),style: const TextStyle(
                            //fontSize: 16,
                              color: Colors.grey)),
                        ),

                      ],
                      onSelectChanged: (selected){
                        if(selected != null && selected){
                          //final detail = filteredData[(currentPage - 1) * itemsPerPage + index];
                          if (filteredData.length <= 9) {
                           context.go('/Cus_Details',extra:{
                             'orderId': detail.cusId
                           });
                          } else {
                            context.go('/Cus_Details',extra:{
                              'orderId': detail.cusId
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
              width: right * 0.78,

              decoration:const BoxDecoration(
                  color: Color(0xFFF7F7F7),
                  border: Border.symmetric(horizontal: BorderSide(color: Colors.grey,width: 0.5))
              ),
              child: DataTable(
                  showCheckboxColumn: false,
                  headingRowHeight: 40,
                  columns: [
                    DataColumn(label: Text('Customer ID',style:TextStyle(
                        color: Colors.indigo[900],
                        fontSize: 13,
                        fontWeight: FontWeight.bold
                    ),)),
                    DataColumn(label: Text('Customer Name',style:TextStyle(
                        color: Colors.indigo[900],
                        fontSize: 13,
                        fontWeight: FontWeight.bold
                    ),)),
                    DataColumn(label: Text(
                      'Contact',style:TextStyle(
                        color: Colors.indigo[900],
                        fontSize: 13,
                        fontWeight: FontWeight.bold
                    ),)),
                    DataColumn(label: Text(
                      'Email Address',style:TextStyle(
                        color: Colors.indigo[900],
                        fontSize: 13,
                        fontWeight: FontWeight.bold
                    ),)),
                    DataColumn(label: Text(
                      'Credit Amount',style:TextStyle(
                        color: Colors.indigo[900],
                        fontSize: 13,
                        fontWeight: FontWeight.bold
                    ),)),

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
            return a.cusId!.compareTo(b.cusId!);
          } else if (columnIndex == 1) {
            return a.cusName!.compareTo(b.cusName!);
          } else if (columnIndex == 2) {
            return a.contact!.compareTo(b.contact!);
          } else if (columnIndex == 3) {
            return a.email!.toLowerCase().compareTo(b.email!.toLowerCase());
          } else if (columnIndex == 4) {
            return a.creditAmount!.compareTo(b.creditAmount!);
          } else {
            return 0;
          }
        });
      } else {
        filteredData.sort((a, b) {
          if (columnIndex == 0) {
            return b.cusId!.compareTo(a.cusId!); // Reverse the comparison
          } else if (columnIndex == 1) {
            return b.cusName!.compareTo(a.cusName!); // Reverse the comparison
          } else if (columnIndex == 2) {
            return b.contact!.compareTo(a.contact!); // Reverse the comparison
          } else if (columnIndex == 3) {
            return b.email!.toLowerCase().compareTo(a.email!.toLowerCase()); // Reverse the comparison
          } else if (columnIndex == 4) {
            return b.creditAmount!.compareTo(a.creditAmount!); // Reverse the comparison
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
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.indigo[900],
                                    fontSize: 13,
                                  ),
                                ),

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
                                          columnWidths[columns.indexOf(column)] += details.delta.dx;
                                          columnWidths[columns.indexOf(column)] =
                                              columnWidths[columns.indexOf(column)].clamp(50.0, 300.0);
                                        });
                                        // setState(() {
                                        //   columnWidths[columns.indexOf(column)] += details.delta.dx;
                                        //   if (columnWidths[columns.indexOf(column)] < 50) {
                                        //     columnWidths[columns.indexOf(column)] = 50; // Minimum width
                                        //   }
                                        // });
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.only(top: 10,bottom: 10),
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
                            Text(detail.cusId!,style:
                            const TextStyle(
                              // fontSize: 16,
                                color: Colors.grey),)),
                        DataCell(
                          Text(detail.cusName!,style: const TextStyle(
                            // fontSize: 16,
                              color: Colors.grey)),
                        ),
                        DataCell(
                          Text(detail.contact!,style: const TextStyle(
                            //fontSize: 16,
                              color: Colors.grey)),
                        ),
                        DataCell(
                          Container(
                            width: columnWidths[3],
                            child: Text(detail.email.toString(),style: const TextStyle(
                              // fontSize: 16,
                                color: Colors.grey)),
                          ),
                        ),
                        DataCell(
                          Text(detail.creditAmount!.toStringAsFixed(2),style: const TextStyle(
                            //fontSize: 16,
                              color: Colors.grey)),
                        ),

                      ],
                      onSelectChanged: (selected){
                        if(selected != null && selected){
                          //final detail = filteredData[(currentPage - 1) * itemsPerPage + index];
                          if (filteredData.length <= 9) {
                            context.go('/Cus_Details',extra:{
                              'orderId': detail.cusId
                            });
                          } else {
                            context.go('/Cus_Details',extra:{
                              'orderId': detail.cusId
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
//     final matchesSearchText= product.cusId!.toLowerCase().contains(_searchText.toLowerCase());
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
  String? cusId;
  String? cusName;
  String? contact;
  String? location;
  String? email;
  double? creditAmount;


  CusDetail({
    this.cusId,
    this.cusName,
    this.contact,
    this.location,
    this.email,
    this.creditAmount
  });

  factory CusDetail.fromJson(Map<String, dynamic> json) {
    return CusDetail(
      cusId: json['customerId'] ?? '',
      cusName: json['customerName'] ?? '',
      email: json['email'] ?? '',
      contact: json['contactNo'] ?? '',
      location: json['deliveryLocation'] ?? '',
      creditAmount: json['returnCredit'] ?? 0.0,

    );
  }

  factory CusDetail.fromString(String jsonString) {
    final jsonMap = jsonDecode(jsonString);
    return CusDetail.fromJson(jsonMap);
  }


  @override
  String toString() {
    return 'cus ID: $cusId, Order Date: $cusName, Total: $contact, Status: $Location, Delivery Status: $creditAmount';
  }

  String toJson() {
    return jsonEncode({
      "cusId": cusId,
      "cusName": cusName,
      "email": email,
      "Contact": contact,
      "Location": location,
      "CreditAmount": creditAmount,

    });
  }


}


