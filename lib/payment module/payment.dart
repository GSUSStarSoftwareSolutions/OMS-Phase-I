import 'dart:async';
import 'dart:convert';
import 'dart:html';
import 'dart:math'as math;
import 'package:adaptive_scrollbar/adaptive_scrollbar.dart';
import 'package:btb/admin/Api%20name.dart';
import 'package:btb/widgets/confirmdialog.dart';
import 'package:btb/widgets/pagination.dart';
import 'package:btb/widgets/productclass.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import '../../widgets/custom loading.dart';
import 'package:btb/Order%20Module/firstpage.dart';
import '../../widgets/no datafound.dart';


void main(){
  runApp(const PaymentList());
}


class PaymentList extends StatefulWidget {
  const PaymentList({super.key});
  @override
  State<PaymentList> createState() => _PaymentListState();
}

class _PaymentListState extends State<PaymentList> {
  Timer? _searchDebounceTimer;
  String _searchText = '';
  bool isOrdersSelected = false;
  bool _loading = false;
  detail? _selectedProduct;
  //String? role = window.sessionStorage["role"];
  DateTime? _selectedDate;
  late TextEditingController _dateController;
  final ScrollController horizontalScroll = ScrollController();
  int startIndex = 0;
  List<Product> filteredProducts = [];
  int currentPage = 1;
  String? dropdownValue1 = 'Status';
  late Future<List<detail>> futureOrders;
  List<detail> productList = [];
  final ScrollController _scrollController = ScrollController();
  List<dynamic> detailJson = [];
  String searchQuery = '';
  List<detail>filteredData = [];
  String status = '';
  Map<String, dynamic> _selectedProductMap = {};
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
  String selectDate = '';

  List<String> _sortOrder = List.generate(6, (index) => 'asc');
  List<String> columns = ['','Order ID','Delivery Date','Credit Amount','Payment Status' ,'Amount'];
  List<double> columnWidths = [50,100, 130, 139, 150, 135,];
  List<bool> columnSortState = [true, true, true,true,true,true];


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


  int itemsPerPage = 10;
  int totalItems = 0;
  int totalPages = 0;
  bool isLoading = false;


