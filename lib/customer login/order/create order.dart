import 'dart:async';
import 'dart:convert';
import 'dart:html';
import 'dart:ui' as order;
import 'dart:math' as math;
import 'dart:ui' as ord;
import 'package:adaptive_scrollbar/adaptive_scrollbar.dart';
import 'package:btb/admin/Api%20name.dart';
import 'package:btb/widgets/confirmdialog.dart';
import 'package:btb/widgets/pagination.dart';
import 'package:btb/widgets/productclass.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;

import '../../Order Module/firstpage.dart';
import '../../dashboard/dashboard.dart';
import '../../widgets/custom loading.dart';
import '../../widgets/no datafound.dart';
import '../../widgets/productsap.dart' as ord;
import '../../widgets/text_style.dart';




void main() {
  runApp(const CreateOrder());
}

class CreateOrder extends StatefulWidget {
  const CreateOrder({super.key});

  @override
  State<CreateOrder> createState() => _CreateOrderState();
}

class _CreateOrderState extends State<CreateOrder> with SingleTickerProviderStateMixin {
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
  final ScrollController horizontalScroll = ScrollController();

  late Future<List<detail>> futureOrders;
 // List<ord.ProductData> productList = [];



  final ScrollController _scrollController = ScrollController();
  List<dynamic> detailJson = [];
  String searchQuery = '';
  List<detail> filteredData = [];
  late AnimationController _controller;
  bool _isHovered1 = false;
  late Animation<double> _shakeAnimation;
  String status = '';
  String selectDate = '';

  String token = window.sessionStorage["token"] ?? " ";
  String? dropdownValue2 = 'Select Year';


  List<Map<String, dynamic>> productList = [];
  final List<Map<String, dynamic>> _selectedProducts = [];

  final List<Map<String, dynamic>> _products = [
    {'name': 'Product 1', 'price': 100},
    {'name': 'Product 2', 'price': 200},
    {'name': 'Product 3', 'price': 300},
  ];


