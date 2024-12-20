import 'package:adaptive_scrollbar/adaptive_scrollbar.dart';
import 'package:btb/sample/size.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../home/home.dart';
import '../../widgets/confirmdialog.dart';
import '../../widgets/custom loading.dart';
import '../../widgets/layout size.dart';
import '../../widgets/pagination.dart';
import '../../widgets/text_style.dart';
import '../../sample/grid view connection.dart';
import '../../sample/notifier.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:html';
import 'dart:ui' as ord;
import 'dart:math' as math;

import 'package:btb/admin/Api%20name.dart';
import 'package:btb/widgets/productclass.dart';

import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:btb/widgets/productclass.dart' as ord;
import 'package:btb/Order%20Module/firstpage.dart' as ors;
import '../../../widgets/no datafound.dart';
import 'dart:math' as math;
import 'package:http/http.dart' as http;
import '../../../Order Module/firstpage.dart';
import '../../../dashboard/dashboard.dart';

void main() => runApp(MaterialApp(
  debugShowCheckedModeBanner: false,
  home: MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (context) => MenuProvider())
    ],
    child: ResponsivecreateOrdersPage(),
  ),
));

class ResponsivecreateOrdersPage extends StatelessWidget {
  const ResponsivecreateOrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFFFFFFFF),
        title: Padding(
          padding: const EdgeInsets.only(left: 15, top: 5),
          child: Image.asset(
            "images/Final-Ikyam-Logo.png",
            height: 35,
          ),
        ),
        //elevation: 2.0,
        // shadowColor: const Color(0xFFFFFFFF),
        actions: [
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: AccountMenu(),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3.0), // Height of the divider
          child: const Divider(
            height: 3.0,
            thickness: 3.0, // Thickness of the shadow
            color: Color(0x29000000), // Shadow color (#00000029)
          ),
        ),
      ),

      key: context.read<MenuProvider>().scaffoldKey,
      drawer: SideMenu(),
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Container(
            //   color: Colors.white, // White background color
            //   height: 60.0, // Total height including bottom shadow
            //   child: Column(
            //     crossAxisAlignment: CrossAxisAlignment.start,
            //     children: [
            //       Row(
            //         mainAxisAlignment: MainAxisAlignment.start,
            //         children: [
            //           Padding(
            //             padding: const EdgeInsets.only(left: 15, top: 10),
            //             child: Image.asset(
            //               "images/Final-Ikyam-Logo.png",
            //               height: 35.0,
            //               // Adjusted to better match proportions
            //             ),
            //           ),
            //           const Spacer(),
            //           Row(
            //             children: [
            //               const SizedBox(width: 10),
            //               Padding(
            //                 padding:
            //                 const EdgeInsets.only(right: 10, top: 10),
            //                 // Adjust padding for better spacing
            //                 child: AccountMenu(),
            //               ),
            //             ],
            //           ),
            //         ],
            //       ),
            //       const SizedBox(
            //         height: 7,
            //       ),
            //       const Divider(
            //         height: 3.0,
            //         thickness: 3.0, // Thickness of the shadow
            //         color: Color(0x29000000), // Shadow color (#00000029)
            //       ),
            //     ],
            //   ),
            // ),
            if (Responsive.isDesktop(context) )
              Expanded(flex: 1, child: SideMenu()),
            Expanded(flex: 5, child: DashboardScreen()),
          ],
        ),
      ),
    );
  }
}

// class Sidebar extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Row(
//         children: [
//           Expanded(
//             child: Container(
//               width: 200,
//               color: Colors.blue,
//               child: ListView(
//                 padding: EdgeInsets.zero,
//                 children: [
//                   DrawerHeader(
//                     decoration: BoxDecoration(
//                       color: Colors.blueAccent,
//                     ),
//                     child: Text(
//                       'Ikyam',
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 24,
//                       ),
//                     ),
//                   ),
//                   ListTile(
//                     leading: Icon(Icons.home, color: Colors.white),
//                     title: Text(
//                       'Home',
//                       style: TextStyle(color: Colors.white),
//                     ),
//                     onTap: () {},
//                   ),
//                   ListTile(
//                     leading: Icon(Icons.shopping_cart, color: Colors.white),
//                     title: Text(
//                       'Order',
//                       style: TextStyle(color: Colors.white),
//                     ),
//                     onTap: () {},
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

class SideMenu extends StatefulWidget {
  const SideMenu({Key? key}) : super(key: key);

