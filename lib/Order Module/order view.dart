import 'dart:async';
import 'dart:convert';
import 'dart:html';
import 'dart:ui' as order;
import 'dart:math' as math;
import 'dart:ui' as ord;
import 'package:adaptive_scrollbar/adaptive_scrollbar.dart';
import 'package:btb/widgets/Api%20name.dart';
import 'package:btb/widgets/confirmdialog.dart';
import 'package:btb/widgets/pagination.dart';
import 'package:btb/widgets/productclass.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../../Order Module/firstpage.dart';
import '../../dashboard/dashboard.dart';
import '../../widgets/custom loading.dart';
import '../../widgets/no datafound.dart';
import '../../widgets/productsap.dart' as ord;
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
  List<String> _sortOrder = List.generate(5, (index) => 'asc');
  List<String> columns = [
    'Order ID',
    'Customer ID',
    'Order Date',
    'Total',
    'Status',
  ];
  bool _hasShownPopup = false;
  List<double> columnWidths = [95, 110, 110, 95, 150, 140];
  List<bool> columnSortState = [true, true, true, true, true, true];
  Timer? _searchDebounceTimer;
  String _searchText = '';
  bool isOrdersSelected = false;
  bool _loading = false;
  detail? _selectedProduct;
  late TextEditingController _dateController;
  Map<String, dynamic> PaymentMap = {};

  int startIndex = 0;
  List<Product> filteredProducts = [];
  int currentPage = 1;
  String? dropdownValue1 = 'Status';
  final ScrollController verticalScroll = ScrollController();
  final ScrollController horizontalScroll = ScrollController();

  late Future<List<detail>> futureOrders;

  // List<ord.ProductData> productList = [];

  final ScrollController _scrollController = ScrollController();
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
  final TextEditingController mobilePhoneNumberController =TextEditingController();
  final TextEditingController orderIdController =TextEditingController();
  final TextEditingController orderDateController =TextEditingController();
  final TextEditingController totalAmountController =TextEditingController();
  //final TextEditingController orderIdController =TextEditingController();
  String companyName = window.sessionStorage["company Name"] ?? " ";

  DateTime? _selectedDate;
  List<detail> filteredData = [];
  bool _isTotalVisible = false;
  late AnimationController _controller;
  bool _isHovered1 = false;
  late Animation<double> _shakeAnimation;
  String status = '';
  String selectDate = '';

  String token = window.sessionStorage["token"] ?? " ";
  String userId = window.sessionStorage["userId"] ?? " ";
  String? dropdownValue2 = 'Select Year';

  List<Map<String, dynamic>> productList = [];
  List<Map<String, dynamic>> _selectedProducts = [];

  final List<Map<String, dynamic>> _products = [
    {'name': 'Product 1', 'price': 100},
    {'name': 'Product 2', 'price': 200},
    {'name': 'Product 3', 'price': 300},
  ];




