import 'dart:async';
import 'dart:convert';
import 'dart:html';
import 'dart:math' as math;
import 'package:adaptive_scrollbar/adaptive_scrollbar.dart';
import 'package:btb/widgets/Api%20name.dart';
import 'package:btb/widgets/confirmdialog.dart';
import 'package:btb/widgets/productclass.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../../Order Module/firstpage.dart';
import '../../dashboard/dashboard.dart';
import '../../widgets/custom loading.dart';
import '../../widgets/no datafound.dart';
import '../../widgets/text_style.dart';

void main() {
  runApp(const OrderView2());
}

class OrderView2 extends StatefulWidget {
  final String? orderId;

  const OrderView2({super.key, this.orderId});

  @override
  State<OrderView2> createState() => _OrderView2State();
}

class _OrderView2State extends State<OrderView2>
    with SingleTickerProviderStateMixin {
  final List<String> _sortOrder = List.generate(5, (index) => 'asc');
  List<String> columns = [
    'Order ID',
    'Customer ID',
    'Order Date',
    'Total',
    'Status',
  ];
  List<double> columnWidths = [95, 110, 110, 95, 150, 140];
  List<bool> columnSortState = [true, true, true, true, true, true];
  Timer? _searchDebounceTimer;
  bool isOrdersSelected = false;
  detail? _selectedProduct;
  late TextEditingController _dateController;

  int startIndex = 0;
  List<Product> filteredProducts = [];
  int currentPage = 1;
  String? dropdownValue1 = 'Status';
  final ScrollController verticalScroll = ScrollController();
  final ScrollController horizontalScroll = ScrollController();
  late Future<List<detail>> futureOrders;
  List<dynamic> detailJson = [];
  String searchQuery = '';
  final TextEditingController businessPartnerController =
      TextEditingController();
  final TextEditingController orderDate = TextEditingController();
  final TextEditingController businessPartnerNameController =
      TextEditingController();
  final TextEditingController customerController = TextEditingController();
  final TextEditingController addressIDController = TextEditingController();
  final TextEditingController cityNameController = TextEditingController();
  final TextEditingController postalCodeController = TextEditingController();
  final TextEditingController streetNameController = TextEditingController();
  final TextEditingController regionController = TextEditingController();
  final TextEditingController telephoneNumber1Controller =
      TextEditingController();
  final TextEditingController countryController = TextEditingController();
  final TextEditingController districtNameController = TextEditingController();
  final TextEditingController emailAddressController = TextEditingController();
  final TextEditingController mobilePhoneNumberController =
      TextEditingController();
  final TextEditingController orderIdController = TextEditingController();
  final TextEditingController orderDateController = TextEditingController();
  final TextEditingController totalAmountController = TextEditingController();
  String companyName = window.sessionStorage["company Name"] ?? " ";

  DateTime? _selectedDate;
  List<detail> filteredData = [];
  late AnimationController _controller;
  late Animation<double> _shakeAnimation;
  String status = '';
  String selectDate = '';

  String token = window.sessionStorage["token"] ?? " ";
  String userId = window.sessionStorage["userId"] ?? " ";
  String? dropdownValue2 = 'Select Year';

  List<Map<String, dynamic>> productList = [];
  List<Map<String, dynamic>> _selectedProducts = [];

  double _calculateTotal() {
    double total = 0.0;
    for (var product in _selectedProducts) {
      total += (product['qty'] * product['price']);
    }
    return total;
  }

  Future<void> fetchCustomerData() async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse('$apicall/$companyName/order_master/get_all_ordermaster'),
        headers: {
          "Content-type": "application/json",
          "Authorization": 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final decodedResponse = jsonDecode(response.body);

        if (decodedResponse is List) {
          setState(() {
            var matchingOrder = decodedResponse.firstWhere(
              (order) => order['orderId'] == widget.orderId,
              orElse: () => null,
            );

            if (matchingOrder != null) {
              if (matchingOrder.containsKey('items') &&
                  matchingOrder['items'] is List) {
                _selectedProducts =
                    List<Map<String, dynamic>>.from(matchingOrder['items']);
              } else {
                throw Exception('No matching order or invalid items structure');
              }
              orderIdController.text = matchingOrder['orderId'] ?? '';
              orderDateController.text = matchingOrder['orderDate'] ?? '';
              totalAmountController.text =
                  matchingOrder['total']?.toString() ?? '';
            } else {
              throw Exception('Order not found');
            }
          });
        } else if (decodedResponse is Map<String, dynamic>) {
          if (decodedResponse.containsKey('items') &&
              decodedResponse['items'] is List) {
            setState(() {
              _selectedProducts =
                  List<Map<String, dynamic>>.from(decodedResponse['items']);
              orderIdController.text = decodedResponse['orderId'] ?? '';
              orderDateController.text = decodedResponse['orderDate'] ?? '';
              totalAmountController.text =
                  decodedResponse['total']?.toString() ?? '';
            });
          } else {
            throw Exception(
                'Invalid JSON structure: Missing "items" key or invalid type');
          }
        } else {
          throw Exception('Unexpected JSON structure');
        }
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
            Text('Error fetching customer data: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> callApi() async {
    List<Map<String, dynamic>> items = [];
    for (int i = 0; i < _selectedProducts.length; i++) {
      final product = _selectedProducts[i];
      items.add({
        "baseUnit": product['baseUnit'] ?? '',
        "categoryName": product['categoryName'] ?? '',
        "currency": product['currency'] ?? '',
        "product": product['product'] ?? '',
        "productDescription": product['productDescription'] ?? '',
        "productType": product['productType'] ?? '',
        "qty": product['qty'] ?? '',
        "StandardPrice": product['price'] ?? '',
        "totalAmount": ((product['qty'] * product['price'])) ?? ''
      });
    }
    final url = '$apicall/order_master/add_order_master';
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
    final body = {
      "deliveryLocation": cityNameController.text,
      "contactPerson": businessPartnerNameController.text,
      "customerId": customerController.text,
      "orderDate": _dateController.text,
      "postalCode": postalCodeController.text,
      "region": regionController.text,
      "streetName": streetNameController.text,
      "telephoneNumber": telephoneNumber1Controller.text,
      "total": _calculateTotal(),
      "items": items,
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if(responseData['status'] == 'success'){
          showDialog(
            barrierDismissible: false,
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 25,
                ),
                content: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Order Placed'),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      context.go('/Customer_Order_List'); // Close the dialog
                    },
                    child: const Text('OK'),
                  ),
                ],
              );
            },
          );
        }else{
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                Text('Failed to save data ${response.statusCode}')),
          );
        }

      } else {
        print('API call failed with status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error during API call: $e');
    }
  }

  int itemsPerPage = 10;
  int totalItems = 0;
  int totalPages = 0;
  bool isLoading = false;


  final Map<String, bool> _isHovered = {
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
          _buildMenuItem(
              'Home', Icons.home_outlined, Colors.blue[900]!, '/Home'),
          _buildMenuItem('Product', Icons.production_quantity_limits,
              Colors.blue[900]!, '/Product_List'),
          _buildMenuItem('Customer', Icons.account_circle_outlined,
              Colors.white, '/Customer'),
          Container(
              height: 42,
              decoration: BoxDecoration(
                color: Colors.blue[800],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                  bottomLeft: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                ),
              ),
              child: _buildMenuItem('Orders', Icons.warehouse_outlined,
                  Colors.blue[900]!, '/Order_List')),
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
    title == 'Orders' ? _isHovered[title] = false : _isHovered[title] = false;
    title == 'Orders' ? iconColor = Colors.white : Colors.black;
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
            padding: const EdgeInsets.only(left: 10, top: 2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(
                  icon,
                  color: iconColor,
                  size: 20,
                ),
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

  @override
  void initState() {
    super.initState();

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
    _dateController = TextEditingController();
    _selectedDate = DateTime.now();

    String formattedDate1 =
        DateFormat('yyyy-MM-ddTHH:mm:ss').format(_selectedDate!);
    String formattedDate = DateFormat('dd/MM/yyyy').format(_selectedDate!);
    _dateController.text = formattedDate;
    orderDate.text = formattedDate1;
    fetchCustomerData();
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
        body: LayoutBuilder(builder: (context, constraints) {
          double maxWidth = constraints.maxWidth;
          double maxHeight = constraints.maxHeight;
          return Stack(
            children: [
              Container(
                color: Colors.white,
                height: 60.0,
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
                          ),
                        ),
                        const Spacer(),
                        const Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(right: 10, top: 10),
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
                      thickness: 3.0,
                      color: Color(0x29000000),
                    ),
                  ],
                ),
              ),
              if (constraints.maxHeight <= 500) ...{
                Positioned(
                  top: 60,
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: SingleChildScrollView(
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Container(
                          height: 1400,
                          width: 200,
                          color: Colors.white,
                          padding: const EdgeInsets.only(
                              left: 15, top: 10, right: 15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: _buildMenuItems(context),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                VerticalDividerWidget(
                  height: maxHeight,
                  color: const Color(0x29000000),
                ),
              } else ...{
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 60),
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
                  color: const Color(0x29000000),
                ),
              },
              Positioned(
                left: 200,
                top: 60,
                right: 0,
                bottom: 0,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    if (constraints.maxWidth >= 1300) ...{
                      Expanded(
                          child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 40, top: 10),
                              child: Row(
                                children: [
                                  IconButton(
                                      onPressed: () {
                                        context.go('/Order_List');
                                      },
                                      icon: const Icon(
                                        Icons.arrow_back,
                                        size: 20,
                                      )),
                                  Text(
                                    'View Order',
                                    style: TextStyles.header1,
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.only(left: 0, top: 5),
                              height: 1,
                              width: constraints.maxWidth,
                              color: Colors.grey.shade300,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  top: 40, left: 70, right: 50, bottom: 30),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(2),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.1),
                                      spreadRadius: 3,
                                      blurRadius: 3,
                                      offset: const Offset(0, 3),
                                    ),
                                  ], // border-radius: 8px
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    Row(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              top: 20, left: 30, bottom: 20),
                                          child: Text(
                                            'Order ID: ${orderIdController.text}',
                                            style: TextStyles.body2,
                                          ),
                                        ),
                                        const Spacer(),
                                        Padding(
                                          padding: EdgeInsets.only(
                                              right: maxWidth * 0.04,
                                              top: 20,
                                              bottom: 20),
                                          child: Text(
                                            'Order Date: ${orderDateController.text}',
                                            style: TextStyles.body2,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Container(
                                      width: maxWidth,
                                      color: Colors.grey[100],
                                      child: DataTable(
                                        dataRowHeight: 57,
                                        headingRowHeight: 50,
                                        dataRowColor: MaterialStateProperty
                                            .resolveWith<Color>(
                                          (Set<MaterialState> states) {
                                            return Colors.white;
                                          },
                                        ),
                                        columns: [
                                          DataColumn(
                                              label: Text('S.NO',
                                                  style: TextStyles.subhead)),
                                          DataColumn(
                                              label: Text('Product Name',
                                                  style: TextStyles.subhead)),
                                          DataColumn(
                                              label: Text('Category',
                                                  style: TextStyles.subhead)),
                                          DataColumn(
                                              label: Text('Unit',
                                                  style: TextStyles.subhead)),
                                          DataColumn(
                                              label: Text('Price',
                                                  style: TextStyles.subhead)),
                                          DataColumn(
                                              label: Text('Qty',
                                                  style: TextStyles.subhead)),
                                          DataColumn(
                                              label: Text('Total Amount',
                                                  style: TextStyles.subhead)),
                                        ],
                                        rows: _selectedProducts.map((product) {
                                          int index = _selectedProducts
                                                  .indexOf(product) +
                                              1;
                                          return DataRow(cells: [
                                            DataCell(Text('$index')),
                                            DataCell(Text(
                                                product['productDescription'] ??
                                                    '')),
                                            DataCell(Text(
                                                product['categoryName'] ?? '')),
                                            DataCell(Text(
                                                product['baseUnit'] ?? '')),
                                            DataCell(Text(
                                                product['standardPrice']
                                                        ?.toStringAsFixed(2) ??
                                                    '0.00')),
                                            DataCell(
                                                Text(product['qty'] ?? '0')),
                                            DataCell(Text((double.parse(
                                                        product['qty']) *
                                                    product['standardPrice'])
                                                .toStringAsFixed(2))),
                                          ]);
                                        }).toList(),
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        const Spacer(),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              right: 10, bottom: 10),
                                          child: Container(
                                            decoration: BoxDecoration(
                                                border: Border.all(
                                                    color: Colors.blue)),
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 20,
                                                  bottom: 10,
                                                  left: 10,
                                                  top: 10),
                                              child: Align(
                                                alignment:
                                                    Alignment.centerRight,
                                                child: Text(
                                                  'Total: \₹${totalAmountController.text}',
                                                  style: TextStyles.subhead,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ))
                    } else ...{
                      SizedBox(
                        height: maxHeight,
                        child: AdaptiveScrollbar(
                            position: ScrollbarPosition.bottom,
                            controller: horizontalScroll,
                            child: SingleChildScrollView(
                              controller: horizontalScroll,
                              scrollDirection: Axis.horizontal,
                              child: SingleChildScrollView(
                                controller: verticalScroll,
                                scrollDirection: Axis.vertical,
                                child: Padding(
                                  padding:
                                      const EdgeInsets.only(left: 3, right: 0),
                                  child: Container(
                                    color: Colors.grey[50],
                                    width: 1500,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left: 30, top: 10),
                                          child: Row(
                                            children: [
                                              IconButton(
                                                  onPressed: () {
                                                    context.go('/Order_List');
                                                  },
                                                  icon: const Icon(
                                                    Icons.arrow_back,
                                                    size: 20,
                                                  )),
                                              Text(
                                                'View Order',
                                                style: TextStyles.header1,
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          margin: const EdgeInsets.only(top: 5),
                                          height: 1,
                                          width: 1500,
                                          color: Colors.grey.shade300,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              top: 40,
                                              left: 70,
                                              right: 50,
                                              bottom: 30),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(2),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.grey
                                                      .withOpacity(0.1),
                                                  // Soft grey shadow
                                                  spreadRadius: 3,
                                                  blurRadius: 3,
                                                  offset: const Offset(0, 3),
                                                ),
                                              ], // border-radius: 8px
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const SizedBox(
                                                  height: 20,
                                                ),
                                                Row(
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 20,
                                                              left: 30,
                                                              bottom: 20),
                                                      child: Text(
                                                        'Order ID: ${orderIdController.text}',
                                                        style: TextStyles.body2,
                                                      ),
                                                    ),
                                                    const Spacer(),
                                                    Padding(
                                                      padding: EdgeInsets.only(
                                                          right:
                                                              maxWidth * 0.04,
                                                          top: 20,
                                                          bottom: 20),
                                                      child: Text(
                                                        'Order Date: ${orderDateController.text}',
                                                        style: TextStyles.body2,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 10),
                                                Container(
                                                  width: 1400,
                                                  color: Colors.grey[100],
                                                  child: DataTable(
                                                    dataRowHeight: 57,
                                                    headingRowHeight: 50,
                                                    dataRowColor:
                                                        MaterialStateProperty
                                                            .resolveWith<Color>(
                                                      (Set<MaterialState>
                                                          states) {
                                                        return Colors
                                                            .white; // Set row background to white
                                                      },
                                                    ),
                                                    columns: [
                                                      DataColumn(
                                                          label: Text('S.NO',
                                                              style: TextStyles
                                                                  .subhead)),
                                                      DataColumn(
                                                          label: Text(
                                                              'Product Name',
                                                              style: TextStyles
                                                                  .subhead)),
                                                      DataColumn(
                                                          label: Text(
                                                              'Category',
                                                              style: TextStyles
                                                                  .subhead)),
                                                      DataColumn(
                                                          label: Text('Unit',
                                                              style: TextStyles
                                                                  .subhead)),
                                                      DataColumn(
                                                          label: Text('Price',
                                                              style: TextStyles
                                                                  .subhead)),
                                                      DataColumn(
                                                          label: Text('Qty',
                                                              style: TextStyles
                                                                  .subhead)),
                                                      DataColumn(
                                                          label: Text(
                                                              'Total Amount',
                                                              style: TextStyles
                                                                  .subhead)),
                                                    ],
                                                    rows: _selectedProducts
                                                        .map((product) {
                                                      int index =
                                                          _selectedProducts
                                                                  .indexOf(
                                                                      product) +
                                                              1;
                                                      return DataRow(cells: [
                                                        DataCell(
                                                            Text('$index')),
                                                        DataCell(Text(product[
                                                                'productDescription'] ??
                                                            '')),
                                                        DataCell(Text(product[
                                                                'categoryName'] ??
                                                            '')),
                                                        DataCell(Text(product[
                                                                'baseUnit'] ??
                                                            '')),
                                                        DataCell(Text(product[
                                                                    'standardPrice']
                                                                ?.toStringAsFixed(
                                                                    2) ??
                                                            '0.00')),
                                                        DataCell(Text(
                                                            product['qty'] ??
                                                                '0')),
                                                        DataCell(Text((double
                                                                    .parse(product[
                                                                        'qty']) *
                                                                product[
                                                                    'standardPrice'])
                                                            .toStringAsFixed(
                                                                2))),
                                                      ]);
                                                    }).toList(),
                                                  ),
                                                ),
                                                Row(
                                                  children: [
                                                    const Spacer(),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              right: 10,
                                                              bottom: 10),
                                                      child: Container(
                                                        decoration: BoxDecoration(
                                                            border: Border.all(
                                                                color: Colors
                                                                    .blue)),
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  right: 20,
                                                                  bottom: 10,
                                                                  left: 10,
                                                                  top: 10),
                                                          child: Align(
                                                            alignment: Alignment
                                                                .centerRight,
                                                            child: Text(
                                                              'Total: \₹${totalAmountController.text}',
                                                              style: TextStyles
                                                                  .subhead,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            )),
                      )
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

  String calculateTotalPrice(Map<String, dynamic> product) {
    double total = product['qty'] * product['price'];
    return total.toStringAsFixed(2);
  }

  Widget buildDataTable2() {
    if (isLoading) {
      var width = MediaQuery.of(context).size.width;
      var height = MediaQuery.of(context).size.height;
      return Padding(
        padding: EdgeInsets.only(
            top: height * 0.100, bottom: height * 0.100, left: width * 0.300),
        child: CustomLoadingIcon(),
      );
    }

    if (filteredData.isEmpty) {
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
                columns: columns.map((column) {
                  return DataColumn(
                    label: Stack(
                      children: [
                        Container(
                          padding: null,
                          width: columnWidths[columns.indexOf(column)],
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
            padding: const EdgeInsets.only(
                top: 150, left: 130, bottom: 350, right: 150),
            child: CustomDatafound(),
          ),
        ],
      );
    }
    return LayoutBuilder(builder: (context, constraints) {
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
                columnSpacing: 35,
                columns: columns.map((column) {
                  return DataColumn(
                    label: Stack(
                      children: [
                        Container(
                          padding: null,
                          width: columnWidths[columns.indexOf(column)],
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
                                        ? SizedBox(
                                            width: 12,
                                            child: Image.asset(
                                              "images/sort.png",
                                              color: Colors.grey,
                                            ))
                                        : SizedBox(
                                            width: 12,
                                            child: Image.asset(
                                              "images/sort.png",
                                              color: Colors.blue,
                                            )),
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
                              const Spacer(),
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
                                                .clamp(151.0, 300.0);
                                      });
                                    },
                                    child: const Padding(
                                      padding:
                                          EdgeInsets.only(top: 10, bottom: 10),
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
                        return Colors.blue.shade500.withOpacity(0.8);
                      } else {
                        return Colors.white.withOpacity(0.9);
                      }
                    }),
                    cells: [
                      DataCell(
                        SizedBox(
                          width: columnWidths[0],
                          child: Text(
                            detail.orderId.toString(),
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.deepOrange[200]
                                  : const Color(0xFFFFB315),
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
                            detail.invoiceNo!,
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
                        SizedBox(
                          width: columnWidths[4],
                          child: Text(
                            detail.deliveryStatus.toString(),
                            style: TextStyle(
                              color: detail.deliveryStatus == "In Progress"
                                  ? Colors.orange
                                  : detail.deliveryStatus == "Delivered"
                                      ? Colors.green
                                      : Colors.red,
                            ),
                          ),
                        ),
                      ),
                      DataCell(
                        SizedBox(
                          width: columnWidths[4],
                          child: Text(
                            detail.paymentStatus.toString(),
                            style: const TextStyle(
                              color: Color(0xFFA6A6A6),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                })),
          ),
        ],
      );
    });
  }

  Widget buildDataTable() {
    if (isLoading) {
      var width = MediaQuery.of(context).size.width;
      var height = MediaQuery.of(context).size.height;
      return Padding(
        padding: EdgeInsets.only(
            top: height * 0.100, bottom: height * 0.100, left: width * 0.300),
        child: CustomLoadingIcon(),
      );
    }

    if (filteredData.isEmpty) {
      double right = MediaQuery.of(context).size.width;
      return Column(
        children: [
          Container(
            width: right - 100,
            decoration: const BoxDecoration(
                color: Color(0xFFF7F7F7),
                border: Border.symmetric(
                    horizontal: BorderSide(color: Colors.grey, width: 0.5))),
            child: DataTable(
                showCheckboxColumn: false,
                headingRowHeight: 40,
                columnSpacing: 35,
                columns: columns.map((column) {
                  return DataColumn(
                    label: Stack(
                      children: [
                        Container(
                          padding: null,
                          width: columnWidths[columns.indexOf(column)],
                          child: Row(
                            children: [
                              Text(column, style: TextStyles.subhead),
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
            padding: const EdgeInsets.only(
                top: 150, left: 130, bottom: 350, right: 150),
            child: CustomDatafound(),
          ),
        ],
      );
    }
    return LayoutBuilder(builder: (context, constraints) {
      double right = MediaQuery.of(context).size.width * 0.92;

      return Column(
        children: [
          Container(
            width: right - 100,
            decoration: const BoxDecoration(
                color: Color(0xFFF7F7F7),
                border: Border.symmetric(
                    horizontal: BorderSide(color: Colors.grey, width: 0.5))),
            child: DataTable(
                showCheckboxColumn: false,
                headingRowHeight: 40,
                columnSpacing: 35,
                columns: columns.map((column) {
                  return DataColumn(
                    label: Stack(
                      children: [
                        Container(
                          padding: null,
                          width: columnWidths[columns.indexOf(column)],
                          child: Row(
                            children: [
                              Text(column, style: TextStyles.subhead),
                              IconButton(
                                icon:
                                    _sortOrder[columns.indexOf(column)] == 'asc'
                                        ? SizedBox(
                                            width: 12,
                                            child: Image.asset(
                                              "images/sort.png",
                                              color: Colors.grey,
                                            ))
                                        : SizedBox(
                                            width: 12,
                                            child: Image.asset(
                                              "images/sort.png",
                                              color: Colors.blue,
                                            )),
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
                        return Colors.blue.shade500.withOpacity(0.8);
                      } else {
                        return Colors.white.withOpacity(0.9);
                      }
                    }),
                    cells: [
                      DataCell(
                        SizedBox(
                          width: columnWidths[0],
                          child: Text(
                            detail.orderId.toString(),
                            style: TextStyles.body,
                          ),
                        ),
                      ),
                      DataCell(
                        SizedBox(
                          width: columnWidths[1],
                          child: Text(
                            detail.orderDate,
                            style: TextStyles.body,
                          ),
                        ),
                      ),
                      DataCell(
                        SizedBox(
                          width: columnWidths[2],
                          child: Text(
                            detail.invoiceNo!,
                            style: TextStyles.body,
                          ),
                        ),
                      ),
                      DataCell(
                        SizedBox(
                          width: columnWidths[3],
                          child: Text(
                            detail.total.toString(),
                            style: TextStyles.body,
                          ),
                        ),
                      ),
                      DataCell(
                        SizedBox(
                          width: columnWidths[4],
                          child: Text(
                            detail.deliveryStatus.toString(),
                            style: TextStyles.body,
                          ),
                        ),
                      ),
                    ],
                  );
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
          return a.paymentStatus!
              .toLowerCase()
              .compareTo(b.paymentStatus!.toLowerCase());
        } else if (columnIndex == 1) {
          return a.orderId!.compareTo(b.orderId!);
        } else if (columnIndex == 2) {
          return a.orderDate.compareTo(b.orderDate);
        } else if (columnIndex == 3) {
          return a.invoiceNo!.compareTo(b.invoiceNo!);
        } else if (columnIndex == 4) {
          return a.total.compareTo(b.total);
        } else if (columnIndex == 5) {
          return a.deliveryStatus.compareTo(b.deliveryStatus);
        } else {
          return 0;
        }
      });
    } else {
      filteredData.sort((a, b) {
        if (columnIndex == 0) {
          return b.paymentStatus!
              .toLowerCase()
              .compareTo(a.paymentStatus!.toLowerCase());
        } else if (columnIndex == 1) {
          return b.orderId!.compareTo(a.orderId!);
        } else if (columnIndex == 2) {
          return b.orderDate.compareTo(a.orderDate);
        } else if (columnIndex == 3) {
          return b.invoiceNo!.compareTo(a.invoiceNo!);
        } else if (columnIndex == 4) {
          return b.total.compareTo(a.total);
        } else if (columnIndex == 5) {
          return b.deliveryStatus.compareTo(a.deliveryStatus);
        } else {
          return 0;
        }
      });
    }
    setState(() {});
  }
}
