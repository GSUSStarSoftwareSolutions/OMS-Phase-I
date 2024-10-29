import 'dart:async';
import 'dart:convert';
import 'dart:html';
import 'dart:typed_data';
import 'package:btb/admin/Api%20name.dart';
import 'package:btb/pdf/delivery%20note%20pdf.dart';
import 'package:btb/widgets/confirmdialog.dart';
import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart'as http;
import '../pdf/invoice pdf.dart';
import '../pdf/order bill pdf.dart';
import '../pdf/payment pdf.dart';
import 'firstpage.dart';

void main(){
  runApp(MaterialApp(home:EighthPage(orderDetails: [],),));
}

class EighthPage extends StatefulWidget {
  final Map<String, dynamic>? selectedProductMap;
  final List<dynamic>? orderDetails;
  final String? orderId;
  final String? string;
  final String? deliveryStatus;
  final String? Date;
  final Map<String, dynamic>? paymentStatus;
  final String? Location;
  final String? Total;
  final String? contactNo;
  final String? InvNo;
  const EighthPage({super.key,this.string,this.selectedProductMap,required this.orderDetails,this.orderId,this.deliveryStatus, this.paymentStatus,this.InvNo,this.Total,this.contactNo,this.Location,this.Date});

  @override
  State<EighthPage> createState() => _EighthPageState();
}

class _EighthPageState extends State<EighthPage> {
  final _formKey = GlobalKey<FormState>();
  Map<String, dynamic> data2 = {};
  bool _hasShownPopup = false;
  final TextEditingController deliveryStatusController = TextEditingController();
  DateTime? _selectedDate;
  final TextEditingController deliveryLocationController = TextEditingController();
  List<Map<String, dynamic>> selectedItems = [];
  String _searchText = '';
  Timer? _timer;
  final TextEditingController paymentStatusController = TextEditingController();
  final TextEditingController deliveryAddressController = TextEditingController();
  final TextEditingController contactPersonController = TextEditingController();
  final TextEditingController contactNumberController = TextEditingController();
  final TextEditingController commentsController = TextEditingController();
  final List<String> list = ['  Name 1', '  Name 2', '  Name3'];
  final TextEditingController CreatedDateController = TextEditingController();
  final TextEditingController orderIdController = TextEditingController();
  final TextEditingController PaymentIdController = TextEditingController();
  final TextEditingController PaidAmount = TextEditingController();
  late TextEditingController PaymentModeController = TextEditingController();
  late TextEditingController PaymentDate = TextEditingController();
  final TextEditingController totalController = TextEditingController();
  final TextEditingController productNameController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();
  final TextEditingController subCategoryController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController qtyController = TextEditingController();
  final TextEditingController InvNoController = TextEditingController();
  late TextEditingController DeliveryId = TextEditingController();
  final TextEditingController Deliverydate = TextEditingController();
  final TextEditingController DeliveryAddress = TextEditingController();
  final TextEditingController DeliveryStatus = TextEditingController();

  bool? _isChecked1 = true;
  bool? _isChecked2 = true;

  String token = window.sessionStorage["token"]?? " ";
  List<Map> _orders = [];
  bool _loading = false;
  bool _isFirstLoad = true;

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

