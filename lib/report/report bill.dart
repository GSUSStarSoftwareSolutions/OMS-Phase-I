import 'dart:async';
import 'dart:convert';
import 'dart:html';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:btb/Return%20Module/return%20first%20page.dart';
import 'package:btb/admin/Api%20name.dart';
import 'package:btb/widgets/confirmdialog.dart';
import 'package:btb/widgets/pagination.dart';
import 'package:btb/widgets/productclass.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import '../Order Module/firstpage.dart';
import '../pdf/credit memo pdf.dart';
import '../pdf/delivery note pdf.dart';
import '../pdf/invoice pdf.dart';
import '../pdf/order bill pdf.dart';
import 'dart:html' as html;
import '../pdf/payment pdf.dart';
import '../widgets/custom loading.dart';
import '../widgets/no datafound.dart';

void main() {
  runApp(Reportspage());
}

class Reportspage extends StatefulWidget {
  const Reportspage({super.key});

  @override
  State<Reportspage> createState() => _ReportspageState();
}

class _ReportspageState extends State<Reportspage> {
  List<String> statusOptions = ['Order', 'Invoice', 'Delivery', 'Payment'];
  Timer? _searchDebounceTimer;
  List<String> columns = [
    'Order ID',
    'Order Date',
    'Invoice No',
    'Total Amount',
    'Delivery Status',
    ''
  ];
  List<double> columnWidths = [100, 120, 120, 125, 135, 150];
  List<bool> columnSortState = [true, true, true, true, true, true];
  String _searchText = '';
  String _initialValue = 'Download';
  bool isOrdersSelected = false;
  bool _loading = false;
  detail? _selectedProduct;
  DateTime? _selectedDate;
  late TextEditingController _dateController;
  Map<String, dynamic> PaymentMap = {};
  int startIndex = 0;
  List<String> _sortOrder = List.generate(6, (index) => 'asc');
  List<Product> filteredProducts = [];
  int currentPage = 1;
  String? dropdownValue1 = 'Status';
  late Future<List<detail>> futureOrders;
  List<detail> productList = [];
  final ScrollController _scrollController = ScrollController();
  List<dynamic> detailJson = [];
  String searchQuery = '';
  List<detail> filteredData = [];
  String initialValue = 'Download';
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

  String dropdownValue = 'Download'; // Initial value

