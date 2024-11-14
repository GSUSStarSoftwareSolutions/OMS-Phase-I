import 'dart:async';
import 'dart:convert';
import 'dart:html';

import 'package:btb/Order%20Module/firstpage.dart';
import 'package:btb/admin/Api%20name.dart';
import 'package:btb/widgets/confirmdialog.dart';
import 'package:btb/widgets/productclass.dart' as ord;
import 'package:flutter/cupertino.dart';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;

import '../../widgets/custom loading.dart';
import '../../widgets/pagination.dart';
import '../../widgets/productclass.dart';


class CusOrderPage3 extends StatefulWidget {
  final Map<String, dynamic> data;
  final String string;
  const CusOrderPage3({super.key, required this.data,required this.string});
  @override
  CusOrderPage3State createState() => CusOrderPage3State();
}

class CusOrderPage3State extends State<CusOrderPage3> {
  int itemCount = 0;
  List<Product> products = [];
  double _total = 0;
  String? dropdownValue1 = 'Filter I';
  bool isOrdersSelected = false;
  List<Product> productList = [];
  String? dropdownValue2 = 'Filter II';
  String token = window.sessionStorage["token"] ?? " ";
  String _searchText = '';
  String? _selectedValue1;
  int itemsPerPage = 10;
  bool _isRowHovered = false;
  int totalItems = 0;
  int totalPages = 0;
  String? _selectedValue;
  final String _category = '';
  final String _subCategory = '';
  int startIndex = 0;
  int currentPage = 1;
  Timer? _searchDebounceTimer;
  bool _loading = false;
  final _scrollController = ScrollController();
  Map<String, dynamic> data1 = {};
  List<Product> filteredProducts = [];
  List<Product> selectedProducts = [];
  List<String> variationList = ['Select', 'Variation 1', 'Variation 2'];
  String selectedVariation = 'Select';
  int _currentPage = 1;
  int _totalPages = 1;
  int _pageSize = 10;
  final Map<Product, TextEditingController> _controller = {};
  String userId = window.sessionStorage['userId'] ?? '';

  List<Product> _allProducts = [];
  List<String> uomList = ['Select', 'UOM 1', 'UOM 2'];
  String selectedUOM = 'Select';
  bool isLoading = false;

  Map<String, bool> _isHovered = {
    'Orders': false,
    'Invoice': false,
    'Delivery': false,
    'Payment': false,
    'Return': false,
  };


