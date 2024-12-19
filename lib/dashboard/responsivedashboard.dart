import 'package:btb/sample/size.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

// import '../../Order Module/firstpage.dart';
// import 'home.dart';
// import '../../widgets/confirmdialog.dart';
// import '../../widgets/custom loading.dart';
// import '../../widgets/layout size.dart';
// import '../../widgets/pagination.dart';
// import '../../widgets/text_style.dart';
// import '../../sample/grid view connection.dart';
// import '../../sample/notifier.dart';
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
import 'package:responsive_framework/responsive_framework.dart';

import '../../../widgets/confirmdialog.dart';
import '../../../widgets/no datafound.dart';
import '../../../widgets/text_style.dart';
import '../../dashboard/dashboard.dart';
import '../../sample/notifier.dart';
import '../../widgets/pagination.dart';

//
void main() => runApp(MaterialApp(
  debugShowCheckedModeBanner: false,
  home: MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (context) => MenuProvider())
    ],
    child: const ResponsiveEmpdashboard(),
  ),
));

class ResponsiveEmpdashboard extends StatelessWidget {
  const ResponsiveEmpdashboard({super.key});

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
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(3.0), // Height of the divider
          child: Divider(
            height: 3.0,
            thickness: 3.0, // Thickness of the shadow
            color: Color(0x29000000), // Shadow color (#00000029)
          ),
        ),
      ),
      key: context.read<MenuProvider>().scaffoldKey,
      drawer: const SideMenu(),
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

            if (Responsive.isDesktop(context))
              const Expanded(flex: 1, child: SideMenu()),
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
    'Customer': false,
    'Products': false,
    'Orders': false,
    'Invoice': false,
    'Delivery': false,
    'Payment': false,
    'Return': false,
    'Reports': false,
  };

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.of(context).size.height;
    return Drawer(
      // width: 200,
      elevation: 0,
      backgroundColor: Colors.white,
      child: ListView(
        padding: const EdgeInsets.only(left: 15, right: 15, top: 30),
        children: [
          // Sidebar Menu Items
          Container(
            margin: const EdgeInsets.only(bottom: 5, right: 20),
            height: 42,
            decoration: const BoxDecoration(
              color: Colors.blue, // Adjusted color
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8),
                bottomLeft: Radius.circular(8),
                bottomRight: Radius.circular(8),
              ),
            ),
            child: _buildMenuItem(
              context,
              'Home',
              Icons.home,
              Colors.white,
              '/Cus_Home',
            ),
          ),
          _buildMenuItem(
            context,
            'Product',
            Icons.production_quantity_limits,
            Colors.blue[900]!,
            '/Product_List',
          ),
          _buildMenuItem(
            context,
            'Customer',
            Icons.account_circle_outlined,
            Colors.blue[900]!,
            '/Customer',
          ),

          _buildMenuItem(
            context,
            'Order',
            Icons.warehouse_outlined,
            Colors.blue[900]!,
            '/Order_List',
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
  void _sortProducts(int columnIndex, String sortDirection) {
    if (sortDirection == 'asc') {
      filteredData1.sort((a, b) {
        if (columnIndex == 0) {
          return a.orderId!.compareTo(b.orderId!);
        } else if (columnIndex == 1) {
          return a.contactPerson!.compareTo(b.contactPerson!);
        } else if (columnIndex == 2) {
          return a.createdDate!.compareTo(b.createdDate!);
        } else if (columnIndex == 3) {
          return a.total.compareTo(b.total);
        } else if (columnIndex == 4) {
          return a.deliveryStatus.compareTo(b.deliveryStatus);
        } else {
          return 0;
        }
      });
    } else {
      filteredData1.sort((a, b) {
        if (columnIndex == 0) {
          return b.orderId!.compareTo(a.orderId!); // Reverse the comparison
        } else if (columnIndex == 1) {
          return b.contactPerson!
              .compareTo(a.contactPerson!); // Reverse the comparison
        } else if (columnIndex == 2) {
          return b.createdDate!
              .compareTo(a.createdDate!); // Reverse the comparison
        } else if (columnIndex == 3) {
          return b.total.compareTo(a.total); // Reverse the comparison
        } else if (columnIndex == 4) {
          return b.deliveryStatus
              .compareTo(a.deliveryStatus); // Reverse the comparison
        } else {
          return 0;
        }
      });
    }
    setState(() {});
  }

  bool isHomeSelected = false;
  final ScrollController horizontalScroll = ScrollController();
  final ScrollController _scrollController = ScrollController();
  final ScrollController verticalscroll = ScrollController();
  final ScrollController verticalscroll1 = ScrollController();
  final ScrollController verticalscroll2 = ScrollController();

  String _searchText = '';

  // DashboardCounts? _dashboardCounts;
  DateTime? _selectedDate;
  late TextEditingController _dateController;
  int startIndex = 0;
  late Future<List<Dashboard1>> futureOrders;
  bool _hasShownPopup = false;
  List<Product> filteredProducts = [];
  String status = '';
  String selectDate = '';
  String deliverystatus = '';
  late AnimationController _controller;
  late Animation<double> _shakeAnimation;
  bool _isHovered1 = false;
  bool _isHovered2 = false;
  bool isLoading = false;
  bool _isHovered5 = false;
  bool orderhover = false;
  bool orderhover2 = false;
  Map<String, dynamic> PaymentMap = {};
  String? dropdownValue1 = 'Delivery Status';
  String searchQuery = '';

  // String token = 'eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJUZXN0IEN1c3RvbWVyIiwiUm9sZXMiOlt7ImF1dGhvcml0eSI6IkN1c3RvbWVyIn1dLCJleHAiOjE3MzQ1MTA1MDEsImlhdCI6MTczNDUwMzMwMX0.89Y1_HthjVIJQpKcBIEAke5lIrM1yn0vtrc8xzu_TsK2JbSPPJjkwfTylSFfexUCDszjmKdKXzUE2n1LxrPYNA';

  String token = window.sessionStorage["token"] ?? " ";
  String? role = window.sessionStorage["role"];
  String? dropdownValue2 = 'Select Year';

  // late Future<DashboardCounts?> futureDashboardCounts;
  //Naveen code
  int currentPage = 1;
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
  ord.Product? _selectedProduct;
  int itemsPerPage = 10;
  int totalItems = 0;
  int totalPages = 0;

  bool _loading = false;
  List<ors.detail> filteredData1 = [];
  List<ors.detail> filteredData = [];
  List<ors.detail> productList = [];

  List<String> _sortOrder = List.generate(5, (index) => 'asc');
  List<String> columns = [
    'Order ID',
    'Customer Name',
    'Order Date',
    'Total Amount',
    'Status'
  ];
  List<double> columnWidths = [
    140,
    150,
    110,
    119,
    140,
    135,
  ];
  List<bool> columnSortState = [true, true, true, true, true, true];

  Product? product1;

  Future<void> fetchProducts(int page, int itemsPerPage) async {
    if (isLoading) return;
    if (!mounted) return;
    setState(() {
      isLoading = true;
    });
    try {
      //https://ordermanagement-industrious-dugong-ig.cfapps.us10-001.hana.ondemand.com/api/order_master/get_all_ordermaster
      final response = await http.get(
        Uri.parse(
          '$apicall/order_master/get_all_ordermaster?page=$page&limit=$itemsPerPage', // Changed limit to 10
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
          List<ors.detail> products = [];
          if (jsonData is List) {
            products =
                jsonData.map((item) => ors.detail.fromJson(item)).toList();
          } else if (jsonData is Map && jsonData.containsKey('body')) {
            final body = jsonData['body'];
            if (body != null) {
              products = (body as List)
                  .map((item) => ors.detail.fromJson(item))
                  .toList();
              totalItems =
                  jsonData['totalItems'] ?? 0; // Get the total number of items
            } else {}
          } else {}

          if (mounted) {
            setState(() {
              totalPages = (products.length / itemsPerPage).ceil();
              productList = products;
              _filterAndPaginateProducts();
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

  void _updateSearch(String searchText) {
    setState(() {
      _searchText = searchText;
      currentPage = 1; // Reset to first page when searching
      _filterAndPaginateProducts();
      // _clearSearch();
    });
  }

  void _goToPreviousPage() {
    if (currentPage > 1) {
      if (filteredData1.length > itemsPerPage) {
        setState(() {
          currentPage--;
        });
      }
    }
  }

  void _goToNextPage() {
    if (currentPage < totalPages) {
      if (filteredData1.length > currentPage * itemsPerPage) {
        setState(() {
          currentPage++;
        });
      }
    }
  }

  void _filterAndPaginateProducts() {
    filteredData1 = productList.where((product) {
      final matchesSearchText =
      product.orderId!.toLowerCase().contains(_searchText.toLowerCase());
      String orderYear = '';
      if (product.deliveredDate!.contains('/') ||
          product.deliveredDate!.contains('-')) {
        String separator = product.deliveredDate!.contains('/') ? '/' : '-';
        final dateParts = product.deliveredDate!.split(separator);
        if (dateParts.length == 3) {
          orderYear = dateParts[2]; // Extract the year
          //Extract the day
        }
      }
      // print(product.deliveredDate);
      // if (product.deliveredDate!.contains('/')) {
      //   final dateParts = product.deliveredDate!.split('/');
      //   if (dateParts.length == 3) {
      //     orderYear = dateParts[0]; // Extract the year
      //   }
      // }
      if (status.isEmpty && selectDate.isEmpty) {
        return matchesSearchText; // Include all products that match the search text
      }
      if (status == 'Delivery Status' && selectDate == 'Select Year') {
        return matchesSearchText;
      }
      if (status == 'Delivery Status' && selectDate.isEmpty) {
        return matchesSearchText;
      }
      if (selectDate == 'Select Year' && status.isEmpty) {
        return matchesSearchText;
      }
      if (status == 'Delivery Status' && selectDate.isNotEmpty) {
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
    totalPages = (filteredData1.length / itemsPerPage).ceil();
    setState(() {
      // print('fileterpaginate');
      // print(_filteredData);
      currentPage = 1;
    });
  }

  @override
  void initState() {
    super.initState();
    _getDashboardCounts();
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
    String formattedDate = DateFormat('dd/MM/yyyy').format(_selectedDate!);
    _dateController.text = formattedDate;
    fetchProducts(currentPage, itemsPerPage);
  }

  Map<String, int> _dashboardCounts = {}; // Start with an empty map.

  Future<void> _getDashboardCounts() async {
    final response = await http.get(
      Uri.parse('$apicall/order_master/get_order_counts'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (token.trim().isEmpty) {
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
                      const Icon(Icons.warning, color: Colors.orange, size: 50),
                      const SizedBox(height: 16),
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              context.go('/');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              side: const BorderSide(color: Colors.blue),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                            child: const Text(
                              'OK',
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
        final dashboardCounts = DashboardCounts.fromJson(jsonData);

        setState(() {
          _dashboardCounts = {
            if (dashboardCounts.openOrders > 0)
              'Open Orders': dashboardCounts.openOrders,
            if (dashboardCounts.Picked > 0)
              'Picked Orders': dashboardCounts.Picked,
            if (dashboardCounts.Delivered > 0)
              'Order Delivered': dashboardCounts.Delivered,
            if (dashboardCounts.Cleard > 0)
              'Order Completed': dashboardCounts.Cleard,
          } as Map<String, int>;
        });
      } else {
        throw Exception('Failed to load dashboard counts');
      }
    }
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
          controller: verticalscroll1,
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
                        icon: const Icon(
                          Icons.menu,
                        )),
                  },
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 10),
                    child: Text(
                      'Dashboard',
                      style: TextStyles.header1,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                      flex: 5,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Responsive(
                            mobile: GridView1(
                              // openorders: dashboardCounts.openorders,
                              crossAxisCount: _size.width <= 1080 ? 2 : 4,
                              childAspectRatio: _size.width < 1080 ? 1.4 : 1.1,
                            ),
                            desktop: GridView1(
                              childAspectRatio: _size.width < 1280 ? 1.1 : 1.4,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(30),
                            child: Container(
                              //  padding: const EdgeInsets.all(16.0),
                              decoration: BoxDecoration(
                                //   border: Border.all(color: Colors.grey),
                                color: Colors.white,
                                border:
                                Border.all(color: const Color(0x29000000)),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: [
                                      // Search Field
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            top: 20, left: 30),
                                        child: Container(
                                          width: width * 0.25,
                                          height: 35,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                            BorderRadius.circular(2),
                                            border:
                                            Border.all(color: Colors.grey),
                                          ),
                                          child: TextFormField(
                                            style: GoogleFonts.inter(
                                                color: Colors.black,
                                                fontSize: 13),
                                            decoration: InputDecoration(
                                              hintText: 'Search by Order ID',
                                              hintStyle: TextStyles.body,
                                              contentPadding:
                                              EdgeInsets.symmetric(
                                                  vertical: 3,
                                                  horizontal: 5),
                                              // adjusted padding
                                              border: InputBorder.none,
                                              suffixIcon: Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 10, right: 5),
                                                // Adjust image padding
                                                child: Image.asset(
                                                  'images/search.png', // Replace with your image asset path
                                                ),
                                              ),
                                            ),
                                            onChanged: _updateSearch,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 8.0),

                                  // DataTable with ConstrainedBox to avoid overflow
                                  if (Responsive.isMobile(context)) ...{
                                    if (filteredData1.isEmpty) ...{
                                      Column(
                                        mainAxisAlignment:
                                        MainAxisAlignment.start,
                                        children: [
                                          Container(
                                            // height: 600,
                                            width: width,
                                            decoration: const BoxDecoration(
                                                color: Color(0xFFF7F7F7),
                                                border: Border.symmetric(
                                                    horizontal: BorderSide(
                                                        color: Colors.grey,
                                                        width: 0.5))),
                                            child: DataTable(
                                                showCheckboxColumn: false,
                                                headingRowHeight: 40,
                                                columnSpacing: 50,
                                                columns: [
                                                  DataColumn(
                                                      label: Container(
                                                          child: Text(
                                                              'Order ID',
                                                              style: TextStyles
                                                                  .subhead))),
                                                  DataColumn(
                                                      label: Text(
                                                          'Customer Name',
                                                          style: TextStyles
                                                              .subhead)),
                                                  DataColumn(
                                                      label: Container(
                                                          child: Text(
                                                            'Order Date',
                                                            style: TextStyles.subhead,
                                                          ))),
                                                  DataColumn(
                                                      label: Container(
                                                          child: Text(
                                                            'Total Amount',
                                                            style: TextStyles.subhead,
                                                          ))),
                                                  DataColumn(
                                                      label: Container(
                                                          child: Text(
                                                            'Status',
                                                            style: TextStyles.subhead,
                                                          ))),
                                                ],
                                                rows: const []),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                top: 5, left: 130, right: 150),
                                            child: CustomDatafound(),
                                          ),
                                        ],
                                      ),
                                    } else ...{
                                      SizedBox(
                                        height: height,
                                        width: width,
                                        child: SingleChildScrollView(
                                          controller: verticalscroll1,
                                          scrollDirection: Axis.vertical,
                                          child: SingleChildScrollView(
                                            scrollDirection: Axis.horizontal,
                                            child: DataTable(
                                                showCheckboxColumn: false,
                                                headingRowHeight: 40,
                                                headingRowColor:
                                                MaterialStateProperty.all(
                                                    Color(0xFFF7F7F7)),
                                                columns: columns.map((column) {
                                                  return DataColumn(
                                                    label: Stack(
                                                      children: [
                                                        Container(
                                                          //   padding: EdgeInsets.only(left: 5,right: 5),
                                                          width: columnWidths[
                                                          columns.indexOf(
                                                              column)],
                                                          // Dynamic width based on user interaction
                                                          child: Row(
                                                            mainAxisSize:
                                                            MainAxisSize
                                                                .min,
                                                            //crossAxisAlignment: CrossAxisAlignment.end,
                                                            //   mainAxisAlignment: MainAxisAlignment.end,
                                                            children: [
                                                              Text(column,
                                                                  overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                                  style: TextStyles
                                                                      .subhead),
                                                              //  if (columns.indexOf(column) > 0)
                                                              IconButton(
                                                                icon: _sortOrder[columns.indexOf(
                                                                    column)] ==
                                                                    'asc'
                                                                    ? SizedBox(
                                                                    width:
                                                                    12,
                                                                    child: Image
                                                                        .asset(
                                                                      "images/ix_sort.png",
                                                                      color:
                                                                      Colors.blue,
                                                                    ))
                                                                    : SizedBox(
                                                                    width:
                                                                    12,
                                                                    child: Image
                                                                        .asset(
                                                                      "images/ix_sort.png",
                                                                      color:
                                                                      Colors.blue,
                                                                    )),
                                                                onPressed: () {
                                                                  setState(() {
                                                                    _sortOrder[columns
                                                                        .indexOf(
                                                                        column)] = _sortOrder[
                                                                    columns.indexOf(column)] ==
                                                                        'asc'
                                                                        ? 'desc'
                                                                        : 'asc';
                                                                    _sortProducts(
                                                                        columns.indexOf(
                                                                            column),
                                                                        _sortOrder[
                                                                        columns.indexOf(column)]);
                                                                  });
                                                                },
                                                              ),
                                                              //SizedBox(width: 50,),
                                                              // ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    onSort: (columnIndex,
                                                        ascending) {
                                                      _sortOrder;
                                                    },
                                                  );
                                                }).toList(),
                                                rows: List.generate(
                                                    math.min(
                                                        itemsPerPage,
                                                        filteredData1.length -
                                                            (currentPage - 1) *
                                                                itemsPerPage),
                                                        (index) {
                                                      // final detail1 = filteredData.skip((currentPage - 1) * itemsPerPage).elementAt(index);
                                                      final detail = filteredData1
                                                          .skip((currentPage - 1) *
                                                          itemsPerPage)
                                                          .elementAt(index);
                                                      final isSelected =
                                                          _selectedProduct ==
                                                              detail;
                                                      return DataRow(
                                                        color: MaterialStateProperty
                                                            .resolveWith<Color>(
                                                                (states) {
                                                              if (states.contains(
                                                                  MaterialState
                                                                      .hovered)) {
                                                                return Colors
                                                                    .blue.shade500
                                                                    .withOpacity(
                                                                    0.8); // Add some opacity to the dark blue
                                                              } else {
                                                                return Colors.white
                                                                    .withOpacity(0.9);
                                                              }
                                                            }),
                                                        cells: [
                                                          DataCell(
                                                            Container(
                                                              width:
                                                              columnWidths[0],
                                                              // Same dynamic width as column headers
                                                              child: Text(
                                                                detail.orderId
                                                                    .toString(),
                                                                style:
                                                                TextStyles.body,
                                                              ),
                                                            ),
                                                          ),
                                                          DataCell(
                                                            Container(
                                                              width:
                                                              columnWidths[1],
                                                              child: Text(
                                                                detail
                                                                    .contactPerson!,
                                                                style:
                                                                TextStyles.body,
                                                              ),
                                                            ),
                                                          ),
                                                          DataCell(
                                                            Container(
                                                              width:
                                                              columnWidths[2],
                                                              child: Text(
                                                                detail.orderDate!,
                                                                style:
                                                                TextStyles.body,
                                                              ),
                                                            ),
                                                          ),
                                                          DataCell(
                                                            Container(
                                                              width:
                                                              columnWidths[3],
                                                              child: Text(
                                                                detail.total
                                                                    .toString(),
                                                                style:
                                                                TextStyles.body,
                                                              ),
                                                            ),
                                                          ),
                                                          DataCell(
                                                            Container(
                                                              width:
                                                              columnWidths[4],
                                                              child: Text(
                                                                detail
                                                                    .deliveryStatus
                                                                    .toString(),
                                                                style:
                                                                TextStyles.body,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      );
                                                    })),
                                          ),
                                        ),
                                      ),
                                    }
                                  } else ...{
                                    if (filteredData1.isEmpty) ...{
                                      Column(
                                        mainAxisAlignment:
                                        MainAxisAlignment.start,
                                        children: [
                                          Container(
                                            // height: 600,
                                            width: width,
                                            decoration: const BoxDecoration(
                                                color: Color(0xFFF7F7F7),
                                                border: Border.symmetric(
                                                    horizontal: BorderSide(
                                                        color: Colors.grey,
                                                        width: 0.5))),
                                            child: DataTable(
                                                showCheckboxColumn: false,
                                                headingRowHeight: 40,
                                                columnSpacing: 50,
                                                columns: [
                                                  DataColumn(
                                                      label: Container(
                                                          child: Text(
                                                              'Order ID',
                                                              style: TextStyles
                                                                  .subhead))),
                                                  DataColumn(
                                                      label: Text(
                                                          'Customer Name',
                                                          style: TextStyles
                                                              .subhead)),
                                                  DataColumn(
                                                      label: Container(
                                                          child: Text(
                                                            'Order Date',
                                                            style: TextStyles.subhead,
                                                          ))),
                                                  DataColumn(
                                                      label: Container(
                                                          child: Text(
                                                            'Total Amount',
                                                            style: TextStyles.subhead,
                                                          ))),
                                                  DataColumn(
                                                      label: Container(
                                                          child: Text(
                                                            'Status',
                                                            style: TextStyles.subhead,
                                                          ))),
                                                ],
                                                rows: const []),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                top: 5, left: 130, right: 150),
                                            child: CustomDatafound(),
                                          ),
                                        ],
                                      ),
                                    } else ...{
                                      Column(children: [
                                        SizedBox(
                                          height: 500,
                                          width: width,
                                          child: SingleChildScrollView(
                                            scrollDirection: Axis.vertical,
                                            controller: verticalscroll2,
                                            child: DataTable(
                                                showCheckboxColumn: false,
                                                headingRowHeight: 40,
                                                headingRowColor:
                                                MaterialStateProperty.all(
                                                    Color(0xFFF7F7F7)),
                                                columns: columns.map((column) {
                                                  return DataColumn(
                                                    label: Stack(
                                                      children: [
                                                        Container(
                                                          //   padding: EdgeInsets.only(left: 5,right: 5),
                                                          width: columnWidths[
                                                          columns.indexOf(
                                                              column)],
                                                          // Dynamic width based on user interaction
                                                          child: Row(
                                                            mainAxisSize:
                                                            MainAxisSize
                                                                .min,
                                                            //crossAxisAlignment: CrossAxisAlignment.end,
                                                            //   mainAxisAlignment: MainAxisAlignment.end,
                                                            children: [
                                                              Text(column,
                                                                  overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                                  style: TextStyles
                                                                      .subhead),
                                                              //  if (columns.indexOf(column) > 0)
                                                              IconButton(
                                                                icon: _sortOrder[columns.indexOf(
                                                                    column)] ==
                                                                    'asc'
                                                                    ? SizedBox(
                                                                    width:
                                                                    12,
                                                                    child: Image
                                                                        .asset(
                                                                      "images/ix_sort.png",
                                                                      color:
                                                                      Colors.blue,
                                                                    ))
                                                                    : SizedBox(
                                                                    width:
                                                                    12,
                                                                    child: Image
                                                                        .asset(
                                                                      "images/ix_sort.png",
                                                                      color:
                                                                      Colors.blue,
                                                                    )),
                                                                onPressed: () {
                                                                  setState(() {
                                                                    _sortOrder[columns
                                                                        .indexOf(
                                                                        column)] = _sortOrder[
                                                                    columns.indexOf(column)] ==
                                                                        'asc'
                                                                        ? 'desc'
                                                                        : 'asc';
                                                                    _sortProducts(
                                                                        columns.indexOf(
                                                                            column),
                                                                        _sortOrder[
                                                                        columns.indexOf(column)]);
                                                                  });
                                                                },
                                                              ),
                                                              //SizedBox(width: 50,),
                                                              // ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    onSort: (columnIndex,
                                                        ascending) {
                                                      _sortOrder;
                                                    },
                                                  );
                                                }).toList(),
                                                rows: List.generate(
                                                    math.min(
                                                        itemsPerPage,
                                                        filteredData1.length -
                                                            (currentPage - 1) *
                                                                itemsPerPage),
                                                        (index) {
                                                      // final detail1 = filteredData.skip((currentPage - 1) * itemsPerPage).elementAt(index);
                                                      final detail = filteredData1
                                                          .skip((currentPage - 1) *
                                                          itemsPerPage)
                                                          .elementAt(index);
                                                      final isSelected =
                                                          _selectedProduct ==
                                                              detail;
                                                      return DataRow(
                                                        color: MaterialStateProperty
                                                            .resolveWith<Color>(
                                                                (states) {
                                                              if (states.contains(
                                                                  MaterialState
                                                                      .hovered)) {
                                                                return Colors
                                                                    .blue.shade500
                                                                    .withOpacity(
                                                                    0.8); // Add some opacity to the dark blue
                                                              } else {
                                                                return Colors.white
                                                                    .withOpacity(0.9);
                                                              }
                                                            }),
                                                        cells: [
                                                          DataCell(
                                                            Container(
                                                              width:
                                                              columnWidths[0],
                                                              // Same dynamic width as column headers
                                                              child: Text(
                                                                detail.orderId
                                                                    .toString(),
                                                                style:
                                                                TextStyles.body,
                                                              ),
                                                            ),
                                                          ),
                                                          DataCell(
                                                            Container(
                                                              width:
                                                              columnWidths[1],
                                                              child: Text(
                                                                detail
                                                                    .contactPerson!,
                                                                style:
                                                                TextStyles.body,
                                                              ),
                                                            ),
                                                          ),
                                                          DataCell(
                                                            Container(
                                                              width:
                                                              columnWidths[2],
                                                              child: Text(
                                                                detail.orderDate!,
                                                                style:
                                                                TextStyles.body,
                                                              ),
                                                            ),
                                                          ),
                                                          DataCell(
                                                            Container(
                                                              width:
                                                              columnWidths[3],
                                                              child: Text(
                                                                detail.total
                                                                    .toString(),
                                                                style:
                                                                TextStyles.body,
                                                              ),
                                                            ),
                                                          ),
                                                          DataCell(
                                                            Container(
                                                              width:
                                                              columnWidths[4],
                                                              child: Text(
                                                                detail
                                                                    .deliveryStatus
                                                                    .toString(),
                                                                style:
                                                                TextStyles.body,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      );
                                                    })),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 30),
                                          child: Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment.end,
                                            children: [
                                              PaginationControls(
                                                currentPage: currentPage,
                                                totalPages:
                                                filteredProducts.length >
                                                    itemsPerPage
                                                    ? totalPages
                                                    : 1,
                                                onPreviousPage:
                                                _goToPreviousPage,
                                                onNextPage: _goToNextPage,
                                                // onLastPage: _goToLastPage,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ])
                                    }
                                  }
                                ],
                              ),
                            ),
                          ),
                        ],
                      ))
                ],
              ),
            ],
          )),
    );
  }
}

class GridView1 extends StatefulWidget {
  final int? openorders;
  final int crossAxisCount;
  final double childAspectRatio;

  const GridView1({
    Key? key,
    this.openorders,
    this.crossAxisCount = 4,
    this.childAspectRatio = 3,
  }) : super(key: key);

  @override
  _GridView1State createState() => _GridView1State();
}

class _GridView1State extends State<GridView1> {
  bool _hasShownPopup = false;
  String token = window.sessionStorage["token"] ?? " ";
  Map<String, int> _dashboardCounts1 = {};
  DashboardCounts? _dashboardCounts;

  // List of corresponding images for each tile
  final List<String> _imagePaths = [
    "images/openorders.png",
    "images/file.png",
    "images/dash.png",
    "images/nk1.png",
  ];

  // Dynamic colors for each tile
  final List<Color> _cardColors = [
    const Color(0xFFFFAC8C), // Open Orders
    const Color(0xFF9F86FF), // Picked Orders
    const Color(0xFF455A64), // Order Completed
    const Color(0xFF8BC34A), // Order Delivered
  ];

  // List to track hover states for each grid tile
  late List<bool> _isHovered;

  @override
  void initState() {
    super.initState();
    _getDashboardCounts();
    // Initialize _isHovered as an empty list to avoid errors
    _isHovered = [];
  }

  Future<void> _getDashboardCounts() async {
    if (token.trim().isEmpty) {
      _showSessionExpiredDialog();
      return;
    }

    final response = await http.get(
      Uri.parse('$apicall/order_master/get_order_counts'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      _dashboardCounts = DashboardCounts.fromJson(jsonData);
      setState(() {
        _dashboardCounts1 = {
          'Open Orders': _dashboardCounts?.openOrders ?? 0,
          'Picked Orders': _dashboardCounts?.Picked ?? 0,
          'Order Delivered': _dashboardCounts?.Delivered ?? 0,
          'Order Completed': _dashboardCounts?.Cleard ?? 0,
        };

        // Initialize _isHovered based on the size of _dashboardCounts1
        _isHovered =
        List<bool>.generate(_dashboardCounts1.length, (_) => false);
      });
    } else {
      throw Exception('Failed to load dashboard counts');
    }
  }

  void _showSessionExpiredDialog() {
    if (_hasShownPopup) return; // Prevent multiple dialogs
    _hasShownPopup = true;

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
                    const Icon(Icons.warning, color: Colors.orange, size: 50),
                    const SizedBox(height: 16),
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            context.go('/'); // Navigate to login
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            side: const BorderSide(color: Colors.blue),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                          child: const Text(
                            'OK',
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
  }

  @override
  Widget build(BuildContext context) {
    // Show a loading indicator until _dashboardCounts1 is populated
    if (_dashboardCounts1.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _dashboardCounts1.length,
      padding: const EdgeInsets.all(32),
      shrinkWrap: true,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: widget.crossAxisCount,
        childAspectRatio: 2,
        crossAxisSpacing: 50,
        mainAxisSpacing: 12,
      ),
      itemBuilder: (context, index) {
        String title = _dashboardCounts1.keys.elementAt(index);
        int count = _dashboardCounts1.values.elementAt(index);
        String imagePath = index < _imagePaths.length
            ? _imagePaths[index]
            : "images/default.png";
        Color cardColor =
        index < _cardColors.length ? _cardColors[index] : Colors.grey;

        return MouseRegion(
          onEnter: (_) {
            setState(() {
              _isHovered[index] = true;
            });
          },
          onExit: (_) {
            setState(() {
              _isHovered[index] = false;
            });
          },
          child: AnimatedScale(
            scale: _isHovered[index] ? 1.05 : 1.0,
            duration: const Duration(milliseconds: 200),
            child: InkWell(
              onTap: () {
                // Add navigation or other onTap functionality here
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: cardColor.withOpacity(0.5)),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: _isHovered[index]
                      ? [
                    BoxShadow(
                      color: cardColor.withOpacity(0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                      : [],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: cardColor,
                          width: 1.5,
                        ),
                        color: cardColor.withOpacity(0.2),
                        boxShadow: [
                          BoxShadow(
                            color: cardColor.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 3,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Image.asset(
                        imagePath,
                        fit: BoxFit.scaleDown,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          count.toString(),
                          style: const TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: MediaQuery.of(context).size.width * 0.01,
                            color: const Color(0xFF455A64),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

//second one
// class GridView1 extends StatefulWidget {
//   final int? openorders;
//   final int crossAxisCount;
//   final double childAspectRatio;
//
//   const GridView1({
//     Key? key,
//     this.openorders,
//     this.crossAxisCount = 4,
//     this.childAspectRatio = 2,
//   }) : super(key: key);
//
//   @override
//   _GridView1State createState() => _GridView1State();
// }
//
// class _GridView1State extends State<GridView1> {
//   bool _hasShownPopup = false;
//   String token = window.sessionStorage["token"] ?? " ";
//   Map<String, int> _dashboardCounts1 = {};
//   DashboardCounts? _dashboardCounts;
//
//     //Map<String, int> _dashboardCounts1 = {};
//
//   // List of corresponding images for each tile
//   final List<String> _imagePaths = [
//     "images/openorders.png",
//     "images/file.png",
//     "images/dash.png",
//     "images/nk1.png",
//   ];
//
//   // Dynamic colors for each tile
//   final List<Color> _cardColors = [
//     const Color(0xFFFFAC8C), // Open Orders
//     const Color(0xFF9F86FF), // Picked Orders
//     const Color(0xFF455A64), // Order Completed
//     const Color(0xFF8BC34A), // Order Delivered
//   ];
//
//   // List to track hover states for each grid tile
//   late List<bool> _isHovered;
//   @override
//   void initState() {
//     super.initState();
//     _getDashboardCounts();
//     _isHovered = List<bool>.generate(_dashboardCounts1.length, (_) => false);
//   }
//
//   Future<void> _getDashboardCounts() async {
//     if (token.trim().isEmpty) {
//       _showSessionExpiredDialog();
//       return;
//     }
//
//     final response = await http.get(
//       Uri.parse('$apicall/order_master/get_order_counts'),
//       headers: {
//         'Content-Type': 'application/json',
//         'Authorization': 'Bearer $token',
//       },
//     );
//
//     if (response.statusCode == 200) {
//       final jsonData = jsonDecode(response.body);
//       _dashboardCounts = DashboardCounts.fromJson(jsonData);
//       setState(() {
//         _dashboardCounts1 = {
//           'Open Orders': _dashboardCounts?.openOrders ?? 0,
//           'Picked Orders': _dashboardCounts?.Picked ?? 0,
//           'Order Delivered': _dashboardCounts?.Delivered ?? 0,
//           'Order Completed': _dashboardCounts?.Cleard ?? 0,
//         };
//       });
//     } else {
//       throw Exception('Failed to load dashboard counts');
//     }
//   }
//
//   void _showSessionExpiredDialog() {
//     if (_hasShownPopup) return; // Prevent multiple dialogs
//     _hasShownPopup = true;
//
//     showDialog(
//       barrierDismissible: false,
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
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
//                     const Icon(Icons.warning, color: Colors.orange, size: 50),
//                     const SizedBox(height: 16),
//                     const Text(
//                       'Session Expired',
//                       style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.black,
//                       ),
//                     ),
//                     const Text(
//                       "Please log in again to continue",
//                       style: TextStyle(
//                         fontSize: 12,
//                         color: Colors.black,
//                       ),
//                     ),
//                     const SizedBox(height: 20),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         ElevatedButton(
//                           onPressed: () {
//                             context.go('/'); // Navigate to login
//                           },
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.white,
//                             side: const BorderSide(color: Colors.blue),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(10.0),
//                             ),
//                           ),
//                           child: const Text(
//                             'OK',
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
//       },
//     ).whenComplete(() {
//       _hasShownPopup = false;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return GridView.builder(
//       physics: const NeverScrollableScrollPhysics(),
//       itemCount: _dashboardCounts1.length,
//       padding: const EdgeInsets.all(32),
//       shrinkWrap: true,
//       gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: widget.crossAxisCount,
//         childAspectRatio: widget.childAspectRatio,
//         crossAxisSpacing: 50,
//         mainAxisSpacing: 12,
//       ),
//       itemBuilder: (context, index) {
//         String title = _dashboardCounts1.keys.elementAt(index);
//         int count = _dashboardCounts1.values.elementAt(index);
//         String imagePath = index < _imagePaths.length ? _imagePaths[index] : "images/default.png";
//         Color cardColor = index < _cardColors.length ? _cardColors[index] : Colors.grey;
//
//         return MouseRegion(
//           onEnter: (_) {
//             setState(() {
//               _isHovered[index] = true;
//             });
//           },
//           onExit: (_) {
//             setState(() {
//               _isHovered[index] = false;
//             });
//           },
//           child: AnimatedScale(
//             scale: _isHovered[index] ? 1.05 : 1.0,
//             duration: const Duration(milliseconds: 200),
//             child: InkWell(
//               onTap: () {
//                 // Add navigation or other onTap functionality here
//               },
//               child: Container(
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   border: Border.all(color: cardColor.withOpacity(0.5)),
//                   borderRadius: BorderRadius.circular(15),
//                   boxShadow: _isHovered[index]
//                       ? [
//                     BoxShadow(
//                       color: cardColor.withOpacity(0.4),
//                       blurRadius: 8,
//                       offset: const Offset(0, 4),
//                     ),
//                   ]
//                       : [],
//                 ),
//                 child: Row(
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     Container(
//                       width: 60,
//                       height: 60,
//                       decoration: BoxDecoration(
//                         shape: BoxShape.circle,
//                         border: Border.all(
//                           color: cardColor,
//                           width: 1.5,
//                         ),
//                         color: cardColor.withOpacity(0.2),
//                         boxShadow: [
//                           BoxShadow(
//                             color: cardColor.withOpacity(0.1),
//                             spreadRadius: 1,
//                             blurRadius: 3,
//                             offset: const Offset(0, 1),
//                           ),
//                         ],
//                       ),
//                       child: Image.asset(
//                         imagePath,
//                         fit: BoxFit.scaleDown,
//                       ),
//                     ),
//                     const SizedBox(width: 10),
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Text(
//                           count.toString(),
//                           style: const TextStyle(
//                             fontSize: 25,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         const SizedBox(height: 5),
//                         Text(
//                           title,
//                           style: TextStyle(
//                             fontSize: MediaQuery.of(context).size.width * 0.01,
//                             color: const Color(0xFF455A64),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
// }
//third one
// class GridView1 extends StatefulWidget {
//   final int? openorders;
//   final int crossAxisCount;
//   final double childAspectRatio;
//
//   const GridView1({
//     Key? key,
//     this.openorders,
//     this.crossAxisCount = 4,
//     this.childAspectRatio = 2,
//   }) : super(key: key);
//
//   @override
//   _GridView1State createState() => _GridView1State();
// }
//
// class _GridView1State extends State<GridView1> {
//  // DashboardCounts? _dashboardCounts;
//   bool _hasShownPopup = false;
//   String token = window.sessionStorage["token"] ?? " ";
//   //String token =    'eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJUZXN0IEN1c3RvbWVyIiwiUm9sZXMiOlt7ImF1dGhvcml0eSI6IkN1c3RvbWVyIn1dLCJleHAiOjE3MzQ1MTA1MDEsImlhdCI6MTczNDUwMzMwMX0.89Y1_HthjVIJQpKcBIEAke5lIrM1yn0vtrc8xzu_TsK2JbSPPJjkwfTylSFfexUCDszjmKdKXzUE2n1LxrPYNA';
//   Map<String, int> _dashboardCounts1 = {}; // Initialize with an empty map.
//   DashboardCounts? _dashboardCounts; // Class instance for parsed data.
//
//   Future<void> _getDashboardCounts() async {
//     final response = await http.get(
//       Uri.parse('$apicall/order_master/get_order_counts'),
//       headers: {
//         'Content-Type': 'application/json',
//         'Authorization': 'Bearer $token',
//       },
//     );
//
//     if (token.trim().isEmpty) {
//       // Show the "Session Expired" dialog
//       showDialog(
//         barrierDismissible: false,
//         context: context,
//         builder: (BuildContext context) {
//           return AlertDialog(
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(15.0),
//             ),
//             contentPadding: EdgeInsets.zero,
//             content: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Column(
//                     children: [
//                       const Icon(Icons.warning, color: Colors.orange, size: 50),
//                       const SizedBox(height: 16),
//                       const Text(
//                         'Session Expired',
//                         style: TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.black,
//                         ),
//                       ),
//                       const Text(
//                         "Please log in again to continue",
//                         style: TextStyle(
//                           fontSize: 12,
//                           color: Colors.black,
//                         ),
//                       ),
//                       const SizedBox(height: 20),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           ElevatedButton(
//                             onPressed: () {
//                               context.go('/'); // Navigate to login
//                             },
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: Colors.white,
//                               side: const BorderSide(color: Colors.blue),
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(10.0),
//                               ),
//                             ),
//                             child: const Text(
//                               'OK',
//                               style: TextStyle(
//                                 color: Colors.blue,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           );
//         },
//       ).whenComplete(() {
//         _hasShownPopup = false;
//       });
//     } else {
//       if (response.statusCode == 200) {
//         final jsonData = jsonDecode(response.body);
//         _dashboardCounts = DashboardCounts.fromJson(jsonData);
//
//         // Update the map with actual values
//         setState(() {
//           _dashboardCounts1 = {
//             // 'Open Orders': ,
//             // 'Picked Orders': 10,
//             // 'Order Delivered': 5,
//             // 'Order Completed': 20,
//             'Open Orders': _dashboardCounts?.openOrders ?? 0,
//             'Picked Orders': _dashboardCounts?.Picked ?? 0,
//             'Order Delivered': _dashboardCounts?.Delivered ?? 0,
//             'Order Completed': _dashboardCounts?.Cleard ?? 0,
//           };
//         });
//       } else {
//         throw Exception('Failed to load dashboard counts');
//       }
//     }
//   }
//
//   // Mock data for dashboard counts
//
//
//    //Map<String, int> _dashboardCounts1 = {};
//
//   // List of corresponding images for each tile
//   final List<String> _imagePaths = [
//     "images/openorders.png",
//     "images/file.png",
//     "images/dash.png",
//     "images/nk1.png",
//   ];
//
//   // Dynamic colors for each tile
//   final List<Color> _cardColors = [
//     const Color(0xFFFFAC8C), // Open Orders
//     const Color(0xFF9F86FF), // Picked Orders
//     const Color(0xFF455A64), // Order Completed
//     const Color(0xFF8BC34A), // Order Delivered
//   ];
//
//   // List to track hover states for each grid tile
//   late List<bool> _isHovered;
//
//   @override
//   void initState() {
//     super.initState();
//     _getDashboardCounts();
//     // Initialize hover states for each tile
//     _isHovered = List<bool>.generate(_dashboardCounts1.length, (_) => false);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return   GridView.builder(
//       physics: const NeverScrollableScrollPhysics(),
//       itemCount: _dashboardCounts1.length, // Total tiles = map length
//       padding: const EdgeInsets.all(32),
//       shrinkWrap: true,
//       gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: widget.crossAxisCount,
//         childAspectRatio: 2,
//         crossAxisSpacing: 50,
//         mainAxisSpacing: 12,
//       ),
//       itemBuilder: (context, index) {
//         // Get data for the current index
//         String title = _dashboardCounts1.keys.elementAt(index);
//         int count = _dashboardCounts1.values.elementAt(index);
//
//         // Ensure the list doesn't throw an out-of-bounds error
//         String imagePath = index < _imagePaths.length
//             ? _imagePaths[index]
//             : "images/default.png"; // Fallback image
//
//         Color cardColor = index < _cardColors.length
//             ? _cardColors[index]
//             : Colors.grey; // Fallback color
//
//         // Initialize hover state dynamically for each tile
//         bool isHovered = _isHovered.length > index ? _isHovered[index] : false;
//
//         return MouseRegion(
//           onEnter: (_) {
//             setState(() {
//               _isHovered[index] = true;
//             });
//           },
//           onExit: (_) {
//             setState(() {
//               _isHovered[index] = false;
//             });
//           },
//           child: AnimatedScale(
//             scale: isHovered ? 1.05 : 1.0,
//             duration: const Duration(milliseconds: 200),
//             child: InkWell(
//               onTap: () {
//                 // Add navigation or other onTap functionality here
//               },
//               child: Container(
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   color: Colors.white, // Use card color with opacity
//                   border: Border.all(color: cardColor.withOpacity(0.5)),
//                   borderRadius: BorderRadius.circular(15),
//                   boxShadow: isHovered
//                       ? [
//                     BoxShadow(
//                       color: cardColor.withOpacity(0.4),
//                       blurRadius: 8,
//                       offset: const Offset(0, 4),
//                     ),
//                   ]
//                       : [],
//                 ),
//                 child: Row(
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     // Left Side Circle Avatar with Image
//                     Container(
//                       width: 60,
//                       height: 60,
//                       decoration: BoxDecoration(
//                         shape: BoxShape.circle,
//                         border: Border.all(
//                           color: cardColor, // Border color matches card
//                           width: 1.5,
//                         ),
//                         color: cardColor.withOpacity(0.2),
//                         boxShadow: [
//                           BoxShadow(
//                             color: cardColor.withOpacity(0.1),
//                             spreadRadius: 1,
//                             blurRadius: 3,
//                             offset: const Offset(0, 1),
//                           ),
//                         ],
//                       ),
//                       child: Image.asset(
//                         imagePath, // Dynamic image for each tile
//                         fit: BoxFit.scaleDown,
//                       ),
//                     ),
//                     const SizedBox(width: 10),
//
//                     // Right Side Column for Count and Label
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Text(
//                           count.toString(), // Dynamic count
//                           style: const TextStyle(
//                             fontSize: 25,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         const SizedBox(height: 5),
//                         Text(
//                           title, // Dynamic title
//                           style: TextStyle(
//                             fontSize: MediaQuery.of(context).size.width * 0.01,
//                             color: const Color(0xFF455A64),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         );
//       },
//     );
//
//   }
// }

class DataType {
  final String orderId;
  final String contactPerson;
  final String orderDate;
  final double total;
  final String deliveryStatus;

  DataType({
    required this.orderId,
    required this.contactPerson,
    required this.orderDate,
    required this.total,
    required this.deliveryStatus,
  });
}
