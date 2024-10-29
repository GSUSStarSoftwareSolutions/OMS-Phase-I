import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'dart:html';
import 'package:btb/admin/Api%20name.dart';
import 'package:btb/widgets/productclass.dart' as ord;
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import '../widgets/confirmdialog.dart';
import '../widgets/custom loading.dart';
import '../widgets/no datafound.dart';
import '../widgets/pagination.dart';
import '../Order Module/firstpage.dart';
import '../widgets/productdata.dart';


void main() => runApp(OrderList());

class OrderList extends StatefulWidget {
  const OrderList({super.key});


  @override
  State<OrderList> createState() => _OrderListState();
}

class _OrderListState extends State<OrderList> {
  ord.Product? _selectedProduct;
  late ProductData productData;
  bool isHomeSelected = false;
  bool isOrdersSelected = false;
  Timer? _searchDebounceTimer;
  Map<String, dynamic> PaymentMap = {};
  String _searchText = '';
  String _category = '';

  late TextEditingController _dateController;
  String _subCategory = '';
  int startIndex = 0;
  List<ord.Product> filteredProducts = [];
  String? dropdownValue1 = 'Delivery Status';
  String token = window.sessionStorage["token"] ?? " ";
  String? dropdownValue2 = 'Select Year';
  bool _hasShownPopup = false;
  List<detail>filteredData1 = [];
  List<detail>filteredData= [];
  List<detail> productList = [];

  List<String> _sortOrder = List.generate(6, (index) => 'asc');
  List<String> columns = ['Order ID','Created Date','Delivery Date','Total Amount' ,'Delivery Status','Payment'];
  List<double> columnWidths = [100,130, 130, 139, 160, 135,];
  List<bool> columnSortState = [true, true, true,true,true,true];


  void _onSearchTextChanged(String text) {
    if (_searchDebounceTimer != null) {
      _searchDebounceTimer!.cancel(); // Cancel the previous timer
    }
    _searchDebounceTimer = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        _searchText = text;
        _filterAndPaginateProducts();
      });
    });
  }
  final ScrollController _scrollController = ScrollController();
  int currentPage = 1;
  int itemsPerPage = 10;
  bool _isRowHovered = false;
  int totalItems = 0;
  int totalPages = 0;
  bool _loading = false;
  String status='';
  String selectDate='';
  bool isLoading = false;
  //List<ord.Product> productList = [];

