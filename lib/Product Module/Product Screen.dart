import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'dart:html';
import 'package:adaptive_scrollbar/adaptive_scrollbar.dart';
import 'package:btb/admin/Api%20name.dart';
import 'package:btb/widgets/productclass.dart' as ord;
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:provider/single_child_widget.dart';
import '../widgets/confirmdialog.dart';
import '../widgets/custom loading.dart';
import '../widgets/no datafound.dart';
import '../widgets/pagination.dart';
import '../Order Module/firstpage.dart';
import '../widgets/productdata.dart';


class ProductPage extends StatefulWidget {
  const ProductPage({super.key, required this.product});
  final ord.Product? product;
  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> with SingleTickerProviderStateMixin{
  ord.Product? _selectedProduct;
  List<String> _sortOrder = List.generate(5, (index) => 'asc');
  List<String> columns = ['Product Name', 'Category','Sub Category','Unit','Price'];
  List<double> columnWidths = [130, 115, 125, 80, 100];
  List<bool> columnSortState = [true, true, true,true,true];
  late ProductData productData;
  bool isHomeSelected = false;
  bool isOrdersSelected = false;
  Timer? _searchDebounceTimer;
  final ScrollController horizontalScroll = ScrollController();
  late AnimationController _controller;
  bool _isHovered1 = false;
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
  late Animation<double> _shakeAnimation;
  String _searchText = '';
  String _category = '';

  late TextEditingController _dateController;
  String _subCategory = '';
  int startIndex = 0;
  List<ord.Product> filteredProducts = [];
  String? dropdownValue1 = 'Category';
  String token = window.sessionStorage["token"] ?? " ";
  String? dropdownValue2 = 'Sub Category';
  bool _hasShownPopup = false;

  final ScrollController _scrollController = ScrollController();
  int currentPage = 1;
  int itemsPerPage = 10;
  bool _isRowHovered = false;
  int totalItems = 0;
  int totalPages = 0;
  bool _loading = false;
  bool isLoading = false;
  List<ord.Product> productList = [];

// Example method for fetching products
  Future<void> fetchProducts(int page, int itemsPerPage) async {
    if (isLoading) return;
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse(
          '$apicall/productmaster/get_all_productmaster?page=$page&limit=$itemsPerPage', // Changed limit to 10
        ),
        headers: {
          "Content-type": "application/json",
          "Authorization": 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        List<ord.Product> products = [];
        if (jsonData != null) {
          if (jsonData is List) {
            products = jsonData.map((item) => ord.Product.fromJson(item)).toList();
          } else if (jsonData is Map && jsonData.containsKey('body')) {
            products = (jsonData['body'] as List).map((item) => ord.Product.fromJson(item)).toList();
            //  totalItems = jsonData['totalItems'] ?? 0;

            print('pages');
            print(totalPages);// Changed itemsPerPage to 10
          }

          setState(() {
            productList = products;
            totalPages = (products.length / itemsPerPage).ceil();
            print(totalPages);
            _filterAndPaginateProducts();
          });
        }
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Error decoding JSON: $e');
      // Optionally, show an error message to the user
    } finally {
      setState(() {
        isLoading = false;
      });
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
      if(filteredProducts.length > itemsPerPage) {
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
      if(filteredProducts.length > currentPage * itemsPerPage) {
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
            double maxWidth = constraints.maxWidth;
            return Stack(
              children: [
                if(constraints.maxHeight <= 500)...{
                  SingleChildScrollView(
                    child:  Align(
                      // Added Align widget for the left side menu
                      alignment: Alignment.topLeft,
                      child: Container(
                        height: 1400,
                        width: 200,
                        color: const Color(0xFFF7F6FA),
                        padding: const EdgeInsets.only(left: 15, top: 10,right: 15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: _buildMenuItems(context),

                        ),
                      ),
                    ),
                  ),
                }
                else...{
                  Align(
                    // Added Align widget for the left side menu
                    alignment: Alignment.topLeft,
                    child: Container(
                      height: 1400,
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
                  padding: const EdgeInsets.only( left: 190),
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 10), // Space above/below the border
                    width: 1,
                    height: 1400,// Border height
                    decoration:const BoxDecoration(
                      border:
                      Border(left: BorderSide(width: 1, color: Colors.grey)),
                    ),// Border color
                  ),
                ),
                Positioned(
                  left: 201,
                  top: 0,
                  right: 0,
                  bottom: 0,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          color: Color(0xFFFFFDFF),
                          height: 50,
                          child: Row(
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(left: 20),
                                child: Text(
                                  'Product List',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              const Spacer(),
                              Align(
                                alignment: Alignment.topRight,
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 10, right: 80),
                                  child: AnimatedBuilder(
                                      animation: _controller,
                                      builder: (context, child) {
                                        return Transform.translate(offset: Offset(_isHovered1? _shakeAnimation.value : 0,0),
                                          child: AnimatedContainer(
                                            duration: const Duration(milliseconds: 300),
                                            curve: Curves.easeInOut,
                                            decoration: BoxDecoration(
                                              color: _isHovered1
                                                  ? Colors.blue[800]
                                                  : Colors.blue[800], // Background color change on hover
                                              borderRadius: BorderRadius.circular(5),
                                              boxShadow: _isHovered1
                                                  ? [
                                                BoxShadow(
                                                    color: Colors.black45,
                                                    blurRadius: 6,
                                                    spreadRadius: 2)
                                              ]
                                                  : [],
                                            ),
                                            child: OutlinedButton(
                                              onPressed: () {
                                                context.go('/Create_New_Product');
                                              },
                                              style: OutlinedButton.styleFrom(
                                                backgroundColor: Colors
                                                    .blue[800], // Button background color
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(
                                                      5), // Rounded corners
                                                ),
                                                side: BorderSide.none, // No outline
                                              ),
                                              child: const Text(
                                                'Create',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  // fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      }

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
                        // width: 1000,
                        width: constraints.maxWidth,
                        // Border height
                        color: Colors.grey, // Border color
                      ),
                      if(constraints.maxWidth >= 1350)...{
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
                                                        child: buildDataTable(),
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
                                                          totalPages: filteredProducts
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
                                                              totalPages: filteredProducts
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
                const SizedBox(height: 50,),
              ],
            );
          }
          )
      ),
    );
  }


  Widget buildSearchField() {
    return LayoutBuilder(
        builder: (context, constraints) {
          return ConstrainedBox(
            constraints: BoxConstraints(),
            child: Container(
              padding: const EdgeInsets.only(
                left: 20,
                right: 20,
                top: 2,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            // maxWidth: 374,
                            maxWidth: constraints.maxWidth * 0.261,
                            // reduced width
                            maxHeight: 39, // reduced height
                          ),
                          child: Container(
                            height: 35,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(2),
                              border: Border.all(color: Colors.grey),
                            ),
                            child: TextFormField(
                              decoration: const InputDecoration(
                                hintText: 'Search by product name',
                                hintStyle: TextStyle(color: Colors.grey,fontSize: 13),
                                contentPadding: EdgeInsets.only(bottom: 20,left: 10),
                                // adjusted padding
                                border: InputBorder.none,
                                suffixIcon: Padding(
                                  padding: EdgeInsets.only(right: 5),
                                  child: Icon(Icons.search_outlined,
                                      color: Colors.indigo),
                                ),
                              ),
                              onChanged: _updateSearch,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  // const SizedBox(height: 2),
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          //const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth: constraints.maxWidth * 0.12,
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
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.only(bottom: 15,left: 10),
                                    // adjusted padding
                                    border: InputBorder.none,
                                    filled: true,
                                    fillColor: Colors.white,
                                    hintText: 'Category',
                                  ),
                                  value: dropdownValue1,
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      dropdownValue1 = newValue;
                                      _category = newValue ?? '';
                                      _filterAndPaginateProducts();
                                    });
                                  },
                                  items: <String>[
                                    'Category',
                                    'Select 1',
                                    'Select 2',
                                    'Select 3'
                                  ].map<DropdownMenuItem<String>>((
                                      String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value,
                                          style: TextStyle(fontSize: 12,color: value == 'Category' ? Colors.grey : Colors.black,)),
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
                                   // overlayColor: C,
                                    //focusColor: Color(0xFFF0F4F8),
                                    height: 50, // Button height
                                    padding: EdgeInsets.only(left: 10, right: 10), // Button padding
                                  ),
                                  dropdownStyleData: DropdownStyleData(
                                    decoration: BoxDecoration(

                                      borderRadius: BorderRadius.circular(7), // Rounded corners
                                      color: Colors.white, // Dropdown background color
                                    ),
                                    maxHeight: 200, // Max height for dropdown items

                                    width: constraints.maxWidth *  0.12, // Dropdown width
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
                          //const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth: constraints.maxWidth * 0.128,
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
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.only(bottom: 20,left: 10),
                                    // adjusted padding
                                    border: InputBorder.none,
                                    filled: true,
                                    fillColor: Colors.white,
                                  ),
                               //   icon: Container(),
                                  value: dropdownValue2,
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      dropdownValue2 = newValue;
                                      _subCategory = newValue ?? '';
                                      _filterAndPaginateProducts();
                                    });
                                  },
                                  items: <String>['Sub Category', 'Yes', 'No']
                                      .map<DropdownMenuItem<String>>((
                                      String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value, style: TextStyle(
                                          color: value == 'Sub Category' ? Colors.grey : Colors.black,fontSize: 12)),
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
                                    // overlayColor: C,
                                    //focusColor: Color(0xFFF0F4F8),
                                    height: 50, // Button height
                                    padding: EdgeInsets.only(left: 10, right: 10), // Button padding
                                  ),
                                  dropdownStyleData: DropdownStyleData(
                                    decoration: BoxDecoration(

                                      borderRadius: BorderRadius.circular(7), // Rounded corners
                                      color: Colors.white, // Dropdown background color
                                    ),
                                    maxHeight: 150, // Max height for dropdown items
                                    width: constraints.maxWidth *  0.12, // Dropdown width
                                    offset:  const Offset(0, -10),
                                  ),
                                 // focusColor: Color(0xFFF0F4F8),
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
        }
    );
  }

  Widget buildDataTable2() {
    // _filterAndPaginateProducts();

    if (isLoading) {
      var width = MediaQuery.of(context).size.width;
      var Height = MediaQuery.of(context).size.height;
      _loading = true;
      // Show loading indicator while data is being fetched
      return Padding(
        padding: EdgeInsets.only(bottom: Height * 0.100,left: width * 0.300),
        child: CustomLoadingIcon(), // Replace this with your custom GIF widget
      );
    }
    if (filteredProducts.isEmpty) {
      var _mediaQuery = MediaQuery.of(context).size.width;
      return  Column(
        children: [

          Container(
            width: 1100,
            decoration:const  BoxDecoration(
              ///  color:  Colors.grey,
              // color:  Color(0xFFECEFF1),
                color:  Color(0xFFF7F7F7),
                border: Border.symmetric(horizontal: BorderSide(color: Colors.grey,width: 0.5))
            ),
            child:
            DataTable(
                showCheckboxColumn: false,
                headingRowHeight: 40,
                columns: [
                  DataColumn(
                    label: Container(
                      // padding: const EdgeInsets.only(left: 19),
                      child: Text(
                        'Product Name',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo[900],
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Container(
                      // padding: const EdgeInsets.only(left: 10),
                      child: Text(
                        'Category',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo[900],
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Container(
                      //padding: const EdgeInsets.only(left: 10),
                      child: Text(
                        'Sub Category',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo[900],
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Container(
                      //padding: const EdgeInsets.only(left: 22),
                      child: Text(
                        'Unit',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo[900],
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Container(
                      //padding: const EdgeInsets.only(left: 12),
                      child: Text(
                        'Price',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo[900],
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ],
                rows:
                []
            ),


          ),
          Padding(
            padding: EdgeInsets.only(top: 150,left: 130,bottom: 350,right: 150),
            child: CustomDatafound(),
          ),
          //Text('No productss found', style: TextStyle(fontSize: 24))),
        ],

      );

    }
    return LayoutBuilder(builder: (context, constraints){
      var _mediaQuery = MediaQuery.of(context).size.width;
      return Column(
        children: [
          // Heading Row with GestureDetector for resizing
          Container(
            width: 1100,
            decoration: BoxDecoration(
              color: Color(0xFFF7F7F7),
              border: Border.symmetric(horizontal: BorderSide(color: Colors.grey, width: 0.5)),
            ),
            child:
            DataTable(
                showCheckboxColumn: false,
                headingRowHeight: 40,
                // List.generate(5, (index)
                columns: columns.map((column) {
                  return DataColumn(
                    label: Stack(
                      children: [
                        Container(
                          padding: null,
                          width: columnWidths[columns.indexOf(column)], // Dynamic width based on user interaction
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
                              Spacer(),
                              MouseRegion(

                                cursor: SystemMouseCursors.resizeColumn,
                                child: GestureDetector(

                                    onHorizontalDragUpdate: (details) {
                                      // Update column width dynamically as user drags
                                      setState(() {
                                        columnWidths[columns.indexOf(column)] += details.delta.dx;
                                        columnWidths[columns.indexOf(column)] =
                                            columnWidths[columns.indexOf(column)].clamp(131.0, 300.0);
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


                rows: List.generate(
                    math.min(itemsPerPage, filteredProducts.length - (currentPage - 1) * itemsPerPage),(index)
                {
                  final product = filteredProducts[(currentPage - 1) * itemsPerPage + index];
                  final isSelected = _selectedProduct == product;
                  return DataRow(
                    color: MaterialStateProperty.resolveWith<Color>((states) {
                      if (states.contains(MaterialState.hovered)) {
                        return Colors.blue.shade500.withOpacity(0.8); // Add some opacity to the dark blue
                      } else {
                        return Colors.white.withOpacity(0.9);
                      }
                    }),

                    cells: [
                      DataCell(
                        Container(
                          width: columnWidths[0], // Same dynamic width as column headers
                          child: Text(product.productName,style: TextStyle(
                            color: isSelected
                                ? Colors.deepOrange[200]
                                : const Color(0xFFFFB315),
                          ),),
                        ),
                      ),
                      DataCell(
                        Container(
                          width: columnWidths[1],
                          child: Text(product.category,
                            style: const TextStyle(
                              color: Color(0xFFA6A6A6),
                            ),),
                        ),
                      ),
                      DataCell(
                        Container(
                          width: columnWidths[2],
                          child: Text(product.subCategory,
                            style: const TextStyle(
                              color: Color(0xFFA6A6A6),
                            ),),
                        ),
                      ),
                      DataCell(
                        Container(
                          width: columnWidths[3],
                          child: Text(product.unit,
                            style: const TextStyle(color: Color(0xFFA6A6A6),),
                          ),
                        ),
                      ),
                      DataCell(
                        Container(
                          width: columnWidths[4],
                          child: Text(product.price.toString(),  style: const TextStyle(color:
                          Color(0xFFA6A6A6),
                          ),),
                        ),
                      ),
                    ],
                    onSelectChanged: (selected) {
                      if (selected != null && selected) {
                        print('from first page');
                        print(filteredProducts);
                        print(product);

                        if(filteredProducts.length <=9){
                          context.go('/Product_View',
                              extra: {
                                'product': product,
                                'orderDetails': productList.map((detail) => OrderDetail(
                                  orderId: detail.prodId,
                                  orderDate: detail.productName,
                                  orderCategory: detail.category,
                                  items: [],
                                  // Add other fields as needed
                                )).toList(),
                              });
                        }else {
                          context.go('/Product_View',
                              extra: {
                                'product': product,
                                'orderDetails': filteredProducts.map((detail) => OrderDetail(
                                  orderId: detail.prodId,
                                  orderDate: detail.productName,
                                  orderCategory: detail.category,
                                  items: [],
                                  // Add other fields as needed
                                )).toList(),
                              });
                        }


                      }
                    },

                  );
                }
                )

            ),
          ),
        ],
      );
    });
  }
  Widget buildDataTable() {
    // _filterAndPaginateProducts();

    if (isLoading) {
      var width = MediaQuery.of(context).size.width;
      var Height = MediaQuery.of(context).size.height;
      _loading = true;
      // Show loading indicator while data is being fetched
      return Padding(
        padding: EdgeInsets.only(bottom: Height * 0.100,left: width * 0.300),
        child: CustomLoadingIcon(), // Replace this with your custom GIF widget
      );
    }
    if (filteredProducts.isEmpty) {
      var _mediaQuery = MediaQuery.of(context).size.width;
      return  Column(
        children: [

          Container(
            width: _mediaQuery- 250,
            decoration: BoxDecoration(
              ///  color:  Colors.grey,
              // color:  Color(0xFFECEFF1),
                color:  Color(0xFFF7F7F7),
                border: Border.symmetric(horizontal: BorderSide(color: Colors.grey,width: 0.5))
            ),
            child:
            DataTable(
                showCheckboxColumn: false,
                headingRowHeight: 40,
                columns: [
                  DataColumn(
                    label: Container(
                      // padding: const EdgeInsets.only(left: 19),
                      child: Text(
                        'Product Name',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo[900],
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Container(
                      // padding: const EdgeInsets.only(left: 10),
                      child: Text(
                        'Category',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo[900],
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Container(
                      //padding: const EdgeInsets.only(left: 10),
                      child: Text(
                        'Sub Category',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo[900],
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Container(
                      //padding: const EdgeInsets.only(left: 22),
                      child: Text(
                        'Unit',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo[900],
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Container(
                      //padding: const EdgeInsets.only(left: 12),
                      child: Text(
                        'Price',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo[900],
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ],
                rows:
                []
            ),


          ),
          Padding(
            padding: EdgeInsets.only(top: 150,left: 130,bottom: 350,right: 150),
            child: CustomDatafound(),
          ),
          //Text('No productss found', style: TextStyle(fontSize: 24))),
        ],

      );

    }
    return LayoutBuilder(builder: (context, constraints){
      var _mediaQuery = MediaQuery.of(context).size.width;
      return Column(
        children: [
          // Heading Row with GestureDetector for resizing
          Container(
            width: _mediaQuery - 250,
            decoration: BoxDecoration(
              color: Color(0xFFF7F7F7),
              border: Border.symmetric(horizontal: BorderSide(color: Colors.grey, width: 0.5)),
            ),
            child:
            SizedBox(
              width: _mediaQuery * 0.2,
              child:
              DataTable(
                  showCheckboxColumn: false,
                  headingRowHeight: 40,
                  // List.generate(5, (index)
                  columns: columns.map((column) {
                    return DataColumn(
                      label: Stack(
                        children: [
                          Container(
                           padding: null,
                            width: columnWidths[columns.indexOf(column)], // Dynamic width based on user interaction
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
                                Spacer(),
                                  MouseRegion(

                                    cursor: SystemMouseCursors.resizeColumn,
                                    child: GestureDetector(

                                        onHorizontalDragUpdate: (details) {
                                          // Update column width dynamically as user drags
                                          setState(() {
                                                      columnWidths[columns.indexOf(column)] += details.delta.dx;
                                                      columnWidths[columns.indexOf(column)] =
                                                      columnWidths[columns.indexOf(column)].clamp(131.0, 300.0);
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


                  rows: List.generate(
                      math.min(itemsPerPage, filteredProducts.length - (currentPage - 1) * itemsPerPage),(index)
                  {
                    final product = filteredProducts[(currentPage - 1) * itemsPerPage + index];
                    final isSelected = _selectedProduct == product;
                    return DataRow(
                      color: MaterialStateProperty.resolveWith<Color>((states) {
                        if (states.contains(MaterialState.hovered)) {
                          return Colors.blue.shade500.withOpacity(0.8); // Add some opacity to the dark blue
                        } else {
                          return Colors.white.withOpacity(0.9);
                        }
                      }),

                      cells: [
                        DataCell(
                          Container(
                            width: columnWidths[0], // Same dynamic width as column headers
                            child: Text(product.productName,style: TextStyle(
                              color: isSelected
                                  ? Colors.deepOrange[200]
                                  : const Color(0xFFFFB315),
                            ),),
                          ),
                        ),
                        DataCell(
                          Container(
                            width: columnWidths[1],
                            child: Text(product.category,
                              style: const TextStyle(
                                color: Color(0xFFA6A6A6),
                              ),),
                          ),
                        ),
                        DataCell(
                          Container(
                            width: columnWidths[2],
                            child: Text(product.subCategory,
                              style: const TextStyle(
                                color: Color(0xFFA6A6A6),
                              ),),
                          ),
                        ),
                        DataCell(
                          Container(
                            width: columnWidths[3],
                            child: Text(product.unit,
                              style: const TextStyle(color: Color(0xFFA6A6A6),),
                            ),
                          ),
                        ),
                        DataCell(
                          Container(
                            width: columnWidths[4],
                            child: Text(product.price.toString(),  style: const TextStyle(color:
                            Color(0xFFA6A6A6),
                            ),),
                          ),
                        ),
                      ],
                      onSelectChanged: (selected) {
                        if (selected != null && selected) {
                          print('from first page');
                          print(filteredProducts);
                          print(product);

                          if(filteredProducts.length <=9){
                            context.go('/Product_View',
                                extra: {
                                  'product': product,
                                  'orderDetails': productList.map((detail) => OrderDetail(
                                    orderId: detail.prodId,
                                    orderDate: detail.productName,
                                    orderCategory: detail.category,
                                    items: [],
                                    // Add other fields as needed
                                  )).toList(),
                                });
                          }else {
                            context.go('/Product_View',
                                extra: {
                                  'product': product,
                                  'orderDetails': filteredProducts.map((detail) => OrderDetail(
                                    orderId: detail.prodId,
                                    orderDate: detail.productName,
                                    orderCategory: detail.category,
                                    items: [],
                                    // Add other fields as needed
                                  )).toList(),
                                });
                          }


                        }
                      },

                    );
                  }
                  )

              ),
            ),
          ),
        ],
      );
    });
  }


  List<Widget> _buildMenuItems(BuildContext context) {
    return [
      _buildMenuItem('Home', Icons.home_outlined, Colors.blue[900]!, '/Home'),
      _buildMenuItem('Customer', Icons.account_circle_outlined, Colors.blue[900]!, '/Customer'),
      Container(
          decoration: BoxDecoration(
            color: Colors.blue[800] ,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8), // Radius for top-left corner
              topRight: Radius.circular(8), // No radius for top-right corner
              bottomLeft: Radius.circular(8), // Radius for bottom-left corner
              bottomRight: Radius.circular(8), // No radius for bottom-right corner
            ),
          ),
          child: _buildMenuItem('Products', Icons.image_outlined, Colors.white, '/Product_List')),
      _buildMenuItem('Orders', Icons.warehouse_outlined, Colors.blue[900]!, '/Order_List'),
      _buildMenuItem('Delivery', Icons.fire_truck_outlined, Colors.blue[900]!, '/Delivery_List'),
      _buildMenuItem('Invoice', Icons.document_scanner_outlined, Colors.blue[900]!, '/Invoice'),
      _buildMenuItem('Payment', Icons.payment_outlined, Colors.blue[900]!, '/Payment_List'),
      _buildMenuItem('Return', Icons.keyboard_return, Colors.blue[900]!, '/Return_List'),
      _buildMenuItem('Reports', Icons.insert_chart_outlined, Colors.blue[900]!, '/Report_List'),

    ];
  }

  Widget _buildMenuItem(String title, IconData icon, Color iconColor, String route) {
    iconColor = _isHovered[title] == true ? Colors.blue : Colors.black87;
    title == 'Products'? _isHovered[title] = false :  _isHovered[title] = false;
    title == 'Products'? iconColor = Colors.white : Colors.black;
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

  void _sortProducts(int columnIndex, String sortOrder) {
    if (sortOrder == 'asc') {
      filteredProducts.sort((a, b) {
        switch (columnIndex) {
          case 0:
            return a.productName.toLowerCase().compareTo(b.productName.toLowerCase());
          case 1:
            return a.category.compareTo(b.category);
          case 2:
            return a.subCategory.compareTo(b.subCategory);
          case 3:
            return a.unit.compareTo(b.unit);
          case 4:
            return a.price.compareTo(b.price);
          default:
            return 0;
        }
      });
    } else if (sortOrder == 'desc') {
      filteredProducts.sort((a, b) {
        switch (columnIndex) {
          case 0:
            return b.productName.toLowerCase().compareTo(a.productName.toLowerCase());
          case 1:
            return b.category.compareTo(a.category);
          case 2:
            return b.subCategory.compareTo(a.subCategory);
          case 3:
            return b.unit.compareTo(a.unit);
          case 4:
            return b.price.compareTo(a.price);
          default:
            return 0;
        }
      });
    }
    setState(() {});
  }


  void _filterAndPaginateProducts() {
    filteredProducts = productList.where((product) {
      print('filter');
      print(filteredProducts);
      final matchesSearchText =
      product.productName.toLowerCase().contains(_searchText.toLowerCase());
      if (_category.isEmpty && _subCategory.isEmpty) {
        return matchesSearchText;
      }
      if(_category == 'Category' && _subCategory == 'Sub Category'){
        return matchesSearchText;
      }
      if(_category == 'Category' &&  _subCategory.isEmpty)
      {
        return matchesSearchText;
      }
      if(_subCategory == 'Sub Category' &&  _category.isEmpty)
      {
        return matchesSearchText;
      }
      if (_category == 'Category' && _subCategory.isNotEmpty) {
        return matchesSearchText && product.subCategory == _subCategory; // Include all products
      }
      if (_category.isNotEmpty && _subCategory == 'Sub Category') {
        return matchesSearchText && product.category == _category;// Include all products
      }
      if (_category.isEmpty && _subCategory.isNotEmpty) {
        return matchesSearchText && product.subCategory == _subCategory; // Include all products
      }
      if (_category.isNotEmpty && _subCategory.isEmpty) {
        return matchesSearchText && product.category == _category;// Include all products
      }
      return matchesSearchText &&
          (product.category == _category && product.subCategory == _subCategory);
    }).toList();

    // filteredProducts.sort((a, b) => a.productName.toLowerCase().compareTo(b.productName.toLowerCase()));
    totalPages = (filteredProducts.length / itemsPerPage).ceil();
    // final startIndex = (currentPage - 1) * itemsPerPage;
    // final endIndex = startIndex + itemsPerPage;
    //
    setState(() {
      currentPage = 1;
    });
  }

}


