import 'dart:async';
import 'dart:convert';
import 'dart:html';
import 'dart:math' as math;
import 'dart:ui' as ord;
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
  runApp(const CreateOrder());
}

class CreateOrder extends StatefulWidget {
  const CreateOrder({super.key});

  @override
  State<CreateOrder> createState() => _CreateOrderState();
}

class _CreateOrderState extends State<CreateOrder>
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
  final Map<Map<String, dynamic>, TextEditingController> _controllers = {};

  detail? _selectedProduct;
  late TextEditingController _dateController;
  Map<String, dynamic> paymentMap = {};

  int startIndex = 0;
  List<Product> filteredProducts = [];
  int currentPage = 1;
  String? dropdownValue1 = 'Status';
  final ScrollController horizontalScroll = ScrollController();

  late Future<List<detail>> futureOrders;

  // List<ord.ProductData> productList = [];

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
  String companyName = window.sessionStorage["company Name"] ?? " ";

  DateTime? _selectedDate;
  List<detail> filteredData = [];
  bool _isTotalVisible = false;
  late AnimationController _controller;
  late Animation<double> _shakeAnimation;
  String status = '';
  String selectDate = '';

  String token = window.sessionStorage["token"] ?? " ";
  String userId = window.sessionStorage["userId"] ?? " ";
  String? dropdownValue2 = 'Select Year';

  List<Map<String, dynamic>> productList = [];
  final List<Map<String, dynamic>> _selectedProducts = [];



  Future<void> fetchProducts(int page, int itemsPerPage) async {
    if (isLoading) return;
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse(
            '$apicall/public/productmaster/get_all_s4hana_productmaster?page=$page&limit=$itemsPerPage'),
        headers: {
          "Content-type": "application/json",
          "Authorization": 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData != null) {
          //var results = jsonData['d']['results'];

          // Update the product list
          setState(() {
            productList = jsonData.map<Map<String, dynamic>>((item) {
              return {
                'product': item['product'] ?? '',
                'categoryName': item['categoryName'] ?? '',
                'productType': item['productType'] ?? '',
                'baseUnit': item['baseUnit'] ?? '',
                'productDescription': item['productDescription'] ?? '',
                'price': item['standardPrice'] ?? 0,
                'currency': item['currency'] ?? 'INR',
              };
            }).toList();
            totalPages = (jsonData.length / itemsPerPage).ceil();
          });
        }
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Error fetching data: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

// Function to calculate the total amount
  double _calculateTotal() {
    double total = 0.0;
    for (var product in _selectedProducts) {
      total += (product['qty'] * product['price']);
    }
    return total;
  }

  Future<void> fetchCustomerData(String userId) async {
    if (isLoading) return;
    setState(() {
      isLoading = true;
    });

    try {
      // API call to fetch customer data for a specific userId
      final response = await http.get(
        Uri.parse('$apicall/public/customer_master/get_all_s4hana_customermaster'),
        headers: {
          "Content-type": "application/json",
          "Authorization": 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);

        if (jsonData != null) {
          var result = jsonData.firstWhere(
            (item) => item['customer'] == userId,
            orElse: () => null,
          );

          if (result != null) {

            businessPartnerController.text = result['BusinessPartner'] ?? '';
            businessPartnerNameController.text = result['customerName'] ?? '';
            customerController.text = result['customer'] ?? '';
            addressIDController.text = result['addressID'] ?? '';
            cityNameController.text = result['cityName'] ?? '';
            postalCodeController.text = result['postalCode'] ?? '';
            streetNameController.text = result['streetName'] ?? '';
            regionController.text = result['region'] ?? '';
            telephoneNumber1Controller.text = result['telephoneNumber1'] ?? '';
            countryController.text = result['country'] ?? '';
            districtNameController.text = result['districtName'] ?? '';
            emailAddressController.text = result['emailAddress'] ?? '';
            mobilePhoneNumberController.text =
                result['mobilePhoneNumber'] ?? '';

          } else {
            throw Exception('Customer data not found for userId: $userId');
          }
        } else {
          throw Exception('Invalid JSON structure');
        }
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Error fetching customer data: $e');
      // Optionally, show an error message to the user
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }


  Future<void> callApi() async {
    List<Map<String, dynamic>> items = [];

    // Process _selectedProducts rows into API payload
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
        "standardPrice": product['price'] ?? '',
        "totalAmount": ((product['qty'] * product['price'])) ?? ''
        // "productName": product['productDescription'] ?? 'Dummy Product',
        // "category": product['categoryName'] ?? 'Dummy Category',
        // "subCategory": 'Dummy SubCategory',
        // "price": product['price'] ?? 0.0,
        // "qty": product['qty'] ?? 1,
        // "actualAmount": (product['price'] ?? 0.0) * (product['qty'] ?? 1),
        // "totalAmount": (product['price'] ?? 0.0) * (product['qty'] ?? 1),
        // "discount": 0.0,
        // "tax": 0.0,
      });
    }

    // Dummy data for the main payload
    final url =
        '$apicall/$companyName/order_master/add_order_master';
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
      } else {
        print('API call failed with status code: ${response.statusCode}');
        print('Response: ${response.body}');
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
              'Home', Icons.home_outlined, Colors.blue[900]!, '/Cus_Home'),
          Container(
              height: 42,
              decoration: BoxDecoration(
                color: Colors.blue[800],

                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),

                  topRight: Radius.circular(8),

                  bottomLeft: Radius.circular(8),
                  bottomRight:
                      Radius.circular(8),
                ),
              ),
              child: _buildMenuItem('Orders', Icons.warehouse_outlined,
                  Colors.blue[900]!, '/Customer_Order_List')),
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
      fetchProducts(currentPage, itemsPerPage);

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
                        const Row(
                          children: [
                            Padding(
                              padding:
                                  EdgeInsets.only(right: 10, top: 10),
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
                  top: 60,
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: SingleChildScrollView(
                    child: Align(
                      // Added Align widget for the left side menu
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
                left: 202,
                top: 60,
                right: 0,
                bottom: 0,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    if (constraints.maxWidth >= 1300) ...{
                      //   double overallTotal = _selectedProducts.fold(0, (sum, product) {return sum + (product['qty'] * product['price']);});
                      Expanded(
                          child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 15, top: 10),
                              child: Row(
                                children: [
                                  IconButton(
                                      onPressed: () {
                                        context.go('/Customer_Order_List');
                                      },
                                      icon: const Icon(
                                        Icons.arrow_back,
                                        size: 20,
                                      )),
                                  Text(
                                    'Create Order',
                                    style: TextStyles.header1,
                                  ),
                                  const Spacer(),
                                  Align(
                                    alignment: Alignment.topRight,
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          right: 54, top: 5),
                                      child: OutlinedButton(
                                        onPressed: () async {
                                          if (_selectedProducts.isEmpty) {
                                             ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                    'Please add a product before creating an order'),
                                                duration: Duration(seconds: 2),
                                              ),
                                            );
                                          } else if (_selectedProducts.any(
                                              (product) =>
                                                  product['productDescription'] ==
                                                      null ||
                                                  product['productDescription']
                                                      .isEmpty)) {
                                          ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                    'Each product must have a description'),
                                                duration: Duration(seconds: 2),
                                              ),
                                            );
                                          } else if (_selectedProducts.any(
                                              (product) =>
                                                  product['qty'] == null ||
                                                  product['qty'] <= 0)) {
                                            // Check if any product has an invalid or zero quantity

                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                    'Each product must have a valid quantity greater than zero'),
                                                duration: Duration(seconds: 2),
                                              ),
                                            );
                                          } else {
                                            await fetchCustomerData(userId);

                                            await callApi();
                                          }
                                        },

                                        style: OutlinedButton.styleFrom(
                                          backgroundColor: Colors.blue[800],
                                          // Button background color
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                                5),),
                                          side: BorderSide.none,
                                        ),
                                        child: Text(
                                          ' Create Order',
                                          style: TextStyles.button1,
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.only(left: 5, top: 5),
                              height: 1,
                              width: constraints.maxWidth,
                              color: Colors.grey.shade300,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 50),
                              child: SizedBox(
                                width: maxWidth,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(
                                          right: maxWidth * 0.08,
                                          top: 30,
                                          left: maxWidth * 0.016),
                                      child: Text(
                                        'Order Date',
                                        style: TextStyles.header3,
                                      ),
                                    ),

                                    //  ),
                                    // SizedBox(height: 20.h),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                left: 70,
                              ),
                              child: SizedBox(
                                height: 39,
                                width: maxWidth * 0.11,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        controller: _dateController,
                                        style: TextStyle(
                                            fontSize: maxWidth * 0.009),
                                        // Replace with your TextEditingController
                                        readOnly: true,
                                        decoration: InputDecoration(
                                          suffixIcon: Padding(
                                            padding: const EdgeInsets.only(
                                                right: 20),
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 2, left: 10),
                                              child: IconButton(
                                                icon: const Padding(
                                                  padding: EdgeInsets.only(
                                                      bottom: 16),
                                                  child: Icon(
                                                      Icons.calendar_month),
                                                ),
                                                iconSize: 20,
                                                onPressed: () {
                                                  // _showDatePicker(context);
                                                },
                                              ),
                                            ),
                                          ),
                                          hintText: '        Select Date',
                                          fillColor: Colors.white,
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 8, vertical: 8),
                                          border: InputBorder.none,
                                          filled: true,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  top: 40, left: 70, right: 50, bottom: 30),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFFFFF),
                                  boxShadow: const [
                                    BoxShadow(
                                      offset: Offset(0, 3),
                                      blurRadius: 6,
                                      color: Color(
                                          0x29000000), // box-shadow: 0px 3px 6px #00000029
                                    )
                                  ],
                                  border: Border.all(
                                    color: const Color(
                                        0xFFB2C2D3), // border: #B2C2D3
                                  ),
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(8)), // border-radius: 8px
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 20, left: 25, bottom: 20),
                                      child: Text(
                                        'Item Table',
                                        style: TextStyles.header3,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Container(
                                      width: maxWidth,
                                      color: Colors.grey[100],
                                      child: DataTable(
                                      //  dataRowHeight: 57,
                                        headingRowHeight: 50,
                                        dataRowColor: MaterialStateProperty
                                            .resolveWith<Color>(
                                          (Set<MaterialState> states) {
                                            return Colors
                                                .white;
                                          },
                                        ),
                                        columns: [
                                          DataColumn(
                                              label: Text('S.NO',
                                                  style: TextStyles.subhead)),
                                          DataColumn(
                                              label: Padding(
                                            padding:
                                                const EdgeInsets.only(left: 10),
                                            child: Text('Product Name',
                                                style: TextStyles.subhead),
                                          )),
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
                                              label: Padding(
                                            padding:
                                                const EdgeInsets.only(left: 10),
                                            child: Text('Qty',
                                                style: TextStyles.subhead),
                                          )),
                                          DataColumn(
                                              label: Text('Total Amount',
                                                  style: TextStyles.subhead)),
                                          const DataColumn(label: Text(' ')),
                                        ],
                                        rows: _selectedProducts.map((product) {
                                          int index = _selectedProducts
                                                  .indexOf(product) +
                                              1;
                                          return DataRow(cells: [
                                            DataCell(Text('$index')),
                                            DataCell(_buildProductSearchField(
                                                product)),
                                            DataCell(Text(
                                                product['categoryName'] ?? '')),
                                            DataCell(Text(
                                                product['baseUnit'] ?? '')),
                                            DataCell(Text(product['price']
                                                .toStringAsFixed(2))),
                                            DataCell(_buildQuantityField(
                                                product,
                                                _controllers[product]!)),
                                            DataCell(Text((product['qty'] *
                                                    product['price'])
                                                .toStringAsFixed(2))),
                                            DataCell(IconButton(
                                              icon: const Icon(
                                                  Icons.remove_circle_outline,
                                                  color: Colors.grey),
                                              onPressed: () {
                                                setState(() {
                                                  if (_controllers
                                                      .containsKey(product)) {
                                                    _controllers[product]
                                                        ?.dispose();
                                                    _controllers
                                                        .remove(product);
                                                  }
                                                  _selectedProducts
                                                      .remove(product);
                                                });
                                              },
                                            )),
                                          ]);
                                        }).toList(),
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left: 45, bottom: 20, top: 20),
                                          child: SizedBox(
                                            width: 160,
                                            child: ElevatedButton(
                                              onPressed: () {
                                                setState(() {
                                                  // Add a new product with default values
                                                  Map<String, dynamic>
                                                      newProduct = {
                                                    'product': '',
                                                    'productDescription': '',
                                                    'categoryName': '',
                                                    'baseUnit': '',
                                                    'price': 0.0,
                                                    'qty': 0,
                                                  };

                                                  _selectedProducts
                                                      .add(newProduct);
                                                  if (_controllers != null) {
                                                    _controllers[newProduct] =
                                                        TextEditingController(
                                                            text: '0');
                                                  }
                                                  _isTotalVisible = true;
                                                });

                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    Colors.blue[800],
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(5),
                                                ),
                                              ),
                                              child: Text(
                                                '+ Add Product',
                                                style: TextStyles.button1,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const Spacer(),
                                        if (_isTotalVisible &&
                                            _calculateTotal() != 0.00)
                                          Padding(
                                            padding: const EdgeInsets.only(right: 10),
                                            child: Container(
                                                                                        decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: Colors.blue)),
                                                                                        child: Padding(
                                            padding: const EdgeInsets.only(
                                                right: 20,
                                                bottom: 10,left: 10,
                                                top: 10),
                                            // Adjust padding to match alignment
                                            child: Align(
                                              alignment:
                                                  Alignment.centerRight,
                                              // Align text to the right
                                              child: Text(
                                                'Total: ₹${_calculateTotal().toStringAsFixed(2)}',
                                                style: TextStyles.subhead,
                                                textAlign: TextAlign
                                                    .right, // Ensure right-aligned text
                                              ),
                                            ),
                                                                                        ),
                                                                                      ),
                                          )
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),

                          ],
                        ),
                      )),
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
                                      //   mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left: 20, top: 10),
                                          child: Row(
                                            children: [
                                              IconButton(
                                                  onPressed: () {
                                                    context.go(
                                                        '/Customer_Order_List');
                                                  },
                                                  icon: const Icon(
                                                    Icons.arrow_back,
                                                    size: 20,
                                                  )),
                                              Text(
                                                'Create Order',
                                                style: TextStyles.header1,
                                              ),
                                              const Spacer(),
                                              Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.end,
                                                children: [
                                                  Align(
                                                    alignment:
                                                        Alignment.topRight,
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              right: 54,
                                                              top: 5),
                                                      child: OutlinedButton(
                                                        onPressed: () async {
                                                          if (_selectedProducts
                                                              .isEmpty) {
                                                            ScaffoldMessenger
                                                                    .of(context)
                                                                .showSnackBar(
                                                              const SnackBar(
                                                                content: Text(
                                                                    'Please add a product before creating an order'),
                                                                duration:
                                                                    Duration(
                                                                        seconds:
                                                                            2),
                                                              ),
                                                            );
                                                          } else if (_selectedProducts
                                                              .any((product) =>
                                                                  product['productDescription'] ==
                                                                      null ||
                                                                  product['productDescription']
                                                                      .isEmpty)) {
                                                            // Check if any product has an empty or null productDescription

                                                            ScaffoldMessenger
                                                                    .of(context)
                                                                .showSnackBar(
                                                              const SnackBar(
                                                                content: Text(
                                                                    'Each product must have a description'),
                                                                duration:
                                                                    Duration(
                                                                        seconds:
                                                                            2),
                                                              ),
                                                            );
                                                          } else if (_selectedProducts
                                                              .any((product) =>
                                                                  product['qty'] ==
                                                                      null ||
                                                                  product['qty'] <=
                                                                      0)) {
                                                            ScaffoldMessenger
                                                                    .of(context)
                                                                .showSnackBar(
                                                              const SnackBar(
                                                                content: Text(
                                                                    'Each product must have a valid quantity greater than zero'),
                                                                duration:
                                                                    Duration(
                                                                        seconds:
                                                                            2),
                                                              ),
                                                            );
                                                          } else {
                                                          await fetchCustomerData(
                                                                userId);

                                                            await callApi();
                                                          }
                                                        },
                                                        style: OutlinedButton
                                                            .styleFrom(
                                                          backgroundColor:
                                                              Colors.blue[800],
                                                          shape:
                                                              RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        5),
                                                          ),
                                                          side: BorderSide
                                                              .none,
                                                        ),
                                                        child: Text(
                                                          ' Create Order',
                                                          style: TextStyles
                                                              .button1,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              )
                                            ],
                                          ),
                                        ),
                                        Container(
                                          margin: const EdgeInsets.only(top: 5),
                                          height: 1,
                                          width: 1900,
                                          color: Colors.grey.shade300,
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 50),
                                          child: SizedBox(
                                            width: 250,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Padding(
                                                  padding: EdgeInsets.only(
                                                      right: maxWidth * 0.08,
                                                      top: 30,
                                                      left: 20),
                                                  child: Text(
                                                    'Order Date',
                                                    style: TextStyles.header3,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            left: 70,
                                          ),
                                          child: SizedBox(
                                            height: 39,
                                            width: 150,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Expanded(
                                                  child: TextFormField(
                                                    controller: _dateController,
                                                    style: TextStyle(
                                                        fontSize:
                                                            maxWidth * 0.009),
                                                    readOnly: true,
                                                    decoration: InputDecoration(
                                                      suffixIcon: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                right: 20),
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  top: 2,
                                                                  left: 10),
                                                          child: IconButton(
                                                            icon: const Padding(
                                                              padding: EdgeInsets
                                                                  .only(
                                                                      bottom:
                                                                          16),
                                                              child: Icon(Icons
                                                                  .calendar_month),
                                                            ),
                                                            iconSize: 20,
                                                            onPressed: () {
                                                            },
                                                          ),
                                                        ),
                                                      ),
                                                      hintText:
                                                          '        Select Date',
                                                      fillColor: Colors.white,
                                                      contentPadding:
                                                          const EdgeInsets
                                                              .symmetric(
                                                              horizontal: 8,
                                                              vertical: 8),
                                                      border: InputBorder.none,
                                                      filled: true,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              top: 10,
                                              left: 70,
                                              right: 50,
                                              bottom: 60),
                                          child: Container(
                                            width: 1500,
                                            //height: 800,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              // color: const Color(0xFFFFFFFF),
                                              boxShadow: const [
                                                BoxShadow(
                                                  offset: Offset(0, 3),
                                                  blurRadius: 6,
                                                  color: Color(
                                                      0x29000000), // box-shadow: 0px 3px 6px #00000029
                                                )
                                              ],
                                              border: Border.all(
                                                color: const Color(
                                                    0xFFB2C2D3), // border: #B2C2D3
                                              ),
                                              borderRadius: const BorderRadius
                                                  .all(Radius.circular(
                                                      8)), // border-radius: 8px
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets.only(
                                                      top: 20,
                                                      left: 25,
                                                      bottom: 20),
                                                  child: Text(
                                                    'Item Table',
                                                    style: TextStyles.header3,
                                                  ),
                                                ),
                                                const SizedBox(height: 10),
                                                Container(
                                                  width: 1600,
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
                                                          label: Padding(
                                                            padding: const EdgeInsets.only(left: 10),
                                                            child: Text(
                                                                'Product Name',
                                                                style: TextStyles
                                                                    .subhead),
                                                          )),
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
                                                          label: Padding(
                                                            padding: const EdgeInsets.only(left: 10),
                                                            child: Text('Qty',
                                                                style: TextStyles
                                                                    .subhead),
                                                          )),
                                                      DataColumn(
                                                          label: Text(
                                                              'Total Amount',
                                                              style: TextStyles
                                                                  .subhead)),
                                                      const DataColumn(
                                                          label: Text(' ')),
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
                                                        DataCell(
                                                            _buildProductSearchField(
                                                                product)),
                                                        DataCell(Text(product[
                                                                'categoryName'] ??
                                                            '')),
                                                        DataCell(Text(product[
                                                                'baseUnit'] ??
                                                            '')),
                                                        DataCell(Text(product[
                                                                'price']
                                                            .toStringAsFixed(
                                                                2))),
                                                        DataCell(
                                                            _buildQuantityField(
                                                                product,
                                                                _controllers[
                                                                    product]!)),
                                                        DataCell(Text((product[
                                                                    'qty'] *
                                                                product[
                                                                    'price'])
                                                            .toStringAsFixed(
                                                                2))),
                                                        DataCell(IconButton(
                                                          icon: const Icon(
                                                              Icons
                                                                  .remove_circle_outline,
                                                              color:
                                                                  Colors.grey),
                                                          onPressed: () {
                                                            setState(() {
                                                              _selectedProducts
                                                                  .remove(
                                                                      product);
                                                            });
                                                          },
                                                        )),
                                                      ]);
                                                    }).toList(),
                                                  ),
                                                ),
                                                Row(
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 45,
                                                              bottom: 20,
                                                              top: 20),
                                                      child: SizedBox(
                                                        width: 160,
                                                        child: ElevatedButton(
                                                          onPressed: () {
                                                            setState(() {
                                                              // Add a new product with default values
                                                              Map<String,
                                                                      dynamic>
                                                                  newProduct = {
                                                                'product': '',
                                                                'productDescription':
                                                                    '',
                                                                'categoryName':
                                                                    '',
                                                                'baseUnit': '',
                                                                'price': 0.0,
                                                                'qty': 0,
                                                              };

                                                              _selectedProducts
                                                                  .add(
                                                                      newProduct);
                                                              if (_controllers != null) {
                                                                _controllers[
                                                                        newProduct] =
                                                                    TextEditingController(
                                                                        text:
                                                                            '0');
                                                              }

                                                              // Make the total visible
                                                              _isTotalVisible =
                                                                  true;
                                                            });
                                                          },
                                                          style: ElevatedButton
                                                              .styleFrom(
                                                            backgroundColor:
                                                                Colors
                                                                    .blue[800],
                                                            shape:
                                                                RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          5),
                                                            ),
                                                          ),
                                                          child: Text(
                                                            '+ Add Product',
                                                            style: TextStyles
                                                                .button1,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    const Spacer(),
                                                    if (_isTotalVisible &&
                                                        _calculateTotal() != 0.00)
                                                      Padding(
                                                        padding: const EdgeInsets.only(right: 10),
                                                        child: Container(
                                                          decoration: BoxDecoration(
                                                              border: Border.all(
                                                                  color: Colors.blue)),
                                                          child: Padding(
                                                            padding: const EdgeInsets.only(
                                                                right: 20,
                                                                bottom: 10,left: 10,
                                                                top: 10),
                                                            // Adjust padding to match alignment
                                                            child: Align(
                                                              alignment:
                                                              Alignment.centerRight,
                                                              // Align text to the right
                                                              child: Text(
                                                                'Total: ₹${_calculateTotal().toStringAsFixed(2)}',
                                                                style: TextStyles.subhead,
                                                                textAlign: TextAlign
                                                                    .right, // Ensure right-aligned text
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      )
                                                  ],
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



 Widget _buildProductSearchField(Map<String, dynamic> product) {
   return SizedBox(
     height: 65,
     width: 200,
     child: Autocomplete<String>(
       optionsBuilder: (TextEditingValue textEditingValue) {
         if (textEditingValue.text.isEmpty) {
           return const Iterable<String>.empty();
         }
         return productList
             .where((p) => p['productDescription']
                 .toLowerCase()
                 .contains(textEditingValue.text.toLowerCase()))
             .map((p) => p['productDescription']);
       },
       onSelected: (String selection) {
         final selectedProduct = productList
             .firstWhere((p) => p['productDescription'] == selection);
         setState(() {
           product['product'] = selectedProduct['product'];
           product['categoryName'] = selectedProduct['categoryName'];
           product['baseUnit'] = selectedProduct['baseUnit'];
           product['price'] = selectedProduct['price'];
           product['productDescription'] =
               selectedProduct['productDescription'];
           product['currency'] = selectedProduct['currency'];
           product['productType'] = selectedProduct['productType'];
           product['standardPrice'] = selectedProduct['standardPrice'];
         });
       },
       optionsViewBuilder: (context, onSelected, options) {
         return Align(
           alignment: Alignment.topLeft,
           child: Material(
             elevation: 4.0,
             child: Container(
               decoration: BoxDecoration(
                 color: Colors.white, // Set background color to white
                 borderRadius: BorderRadius.circular(8.0), // Set border radius
               ),
               width: 200, // Set the desired width of the dropdown
               child: ListView(
                 padding: EdgeInsets.zero,
                 shrinkWrap: true,
                 children: options.map((String option) {
                   return ListTile(
                     title: Text(option),
                     onTap: () {
                       onSelected(option);
                     },
                   );
                 }).toList(),
               ),
             ),
           ),
         );
       },
         fieldViewBuilder: (
             BuildContext context,
             TextEditingController textEditingController,
             FocusNode focusNode,
             ord.VoidCallback onFieldSubmitted,
             ) {
           textEditingController.text = product['productDescription'] ?? '';
           return Padding(
             padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 8), // External padding for space around TextFormField
             child: TextFormField(
               textAlign: TextAlign.start,
               controller: textEditingController,
               focusNode: focusNode,
               decoration: InputDecoration(
                 filled: true,
                 fillColor: Colors.grey[100],
                 contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15), // Internal padding for text area
                 border: OutlineInputBorder( // Add an outline border to make the padding more visible
                   borderRadius: BorderRadius.circular(8.0),
                   borderSide: BorderSide.none, // Optional: Remove border for a cleaner look
                 ),
                 hintText: 'Search Product',
                 hintStyle: TextStyles.body,
               ),
             ),
           );
         }
     ),
   );
 }


  String calculateTotalPrice(Map<String, dynamic> product) {

    double total = product['qty'] * product['price'];

    return total.toStringAsFixed(2);
  }

  Widget _buildQuantityField(
      Map<String, dynamic> product, TextEditingController controller) {

    if (controller.text != product['qty'].toString()) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final newText = product['qty']?.toString() ?? '';
        if (controller.text != newText) {
          controller.value = TextEditingValue(
            text: newText,
            selection: TextSelection.collapsed(offset: newText.length),
          );
        }
      });
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 5),
      child: SizedBox(
        width: 60,
        child: TextFormField(
          controller: controller,
          textAlign: TextAlign.start,
          keyboardType: TextInputType.number,
          onChanged: (value) {
            setState(() {
              if (value.isEmpty) {
                product['qty'] = 0;
              } else {
                final parsedValue = double.tryParse(value);
                if (parsedValue != null) {
                  product['qty'] = parsedValue;
                }
              }
            });
          },
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[100],
            contentPadding: const EdgeInsets.symmetric(
              vertical: 12,
              horizontal: 10,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide.none,
            ),
            hintText: 'Qty',
            hintStyle: TextStyles.body,
          ),
          style: TextStyles.body,
        ),
      ),
    );
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
                                      }); },
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
                          return Colors.blue.shade500.withOpacity(
                              0.8);
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
