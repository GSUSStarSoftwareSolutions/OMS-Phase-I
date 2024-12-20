import 'package:btb/sample/size.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

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
    child: ResponsiveEmpOrdersPage(),
  ),
));

class ResponsiveEmpOrdersPage extends StatelessWidget {
  const ResponsiveEmpOrdersPage({super.key});

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
            Expanded(flex: 5, child: OrderListResponsive()),
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
              Icons.home_outlined,
              Colors.blue[900]!,
              '/Home',
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
                '/Order_List',
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

class OrderListResponsive extends StatefulWidget {
  OrderListResponsive({super.key});

  @override
  State<OrderListResponsive> createState() => _OrderListResponsiveState();
}

class _OrderListResponsiveState extends State<OrderListResponsive>
    with SingleTickerProviderStateMixin {
  List<String> _sortOrder = List.generate(5, (index) => 'asc');
  List<String> columns = [
    'Order ID',
    'Customer Name',
    'Order Date',
    'Total',
    'Status',
  ];
  bool _hasShownPopup = false;
  List<double> columnWidths = [95, 130, 110, 95, 150, 140];
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
  List<detail> productList = [];

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
                        Icon(Icons.warning, color: Colors.orange, size: 50),
                        SizedBox(height: 16),
                        // Confirmation Message
                        Text(
                          'Session Expired',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          "Please log in again to continue",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 20),
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
                                side: BorderSide(color: Colors.blue),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                              ),
                              child: Text(
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


  void _filterAndPaginateProducts() {
    filteredData = productList.where((product) {
      final matchesSearchText =
          product.orderId!.toLowerCase().contains(_searchText.toLowerCase()) ||
              product.contactPerson!
                  .toLowerCase()
                  .contains(_searchText.toLowerCase());
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                    child: Text(
                      'Order List',
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
                          Padding(
                            padding: const EdgeInsets.all(30),
                            child: Container(
                              //  padding: const EdgeInsets.all(16.0),
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
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.only(
                                      left: 20,
                                      right: 20,
                                      top: 10,
                                    ),
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                          children: [
                                            // Search Field
                                            Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: ConstrainedBox(
                                                constraints: BoxConstraints(
                                                  maxWidth: width * 0.261,
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
                                                    style: GoogleFonts.inter(
                                                        color: Colors.black, fontSize: 13),
                                                    decoration: InputDecoration(
                                                        hintText:
                                                        'Search by Order ID or Customer Name',
                                                        hintStyle: TextStyles.body,
                                                        contentPadding: EdgeInsets.symmetric(
                                                            vertical: 3, horizontal: 5),
                                                        // contentPadding:
                                                        // EdgeInsets.only(bottom: 20, left: 10),
                                                        // adjusted padding
                                                        border: InputBorder.none,
                                                        suffixIcon: Padding(
                                                          padding: const EdgeInsets.only(
                                                              left: 10, right: 5),
                                                          // Adjust image padding
                                                          child: Image.asset(
                                                            'images/search.png', // Replace with your image asset path
                                                          ),
                                                        )),
                                                    onChanged: _updateSearch,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: ConstrainedBox(
                                                constraints: BoxConstraints(
                                                  maxWidth: width <=500 ?120  : width * 0.12,
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
                                                      'Created',
                                                      'Picked',
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
                                                    iconStyleData: const IconStyleData(
                                                      icon: Icon(
                                                        Icons.keyboard_arrow_down,
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
                                                      width: width * 0.12, // Dropdown width
                                                      offset:  const Offset(0, -10),
                                                    ),
                                                    isExpanded: true,
                                                    // focusColor: Color(0xFFF0F4F8),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            //  Spacer(),
                                            // Padding(
                                            //   padding: const EdgeInsets.all(16),
                                            //   child: Column(
                                            //     crossAxisAlignment: CrossAxisAlignment.start,
                                            //     children: [
                                            //       //  const SizedBox(height: 8),
                                            //       Padding(
                                            //         padding: const EdgeInsets.only(left: 30,top: 20),
                                            //         child: Container(
                                            //           width: width * 0.1, // reduced width
                                            //           height: 40, // reduced height
                                            //           decoration: BoxDecoration(
                                            //             color: Colors.white,
                                            //             borderRadius: BorderRadius.circular(2),
                                            //             border: Border.all(color: Colors.grey),
                                            //           ),
                                            //           child: DropdownButtonFormField2<String>(
                                            //             decoration: const InputDecoration(
                                            //               contentPadding: EdgeInsets.only(
                                            //                   bottom: 15, left: 9), // Custom padding
                                            //               border: InputBorder.none, // No default border
                                            //               filled: true,
                                            //               fillColor: Colors.white, // Background color
                                            //             ),
                                            //             isExpanded: true,
                                            //             // Ensures dropdown takes full width
                                            //             value: dropdownValue1,
                                            //             onChanged: (String? newValue) {
                                            //               setState(() {
                                            //                 dropdownValue1 = newValue;
                                            //                 status = newValue ?? '';
                                            //                 _filterAndPaginateProducts();
                                            //               });
                                            //             },
                                            //             items: <String>[
                                            //               'Delivery Status',
                                            //               'Not Started',
                                            //               'In Progress',
                                            //               'Delivered',
                                            //             ].map<DropdownMenuItem<String>>((String value) {
                                            //               return DropdownMenuItem<String>(
                                            //                 value: value,
                                            //                 child: Text(
                                            //                   value,
                                            //                   style: TextStyle(
                                            //                     fontSize: 13,
                                            //                     color: value == 'Delivery Status'
                                            //                         ? Colors.grey
                                            //                         : Colors.black,
                                            //                   ),
                                            //                 ),
                                            //               );
                                            //             }).toList(),
                                            //             iconStyleData: const IconStyleData(
                                            //               icon: Icon(
                                            //                 Icons.keyboard_arrow_down,
                                            //                 color: Colors.indigo,
                                            //                 size: 16,
                                            //               ),
                                            //               iconSize: 16,
                                            //             ),
                                            //             buttonStyleData: const ButtonStyleData(
                                            //               height: 50, // Button height
                                            //               padding: EdgeInsets.only(
                                            //                   left: 10, right: 10), // Button padding
                                            //             ),
                                            //             dropdownStyleData: DropdownStyleData(
                                            //               decoration: BoxDecoration(
                                            //                 borderRadius: BorderRadius.circular(7),
                                            //                 // Rounded corners
                                            //                 color: Colors.white, // Dropdown background color
                                            //               ),
                                            //               maxHeight: 200, // Max height for dropdown items
                                            //               width: width * 0.1, // Dropdown width
                                            //               offset: const Offset(0, -20),
                                            //             ),
                                            //           ),
                                            //         ),
                                            //       ),
                                            //     ],
                                            //   ),
                                            // ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(height: 8.0),
                                  // DataTable with ConstrainedBox to avoid overflow
                                  if (Responsive.isMobile(context)) ...{
                                    if (filteredData.isEmpty) ...{
                                      Column(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          Container(
                                            // height: 600,
                                            width: width,
                                            decoration: BoxDecoration(
                                                color: Color(0xFFF7F7F7),
                                                border: Border.symmetric(
                                                    horizontal: BorderSide(
                                                        color: Colors.grey,
                                                        width: 0.5))),
                                            child: DataTable(
                                                showCheckboxColumn: false,
                                                headingRowHeight: 40,
                                                columnSpacing: 50,
                                                headingRowColor:
                                                MaterialStateProperty.all(
                                                    Colors.grey.shade300),
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
                                                rows: const []),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                top: 5, left: 130, right: 150),
                                            child: CustomDatafound(),
                                          ),
                                        ],
                                      ),
                                    }else...{
                                      SizedBox(
                                        height: height,
                                        width: width,
                                        child: SingleChildScrollView(
                                          scrollDirection: Axis.vertical,
                                          child:  width <= 850
                                              ?  ListView.builder(
                                            shrinkWrap: true,
                                            physics: NeverScrollableScrollPhysics(),
                                            itemCount: math.min(itemsPerPage, filteredData.length - (currentPage - 1) * itemsPerPage),
                                            itemBuilder: (context, index) {
                                              final product = filteredData[(currentPage - 1) * itemsPerPage + index];
                                              return Container(
                                                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                                decoration:BoxDecoration(
                                                  //   border: Border.all(color: Colors.grey),
                                                  color: Colors.white,
                                                  border: Border.all(color: Color(0x29000000)),
                                                  borderRadius: BorderRadius.circular(15),
                                                ),
                                                child: Padding(
                                                  padding: const EdgeInsets.all(16.0),
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        product.orderId!.length > 25
                                                            ? '${product.orderId!.substring(0, 25)}...'
                                                            : product.orderId!,
                                                        style: TextStyles.subhead.copyWith(fontWeight: FontWeight.bold),
                                                      ),
                                                      SizedBox(height: 8),
                                                      Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: [
                                                          Text('Customer Name:', style: TextStyles.body),
                                                          Text(product.customerName!, style: TextStyles.body),
                                                        ],
                                                      ),
                                                      SizedBox(height: 8),
                                                      Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: [
                                                          Text('Order Date:', style: TextStyles.body),
                                                          Text(product.orderDate, style: TextStyles.body),
                                                        ],
                                                      ),
                                                      SizedBox(height: 8),
                                                      Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: [
                                                          Text('Total Amount: ', style: TextStyles.body),
                                                          Text('₹${product.total.toString()}', style: TextStyles.body),
                                                        ],
                                                      ),
                                                      SizedBox(height: 8),
                                                      Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: [
                                                          Text('Status:', style: TextStyles.body),
                                                          Text(product.status.toString(), style: TextStyles.body),
                                                        ],
                                                      ),

                                                    ],
                                                  ),
                                                ),
                                              );
                                            },
                                          ): DataTable(
                                              showCheckboxColumn: false,
                                              headingRowHeight: 40,
                                              columnSpacing: 35,
                                              headingRowColor:
                                              MaterialStateProperty.all(
                                                  Color(0xFFF7F7F7)),
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
                                                          children: [
                                                            Text(column, style: TextStyles.subhead),
                                                            IconButton(
                                                              icon:
                                                              _sortOrder[columns.indexOf(column)] == 'asc'
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
                                                                detail.contactPerson!,
                                                                style: TextStyles.body,
                                                              ),
                                                            ),
                                                          ),
                                                          DataCell(
                                                            Container(
                                                              width: columnWidths[2],
                                                              child: Text(
                                                                detail.orderDate!,
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
                                                          context.go('/Order_View', extra: {
                                                            'orderId': detail.orderId,
                                                          });
                                                        });
                                                  })),
                                        ),
                                      ),
                                    }
                                  } else ...{
                                    if(filteredData.isEmpty)...{
                                      Column(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          Container(
                                            // height: 600,
                                            width: width,
                                            decoration: BoxDecoration(
                                                color: Color(0xFFF7F7F7),
                                                border: Border.symmetric(
                                                    horizontal: BorderSide(
                                                        color: Colors.grey,
                                                        width: 0.5))),
                                            child: DataTable(
                                                headingRowColor:
                                                MaterialStateProperty.all(
                                                    Color(0xFFF7F7F7)),
                                                showCheckboxColumn: false,
                                                headingRowHeight: 40,
                                                columnSpacing: 50,
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
                                                rows: const []),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                top: 5, left: 130, right: 150),
                                            child: CustomDatafound(),
                                          ),
                                        ],
                                      ),
                                    }else...{
                                      Column(children: [
                                        SizedBox(
                                          height: 600,
                                          width: width,
                                          child: SingleChildScrollView(
                                            scrollDirection: Axis.vertical,
                                            child: DataTable(
                                                headingRowColor:
                                                MaterialStateProperty.all(
                                                    Color(0xFFF7F7F7)),
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
                                                            children: [
                                                              Text(column, style: TextStyles.subhead),
                                                              IconButton(
                                                                icon:
                                                                _sortOrder[columns.indexOf(column)] == 'asc'
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
                                                                  detail.contactPerson!,
                                                                  style: TextStyles.body,
                                                                ),
                                                              ),
                                                            ),
                                                            DataCell(
                                                              Container(
                                                                width: columnWidths[2],
                                                                child: Text(
                                                                  detail.orderDate!,
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
                                                            context.go('/Order_View', extra: {
                                                              'orderId': detail.orderId,
                                                            });
                                                          });
                                                    })),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 30),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            children: [
                                              PaginationControls(
                                                currentPage: currentPage,
                                                totalPages: filteredProducts.length >
                                                    itemsPerPage
                                                    ? totalPages
                                                    : 1,
                                                onPreviousPage: _goToPreviousPage,
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
                          //buildDataTable2(),
                          // Padding(
                          //   padding: const EdgeInsets.all(15.0),
                          //   child: Container(
                          //     padding: EdgeInsets.all(20),
                          //     decoration: BoxDecoration(
                          //       color: Colors.orange,
                          //       border: Border.all(color: Colors.grey),
                          //       borderRadius: BorderRadius.circular(12),
                          //     ),
                          //     height: 500,
                          //     child: Column(
                          //       children: [
                          //         SizedBox(
                          //           width: double.infinity,
                          //           child: DataTable(
                          //             // horizontalMargin: 5,
                          //             headingRowColor:
                          //             MaterialStateProperty.all(Colors.grey[300]),
                          //             columns: const [
                          //               DataColumn(
                          //                   label: Text('ID',
                          //                       style: TextStyle(
                          //                           fontWeight: FontWeight
                          //                               .bold))),
                          //               DataColumn(
                          //                   label: Text('Name',
                          //                       style: TextStyle(
                          //                           fontWeight: FontWeight
                          //                               .bold))),
                          //               DataColumn(
                          //                   label: Text('Age',
                          //                       style: TextStyle(
                          //                           fontWeight: FontWeight
                          //                               .bold))),
                          //               DataColumn(
                          //                   label: Text('Country',
                          //                       style: TextStyle(
                          //                           fontWeight: FontWeight
                          //                               .bold))),
                          //               DataColumn(
                          //                   label: Text('Department',
                          //                       style: TextStyle(
                          //                           fontWeight: FontWeight
                          //                               .bold))),
                          //               DataColumn(
                          //                   label: Text('Salary',
                          //                       style: TextStyle(
                          //                           fontWeight: FontWeight
                          //                               .bold))),
                          //               DataColumn(
                          //                   label: Text('Status',
                          //                       style: TextStyle(
                          //                           fontWeight: FontWeight
                          //                               .bold))),
                          //             ],
                          //             rows: dummyData.map((data) {
                          //               return DataRow(
                          //                 cells: [
                          //                   DataCell(Text(data['ID'].toString())),
                          //                   DataCell(Text(data['Name'])),
                          //                   DataCell(
                          //                       Text(data['Age'].toString())),
                          //                   DataCell(Text(data['Country'])),
                          //                   DataCell(Text(data['Department'])),
                          //                   DataCell(Text(data['Salary'])),
                          //                   DataCell(Text(data['Status'])),
                          //                 ],
                          //               );
                          //             }).toList(),
                          //           ),
                          //         )
                          //         // Text('Recent Files',style: TextStyle(color: Colors.grey),)
                          //       ],
                          //     ),
                          //   ),
                          // ),
                        ],
                      ))
                ],
              ),

              //         Row(
              //           crossAxisAlignment: CrossAxisAlignment.start,
              //           children: [
              //             Expanded(
              //                 child: Column(
              //                   children: [
              //                     Row(
              //                       children: [
              // Text('My file'),
              //
              //                       ],
              //                     )
              //                   ],
              //                 )),
              //             SizedBox(
              //               height: 60,
              //             ),
              //
              //
              //
              //           ],
              //         ),
            ],
          )),
    );
  }

}