// Example method for fetching products
  Future<void> fetchProducts(int page, int itemsPerPage) async {
    if (isLoading) return;
    if (!mounted) return;
    setState(() {
      isLoading = true;
    });
    try {
      final response = await http.get(
        Uri.parse(
          '$apicall/dashboard/get_all_dashboard?page=$page&limit=$itemsPerPage', // Changed limit to 10
        ),
        headers: {
          "Content-type": "application/json",
          "Authorization": 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        print('json data');
        print(jsonData);
        List<detail> products = [];
        if (jsonData is List) {
          products = jsonData.map((item) => detail.fromJson(item)).toList();
        } else if (jsonData is Map && jsonData.containsKey('body')) {
          final body = jsonData['body'];
          if (body != null) {
            products = (body as List).map((item) => detail.fromJson(item)).toList();
            totalItems = jsonData['totalItems'] ?? 0; // Get the total number of items
          } else {
            print('Body is null');
          }
        } else {
          print('Invalid JSON data');
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
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Error decoding JSON: $e');
      if (mounted) {
        if (context.findAncestorWidgetOfExactType<Scaffold>() != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        } else {
          print('No Scaffold ancestor found');
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
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
      _buildMenuItem('Home', Icons.dashboard, Colors.blueAccent, '/Home'),
      _buildMenuItem('Customer', Icons.account_circle, Colors.blue[900]!, '/Customer'),
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


  void _updateSearch(String searchText) {
    setState(() {
      _searchText = searchText;
      currentPage = 1;  // Reset to first page when searching
      _filterAndPaginateProducts();
      // _clearSearch();
    });
  }

  void _goToPreviousPage() {
    print("previos");

    if (currentPage > 1) {
      if(filteredData1.length > itemsPerPage) {
        setState(() {
          currentPage--;
          //  fetchProducts(currentPage, itemsPerPage);
        });
      }
      //fetchProducts(page: currentPage);
      // _filterAndPaginateProducts();
    }
  }

  void _goToNextPage() {
    print('nextpage');

    if (currentPage < totalPages) {
      if(filteredData1.length > currentPage * itemsPerPage) {
        setState(() {
          currentPage++;
        });
      }
    }
  }


  void showConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return
          AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            contentPadding: EdgeInsets.zero,
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Close Button
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon: Icon(Icons.close, color: Colors.blue),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // Warning Icon
                      Icon(Icons.warning, color: Colors.orange, size: 50),
                      SizedBox(height: 16),
                      // Confirmation Message
                      Text(
                        'Are You Sure',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      SizedBox(height: 20),
                      // Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                              'Yes',
                              style: TextStyle(
                                color: Colors.blue,
                              ),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              // Handle No action
                              Navigator.of(context).pop();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              side: BorderSide(color: Colors.red),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                            child: Text(
                              'No',
                              style: TextStyle(
                                color: Colors.red,
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
  void initState() {
    super.initState();
    fetchOrders();
    fetchProducts(currentPage, itemsPerPage);
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
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        print('json data1');
        print(jsonData);
        if (jsonData == null) {
          print('JSON data is null');
          return;
        }
        // List<detail> filteredData = [];
        if (jsonData is List) {
          filteredData = jsonData.map((item) => detail.fromJson(item)).toList();
        } else if (jsonData is Map && jsonData.containsKey('body')) {
          final body = jsonData['body'];
          if (body != null) {
            filteredData = (body as List).map((item) => detail.fromJson(item)).toList();
          } else {
            print('Body is null');
          }
        } else {
          print('Invalid JSON data');
        }

        if (mounted) {
          setState(() {
            filteredData = filteredData; // Update the filteredData list
          });
        }
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Error decoding JSON: $e');
      if (mounted) {
        if (context.findAncestorWidgetOfExactType<Scaffold>() != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        } else {
          print('No Scaffold ancestor found');
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
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
                child:
                AccountMenu(),
              ),
            ],
          ),
          body: LayoutBuilder(builder: (context, constraints) {
            double maxHeight = constraints.maxHeight;
            double maxWidth = constraints.maxWidth;
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
                  padding: const EdgeInsets.only( left: 192),
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 10), // Space above/below the border
                    width: 1, // Border height
                    color: Colors.grey, // Border color
                  ),
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 203),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      color: Color(0xFFFFFDFF),
                      height: 50,
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(
                                Icons.arrow_back), // Back button icon
                            onPressed: () {
                              context.go(
                                  '/Home');
                              // Navigator.of(context).push(PageRouteBuilder(
                              //   pageBuilder: (context, animation,
                              //       secondaryAnimation) =>
                              //   const ProductPage(product: null),
                              // ));
                            },
                          ),
                          const Padding(
                            padding: EdgeInsets.only(left: 20),
                            child: Text(
                              'Order Completed',
                              style: TextStyle(
                                fontSize: 20,
                                //fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const Spacer(),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 33, left: 202),
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                        vertical: 16), // Space above/below the border
                    height: 1, // Border height
                    color: Colors.grey, // Border color
                  ),
                ),
                Padding(
                  padding:  EdgeInsets.only(left: 300, top: 120,right: maxWidth * 0.062,bottom: 15),
                  child: Container(
                    width: maxWidth,
                    height: 700,
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
                        //  height: 1300,
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
                            SizedBox(),
                            Padding(
                              padding: const EdgeInsets.only(right:30),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  PaginationControls(
                                    currentPage: currentPage,
                                    totalPages:  (filteredData1.where((product) => product.deliveryStatus == 'Delivered').length / itemsPerPage).ceil(),
                                    //totalPages: filteredData1.where((e) => e.deliveryStatus == 'Delivered').length > itemsPerPage ? totalPages : 1,
                                 //  totalPages: filteredData1.length > itemsPerPage ? totalPages : 1,//totalPages//totalPages,
                                    onPreviousPage: _goToPreviousPage,
                                    onNextPage: _goToNextPage,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  ),
                ),
                const SizedBox(height: 50,),
              ],
            );
          }
          )
      ),
    );
  }


  Widget buildSearchField() {
    double maxWidth1 = MediaQuery.of(context).size.width;
    return LayoutBuilder(builder: (context, constraints) {
      return ConstrainedBox(
        constraints: BoxConstraints(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.only(top: 20, left: 30),
                  child: Container(
                    width: maxWidth1 * 0.2, // reduced width
                    height: 35, // reduced height
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(2),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: TextFormField(
                      decoration: const InputDecoration(
                        hintText: 'Search by Order ID',
                        hintStyle: TextStyle(color: Colors.grey,fontSize: 13),
                        contentPadding:
                        EdgeInsets.only(bottom: 20,left: 10) ,// adjusted padding
                        border: InputBorder.none,
                        suffixIcon: Padding(
                          padding: EdgeInsets.only(right: 2),
                          child: Icon(Icons.search_outlined, color: Colors.indigo,size: 20,),
                        ),
                      ),
                      onChanged: _updateSearch,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //  const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.only(left: 30),
                      child: Container(
                        width: maxWidth1 * 0.1, // reduced width
                        height: 35, // reduced height
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(2),
                          border: Border.all(color: Colors.grey),
                        ),
                        child: DropdownButtonFormField2<String>(
                          decoration: const InputDecoration(
                            contentPadding:
                            EdgeInsets.only(bottom: 15,left: 9), // adjusted padding
                            border: InputBorder.none,
                            filled: true,
                            fillColor: Colors.white,
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
                            'Delivery Status',
                            'Not Started',
                            'In Progress',
                            'Delivered'
                          ]
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                value,
                                style: TextStyle(fontSize: 13,color: value == 'Delivery Status' ? Colors.grey : Colors.black,),
                              ),
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
                            width: maxWidth1 * 0.1, // Dropdown width
                            offset:  const Offset(0, -10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                // const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        width: maxWidth1 * 0.095, // reduced width
                        height: 35, // reduced height
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(2),
                          border: Border.all(color: Colors.grey),
                        ),
                        child: DropdownButtonFormField2<String>(
                          decoration: const InputDecoration(
                            contentPadding:
                            EdgeInsets.only(bottom: 15,left: 10), // adjusted padding
                            border: InputBorder.none,
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          value: dropdownValue2,
                          onChanged: (String? newValue) {
                            setState(() {
                              selectDate = newValue ?? '';
                              dropdownValue2 = newValue;
                              _filterAndPaginateProducts();
                            });
                          },
                          items: <String>['Select Year', '2023', '2024', '2025']
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                value,
                                style: TextStyle(fontSize: 13, color: value == 'Select Year' ? Colors.grey : Colors.black,),
                              ),
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
                            width: maxWidth1 * 0.095, // Dropdown width
                            offset:  const Offset(0, -10),
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

    if (filteredData1.isEmpty) {
      double right = MediaQuery.of(context).size.width;
      return Column(
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
                  DataColumn(label: Container(
                      child: Text('Order ID',style:TextStyle(
                          color: Colors.indigo[900],
                          fontSize: 13,
                          fontWeight: FontWeight.bold
                      ),))),
                  DataColumn(label: Container(
                      child: Text('Created Date',style:TextStyle(
                          color: Colors.indigo[900],
                          fontSize: 13,
                          fontWeight: FontWeight.bold
                      ),))),
                  DataColumn(label: Container(child: Text(
                    'Delivery Date',style:TextStyle(
                      color: Colors.indigo[900],
                      fontSize: 13,
                      fontWeight: FontWeight.bold
                  ),))),
                  DataColumn(label: Container(child: Text(
                    'Total Amount',style:TextStyle(
                      color: Colors.indigo[900],
                      fontSize: 13,
                      fontWeight: FontWeight.bold
                  ),))),
                  DataColumn(label: Container(child: Text(
                    'Delivery Status',style:  TextStyle(

                      color: Colors.indigo[900],
                      fontSize: 13,
                      fontWeight: FontWeight.bold
                  ),))),
                  DataColumn(label: Container(child: Text(
                    'Payment',style:TextStyle(
                      color: Colors.indigo[900],
                      fontSize: 13,
                      fontWeight: FontWeight.bold
                  ),))),
                ],
                rows: [],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 80,left: 130,right: 150),
            child: CustomDatafound(),
          ),
        ],
      );


    }


    void _sortProducts(int columnIndex, String sortDirection) {
      if (sortDirection == 'asc') {
        filteredData1.sort((a, b) {
          if (columnIndex == 0) {
            return a.orderId!.compareTo(b.orderId!);
          } else if (columnIndex == 1) {
            return a.createdDate!.compareTo(b.createdDate!);
          } else if (columnIndex == 2) {
            return a.deliveredDate!.compareTo(b.deliveredDate!);
          } else if (columnIndex == 3) {
            return a.totalAmount!.compareTo(b.totalAmount!);
          } else if (columnIndex == 4) {
            return a.deliveryStatus.compareTo(b.deliveryStatus);
          }
          else if (columnIndex == 5) {
            return a.paymentStatus!.toLowerCase().compareTo(b.paymentStatus!.toLowerCase());
          } else {
            return 0;
          }
        });
      } else {
        filteredData1.sort((a, b) {
          if (columnIndex == 0) {
            return b.orderId!.compareTo(a.orderId!); // Reverse the comparison
          } else if (columnIndex == 1) {
            return b.createdDate!.compareTo(a.createdDate!); // Reverse the comparison
          } else if (columnIndex == 2) {
            return b.deliveredDate!.compareTo(a.deliveredDate!); // Reverse the comparison
          } else if (columnIndex == 3) {
            return b.totalAmount!.compareTo(a.totalAmount!); // Reverse the comparison
          } else if (columnIndex == 4) {
            return b.deliveryStatus.compareTo(a.deliveryStatus); // Reverse the comparison
          }
          else if (columnIndex == 5) {
            return b.paymentStatus!.toLowerCase().compareTo(a.paymentStatus!.toLowerCase()); // Reverse the comparison
          }else {
            return 0;
          }
        });
      }
      setState(() {});
    }

    return LayoutBuilder(builder: (context, constraints){
      // double padding = constraints.maxWidth * 0.065;
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
                                //  if (columns.indexOf(column) > 0)
                                IconButton(
                                  icon: _sortOrder[columns.indexOf(column)] == 'asc'
                                      ? Icon(Icons.arrow_circle_up, size: 20,)
                                      : Icon(Icons.arrow_circle_down, size: 20,),
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
                                              color: Colors.black,

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
                    math.min(itemsPerPage, filteredData1.where((product) => product.deliveryStatus == 'Delivered').length - (currentPage - 1) * itemsPerPage),(index){
                  // final detail1 = filteredData.skip((currentPage - 1) * itemsPerPage).elementAt(index);
                  final detail = filteredData1.where((product) => product.deliveryStatus == 'Delivered').skip((currentPage - 1) * itemsPerPage).elementAt(index);
                  final isSelected = _selectedProduct == detail;
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
                            Text(detail.orderId.toString(), style: TextStyle(
                              //fontSize: 16,
                              color:isSelected ? Colors.deepOrange[200] : const Color(0xFFFFB315) ,),)),
                        DataCell(
                            Text(detail.createdDate!,style:
                            TextStyle(
                              // fontSize: 16,
                                color: Colors.grey),)),
                        DataCell(
                          Text(detail.deliveredDate!,style: TextStyle(
                            // fontSize: 16,
                              color: Colors.grey)),
                        ),
                        DataCell(
                          Text(detail.total.toString(),style: TextStyle(
                            //fontSize: 16,
                              color: Colors.grey)),
                        ),
                        DataCell(
                          Text(detail.deliveryStatus.toString(),style: TextStyle(
                            // fontSize: 16,
                                            color: detail.deliveryStatus == "In Progress" ? Colors.orange : detail.deliveryStatus == "Delivered" ? Colors.green : Colors.grey,
                          )),
                        ),
                        DataCell(
                          Text(detail.paymentStatus.toString(),style: TextStyle(
                            //fontSize: 16,
                              color: Colors.grey)),
                        ),

                      ],
                      onSelectChanged: (selected){
                        if(selected != null && selected){
                          print('what is this');
                          print(detail);
                          print('filtereddata');
                          print(filteredData);
                          print('roduct');
                          print(productList);
                          final orderId = detail.orderId; // Capture the orderId of the selected row
                          final detail1 = filteredData.firstWhere((element) => element.orderId == orderId);
                          //final detail1 = filteredData.skip((currentPage - 1) * itemsPerPage).elementAt(index);
                          //final detail = filteredData[(currentPage - 1) * itemsPerPage + index];

                          if (filteredData.length <= 9) {
                            PaymentMap = {
                              'paymentId': detail.paymentDate,
                              'paymentmode': detail.paymentMode,
                              'paymentStatus': detail.paymentStatus,
                              'paymentdate': detail.paymentDate,
                              'paidamount': detail.paidAmount,
                            };
                            //fetchOrders();
                            context.go('/Order_Placed_List', extra: {
                              'product': detail1,
                              'arrow': 'order_complete',
                              'item': [], // pass an empty list of maps
                              'body': {},
                              'status': detail.deliveryStatus,
                              'paymentStatus': PaymentMap,
                              // 'status': detail.deliveryStatus,
                              'itemsList': [], // pass an empty list of maps
                              'orderDetails': filteredData.map((detail) => OrderDetail(
                                orderId: detail.orderId,
                                orderDate: detail.orderDate, items: [],
                                deliveryStatus: detail.deliveryStatus,
                                // Add other fields as needed
                              )).toList(),

                            });
                          } else {

                            PaymentMap = {
                              'paymentId': detail.paymentDate,
                              'paymentmode': detail.paymentMode,
                              'paymentStatus': detail.paymentStatus,
                              'paymentdate': detail.paymentDate,
                              'paidamount': detail.paidAmount,
                            };
                            context.go('/Order_Placed_List', extra: {
                              'product': detail1,
                              'item': [], // pass an empty list of maps
                              'arrow': 'order_complete',
                              'status': detail.deliveryStatus,
                              'paymentStatus': PaymentMap,
                              'body': {},
                              'itemsList': [], // pass an empty list of maps
                              'orderDetails': filteredData.map((detail) => OrderDetail(
                                orderId: detail.orderId,
                                orderDate: detail.orderDate, items: [],
                                deliveryStatus: detail.deliveryStatus,
                                // Add other fields as needed
                              )).toList(),
                            });
                          }
                        }
                      }
                  );
                })
            ),
          ),
        ],
      );
    });
  }


  void _filterAndPaginateProducts() {
    filteredData1 = productList.where((product) {
      final matchesSearchText= product.orderId!.toLowerCase().contains(_searchText.toLowerCase());
      print('-----');
      print(product.orderDate);
      String orderYear = '';
      if (product.deliveredDate!.contains('/')) {
        final dateParts = product.deliveredDate!.split('/');
        if (dateParts.length == 3) {
          orderYear = dateParts[2]; // Extract the year
        }
      }
      // final orderYear = element.orderDate.substring(5,9);
      if (status.isEmpty && selectDate.isEmpty) {
        return matchesSearchText; // Include all products that match the search text
      }
      if(status == 'Delivery Status' && selectDate == 'Select Year'){
        return matchesSearchText;
      }
      if(status == 'Delivery Status' &&  selectDate.isEmpty)
      {
        return matchesSearchText;
      }
      if(selectDate == 'Select Year' &&  status.isEmpty)
      {
        return matchesSearchText;
      }
      if (status == 'Delivery Status' && selectDate.isNotEmpty) {
        return matchesSearchText && orderYear == selectDate; // Include all products
      }
      if (status.isNotEmpty && selectDate == 'Select Year') {
        return matchesSearchText && product.deliveryStatus == status;// Include all products
      }
      if (status.isEmpty && selectDate.isNotEmpty) {
        return matchesSearchText && orderYear == selectDate; // Include all products
      }

      if (status.isNotEmpty && selectDate.isEmpty) {
        return matchesSearchText && product.deliveryStatus == status;// Include all products
      }
      return matchesSearchText &&
          (product.deliveryStatus == status && orderYear == selectDate);
      //  return false;
    }).toList();
    totalPages = (filteredData1.length / itemsPerPage).ceil();
    //totalPages = (productList.length / itemsPerPage).ceil();
    setState(() {
      currentPage = 1;
    });
  }

}