  List<Widget> _buildMenuItems(BuildContext context) {
    return [
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
          ),child: _buildMenuItem('Orders', Icons.warehouse, Colors.blueAccent, '/Customer_Order_List')),
      _buildMenuItem('Invoice', Icons.document_scanner_rounded, Colors.blue[900]!, '/Customer_Invoice_List'),
      _buildMenuItem('Delivery', Icons.fire_truck_outlined, Colors.blue[900]!, '/Customer_Delivery_List'),
      _buildMenuItem('Payment', Icons.payment_outlined, Colors.blue[900]!, '/Customer_Payment_List'),
      _buildMenuItem('Return', Icons.backspace_sharp, Colors.blue[900]!, '/Customer_Return_List'),
    ];
  }

  Widget _buildMenuItem(String title, IconData icon, Color iconColor, String route) {
    iconColor = _isHovered[title] == true ? Colors.blue : Colors.black87;
    title == 'Orders'? _isHovered[title] = false :  _isHovered[title] = false;
    title == 'Orders'? iconColor = Colors.white : Colors.black;
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




  @override
  void initState() {
    super.initState();
    fetchProduct();
    if(widget.string == 'arrow_back'){
      print(widget.data);
      widget.data;
    }

    //_selectedValue1 = widget.subText;
    data1 = widget.data;
    print('-------selectlist');
    print(data1);
    fetchProducts(_currentPage, _pageSize);
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

  void _updateProductList() {
    final filteredProducts = _allProducts
        .where((product) => product.productName
        .toLowerCase()
        .contains(_searchText.toLowerCase()))
        .toList();

    final startIndex = (_currentPage - 1) * _pageSize;
    final endIndex = startIndex + _pageSize;

    setState(() {
      productList = filteredProducts
          .sublist(startIndex, endIndex > filteredProducts.length ? filteredProducts.length : endIndex);
    });
  }


  void _updateSearch(String value) {
    setState(() {
      _searchText = value;
      _filterAndPaginateProducts();
    });

  }

  Future<void> fetchProduct() async {

    try {
      final response = await http.get(
        Uri.parse(
          '$apicall/order_master/get_all_draft_master'
        ),
        headers: {
          "Content-type": "application/json",
          "Authorization": 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
// print('json data');
// print(jsonData);
        List<detail> products = [];
        if (jsonData != null) {
          if (jsonData is List) {
            products = jsonData.map((item) => detail.fromJson(item)).toList();
          }
          else if (jsonData is Map && jsonData.containsKey('body')) {
            products = (jsonData['body'] as List)
                .map((item) => detail.fromJson(item))
                .toList();

          }
          List<detail> matchedCustomers = products.where((customer) {  return customer.CusId == userId;}).toList();

          if (matchedCustomers.isNotEmpty) {
            setState(() {

              print('pages');
              itemCount = products.length;

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
      if (mounted) {
      }
    }
  }
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

  void _filterAndPaginateProducts() {
    filteredProducts = productList.where((product) {

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

    filteredProducts.sort((a, b) => a.productName.toLowerCase().compareTo(b.productName.toLowerCase()));
    setState(() {
      currentPage = 1;
    });

  }


  @override
  void dispose() {
    _searchDebounceTimer
        ?.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
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
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
          backgroundColor: const Color(0xFFF0F4F8),
          appBar:
          AppBar(
            leading: null,
            automaticallyImplyLeading: false,
            title: Image.asset("images/Final-Ikyam-Logo.png"),
            backgroundColor: const Color(0xFFFFFFFF),
            // Set background color to white
            elevation: 4.0,
            shadowColor: const Color(0xFFFFFFFF),
            // Set shadow color to black
            actions: [
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Stack(
                    clipBehavior: Clip.none, // This ensures the badge can be positioned outside the icon bounds
                    children: [
                      IconButton(
                        icon: const Icon(Icons.shopping_cart),
                        onPressed: () {
                          context.go('/Customer_Draft_List');
                          // Handle notification icon press
                        },
                      ),
                      Positioned(
                        right: 0,
                        top: -5, // Adjust this value to move the text field
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.red, // Background color of the badge
                            shape: BoxShape.circle,
                          ),
                          child:  Text(
                            '${itemCount}', // The text field value (like a badge count)
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12, // Adjust the font size as needed
                            ),
                          ),
                        ),
                      ),
                    ],
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
              builder: (context, constraints){
                double maxHeight = constraints.maxHeight;
                double maxWidth = constraints.maxWidth;
                return Stack(
                  children: [
                    buildSideMenu(),
                    Padding(
                      padding: const EdgeInsets.only(left: 200,top: 0),
                      child: Container(
                        width: 1.8, // Set the width to 1 for a vertical line
                        height: maxHeight, // Set the height to your liking
                        decoration: const BoxDecoration(
                          border: Border(left: BorderSide(width: 1, color: Colors.grey)),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 201,
                      top: 1,
                      right: 0,
                      height: kToolbarHeight,
                      child: Container(
                        color: const Color(0xFFFFFDFF),
                        height: 50,
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back), // Back button icon
                              onPressed: () {
                                context.go('/Customer_Order_List');
                              },
                            ),
                            const Padding(
                              padding: EdgeInsets.only(left: 30),
                              child: Text(
                                'Go back',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.left,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 45, left: 200),
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                            vertical: 10), // Space above/below the border
                        height: 0.8,
                        // width: 1500,
                        width: constraints.maxWidth,// Border height
                        color: Colors.black87, // Border color
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.only(top: 120,left: 300,bottom: 20,right: 100),
                      child: Container(
                        height: 830,
                        width: maxWidth,
                        // margin: const EdgeInsets.only(left: 300, right: 100,bottom: 15),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: SizedBox(
                            width: maxWidth * 0.79,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [

                                Container(
                                  width: maxWidth,
                                  height: 50,
                                  padding: const EdgeInsets.only(top: 10),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade900,
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(8.0),
                                      topRight: Radius.circular(8.0),
                                    ),
                                  ),
                                  child:const Padding(
                                    padding: EdgeInsets.only(left: 30),
                                    child: Text(
                                      'Search Products',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20.0,
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(right: 800,left: 30,top: 20,bottom: 20),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                    decoration: BoxDecoration(
                                      // color: Colors.grey.shade200,
                                      borderRadius: BorderRadius.circular(4.0),
                                    ),
                                    child:  SizedBox(
                                      height: 40,
                                      width: maxWidth * 0.2,
                                      child:   TextField(
                                        decoration: InputDecoration(
                                          prefixIcon: Icon(Icons.search,color: Colors.blue[800],),
                                          hintText: 'Search for products',
                                          contentPadding:  const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 8),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(5.0),
                                            borderSide: const BorderSide(color: Colors.blue), // Added blue border
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(5.0),
                                            borderSide: const BorderSide(color: Colors.grey), // Added blue border
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(5.0),
                                            borderSide: const BorderSide(color: Colors.blue), // Added blue border
                                          ),
                                        ),
                                        onChanged: _updateSearch,
                                      ),
                                    ),
                                  ),
                                ),
                                buildDataTable(),
                                Padding(
                                  padding: const EdgeInsets.only(right:30),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      PaginationControls(
                                        currentPage: currentPage,
                                        totalPages: filteredProducts.length > itemsPerPage ? totalPages : 1,//totalPages//totalPages,
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
                  ],
                );
              }
          )
      ),
    );
  }



  //original
  Widget buildDataTable() {
    if (isLoading) {
      var width = MediaQuery.of(context).size.width;
      var Height = MediaQuery.of(context).size.height;
      _loading = true;
      // Show loading indicator while data is being fetched
      return Padding(
        padding: EdgeInsets.only(bottom: Height * 0.100,left: width * 0.300,top: Height * 0.100),
        child: CustomLoadingIcon(), // Replace this with your custom GIF widget
      );
    }
    if (filteredProducts.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: 250,left: 50,bottom: 250),
        child: Center(
          child: Text('Searched products not found'),
        ),
      );
    }

    double maxWidth = MediaQuery.of(context).size.width;
    return
      SizedBox(
        //  height: 592.5, // set the desired height
        width: maxWidth,
        //  width: maxWidth * 0.74, // set the desired width// change contianer width in this place
        child: Column(
          children: [
            Container(
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: Color(0xFFB2C2D3), width: 1.2),
                  bottom: BorderSide(color: Color(0xFFB2C2D3), width: 1.2),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.only(top: 5,bottom: 5),
                child: Table(
                  // border: TableBorder.all(color: Colors.grey),
                  columnWidths: const {
                    0: FlexColumnWidth(2.3),
                    1: FlexColumnWidth(2),
                    2: FlexColumnWidth(1.8),
                    3: FlexColumnWidth(1.7),
                    4: FlexColumnWidth(1),
                    5: FlexColumnWidth(1.5),
                    6:FlexColumnWidth(1),
                    // 8:FlexColumnWidth(2),

                  },
                  children: const [
                    TableRow(
                      children: [
                        TableCell(
                          child: Padding(
                            padding: EdgeInsets.only(
                              // left: 10,
                              // right: 10,
                              top: 5,
                              bottom: 5,
                            ),
                            child: Center(child: Text('Product Name',style: TextStyle(fontWeight: FontWeight.bold),)),
                          ),
                        ),
                        TableCell(
                          child: Padding(
                            padding: EdgeInsets.only(
                              // left: 10,
                              // right: 10,
                              top: 5,
                              bottom: 5,
                            ),
                            child: Center(child: Text('Category',style: TextStyle(fontWeight: FontWeight.bold),)),
                          ),
                        ),
                        TableCell(
                          child: Padding(
                            padding: EdgeInsets.only(
                              // left: 10,
                              // right: 10,
                              top: 5,
                              bottom: 5,
                            ),
                            child: Center(child: Text('Sub Category',style: TextStyle(fontWeight: FontWeight.bold),)),
                          ),
                        ),
                        TableCell(
                          child: Padding(
                            padding: EdgeInsets.only(
                              // left: 10,
                              // right: 10,
                              top: 5,
                              bottom: 5,
                            ),
                            child: Center(child: Text('Price',style: TextStyle(fontWeight: FontWeight.bold),)),
                          ),
                        ),
                        TableCell(
                          child: Padding(
                            padding: EdgeInsets.only(
                              // left: 10,
                              // right: 10,
                              top: 5,
                              bottom: 5,
                            ),
                            child: Center(child: Text('QTY',style: TextStyle(fontWeight: FontWeight.bold),)),
                          ),
                        ),
                        TableCell(
                          child: Padding(
                            padding: EdgeInsets.only(
                              // left: 10,
                              // right: 10,
                              top: 5,
                              bottom: 5,
                            ),
                            child: Center(child: Text('Total Amount',style: TextStyle(fontWeight: FontWeight.bold),)),
                          ),
                        ),
                        TableCell(
                          child: Padding(
                            padding: EdgeInsets.only(
                              // left: 10,
                              // right: 10,
                              top: 5,
                              bottom: 5,
                            ),
                            child: Center(child: Text('        ')),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: math.min(itemsPerPage, filteredProducts.length - (currentPage - 1) * itemsPerPage),
              //     itemCount: filteredProducts.length,
              itemBuilder: (context, index) {
                final product =filteredProducts[(currentPage - 1) * itemsPerPage + index];
                //Product product = filter
                // edProducts[index];
                if (!_controller.containsKey(product)) {
                  _controller[product] = TextEditingController();
                }
                return Table(
                  border: const TableBorder(
                    bottom: BorderSide(width:1 ,color: Colors.grey),
                    //   horizontalInside: BorderSide(width: 1,color: Colors.grey), // horizontal border inside the table
                    verticalInside: BorderSide(width: 1,color: Colors.grey),
                  ),
                  //   border: TableBorder.symmetric(
                  //     inside: BorderSide(color: Color(0xFFB2C2D3), width: 1),
                  //
                  // ),
                  // Add this line
                  columnWidths: const {
                    0: FlexColumnWidth(2.3),
                    1: FlexColumnWidth(2),
                    2: FlexColumnWidth(1.8),
                    3: FlexColumnWidth(1.7),
                    4: FlexColumnWidth(1),
                    5: FlexColumnWidth(1.5),
                    6: FlexColumnWidth(1),
                  },
                  children: [
                    TableRow(
                      children: [
                        TableCell(
                          child: Padding(
                            padding: const EdgeInsets.only(
                                left: 10,
                                right: 10,
                                top: 10,
                                bottom: 10),
                            child: Container(
                              height: 35,
                              decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(4.0)
                              ),
                              child: Center(
                                child: Text(
                                  product.productName,
                                ),
                              ),
                            ),
                          ),
                        ),
                        TableCell(
                          child: Padding(
                            padding: const EdgeInsets.only(
                                left: 10,
                                right: 10,
                                top: 10,
                                bottom: 10),
                            child: Container(
                              height: 35,
                              decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(4.0)
                              ),
                              child: Center(
                                child: Text(
                                  product.category,
                                  textAlign: TextAlign
                                      .center,
                                ),
                              ),
                            ),
                          ),
                        ),
                        TableCell(
                          child: Padding(
                            padding: const EdgeInsets.only(
                                left: 10,
                                right: 10,
                                top: 10,
                                bottom: 10),
                            child: Container(
                              height: 35,
                              decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(4.0)
                              ),
                              child: Center(
                                child: Text(
                                  product.subCategory,
                                  textAlign: TextAlign
                                      .center,
                                ),
                              ),
                            ),
                          ),
                        ),
                        TableCell(
                          child: Padding(
                            padding: const EdgeInsets.only(
                                left: 10,
                                right: 10,
                                top: 10,
                                bottom: 10),
                            child: Container(
                              height: 35,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4.0),
                                color: Colors.grey.shade200,
                              ),
                              child: Center(
                                child: Text(
                                  product.price.toString(),
                                  textAlign: TextAlign
                                      .center,
                                ),
                              ),
                            ),
                          ),
                        ),
                        TableCell(
                          child: Padding(
                            padding: const EdgeInsets.only(
                                left: 10,
                                right: 10,
                                top: 10,
                                bottom: 10),
                            child:
                            Container(
                              height: 35,
                              decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(4.0)
                              ),
                              child: Center(
                                child: TextFormField(
                                  controller: _controller[product],
                                  inputFormatters: [
                                    LengthLimitingTextInputFormatter(4),
                                    FilteringTextInputFormatter.allow(
                                        RegExp("[0-9]")),
                                    // Allow only letters, numbers, and single space
                                    FilteringTextInputFormatter.deny(
                                        RegExp(r'^\s')),
                                    // Disallow starting with a space
                                    FilteringTextInputFormatter.deny(
                                        RegExp(r'\s\s')),
                                    // Disallow multiple spaces
                                  ],
                                  autofocus: true,
                                  //initialValue: '',
                                  onChanged: (value){
                                    setState(() {
                                      product.quantity = int.tryParse(value) ?? 0;
                                      product.total = (product.price * product.quantity) as double;
                                      _calculateTotal();
                                    });
                                  },
                                  // onChanged: (value){
                                  //   setState(() {
                                  //     product.quantity = int.tryParse(value) ?? 0;
                                  //     product.total = (product.price * product.quantity) as double;
                                  //     _calculateTotal();
                                  //   });
                                  // },
                                  decoration: const InputDecoration(
                                      border:
                                      InputBorder.none,
                                      contentPadding: EdgeInsets.only(
                                          bottom: 12
                                      )
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                        ),
                        TableCell(
                          child: Padding(
                            padding: const EdgeInsets.only(
                                left: 10,
                                right: 10,
                                top: 10,
                                bottom: 10),
                            child: Container(
                              height: 35,
                              decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(4.0)
                              ),
                              child: Center(
                                child: Text(
                                  product.total.toString(),
                                  textAlign: TextAlign
                                      .center,
                                ),
                              ),
                            ),
                          ),
                        ),
                        TableCell(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 7,bottom: 3),
                            child: IconButton(
                              icon:  Icon(
                                Icons.add_circle_rounded,
                                color: Colors.blue[800],
                              ),
                              onPressed: () {
                                if (product.quantity == null || product.quantity == 0) {
                                  // Show a popup to fill the quantity field
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Error'),
                                      content: const Text('Please fill the quantity field'),
                                      actions: [
                                        TextButton(
                                          child: const Text('OK'),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                            //  Navigator.of(context).pop();
                                          },
                                        ),
                                      ],
                                    ),
                                  );
                                } else {
                                  print('---data1');
                                  print(Product);
                                  context.go(
                                    '/Selected_product_item',
                                    extra: {
                                      'selectedProducts': <Product>[],  // Empty but explicitly typed list
                                      'product': product,  // Pass the correct Product object
                                      'data':data1,// Pass the Map<String, dynamic> object
                                      'inputText': '',  // Pass empty string
                                      'subText': '',  // Pass empty string
                                      'products': <Product>[],  // Another empty but explicitly typed list
                                      'notselect': '',  // Pass empty string
                                    },
                                  );
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      );
    // );
  }



  Widget buildSideMenu() {
    return Align(
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
    );
  }


  void _calculateTotal() {
    double total = 0;
    for (var product in products) {
      total += product.total;
    }
    setState(() {
      _total = total;
    });
  }


}