  Future<void> fetchProducts(int page, int itemsPerPage) async {
    if (isLoading) return;
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse('$apicall/productmaster/get_all_product_data?page=$page&limit=$itemsPerPage'),
        headers: {
          "Content-type": "application/json",
          "Authorization": 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData != null && jsonData.containsKey('d') && jsonData['d'].containsKey('results')) {
          var results = jsonData['d']['results'];

          // Update the product list
          setState(() {
            productList = results.map<Map<String, dynamic>>((item) {
              return {
                'product': item['Product'] ?? '',
                'categoryName': item['CategoryName'] ?? '',
                'productType': item['ProductType'] ?? '',
                'baseUnit': item['BaseUnit'] ?? '',
                'productDescription': item['ProductDescription'] ?? '',
                'price': double.tryParse(item['StandardPrice'] ?? '0.00') ?? 0.00,
                'currency': item['Currency'] ?? 'INR',
              };
            }).toList();
            totalPages = (results.length / itemsPerPage).ceil();
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

 // final List<Map<String, dynamic>> _selectedProducts = [];


  Future<void> callApi() async {
    List<Map<String, dynamic>> items = [];

    // for (int i = 0; i < widget.selectedProducts.length; i++) {
    //   Product product = widget.selectedProducts[i];
    //   items.add({
    //     "productName": product.productName,
    //     "category": product.category,
    //     "subCategory": product.subCategory,
    //     "price": product.price,
    //     "qty": product.quantity,
    //     "actualAmount": product.price * product.quantity,
    //     "totalAmount": (product.totalAmount * product.quantity),
    //     "discount": product.discount,
    //     "tax": product.tax,
    //   });
    // }

    final url = '$apicall/order_master/add_order_master';
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${token}',
    };
    final body = {
      // "orderDate": data2['date'],
      // "deliveryLocation": EmailIdController.text,
      // "deliveryAddress": deliveryAddressController.text,
      // "contactPerson": contactPersonController.text,
      // "contactNumber": contactNumberController.text,
      // "comments": ShippingAddress.text,
      // "status": "Not Started",
      // "customerId": CusIdController.text,
      // "total": data2['totalAmount'],
      // "items": items,
    };

    final response = await http.post(Uri.parse(url),
        headers: headers, body: json.encode(body));
    // if (token == " ") {
    //   showDialog(
    //     barrierDismissible: false,
    //     context: context,
    //     builder: (BuildContext context) {
    //       return AlertDialog(
    //         shape: RoundedRectangleBorder(
    //           borderRadius: BorderRadius.circular(15.0),
    //         ),
    //         contentPadding: EdgeInsets.zero,
    //         content: Column(
    //           mainAxisSize: MainAxisSize.min,
    //           children: [
    //             Padding(
    //               padding: const EdgeInsets.all(16.0),
    //               child: Column(
    //                 children: [
    //                   // Warning Icon
    //                   Icon(Icons.warning, color: Colors.orange, size: 50),
    //                   SizedBox(height: 16),
    //                   // Confirmation Message
    //                   Text(
    //                     'Session Expired',
    //                     style: TextStyle(
    //                       fontSize: 16,
    //                       fontWeight: FontWeight.bold,
    //                       color: Colors.black,
    //                     ),
    //                   ),
    //                   Text(
    //                     "Please log in again to continue",
    //                     style: TextStyle(
    //                       fontSize: 12,
    //                       color: Colors.black,
    //                     ),
    //                   ),
    //                   SizedBox(height: 20),
    //                   // Buttons
    //                   Row(
    //                     mainAxisAlignment: MainAxisAlignment.center,
    //                     children: [
    //                       ElevatedButton(
    //                         onPressed: () {
    //                           // Handle Yes action
    //                           context.go('/');
    //                           // Navigator.of(context).pop();
    //                         },
    //                         style: ElevatedButton.styleFrom(
    //                           backgroundColor: Colors.white,
    //                           side: BorderSide(color: Colors.blue),
    //                           shape: RoundedRectangleBorder(
    //                             borderRadius: BorderRadius.circular(10.0),
    //                           ),
    //                         ),
    //                         child: Text(
    //                           'ok',
    //                           style: TextStyle(
    //                             color: Colors.blue,
    //                           ),
    //                         ),
    //                       ),
    //                     ],
    //                   ),
    //                 ],
    //               ),
    //             ),
    //           ],
    //         ),
    //       );
    //     },
    //   ).whenComplete(() {
    //     _hasShownPopup = false;
    //   });
    // } else {
    //   if (response.statusCode == 200) {
    //     print('API call successful');
    //     final responseData = json.decode(response.body);
    //     String? invoiceNo;
    //     // Add null checks and error handling
    //     String orderId;
    //
    //     // String orderId;
    //     try {
    //       orderId = responseData['orderId'];
    //       invoiceNo = responseData['invoiceNo'];
    //     } catch (e) {
    //       print('Error parsing orderId: $e');
    //       orderId = ''; // or some default value
    //     }
    //
    //     detail details;
    //     try {
    //       details = detail(
    //         orderId: orderId,
    //         orderDate: data2['date'],
    //         total: double.parse(data2['totalAmount']),
    //         status: '',
    //         // Initialize status as empty string
    //         deliveryStatus: '',
    //         // Initialize delivery status as empty string
    //         referenceNumber: '',
    //         items: [], // Initialize reference number as empty string
    //       );
    //     } catch (e) {
    //       print('Error creating detail object: $e');
    //       details = detail(
    //           orderId: '',
    //           orderDate: '',
    //           total: 0,
    //           status: '',
    //           deliveryStatus: '',
    //           referenceNumber: '',
    //           items: []); // or some default value
    //     }
    //
    //     if (details != null) {
    //       // await callApi2();
    //       List<OrderDetail> orderDetails = filteredData
    //           .map((detail) => OrderDetail(
    //         orderId: detail.orderId,
    //         orderDate: detail.orderDate,
    //         items: [], // initialize items as an empty list
    //         // Add other fields as needed
    //       ))
    //           .toList();
    //
    //       orderDetails.add(OrderDetail(
    //         orderId: details.orderId,
    //         orderDate: details.orderDate,
    //         items: [], // initialize items as an empty list
    //         // Add other fields as needed
    //       ));
    //
    //       // Check if filteredData is updated
    //       // if (filteredData.isNotEmpty) {
    //       //   // Create details object
    //       //   detail details = detail(
    //       //     orderId: orderId,
    //       //     orderDate: data2['date'],
    //       //     total: double.parse(data2['totalAmount']),
    //       //     status: '',
    //       //     // Initialize status as empty string
    //       //     deliveryStatus: '',
    //       //     // Initialize delivery status as empty string
    //       //     referenceNumber: '',
    //       //     items: [], // Initialize reference number as empty string
    //       //   );
    //       // }
    //
    //       // Navigate to next page
    //       // context.go('/Placed_Order_List', extra: {
    //       //   'product': details,
    //       //   'item': items,
    //       //   'body': body,
    //       //   'itemsList': items,
    //       //   'orderDetails': filteredData,
    //       // });
    //
    //       print('order');
    //       print(orderDetails);
    //       print(invoiceNo);
    //
    //       context.go('/Order_Placed', extra: {
    //         'product': details,
    //         'InvNo': invoiceNo,
    //         'item': items,
    //         'body': body,
    //         'status': orderId,
    //         'paymentStatus': PaymentMap,
    //         'itemsList': items,
    //         'orderDetails': orderDetails,
    //       });
    //       // context.go('/Placed_Order_List', extra: {
    //       //   'product': details,
    //       //   'item': items,
    //       //   'body': body,
    //       //   'itemsList': items,
    //       //  'orderDetails': orderDetails,
    //       // });
    //
    //       Future<void> navigateToNextPage() async {
    //         // Call the API to fetch the orders
    //         final orders = await fetchOrders();
    //
    //         // Update filteredData with the latest data
    //         setState(() {
    //           filteredData = orders.where((element) {
    //             final matchesSearchText = element.orderId!
    //                 .toLowerCase()
    //                 .contains(searchQuery.toLowerCase());
    //             String orderYear = '';
    //             if (element.orderDate.contains('/')) {
    //               final dateParts = element.orderDate.split('/');
    //               if (dateParts.length == 3) {
    //                 orderYear = dateParts[2]; // Extract the year
    //               }
    //             }
    //             // final orderYear = element.orderDate.substring(5,9);
    //             if (status.isEmpty && selectDate.isEmpty) {
    //               return matchesSearchText; // Include all products that match the search text
    //             }
    //             if (status == 'Status' && selectDate == 'SelectYear') {
    //               return matchesSearchText;
    //             }
    //             if (status == 'Status' && selectDate.isEmpty) {
    //               return matchesSearchText;
    //             }
    //             if (selectDate == 'SelectYear' && status.isEmpty) {
    //               return matchesSearchText;
    //             }
    //             if (status == 'Status' && selectDate.isNotEmpty) {
    //               return matchesSearchText &&
    //                   orderYear == selectDate; // Include all products
    //             }
    //             if (status.isNotEmpty && selectDate == 'SelectYear') {
    //               return matchesSearchText &&
    //                   element.status == status; // Include all products
    //             }
    //             if (status.isEmpty && selectDate.isNotEmpty) {
    //               return matchesSearchText &&
    //                   orderYear == selectDate; // Include all products
    //             }
    //
    //             if (status.isNotEmpty && selectDate.isEmpty) {
    //               return matchesSearchText &&
    //                   element.status == status; // Include all products
    //             }
    //             return matchesSearchText &&
    //                 (element.status == _category &&
    //                     element.orderDate == selectDate);
    //             //  return false;
    //           }).toList();
    //         });
    //
    //         // Navigate to the next page
    //         // Navigator.push(
    //         //   context,
    //         //   PageRouteBuilder(
    //         //     pageBuilder: (context, animation, secondaryAnimation) => SixthPage(
    //         //       product: details,
    //         //       item: items,
    //         //       body: body,
    //         //       itemsList: items,
    //         //       orderDetails: filteredData.map((detail) => OrderDetail(
    //         //         orderId: detail.orderId,
    //         //         orderDate: detail.orderDate, items: [],
    //         //         // Add other fields as needed
    //         //       )).toList(),
    //         //     ),
    //         //   ),
    //         // );
    //       }
    //
    //       navigateToNextPage();
    //     } else {
    //       print('Failed to create detail object, not navigating to SixthPage');
    //     }
    //   } else {
    //     print('API call failed with status code ${response.statusCode}');
    //   }
    // }
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
              Colors.blue[900]!, '/Cus_Home'),

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
                  'Orders', Icons.production_quantity_limits, Colors.blue[900]!, '/Customer_Order_List')),
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
    _dateController = TextEditingController();
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
  }