  List<Widget> _buildMenuItems(BuildContext context) {
    return [
      _buildMenuItem('Home', Icons.home_outlined, Colors.blue[900]!, '/Home'),
      _buildMenuItem('Customer', Icons.account_circle_outlined, Colors.blue[900]!, '/Customer'),
      _buildMenuItem('Products', Icons.image_outlined, Colors.blue[900]!, '/Product_List'),
      _buildMenuItem('Orders', Icons.warehouse_outlined, Colors.blue[900]!, '/Order_List'),
      _buildMenuItem('Delivery', Icons.fire_truck_outlined, Colors.blue[900]!, '/Delivery_List'),
      _buildMenuItem('Invoice', Icons.document_scanner_outlined, Colors.blue[900]!, '/Invoice'),

      Container(
          decoration: BoxDecoration(
            color: Colors.blue[800],
            // border: Border(  left: BorderSide(    color: Colors.blue,    width: 5.0,  ),),
            // color: Color.fromRGBO(224, 59, 48, 1.0),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8), // Radius for top-left corner
              topRight: Radius.circular(8), // No radius for top-right corner
              bottomLeft: Radius.circular(8), // Radius for bottom-left corner
              bottomRight: Radius.circular(8), // No radius for bottom-right corner
            ),
          ),child: _buildMenuItem('Payment', Icons.payment_rounded, Colors.white, '/Payment_List')),
      _buildMenuItem('Return', Icons.keyboard_return, Colors.blue[900]!, '/Return_List'),
      _buildMenuItem('Reports', Icons.insert_chart_outlined, Colors.blue[900]!, '/Report_List'),
    ];
  }

  Widget _buildMenuItem(String title, IconData icon, Color iconColor, String route) {
    iconColor = _isHovered[title] == true ? Colors.blue : Colors.black87;
    title == 'Payment'? _isHovered[title] = false :  _isHovered[title] = false;
    title == 'Payment'? iconColor = Colors.white : Colors.black;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered[title] = true),
      onExit: (_) => setState(() => _isHovered[title] = false),
      child: GestureDetector(
        onTap: () {
          context.go(route);
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 5,right: 20),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: _isHovered[title]! ? Colors.black12 : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.only(left: 5,top: 5),
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
      ),
    );
  }





  Future<void> fetchProducts() async {

    if (isLoading) return;
    if (!mounted) return;
    setState(() {
      isLoading = true;
    });
    try {
      final response = await http.get(
        Uri.parse(
          '$apicall/payment_master/get_all_paymentmaster', // Changed limit to 10
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
        if (jsonData != null) {
          if (jsonData is List) {
            products = jsonData.map((item) => detail.fromJson(item)).toList();
          } else if (jsonData is Map && jsonData.containsKey('body')) {
            products = (jsonData['body'] as List).map((item) => detail.fromJson(item)).toList();
            totalItems = jsonData['totalItems'] ?? 0; // Get the total number of items
          }

          if(mounted){
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
      if(mounted){
        setState(() {
          isLoading = false;
        });
      }

    }
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
      if(filteredData.length > itemsPerPage) {
        setState(() {
          currentPage--;
        });
      }

    }
  }

  void _goToNextPage() {
    print('nextpage');

    if (currentPage < totalPages) {
      if(filteredData.length > currentPage * itemsPerPage) {
        setState(() {
          currentPage++;
        });
      }
      //_filterAndPaginateProducts();
    }
  }

  @override
  void initState() {
    super.initState();
    _dateController = TextEditingController();
    fetchProducts();
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
              child: AccountMenu(),

            ),
          ],
        ),
        body: LayoutBuilder(
            builder: (context,constraints) {
              double maxWidth = constraints.maxWidth;
              return
                Stack(
                  children: [
                    if(constraints.maxHeight <= 500)...{
                      SingleChildScrollView(
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Container(
                            width: 200,
                            color: const Color(0xFFF7F6FA),
                            padding: const EdgeInsets.only(left: 15, top: 10,right: 15),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: _buildMenuItems(context),
                            ),
                          ),
                        ),
                      )

                    }
                    else...{
                      Align(
                        alignment: Alignment.topLeft,
                        child: Container(
                          width: 200,
                          color: const Color(0xFFF7F6FA),
                          padding: const EdgeInsets.only(left: 15, top: 10,right: 15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: _buildMenuItems(context),
                          ),
                        ),
                      ),
                    },
                    Padding(
                      padding: const EdgeInsets.only(left: 200,top: 0),
                      child: Container(
                        width: 1, // Set the width to 1 for a vertical line
                        height: 1400, // Set the height to your liking
                        decoration:const  BoxDecoration(
                          border: Border(left: BorderSide(width: 1, color: Colors.grey)),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 0,
                      left: 201,
                      right: 0,
                      bottom: 0,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              color: Colors.white,
                              height: 50,
                              child: Row(
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.only(left: 20),
                                    child: Text(
                                      'Payment List',
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  const Spacer(),


                                  Align(
                                    alignment: Alignment.topRight,
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          top: 10, right: 80,bottom: 10),

                                      child: SizedBox(
                                        width: 150,
                                        child:
                                         // _selectedProductMap['paymentStatus'] == 'cleared'? Container():
                                        OutlinedButton(
                                            onPressed: () {
                                              print(_selectedProduct);
                                              print('hi');
                                              print(_selectedProductMap);
                                              if(_selectedProductMap['paymentStatus']== 'partial payment' || _selectedProductMap['paymentStatus']== 'cleared' || _selectedProductMap['paymentStatus'] == '-' ||  _selectedProductMap['paymentStatus'] == 'open')
                                              {
                                               print(_selectedProductMap['orderId']) ;
                                             //  String orderId = '';
                                               //_selectedProductMap['orderId'] = orderId;
                                                context.go('/Pay', extra: {
                                                  'productMap': _selectedProductMap,
                                                });
                                               //  Navigator.push(
                                               //    context,
                                               //    PageRouteBuilder(
                                               //      pageBuilder:
                                               //          (context, animation, secondaryAnimation) =>
                                               //          Payment(productMap: _selectedProductMap,),
                                               //      transitionDuration:
                                               //      const Duration(milliseconds: 50),
                                               //      transitionsBuilder: (context, animation,
                                               //          secondaryAnimation, child) {
                                               //        return FadeTransition(
                                               //          opacity: animation,
                                               //          child: child,
                                               //        );
                                               //      },
                                               //    ),
                                               //  );
                                              }


                                            },
                                            style: OutlinedButton.styleFrom(
                                              backgroundColor: Colors.blue[800],
                                              // Button background color
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                BorderRadius.circular(
                                                    5), // Rounded corners
                                              ),
                                              side: BorderSide.none, // No outline
                                              padding: EdgeInsets.zero,
                                            ),
                                            child:  Row(
                                              mainAxisSize: MainAxisSize.min,
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets.only(left: 15),
                                                  child: Text(
                                                    _selectedProductMap['paymentStatus'] == 'cleared' ?
                                                    'Go to History' : 'Go to Payment',
                                                    style: TextStyle(
                                                      fontSize: 13,
                                                      fontWeight: FontWeight.w100,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                                IconButton(onPressed: (){}, icon: Icon(Icons.arrow_forward,color: Colors.white,size: 15,))
                                              ],
                                            )
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                    Container(
                      margin: const EdgeInsets.only(left: 0),
                      // Space above/below the border
                      height: 1,
                      // width: 10  00,
                      width: constraints.maxWidth,
                      // Border height
                      color: Colors.grey, // Border color
                    ),
                          if(constraints.maxWidth >= 1310)...{
                            Expanded(
                                child: SingleChildScrollView(
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 30,
                                                  top: 50,
                                                  right: 30,
                                                  bottom: 15),
                                              child: Container(
                                                height: 755,
                                                width: maxWidth * 0.8,
                                                decoration:BoxDecoration(
                                                  //   border: Border.all(color: Colors.grey),
                                                  color: Colors.white,
                                                  borderRadius: BorderRadius.circular(8),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black.withOpacity(0.3), // Soft grey shadow
                                                      spreadRadius: 3,
                                                      blurRadius: 3,
                                                      offset: const Offset(0, 3),
                                                    ),
                                                  ],
                                                ),
                                                child: SizedBox(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                    children: [
                                                      buildSearchField(),
                                                      const SizedBox(height: 10),
                                                      Expanded(
                                                        child: Scrollbar(
                                                          controller:
                                                          _scrollController,
                                                          thickness: 6,
                                                          thumbVisibility: true,
                                                          child:
                                                          SingleChildScrollView(
                                                            controller:
                                                            _scrollController,
                                                            scrollDirection:
                                                            Axis.horizontal,
                                                            child:
                                                            buildDataTable(),
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        height: 1,
                                                      ),
                                                      Padding(
                                                        padding:
                                                        const EdgeInsets.only(
                                                            right: 30),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                          MainAxisAlignment.end,
                                                          children: [
                                                            PaginationControls(
                                                              currentPage:
                                                              currentPage,
                                                              totalPages: filteredData
                                                                  .length >
                                                                  itemsPerPage
                                                                  ? totalPages
                                                                  : 1,
                                                              onPreviousPage:
                                                              _goToPreviousPage,
                                                              onNextPage:
                                                              _goToNextPage,
                                                              // onLastPage: _goToLastPage,
                                                            ),
                                                          ],
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              )),
                                        ],
                                      ),
                                    ],
                                  ),
                                )),
                          }
                          else...{
                            Expanded(
                                child: AdaptiveScrollbar(

                                  position: ScrollbarPosition.bottom,controller: horizontalScroll,
                                  child: SingleChildScrollView(
                                    controller: horizontalScroll,
                                    scrollDirection: Axis.horizontal,
                                    child: SingleChildScrollView(
                                      child: Column(
                                        children: [
                                          Row(
                                            children: [
                                              Padding(
                                                  padding: const EdgeInsets.only(
                                                      left: 30,
                                                      top: 50,
                                                      right: 30,
                                                      bottom: 15),
                                                  child: Container(
                                                    height: 755,
                                                    width: 1100,
                                                    decoration:BoxDecoration(
                                                      //   border: Border.all(color: Colors.grey),
                                                      color: Colors.white,
                                                      borderRadius: BorderRadius.circular(8),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors.black.withOpacity(0.3), // Soft grey shadow
                                                          spreadRadius: 3,
                                                          blurRadius: 3,
                                                          offset: const Offset(0, 3),
                                                        ),
                                                      ],
                                                    ),
                                                    child: SizedBox(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                        CrossAxisAlignment.start,
                                                        children: [
                                                          buildSearchField(),
                                                          const SizedBox(height: 10),
                                                          Expanded(
                                                            child: Scrollbar(
                                                              controller:
                                                              _scrollController,
                                                              thickness: 6,
                                                              thumbVisibility: true,
                                                              child:
                                                              SingleChildScrollView(
                                                                controller:
                                                                _scrollController,
                                                                scrollDirection:
                                                                Axis.horizontal,
                                                                child: buildDataTable2(),
                                                              ),
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            height: 1,
                                                          ),
                                                          Padding(
                                                            padding:
                                                            const EdgeInsets.only(
                                                                right: 30),
                                                            child: Row(
                                                              mainAxisAlignment:
                                                              MainAxisAlignment.end,
                                                              children: [
                                                                PaginationControls(
                                                                  currentPage:
                                                                  currentPage,
                                                                  totalPages: filteredData
                                                                      .length >
                                                                      itemsPerPage
                                                                      ? totalPages
                                                                      : 1,
                                                                  onPreviousPage:
                                                                  _goToPreviousPage,
                                                                  onNextPage:
                                                                  _goToNextPage,
                                                                  // onLastPage: _goToLastPage,
                                                                ),
                                                              ],
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  )),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                )),
                          }
                        ],
                      ),
                    ),
                  ],
                );
            }
        ),
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
                            decoration:  InputDecoration(
                              hintText: 'Search by Order ID',
                              hintStyle: TextStyle(fontSize: 13,color: Colors.grey),
                              contentPadding: EdgeInsets.only(bottom: 20,left: 10), // adjusted padding
                              border: InputBorder.none,
                              suffixIcon: Icon(Icons.search_outlined, color: Colors.blue[800]),
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
                              maxWidth: constraints.maxWidth * 0.12, // reduced width
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
                                  contentPadding: EdgeInsets.only(bottom: 15,left: 10),// adjusted padding
                                  border: InputBorder.none,
                                  filled: true,
                                  focusColor: Color(0xFFF0F4F8),
                                  fillColor: Colors.white,
                                  //hintText: 'Category',
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
                                  'open',
                                  'partial payment',
                                  'cleared',
                                ].map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value, style: TextStyle(color: value == 'Status' ? Colors.grey : Colors.black,fontSize: 13)),
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
                                  width: constraints.maxWidth* 0.12, // Dropdown width
                                  offset:  const Offset(0, -10),
                                ),
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
                              maxWidth: constraints.maxWidth * 0.128, // reduced width
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
                                  contentPadding: EdgeInsets.only(bottom: 22,left: 10),
                                  border: InputBorder.none,
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                                value: dropdownValue2,
                               // focusColor: Color(0xFFF0F4F8),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    dropdownValue2 = newValue;
                                    selectDate = newValue ?? '';
                                    _filterAndPaginateProducts();
                                  });
                                },
                                items: <String>[
                                  'Select Year', '2023', '2024', '2025'
                                ].map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value, style: TextStyle(color: value == 'Select Year' ? Colors.grey : Colors.black,fontSize: 13)),
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
                                  width: constraints.maxWidth * 0.128, // Dropdown width
                                  offset:  const Offset(0, -10),
                                ),
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
  Widget buildDataTable2() {

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

    if (filteredData.isEmpty) {
      // String? role = Provider.of<UserRoleProvider>(context).role;
      double right = MediaQuery.of(context).size.width;
      return
        Column(
          children: [
            Container(
                width: 1100,

                decoration:const BoxDecoration(
                    color: Color(0xFFF7F7F7),
                    border: Border.symmetric(horizontal: BorderSide(color: Colors.grey,width: 0.5))
                ),
                child:

                DataTable(
                    showCheckboxColumn: false,
                    headingRowHeight: 40,
                    columns: [
                      DataColumn(label: Container(child: Text('      '))),
                      DataColumn(
                        label: Container(
                          child: Text(
                            'Order ID',
                            style: TextStyle(
                              color: Colors.indigo[900],
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Container(
                          child: Text(
                            'Delivered Date',
                            style: TextStyle(
                              color: Colors.indigo[900],
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Container(
                          child: Text(
                            'Credit Amount',
                            style: TextStyle(
                              color: Colors.indigo[900],
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      // DataColumn(
                      //   label: Container(
                      //     child: Text(
                      //       'Payment Date',
                      //       style: TextStyle(
                      //         color: Colors.indigo[900],
                      //         fontSize: 13,
                      //         fontWeight: FontWeight.bold,
                      //       ),
                      //     ),
                      //   ),
                      // ),
                      // DataColumn(
                      //   label: Container(
                      //     child: Text(
                      //       'Payment Mode',
                      //       style: TextStyle(
                      //         color: Colors.indigo[900],
                      //         fontSize: 13,
                      //         fontWeight: FontWeight.bold,
                      //       ),
                      //     ),
                      //   ),
                      // ),
                      DataColumn(
                        label: Container(
                          child: Text(
                            'Payment Status',
                            style: TextStyle(
                              color: Colors.indigo[900],
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Container(
                          child: Text(
                            'Amount',
                            style: TextStyle(
                              color: Colors.indigo[900],
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                    rows: []

                )
            ),
            Padding(
              padding: EdgeInsets.only(top: 150,left: 130,bottom: 350,right: 150),
              child: CustomDatafound(),
            ),
          ],
        );

    }

    void _sortProducts(int columnIndex, String sortDirection) {
      if (sortDirection == 'asc') {
        filteredData.sort((a, b) {
          if (columnIndex == 1) {
            return a.orderId!.compareTo(b.orderId!);
          } else if (columnIndex == 2) {
            return a.deliveredDate!.compareTo(b.deliveredDate!);
          } else if (columnIndex == 3) {
            return a.invoiceNo!.compareTo(b.invoiceNo!);
          } else if (columnIndex == 4) {
            return a.paymentStatus!.compareTo(b.paymentStatus!);
          } else if (columnIndex == 5) {
            return a.grossAmount!.compareTo(b.grossAmount!);
          } else {
            return 0;
          }
        });
      } else {
        filteredData.sort((a, b) {
          if (columnIndex == 1) {
            return b.orderId!.compareTo(a.orderId!); // Reverse the comparison
          } else if (columnIndex == 2) {
            return b.deliveredDate!.compareTo(a.deliveredDate!); // Reverse the comparison
          } else if (columnIndex == 3) {
            return b.invoiceNo!.compareTo(a.invoiceNo!); // Reverse the comparison
          } else if (columnIndex == 4) {
            return b.paymentStatus!.compareTo(a.paymentStatus!); // Reverse the comparison
          } else if (columnIndex == 5) {
            return b.grossAmount!.compareTo(a.grossAmount!); // Reverse the comparison
          } else {
            return 0;
          }
        });
      }
      setState(() {});
    }



    return LayoutBuilder(builder: (context, constraints){
      // double padding = constraints.maxWidth * 0.065;
      double right = MediaQuery.of(context).size.width;
      // String? role = Provider.of<UserRoleProvider>(context).role;


      return
        Column(
          children: [
            Container(
                width: 1100,

                decoration:const BoxDecoration(
                    color: Color(0xFFF7F7F7),
                    border: Border.symmetric(horizontal: BorderSide(color: Colors.grey,width: 0.5))
                ),
                child:

                DataTable(
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
                                  if (columns.indexOf(column) > 0)
                                    IconButton(
                                      icon: _sortOrder[columns.indexOf(column)] == 'asc'
                                          ? SizedBox(width: 12,
                                          child: Image.asset("images/sort.png",color: Colors.grey,))
                                          : SizedBox(width: 12,child: Image.asset("images/sort.png",color: Colors.blue,)),
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
                                  if (columns.indexOf(column) > 0)
                                    Spacer(),
                                  if (columns.indexOf(column) > 0)
                                    MouseRegion(
                                      cursor: SystemMouseCursors.resizeColumn,
                                      child: GestureDetector(
                                          onHorizontalDragUpdate: (details) {
                                            // Update column width dynamically as user drags
                                            setState(() {
                                              columnWidths[columns.indexOf(column)] += details.delta.dx;
                                              columnWidths[columns.indexOf(column)] =
                                                  columnWidths[columns.indexOf(column)].clamp(151.0, 300.0);
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
                                                  thickness: 4,
                                                  color: Colors.grey,

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
                  // columns: [
                  //   DataColumn(label: Container(child: Text('      '))),
                  //   DataColumn(
                  //     label: Container(
                  //       child: Text(
                  //         'Order ID',
                  //         style: TextStyle(
                  //           color: Colors.indigo[900],
                  //           fontSize: 13,
                  //           fontWeight: FontWeight.bold,
                  //         ),
                  //       ),
                  //     ),
                  //   ),
                  //   DataColumn(
                  //     label: Container(
                  //       child: Text(
                  //         'Delivered Date',
                  //         style: TextStyle(
                  //           color: Colors.indigo[900],
                  //           fontSize: 13,
                  //           fontWeight: FontWeight.bold,
                  //         ),
                  //       ),
                  //     ),
                  //   ),
                  //   DataColumn(
                  //     label: Container(
                  //       child: Text(
                  //         'Invoice Number',
                  //         style: TextStyle(
                  //           color: Colors.indigo[900],
                  //           fontSize: 13,
                  //           fontWeight: FontWeight.bold,
                  //         ),
                  //       ),
                  //     ),
                  //   ),
                  //   // DataColumn(
                  //   //   label: Container(
                  //   //     child: Text(
                  //   //       'Payment Date',
                  //   //       style: TextStyle(
                  //   //         color: Colors.indigo[900],
                  //   //         fontSize: 13,
                  //   //         fontWeight: FontWeight.bold,
                  //   //       ),
                  //   //     ),
                  //   //   ),
                  //   // ),
                  //   // DataColumn(
                  //   //   label: Container(
                  //   //     child: Text(
                  //   //       'Payment Mode',
                  //   //       style: TextStyle(
                  //   //         color: Colors.indigo[900],
                  //   //         fontSize: 13,
                  //   //         fontWeight: FontWeight.bold,
                  //   //       ),
                  //   //     ),
                  //   //   ),
                  //   // ),
                  //   DataColumn(
                  //     label: Container(
                  //       child: Text(
                  //         'Payment Status',
                  //         style: TextStyle(
                  //           color: Colors.indigo[900],
                  //           fontSize: 13,
                  //           fontWeight: FontWeight.bold,
                  //         ),
                  //       ),
                  //     ),
                  //   ),
                  //   DataColumn(
                  //     label: Container(
                  //       child: Text(
                  //         'Amount',
                  //         style: TextStyle(
                  //           color: Colors.indigo[900],
                  //           fontSize: 13,
                  //           fontWeight: FontWeight.bold,
                  //         ),
                  //       ),
                  //     ),
                  //   ),
                  // ],
                  rows: List.generate(
                    math.min(itemsPerPage, filteredData.length - (currentPage - 1) * itemsPerPage),
                        (index) {
                      final detail = filteredData.skip((currentPage - 1) * itemsPerPage).elementAt(index);
                      final isSelected = _selectedProduct == detail;
                      return DataRow(
                        color: MaterialStateProperty.resolveWith<Color>((states) {
                          if (states.contains(MaterialState.hovered)) {
                            return Colors.blue.shade500.withOpacity(0.8); // Dark blue with opacity
                          } else if (isSelected) {
                            return Colors.blue.shade100.withOpacity(0.8); // Green with opacity for selected row
                          } else {
                            return Colors.white.withOpacity(0.9);
                          }
                        }),
                        cells: [
                          DataCell(
                            Checkbox(
                              value: isSelected,
                              checkColor: Colors.white,
                              activeColor: Colors.blue[800],
                              onChanged: (selected) {
                                setState(() {
                                  if (selected != null && selected) {
                                    _selectedProduct = detail;

                                    _selectedProductMap = {
                                      'orderId': _selectedProduct!.orderId,
                                      'deliveredDate': _selectedProduct!.deliveredDate,
                                      'invoiceNo': _selectedProduct!.invoiceNo,//
                                      'paymentDate': _selectedProduct!.paymentDate.toString(),
                                      'paymentMode': _selectedProduct!.paymentMode.toString(),
                                      'paymentStatus': _selectedProduct!.paymentStatus.toString(),
                                      'grossAmount': _selectedProduct!.grossAmount.toString(),
                                      'payableAmount': _selectedProduct!.payableAmount.toString(),
                                      'paidAmount': _selectedProduct!.paidAmount.toString(),//

                                    };
                                  } else {
                                    _selectedProduct = null;
                                    _selectedProductMap ={};
                                  }
                                });
                              },
                            ),
                          ),
                          DataCell(
                            Text(
                              detail.orderId!,
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                          DataCell(
                            Text(
                              detail.deliveredDate!,
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                          DataCell(
                            Text(
                              detail.creditUsed!.toStringAsFixed(2),
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                          DataCell(
                            Text(
                              detail.paymentStatus.toString(),
                              style: TextStyle(
                                color: detail.paymentStatus == "payment cleared"
                                    ? Colors.green
                                    : detail.paymentStatus == "partial payment"
                                    ? Colors.orange
                                    : Colors.grey,
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              detail.grossAmount.toString(),
                              style: TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ],
                        onSelectChanged: (selected) {
                          setState(() {
                            if (selected != null && selected) {
                              _selectedProduct = detail;

                              _selectedProductMap = {
                                'orderId': _selectedProduct!.orderId,
                                'deliveredDate': _selectedProduct!.deliveredDate,
                                'invoiceNo': _selectedProduct!.invoiceNo,//
                                'paymentDate': _selectedProduct!.paymentDate.toString(),
                                'paymentMode': _selectedProduct!.paymentMode.toString(),
                                'paymentStatus': _selectedProduct!.paymentStatus.toString(),
                                'grossAmount': _selectedProduct!.grossAmount.toString(),
                                'payableAmount': _selectedProduct!.payableAmount.toString(),
                                'paidAmount': _selectedProduct!.paidAmount.toString(),//

                              };
                            } else {
                              _selectedProduct = null;
                              _selectedProductMap ={};
                            }
                          });
                        },
                      );
                    },
                  ),
                )
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
        padding: EdgeInsets.only(top: Height * 0.100,bottom: Height * 0.100,left: width * 0.300),
        child: CustomLoadingIcon(), // Replace this with your custom GIF widget
      );
    }

    if (filteredData.isEmpty) {
     // String? role = Provider.of<UserRoleProvider>(context).role;
      double right = MediaQuery.of(context).size.width;
      return
        Column(
          children: [
            Container(
              width: right - 200,

              decoration:const BoxDecoration(
                  color: Color(0xFFF7F7F7),
                  border: Border.symmetric(horizontal: BorderSide(color: Colors.grey,width: 0.5))
              ),
              child:

              DataTable(
                  showCheckboxColumn: false,
                  headingRowHeight: 40,
                  columns: [
                    DataColumn(label: Container(child: Text('      '))),
                    DataColumn(
                      label: Container(
                        child: Text(
                          'Order ID',
                          style: TextStyle(
                            color: Colors.indigo[900],
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Container(
                        child: Text(
                          'Delivered Date',
                          style: TextStyle(
                            color: Colors.indigo[900],
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Container(
                        child: Text(
                          'Credit Amount',
                          style: TextStyle(
                            color: Colors.indigo[900],
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    // DataColumn(
                    //   label: Container(
                    //     child: Text(
                    //       'Payment Date',
                    //       style: TextStyle(
                    //         color: Colors.indigo[900],
                    //         fontSize: 13,
                    //         fontWeight: FontWeight.bold,
                    //       ),
                    //     ),
                    //   ),
                    // ),
                    // DataColumn(
                    //   label: Container(
                    //     child: Text(
                    //       'Payment Mode',
                    //       style: TextStyle(
                    //         color: Colors.indigo[900],
                    //         fontSize: 13,
                    //         fontWeight: FontWeight.bold,
                    //       ),
                    //     ),
                    //   ),
                    // ),
                    DataColumn(
                      label: Container(
                        child: Text(
                          'Payment Status',
                          style: TextStyle(
                            color: Colors.indigo[900],
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Container(
                        child: Text(
                          'Amount',
                          style: TextStyle(
                            color: Colors.indigo[900],
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                  rows: []

              )
            ),
            Padding(
              padding: EdgeInsets.only(top: 150,left: 130,bottom: 350,right: 150),
              child: CustomDatafound(),
            ),
          ],
        );

    }

    void _sortProducts(int columnIndex, String sortDirection) {
      if (sortDirection == 'asc') {
        filteredData.sort((a, b) {
          if (columnIndex == 1) {
            return a.orderId!.compareTo(b.orderId!);
          } else if (columnIndex == 2) {
            return a.deliveredDate!.compareTo(b.deliveredDate!);
          } else if (columnIndex == 3) {
            return a.invoiceNo!.compareTo(b.invoiceNo!);
          } else if (columnIndex == 4) {
            return a.paymentStatus!.compareTo(b.paymentStatus!);
          } else if (columnIndex == 5) {
            return a.grossAmount!.compareTo(b.grossAmount!);
          } else {
            return 0;
          }
        });
      } else {
        filteredData.sort((a, b) {
          if (columnIndex == 1) {
            return b.orderId!.compareTo(a.orderId!); // Reverse the comparison
          } else if (columnIndex == 2) {
            return b.deliveredDate!.compareTo(a.deliveredDate!); // Reverse the comparison
          } else if (columnIndex == 3) {
            return b.invoiceNo!.compareTo(a.invoiceNo!); // Reverse the comparison
          } else if (columnIndex == 4) {
            return b.paymentStatus!.compareTo(a.paymentStatus!); // Reverse the comparison
          } else if (columnIndex == 5) {
            return b.grossAmount!.compareTo(a.grossAmount!); // Reverse the comparison
          } else {
            return 0;
          }
        });
      }
      setState(() {});
    }



    return LayoutBuilder(builder: (context, constraints){
      // double padding = constraints.maxWidth * 0.065;
      double right = MediaQuery.of(context).size.width;
     // String? role = Provider.of<UserRoleProvider>(context).role;


      return
        Column(
          children: [
            Container(
              width: right-200,

              decoration:const BoxDecoration(
                  color: Color(0xFFF7F7F7),
                  border: Border.symmetric(horizontal: BorderSide(color: Colors.grey,width: 0.5))
              ),
              child:

              DataTable(
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
                                if (columns.indexOf(column) > 0)
                                  IconButton(
                                    icon: _sortOrder[columns.indexOf(column)] == 'asc'
                                        ? SizedBox(width: 12,
                                        child: Image.asset("images/sort.png",color: Colors.grey,))
                                        : SizedBox(width: 12,child: Image.asset("images/sort.png",color: Colors.blue,)),
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
                                if (columns.indexOf(column) > 0)
                                  Spacer(),
                                if (columns.indexOf(column) > 0)
                                  MouseRegion(
                                    cursor: SystemMouseCursors.resizeColumn,
                                    child: GestureDetector(
                                        onHorizontalDragUpdate: (details) {
                                          // Update column width dynamically as user drags
                                          setState(() {
                                            columnWidths[columns.indexOf(column)] += details.delta.dx;
                                            columnWidths[columns.indexOf(column)] =
                                                columnWidths[columns.indexOf(column)].clamp(151.0, 300.0);
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
                                                thickness: 4,
                                                color: Colors.grey,

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
                // columns: [
                //   DataColumn(label: Container(child: Text('      '))),
                //   DataColumn(
                //     label: Container(
                //       child: Text(
                //         'Order ID',
                //         style: TextStyle(
                //           color: Colors.indigo[900],
                //           fontSize: 13,
                //           fontWeight: FontWeight.bold,
                //         ),
                //       ),
                //     ),
                //   ),
                //   DataColumn(
                //     label: Container(
                //       child: Text(
                //         'Delivered Date',
                //         style: TextStyle(
                //           color: Colors.indigo[900],
                //           fontSize: 13,
                //           fontWeight: FontWeight.bold,
                //         ),
                //       ),
                //     ),
                //   ),
                //   DataColumn(
                //     label: Container(
                //       child: Text(
                //         'Invoice Number',
                //         style: TextStyle(
                //           color: Colors.indigo[900],
                //           fontSize: 13,
                //           fontWeight: FontWeight.bold,
                //         ),
                //       ),
                //     ),
                //   ),
                //   // DataColumn(
                //   //   label: Container(
                //   //     child: Text(
                //   //       'Payment Date',
                //   //       style: TextStyle(
                //   //         color: Colors.indigo[900],
                //   //         fontSize: 13,
                //   //         fontWeight: FontWeight.bold,
                //   //       ),
                //   //     ),
                //   //   ),
                //   // ),
                //   // DataColumn(
                //   //   label: Container(
                //   //     child: Text(
                //   //       'Payment Mode',
                //   //       style: TextStyle(
                //   //         color: Colors.indigo[900],
                //   //         fontSize: 13,
                //   //         fontWeight: FontWeight.bold,
                //   //       ),
                //   //     ),
                //   //   ),
                //   // ),
                //   DataColumn(
                //     label: Container(
                //       child: Text(
                //         'Payment Status',
                //         style: TextStyle(
                //           color: Colors.indigo[900],
                //           fontSize: 13,
                //           fontWeight: FontWeight.bold,
                //         ),
                //       ),
                //     ),
                //   ),
                //   DataColumn(
                //     label: Container(
                //       child: Text(
                //         'Amount',
                //         style: TextStyle(
                //           color: Colors.indigo[900],
                //           fontSize: 13,
                //           fontWeight: FontWeight.bold,
                //         ),
                //       ),
                //     ),
                //   ),
                // ],
                rows: List.generate(
                  math.min(itemsPerPage, filteredData.length - (currentPage - 1) * itemsPerPage),
                      (index) {
                    final detail = filteredData.skip((currentPage - 1) * itemsPerPage).elementAt(index);
                    final isSelected = _selectedProduct == detail;
                    return DataRow(
                      color: MaterialStateProperty.resolveWith<Color>((states) {
                        if (states.contains(MaterialState.hovered)) {
                          return Colors.blue.shade500.withOpacity(0.8); // Dark blue with opacity
                        } else if (isSelected) {
                          return Colors.blue.shade100.withOpacity(0.8); // Green with opacity for selected row
                        } else {
                          return Colors.white.withOpacity(0.9);
                        }
                      }),
                      cells: [
                        DataCell(
                          Checkbox(
                            value: isSelected,
                            checkColor: Colors.white,
                            activeColor: Colors.blue[800],
                            onChanged: (selected) {
                              setState(() {
                                if (selected != null && selected) {
                                  _selectedProduct = detail;

                                  _selectedProductMap = {
                                    'orderId': _selectedProduct!.orderId,
                                    'deliveredDate': _selectedProduct!.deliveredDate,
                                    'invoiceNo': _selectedProduct!.invoiceNo,//
                                    'paymentDate': _selectedProduct!.paymentDate.toString(),
                                    'paymentMode': _selectedProduct!.paymentMode.toString(),
                                    'paymentStatus': _selectedProduct!.paymentStatus.toString(),
                                    'grossAmount': _selectedProduct!.grossAmount.toString(),
                                    'payableAmount': _selectedProduct!.payableAmount.toString(),
                                    'paidAmount': _selectedProduct!.paidAmount.toString(),//

                                  };
                                } else {
                                  _selectedProduct = null;
                                  _selectedProductMap ={};
                                }
                              });
                            },
                          ),
                        ),
                        DataCell(
                          Text(
                            detail.orderId!,
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                        DataCell(
                          Text(
                            detail.deliveredDate!,
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                        DataCell(
                          Text(
                            detail.creditUsed!.toStringAsFixed(2),
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                        // DataCell(
                        //   Padding(
                        //     padding: const EdgeInsets.only(left: 13),
                        //     child: Text(
                        //       detail.paymentDate.toString(),
                        //       style: TextStyle(color: Colors.grey),
                        //     ),
                        //   ),
                        // ),
                        // DataCell(
                        //   Padding(
                        //     padding: const EdgeInsets.only(left: 10),
                        //     child: Text(
                        //       detail.paymentMode.toString(),
                        //       style: TextStyle(
                        //         color: detail.deliveryStatus == "In Progress"
                        //             ? Colors.orange
                        //             : detail.deliveryStatus == "Delivered"
                        //             ? Colors.green
                        //             : Colors.grey,
                        //       ),
                        //     ),
                        //   ),
                        // ),
                        DataCell(
                         Text(
                           detail.paymentStatus.toString(),
                           style: TextStyle(
                             color: detail.paymentStatus == "payment cleared"
                                 ? Colors.green
                                 : detail.paymentStatus == "partial payment"
                                 ? Colors.orange
                                 : Colors.grey,
                           ),
                         ),
                        ),
                        DataCell(
                          Text(
                            detail.grossAmount.toString(),
                            style: TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ],
                      onSelectChanged: (selected) {
                        setState(() {
                          if (selected != null && selected) {
                            _selectedProduct = detail;

                            _selectedProductMap = {
                              'orderId': _selectedProduct!.orderId,
                              'deliveredDate': _selectedProduct!.deliveredDate,
                              'invoiceNo': _selectedProduct!.invoiceNo,//
                              'paymentDate': _selectedProduct!.paymentDate.toString(),
                              'paymentMode': _selectedProduct!.paymentMode.toString(),
                              'paymentStatus': _selectedProduct!.paymentStatus.toString(),
                              'grossAmount': _selectedProduct!.grossAmount.toString(),
                              'payableAmount': _selectedProduct!.payableAmount.toString(),
                              'paidAmount': _selectedProduct!.paidAmount.toString(),//

                            };
                          } else {
                            _selectedProduct = null;
                            _selectedProductMap ={};
                          }
                        });
                      },
                    );
                  },
                ),
              )
            ),
          ],
        );
    });
  }

  void _filterAndPaginateProducts() {
    filteredData = productList.where((product) {
      final matchesSearchText= product.orderId!.toLowerCase().contains(_searchText.toLowerCase());
      print('-----');
      print(product.paymentDate);
      String orderYear = '';
      if (product.paymentDate!.contains('/')) {
        final dateParts = product.paymentDate!.split('/');
        if (dateParts.length == 3) {
          orderYear = dateParts[2]; // Extract the year
        }
      }
      // final orderYear = element.orderDate.substring(5,9);
      if (status.isEmpty && selectDate.isEmpty) {
        return matchesSearchText; // Include all products that match the search text
      }
      if(status == 'Status' && selectDate == 'Select Year'){
        return matchesSearchText;
      }
      if(status == 'Status' &&  selectDate.isEmpty)
      {
        return matchesSearchText;
      }
      if(selectDate == 'Select Year' &&  status.isEmpty)
      {
        return matchesSearchText;
      }
      if (status == 'Status' && selectDate.isNotEmpty) {
        return matchesSearchText && orderYear == selectDate; // Include all products
      }
      if (status.isNotEmpty && selectDate == 'Select Year') {
        return matchesSearchText && product.paymentStatus == status;// Include all products
      }
      if (status.isEmpty && selectDate.isNotEmpty) {
        return matchesSearchText && orderYear == selectDate; // Include all products
      }//this one

      if (status.isNotEmpty && selectDate.isEmpty) {
        return matchesSearchText && product.paymentStatus == status;// Include all products
      }
      return matchesSearchText &&
          (product.paymentStatus == status && orderYear == selectDate);
      //  return false;
    }).toList();
    totalPages = (filteredData.length / itemsPerPage).ceil();

    //   filteredData.sort((a, b) => a.orderId)
    setState(() {
      currentPage = 1;
    });

  }

}



// class OrderDetail {
//   String? orderId;
//   String? orderDate;
//   String? InvNo;
//   String? referenceNumber;
//   double? total;
//   String? deliveryStatus;
//   String? status;
//   String? orderCategory;
//   final String? deliveryLocation;
//   final String? deliveryAddress;
//   final String? contactPerson;
//   final String? contactNumber;
//   final String? comments;
//   final List<dynamic> items;
//
//   OrderDetail({
//     this.orderId,
//     this.orderDate,
//     this.orderCategory,
//     this.referenceNumber,
//     this.total,
//     this.deliveryStatus,
//     this.status,
//     this.deliveryLocation,
//     this.deliveryAddress,
//     this.contactPerson,
//     this.contactNumber,
//     this.comments,
//     this.InvNo,
//     required this.items,
//   });
//
//   factory OrderDetail.fromJson(Map<String, dynamic> json) {
//     return OrderDetail(
//       orderId: json['orderId'],
//       orderCategory: json['orderCategory'] ?? '',
//       orderDate: json['orderDate'] ?? 'Unknown date',
//       total: json['total'].toDouble() ?? 0.0,
//       status: json['status'] ?? '',
//       // Dummy value
//       InvNo: json['invoiceNo'],
//       deliveryStatus: 'Not Started',
//       // Dummy value
//       referenceNumber: '  ', // Dummy value
//       deliveryLocation: json['deliveryLocation'],
//       deliveryAddress: json['deliveryAddress'],
//       contactPerson: json['contactPerson'],
//       contactNumber: json['contactNumber'],
//       comments: json['comments'],
//       items: json['items'],
//     );
//   }
//
//   factory OrderDetail.fromString(String jsonString) {
//     final jsonMap = jsonDecode(jsonString);
//     return OrderDetail.fromJson(jsonMap);
//   }
//
//   @override
//   String toString() {
//     return 'Order ID: $orderId, Order Date: $orderDate, Total: $total, Status: $status, Delivery Status: $deliveryStatus, Reference Number: $referenceNumber';
//   }
//
//   String toJson() {
//     return jsonEncode({
//       "orderId": orderId,
//       "orderDate": orderDate,
//       "total": total,
//       "status": status,
//       "deliveryStatus": deliveryStatus,
//       "referenceNumber": referenceNumber,
//       "items": items,
//       "deliveryLocation": deliveryLocation,
//       "deliveryAddress": deliveryAddress,
//       "contactPerson": contactPerson,
//       "contactNumber": contactNumber,
//       "comments": comments,
//     });
//   }
// }