  bool _isLoading = false;
  Map<String, dynamic> _selectedProductMap = {};
  bool isEditing = false;
  List<bool> _isSelected = [];
  late TextEditingController _dateController;
  bool? _isChecked3 = false;
  bool? _isChecked4 = false;
  final TextEditingController ContactNoController = TextEditingController();
  final TextEditingController totalAmountController = TextEditingController();
  bool isOrdersSelected = false;
  String _errorMessage = '';
  final _orderIdController = TextEditingController();


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isFirstLoad) {
      print('didichange');
      _isFirstLoad = false;
      for (int i = 0; i < widget.orderDetails!.length; i++) {
        if (orderIdController.text == widget.orderDetails![i].orderId) {
          setState(() {
            var selectedItem = widget.orderDetails![i];
            widget.orderDetails!.removeAt(i);
            widget.orderDetails!.insert(0, selectedItem);
            for (int j = 0; j < _isSelected.length; j++) {
              _isSelected[j] = j == 0;
            }
          });
          break;
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchOrders();
    print('from sixth orderid');
    PaymentModeController = TextEditingController();
     PaymentDate = TextEditingController();
     DeliveryId = TextEditingController();
    // print(widget.orderId);
    // print(widget.deliveryStatus ?? '');
    // //print(widget.paymentStatus);
    // //  print(widget.InvNo);
    //
    // print('total');
    // print(widget.Location);
    // print(widget.Date);
    //  print(widget.selectedProductMap)
    totalAmountController.text = widget.Total ?? '';
    ContactNoController.text = widget.contactNo ?? '';
    CreatedDateController.text = widget.Date ?? '';
    _fetchOrderDetails1(widget.orderId!);
    deliveryStatusController.text = widget.deliveryStatus! ?? '';
    InvNoController.text = widget.InvNo ?? '';
    ContactNoController.text = widget.contactNo ?? '';
    totalAmountController.text = widget.Total!;
    orderIdController.text = widget.orderId!;
    deliveryLocationController.text= widget.Location ?? '';
    paymentStatusController.text = widget.paymentStatus!['paymentStatus'] ?? '';
    PaymentIdController.text = widget.paymentStatus!['paymentId'] ?? '';
    PaymentModeController.text = widget.paymentStatus!['paymentmode'] ?? '';
    PaidAmount.text = widget.paymentStatus!['paidamount'].toString();
    PaymentDate.text = widget.paymentStatus!['paymentdate'] ?? '';
    _orderIdController.addListener(_fetchOrders);
    _dateController = TextEditingController();
    print(widget.orderDetails);
    _isLoading =true;
    _timer = Timer(Duration(seconds: 1), () {
      setState(() {
        _isLoading = false;
      });
    });

    _isSelected = List<bool>.filled(widget.orderDetails?.length ?? 0, false);

    print('selectinde');
    //print(_selectedIndex);

    print(_isSelected);
    _selectedDate = DateTime.now();
    _dateController.text = DateFormat.yMd().format(_selectedDate!);
  }

  @override
  void dispose() {
    _orderIdController.removeListener(_fetchOrders);
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _fetchOrders() async {
    setState(() {
      _loading = true;
      _orders = []; // clear the orders list
      _errorMessage = ''; // clear the error message
    });
    try {
      final orderId = _orderIdController.text
          .trim(); // trim to remove whitespace
      final url = orderId.isEmpty
          ? '$apicall/order_master/get_all_ordermaster'
          : '$apicall/order_master/search_by_orderid/$orderId';
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token', // Replace with your API key
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final responseBody = response.body;
        if (responseBody != null) {
          final jsonData = jsonDecode(responseBody).cast<
              Map<dynamic, dynamic>>();
          setState(() {
            _orders =
                jsonData; // update _orders with all orders or search results
            _errorMessage = ''; // clear the error message
          });
        } else {
          setState(() {
            _orders = []; // clear the orders list
            _errorMessage = 'Failed to load orders';
          });
        }
      } else {
        setState(() {
          _orders = []; // clear the orders list
          _errorMessage = 'Failed to load orders';
        });
      }
    } catch (e) {
      setState(() {
        _orders = []; // clear the orders list
        _errorMessage = 'Error: $e';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }



  }



  Future<void> _fetchOrderDetails1(String orderId) async {

    try {
      final url = '$apicall/order_master/search_by_orderid/$orderId';
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token', // Replace with your API key
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final responseBody = response.body;
        print('search');
        print(responseBody);
        // print(responseBody['status' as int]);
        final jsonData = jsonDecode(responseBody);
        if (jsonData is List<dynamic>) {
          final jsonObject = jsonData.first;


          print(jsonObject);
          final orderDetails = OrderDetail.fromJson(jsonObject);
          print('orderDetails');
          //  print(orderDetails);
          _showProductDetails(orderDetails);
        } else {
          print('Failed to load order details');
        }
      } else {
        print('Failed to load order details');
      }
    } catch (e) {
      // print('Error: $e');
      setState(() {
        _isLoading = false;
        //_hasError = true;
      });
    }finally {
      // Timer(Duration(seconds: 10), () {
      //   setState(() {
      //     _isLoading = false;
      //   });
      // });
      //}
      setState(() {
        _isLoading = true;
      });
    }
  }

  Future<OrderDetail?> _fetchOrderDetails(String orderId) async {
    //String token = 'eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJkaGFuYXNla2FyIiwiUm9sZXMiOlt7ImF1dGhvcml0eSI6ImRldmVsb3BlciJ9XSwiZXhwIjoxNzI0ODMyMjUzLCJpYXQiOjE3MjQ4MjUwNTN9.-HLZdMO9251y0hm5saV5EP4YBu6JKJgtZKiEahCLcw5OKNuSIUaTTZ1vtKnwYj4SgQMoHMpu8dZihvNUTYv3Ig';
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


  Future downloadDeliverypdf() async {
    // final String orderId = 'ORD_02282';
    final String orderId = orderIdController.text;
    print('ord');
    print(orderId);
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

  // Future<void> _fetchOrderDetails(String orderId) async {
  //
  //   try {
  //     final url = '$apicall/order_master/search_by_orderid/$orderId';
  //     final response = await http.get(
  //       Uri.parse(url),
  //       headers: {
  //         'Authorization': 'Bearer $token', // Replace with your API key
  //         'Content-Type': 'application/json',
  //       },
  //     );
  //
  //     if (response.statusCode == 200) {
  //       final responseBody = response.body;
  //       print('search');
  //       print(responseBody);
  //       // print(responseBody['status' as int]);
  //       final jsonData = jsonDecode(responseBody);
  //       if (jsonData is List<dynamic>) {
  //         final jsonObject = jsonData.first;
  //
  //
  //         print(jsonObject);
  //         final orderDetails = OrderDetail.fromJson(jsonObject);
  //         print('orderDetails');
  //         //  print(orderDetails);
  //         _showProductDetails(orderDetails);
  //       } else {
  //         print('Failed to load order details');
  //       }
  //     } else {
  //       print('Failed to load order details');
  //     }
  //   } catch (e) {
  //     // print('Error: $e');
  //     setState(() {
  //       _isLoading = false;
  //       _hasError = true;
  //     });
  //   }finally {
  //     // Timer(Duration(seconds: 10), () {
  //     //   setState(() {
  //     //     _isLoading = false;
  //     //   });
  //     // });
  //     //}
  //     setState(() {
  //       _isLoading = true;
  //     });
  //   }
  // }

  // Future<OrderDetail?> _fetchDeliveryDetails(String orderId) async {
  //   //String token = 'eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJkaGFuYXNla2FyIiwiUm9sZXMiOlt7ImF1dGhvcml0eSI6ImRldmVsb3BlciJ9XSwiZXhwIjoxNzIzMTE0OTQ0LCJpYXQiOjE3MjMxMDc3NDR9.1UxLslHM3GivBHoBr8pS02OxD6dC5IRG4ryxiUdgzIJmFjSCwftf6Kme4rPLb-ZOjzOoAaxueSzKxiLmjnmSFg';
  //   try {
  //     final url = '$apicall/order_master/search_by_orderid/$orderId';
  //     final response = await http.get(
  //       Uri.parse(url),
  //       headers: {
  //         'Authorization': 'Bearer $token',
  //         'Content-Type': 'application/json',
  //       },
  //     );
  //     if (response.statusCode == 200) {
  //       final responseBody = response.body;
  //       print('onTap');
  //       print(responseBody);
  //       if (responseBody != null) {
  //         final jsonData = jsonDecode(responseBody);
  //         if (jsonData is List<dynamic>) {
  //           final jsonObject = jsonData.first;
  //
  //           print(jsonObject);
  //           final orderDetails = OrderDetail.fromJson(jsonObject);
  //           print('orderDetails');
  //           print(orderDetails);
  //           _showProductDetails(orderDetails);
  //
  //         } else {
  //           print('Failed to load order details');
  //         }
  //       } else {
  //         print('Failed to load order details');
  //       }
  //     } else {
  //       print('Failed to load order details');
  //     }
  //   } catch (e) {
  //     print('Error: $e');
  //   }
  //   return null;
  // }

  Future<List<dynamic>> _fetchAllProductMaster() async {
    //final String token = 'eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJkaGFuYXNla2FyIiwiUm9sZXMiOlt7ImF1dGhvcml0eSI6ImRldmVsb3BlciJ9XSwiZXhwIjoxNzIzMTE0OTQ0LCJpYXQiOjE3MjMxMDc3NDR9.1UxLslHM3GivBHoBr8pS02OxD6dC5IRG4ryxiUdgzIJmFjSCwftf6Kme4rPLb-ZOjzOoAaxueSzKxiLmjnmSFg';
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
  Future downloadInvoicePdf() async {
    final String orderId = orderIdController.text;
    print('download');
    print(orderIdController.text);
    print(orderId);

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


  Future downloadPdf() async {
    final String orderId = orderIdController.text;
    print('download');
    print(orderIdController.text);
    print(orderId);

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
        final Uint8List pdfBytes = await OrderBillPdf(orderDetails);
        final blob = html.Blob([pdfBytes]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute('download', 'Order.pdf')
          ..click();
        html.Url.revokeObjectUrl(url);
      } else {
        print('Failed to fetch order details.');
      }
    } catch (e) {
      print('Error generating PDF: $e');
    }
  }


  List<Widget> _buildMenuItems(BuildContext context) {
    return [
      _buildMenuItem('Home', Icons.dashboard, Colors.blue[900]!, '/Home'),
      _buildMenuItem('Customer', Icons.account_circle, Colors.blue[900]!, '/Customer'),
      _buildMenuItem('Products', Icons.image_outlined, Colors.blue[900]!, '/Product_List'),
      _buildMenuItem('Orders', Icons.warehouse, Colors.blueAccent, '/Order_List'),
      _buildMenuItem('Invoice', Icons.document_scanner_rounded, Colors.blue[900]!, '/Invoice'),
      _buildMenuItem('Delivery', Icons.fire_truck_outlined, Colors.blue[900]!, '/Delivery_List'),
      _buildMenuItem('Payment', Icons.payment_outlined, Colors.blue[900]!, '/Payment_List'),
      _buildMenuItem('Return', Icons.backspace_sharp, Colors.blue[900]!, '/Return_List'),
      _buildMenuItem('Reports', Icons.insert_chart, Colors.blue[900]!, '/Report_List'),
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


  Future<List<dynamic>> _fetchAllproductpayment() async {
  //  final String token = 'eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJkaGFuYXNla2FyIiwiUm9sZXMiOlt7ImF1dGhvcml0eSI6ImRldmVsb3BlciJ9XSwiZXhwIjoxNzI2MTQzMzMwLCJpYXQiOjE3MjYxMzYxMzB9.azbMgCL63olMUbpF0BaXhXAM2oEuXk7AkWMAtTAXuinBjy15IlqFyu0gvoFdGqtwJbFfZXVgIgGFnYmbgAKkoQ';
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

  Future<OrderDetail?> _fetchOrderDetailspayment(String orderId) async {
   // String token = 'eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJkaGFuYXNla2FyIiwiUm9sZXMiOlt7ImF1dGhvcml0eSI6ImRldmVsb3BlciJ9XSwiZXhwIjoxNzI2MTQzMzMwLCJpYXQiOjE3MjYxMzYxMzB9.azbMgCL63olMUbpF0BaXhXAM2oEuXk7AkWMAtTAXuinBjy15IlqFyu0gvoFdGqtwJbFfZXVgIgGFnYmbgAKkoQ';
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
            item['discountamount'] = (double.parse(item['totalAmount'].toString()) * double.parse(item['discount'].replaceAll('%', ''))) / 100;
            item['taxamount'] = ((double.parse(item['totalAmount'].toString()) -
                double.parse(item['discountamount'].toString())) *
                double.parse(item['tax'].replaceAll('%', '').toString())) / 100;
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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar:  AppBar(
          leading: null,
          automaticallyImplyLeading: false,
          backgroundColor: const Color(0xFFFFFFFF),
          title: Image.asset("images/Final-Ikyam-Logo.png"),
          // Set background color to white
          elevation: 2.0,
          shadowColor: const Color(0xFFFFFFFF),
          // Set shadow color to black
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 15),
              child: IconButton(
                icon: const Icon(Icons.notifications),
                onPressed: () {
                  // Handle notification icon press
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child:
              AccountMenu(),
            ),
          ],
        ),
        body: LayoutBuilder(
            builder: (context, constraints){
              double maxHeight = constraints.maxHeight;
              double maxWidth = constraints.maxWidth;
              return Row(
                children: [
                  Align(
                    // Added Align widget for the left side menu
                    alignment: Alignment.topLeft,
                    child: Container(
                      height: 984,
                      width: 200,
                      color: const Color(0xFFF7F6FA),
                      padding: const EdgeInsets.only(left: 20, top: 30),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: _buildMenuItems(context),
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 1), // Space above/below the border
                    height: 984,
                    // width: 1500,
                    width:0.5,// Border height
                    color: Colors.black, // Border color
                  ),
                  Container(
                    margin: const EdgeInsets.only(
                      //  top: 56,
                      left: 1,
                    ),
                    width: 298,
                    height: 933,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFFFF),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 5),
                                child: IconButton(
                                  icon:
                                  const Icon(Icons.arrow_back), // Back button icon
                                  onPressed: () {
                                    context.go('/Order_List');
                                    // Navigator.push(
                                    //   context,
                                    //   MaterialPageRoute(
                                    //       builder: (context) =>
                                    //       const Orderspage()),
                                    // );
                                  },
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(left: 15,top: 10),
                                child: Text(
                                  'Order List',
                                  style: TextStyle(
                                    fontSize: 19,
                                    //  fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                          // Divider(),
                          Padding(
                            padding: const EdgeInsets.only(top: 0, left: 0),
                            child: Container(
                              margin: const EdgeInsets.symmetric(
                                  vertical: 5), // Space above/below the border
                              height: 0.5,
                              // width: 1500,
                              width: constraints.maxWidth,// Border height
                              color: Colors.black, // Border color
                            ),
                          ),
                          SizedBox(
                            height: 50,
                            width: 60,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  left: 15, right: 15, bottom: 5,top: 10 ),
                              child: TextFormField(
                                controller: _orderIdController, // Assign the controller to the TextFormField
                                decoration: const InputDecoration(
                                  // labelText: 'Order ID',
                                  hintText: 'Search Order',
                                  contentPadding: EdgeInsets.all(8),
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.search_outlined),
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    _searchText = value.toLowerCase();
                                  });
                                },
                              ),
                            ),
                          ),
                          //const SizedBox(height: 2),
                          Expanded(child: SingleChildScrollView(child: Column(children: [
                            _loading
                                ? const Center(child: CircularProgressIndicator(strokeWidth: 4))
                                : _errorMessage.isNotEmpty
                                ? Center(child: Text(_errorMessage))
                                : widget.orderDetails!.isEmpty
                                ? const Center(child: Text('No product found'))
                                : ListView.separated(
                              shrinkWrap: true,
                              itemCount: _searchText.isNotEmpty
                                  ? widget.orderDetails!.where((orderDetail) =>
                              orderDetail.orderId.toLowerCase().contains(_searchText.toLowerCase()) ||
                                  orderDetail.orderDate.toLowerCase().contains(_searchText.toLowerCase())
                              ).length
                                  : widget.orderDetails!.length,
                              itemBuilder: (context, index) {
                                final filteredOrderDetails = _searchText.isNotEmpty
                                    ? widget.orderDetails!.where((orderDetail) =>
                                orderDetail.orderId.toLowerCase().contains(_searchText.toLowerCase()) ||
                                    orderDetail.orderDate.toLowerCase().contains(_searchText.toLowerCase())
                                ).toList()
                                    : widget.orderDetails!;

                                final orderDetail = filteredOrderDetails[index];

                                final isSelectedIndex = _searchText.isNotEmpty
                                    ? filteredOrderDetails.indexOf(orderDetail)
                                    : index;

                                return GestureDetector(
                                  onTap: () async {
                                    _timer = Timer(Duration(seconds: 1), () {
                                      setState(() {
                                        _isLoading = false;
                                      });
                                    });
                                    setState(() {
                                      _isLoading = false;
                                      for (int i = 0; i < _isSelected.length; i++) {
                                        _isSelected[i] = i == isSelectedIndex;
                                      }
                                      orderIdController.text = orderDetail.orderId;
                                    });
                                    await _fetchOrderDetails1(orderDetail.orderId);
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    decoration: BoxDecoration(
                                      color: _isSelected[isSelectedIndex] ? Colors.lightBlue[100] : Colors.white,
                                    ),
                                    child: ListTile(
                                      title: Text('Order ID: ${orderDetail?.orderId}'),
                                      subtitle: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('Order Date: ${orderDetail?.orderDate}'),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                              separatorBuilder: (context, index) {
                                return const Divider();
                              },
                            )
                            // _loading
                            //     ? const Center(child: CircularProgressIndicator(strokeWidth: 4))
                            //     : _errorMessage.isNotEmpty
                            //     ? Center(child: Text(_errorMessage))
                            //     : widget.orderDetails!.isEmpty
                            //     ? const Center(child: Text('No product found'))
                            //     : ListView.separated(
                            //   shrinkWrap: true,
                            //   itemCount: _searchText.isNotEmpty
                            //       ? widget.orderDetails!.where((orderDetail) =>
                            //   orderDetail.orderId.toLowerCase().contains(_searchText.toLowerCase()) ||
                            //       orderDetail.orderDate.toLowerCase().contains(_searchText.toLowerCase())
                            //   ).length
                            //       : widget.orderDetails!.length,
                            //   itemBuilder: (context, index) {
                            //     final isSelected = _isSelected[index];
                            //     final orderDetail = _searchText.isNotEmpty
                            //         ? widget.orderDetails!.where((orderDetail) =>
                            //     orderDetail.orderId.toLowerCase().contains(_searchText.toLowerCase()) ||
                            //         orderDetail.orderDate.toLowerCase().contains(_searchText.toLowerCase())
                            //     ).toList().isEmpty ? null : widget.orderDetails!.where((orderDetail) =>
                            //     orderDetail.orderId.toLowerCase().contains(_searchText.toLowerCase()) ||
                            //         orderDetail.orderDate.toLowerCase().contains(_searchText.toLowerCase())
                            //     ).elementAt(index)
                            //         : widget.orderDetails![index];
                            //
                            //
                            //     return GestureDetector(
                            //       onTap: ()  {
                            //
                            //         _timer = Timer(Duration(seconds: 1), () {
                            //           setState(() {
                            //             _isLoading = false;
                            //           });
                            //         });
                            //         setState(() {
                            //           _isLoading = false;
                            //           for (int i = 0; i < _isSelected.length; i++) {
                            //             _isSelected[i] = i == index;
                            //           }
                            //           orderIdController.text = orderDetail.orderId;
                            //         });
                            //       },
                            //       child: AnimatedContainer(
                            //         duration: const Duration(milliseconds: 200),
                            //         decoration: BoxDecoration(
                            //           color: isSelected ? Colors.lightBlue[100] : Colors.white,
                            //         ),
                            //         child: ListTile(
                            //           title: Text('Order ID: ${orderDetail?.orderId}'),
                            //           subtitle: Column(
                            //             crossAxisAlignment: CrossAxisAlignment.start,
                            //             children: [
                            //               Text('Order Date: ${orderDetail?.orderDate}'),
                            //             ],
                            //           ),
                            //         ),
                            //       ),
                            //     );
                            //   },
                            //   separatorBuilder: (context, index) {
                            //     return const Divider();
                            //   },
                            // )
                          ],),))

                        ],
                      ),
                    ),

                  ),
                  Expanded(child: SingleChildScrollView(child: Stack(children: [
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: Padding(
                        padding: const EdgeInsets.only(
                          top: 0,
                          left: 0,
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          color: Colors.white,
                          height: 50,
                          child: Row(
                            children: [

                              // Padding(
                              //   padding: const EdgeInsets.only(left: 80),
                              //   child: IconButton(
                              //     icon: Icon(Icons.arrow_circle_left_rounded,color: Colors.blue,),
                              //     tooltip: 'Go Back', onPressed: () {  },
                              //   ),
                              // ),
                              // Text('Go back')
                            ],
                          ),
                        ),
                      ),
                    ),

                    Container(
                      width: 0.8, // Set the width to 1 for a vertical line
                      height: 984, // Set the height to your liking
                      decoration: BoxDecoration(
                        border: Border(left: BorderSide(width: 1, color: Colors.black54)),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 40, left: 0),
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                            vertical: 10), // Space above/below the border
                        height: 0.5,
                        // width: 1500,
                        width: constraints.maxWidth,// Border height
                        color: Colors.black, // Border color
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.only(left: 80, top: 100,right: 60),
                      child: Container(
                        height: 100,
                        width: maxWidth,
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFB2C2D3), width: 2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child:  Padding(
                          padding: EdgeInsets.only(top: 30),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Expanded(
                                flex: 1,
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.check_box,
                                      color: Colors.green,
                                    ),
                                    Text(
                                      'Order',
                                      style: TextStyle(
                                          color: Colors.black,fontWeight: FontWeight.bold
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.check_box,
                                      color: Colors.green,
                                    ),
                                    Text(
                                      'Invoice',
                                      style: TextStyle(
                                          color: Colors.black,fontWeight: FontWeight.bold
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.check_box,
                                      color: deliveryStatusController.text == 'Not Started'
                                          ? Colors.grey
                                          :deliveryStatusController.text == 'Delivered'
                                          ? Colors.green
                                          : Colors.grey, // default color
                                    ),
                                    Text(
                                      deliveryStatusController.text == 'In Progress' ? '    Delivery\n(In Progress)' : 'Delivered',
                                      style: TextStyle(
                                        color: deliveryStatusController.text == 'Not Started'
                                            ? Colors.grey
                                            : deliveryStatusController.text == 'In Progress'
                                            ? Colors.grey
                                            : Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.check_box,
                                      color:  paymentStatusController.text == 'partial payment' || paymentStatusController.text=='cleared'? Colors.green: Colors.grey,
                                    ),
                                    Text(
                                      'Payments',
                                      style: TextStyle(
                                        color: paymentStatusController.text == 'partial payment' || paymentStatusController.text=='cleared'? Colors.black: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 80, top: 270,right: 60),
                      child: Container(
                        height: 115,
                        width: constraints.maxWidth * 0.7,
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFB2C2D3), width: 2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(top: 2,bottom: 3),
                              child: Row(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(left: 30),
                                    child: Text('Order',style: TextStyle(fontWeight: FontWeight.bold),),
                                  ),
                                  Spacer(),
                                  Text('Available for Download'),
                                  SizedBox(width: 5,),
                                  Padding(
                                    padding: EdgeInsets.only(right: 10),
                                    child: IconButton(
                                      onPressed: (){
                                        downloadPdf();
                                      },
                                      color: Colors.green, icon: Icon(Icons.download_for_offline),),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              height: 1, // 1 pixel height
                              width: double.infinity, // match parent width
                              color: Colors.grey, // adjust the color to your liking
                            ),
                            const SizedBox(height: 20,),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Expanded(
                                  flex: 1,
                                  child:Column(
                                    children: [
                                      Text('ORDER ID'),
                                      Text('${orderIdController.text}'),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Column(
                                    children: [
                                      Text('Date'),
                                      Text('${CreatedDateController.text}'),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Column(
                                    children: [
                                      Text('Contact No'),
                                      Text('${ContactNoController.text}'),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Column(
                                    children: [
                                      Text('Location'),
                                      Text('${deliveryLocationController.text}'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 80, top: 780,right: 60),
                      child: Container(
                        height: 115,
                        width: constraints.maxWidth * 0.7,
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFB2C2D3), width: 2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(top: 2,bottom: 3),
                              child: Row(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(left: 30),
                                    child: Text('Payment',style: TextStyle(fontWeight: FontWeight.bold),),
                                  ),
                                  Spacer(),
                                  Text('Available for Download'),
                                  SizedBox(width: 5,),
                                  Padding(
                                    padding: EdgeInsets.only(right: 10),
                                    child:
                                    IconButton(
                                      onPressed:(){
                                        print(PaymentIdController.text);
                                        paymentStatusController.text == 'cleared' || paymentStatusController.text == 'partial payment'
                                            ? downloadPaymentReceipt(orderIdController.text)
                                            : null;
                                      },
                                      color: paymentStatusController.text == '-'
                                          ? Colors.grey
                                          :  paymentStatusController.text == 'cleared' || paymentStatusController.text == 'partial payment'
                                          ? Colors.green
                                          : Colors.grey,
                                      icon: Icon(Icons.download_for_offline),
                                      // enabled: deliveryStatusController.text == 'In Progress' || deliveryStatusController.text == 'Delivered',
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            Container(
                              height: 1, // 1 pixel height
                              width: double.infinity, // match parent width
                              color: Colors.grey, // adjust the color to your liking
                            ),
                            const SizedBox(height: 20,),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Expanded(
                                  flex: 1,
                                  child:Column(
                                    children: [
                                      Text('Payment ID'),
                                      Text('${PaymentIdController.text}'),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Column(
                                    children: [
                                      Text('Date'),
                                      Text('${PaymentDate.text}'),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Column(
                                    children: [
                                      Text('Payment Mode'),
                                      Text('${PaymentModeController.text}'),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Column(
                                    children: [
                                      Text('Status'),
                                      Text('${paymentStatusController.text}'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(

                      padding: const EdgeInsets.only(left: 80, top: 440,right: 60),
                      child: Container(
                        height: 115,
                        width: constraints.maxWidth * 0.7,
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFB2C2D3), width: 2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(top: 2,bottom: 3),
                              child: Row(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(left: 30),
                                    child: Text('Invoice',style: TextStyle(fontWeight: FontWeight.bold),),
                                  ),
                                  Spacer(),
                                  Text('Available for Download'),
                                  SizedBox(width: 5,),
                                  Padding(
                                    padding: EdgeInsets.only(right: 10),
                                    child:IconButton(
                                      onPressed: (){
                                        downloadInvoicePdf();
                                      },
                                      color: Colors.green, icon: Icon(Icons.download_for_offline),),
                                  ),
                                ],
                              ),
                            ),

                            Container(
                              height: 1, // 1 pixel height
                              width: double.infinity, // match parent width
                              color: Colors.grey, // adjust the color to your liking
                            ),
                            const SizedBox(height: 20,),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Expanded(
                                  flex: 1,
                                  child:Column(
                                    children: [
                                      Text('INV_NO'),
                                      Text('${InvNoController.text}'),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Column(
                                    children: [
                                      Text('Date'),
                                      Text('${CreatedDateController.text}'),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Column(
                                    children: [
                                      Text('Location'),
                                      Text('${deliveryLocationController.text}'),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Column(
                                    children: [
                                      Text('Gross Amount'),
                                      Text('${totalAmountController.text}'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 80, top: 610,right: 60),
                      child: Container(
                        height: 115,
                        width: constraints.maxWidth * 0.7,
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFB2C2D3), width: 2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            Padding(
                              padding:const EdgeInsets.only(top: 2,bottom: 3),
                              child: Row(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(left: 30),
                                    child: Text('Delivery',style: TextStyle(fontWeight: FontWeight.bold),),
                                  ),
                                  Spacer(),
                                  Text('Available for Download'),
                                  SizedBox(width: 5,),
                                  Padding(
                                    padding: EdgeInsets.only(right: 10),
                                    child: IconButton(
                                      onPressed:(){
                                        deliveryStatusController.text == 'Delivered'
                                            ? downloadDeliverypdf()
                                            : null;
                                      },
                                      color: deliveryStatusController.text == 'Not Started'
                                          ? Colors.grey
                                          :  deliveryStatusController.text == 'Delivered'
                                          ? Colors.green
                                          : Colors.grey,
                                      icon: Icon(Icons.download_for_offline),
                                      // enabled: deliveryStatusController.text == 'In Progress' || deliveryStatusController.text == 'Delivered',
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            Container(
                              height: 1, // 1 pixel height
                              width: double.infinity, // match parent width
                              color: Colors.grey, // adjust the color to your liking
                            ),
                            const SizedBox(height: 20,),
                             Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Expanded(
                                  flex: 1,
                                  child:Column(
                                    children: [
                                      Text('Delivery ID'),
                                      Text('${DeliveryId.text}'),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Column(
                                    children: [
                                      Text('Delivery Date'),
                                      Text('${Deliverydate.text}'),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Column(
                                    children: [
                                      Text('Delivery Location'),
                                      Text('${DeliveryAddress.text}'),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Column(
                                    children: [
                                      Text('Delivery Status'),
                                      Text('${DeliveryStatus.text}'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],),))
                ],
              );
            }
        )
    );
  }

  void _showProductDetails(OrderDetail selectedOrderDetails) {
    print('hi showprodc');
    setState(() {
      PaymentModeController.text = selectedOrderDetails.paymentMode ?? '';
      PaymentDate.text = selectedOrderDetails.paymentDate ?? '';
      DeliveryId.text = selectedOrderDetails.deliveryId ?? '';
      Deliverydate.text = selectedOrderDetails.deliveredDate ?? '';
      DeliveryAddress.text = selectedOrderDetails.deliveryAddress ?? '';
      DeliveryStatus.text = selectedOrderDetails.status ?? '';
    });
    // final selectedOrderDetails = _orders[index];
    InvNoController.text = selectedOrderDetails.InvNo ?? '';
    totalAmountController.text = selectedOrderDetails.total.toString();
    ContactNoController.text =selectedOrderDetails.contactNumber ?? '';
    deliveryLocationController.text = selectedOrderDetails.deliveryLocation  ?? '';
    CreatedDateController.text = selectedOrderDetails.orderDate ?? '';
    deliveryStatusController.text = selectedOrderDetails.status ?? '';
    paymentStatusController.text = selectedOrderDetails.Payment ?? '';
    PaymentIdController.text = selectedOrderDetails.paymentId ?? '';
    PaidAmount.text = selectedOrderDetails.paidAmount! as String;


  //  print(DeliveryStatus.text);



   // print(deliveryStatusController.text);

    //orderid
    //date
    //customer name
    //deliveyrlocaiton
    //totalamount

    orderIdController.text = selectedOrderDetails.orderId ?? '';
    CreatedDateController.text = selectedOrderDetails.orderDate ?? '';
    contactPersonController.text = selectedOrderDetails.contactPerson ?? '';
    deliveryLocationController.text = selectedOrderDetails.deliveryLocation ?? '';
    totalController.text = selectedOrderDetails.total!.toString();
    print(productNameController.text);

    print('------------devli');
    print(CreatedDateController.text);
    print(data2['deliveryLocation']);
    //  final selectedOrder = _orders[index];
    // Add more fields to print as needed
  }
}