  @override
  State<SideMenu> createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu> {
  Map<String, bool> _isHovered = {
    'Home': false,
    'Order': false,
  };

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.of(context).size.height;

    return
      Drawer(
        // width: 200,
        elevation: 0,
        backgroundColor: Colors.white,
        child: ListView(
          padding: const EdgeInsets.only(left: 15, right: 15, top: 30),
          children: [
            // Sidebar Menu Items
            _buildMenuItem(
              context,
              'Home',
              Icons.home,
              Colors.blue[900]!,
              '/Cus_Home',
            ),
            Container(
              height: 42,
              margin: const EdgeInsets.only(bottom: 5, right: 20),
              decoration: const BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8),
                  bottomLeft: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                ),
              ),
              child: _buildMenuItem(
                context,
                'Order',
                Icons.warehouse_outlined,
                Colors.white,
                '/Customer_Order_List',
              ),
            ),

          ],
        ),
      );
  }

  /// Reusable Menu Item Widget
  Widget _buildMenuItem(BuildContext context, String title, IconData icon,
      Color iconColor, String route) {
    iconColor = _isHovered[title] == true ? Colors.blue : Colors.black87;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered[title] = true),
      onExit: (_) => setState(() => _isHovered[title] = false),
      child: GestureDetector(
        onTap: () {
          Scaffold.of(context).closeDrawer();
          context.go(route);
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 5, right: 20),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: _isHovered[title] == true
                ? Colors.blue.withOpacity(0.1)
                : Colors.transparent,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: Colors.black87,
                size: 20,
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


// class SideMenu extends StatelessWidget {
//   const SideMenu({
//     Key? key,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Drawer(
//       child: ListView(
//         children: [
//           // DrawerHeader(
//           //   child: Image.asset("assets/images/logo.png"),
//           // ),
//           DrawerListTile(
//             title: "Dashboard",
//             svgSrc: "assets/icons/menu_dashboard.svg",
//             press: () {},
//           ),
//           DrawerListTile(
//             title: "Transaction",
//             svgSrc: "assets/icons/menu_tran.svg",
//             press: () {},
//           ),
//           DrawerListTile(
//             title: "Task",
//             svgSrc: "assets/icons/menu_task.svg",
//             press: () {},
//           ),
//           DrawerListTile(
//             title: "Documents",
//             svgSrc: "assets/icons/menu_doc.svg",
//             press: () {},
//           ),
//           DrawerListTile(
//             title: "Store",
//             svgSrc: "assets/icons/menu_store.svg",
//             press: () {},
//           ),
//           DrawerListTile(
//             title: "Notification",
//             svgSrc: "assets/icons/menu_notification.svg",
//             press: () {},
//           ),
//           DrawerListTile(
//             title: "Profile",
//             svgSrc: "assets/icons/menu_profile.svg",
//             press: () {},
//           ),
//           DrawerListTile(
//             title: "Settings",
//             svgSrc: "assets/icons/menu_setting.svg",
//             press: () {},
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class DrawerListTile extends StatelessWidget {
//   const DrawerListTile({
//     Key? key,
//     // For selecting those three line once press "Command+D"
//     required this.title,
//     required this.svgSrc,
//     required this.press,
//   }) : super(key: key);
//
//   final String title, svgSrc;
//   final VoidCallback press;
//
//   @override
//   Widget build(BuildContext context) {
//     return ListTile(
//       onTap: press,
//       horizontalTitleGap: 0.0,
//
//       title: Text(
//         title,
//         style: TextStyle(color: Colors.white54),
//       ),
//     );
//   }
// }

class DashboardScreen extends StatefulWidget {
  DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  List<String> _sortOrder = List.generate(5, (index) => 'asc');
  List<String> columns = [
    'Order ID',
    'Customer Name',
    'Order Date',
    'Total',
    'Status',
  ];
  List<detail> filteredData = [];
  bool _isTotalVisible = false;
  Map<Map<String, dynamic>, TextEditingController> _controllers = {};
  bool _hasShownPopup = false;
  List<double> columnWidths = [95, 130, 110, 95, 150, 140];
  List<bool> columnSortState = [true, true, true, true, true, true];
  Timer? _searchDebounceTimer;
  String _searchText = '';
  List<Map<String, dynamic>> productList = [];
  final List<Map<String, dynamic>> _selectedProducts = [];
  bool isOrdersSelected = false;
  bool _loading = false;
  detail? _selectedProduct;
  late TextEditingController _dateController;
  Map<String, dynamic> PaymentMap = {};
  int startIndex = 0;
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

  DateTime? _selectedDate;

  late AnimationController _controller;
  bool _isHovered1 = false;
  late Animation<double> _shakeAnimation;
  String status = '';
  String selectDate = '';

  String token = window.sessionStorage["token"] ?? " ";
  String userId = window.sessionStorage["userId"] ?? " ";
  String? dropdownValue2 = 'Select Year';

  List<Product> filteredProducts = [];
  int currentPage = 1;
  String? dropdownValue1 = 'Status';
  final ScrollController horizontalScroll = ScrollController();

  late Future<List<detail>> futureOrders;
  // List<detail> productList = [];

  final ScrollController _scrollController = ScrollController();
  List<dynamic> detailJson = [];
  String searchQuery = '';
 // List<detail> filteredData = [];
  //late AnimationController _controller;
  //bool _isHovered1 = false;
  //late Animation<double> _shakeAnimation;
  //String status = '';
  //String selectDate = '';

  // String token = window.sessionStorage["token"] ?? " ";
  // String? dropdownValue2 = 'Select Year';

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

  static final TextStyle filter = GoogleFonts.inter(
    fontSize: 13.0, // Font size in px
    fontWeight: FontWeight.w500, // Medium weight
    color: Colors.grey,
    // color: Color.fromRGBO(0, 83, 176, 1), // Default text color
  );


  double _calculateTotal() {
    double total = 0.0;
    for (var product in _selectedProducts) {
      total += (product['qty'] * product['price']);
    }
    return total;
  }

  int itemsPerPage = 10;
  int totalItems = 0;
  int totalPages = 0;
  bool isLoading = false;
  double size = 200;

  void _sortProducts(int columnIndex, String sortDirection) {
    if (sortDirection == 'asc') {
      filteredData.sort((a, b) {
        if (columnIndex == 0) {
          return a.orderId!.toLowerCase().compareTo(b.orderId!.toLowerCase());
        } else if (columnIndex == 1) {
          return a.contactPerson!.compareTo(b.contactPerson!);
        } else if (columnIndex == 2) {
          return a.orderDate.compareTo(b.orderDate);
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
          return b.orderId!.toLowerCase().compareTo(a.orderId!.toLowerCase());
        } else if (columnIndex == 1) {
          return b.contactPerson!.compareTo(a.contactPerson!);
        } else if (columnIndex == 2) {
          return b.orderDate.compareTo(a.orderDate);
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


  // String token = 'eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJUZXN0IEN1c3RvbWVyIiwiUm9sZXMiOlt7ImF1dGhvcml0eSI6IkN1c3RvbWVyIn1dLCJleHAiOjE3MzQ1MTA1MDEsImlhdCI6MTczNDUwMzMwMX0.89Y1_HthjVIJQpKcBIEAke5lIrM1yn0vtrc8xzu_TsK2JbSPPJjkwfTylSFfexUCDszjmKdKXzUE2n1LxrPYNA';


  Future<void> fetchProducts(int page, int itemsPerPage) async {
    if (isLoading) return;
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse(
            '$apicall/productmaster/get_all_s4hana_productmaster?page=$page&limit=$itemsPerPage'),
        headers: {
          "Content-type": "application/json",
          "Authorization": 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData != null) {
          //var results = jsonData['d']['results'];
          print(jsonData);

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

  Future<void> fetchCustomerData(String userId) async {
    if (isLoading) return;
    setState(() {
      isLoading = true;
    });

    try {
      // API call to fetch customer data for a specific userId
      final response = await http.get(
        Uri.parse('$apicall/customer_master/get_all_s4hana_customermaster'),
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
            // Assigning values to controllers
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

            print(businessPartnerController.text);
            print(businessPartnerNameController.text);
            print(customerController.text);
            print(addressIDController.text);
            print(cityNameController.text);
            print(postalCodeController.text);
            print(streetNameController.text);
            print(regionController.text);
            print(telephoneNumber1Controller.text);
            print(countryController.text);
            print(districtNameController.text);
            print(emailAddressController.text);
            print(mobilePhoneNumberController.text);
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


  Future<void> fetchOrders() async {
    try {
      final response = await http.get(
        Uri.parse(
          '$apicall/order_master/get_all_ordermaster',
        ),
        headers: {
          "Content-type": "application/json",
          "Authorization": 'Bearer $token',
        },
      );
      if (token == " ") {
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
                        // Warning Icon
                        const Icon(Icons.warning,
                            color: Colors.orange, size: 50),
                        const SizedBox(height: 16),
                        // Confirmation Message
                        const Text(
                          'Session Expired',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const Text(
                          "Please log in again to continue",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 20),
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
                                side: const BorderSide(color: Colors.blue),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                              ),
                              child: const Text(
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
      } else {
        if (response.statusCode == 200) {
          final jsonData = jsonDecode(response.body);
          if (jsonData == null) {
            return;
          }
          // List<detail> filteredData = [];
          if (jsonData is List) {
            filteredData =
                jsonData.map((item) => ors.detail.fromJson(item)).toList();
          } else if (jsonData is Map && jsonData.containsKey('body')) {
            final body = jsonData['body'];
            if (body != null) {
              filteredData = (body as List)
                  .map((item) => ors.detail.fromJson(item))
                  .toList();
            } else {}
          } else {}

          if (mounted) {
            setState(() {
              filteredData = filteredData; // Update the filteredData list
            });
          }
        } else {
          throw Exception('Failed to load data');
        }
      }
    } catch (e) {
      if (mounted) {
        if (context.findAncestorWidgetOfExactType<Scaffold>() != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        } else {}
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }



  String calculateTotalPrice(Map<String, dynamic> product) {
    // Calculate total price
    double total = product['qty'] * product['price'];
    // Return formatted string
    return total.toStringAsFixed(2);
  }


  Widget _buildQuantityField(
      Map<String, dynamic> product, TextEditingController controller) {
    // Only update the controller text if it doesn't match the current product quantity
    if (controller.text != product['qty'].toString()) {
      controller.text = product['qty'].toString();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 5), // External padding
      child: SizedBox(
        width: 60, // Adjusted width for better spacing in DataTable
        child: TextFormField(
          controller: controller,
          textAlign: TextAlign.start,
          keyboardType: TextInputType.number,
          onChanged: (value) {
            setState(() {
              product['qty'] = double.tryParse(value) ?? 0;
            });
          },
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[100],
            contentPadding: const EdgeInsets.symmetric(
              vertical: 12, // Internal padding for better alignment of text
              horizontal: 10,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide.none, // Optional: Remove border for cleaner look
            ),
            hintStyle: TextStyles.body,
          ),
          style: TextStyles.body, // Ensure consistent text style
        ),
      ),
    );
  }








  Map<String, bool> _isHovered = {
    'Home': false,
    'Orders': false,
  };

  @override
  void initState() {
    super.initState();
    //_getDashboardCounts();
    fetchOrders();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

// Define the shake animation (values will oscillate between -5.0 and 5.0)
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
    // _dateController = TextEditingController();
    // _selectedDate = DateTime.now();
    //String formattedDate = DateFormat('dd/MM/yyyy').format(_selectedDate!);
    // _dateController.text = formattedDate;
    fetchProducts(currentPage, itemsPerPage);
  }





  @override
  void dispose() {
    //_searchDebounceTimer?.cancel();
    _controller.dispose(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size _size = MediaQuery.of(context).size;
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return RawScrollbar(
      controller: _scrollController,
      thumbVisibility: true,
      thickness: 8,
      radius: const Radius.circular(2),
      thumbColor: Colors.grey[400],
      trackColor: Colors.grey[900],
      trackRadius: const Radius.circular(2),
      child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (!Responsive.isDesktop(context)) ...{
                    IconButton(
                        onPressed: () {
                          context.read<MenuProvider>().controlMenu();
                        },
                        icon: Icon(
                          Icons.menu,
                        )),
                  },


                ],
              ),
              if(Responsive.isMobile(context))...{
                Padding(
                  padding: const EdgeInsets.only(left: 15, top: 10),
                  child: Row(
                    children: [
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
                                // Check if any product has an empty or null productDescription

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
                                // If all validations pass, proceed with API calls

                                await fetchCustomerData(userId);

                                await callApi();
                              }
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
                  width: width,
                  color: Colors.grey.shade300,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 50),
                  child: SizedBox(
                    width: width,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                      // mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(
                              right: width * 0.08,
                              top: 30,
                              left: width * 0.016),
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
                    width: 150,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _dateController,
                            style: TextStyle(
                                fontSize: 12),
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
                SizedBox(height: height,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Container(
                      width: width,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                                top: 40, left: 70, right: 50, bottom: 30),
                            child: Container(
                              //width: width,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFFFFF),
                                boxShadow: [
                                  const BoxShadow(
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
                                    padding: EdgeInsets.only(
                                        top: 20, left: 25, bottom: 20),
                                    child: Text(
                                      'Item Table',
                                      style: TextStyles.header3,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                    child: Container(
                                      width: 1270,
                                      color: Colors.grey[100],
                                      child: DataTable(
                                        //  dataRowHeight: 57,
                                        headingRowHeight: 50,
                                        dataRowColor: MaterialStateProperty
                                            .resolveWith<Color>(
                                              (Set<MaterialState> states) {
                                            return Colors
                                                .white; // Set row background to white
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

                                                // Ensure a controller is initialized for the new product's quantity
                                                if (_controllers != null) {
                                                  _controllers[newProduct] =
                                                      TextEditingController(
                                                          text: '0');
                                                }

                                                // Make the total visible
                                                _isTotalVisible = true;
                                              });

                                              // setState(() {
                                              //   _selectedProducts.add({
                                              //     'product': '',
                                              //     'productDescription': '',
                                              //     'categoryName': '',
                                              //     'baseUnit': '',
                                              //     'price': 0.0,
                                              //     'qty': 0,
                                              //   });
                                              //   _controllers?
                                              //   _isTotalVisible = true;
                                              // });
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
                                                  'Total: \₹${_calculateTotal().toStringAsFixed(2)}',
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
                    ),
                  ),)
              }else...{
                if(Responsive.isTablet(context))...{
                  SizedBox(height: height,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Container(
                        width: 1270,
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
                                      icon: const Icon(Icons.arrow_back, size: 20,)),
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
                                            // Check if any product has an empty or null productDescription

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
                                            // If all validations pass, proceed with API calls

                                            await fetchCustomerData(userId);

                                            await callApi();
                                          }
                                        },
                                        // onPressed: () async {
                                        //   if (_selectedProducts.isEmpty) {
                                        //     ScaffoldMessenger.of(context)
                                        //         .showSnackBar(
                                        //       const SnackBar(
                                        //         content: Text(
                                        //             'Please add a product before creating an order'),
                                        //         duration: Duration(
                                        //             seconds:
                                        //                 2), // Optional duration
                                        //       ),
                                        //     );
                                        //   } else {
                                        //     // Validate that all products have a name and quantity entered
                                        //     bool isValid = true;
                                        //     for (var product
                                        //         in _selectedProducts) {
                                        //       // Check if the product name is empty
                                        //       String productName =
                                        //           product['productName'] ?? '';
                                        //       if (productName.isEmpty) {
                                        //         isValid = false;
                                        //         break; // Exit the loop if validation fails
                                        //       }
                                        //
                                        //       // Check if quantity is entered (greater than 0)
                                        //       int quantity =
                                        //           product['qty'] ?? 0;
                                        //       if (quantity <= 0) {
                                        //         isValid = false;
                                        //         break; // Exit the loop if validation fails
                                        //       }
                                        //     }
                                        //
                                        //     if (!isValid) {
                                        //       ScaffoldMessenger.of(context)
                                        //           .showSnackBar(
                                        //         const SnackBar(
                                        //           content: Text(
                                        //               'Please make sure all products have a name and quantity'),
                                        //           duration: Duration(
                                        //               seconds:
                                        //                   2), // Optional duration
                                        //         ),
                                        //       );
                                        //     } else {
                                        //       // Proceed with fetching customer data and calling the API
                                        //       await fetchCustomerData(userId);
                                        //       await callApi();
                                        //     }
                                        //   }
                                        //
                                        //   // if(_selectedProducts.isEmpty){
                                        //   //   ScaffoldMessenger.of(context).showSnackBar(
                                        //   //     const SnackBar(
                                        //   //       content: Text('Please add a product before creating an order'),
                                        //   //       duration: Duration(seconds: 2), // Optional duration
                                        //   //     ),
                                        //   //   );
                                        //   // }else{
                                        //   //   await fetchCustomerData(userId);
                                        //   //   await callApi();
                                        //   // }
                                        // },
                                        style: OutlinedButton.styleFrom(
                                          backgroundColor: Colors.blue[800],
                                          // Button background color
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                                5), // Rounded corners
                                          ),
                                          side: BorderSide.none, // No outline
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
                              width: width,
                              color: Colors.grey.shade300,
                            ),

                            Padding(
                              padding: const EdgeInsets.only(left: 50),
                              child: SizedBox(
                                width: width,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  // mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(
                                          right: width * 0.08,
                                          top: 30,
                                          left: width * 0.016),
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
                                width: width * 0.11,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        controller: _dateController,
                                        style: TextStyle(
                                            fontSize: width * 0.009),
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
                                  boxShadow: [
                                    const BoxShadow(
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
                                      padding: EdgeInsets.only(
                                          top: 20, left: 25, bottom: 20),
                                      child: Text(
                                        'Item Table',
                                        style: TextStyles.header3,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Container(
                                        width: 1270,
                                        color: Colors.grey[100],
                                        child: DataTable(
                                          //  dataRowHeight: 57,
                                          headingRowHeight: 50,
                                          dataRowColor: MaterialStateProperty
                                              .resolveWith<Color>(
                                                (Set<MaterialState> states) {
                                              return Colors
                                                  .white; // Set row background to white
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

                                                  // Ensure a controller is initialized for the new product's quantity
                                                  if (_controllers != null) {
                                                    _controllers[newProduct] =
                                                        TextEditingController(
                                                            text: '0');
                                                  }

                                                  // Make the total visible
                                                  _isTotalVisible = true;
                                                });

                                                // setState(() {
                                                //   _selectedProducts.add({
                                                //     'product': '',
                                                //     'productDescription': '',
                                                //     'categoryName': '',
                                                //     'baseUnit': '',
                                                //     'price': 0.0,
                                                //     'qty': 0,
                                                //   });
                                                //   _controllers?
                                                //   _isTotalVisible = true;
                                                // });
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
                                                    'Total: \₹${_calculateTotal().toStringAsFixed(2)}',
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
                      ),
                    ),)
                },
                if(Responsive.isDesktop(context))...{
                  SingleChildScrollView(
                    scrollDirection: Axis.vertical,
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
                                  icon: const Icon(Icons.arrow_back, size: 20,)),
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
                                        // Check if any product has an empty or null productDescription

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
                                        // If all validations pass, proceed with API calls

                                        await fetchCustomerData(userId);

                                        await callApi();
                                      }
                                    },
                                    // onPressed: () async {
                                    //   if (_selectedProducts.isEmpty) {
                                    //     ScaffoldMessenger.of(context)
                                    //         .showSnackBar(
                                    //       const SnackBar(
                                    //         content: Text(
                                    //             'Please add a product before creating an order'),
                                    //         duration: Duration(
                                    //             seconds:
                                    //                 2), // Optional duration
                                    //       ),
                                    //     );
                                    //   } else {
                                    //     // Validate that all products have a name and quantity entered
                                    //     bool isValid = true;
                                    //     for (var product
                                    //         in _selectedProducts) {
                                    //       // Check if the product name is empty
                                    //       String productName =
                                    //           product['productName'] ?? '';
                                    //       if (productName.isEmpty) {
                                    //         isValid = false;
                                    //         break; // Exit the loop if validation fails
                                    //       }
                                    //
                                    //       // Check if quantity is entered (greater than 0)
                                    //       int quantity =
                                    //           product['qty'] ?? 0;
                                    //       if (quantity <= 0) {
                                    //         isValid = false;
                                    //         break; // Exit the loop if validation fails
                                    //       }
                                    //     }
                                    //
                                    //     if (!isValid) {
                                    //       ScaffoldMessenger.of(context)
                                    //           .showSnackBar(
                                    //         const SnackBar(
                                    //           content: Text(
                                    //               'Please make sure all products have a name and quantity'),
                                    //           duration: Duration(
                                    //               seconds:
                                    //                   2), // Optional duration
                                    //         ),
                                    //       );
                                    //     } else {
                                    //       // Proceed with fetching customer data and calling the API
                                    //       await fetchCustomerData(userId);
                                    //       await callApi();
                                    //     }
                                    //   }
                                    //
                                    //   // if(_selectedProducts.isEmpty){
                                    //   //   ScaffoldMessenger.of(context).showSnackBar(
                                    //   //     const SnackBar(
                                    //   //       content: Text('Please add a product before creating an order'),
                                    //   //       duration: Duration(seconds: 2), // Optional duration
                                    //   //     ),
                                    //   //   );
                                    //   // }else{
                                    //   //   await fetchCustomerData(userId);
                                    //   //   await callApi();
                                    //   // }
                                    // },
                                    style: OutlinedButton.styleFrom(
                                      backgroundColor: Colors.blue[800],
                                      // Button background color
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            5), // Rounded corners
                                      ),
                                      side: BorderSide.none, // No outline
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
                          width: width,
                          color: Colors.grey.shade300,
                        ),

                        Padding(
                          padding: const EdgeInsets.only(left: 50),
                          child: SizedBox(
                            width: width,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              // mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(
                                      right: width * 0.08,
                                      top: 30,
                                      left: width * 0.016),
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
                            width: width * 0.11,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _dateController,
                                    style: TextStyle(
                                        fontSize: width * 0.009),
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
                              boxShadow: [
                                const BoxShadow(
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
                                  padding: EdgeInsets.only(
                                      top: 20, left: 25, bottom: 20),
                                  child: Text(
                                    'Item Table',
                                    style: TextStyles.header3,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Container(
                                  width: width,
                                  color: Colors.grey[100],
                                  child: (width >= 1280 && width <= 1440) ?
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: DataTable(
                                      //  dataRowHeight: 57,
                                      headingRowHeight: 50,
                                      dataRowColor: MaterialStateProperty
                                          .resolveWith<Color>(
                                            (Set<MaterialState> states) {
                                          return Colors
                                              .white; // Set row background to white
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
                                  ) : DataTable(
                                    //  dataRowHeight: 57,
                                    headingRowHeight: 50,
                                    dataRowColor: MaterialStateProperty
                                        .resolveWith<Color>(
                                          (Set<MaterialState> states) {
                                        return Colors
                                            .white; // Set row background to white
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
                                  ) ,
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

                                              // Ensure a controller is initialized for the new product's quantity
                                              if (_controllers != null) {
                                                _controllers[newProduct] =
                                                    TextEditingController(
                                                        text: '0');
                                              }

                                              // Make the total visible
                                              _isTotalVisible = true;
                                            });

                                            // setState(() {
                                            //   _selectedProducts.add({
                                            //     'product': '',
                                            //     'productDescription': '',
                                            //     'categoryName': '',
                                            //     'baseUnit': '',
                                            //     'price': 0.0,
                                            //     'qty': 0,
                                            //   });
                                            //   _controllers?
                                            //   _isTotalVisible = true;
                                            // });
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
                                                'Total: \₹${_calculateTotal().toStringAsFixed(2)}',
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
                  )
                }
    },

//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Padding(
//                     padding:
//                     const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
//                     child: Text(
//                       'Order List',
//                       style: TextStyles.header1,
//                     ),
//                   ),
//                   Padding(
//                     padding:
//                     const EdgeInsets.only(top: 10, right: 50),
//                     child: OutlinedButton(
//                       onPressed: () {
//                         context.go('/Cus_Create_Order',
//                             extra: {'testing': 'hi'});
//                         //context.go('/Home/Orders/Create_Order');
//                       },
//                       style: OutlinedButton.styleFrom(
//                         backgroundColor: Colors.blue[800],
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(
//                               5), // Rounded corners
//                         ),
//                         side: BorderSide.none, // No outline
//                       ),
//                       child: Text('Create',
//                           style: TextStyles.button),
//                     ),
//                   ),
//                 ],
//               ),
//               Row(
//                 children: [
//                   Expanded(
//                       flex: 5,
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Padding(
//                             padding: const EdgeInsets.all(30),
//                             child: Container(
//                               //  padding: const EdgeInsets.all(16.0),
//                               decoration: BoxDecoration(
//                                 //   border: Border.all(color: Colors.grey),
//                                 color: Colors.white,
//                                 borderRadius: BorderRadius.circular(2),
//                                 boxShadow: [
//                                   BoxShadow(
//                                     color: Colors.grey.withOpacity(0.1),
//                                     // Soft grey shadow
//                                     spreadRadius: 3,
//                                     blurRadius: 3,
//                                     offset: const Offset(0, 3),
//                                   ),
//                                 ],
//                               ),
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Container(
//                                     padding: const EdgeInsets.only(
//                                       left: 20,
//                                       right: 20,
//                                       top: 10,
//                                     ),
//                                     child: Column(
//                                       children: [
//                                         Row(
//                                           mainAxisAlignment:
//                                           MainAxisAlignment.spaceBetween,
//                                           children: [
//                                             // Search Field
//                                             Padding(
//                                               padding: const EdgeInsets.all(8.0),
//                                               child: ConstrainedBox(
//                                                 constraints: BoxConstraints(
//                                                   maxWidth: width * 0.261,
//                                                   maxHeight: 39,
//                                                 ),
//                                                 child: Container(
//                                                   // width: constraints.maxWidth * 0.252, // reduced width
//
//                                                   height: 35, // reduced height
//                                                   decoration: BoxDecoration(
//                                                     color: Colors.white,
//                                                     borderRadius: BorderRadius.circular(2),
//                                                     border: Border.all(color: Colors.grey),
//                                                   ),
//                                                   child: TextFormField(
//                                                     style: GoogleFonts.inter(
//                                                         color: Colors.black, fontSize: 13),
//                                                     decoration: InputDecoration(
//                                                         hintText:
//                                                         'Search by Order ID or Customer Name',
//                                                         hintStyle: TextStyles.body,
//                                                         contentPadding: EdgeInsets.symmetric(
//                                                             vertical: 3, horizontal: 5),
//                                                         // contentPadding:
//                                                         // EdgeInsets.only(bottom: 20, left: 10),
//                                                         // adjusted padding
//                                                         border: InputBorder.none,
//                                                         suffixIcon: Padding(
//                                                           padding: const EdgeInsets.only(
//                                                               left: 10, right: 5),
//                                                           // Adjust image padding
//                                                           child: Image.asset(
//                                                             'images/search.png', // Replace with your image asset path
//                                                           ),
//                                                         )),
//                                                     onChanged: _updateSearch,
//                                                   ),
//                                                 ),
//                                               ),
//                                             ),
//                                             //  Spacer(),
//                                             // Padding(
//                                             //   padding: const EdgeInsets.all(16),
//                                             //   child: Column(
//                                             //     crossAxisAlignment: CrossAxisAlignment.start,
//                                             //     children: [
//                                             //       //  const SizedBox(height: 8),
//                                             //       Padding(
//                                             //         padding: const EdgeInsets.only(left: 30,top: 20),
//                                             //         child: Container(
//                                             //           width: width * 0.1, // reduced width
//                                             //           height: 40, // reduced height
//                                             //           decoration: BoxDecoration(
//                                             //             color: Colors.white,
//                                             //             borderRadius: BorderRadius.circular(2),
//                                             //             border: Border.all(color: Colors.grey),
//                                             //           ),
//                                             //           child: DropdownButtonFormField2<String>(
//                                             //             decoration: const InputDecoration(
//                                             //               contentPadding: EdgeInsets.only(
//                                             //                   bottom: 15, left: 9), // Custom padding
//                                             //               border: InputBorder.none, // No default border
//                                             //               filled: true,
//                                             //               fillColor: Colors.white, // Background color
//                                             //             ),
//                                             //             isExpanded: true,
//                                             //             // Ensures dropdown takes full width
//                                             //             value: dropdownValue1,
//                                             //             onChanged: (String? newValue) {
//                                             //               setState(() {
//                                             //                 dropdownValue1 = newValue;
//                                             //                 status = newValue ?? '';
//                                             //                 _filterAndPaginateProducts();
//                                             //               });
//                                             //             },
//                                             //             items: <String>[
//                                             //               'Delivery Status',
//                                             //               'Not Started',
//                                             //               'In Progress',
//                                             //               'Delivered',
//                                             //             ].map<DropdownMenuItem<String>>((String value) {
//                                             //               return DropdownMenuItem<String>(
//                                             //                 value: value,
//                                             //                 child: Text(
//                                             //                   value,
//                                             //                   style: TextStyle(
//                                             //                     fontSize: 13,
//                                             //                     color: value == 'Delivery Status'
//                                             //                         ? Colors.grey
//                                             //                         : Colors.black,
//                                             //                   ),
//                                             //                 ),
//                                             //               );
//                                             //             }).toList(),
//                                             //             iconStyleData: const IconStyleData(
//                                             //               icon: Icon(
//                                             //                 Icons.keyboard_arrow_down,
//                                             //                 color: Colors.indigo,
//                                             //                 size: 16,
//                                             //               ),
//                                             //               iconSize: 16,
//                                             //             ),
//                                             //             buttonStyleData: const ButtonStyleData(
//                                             //               height: 50, // Button height
//                                             //               padding: EdgeInsets.only(
//                                             //                   left: 10, right: 10), // Button padding
//                                             //             ),
//                                             //             dropdownStyleData: DropdownStyleData(
//                                             //               decoration: BoxDecoration(
//                                             //                 borderRadius: BorderRadius.circular(7),
//                                             //                 // Rounded corners
//                                             //                 color: Colors.white, // Dropdown background color
//                                             //               ),
//                                             //               maxHeight: 200, // Max height for dropdown items
//                                             //               width: width * 0.1, // Dropdown width
//                                             //               offset: const Offset(0, -20),
//                                             //             ),
//                                             //           ),
//                                             //         ),
//                                             //       ),
//                                             //     ],
//                                             //   ),
//                                             // ),
//                                           ],
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//
//                                   const SizedBox(height: 8.0),
//                                   // DataTable with ConstrainedBox to avoid overflow
//                                   if (Responsive.isMobile(context)) ...{
//                                     if (filteredData.isEmpty) ...{
//                                       Column(
//                                         mainAxisAlignment: MainAxisAlignment.start,
//                                         children: [
//                                           Container(
//                                             // height: 600,
//                                             width: width,
//                                             decoration: BoxDecoration(
//                                                 color: Color(0xFFF7F7F7),
//                                                 border: Border.symmetric(
//                                                     horizontal: BorderSide(
//                                                         color: Colors.grey,
//                                                         width: 0.5))),
//                                             child: DataTable(
//                                                 showCheckboxColumn: false,
//                                                 headingRowHeight: 40,
//                                                 columnSpacing: 50,
//                                                 headingRowColor:
//                                                 MaterialStateProperty.all(
//                                                     Colors.grey.shade300),
//                                                 columns: columns.map((column) {
//                                                   return DataColumn(
//                                                     label: Stack(
//                                                       children: [
//                                                         Container(
//                                                           padding: null,
//                                                           width: columnWidths[columns.indexOf(column)],
//                                                           // Dynamic width based on user interaction
//                                                           child: Row(
// //crossAxisAlignment: CrossAxisAlignment.end,
// //   mainAxisAlignment: MainAxisAlignment.end,
//                                                             children: [
//                                                               Text(column, style: TextStyles.subhead),
//                                                             ],
//                                                           ),
//                                                         ),
//                                                       ],
//                                                     ),
//                                                     onSort: (columnIndex, ascending) {
//                                                       _sortOrder;
//                                                     },
//                                                   );
//                                                 }).toList(),
//                                                 rows: const []),
//                                           ),
//                                           Padding(
//                                             padding: const EdgeInsets.only(
//                                                 top: 5, left: 130, right: 150),
//                                             child: CustomDatafound(),
//                                           ),
//                                         ],
//                                       ),
//                                     }else...{
//                                       SizedBox(
//                                         height: height,
//                                         width: width,
//                                         child: SingleChildScrollView(
//                                           scrollDirection: Axis.vertical,
//                                           child:  width <= 850
//                                               ? SingleChildScrollView(
//                                             scrollDirection: Axis.horizontal, // Horizontal scroll when width <= 850
//                                             child: DataTable(
//                                                 showCheckboxColumn: false,
//                                                 headingRowHeight: 40,
//                                                 columnSpacing: 35,
//                                                 headingRowColor:
//                                                 MaterialStateProperty.all(
//                                                     Color(0xFFF7F7F7)),
//                                                 // List.generate(5, (index)
//                                                 columns: columns.map((column) {
//                                                   return DataColumn(
//                                                     label: Stack(
//                                                       children: [
//                                                         Container(
//                                                           padding: null,
//                                                           width: columnWidths[columns.indexOf(column)],
//                                                           // Dynamic width based on user interaction
//                                                           child: Row(
//                                                             children: [
//                                                               Text(column, style: TextStyles.subhead),
//                                                               IconButton(
//                                                                 icon:
//                                                                 _sortOrder[columns.indexOf(column)] == 'asc'
//                                                                     ? SizedBox(
//                                                                     width: 12,
//                                                                     child: Image.asset(
//                                                                       "images/ix_sort.png",
//                                                                       color: Colors.blue,
//                                                                     ))
//                                                                     : SizedBox(
//                                                                     width: 12,
//                                                                     child: Image.asset(
//                                                                       "images/ix_sort.png",
//                                                                       color: Colors.blue,
//                                                                     )),
//                                                                 onPressed: () {
//                                                                   setState(() {
//                                                                     _sortOrder[columns.indexOf(column)] =
//                                                                     _sortOrder[columns.indexOf(column)] ==
//                                                                         'asc'
//                                                                         ? 'desc'
//                                                                         : 'asc';
//                                                                     _sortProducts(columns.indexOf(column),
//                                                                         _sortOrder[columns.indexOf(column)]);
//                                                                   });
//                                                                 },
//                                                               ),
//                                                               //SizedBox(width: 50,),
//                                                               //Padding(
//                                                               //  padding:  EdgeInsets.only(left: columnWidths[index]-50,),
//                                                               //  child:
//                                                               // ),
//                                                             ],
//                                                           ),
//                                                         ),
//                                                       ],
//                                                     ),
//                                                     onSort: (columnIndex, ascending) {
//                                                       _sortOrder;
//                                                     },
//                                                   );
//                                                 }).toList(),
//                                                 rows: List.generate(
//                                                     math.min(itemsPerPage,
//                                                         filteredData.length - (currentPage - 1) * itemsPerPage),
//                                                         (index) {
//                                                       final detail =
//                                                       filteredData[(currentPage - 1) * itemsPerPage + index];
//                                                       final isSelected = _selectedProduct == detail;
//                                                       return DataRow(
//                                                           color: MaterialStateProperty.resolveWith<Color>((states) {
//                                                             if (states.contains(MaterialState.hovered)) {
//                                                               return Colors.blue.shade500.withOpacity(
//                                                                   0.8); // Add some opacity to the dark blue
//                                                             } else {
//                                                               return Colors.white.withOpacity(0.9);
//                                                             }
//                                                           }),
//                                                           cells: [
//                                                             DataCell(
//                                                               Container(
//                                                                 width: columnWidths[0],
//                                                                 // Same dynamic width as column headers
//                                                                 child: Text(
//                                                                   detail.orderId.toString(),
//                                                                   style: TextStyles.body,
//                                                                 ),
//                                                               ),
//                                                             ),
//                                                             DataCell(
//                                                               Container(
//                                                                 width: columnWidths[1],
//                                                                 child: Text(
//                                                                   detail.contactPerson!,
//                                                                   style: TextStyles.body,
//                                                                 ),
//                                                               ),
//                                                             ),
//                                                             DataCell(
//                                                               Container(
//                                                                 width: columnWidths[2],
//                                                                 child: Text(
//                                                                   detail.orderDate!,
//                                                                   style: TextStyles.body,
//                                                                 ),
//                                                               ),
//                                                             ),
//                                                             DataCell(
//                                                               Container(
//                                                                 width: columnWidths[3],
//                                                                 child: Text(
//                                                                   detail.total.toString(),
//                                                                   style: TextStyles.body,
//                                                                 ),
//                                                               ),
//                                                             ),
//                                                             DataCell(
//                                                               Container(
//                                                                 width: columnWidths[4],
//                                                                 child: Text(
//                                                                   detail.deliveryStatus.toString(),
//                                                                   style: TextStyles.body,
//                                                                 ),
//                                                               ),
//                                                             ),
//                                                             // DataCell(
//                                                             //   Container(
//                                                             //     width: columnWidths[4],
//                                                             //     child: Text(
//                                                             //       detail.paymentStatus.toString(),
//                                                             //       style: TextStyles.body,
//                                                             //     ),
//                                                             //   ),
//                                                             // ),
//                                                           ],
//                                                           onSelectChanged: (selected) {
//                                                             context.go('/Customer_Order_View', extra: {
//                                                               'orderId': detail.orderId,
//                                                             });
//                                                           });
//                                                     })),) : DataTable(
//                                               showCheckboxColumn: false,
//                                               headingRowHeight: 40,
//                                               columnSpacing: 35,
//                                               headingRowColor:
//                                               MaterialStateProperty.all(
//                                                   Color(0xFFF7F7F7)),
//                                               // List.generate(5, (index)
//                                               columns: columns.map((column) {
//                                                 return DataColumn(
//                                                   label: Stack(
//                                                     children: [
//                                                       Container(
//                                                         padding: null,
//                                                         width: columnWidths[columns.indexOf(column)],
//                                                         // Dynamic width based on user interaction
//                                                         child: Row(
//                                                           children: [
//                                                             Text(column, style: TextStyles.subhead),
//                                                             IconButton(
//                                                               icon:
//                                                               _sortOrder[columns.indexOf(column)] == 'asc'
//                                                                   ? SizedBox(
//                                                                   width: 12,
//                                                                   child: Image.asset(
//                                                                     "images/ix_sort.png",
//                                                                     color: Colors.blue,
//                                                                   ))
//                                                                   : SizedBox(
//                                                                   width: 12,
//                                                                   child: Image.asset(
//                                                                     "images/ix_sort.png",
//                                                                     color: Colors.blue,
//                                                                   )),
//                                                               onPressed: () {
//                                                                 setState(() {
//                                                                   _sortOrder[columns.indexOf(column)] =
//                                                                   _sortOrder[columns.indexOf(column)] ==
//                                                                       'asc'
//                                                                       ? 'desc'
//                                                                       : 'asc';
//                                                                   _sortProducts(columns.indexOf(column),
//                                                                       _sortOrder[columns.indexOf(column)]);
//                                                                 });
//                                                               },
//                                                             ),
//                                                             //SizedBox(width: 50,),
//                                                             //Padding(
//                                                             //  padding:  EdgeInsets.only(left: columnWidths[index]-50,),
//                                                             //  child:
//                                                             // ),
//                                                           ],
//                                                         ),
//                                                       ),
//                                                     ],
//                                                   ),
//                                                   onSort: (columnIndex, ascending) {
//                                                     _sortOrder;
//                                                   },
//                                                 );
//                                               }).toList(),
//                                               rows: List.generate(
//                                                   math.min(itemsPerPage,
//                                                       filteredData.length - (currentPage - 1) * itemsPerPage),
//                                                       (index) {
//                                                     final detail =
//                                                     filteredData[(currentPage - 1) * itemsPerPage + index];
//                                                     final isSelected = _selectedProduct == detail;
//                                                     return DataRow(
//                                                         color: MaterialStateProperty.resolveWith<Color>((states) {
//                                                           if (states.contains(MaterialState.hovered)) {
//                                                             return Colors.blue.shade500.withOpacity(
//                                                                 0.8); // Add some opacity to the dark blue
//                                                           } else {
//                                                             return Colors.white.withOpacity(0.9);
//                                                           }
//                                                         }),
//                                                         cells: [
//                                                           DataCell(
//                                                             Container(
//                                                               width: columnWidths[0],
//                                                               // Same dynamic width as column headers
//                                                               child: Text(
//                                                                 detail.orderId.toString(),
//                                                                 style: TextStyles.body,
//                                                               ),
//                                                             ),
//                                                           ),
//                                                           DataCell(
//                                                             Container(
//                                                               width: columnWidths[1],
//                                                               child: Text(
//                                                                 detail.contactPerson!,
//                                                                 style: TextStyles.body,
//                                                               ),
//                                                             ),
//                                                           ),
//                                                           DataCell(
//                                                             Container(
//                                                               width: columnWidths[2],
//                                                               child: Text(
//                                                                 detail.orderDate!,
//                                                                 style: TextStyles.body,
//                                                               ),
//                                                             ),
//                                                           ),
//                                                           DataCell(
//                                                             Container(
//                                                               width: columnWidths[3],
//                                                               child: Text(
//                                                                 detail.total.toString(),
//                                                                 style: TextStyles.body,
//                                                               ),
//                                                             ),
//                                                           ),
//                                                           DataCell(
//                                                             Container(
//                                                               width: columnWidths[4],
//                                                               child: Text(
//                                                                 detail.deliveryStatus.toString(),
//                                                                 style: TextStyles.body,
//                                                               ),
//                                                             ),
//                                                           ),
//                                                           // DataCell(
//                                                           //   Container(
//                                                           //     width: columnWidths[4],
//                                                           //     child: Text(
//                                                           //       detail.paymentStatus.toString(),
//                                                           //       style: TextStyles.body,
//                                                           //     ),
//                                                           //   ),
//                                                           // ),
//                                                         ],
//                                                         onSelectChanged: (selected) {
//                                                           context.go('/Customer_Order_View', extra: {
//                                                             'orderId': detail.orderId,
//                                                           });
//                                                         });
//                                                   })),
//                                         ),
//                                       ),
//                                     }
//                                   } else ...{
//                                     if(filteredData.isEmpty)...{
//                                       Column(
//                                         mainAxisAlignment: MainAxisAlignment.start,
//                                         children: [
//                                           Container(
//                                             // height: 600,
//                                             width: width,
//                                             decoration: BoxDecoration(
//                                                 color: Color(0xFFF7F7F7),
//                                                 border: Border.symmetric(
//                                                     horizontal: BorderSide(
//                                                         color: Colors.grey,
//                                                         width: 0.5))),
//                                             child: DataTable(
//                                                 headingRowColor:
//                                                 MaterialStateProperty.all(
//                                                     Color(0xFFF7F7F7)),
//                                                 showCheckboxColumn: false,
//                                                 headingRowHeight: 40,
//                                                 columnSpacing: 50,
//                                                 columns: columns.map((column) {
//                                                   return DataColumn(
//                                                     label: Stack(
//                                                       children: [
//                                                         Container(
//                                                           padding: null,
//                                                           width: columnWidths[columns.indexOf(column)],
//                                                           // Dynamic width based on user interaction
//                                                           child: Row(
// //crossAxisAlignment: CrossAxisAlignment.end,
// //   mainAxisAlignment: MainAxisAlignment.end,
//                                                             children: [
//                                                               Text(column, style: TextStyles.subhead),
//                                                             ],
//                                                           ),
//                                                         ),
//                                                       ],
//                                                     ),
//                                                     onSort: (columnIndex, ascending) {
//                                                       _sortOrder;
//                                                     },
//                                                   );
//                                                 }).toList(),
//                                                 rows: const []),
//                                           ),
//                                           Padding(
//                                             padding: const EdgeInsets.only(
//                                                 top: 5, left: 130, right: 150),
//                                             child: CustomDatafound(),
//                                           ),
//                                         ],
//                                       ),
//                                     }else...{
//                                       Column(children: [
//                                         SizedBox(
//                                           height: 500,
//                                           width: width,
//                                           child: SingleChildScrollView(
//                                             scrollDirection: Axis.vertical,
//                                             child: DataTable(
//                                                 headingRowColor:
//                                                 MaterialStateProperty.all(
//                                                     Color(0xFFF7F7F7)),
//                                                 showCheckboxColumn: false,
//                                                 headingRowHeight: 40,
//                                                 columnSpacing: 35,
// // List.generate(5, (index)
//                                                 columns: columns.map((column) {
//                                                   return DataColumn(
//                                                     label: Stack(
//                                                       children: [
//                                                         Container(
//                                                           padding: null,
//                                                           width: columnWidths[columns.indexOf(column)],
//                                                           // Dynamic width based on user interaction
//                                                           child: Row(
//                                                             children: [
//                                                               Text(column, style: TextStyles.subhead),
//                                                               IconButton(
//                                                                 icon:
//                                                                 _sortOrder[columns.indexOf(column)] == 'asc'
//                                                                     ? SizedBox(
//                                                                     width: 12,
//                                                                     child: Image.asset(
//                                                                       "images/ix_sort.png",
//                                                                       color: Colors.blue,
//                                                                     ))
//                                                                     : SizedBox(
//                                                                     width: 12,
//                                                                     child: Image.asset(
//                                                                       "images/ix_sort.png",
//                                                                       color: Colors.blue,
//                                                                     )),
//                                                                 onPressed: () {
//                                                                   setState(() {
//                                                                     _sortOrder[columns.indexOf(column)] =
//                                                                     _sortOrder[columns.indexOf(column)] ==
//                                                                         'asc'
//                                                                         ? 'desc'
//                                                                         : 'asc';
//                                                                     _sortProducts(columns.indexOf(column),
//                                                                         _sortOrder[columns.indexOf(column)]);
//                                                                   });
//                                                                 },
//                                                               ),
// //SizedBox(width: 50,),
// //Padding(
// //  padding:  EdgeInsets.only(left: columnWidths[index]-50,),
// //  child:
// // ),
//                                                             ],
//                                                           ),
//                                                         ),
//                                                       ],
//                                                     ),
//                                                     onSort: (columnIndex, ascending) {
//                                                       _sortOrder;
//                                                     },
//                                                   );
//                                                 }).toList(),
//                                                 rows: List.generate(
//                                                     math.min(itemsPerPage,
//                                                         filteredData.length - (currentPage - 1) * itemsPerPage),
//                                                         (index) {
//                                                       final detail =
//                                                       filteredData[(currentPage - 1) * itemsPerPage + index];
//                                                       final isSelected = _selectedProduct == detail;
//                                                       return DataRow(
//                                                           color: MaterialStateProperty.resolveWith<Color>((states) {
//                                                             if (states.contains(MaterialState.hovered)) {
//                                                               return Colors.blue.shade500.withOpacity(
//                                                                   0.8); // Add some opacity to the dark blue
//                                                             } else {
//                                                               return Colors.white.withOpacity(0.9);
//                                                             }
//                                                           }),
//                                                           cells: [
//                                                             DataCell(
//                                                               Container(
//                                                                 width: columnWidths[0],
//                                                                 // Same dynamic width as column headers
//                                                                 child: Text(
//                                                                   detail.orderId.toString(),
//                                                                   style: TextStyles.body,
//                                                                 ),
//                                                               ),
//                                                             ),
//                                                             DataCell(
//                                                               Container(
//                                                                 width: columnWidths[1],
//                                                                 child: Text(
//                                                                   detail.contactPerson!,
//                                                                   style: TextStyles.body,
//                                                                 ),
//                                                               ),
//                                                             ),
//                                                             DataCell(
//                                                               Container(
//                                                                 width: columnWidths[2],
//                                                                 child: Text(
//                                                                   detail.orderDate!,
//                                                                   style: TextStyles.body,
//                                                                 ),
//                                                               ),
//                                                             ),
//                                                             DataCell(
//                                                               Container(
//                                                                 width: columnWidths[3],
//                                                                 child: Text(
//                                                                   detail.total.toString(),
//                                                                   style: TextStyles.body,
//                                                                 ),
//                                                               ),
//                                                             ),
//                                                             DataCell(
//                                                               Container(
//                                                                 width: columnWidths[4],
//                                                                 child: Text(
//                                                                   detail.deliveryStatus.toString(),
//                                                                   style: TextStyles.body,
//                                                                 ),
//                                                               ),
//                                                             ),
//                                                             // DataCell(
//                                                             //   Container(
//                                                             //     width: columnWidths[4],
//                                                             //     child: Text(
//                                                             //       detail.paymentStatus.toString(),
//                                                             //       style: TextStyles.body,
//                                                             //     ),
//                                                             //   ),
//                                                             // ),
//                                                           ],
//                                                           onSelectChanged: (selected) {
//                                                             context.go('/Customer_Order_View', extra: {
//                                                               'orderId': detail.orderId,
//                                                             });
//                                                           });
//                                                     })),
//                                           ),
//                                         ),
//                                         Padding(
//                                           padding: const EdgeInsets.symmetric(
//                                               horizontal: 30),
//                                           child: Row(
//                                             mainAxisAlignment: MainAxisAlignment.end,
//                                             children: [
//                                               PaginationControls(
//                                                 currentPage: currentPage,
//                                                 totalPages: filteredProducts.length >
//                                                     itemsPerPage
//                                                     ? totalPages
//                                                     : 1,
//                                                 onPreviousPage: _goToPreviousPage,
//                                                 onNextPage: _goToNextPage,
//                                                 // onLastPage: _goToLastPage,
//                                               ),
//                                             ],
//                                           ),
//                                         ),
//                                       ])
//                                     }
//                                   }
//                                 ],
//                               ),
//                             ),
//                           ),
//                           //buildDataTable2(),
//                           // Padding(
//                           //   padding: const EdgeInsets.all(15.0),
//                           //   child: Container(
//                           //     padding: EdgeInsets.all(20),
//                           //     decoration: BoxDecoration(
//                           //       color: Colors.orange,
//                           //       border: Border.all(color: Colors.grey),
//                           //       borderRadius: BorderRadius.circular(12),
//                           //     ),
//                           //     height: 500,
//                           //     child: Column(
//                           //       children: [
//                           //         SizedBox(
//                           //           width: double.infinity,
//                           //           child: DataTable(
//                           //             // horizontalMargin: 5,
//                           //             headingRowColor:
//                           //             MaterialStateProperty.all(Colors.grey[300]),
//                           //             columns: const [
//                           //               DataColumn(
//                           //                   label: Text('ID',
//                           //                       style: TextStyle(
//                           //                           fontWeight: FontWeight
//                           //                               .bold))),
//                           //               DataColumn(
//                           //                   label: Text('Name',
//                           //                       style: TextStyle(
//                           //                           fontWeight: FontWeight
//                           //                               .bold))),
//                           //               DataColumn(
//                           //                   label: Text('Age',
//                           //                       style: TextStyle(
//                           //                           fontWeight: FontWeight
//                           //                               .bold))),
//                           //               DataColumn(
//                           //                   label: Text('Country',
//                           //                       style: TextStyle(
//                           //                           fontWeight: FontWeight
//                           //                               .bold))),
//                           //               DataColumn(
//                           //                   label: Text('Department',
//                           //                       style: TextStyle(
//                           //                           fontWeight: FontWeight
//                           //                               .bold))),
//                           //               DataColumn(
//                           //                   label: Text('Salary',
//                           //                       style: TextStyle(
//                           //                           fontWeight: FontWeight
//                           //                               .bold))),
//                           //               DataColumn(
//                           //                   label: Text('Status',
//                           //                       style: TextStyle(
//                           //                           fontWeight: FontWeight
//                           //                               .bold))),
//                           //             ],
//                           //             rows: dummyData.map((data) {
//                           //               return DataRow(
//                           //                 cells: [
//                           //                   DataCell(Text(data['ID'].toString())),
//                           //                   DataCell(Text(data['Name'])),
//                           //                   DataCell(
//                           //                       Text(data['Age'].toString())),
//                           //                   DataCell(Text(data['Country'])),
//                           //                   DataCell(Text(data['Department'])),
//                           //                   DataCell(Text(data['Salary'])),
//                           //                   DataCell(Text(data['Status'])),
//                           //                 ],
//                           //               );
//                           //             }).toList(),
//                           //           ),
//                           //         )
//                           //         // Text('Recent Files',style: TextStyle(color: Colors.grey),)
//                           //       ],
//                           //     ),
//                           //   ),
//                           // ),
//                         ],
//                       ))
//                 ],
//               ),
            ],
          )),
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
}