// Function to calculate the total amount
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
          // Handle response when it's a List
          setState(() {
            var matchingOrder = decodedResponse.firstWhere(
                  (order) => order['orderId'] == widget.orderId,
              orElse: () => null,
            );

            if (matchingOrder != null) {
              // Populate _selectedProducts
              if (matchingOrder.containsKey('items') &&
                  matchingOrder['items'] is List) {
                _selectedProducts =
                List<Map<String, dynamic>>.from(matchingOrder['items']);
              } else {
                throw Exception('No matching order or invalid items structure');
              }

              // Populate controllers
              orderIdController.text = matchingOrder['orderId'] ?? '';
              orderDateController.text = matchingOrder['orderDate'] ?? '';
              totalAmountController.text =
                  matchingOrder['total']?.toString() ?? '';
            } else {
              throw Exception('Order not found');
            }
          });
        } else if (decodedResponse is Map<String, dynamic>) {
          // Handle response when it's a Map
          if (decodedResponse.containsKey('items') &&
              decodedResponse['items'] is List) {
            setState(() {
              _selectedProducts =
              List<Map<String, dynamic>>.from(decodedResponse['items']);

              // Populate controllers
              orderIdController.text = decodedResponse['orderId'] ?? '';
              orderDateController.text = decodedResponse['orderDate'] ?? '';
              totalAmountController.text =
                  decodedResponse['total']?.toString() ?? '';
            });
          } else {
            throw Exception('Invalid JSON structure: Missing "items" key or invalid type');
          }
        } else {
          throw Exception('Unexpected JSON structure');
        }
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching customer data: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }





  // Future<void> GetCustomerData(int page, int itemsPerPage) async {
  //   if (isLoading) return;
  //   setState(() {
  //     isLoading = true;
  //   });
  //
  //   try {
  //     final response = await http.get(
  //       Uri.parse(
  //         '$apicall/user_master/get_all_customer_data?page=$page&limit=$itemsPerPage', // Adjusted for API call
  //       ),
  //       headers: {
  //         "Content-type": "application/json",
  //         "Authorization": 'Bearer $token',
  //       },
  //     );
  //
  //     if (response.statusCode == 200) {
  //       final jsonData = jsonDecode(response.body);
  //       List<ord.BusinessPartnerData> products = [];
  //
  //       if (jsonData != null && jsonData.containsKey('d') && jsonData['d'].containsKey('results')) {
  //         var results = jsonData['d']['results'];
  //         // Mapping the relevant fields for each product
  //         products = results.map<ord.BusinessPartnerData>((item) {
  //           return ord.BusinessPartnerData(
  //             businessPartner: item['BusinessPartner'] ?? '',
  //             businessPartnerName: item['BusinessPartnerName'] ?? '',
  //             customer: item['Customer'] ?? '',
  //             addressID: item['AddressID'] ?? '',
  //             cityName: item['CityName'] ?? '',
  //             postalCode: item['PostalCode'] ?? '',
  //             streetName: item['StreetName'] ?? '',
  //             region: item['Region'] ?? '',
  //             telephoneNumber1: item['TelephoneNumber1'] ?? '',
  //             country: item['Country'] ?? '',
  //             districtName: item['DistrictName'] ?? '',
  //             emailAddress: item['EmailAddress'] ?? '',
  //             mobilePhoneNumber: item['MobilePhoneNumber'] ?? '',
  //           );
  //         }).toList();
  //
  //         setState(() {
  //           //productList = products;
  //           totalPages = (results.length / itemsPerPage).ceil();  // Update total pages based on new structure
  //           print(totalPages);  // Debugging output
  //           //_filterAndPaginateProducts();
  //         });
  //       }
  //     } else {
  //       throw Exception('Failed to load data');
  //     }
  //   } catch (e) {
  //     print('Error decoding JSON: $e');
  //     // Optionally, show an error message to the user
  //   } finally {
  //     setState(() {
  //       isLoading = false;
  //     });
  //   }
  // }

  // final List<Map<String, dynamic>> _selectedProducts = [];

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
        "StandardPrice": product['price'] ?? '',
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
        '$apicall/order_master/add_order_master'; // Replace with your API endpoint
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token', // Dummy token
    };
    final body = {
      "deliveryLocation": cityNameController.text,
      //  "deliveryAddress": "123 Dummy Street, City",
      "contactPerson": businessPartnerNameController.text,
      //  "contactNumber": "1234567890",
      // "comments": "This is a dummy order comment.",
      // "status": "Not Started",
      "customerId": customerController.text,
      "orderDate": _dateController.text, // 2024-11-17T00:00:00
      "postalCode": postalCodeController.text, //
      "region": regionController.text, //
      "streetName": streetNameController.text, //
      "telephoneNumber": telephoneNumber1Controller.text, //
      "total": _calculateTotal(), // Dummy total amount
      "items": items, // Rows data processed above
    };

    try {
      // Make the POST API call
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: json.encode(body),
      );

      // Handle the response
      if (response.statusCode == 200) {
        print('API call successful');
        final responseData = json.decode(response.body);
        print('Response: $responseData');
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
              content: Row(
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
        // You can handle navigation or further logic here
      } else {
        print('API call failed with status code: ${response.statusCode}');
        print('Response: ${response.body}');
      }
    } catch (e) {
      print('Error during API call: $e');
    }
  }

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

  Future<void> fetchProducts1(int page, int itemsPerPage) async {
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
      // if(token == " ")
      // {
      //   showDialog(
      //     barrierDismissible: false,
      //     context: context,
      //     builder: (BuildContext context) {
      //       return
      //         AlertDialog(
      //           shape: RoundedRectangleBorder(
      //             borderRadius: BorderRadius.circular(15.0),
      //           ),
      //           contentPadding: EdgeInsets.zero,
      //           content: Column(
      //             mainAxisSize: MainAxisSize.min,
      //             children: [
      //               Padding(
      //                 padding: const EdgeInsets.all(16.0),
      //                 child: Column(
      //                   children: [
      //                     // Warning Icon
      //                     Icon(Icons.warning, color: Colors.orange, size: 50),
      //                     SizedBox(height: 16),
      //                     // Confirmation Message
      //                     Text(
      //                       'Session Expired',
      //                       style: TextStyle(
      //                         fontSize: 16,
      //                         fontWeight: FontWeight.bold,
      //                         color: Colors.black,
      //                       ),
      //                     ),
      //                     Text("Please log in again to continue",style: TextStyle(
      //                       fontSize: 12,
      //
      //                       color: Colors.black,
      //                     ),),
      //                     SizedBox(height: 20),
      //                     // Buttons
      //                     Row(
      //                       mainAxisAlignment: MainAxisAlignment.center,
      //                       children: [
      //                         ElevatedButton(
      //                           onPressed: () {
      //                             // Handle Yes action
      //                             context.go('/');
      //                             // Navigator.of(context).pop();
      //                           },
      //                           style: ElevatedButton.styleFrom(
      //                             backgroundColor: Colors.white,
      //                             side: BorderSide(color: Colors.blue),
      //                             shape: RoundedRectangleBorder(
      //                               borderRadius: BorderRadius.circular(10.0),
      //                             ),
      //                           ),
      //                           child: Text(
      //                             'ok',
      //                             style: TextStyle(
      //                               color: Colors.blue,
      //                             ),
      //                           ),
      //                         ),
      //                       ],
      //                     ),
      //                   ],
      //                 ),
      //               ),
      //             ],
      //           ),
      //         );
      //     },
      //   ).whenComplete(() {
      //     _hasShownPopup = false;
      //   });
      //
      // }
      // else{
      //   if (response.statusCode == 200) {
      //     final jsonData = jsonDecode(response.body);
      //     List<detail> products = [];
      //     if (jsonData != null) {
      //       if (jsonData is List) {
      //         products = jsonData.map((item) => detail.fromJson(item)).toList();
      //       } else if (jsonData is Map && jsonData.containsKey('body')) {
      //         products = (jsonData['body'] as List)
      //             .map((item) => detail.fromJson(item))
      //             .toList();
      //         totalItems =
      //             jsonData['totalItems'] ?? 0; // Get the total number of items
      //       }
      //
      //       if (mounted) {
      //         setState(() {
      //           totalPages = (products.length / itemsPerPage).ceil();
      //           print('pages');
      //           print(totalPages);
      //           productList = products;
      //           print(productList);
      //           _filterAndPaginateProducts();
      //         });
      //       }
      //     }
      //   } else {
      //     throw Exception('Failed to load data');
      //   }
      // }
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
          _buildMenuItem(
              'Customer', Icons.account_circle_outlined, Colors.white, '/Customer'),
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
                  'Orders', Icons.warehouse_outlined, Colors.blue[900]!, '/Order_List')),

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

  @override
  void initState() {
    super.initState();
    print(userId ?? '');
    print(widget.orderId ?? '');
    //  fetchProducts

    //fetchProducts(currentPage, itemsPerPage);

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
    //_dateController = TextEditingController();
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

  // double calculateTotalAmount(List<Map<String, dynamic>> products) {
  //   double total = 0.0;
  //   for (var product in products) {
  //     total += product['qty'] * product['price'];
  //   }
  //   return total;
  // }

  @override
  Widget build(BuildContext context) {
    //   double totalAmount = calculateTotalAmount(productList);
    // double overallTotal = productList
    //     .map((product) => product['qty'] * product['price'])
    //     .fold(0.0, (sum, total) => sum + total);
    //String? role = Provider.of<UserRoleProvider>(context).role;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.grey[50],
        //backgroundColor: const Color.fromRGBO(21, 101, 192, 0.07),
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
                      //   double overallTotal = _selectedProducts.fold(0, (sum, product) {return sum + (product['qty'] * product['price']);});
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
                                          // Soft grey shadow
                                          spreadRadius: 3,
                                          blurRadius: 3,
                                          offset: const Offset(0, 3),
                                        ),
                                      ], // border-radius: 8px
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(height: 20,),
                                        Row(
                                          children: [
                                            Padding(
                                              padding:
                                              EdgeInsets.only(top: 20, left: 30,bottom: 20),
                                              child: Text(
                                                'Order ID: ${orderIdController.text}',
                                                style: TextStyles.body2,
                                              ),
                                            ),
                                            Spacer(),
                                            Padding(
                                              padding: EdgeInsets.only(
                                                  right: maxWidth * 0.04,top: 20,bottom: 20
                                              ),
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
                                            dataRowColor: MaterialStateProperty.resolveWith<Color>(
                                                  (Set<MaterialState> states) {
                                                return Colors.white; // Set row background to white
                                              },
                                            ),
                                            columns: [
                                              DataColumn(label: Text('S.NO', style: TextStyles.subhead)),
                                              DataColumn(label: Text('Product Name', style: TextStyles.subhead)),
                                              DataColumn(label: Text('Category', style: TextStyles.subhead)),
                                              DataColumn(label: Text('Unit', style: TextStyles.subhead)),
                                              DataColumn(label: Text('Price', style: TextStyles.subhead)),
                                              DataColumn(label: Text('Qty', style: TextStyles.subhead)),
                                              DataColumn(label: Text('Total Amount', style: TextStyles.subhead)),

                                            ],
                                            rows: _selectedProducts.map((product) {
                                              int index = _selectedProducts.indexOf(product) + 1;
                                              return DataRow(cells: [
                                                DataCell(Text('$index')), // Serial Number
                                                DataCell(Text(product['productDescription'] ?? '')), // Product Name
                                                DataCell(Text(product['categoryName'] ?? '')), // Category
                                                DataCell(Text(product['baseUnit'] ?? '')), // Unit
                                                DataCell(Text(product['standardPrice']?.toStringAsFixed(2) ?? '0.00')), // Price
                                                DataCell(Text(product['qty'] ?? '0')), // Quantity
                                                DataCell(Text(
                                                    (double.parse(product['qty']) * product['standardPrice'])
                                                        .toStringAsFixed(2))),
                                              ]);
                                            }).toList(),
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            Spacer(),
                                            Padding(
                                              padding: const EdgeInsets.only(right: 10,bottom: 10),
                                              child: Container(
                                                decoration: BoxDecoration(
                                                    border: Border.all(
                                                        color: Colors.blue)),
                                                child: Padding(
                                                  padding: const EdgeInsets.only(  right: 20,
                                                      bottom: 10,left: 10,
                                                      top: 10),
                                                  child: Align(
                                                    alignment:
                                                    Alignment.centerRight,
                                                    child: Text(
                                                      'Total: \₹${totalAmountController.text}',
                                                      // Display the total
                                                      style: TextStyles.subhead,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        )
                                        // Row(
                                        //   children: [
                                        //     Spacer(),
                                        //     Padding(
                                        //       padding: const EdgeInsets.only(right: 100,top: 20,bottom: 40),
                                        //       child: Text(
                                        //         'Total: \₹${totalAmountController.text}',
                                        //         // Display the total
                                        //         style: TextStyles.subhead,
                                        //       ),
                                        //     ),
                                        //   ],
                                        // )

                                      ],
                                    ),
                                  ),
                                ),

                                // Padding(
                                //   padding: const EdgeInsets.only(
                                //       top: 40, left: 70, right: 50, bottom: 30),
                                //   child: Container(
                                //     //width: screenWidth * 0.8,
                                //     decoration: BoxDecoration(
                                //       color: const Color(0xFFFFFFFF),
                                //       // background: #FFFFFF
                                //       boxShadow: [
                                //         const BoxShadow(
                                //           offset: Offset(0, 3),
                                //           blurRadius: 6,
                                //           color: Color(
                                //               0x29000000), // box-shadow: 0px 3px 6px #00000029
                                //         )
                                //       ],
                                //       border: Border.all(
                                //         // border: 2px
                                //         color: const Color(
                                //             0xFFB2C2D3), // border: #B2C2D3
                                //       ),
                                //       borderRadius: const BorderRadius.all(
                                //           Radius.circular(8)), // border-radius: 8px
                                //     ),
                                //     child: Column(
                                //
                                //       crossAxisAlignment: CrossAxisAlignment.start,
                                //       children: [
                                //         const Padding(
                                //           padding:
                                //               EdgeInsets.only(top: 10, left: 30),
                                //           child: Text(
                                //             'Item Table',
                                //             style: TextStyle(
                                //                 fontSize: 19, color: Colors.black),
                                //           ),
                                //         ),
                                //         const SizedBox(height: 10),
                                //         Container(
                                //           width: 1300,
                                //           color: Colors.grey[100],
                                //           child: DataTable(
                                //
                                //             //
                                //              dataRowHeight: 57,
                                //              headingRowHeight: 50,
                                //             dataRowColor: MaterialStateProperty
                                //                 .resolveWith<Color>(
                                //               (Set<MaterialState> states) {
                                //                 return Colors
                                //                     .white; // Set row background to white
                                //               },
                                //             ),
                                //             columns: [
                                //               DataColumn(
                                //                   label: Text(
                                //                 'S.NO',
                                //                 style: TextStyles.subhead,
                                //               )),
                                //               DataColumn(
                                //                   label: Text(
                                //                 'Product Name',
                                //                 style: TextStyles.subhead,
                                //               )),
                                //               DataColumn(
                                //                   label: Text(
                                //                 'Category',
                                //                 style: TextStyles.subhead,
                                //               )),
                                //               DataColumn(
                                //                   label: Text(
                                //                 'Unit',
                                //                 style: TextStyles.subhead,
                                //               )),
                                //               DataColumn(
                                //                   label: Text(
                                //                 'Price',
                                //                 style: TextStyles.subhead,
                                //               )),
                                //               DataColumn(
                                //                   label: Text(
                                //                 'Qty',
                                //                 style: TextStyles.subhead,
                                //               )),
                                //               DataColumn(
                                //                   label: Text(
                                //                 'Total Amount',
                                //                 style: TextStyles.subhead,
                                //               )),
                                //               DataColumn(label: Text(' ')),
                                //             ],
                                //             rows: _selectedProducts.map((product) {
                                //               int index = _selectedProducts
                                //                       .indexOf(product) +
                                //                   1;
                                //               return DataRow(cells: [
                                //                 DataCell(Text('$index')),
                                //                 DataCell(_buildProductSearchField(
                                //                     product)),
                                //                 DataCell(Text(
                                //                     product['categoryName'] ?? '')),
                                //                 DataCell(Text(
                                //                     product['baseUnit'] ?? '')),
                                //                 DataCell(Text(product['price']
                                //                     .toStringAsFixed(2))),
                                //                 DataCell(
                                //                     _buildQuantityField(product)),
                                //                 DataCell(Text((product['qty'] *
                                //                         product['price'])
                                //                     .toStringAsFixed(2))),
                                //                 DataCell(IconButton(
                                //                   icon: Icon(
                                //                       Icons.remove_circle_outline,
                                //                       color: Colors.grey),
                                //                   onPressed: () {
                                //                     setState(() {
                                //                       _selectedProducts
                                //                           .remove(product);
                                //                     });
                                //                   },
                                //                 )),
                                //               ]);
                                //             }).toList(),
                                //             // rows: _selectedProducts.map((product) {
                                //             //         return DataRow(cells: [
                                //             //           DataCell(Text('${1}')),
                                //             //         DataCell(_buildProductSearchField(product)),
                                //             //         DataCell(_buildQuantityField(product)),
                                //             //           DataCell(_buildProductSearchField(product)),
                                //             //           DataCell(_buildQuantityField(product)),
                                //             //           DataCell(_buildProductSearchField(product)),
                                //             //         DataCell(Text(product['price'].toString())),
                                //             //         DataCell(Text((product['qty'] * product['price']).toStringAsFixed(2))),
                                //             //         ]);
                                //             //         }).toList(),
                                //           ),
                                //
                                //         ),
                                //         Row(
                                //           children: [
                                //             Padding(
                                //               padding: const EdgeInsets.only(
                                //                   left: 45, bottom: 20, top: 20),
                                //               child: SizedBox(
                                //                 width: 140,
                                //                 child: ElevatedButton(
                                //                   onPressed: () {
                                //                     setState(() {
                                //                       _selectedProducts.add({
                                //                         'product': '',
                                //                         'productDescription': '',
                                //                         // Product name, initially empty
                                //                         'categoryName': '',
                                //                         // Default value for category
                                //                         'baseUnit': '',
                                //                         // Default value for unit
                                //                         'price': 0.0,
                                //                         // Default price
                                //                         'qty': 1,
                                //                         // Default quantity
                                //                       });
                                //                       _isTotalVisible = true;
                                //                     });
                                //                   },
                                //                   style: ElevatedButton.styleFrom(
                                //                       backgroundColor:
                                //                       Colors.blue[800],
                                //                       padding: null,
                                //                       shape: RoundedRectangleBorder(
                                //                           borderRadius:
                                //                           BorderRadius.circular(
                                //                               5))),
                                //                   child: const Text(
                                //                     '+ Add Product',
                                //                     style: TextStyle(
                                //                         color: Colors.white),
                                //                   ),
                                //                 ),
                                //               ),
                                //             ),
                                //             Spacer(),
                                //             Text('Total: $_calculateTotal')
                                //           ],
                                //         ),
                                //       ],
                                //     ),
                                //   ),
                                // ),
                              ],
                            ),
                          ))
                    } else
                      ...{
                        SizedBox(
                          height: maxHeight,
                          child:  AdaptiveScrollbar(
                              position: ScrollbarPosition.bottom,
                              controller: horizontalScroll,
                              child:   SingleChildScrollView(
                                controller: horizontalScroll,
                                scrollDirection: Axis.horizontal,
                                child: SingleChildScrollView(
                                  controller: verticalScroll,
                                  scrollDirection: Axis.vertical,
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 3,right: 0),
                                    child: Container(
                                      color: Colors.grey[50],
                                      width: 1500,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(left: 30, top: 10),
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
                                            margin: const EdgeInsets.only( top: 5),
                                            height: 1,
                                            width: 1500,
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
                                                    // Soft grey shadow
                                                    spreadRadius: 3,
                                                    blurRadius: 3,
                                                    offset: const Offset(0, 3),
                                                  ),
                                                ], // border-radius: 8px
                                              ),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  SizedBox(height: 20,),
                                                  Row(
                                                    children: [
                                                      Padding(
                                                        padding:
                                                        EdgeInsets.only(top: 20, left: 30,bottom: 20),
                                                        child: Text(
                                                          'Order ID: ${orderIdController.text}',
                                                          style: TextStyles.body2,
                                                        ),
                                                      ),
                                                      Spacer(),
                                                      Padding(
                                                        padding: EdgeInsets.only(
                                                            right: maxWidth * 0.04,top: 20,bottom: 20
                                                        ),
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
                                                      dataRowColor: MaterialStateProperty.resolveWith<Color>(
                                                            (Set<MaterialState> states) {
                                                          return Colors.white; // Set row background to white
                                                        },
                                                      ),
                                                      columns: [
                                                        DataColumn(label: Text('S.NO', style: TextStyles.subhead)),
                                                        DataColumn(label: Text('Product Name', style: TextStyles.subhead)),
                                                        DataColumn(label: Text('Category', style: TextStyles.subhead)),
                                                        DataColumn(label: Text('Unit', style: TextStyles.subhead)),
                                                        DataColumn(label: Text('Price', style: TextStyles.subhead)),
                                                        DataColumn(label: Text('Qty', style: TextStyles.subhead)),
                                                        DataColumn(label: Text('Total Amount', style: TextStyles.subhead)),

                                                      ],
                                                      rows: _selectedProducts.map((product) {
                                                        int index = _selectedProducts.indexOf(product) + 1;
                                                        return DataRow(cells: [
                                                          DataCell(Text('$index')), // Serial Number
                                                          DataCell(Text(product['productDescription'] ?? '')), // Product Name
                                                          DataCell(Text(product['categoryName'] ?? '')), // Category
                                                          DataCell(Text(product['baseUnit'] ?? '')), // Unit
                                                          DataCell(Text(product['standardPrice']?.toStringAsFixed(2) ?? '0.00')), // Price
                                                          DataCell(Text(product['qty'] ?? '0')), // Quantity
                                                          DataCell(Text(
                                                              (double.parse(product['qty']) * product['standardPrice'])
                                                                  .toStringAsFixed(2))),
                                                        ]);
                                                      }).toList(),
                                                    ),
                                                  ),

                                                  Row(
                                                    children: [
                                                      Spacer(),
                                                      Padding(
                                                        padding: const EdgeInsets.only(right: 10,bottom: 10),
                                                        child: Container(
                                                          decoration: BoxDecoration(
                                                              border: Border.all(
                                                                  color: Colors.blue)),
                                                          child: Padding(
                                                            padding: const EdgeInsets.only(  right: 20,
                                                                bottom: 10,left: 10,
                                                                top: 10),
                                                            child: Align(
                                                              alignment:
                                                              Alignment.centerRight,
                                                              child: Text(
                                                                'Total: \₹${totalAmountController.text}',
                                                                // Display the total
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
                                    ),
                                  ),
                                ),
                              )
                          ),
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
      height: 60,
      width: 320, // Set the desired width of the suggestion box
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
                width: 300, // Set the desired width of the dropdown
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
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              textAlign: TextAlign.start,
              controller: textEditingController,
              focusNode: focusNode,
              // maxLines: 1,
              // minLines: 1,
              //expands: true,
              decoration: InputDecoration(
                filled: true,
                //  contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                fillColor: Colors.grey[100],
                // contentPadding: EdgeInsets.symmetric(horizontal: 7),
                border: InputBorder.none,
                contentPadding:
                const EdgeInsets.symmetric(vertical: 18, horizontal: 10),
                // Removes the border
                hintText: 'Search Product',
                hintStyle: TextStyles.body,
              ),
              maxLines: 1,
              minLines: 1,
            ),
          );
        },
      ),
    );
  }

  String calculateTotalPrice(Map<String, dynamic> product) {
    // Calculate total price
    double total = product['qty'] * product['price'];
    // Return formatted string
    return total.toStringAsFixed(2);
  }

  Widget _buildQuantityField(Map<String, dynamic> product) {
    return SizedBox(
      width: 100,
      child: Padding(
        padding: const EdgeInsets.only(right: 30, top: 8, bottom: 8, left: 8),
        child: TextFormField(
          textAlign: TextAlign.start,
          keyboardType: TextInputType.number,
          onChanged: (value) {
            setState(() {
              product['qty'] = int.tryParse(value) ?? 1;
            });
          },
          decoration: InputDecoration(
            filled: true,
            // Ensures the fillColor is applied
            fillColor: Colors.grey[100],

            // Set the background color
            contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 10),
            border: InputBorder.none,
            // Removes the border
            //hintText: 'Enter Qty',
            hintStyle: TextStyles.body,
          ),
        ),
      ),
    );
  }

  Widget buildDataTable2() {
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
                          // Dynamic width based on user interaction
                          child: Row(
//crossAxisAlignment: CrossAxisAlignment.end,
//   mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                column,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.indigo[900],
                                  fontSize: 13,
                                ),
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
                rows: []),
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
// double padding = constraints.maxWidth * 0.065;
      double right = MediaQuery.of(context).size.width * 0.92;

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
// List.generate(5, (index)
                columns: columns.map((column) {
                  return DataColumn(
                    label: Stack(
                      children: [
                        Container(
                          padding: null,
                          width: columnWidths[columns.indexOf(column)],
                          // Dynamic width based on user interaction
                          child: Row(
//crossAxisAlignment: CrossAxisAlignment.end,
//   mainAxisAlignment: MainAxisAlignment.end,
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
//SizedBox(width: 50,),
//Padding(
//  padding:  EdgeInsets.only(left: columnWidths[index]-50,),
//  child:
                              const Spacer(),
                              MouseRegion(
                                cursor: SystemMouseCursors.resizeColumn,
                                child: GestureDetector(
                                    onHorizontalDragUpdate: (details) {
// Update column width dynamically as user drags
                                      setState(() {
                                        columnWidths[columns.indexOf(column)] +=
                                            details.delta.dx;
                                        columnWidths[columns.indexOf(column)] =
                                            columnWidths[
                                            columns.indexOf(column)]
                                                .clamp(151.0, 300.0);
                                      });
// setState(() {
//   columnWidths[columns.indexOf(column)] += details.delta.dx;
//   if (columnWidths[columns.indexOf(column)] < 50) {
//     columnWidths[columns.indexOf(column)] = 50; // Minimum width
//   }
// });
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
                              Container(
                                width: columnWidths[0],
                                // Same dynamic width as column headers
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
                              Container(
                                width: columnWidths[1],
                                child: Text(
                                  detail.orderDate!,
                                  style: const TextStyle(
                                    color: Color(0xFFA6A6A6),
                                  ),
                                ),
                              ),
                            ),
                            DataCell(
                              Container(
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
                              Container(
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
                              Container(
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
                              Container(
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
                          onSelectChanged: (selected) {
                            if (selected != null && selected) {
                              print('what is this');
                              print(detail.invoiceNo);
                              print(productList);
                              print(detail.paymentStatus);
//final detail = filteredData[(currentPage - 1) * itemsPerPage + index];
                            }
                          });
                    })),
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
                          // Dynamic width based on user interaction
                          child: Row(
//crossAxisAlignment: CrossAxisAlignment.end,
//   mainAxisAlignment: MainAxisAlignment.end,
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
                rows: []),
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
// double padding = constraints.maxWidth * 0.065;
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
// List.generate(5, (index)
                columns: columns.map((column) {
                  return DataColumn(
                    label: Stack(
                      children: [
                        Container(
                          padding: null,
                          width: columnWidths[columns.indexOf(column)],
                          // Dynamic width based on user interaction
                          child: Row(
//crossAxisAlignment: CrossAxisAlignment.end,
//   mainAxisAlignment: MainAxisAlignment.end,
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
//SizedBox(width: 50,),
//Padding(
//  padding:  EdgeInsets.only(left: columnWidths[index]-50,),
//  child:
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
                              Container(
                                width: columnWidths[0],
                                // Same dynamic width as column headers
                                child: Text(
                                  detail.orderId.toString(),
                                  style: TextStyles.body,
                                ),
                              ),
                            ),
                            DataCell(
                              Container(
                                width: columnWidths[1],
                                child: Text(
                                  detail.orderDate,
                                  style: TextStyles.body,
                                ),
                              ),
                            ),
                            DataCell(
                              Container(
                                width: columnWidths[2],
                                child: Text(
                                  detail.invoiceNo!,
                                  style: TextStyles.body,
                                ),
                              ),
                            ),
                            DataCell(
                              Container(
                                width: columnWidths[3],
                                child: Text(
                                  detail.total.toString(),
                                  style: TextStyles.body,
                                ),
                              ),
                            ),
                            DataCell(
                              Container(
                                width: columnWidths[4],
                                child: Text(
                                  detail.deliveryStatus.toString(),
                                  style: TextStyles.body,
                                ),
                              ),
                            ),
                            // DataCell(
                            //   Container(
                            //     width: columnWidths[4],
                            //     child: Text(
                            //       detail.paymentStatus.toString(),
                            //       style: TextStyles.body,
                            //     ),
                            //   ),
                            // ),
                          ],
                          onSelectChanged: (selected) {
                            if (selected != null && selected) {
                              print('what is this');
                              print(detail.invoiceNo);
                              print(productList);
                              print(detail.paymentStatus);
//final detail = filteredData[(currentPage - 1) * itemsPerPage + index];
                            }
                          });
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