  @override
  void dispose() {
    _searchDebounceTimer
        ?.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //String? role = Provider.of<UserRoleProvider>(context).role;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color.fromRGBO(21, 101, 192, 0.07),

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
                              padding: const EdgeInsets.only(top: 5),
                              child: IconButton(
                                icon: const Icon(Icons.notifications),
                                color: Colors.black, // Default icon color
                                onPressed: () {
                                  // Handle notification icon press
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
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
                SingleChildScrollView(
                  child: Align(
                    // Added Align widget for the left side menu
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 80),
                      child: Container(
                        height: 1400,
                        width: 200,
                        color: const Color(0xFFF7F6FA),
                        padding:
                        const EdgeInsets.only(left: 15, top: 50, right: 15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: _buildMenuItems(context),
                        ),
                      ),
                    ),
                  ),
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
                left: 201,
                top: 60,
                right: 0,
                bottom: 0,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if(constraints.maxWidth >= 1300)...{
                Expanded(child: SingleChildScrollView(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 40),
                      child: Row(

                        children: [
                          IconButton(onPressed: (){
                            context.go('/Customer_Order_List');
                          }, icon: const Icon(Icons.arrow_back,size: 16,)),
                          Text('Create Order',style: TextStyles.header3,),
                        ],
                      ),
                    ),
                Padding(
                padding: const EdgeInsets.only(left: 50),
                child: SizedBox(
                  width: maxWidth,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    // mainAxisAlignment: MainAxisAlignment.start,
                    children: [


                      Padding(
                        padding:  EdgeInsets.only(right: maxWidth * 0.08,top: 30),
                        child:  Text(' Order Date',style: TextStyle(fontSize: maxWidth * 0.010,color: Colors.black87),),
                      ),

                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Align(
                              alignment: Alignment.topLeft,
                              child: Padding(
                                padding:
                                const EdgeInsets.only(right: 100, top: 10),
                                child: OutlinedButton(
                                  onPressed: () async {
                                    await callApi();

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
                                    ' Create Order',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),


                      //  ),
                      // SizedBox(height: 20.h),

                    ],
                  ),
                ),
              ),
              const SizedBox(height: 5,),
              Padding(
                padding: const EdgeInsets.only(left: 50),
                child: SizedBox(
                  height: 39,
                  width: maxWidth *0.13,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _dateController,
                          // Replace with your TextEditingController
                          readOnly: true,
                          decoration: InputDecoration(
                            suffixIcon: Padding(
                              padding: const EdgeInsets.only(right: 20),
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    top: 2, left: 10),
                                child: IconButton(
                                  icon: const Padding(
                                    padding: EdgeInsets.only(bottom: 16),
                                    child: Icon(Icons.calendar_month),
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
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 8),
                            border: const OutlineInputBorder(),
                            filled: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 40,left: 50,right: 100,bottom: 30),
                child: Container(
                  //width: screenWidth * 0.8,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFFFF), // background: #FFFFFF
                    boxShadow: [const BoxShadow(
                      offset: Offset(0, 3),
                      blurRadius: 6,
                      color: Color(0x29000000), // box-shadow: 0px 3px 6px #00000029
                    )],
                    border: Border.all(
                      // border: 2px
                      color: const Color(0xFFB2C2D3), // border: #B2C2D3
                    ),
                    borderRadius: const BorderRadius.all(Radius.circular(8)), // border-radius: 8px
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 10, left: 30),
                        child: Text(
                          'Order Details',
                          style: TextStyle(fontSize: 19,color: Colors.black),
                        ),
                      ),
                      const SizedBox(height: 10),
                      // SingleChildScrollView(
                      //   scrollDirection: Axis.horizontal,
                      //   child:
                      //
                      //   DataTable(
                      //     border: const TableBorder(
                      //       top: BorderSide(width:1 ,color: Colors.grey),
                      //       bottom: BorderSide(width:1 ,color: Colors.grey),
                      //       horizontalInside: BorderSide(width: 1,color: Colors.grey), // horizontal border inside the table
                      //       verticalInside: BorderSide(width: 1,color: Colors.grey),
                      //     ),
                      //     // border: TableBorder.all(color: const Color(0xFFB2C2D3)),
                      //     columnSpacing: screenWidth * 0.066,
                      //     headingRowHeight: 40,
                      //     columns: const [
                      //       DataColumn(label: Text('Product Name')),
                      //       DataColumn(label: Text('Category')),
                      //       DataColumn(label: Text('Sub Category')),
                      //       DataColumn(label: Text('Price')),
                      //       DataColumn(label: Text('Qty')),
                      //       DataColumn(label: Text('Amount')),
                      //       DataColumn(label: Text('TAX')),
                      //       DataColumn(label: Text('Discount')),
                      //       DataColumn(label: Text('Total Amount')),
                      //     ],
                      //     rows: const [],
                      //   ),
                      // ),
                      // Row(
                      //   children: [
                      //     Padding(
                      //       padding: const EdgeInsets.only(left: 30, top: 25),
                      //       child: SizedBox(
                      //         width: screenWidth * 0.15,
                      //         child: OutlinedButton(
                      //           // onPressed: handleButtonPress,
                      //           //my copy
                      //           onPressed: ()
                      //
                      //           {
                      //             String validateFields() {
                      //               if (ContactPersonController.text.isEmpty || ContactPersonController.text.length <= 2) {
                      //                 return 'Please enter a contact person name';
                      //               }
                      //               if (ContactNumberController.text.isEmpty || ContactNumberController.text.length != 10) {
                      //                 return 'Please enter a valid phone number.';
                      //               }
                      //               if (deliveryaddressController.text.isEmpty) {
                      //                 return 'Please fill delivery address.';
                      //               }
                      //               if(EmailIdController.text.isEmpty || !RegExp(r'^[\w-]+(\.[\w-]+)*@[a-zA-Z0-9-]+\.(com|in|net)$').hasMatch(EmailIdController.text) ){  ScaffoldMessenger.of(context).showSnackBar(    SnackBar(content: Text(        'Enter Valid E-mail Address')),  );}
                      //               if (ShippingAddress.text.isEmpty) {
                      //                 return 'Please fill Shipping address ';
                      //               }
                      //
                      //
                      //               return '';
                      //             }
                      //             String validationMessage = validateFields();
                      //             if (validationMessage == '') {
                      //               Map<String, dynamic> data = {
                      //                 'CusId':userId,
                      //                 'deliveryLocation': EmailIdController.text,
                      //                 'ContactName': ContactPersonController.text,
                      //                 'Address': deliveryaddressController.text,
                      //                 'ContactNumber': ContactNumberController.text,
                      //                 'Comments': ShippingAddress.text,
                      //                 'date': _dateController.text,
                      //               };
                      //               context.go('/Search_products',extra: data);
                      //               //   context.go('/Home/Orders/Create_Order/Add_Product',extra: data);
                      //
                      //             } else {
                      //               ScaffoldMessenger.of(context).showSnackBar(
                      //                 SnackBar(
                      //                   content: Text(validationMessage),
                      //                 ),
                      //               );
                      //             }
                      //           },
                      //
                      //           style: OutlinedButton.styleFrom(
                      //             backgroundColor: Colors.blue[800],
                      //             shape: RoundedRectangleBorder(
                      //               borderRadius: BorderRadius.circular(4),
                      //             ),
                      //             side: BorderSide.none,
                      //           ),
                      //           child: const Center(
                      //             child: Text(
                      //               '+ Add Products',
                      //               style: TextStyle(color: Colors.white),
                      //             ),
                      //           ),
                      //         ),
                      //       ),
                      //     ),
                      //   ],
                      // ),

                      // Container(
                      //   width: maxWidth,
                      //   decoration: const BoxDecoration(
                      //     border: Border(
                      //       top: BorderSide(
                      //           color:
                      //           Color(0xFFB2C2D3),
                      //           width: 1.2),
                      //       bottom: BorderSide(
                      //           color:
                      //           Color(0xFFB2C2D3),
                      //           width: 1.2),
                      //     ),
                      //   ),
                      //   child: Padding(
                      //     padding: const EdgeInsets.only(
                      //         top: 5, bottom: 5),
                      //     child: Table(
                      //       columnWidths: const {
                      //         0: FlexColumnWidth(0.7),
                      //         1: FlexColumnWidth(2.7),
                      //         2: FlexColumnWidth(2),
                      //         3: FlexColumnWidth(1.8),
                      //         4: FlexColumnWidth(1.5),
                      //         5: FlexColumnWidth(1.2),
                      //         6: FlexColumnWidth(1.8),
                      //         7: FlexColumnWidth(1),
                      //         8: FlexColumnWidth(1),
                      //         9: FlexColumnWidth(1.2),
                      //         10: FlexColumnWidth(0.7),
                      //       },
                      //       children:  [
                      //         TableRow(
                      //           children: [
                      //             TableCell(
                      //               child: Padding(
                      //                 padding:
                      //                 const EdgeInsets.only(
                      //                     top: 10,
                      //                     bottom: 10),
                      //                 child: Center(
                      //                   child: Padding(
                      //                     padding:
                      //                     const EdgeInsets.only(
                      //                         left: 12),
                      //                     child: Text(
                      //                       'S.NO',
                      //                       style: TextStyles.subhead,
                      //                     ),
                      //                   ),
                      //                 ),
                      //               ),
                      //             ),
                      //             TableCell(
                      //               child: Padding(
                      //                 padding:
                      //                 const EdgeInsets.only(
                      //                     top: 10,
                      //                     bottom: 10),
                      //                 child: Center(
                      //                   child: Text(
                      //                     'Product Name',
                      //                       style: TextStyles.subhead,
                      //                   ),
                      //                 ),
                      //               ),
                      //             ),
                      //             TableCell(
                      //               child: Padding(
                      //                 padding:
                      //                 const EdgeInsets.only(
                      //                     top: 10,
                      //                     bottom: 10),
                      //                 child: Center(
                      //                   child: Text(
                      //                     'Category',
                      //                       style: TextStyles.subhead,
                      //                   ),
                      //                 ),
                      //               ),
                      //             ),
                      //             TableCell(
                      //               child: Padding(
                      //                 padding:
                      //                 const EdgeInsets.only(
                      //                     top: 10,
                      //                     bottom: 10),
                      //                 child: Center(
                      //                   child: Text(
                      //                     'Unit',
                      //                       style: TextStyles.subhead,
                      //                   ),
                      //                 ),
                      //               ),
                      //             ),
                      //             TableCell(
                      //               child: Padding(
                      //                 padding:
                      //                 const EdgeInsets.only(
                      //                     top: 10,
                      //                     bottom: 10),
                      //                 child: Center(
                      //                   child: Text(
                      //                     'Price',
                      //                       style: TextStyles.subhead,
                      //                   ),
                      //                 ),
                      //               ),
                      //             ),
                      //             TableCell(
                      //               child: Padding(
                      //                 padding:
                      //                 const EdgeInsets.only(
                      //                     top: 10,
                      //                     bottom: 10),
                      //                 child: Center(
                      //                   child: Text(
                      //                     'QTY',
                      //                       style: TextStyles.subhead,
                      //                   ),
                      //                 ),
                      //               ),
                      //             ),
                      //             TableCell(
                      //               child: Padding(
                      //                 padding:
                      //                 const EdgeInsets.only(
                      //                     top: 10,
                      //                     bottom: 10),
                      //                 child: Center(
                      //                   child: Text(
                      //                     'Total Amount',
                      //                       style: TextStyles.subhead,
                      //                   ),
                      //                 ),
                      //               ),
                      //             ),
                      //             const TableCell(
                      //               child: Padding(
                      //                 padding:
                      //                 EdgeInsets.only(
                      //                     top: 10,
                      //                     bottom: 10),
                      //                 child: Center(
                      //                   child: Text(
                      //                     '    ',
                      //                     style: TextStyle(
                      //                         fontWeight:
                      //                         FontWeight
                      //                             .bold),
                      //                   ),
                      //                 ),
                      //               ),
                      //             ),
                      //           ],
                      //         ),
                      //       ],
                      //     ),
                      //   ),
                      // ),
                      // Container(
                      //   width: maxWidth,
                      //   decoration: const BoxDecoration(
                      //     border: Border(
                      //       top: BorderSide(
                      //           color:
                      //           Color(0xFFB2C2D3),
                      //           width: 1.2),
                      //       bottom: BorderSide(
                      //           color:
                      //           Color(0xFFB2C2D3),
                      //           width: 1.2),
                      //     ),
                      //   ),
                      //   child: const Padding(
                      //     padding: EdgeInsets.only(
                      //         top: 20, bottom: 20),
                      //     child: Center(child: Text('No Data found')),
                      //   ),
                      // ),
                      // ListView.builder(
                      //   shrinkWrap: true,
                      //   physics:
                      //   const NeverScrollableScrollPhysics(),
                      //   itemCount:
                      //   widget.selectedProducts.length,
                      //   itemBuilder: (context, index) {
                      //     Product product =
                      //     widget.selectedProducts[index];
                      //     return Table(
                      //       border: TableBorder(
                      //         bottom: BorderSide(
                      //             width: 1,
                      //             color: Colors.grey),
                      //         //   horizontalInside: BorderSide(width: 1,color: Colors.grey), // horizontal border inside the table
                      //         verticalInside: BorderSide(
                      //             width: 1,
                      //             color: Colors.grey),
                      //       ),
                      //       // border: TableBorder.all(color: const Color(0xFFB2C2D3)),
                      //       columnWidths: const {
                      //         0: FlexColumnWidth(0.7),
                      //         1: FlexColumnWidth(2.7),
                      //         2: FlexColumnWidth(2),
                      //         3: FlexColumnWidth(1.8),
                      //         4: FlexColumnWidth(1.5),
                      //         5: FlexColumnWidth(1.2),
                      //         6: FlexColumnWidth(1.8),
                      //         7: FlexColumnWidth(1),
                      //         8: FlexColumnWidth(1),
                      //         9: FlexColumnWidth(1.2),
                      //         10: FlexColumnWidth(0.7),
                      //       },
                      //       children: [
                      //         TableRow(
                      //           children: [
                      //             TableCell(
                      //               child: Padding(
                      //                 padding:
                      //                 const EdgeInsets
                      //                     .only(
                      //                     left: 10,
                      //                     right: 10,
                      //                     top: 15,
                      //                     bottom: 5),
                      //                 child: Center(
                      //                   child: Text(
                      //                     (index + 1)
                      //                         .toString(),
                      //                     textAlign: TextAlign
                      //                         .center,
                      //                   ),
                      //                 ),
                      //               ),
                      //             ),
                      //             TableCell(
                      //               child: Padding(
                      //                 padding:
                      //                 const EdgeInsets
                      //                     .only(
                      //                     left: 10,
                      //                     right: 10,
                      //                     top: 10,
                      //                     bottom: 10),
                      //                 child: Container(
                      //                   height: 35,
                      //                   width: 150,
                      //                   decoration:
                      //                   BoxDecoration(
                      //                     color: Colors
                      //                         .grey.shade200,
                      //                     borderRadius:
                      //                     BorderRadius
                      //                         .circular(
                      //                         4.0),
                      //                   ),
                      //                   child: Center(
                      //                     child: Text(
                      //                       product
                      //                           .productName,
                      //                       textAlign:
                      //                       TextAlign
                      //                           .center,
                      //                     ),
                      //                   ),
                      //                 ),
                      //               ),
                      //             ),
                      //             TableCell(
                      //               child: Padding(
                      //                 padding:
                      //                 const EdgeInsets
                      //                     .only(
                      //                     left: 10,
                      //                     right: 10,
                      //                     top: 10,
                      //                     bottom: 10),
                      //                 child: Container(
                      //                   height: 35,
                      //                   width: 150,
                      //                   decoration:
                      //                   BoxDecoration(
                      //                     color: Colors
                      //                         .grey.shade200,
                      //                     borderRadius:
                      //                     BorderRadius
                      //                         .circular(
                      //                         4.0),
                      //                   ),
                      //                   child: Center(
                      //                     child: Text(
                      //                       product.category,
                      //                       textAlign:
                      //                       TextAlign
                      //                           .center,
                      //                     ),
                      //                   ),
                      //                 ),
                      //               ),
                      //             ),
                      //             TableCell(
                      //               child: Padding(
                      //                 padding:
                      //                 const EdgeInsets
                      //                     .only(
                      //                     left: 10,
                      //                     right: 10,
                      //                     top: 10,
                      //                     bottom: 10),
                      //                 child: Container(
                      //                   height: 35,
                      //                   decoration:
                      //                   BoxDecoration(
                      //                     color: Colors
                      //                         .grey.shade200,
                      //                     borderRadius:
                      //                     BorderRadius
                      //                         .circular(
                      //                         4.0),
                      //                   ),
                      //                   child: Center(
                      //                     child: Text(
                      //                       product
                      //                           .subCategory,
                      //                       textAlign:
                      //                       TextAlign
                      //                           .center,
                      //                     ),
                      //                   ),
                      //                 ),
                      //               ),
                      //             ),
                      //             TableCell(
                      //               child: Padding(
                      //                 padding:
                      //                 const EdgeInsets
                      //                     .only(
                      //                     left: 10,
                      //                     right: 10,
                      //                     top: 10,
                      //                     bottom: 10),
                      //                 child: Container(
                      //                   height: 35,
                      //                   decoration:
                      //                   BoxDecoration(
                      //                     color: Colors
                      //                         .grey.shade200,
                      //                     borderRadius:
                      //                     BorderRadius
                      //                         .circular(
                      //                         4.0),
                      //                   ),
                      //                   child: Center(
                      //                     child: Text(
                      //                       product.price
                      //                           .toString(),
                      //                       textAlign:
                      //                       TextAlign
                      //                           .center,
                      //                     ),
                      //                   ),
                      //                 ),
                      //               ),
                      //             ),
                      //             TableCell(
                      //               child: Padding(
                      //                 padding:
                      //                 const EdgeInsets
                      //                     .only(
                      //                     left: 10,
                      //                     right: 10,
                      //                     top: 10,
                      //                     bottom: 10),
                      //                 child: Container(
                      //                   height: 35,
                      //                   decoration:
                      //                   BoxDecoration(
                      //                     color: Colors
                      //                         .grey.shade200,
                      //                     borderRadius:
                      //                     BorderRadius
                      //                         .circular(
                      //                         4.0),
                      //                   ),
                      //                   child: Center(
                      //                     child: Text(
                      //                       product.quantity
                      //                           .toString(),
                      //                       textAlign:
                      //                       TextAlign
                      //                           .center,
                      //                     ),
                      //                   ),
                      //                 ),
                      //               ),
                      //             ),
                      //             TableCell(
                      //               child: Padding(
                      //                 padding:
                      //                 const EdgeInsets
                      //                     .only(
                      //                     left: 10,
                      //                     right: 10,
                      //                     top: 10,
                      //                     bottom: 10),
                      //                 child: Container(
                      //                   height: 35,
                      //                   decoration:
                      //                   BoxDecoration(
                      //                     color: Colors
                      //                         .grey.shade200,
                      //                     borderRadius:
                      //                     BorderRadius
                      //                         .circular(
                      //                         4.0),
                      //                   ),
                      //                   child: Center(
                      //                     child: Text(
                      //                       '${product.price * product.quantity}',
                      //                       textAlign:
                      //                       TextAlign
                      //                           .center,
                      //                     ),
                      //                   ),
                      //                 ),
                      //               ),
                      //             ),
                      //             TableCell(
                      //               child: Padding(
                      //                 padding:
                      //                 const EdgeInsets
                      //                     .only(
                      //                     left: 10,
                      //                     right: 10,
                      //                     top: 10,
                      //                     bottom: 10),
                      //                 child: Container(
                      //                   height: 35,
                      //                   decoration:
                      //                   BoxDecoration(
                      //                     color: Colors
                      //                         .grey.shade200,
                      //                     borderRadius:
                      //                     BorderRadius
                      //                         .circular(
                      //                         4.0),
                      //                   ),
                      //                   child: Center(
                      //                     child: Text(
                      //                       '${product.discount}',
                      //                       textAlign:
                      //                       TextAlign
                      //                           .center,
                      //                     ),
                      //                   ),
                      //                 ),
                      //               ),
                      //             ),
                      //             TableCell(
                      //               child: Padding(
                      //                 padding:
                      //                 const EdgeInsets
                      //                     .only(
                      //                     left: 10,
                      //                     right: 10,
                      //                     top: 10,
                      //                     bottom: 10),
                      //                 child: Container(
                      //                   height: 35,
                      //                   decoration:
                      //                   BoxDecoration(
                      //                     color: Colors
                      //                         .grey.shade200,
                      //                     borderRadius:
                      //                     BorderRadius
                      //                         .circular(
                      //                         4.0),
                      //                   ),
                      //                   child: Center(
                      //                     child: Text(
                      //                       '${product.tax}',
                      //                       textAlign:
                      //                       TextAlign
                      //                           .center,
                      //                     ),
                      //                   ),
                      //                 ),
                      //               ),
                      //             ),
                      //             TableCell(
                      //               child: Padding(
                      //                 padding:
                      //                 const EdgeInsets
                      //                     .only(
                      //                     left: 10,
                      //                     right: 10,
                      //                     top: 10,
                      //                     bottom: 10),
                      //                 child: Container(
                      //                   height: 35,
                      //                   decoration:
                      //                   BoxDecoration(
                      //                     color: Colors
                      //                         .grey.shade200,
                      //                     borderRadius:
                      //                     BorderRadius
                      //                         .circular(
                      //                         4.0),
                      //                   ),
                      //                   child: Center(
                      //                     child: Text(
                      //                       '${(product.totalAmount * product.quantity).toStringAsFixed(2)}',
                      //                       textAlign:
                      //                       TextAlign
                      //                           .center,
                      //                     ),
                      //                   ),
                      //                 ),
                      //               ),
                      //             ),
                      //             TableCell(
                      //               child: Padding(
                      //                 padding:
                      //                 const EdgeInsets
                      //                     .symmetric(
                      //                     vertical: 20),
                      //                 child: InkWell(
                      //                   onTap: () {
                      //                     _deleteProduct(
                      //                         product);
                      //                   },
                      //                   child: const Icon(
                      //                     Icons
                      //                         .remove_circle_outline,
                      //                     size: 18,
                      //                     color: Colors.blue,
                      //                   ),
                      //                 ),
                      //               ),
                      //             ),
                      //           ],
                      //         ),
                      //       ],
                      //     );
                      //   },
                      // ),
                      Container(
                        width: 1200,
                        child: DataTable(columns: [
                          DataColumn(label: Text('S.NO',style: TextStyles.subhead,)),
                          DataColumn(label: Text('Product Name',style: TextStyles.subhead,)),
                          DataColumn(label: Text('Category',style: TextStyles.subhead,)),
                          DataColumn(label: Text('Unit',style: TextStyles.subhead,)),
                          DataColumn(label: Text('Price',style: TextStyles.subhead,)),
                          DataColumn(label: Text('QTY',style: TextStyles.subhead,)),
                          DataColumn(label: Text('Total Amount',style: TextStyles.subhead,)),
                          DataColumn(label: Text(' ')),
                        ],
                          rows: _selectedProducts.map((product) {
                            int index = _selectedProducts.indexOf(product) + 1;
                            return DataRow(cells: [
                              DataCell(Text('$index')),
                              DataCell(_buildProductSearchField(product)),
                              DataCell(Text(product['categoryName'] ?? '')),
                              DataCell(Text(product['baseUnit'] ?? '')),
                              DataCell(Text(product['price'].toStringAsFixed(2))),
                              DataCell(_buildQuantityField(product)),
                              DataCell(Text((product['qty'] * product['price']).toStringAsFixed(2))),
                              DataCell(IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  setState(() {
                                    _selectedProducts.remove(product);
                                  });
                                },
                              )),
                            ]);
                          }).toList(),
                          // rows: _selectedProducts.map((product) {
                          //         return DataRow(cells: [
                          //           DataCell(Text('${1}')),
                          //         DataCell(_buildProductSearchField(product)),
                          //         DataCell(_buildQuantityField(product)),
                          //           DataCell(_buildProductSearchField(product)),
                          //           DataCell(_buildQuantityField(product)),
                          //           DataCell(_buildProductSearchField(product)),
                          //         DataCell(Text(product['price'].toString())),
                          //         DataCell(Text((product['qty'] * product['price']).toStringAsFixed(2))),
                          //         ]);
                          //         }).toList(),
                        ),
                      )


                    ],
                  ),
                ),
              ),
                    Padding(
                     padding: const EdgeInsets.only(left: 45),
                      child: SizedBox(
                        width: 140,
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _selectedProducts.add({
                                'product': '',
                                'productDescription': '',// Product name, initially empty
                                'categoryName': '',     // Default value for category
                                'baseUnit': '',         // Default value for unit
                                'price': 0.0,           // Default price
                                'qty': 1,               // Default quantity
                              });
                            });
                          },

                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding: null,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5)
                            )
                          ),
                          child:
                          const Text('+ Add Product',style: TextStyle(color: Colors.white),),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 100),
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: Container(

                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(color: Colors.grey),
                        ),
                        width: 200,
                          height: 150,
                          child: const Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(left: 30),
                                child: Text('Sub Total:'),
                              )
                            ],
                          ),
                        ),
                      ),
                    )
            ],),))
        }else...{

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
    return Autocomplete<String>(
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
        final selectedProduct = productList.firstWhere((p) => p['productDescription'] == selection);
        setState(() {
          product['product'] = selectedProduct['product'];
          product['categoryName'] = selectedProduct['categoryName'];
          product['baseUnit'] = selectedProduct['baseUnit'];
          product['price'] = selectedProduct['price'];
          product['productDescription'] = selectedProduct['productDescription'];
        });
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
          child: TextField(
            controller: textEditingController,
            focusNode: focusNode,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Search Product',
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuantityField(Map<String, dynamic> product) {
    return TextField(
      keyboardType: TextInputType.number,
      onChanged: (value) {
        setState(() {
          product['qty'] = int.tryParse(value) ?? 1;
        });
      },
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        hintText: 'Enter Qty',
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
                columns:  columns.map((column) {
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
            padding:
            const EdgeInsets.only(top: 150, left: 130, bottom: 350, right: 150),
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
                columns:
                columns.map((column) {
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
                                  style:  TextStyle(
                                    color: detail.deliveryStatus == "In Progress" ? Colors.orange : detail.deliveryStatus == "Delivered" ? Colors.green : Colors.red,
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
            width:  right-100,
            decoration: const BoxDecoration(
                color: Color(0xFFF7F7F7),
                border: Border.symmetric(
                    horizontal: BorderSide(color: Colors.grey, width: 0.5))),
            child: DataTable(
                showCheckboxColumn: false,
                headingRowHeight: 40,
                columnSpacing: 35,
                columns:  columns.map((column) {
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
                                  style: TextStyles.subhead
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
                rows: []),
          ),
          Padding(
            padding:
            const EdgeInsets.only(top: 150, left: 130, bottom: 350, right: 150),
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
                columns:
                columns.map((column) {
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
                                  style: TextStyles.subhead
                              ),
                              IconButton(
                                icon:
                                _sortOrder[columns.indexOf(column)] == 'asc'
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
          return a.paymentStatus!.toLowerCase().compareTo(b.paymentStatus!.toLowerCase());
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
          return b.paymentStatus!.toLowerCase().compareTo(a.paymentStatus!.toLowerCase());
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