  Future<void> performAction(String? newValue, String orderId) async {
    if (newValue == 'Order') {
      await downloadPdf(orderId); // Trigger order PDF download
    } else if (newValue == 'Invoice') {
      await downloadinvoicePdf(orderId); // Trigger invoice PDF download
    }
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
  //       print('Failed to fetch order details.');
  //     }
  //   } catch (e) {
  //     print('Error generating PDF: $e');
  //   }
  // }
  Future<List<dynamic>> _fetchAllpayProductMaster() async {
    //  final String token = 'eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJkaGFuYXNla2FyIiwiUm9sZXMiOlt7ImF1dGhvcml0eSI6ImRldmVsb3BlciJ9XSwiZXhwIjoxNzI1NjA3Nzc3LCJpYXQiOjE3MjU2MDA1Nzd9.stF0hO6T4ue3A_ayQw8BVgBg2Nov1k2_uwrc1BdlyJcWwEl8ycxIedJrTAuMCLJD8o7K7k6PQkWb1IFrD-hSqA';
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

  Future<OrderDetail?> _fetchpayOrderDetails(String orderId) async {
    //  String token = 'eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJkaGFuYXNla2FyIiwiUm9sZXMiOlt7ImF1dGhvcml0eSI6ImRldmVsb3BlciJ9XSwiZXhwIjoxNzI1NjA3Nzc3LCJpYXQiOjE3MjU2MDA1Nzd9.stF0hO6T4ue3A_ayQw8BVgBg2Nov1k2_uwrc1BdlyJcWwEl8ycxIedJrTAuMCLJD8o7K7k6PQkWb1IFrD-hSqA';
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
            item['discountamount'] =
                (double.parse(item['totalAmount'].toString()) *
                        double.parse(item['discount'].replaceAll('%', ''))) /
                    100;
            item['taxamount'] = ((double.parse(item['totalAmount'].toString()) -
                        double.parse(item['discountamount'].toString())) *
                    double.parse(item['tax'].replaceAll('%', '').toString())) /
                100;
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

  Future<List<dynamic>> _fetchAllinvoiceProductMaster() async {
    //  final String token = 'eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJkaGFuYXNla2FyIiwiUm9sZXMiOlt7ImF1dGhvcml0eSI6ImRldmVsb3BlciJ9XSwiZXhwIjoxNzIzMTE0OTQ0LCJpYXQiOjE3MjMxMDc3NDR9.1UxLslHM3GivBHoBr8pS02OxD6dC5IRG4ryxiUdgzIJmFjSCwftf6Kme4rPLb-ZOjzOoAaxueSzKxiLmjnmSFg';
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

  Future<OrderDetail?> _fetchinvoiceOrderDetails(String orderId) async {
    // String token = 'eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJkaGFuYXNla2FyIiwiUm9sZXMiOlt7ImF1dGhvcml0eSI6ImRldmVsb3BlciJ9XSwiZXhwIjoxNzI1NjA2NjA5LCJpYXQiOjE3MjU1OTk0MDl9.a0XS5AykjKk62PBbfGessANRveTtU5wawjPRnHj73Zi1t-Xh3b2-2G_CksANLOaANHiy-4AlsCYwOZFY8GmExA';
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

  Future downloaddelPdf(String orderId) async {
    final String orderId1 = orderId;
    try {
      final productMasterData = await _fetchAlldelProductMaster();
      final orderDetails = await _fetchdelOrderDetails(orderId1);
      for (var product in productMasterData) {
        for (var item in orderDetails!.items) {
          if (product['productName'] == item['productName']) {
            item['tax'] = product['tax'];
            item['discount'] = product['discount'];
            item['discountamount'] =
                (double.parse(item['totalAmount'].toString()) *
                        double.parse(item['discount'].replaceAll('%', ''))) /
                    100;
            item['taxamount'] = ((double.parse(item['totalAmount'].toString()) -
                        double.parse(item['discountamount'].toString())) *
                    double.parse(item['tax'].replaceAll('%', '').toString())) /
                100;
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
        print('Failed to fetch order details.');
      }
    } catch (e) {
      print('Error generating PDF: $e');
    }
  }

  Future<List<dynamic>> _fetchAlldelProductMaster() async {
    // final String token = 'eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJkaGFuYXNla2FyIiwiUm9sZXMiOlt7ImF1dGhvcml0eSI6ImRldmVsb3BlciJ9XSwiZXhwIjoxNzIzMjY4MDk4LCJpYXQiOjE3MjMyNjA4OTh9.GA66i8d7RzYDeZbElDpkHe0EdlBNCKZweQjwTcaMI3HPP1W_b43YKgSqomohzFXsYV-JAAVGY-6yfRT_B2l3sg';
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

  Future<OrderDetail?> _fetchdelOrderDetails(String orderId) async {
    // String token = 'eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJkaGFuYXNla2FyIiwiUm9sZXMiOlt7ImF1dGhvcml0eSI6ImRldmVsb3BlciJ9XSwiZXhwIjoxNzIzMjY4MDk4LCJpYXQiOjE3MjMyNjA4OTh9.GA66i8d7RzYDeZbElDpkHe0EdlBNCKZweQjwTcaMI3HPP1W_b43YKgSqomohzFXsYV-JAAVGY-6yfRT_B2l3sg';
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
            item['discountamount'] =
                (double.parse(item['totalAmount'].toString()) *
                        double.parse(item['discount'].replaceAll('%', ''))) /
                    100;
            item['taxamount'] = ((double.parse(item['totalAmount'].toString()) -
                        double.parse(item['discountamount'].toString())) *
                    double.parse(item['tax'].replaceAll('%', '').toString())) /
                100;
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
        print('Failed to fetch order details.');
      }
    } catch (e) {
      print('Error generating PDF: $e');
    }
  }

  Future<List<dynamic>> _fetchAllProductMaster() async {
    // final String token = 'eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJkaGFuYXNla2FyIiwiUm9sZXMiOlt7ImF1dGhvcml0eSI6ImRldmVsb3BlciJ9XSwiZXhwIjoxNzI0ODMyMjUzLCJpYXQiOjE3MjQ4MjUwNTN9.-HLZdMO9251y0hm5saV5EP4YBu6JKJgtZKiEahCLcw5OKNuSIUaTTZ1vtKnwYj4SgQMoHMpu8dZihvNUTYv3Ig';
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
    // String token = 'eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJkaGFuYXNla2FyIiwiUm9sZXMiOlt7ImF1dGhvcml0eSI6ImRldmVsb3BlciJ9XSwiZXhwIjoxNzI0ODMyMjUzLCJpYXQiOjE3MjQ4MjUwNTN9.-HLZdMO9251y0hm5saV5EP4YBu6JKJgtZKiEahCLcw5OKNuSIUaTTZ1vtKnwYj4SgQMoHMpu8dZihvNUTYv3Ig';
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

  Future<List<dynamic>> _fetchAllproductpayment() async {
    //  final String token = 'eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJkaGFuYXNla2FyIiwiUm9sZXMiOlt7ImF1dGhvcml0eSI6ImRldmVsb3BlciJ9XSwiZXhwIjoxNzI2MTQzMzMwLCJpYXQiOjE3MjYxMzYxMzB9.azbMgCL63olMUbpF0BaXhXAM2oEuXk7AkWMAtTAXuinBjy15IlqFyu0gvoFdGqtwJbFfZXVgIgGFnYmbgAKkoQ';
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

  Future<OrderDetail?> _fetchOrderDetailspayment(String orderId) async {
    // String token = 'eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJkaGFuYXNla2FyIiwiUm9sZXMiOlt7ImF1dGhvcml0eSI6ImRldmVsb3BlciJ9XSwiZXhwIjoxNzI2MTQzMzMwLCJpYXQiOjE3MjYxMzYxMzB9.azbMgCL63olMUbpF0BaXhXAM2oEuXk7AkWMAtTAXuinBjy15IlqFyu0gvoFdGqtwJbFfZXVgIgGFnYmbgAKkoQ';
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
            print('json');
            print(jsonObject);
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

  Future downloadPaymentReceipt(String PaymentId) async {
    final String orderId = PaymentId;
    try {
      final productMasterData = await _fetchAllproductpayment();
      final orderDetails = await _fetchOrderDetailspayment(orderId);
      for (var product in productMasterData) {
        for (var item in orderDetails!.items) {
          if (product['productName'] == item['productName']) {
            item['tax'] = product['tax'];
            item['discount'] = product['discount'];
            item['discountamount'] =
                (double.parse(item['totalAmount'].toString()) *
                        double.parse(item['discount'].replaceAll('%', ''))) /
                    100;
            item['taxamount'] = ((double.parse(item['totalAmount'].toString()) -
                        double.parse(item['discountamount'].toString())) *
                    double.parse(item['tax'].replaceAll('%', '').toString())) /
                100;
          }
        }
      }

      if (orderDetails != null) {
        final Uint8List pdfBytes = await PaymentReceipt(orderDetails);
        final blob = html.Blob([pdfBytes]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute('download', 'Payment Receipt.pdf')
          ..click();
        html.Url.revokeObjectUrl(url);
      } else {
        print('Failed to fetch order details.');
      }
    } catch (e) {
      print('Error generating PDF: $e');
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
          '$apicall/order_master/get_all_ordermaster?page=$page&limit=$itemsPerPage', // Changed limit to 10
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
          } else if (jsonData is Map && jsonData.containsKey('body')) {
            products = (jsonData['body'] as List)
                .map((item) => detail.fromJson(item))
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
    'Invoice': false,
    'Delivery': false,
    'Payment': false,
    'Return': false,
    'Reports': false,
  };

  List<Widget> _buildMenuItems(BuildContext context) {
    return [
      _buildMenuItem('Home', Icons.dashboard, Colors.blue[900]!, '/Home'),
      _buildMenuItem('Customer', Icons.account_circle, Colors.blue[900]!, '/Customer'),
      _buildMenuItem('Products', Icons.image_outlined, Colors.blue[900]!, '/Product_List'),
      _buildMenuItem('Orders', Icons.warehouse, Colors.blue[900]!, '/Order_List'),
      _buildMenuItem('Invoice', Icons.document_scanner_rounded, Colors.blue[900]!, '/Invoice'),
      _buildMenuItem('Delivery', Icons.fire_truck_outlined, Colors.blue[900]!, '/Delivery_List'),
      _buildMenuItem('Payment', Icons.payment_outlined, Colors.blue[900]!, '/Payment_List'),
      _buildMenuItem('Return', Icons.backspace_sharp, Colors.blue[900]!, '/Return_List'),
      _buildMenuItem('Reports', Icons.insert_chart, Colors.blueAccent, '/Report_List'),
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
                            'Reports List',
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
                  // decoration: BoxDecoration(
                  //   color: Colors.white, // or any other color that fits your design
                  //   borderRadius: BorderRadius.all(Radius.circular(10.0)), // adds a subtle rounded corner
                  //   border: Border.all(
                  //     color: Color(0xFFE5E5E5), // a light grey border
                  //     width: 1.0,
                  //   ),
                  //   boxShadow: [
                  //     BoxShadow(
                  //       color: Color(0xFFC7C5B8).withOpacity(0.2), // a soft, warm shadow
                  //       spreadRadius: 0.5,
                  //       blurRadius: 4, // increased blur radius for a softer shadow
                  //       offset: Offset(0, 4), // increased offset for a more pronounced shadow
                  //     ),
                  //   ],
                  // ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    // boxShadow: [
                    //   BoxShadow(
                    //     color: Colors.blue.withOpacity(0.1), // Soft grey shadow
                    //     spreadRadius: 1,
                    //     blurRadius: 3,
                    //     offset: const Offset(0, 1),
                    //   ),
                    // ],
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
                          //Divider(color: Colors.grey,height: 1,)
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
                        // const SizedBox(height: 8),
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
                              //  focusColor: Color(0xFFF0F4F8),
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
                                  width: constraints.maxWidth * 0.128, // Dropdown width
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
            width: right * 0.78,
            decoration: const BoxDecoration(
                color: Color(0xFFF7F7F7),
                border: Border.symmetric(
                    horizontal: BorderSide(color: Colors.grey, width: 0.5))),
            child: DataTable(
                showCheckboxColumn: false,
                headingRowHeight: 40,
                columns: [
                  DataColumn(
                      label: Container(
                          child: Text(
                    'Order ID',
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
                    'Invoice Number',
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
                  DataColumn(label: Container(child: Text('     '))),
                ],
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

    void _sortProducts(int columnIndex, String sortDirection) {
      if (sortDirection == 'asc') {
        filteredData.sort((a, b) {
          if (columnIndex == 0) {
            return a.orderId!.compareTo(b.orderId!);
          } else if (columnIndex == 1) {
            return a.orderDate.compareTo(b.orderDate);
          } else if (columnIndex == 2) {
            return a.invoiceNo!.compareTo(b.invoiceNo!);
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
            return b.orderId!.compareTo(a.orderId!);
          } else if (columnIndex == 1) {
            return b.orderDate.compareTo(a.orderDate);
          } else if (columnIndex == 2) {
            return b.invoiceNo!.compareTo(a.invoiceNo!);
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

    return LayoutBuilder(builder: (context, constraints) {
      // double padding = constraints.maxWidth * 0.065;
      double right = MediaQuery.of(context).size.width;

      return Column(
        children: [
          Container(
            width: right * 0.78,
            decoration: const BoxDecoration(
                color: Color(0xFFF7F7F7),
                border: Border.symmetric(
                    horizontal: BorderSide(color: Colors.grey, width: 0.5))),
            child: DataTable(
                showCheckboxColumn: false,
                headingRowHeight: 40,
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
                                Spacer(),
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
                                        // setState(() {
                                        //   columnWidths[columns.indexOf(column)] += details.delta.dx;
                                        //   if (columnWidths[columns.indexOf(column)] < 50) {
                                        //     columnWidths[columns.indexOf(column)] = 50; // Minimum width
                                        //   }
                                        // });
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
                    math.min(itemsPerPage,
                        filteredData.length - (currentPage - 1) * itemsPerPage),
                    (index) {
                  final detail = filteredData
                      .skip((currentPage - 1) * itemsPerPage)
                      .elementAt(index);
                  final actualIndex = index + (currentPage -1) * itemsPerPage;
                  final isSelected = _selectedProduct == detail;
                  // final isSelected = _selectedProduct == detail;
                  //final product = filteredData[(currentPage - 1) * itemsPerPage + index];
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
                        detail.orderId!,
                        style: TextStyle(
                            // fontSize: 16,
                            color: Colors.grey),
                      )),
                      DataCell(
                        Text(detail.orderDate,
                            style: TextStyle(
                                // fontSize: 16,
                                color: Colors.grey)),
                      ),
                      DataCell(
                        Text(detail.invoiceNo!,
                            style: TextStyle(
                                //fontSize: 16,
                                color: Colors.grey)),
                      ),
                      DataCell(
                        Text(detail.total.toString(),
                            style: TextStyle(
                                // fontSize: 16,
                                color: Colors.grey)),
                      ),
                      DataCell(
                        Text(detail.deliveryStatus.toString(),
                            style: TextStyle(
                                //fontSize: 16,
                                color: detail.deliveryStatus == "In Progress"
                                    ? Colors.orange
                                    : detail.deliveryStatus == "Delivered"
                                        ? Colors.green
                                        : Colors.red)),
                      ),
                      if (detail.deliveryStatus == 'Not Started' ||
                          detail.deliveryStatus == 'In Progress') ...{
                        DataCell (
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              decoration: BoxDecoration(
                                  ),
                              child: DropdownButton2<String>(
                                hint: Padding(
                                  padding: const EdgeInsets.only(left: 9),
                                  child: const Text(
                                    'Download',
                                    style: TextStyle(fontSize: 13),
                                  ),
                                ),
                                items: <String>[
                                  'Order',
                                  'Invoice'
                                ].map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(
                                      value,
                                      style: TextStyle(
                                          color: value == 'Download'
                                              ? Colors.grey
                                              : Colors.black,
                                          fontSize: 13),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) async {
                                  setState(() {
                                    //  detail.status = newValue!; // Update the status based on the selected value
                                  });

                                  // Perform action based on the selected value
                                  if (newValue == 'Order') {
                                    await downloadPdf(
                                        filteredData[actualIndex].orderId!); // Download order PDF
                                  } else if (newValue == 'Invoice') {
                                    await downloadinvoicePdf(
                                        filteredData[actualIndex].orderId!
                                    ); // Download invoice PDF
                                  }
                                },
                                buttonStyleData: ButtonStyleData(
                                  height: 50,
                                  width: 100,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    border: Border.all(color: Colors.black26),
                                    color: Colors.white,
                                  ),
                                ),
                                dropdownStyleData: DropdownStyleData(
                                  // maxHeight: 200,
                                  width: 150,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    border: Border.all(color: Colors.black26),
                                    color: Colors.white,
                                  ),
                                  elevation: 5,
                                  offset: const Offset(0, 50),
                                ),
                                // Hide the selected value
                                // hint: Text(''), // Empty string to hide the selected value
                              ),
                            ),
                          ),
                        ),

                        // DataCell(
                        //   Padding(
                        //     padding: const EdgeInsets.all(8.0),
                        //     child: Container(
                        //       decoration: BoxDecoration(
                        //         border: Border.all(width: 1, color: Colors.grey), // Add a grey border
                        //         borderRadius: BorderRadius.circular(5), // Add a slight rounded corner
                        //       ),
                        //       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), // Add equal padding
                        //       child:
                        //       DropdownButton<String>(
                        //         value: detail.status.toString(), // Current selected value
                        //         items: <String>['Download','Order', 'Invoice']
                        //             .map<DropdownMenuItem<String>>((String value) {
                        //           return DropdownMenuItem<String>(
                        //             value: value,
                        //             child: Text(value, style: TextStyle(color: value == 'Download' ? Colors.grey : Colors.black,fontSize: 13),),
                        //           );
                        //         }).toList(),
                        //         onChanged: (String? newValue) async {
                        //           setState(() {
                        //             detail.status = newValue!; // Update the status based on the selected value
                        //           });
                        //           // Perform action based on the selected value
                        //           if (newValue == 'Order') {
                        //             await downloadPdf(detail.orderId!); // Download order PDF
                        //           } else if (newValue == 'Invoice') {
                        //             await downloadinvoicePdf(detail.orderId!); // Download invoice PDF
                        //           }
                        //         },
                        //         // icon: Padding(
                        //         //   padding: const EdgeInsets.only(bottom: 10,left: 5),
                        //         //   child: Icon(Icons.arrow_drop_down,size: 20,),
                        //         // ),
                        //         //isExpanded: true,
                        //       ),
                        //     ),
                        //   ),
                        // ),
                      } else if (detail.deliveryStatus == 'Delivered' &&
                          detail.paymentStatus == '-') ...{
                        DataCell(
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              child: DropdownButton2<String>(
                                hint: Padding(
                                  padding: const EdgeInsets.only(left: 9),
                                  child: const Text(
                                    'Download',
                                    style: TextStyle(fontSize: 13),
                                  ),
                                ),
                                //value: detail.status.toString(), // Current selected value
                                items: <String>[
                                  'Order',
                                  'Invoice',
                                  'Delivery'
                                ].map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(
                                      value,
                                      style: TextStyle(
                                          color: value == 'Download'
                                              ? Colors.grey
                                              : Colors.black,
                                          fontSize: 13),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) async {
                                  // Perform action based on the selected value
                                  if (newValue == 'Order') {
                                    await downloadPdf(
                                        filteredData[actualIndex].orderId!); // Download order PDF
                                  } else if (newValue == 'Invoice') {
                                    await downloadinvoicePdf(filteredData[actualIndex].orderId!); // Download invoice PDF
                                  } else if (newValue == 'Delivery') {
                                    await downloaddelPdf(filteredData[actualIndex].orderId!); // Download delivery PDF
                                  }
                                },
                                buttonStyleData: ButtonStyleData(
                                  height: 50,
                                  width: 100,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    border: Border.all(color: Colors.black26),
                                    color: Colors.white,
                                  ),
                                ),
                                dropdownStyleData: DropdownStyleData(
                                  // maxHeight: 200,
                                  width: 150,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    border: Border.all(color: Colors.black26),
                                    color: Colors.white,
                                  ),
                                  elevation: 5,
                                  offset: const Offset(0, 50),
                                ),
                              ),
                            ),
                          ),
                        ),
                      } else if (detail.paymentStatus == 'partial payment' &&
                          detail.deliveryStatus == 'Delivered') ...{
                        DataCell(
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              child: DropdownButton2<String>(
                                // Current selected value
                                hint: Padding(
                                  padding: const EdgeInsets.only(left: 9),
                                  child: const Text(
                                    'Download',
                                    style: TextStyle(fontSize: 13),
                                  ),
                                ),
                                items: <String>[
                                  'Order',
                                  'Invoice',
                                  'Delivery',
                                  'Payment'
                                ].map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(
                                      value,
                                      style: TextStyle(
                                          color: value == 'Download'
                                              ? Colors.grey
                                              : Colors.black,
                                          fontSize: 13),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) async {
                                  // Perform action based on the selected value
                                  if (newValue == 'Order') {
                                    await downloadPdf(
                                        filteredData[actualIndex].orderId!); // Download order PDF
                                  } else if (newValue == 'Invoice') {
                                    await downloadinvoicePdf(filteredData[actualIndex].orderId!); // Download invoice PDF
                                  } else if (newValue == 'Delivery') {
                                    await downloaddelPdf(filteredData[actualIndex].orderId!); // Download delivery PDF
                                  } else if (newValue == 'Payment') {
                                    await downloadPaymentReceipt(filteredData[actualIndex].orderId!); // Download payment PDF
                                  }
                                },
                                buttonStyleData: ButtonStyleData(
                                  height: 50,
                                  width: 100,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    border: Border.all(color: Colors.black26),
                                    color: Colors.white,
                                  ),
                                ),
                                dropdownStyleData: DropdownStyleData(
                                  // maxHeight: 200,
                                  width: 150,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    border: Border.all(color: Colors.black26),
                                    color: Colors.white,
                                  ),
                                  elevation: 5,
                                  offset: const Offset(0, 50),
                                ),
                              ),
                            ),
                          ),
                        ),
                      } else if (detail.paymentStatus == 'cleared' &&
                          detail.deliveryStatus == 'Delivered') ...{
                        DataCell(
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              // Add equal padding
                              child: DropdownButton2<String>(
                                hint: Padding(
                                  padding: const EdgeInsets.only(left: 9),
                                  child: const Text(
                                    'Download',
                                    style: TextStyle(fontSize: 13),
                                  ),
                                ),
                                // value: detail.status.toString(), // Current selected value
                                items: <String>[
                                  'Order',
                                  'Invoice',
                                  'Delivery',
                                  'Payment'
                                ].map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(
                                      value,
                                      style: TextStyle(
                                          color: value == 'Download'
                                              ? Colors.grey
                                              : Colors.black,
                                          fontSize: 13),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) async {

                                  // Perform action based on the selected value
                                  if (newValue == 'Order') {
                                    await downloadPdf(
                                       filteredData[actualIndex].orderId!); // Download order PDF
                                  } else if (newValue == 'Invoice') {
                                    await downloadinvoicePdf(filteredData[actualIndex].orderId!); // Download invoice PDF
                                  } else if (newValue == 'Delivery') {
                                    await downloaddelPdf(filteredData[actualIndex].orderId!); // Download delivery PDF
                                  } else if (newValue == 'Payment') {
                                    await downloadPaymentReceipt(filteredData[actualIndex].orderId!); // Download payment PDF
                                  }
                                },
                                buttonStyleData: ButtonStyleData(
                                  height: 50,
                                  width: 100,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    border: Border.all(color: Colors.black26),
                                    color: Colors.white,
                                  ),
                                ),
                                dropdownStyleData: DropdownStyleData(
                                  width: 150,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    border: Border.all(color: Colors.black26),
                                    color: Colors.white,
                                  ),
                                  elevation: 5,
                                  offset: const Offset(0, 50),
                                ),
                              ),
                            ),
                          ),
                        ),
                      } else ...{
                        DataCell(
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              // Add equal padding

                              child: DropdownButton2<String>(
                                hint: Padding(
                                  padding: const EdgeInsets.only(left: 9),
                                  child: const Text(
                                    'Download',
                                    style: TextStyle(fontSize: 13),
                                  ),
                                ),
                                //value: detail.status.toString(), // Current selected value
                                items: <String>[
                                  'Order',
                                  'Invoice',
                                  'Delivery',
                                  'Payment'
                                ].map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(
                                      value,
                                      style: TextStyle(
                                          color: value == 'Download'
                                              ? Colors.grey
                                              : Colors.black,
                                          fontSize: 13),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) async {

                                  // Perform action based on the selected value
                                  if (newValue == 'Order') {
                                    //   await downloadPdf(detail.orderId!); // Download order PDF
                                  } else if (newValue == 'Invoice') {
                                    //await downloadinvoicePdf(detail.orderId!); // Download invoice PDF
                                  } else if (newValue == 'Delivery') {
                                    //await downloaddelPdf(detail.orderId!); // Download delivery PDF
                                  } else if (newValue == 'Payment') {
                                  //   await downloadCreditMemoPdf(detail.orderId!); // Download payment PDF
                                  }
                                },
                                buttonStyleData: ButtonStyleData(
                                  height: 50,
                                  width: 100,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    border: Border.all(color: Colors.black26),
                                    color: Colors.white,
                                  ),
                                ),
                                dropdownStyleData: DropdownStyleData(
                                  //  maxHeight: 200,
                                  width: 150,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    border: Border.all(color: Colors.black26),
                                    color: Colors.white,
                                  ),
                                  elevation: 5,
                                  offset: const Offset(0, 50),
                                ),
                              ),
                            ),
                          ),
                        ),
                      },

                      //     if(detail.deliveryStatus == 'Not Started' || detail.deliveryStatus == 'In Progress')...{
                      //
                      //       DataCell(
                      //         Padding(
                      //           padding: const EdgeInsets.all(8.0),
                      //           child: Container(
                      //             decoration: BoxDecoration(
                      //               border: Border.all(width: 1, color: Colors.grey), // Add a grey border
                      //               borderRadius: BorderRadius.circular(5), // Add a slight rounded corner
                      //             ),
                      //             padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), // Add equal padding
                      //             child:
                      //  // Initial value to display
                      //
                      // // DropdownButton<String>(
                      // // value: _initialValue, // Set the initial value
                      // // items: <String>['Download','Order', 'Invoice'] // Remove 'Download' from the options
                      // //     .map<DropdownMenuItem<String>>((String value) {
                      // // return DropdownMenuItem<String>(
                      // // value: value,
                      // // child: Text(value),
                      // // );
                      // // }).toList(),
                      // // onChanged: (String? newValue) async {
                      // // setState(() {
                      // // _initialValue = newValue!; // Update the initial value
                      // // detail.status = newValue; // Update the status based on the selected value
                      // // });
                      // // // Perform action based on the selected value
                      // // if (newValue == 'Order') {
                      // // await downloadPdf(detail.orderId!); // Download order PDF
                      // // } else if (newValue == 'Invoice') {
                      // // await downloadinvoicePdf(detail.orderId!); // Download invoice PDF
                      // // }
                      // // },
                      // // style: TextStyle(
                      // // color: isSelected ? Colors.deepOrange[200] : const Color(0xFFFFB315),
                      // // ),
                      // // ),
                      // DropdownButton<String>(
                      // value: detail.status.toString(), // Current selected value items: <String>['Order', 'Invoice'] .map<DropdownMenuItem<String>>((String value)
                      // items: <String>['Download','Order', 'Invoice']
                      //      .map<DropdownMenuItem<String>>((String value) {
                      // return DropdownMenuItem<String>(
                      // value: value,
                      // child: Text(value),
                      // );
                      // }).toList(),
                      // onChanged: (String? newValue) async {
                      // setState(() {
                      // detail.status = newValue!; // Update the status based on the selected value
                      // });
                      // // Perform action based on the selected value
                      // if (newValue == 'Order') {
                      // await downloadPdf(detail.orderId!); // Download order PDF
                      // } else if (newValue == 'Invoice') {
                      // await downloadinvoicePdf(detail.orderId!); // Download invoice PDF
                      // }
                      // },
                      // style: TextStyle(
                      // color: isSelected ? Colors.deepOrange[200] : const Color(0xFFFFB315),
                      // ),
                      // ),
                      //           ),
                      //         ),
                      //       ),
                      //     }
                      //     else if(detail.deliveryStatus == 'Delivered' && detail.paymentStatus=='-')...{
                      //       DataCell(
                      //         Padding(
                      //           padding: const EdgeInsets.all(8.0),
                      //           child: Container(
                      //             decoration: BoxDecoration(
                      //               border: Border.all(width: 1, color: Colors.grey), // Add a grey border
                      //               borderRadius: BorderRadius.circular(5), // Add a slight rounded corner
                      //             ),
                      //             padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), // Add equal padding
                      //             child:
                      //             DropdownButton<String>(
                      //               value: detail.status.toString(), // Current selected value
                      //               items: <String>['Download','Order', 'Invoice', 'Delivery']
                      //                   .map<DropdownMenuItem<String>>((String value) {
                      //                 return DropdownMenuItem<String>(
                      //                   value: value,
                      //                   child: Text(value),
                      //                 );
                      //               }).toList(),
                      //               onChanged: (String? newValue) async {
                      //                 setState(() {
                      //                   detail.status = newValue!; // Update the status based on the selected value
                      //                 });
                      //                 // Perform action based on the selected value
                      //                 if (newValue == 'Order') {
                      //                   await downloadPdf(detail.orderId!); // Download order PDF
                      //                 } else if (newValue == 'Invoice') {
                      //                   await downloadinvoicePdf(detail.orderId!); // Download invoice PDF
                      //                 } else if (newValue == 'Delivery') {
                      //                   await downloaddelPdf(detail.orderId!); // Download delivery PDF
                      //                 }
                      //               },
                      //               style: TextStyle(
                      //                 color: isSelected ? Colors.deepOrange[200] : const Color(0xFFFFB315),
                      //               ),
                      //             ),
                      //           ),
                      //         ),
                      //       ),
                      //     }
                      //     else if (detail.paymentStatus == 'partial payment' && detail.deliveryStatus == 'Delivered')...{
                      //         DataCell(
                      //           Padding(
                      //             padding: const EdgeInsets.all(8.0),
                      //             child: Container(
                      //               decoration: BoxDecoration(
                      //                 border: Border.all(width: 1, color: Colors.grey), // Add a grey border
                      //                 borderRadius: BorderRadius.circular(5), // Add a slight rounded corner
                      //               ),
                      //               padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), // Add equal padding
                      //               child: DropdownButton<String>(
                      //                 value: detail.status.toString(), // Current selected value
                      //                 items: <String>['Download','Order', 'Invoice', 'Delivery', 'Payment']
                      //                     .map<DropdownMenuItem<String>>((String value) {
                      //                   return DropdownMenuItem<String>(
                      //                     value: value,
                      //                     child: Text(value),
                      //                   );
                      //                 }).toList(),
                      //                 onChanged: (String? newValue) async {
                      //                   setState(() {
                      //                     detail.status = newValue!; // Update the status based on the selected value
                      //                   });
                      //                   // Perform action based on the selected value
                      //                   if (newValue == 'Order') {
                      //                     await downloadPdf(detail.orderId!); // Download order PDF
                      //                   } else if (newValue == 'Invoice') {
                      //                     await downloadinvoicePdf(detail.orderId!); // Download invoice PDF
                      //                   } else if (newValue == 'Delivery') {
                      //                     await downloaddelPdf(detail.orderId!); // Download delivery PDF
                      //                   } else if (newValue == 'Payment') {
                      //                     await downloadCreditMemoPdf(detail.orderId!); // Download payment PDF
                      //                   }
                      //                 },
                      //                 style: TextStyle(
                      //                   color: isSelected ? Colors.deepOrange[200] : const Color(0xFFFFB315),
                      //                 ),
                      //               ),
                      //             ),
                      //           ),
                      //         ),
                      //
                      //       }
                      //       else if (detail.paymentStatus == 'payment cleared' && detail.deliveryStatus == 'Delivered')...{
                      //           DataCell(
                      //             Padding(
                      //               padding: const EdgeInsets.all(8.0),
                      //               child: Container(
                      //                 decoration: BoxDecoration(
                      //                   border: Border.all(width: 1, color: Colors.grey), // Add a grey border
                      //                   borderRadius: BorderRadius.circular(5), // Add a slight rounded corner
                      //                 ),
                      //                 padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), // Add equal padding
                      //                 child: DropdownButton<String>(
                      //
                      //                   value: detail.status.toString(), // Current selected value
                      //                   items: <String>['Download','Order', 'Invoice', 'Delivery', 'Payment']
                      //                       .map<DropdownMenuItem<String>>((String value) {
                      //                     return DropdownMenuItem<String>(
                      //                       value: value,
                      //                       child: Text(value),
                      //                     );
                      //                   }).toList(),
                      //                   onChanged: (String? newValue) async {
                      //                     setState(() {
                      //                       detail.status = newValue!; // Update the status based on the selected value
                      //                     });
                      //                     // Perform action based on the selected value
                      //                     if (newValue == 'Order') {
                      //                       await downloadPdf(detail.orderId!); // Download order PDF
                      //                     } else if (newValue == 'Invoice') {
                      //                       await downloadinvoicePdf(detail.orderId!); // Download invoice PDF
                      //                     } else if (newValue == 'Delivery') {
                      //                       await downloaddelPdf(detail.orderId!); // Download delivery PDF
                      //                     } else if (newValue == 'Payment') {
                      //                       await downloadCreditMemoPdf(detail.orderId!); // Download payment PDF
                      //                     }
                      //                   },
                      //                   style: TextStyle(
                      //                     color: isSelected ? Colors.deepOrange[200] : const Color(0xFFFFB315),
                      //                   ),
                      //                 ),
                      //               ),
                      //             ),
                      //           ),
                      //
                      //         }
                      //         else...{
                      //             DataCell(
                      //               Padding(
                      //                 padding: const EdgeInsets.all(8.0),
                      //                 child: Container(
                      //                   decoration: BoxDecoration(
                      //                     border: Border.all(width: 1, color: Colors.grey), // Add a grey border
                      //                     borderRadius: BorderRadius.circular(5), // Add a slight rounded corner
                      //                   ),
                      //                   padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), // Add equal padding
                      //                   child: DropdownButton<String>(
                      //                     value: detail.status.toString(), // Current selected value
                      //                     items: <String>['Download', 'Order', 'Invoice', 'Delivery', 'Payment']
                      //                         .map<DropdownMenuItem<String>>((String value) {
                      //                       return DropdownMenuItem<String>(
                      //                         value: value,
                      //                         child: Text(value),
                      //                       );
                      //                     }).toList(),
                      //                     onChanged: (String? newValue) async {
                      //                       setState(() {
                      //                         detail.status = newValue!; // Update the status based on the selected value
                      //                       });
                      //                       // Perform action based on the selected value
                      //                       if (newValue == 'Order') {
                      //                            await downloadPdf(detail.orderId!); // Download order PDF
                      //                       } else if (newValue == 'Invoice') {
                      //                         await downloadinvoicePdf(detail.orderId!); // Download invoice PDF
                      //                       } else if (newValue == 'Delivery') {
                      //                         // await downloaddelPdf(detail.orderId!); // Download delivery PDF
                      //                       } else if (newValue == 'Payment') {
                      //                          await downloadCreditMemoPdf(detail.orderId!); // Download payment PDF
                      //                       }
                      //                     },
                      //                     style: TextStyle(
                      //                       color: isSelected ? Colors.deepOrange[200] : const Color(0xFFFFB315),
                      //                     ),
                      //                   ),
                      //                 ),
                      //               ),
                      //             ),
                      //           }
                    ],
                  );
                })
                //filteredData.skip((currentPage - 1) * itemsPerPage).take(itemsPerPage).map((detail)  {

                //             return DataRow(
                //                 color: MaterialStateColor.resolveWith(
                //                         (states) => isSelected ? Colors.lightBlue[100]! : Colors.white),
                //                 cells: [
                //                   DataCell(
                //                       MouseRegion(
                //                         cursor: SystemMouseCursors.click,
                //                         onEnter: (event) {
                //                           setState(() {
                //                             _selectedProduct = detail;
                //                           });
                //                         },
                //                         onExit: (event) {
                //                           _selectedProduct = null;
                //                         },
                //                         child: GestureDetector(
                //                           onTap: () {
                //                             print(detail.orderDate);
                //                             context.go('/OrdersList', extra: {
                //                               'product': detail,
                //                               'item': [], // pass an empty list of maps
                //                               'body': {},
                //                               'itemsList': [], // pass an empty list of maps
                //                               'orderDetails':filteredData.map((detail) => OrderDetail(
                //                                 orderId: detail.orderId,
                //                                 orderDate: detail.orderDate, items: [],
                //                                 // Add other fields as needed
                //                               )).toList(),
                //                             });
                //                             // Navigator.push(
                //                             //   context,
                //                             //   MaterialPageRoute(
                //                             //       builder: (context) => SixthPage(
                //                             //         product: detail,
                //                             //         item:  const [],
                //                             //         body: const {},
                //                             //         itemsList: const [],
                //                             //         orderDetails: filteredData.map((detail) => OrderDetail(
                //                             //           orderId: detail.orderId,
                //                             //           orderDate: detail.orderDate, items: [],
                //                             //           // Add other fields as needed
                //                             //         )).toList(),
                //                             //         //storeStaticData: storeStaticData,
                //                             //
                //                             //       )
                //                             //   )
                //                             //   , // pass the selected product here
                //                             // );
                //                           },
                //                           child: Container(
                //                             // padding: EdgeInsets.only(left: 40),
                //                               child: Text(detail.status, style: TextStyle(fontSize: 16,color:isSelected ? Colors.deepOrange[200] : const Color(0xFFFFB315) ,),)),
                //                         ),
                //                       )),
                //                   DataCell(
                //                       MouseRegion(
                //                         cursor: SystemMouseCursors.click,
                //                         onEnter: (event) {
                //                           setState(() {
                //                             _selectedProduct = detail;
                //                           });
                //                         },
                //                         onExit: (event) {
                //                           _selectedProduct = null;
                //                         },
                //                         child: GestureDetector(
                //                           onTap: () {
                //                             context.go('/OrdersList', extra: {
                //                               'product': detail,
                //                               'item': [], // pass an empty list of maps
                //                               'body': {},
                //                               'itemsList': [], // pass an empty list of maps
                //                               'orderDetails':filteredData.map((detail) => OrderDetail(
                //                                 orderId: detail.orderId,
                //                                 orderDate: detail.orderDate, items: [],
                //                                 // Add other fields as needed
                //                               )).toList(),
                //                             });
                //                             Navigator.push(
                //                               context,
                //                               MaterialPageRoute(
                //                                   builder: (context) => SixthPage(
                //                                     product: detail,
                //                                     item:  const [],
                //                                     body: const {},
                //                                     itemsList: const [],
                //                                     orderDetails: filteredData.map((detail) => OrderDetail(
                //                                       orderId: detail.orderId,
                //                                       orderDate: detail.orderDate, items: [],
                //                                       // Add other fields as needed
                //                                     )).toList(),
                //                                     //storeStaticData: storeStaticData,
                //                                   )
                //                               )
                //                               , // pass the selected product here
                //                             );
                //                           },
                //                           child: Container(child: Text(detail.orderId!,style: TextStyle(fontSize: 16,color: Colors.grey),)),
                //                         ),
                //                       )),
                //                   DataCell(
                //                     MouseRegion(
                //                         cursor: SystemMouseCursors.click,
                //                         onEnter: (event) {
                //                           setState(() {
                //                             _selectedProduct = detail;
                //                           });
                //                         },
                //                         onExit: (event) {
                //                           _selectedProduct = null;
                //                         },
                //                         child: GestureDetector(
                //                           onTap: () {
                //                             context.go('/OrdersList', extra: {
                //                               'product': detail,
                //                               'item': [], // pass an empty list of maps
                //                               'body': {},
                //                               'itemsList': [], // pass an empty list of maps
                //                               'orderDetails':filteredData.map((detail) => OrderDetail(
                //                                 orderId: detail.orderId,
                //                                 orderDate: detail.orderDate, items: [],
                //                                 // Add other fields as needed
                //                               )).toList(),
                //                             });
                //                             Navigator.push(
                //                               context,
                //                               MaterialPageRoute(
                //                                   builder: (context) => SixthPage(
                //                                     product: detail,
                //                                     item:  const [],
                //                                     body: const {},
                //                                     itemsList: const [],
                //                                     orderDetails: filteredData.map((detail) => OrderDetail(
                //                                       orderId: detail.orderId,
                //                                       orderDate: detail.orderDate, items: [],
                //                                       // Add other fields as needed
                //                                     )).toList(),
                //                                     //storeStaticData: storeStaticData,
                //
                //                                   )
                //                               )
                //                               , // pass the selected product here
                //                             );
                //                           },
                //                           child: Container(child: Padding(
                //                             padding: const EdgeInsets.only(left: 10),
                //                             child: Text(detail.orderDate,style: TextStyle(fontSize: 16,color: Colors.grey)),
                //                           ),
                //                           ),
                //                         )),
                //                   ),
                //                   DataCell(
                //                     MouseRegion(
                //                         cursor: SystemMouseCursors.click,
                //                         onEnter: (event) {
                //                           setState(() {
                //                             _selectedProduct = detail;
                //                           });
                //                         },
                //                         onExit: (event) {
                //                           _selectedProduct = null;
                //                         },
                //                         child: GestureDetector(
                //                           onTap: () {
                //                             context.go('/OrdersList', extra: {
                //                               'product': detail,
                //                               'item': [], // pass an empty list of maps
                //                               'body': {},
                //                               'itemsList': [], // pass an empty list of maps
                //                               'orderDetails':filteredData.map((detail) => OrderDetail(
                //                                 orderId: detail.orderId,
                //                                 orderDate: detail.orderDate, items: [],
                //                                 // Add other fields as needed
                //                               )).toList(),
                //                             });
                //                             Navigator.push(
                //                               context,
                //                               MaterialPageRoute(
                //                                   builder: (context) => SixthPage(
                //                                     product: detail,
                //                                     item:  const [],
                //                                     body: const {},
                //                                     itemsList: const [],
                //                                     orderDetails: filteredData.map((detail) => OrderDetail(
                //                                       orderId: detail.orderId,
                //                                       orderDate: detail.orderDate, items: [],
                //                                       // Add other fields as needed
                //                                     )).toList(),
                //                                     //storeStaticData: storeStaticData,
                //
                //                                   )
                //                               )
                //                               , // pass the selected product here
                //                             );
                //                           },
                //                           child: Container(child: Text(detail.referenceNumber,style: TextStyle(fontSize: 16,color: Colors.grey)),
                //                           ),
                //                         )),
                //                   ),
                //                   DataCell(
                //                     MouseRegion(
                //                         cursor: SystemMouseCursors.click,
                //                         onEnter: (event) {
                //                           setState(() {
                //                             _selectedProduct = detail;
                //                           });
                //                         },
                //                         onExit: (event) {
                //                           _selectedProduct = null;
                //                         },
                //                         child: GestureDetector(
                //                           onTap: () {
                //                             context.go('/OrdersList', extra: {
                //                               'product': detail,
                //                               'item': [], // pass an empty list of maps
                //                               'body': {},
                //                               'itemsList': [], // pass an empty list of maps
                //                               'orderDetails':filteredData.map((detail) => OrderDetail(
                //                                 orderId: detail.orderId,
                //                                 orderDate: detail.orderDate, items: [],
                //                                 // Add other fields as needed
                //                               )).toList(),
                //                             });
                //                             Navigator.push(
                //                               context,
                //                               MaterialPageRoute(
                //                                   builder: (context) => SixthPage(
                //                                     product: detail,
                //                                     item:  const [],
                //                                     body: const {},
                //                                     itemsList: const [],
                //                                     orderDetails: filteredData.map((detail) => OrderDetail(
                //                                       orderId: detail.orderId,
                //                                       orderDate: detail.orderDate, items: [],
                //                                       // Add other fields as needed
                //                                     )).toList(),
                //                                     //storeStaticData: storeStaticData,
                //
                //                                   )
                //                               )
                //                               , // pass the selected product here
                //                             );
                //                           },
                //                           child: Container(child: Padding(
                //                             padding: const EdgeInsets.only(left: 10),
                //                             child: Text(detail.total.toString(),style: TextStyle(fontSize: 16,color: Colors.grey)),
                //                           ),
                //                           ),
                //                         )),
                //                   ),
                //                   DataCell(
                //                     MouseR
                //                         cursor: SystemMouseCursors.click,
                //                         onEnter: (event) {
                //                           setState(() {
                //                             _selectedProduct = detail;
                //                           });
                //                         },
                //                         onExit: (event) {
                //                           _selectedProduct = null;
                //                         },
                //                         child: GestureDetector(
                //                           onTap: () {
                //                             context.go('/OrdersList', extra: {
                //                               'product': detail,
                //                               'item': [], // pass an empty list of maps
                //                               'body': {},
                //                               'itemsList': [], // pass an empty list of maps
                //                               'orderDetails':filteredData.map((detail) => OrderDetail(
                //                                 orderId: detail.orderId,
                //                                 orderDate: detail.orderDate, items: [],
                //                                 // Add other fields as needed
                //                               )).toList(),
                //                             });
                //                             Navigator.push(
                //                               context,
                //                               MaterialPageRoute(
                //                                   builder: (context) => SixthPage(
                //                                     product: detail,
                //                                     item:  const [],
                //                                     body: const {},
                //                                     itemsList: const [],
                //                                     orderDetails: filteredData.map((detail) => OrderDetail(
                //                                       orderId: detail.orderId,
                //                                       orderDate: detail.orderDate, items: [],
                //                                       // Add other fields as needed
                //                                     )).toList(),
                //                                     //storeStaticData: storeStaticData,
                //
                //                                   )
                //                               )
                //                               , // pass the selected product here
                //                             );
                //                           },
                //                           child: Container(child: Padding(
                //                             padding: const EdgeInsets.only(left: 10),
                //                             child: Text(detail.deliveryStatus,style: TextStyle(fontSize: 16,color: Colors.grey)),
                //                           ),
                //                           ),
                //                         )),
                //                   ),
                //
                //                 ]
                // );
                //           }).toList(),
                ),
          ),
        ],
      );
    });
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
