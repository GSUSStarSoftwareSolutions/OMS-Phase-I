
import 'dart:async';
import 'dart:convert';
import 'dart:html';
import 'dart:math' as math;
import 'package:btb/Order%20Module/firstpage.dart';
import 'package:btb/admin/Api%20name.dart';
import 'package:btb/widgets/confirmdialog.dart';
import 'package:btb/widgets/productclass.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import '../../Order Module/add productmaster sample.dart';
import '../../widgets/custom loading.dart';
import '../../widgets/pagination.dart';

void main() => runApp(
    MaterialApp(home: CusSelectedProducts(product:
    Product(prodId: '', category: '',
        productName: '',
        subCategory: '',
        unit: '', qty: 0,
        selectedUOM: '',
        selectedVariation: '',
        quantity: 0, total: 0,
        totalAmount: 0,
        totalamount: 0,
        tax: '', discount: '',
        price: 0, imageId: ''),
        data: const {}, inputText: '',
        products: const [],
        notselect: '', subText: '',
        selectedProducts: const []),)
);


class CusSelectedProducts extends StatefulWidget {
  final List<Product> selectedProducts;
  final  Product product;
  final String notselect;
  final List<Product> products;
  final Map<String, dynamic> data;
  final String inputText;
  final String subText;

  const CusSelectedProducts(
      {super.key,
        required this.product,
        required this.data,
        required this.inputText,
        required this.products,
        required this.notselect,
        required this.subText,
        required this.selectedProducts});

  @override
  State<CusSelectedProducts> createState() => _CusSelectedProductsState();
}
class _CusSelectedProductsState extends State<CusSelectedProducts> {


  Order productToOrder(Product product) {
    return Order(
      prodId: product.prodId,
      price: product.price,
      productName: product.productName,
      proId: product.proId,
      category: product.category,
      subCategory: product.subCategory,
      selectedVariation: product.selectedVariation,
      selectedUOM: product.selectedUOM,
      totalamount: product.totalamount,
      total: product.total,
      tax: product.tax,
      quantity: product.quantity,
      discount: product.discount,
      imageId: product.imageId,
      unit: product.unit,
      totalAmount: product.totalAmount,
      qty: product.qty,
    );
  }
  bool _isFirstTime = true;
  List<Product> products = [];
  final _scrollController = ScrollController();
  double _total = 0;
  final Map<Product, TextEditingController> _controller = {};
  String? dropdownValue1 = 'Filter I';
  bool isOrdersSelected = false;
  List<Product> productList = [];
  String? _selectedValue1;
  Map<String, dynamic> data2 = {};
  bool _loading = false;
  bool isLoading = false;
  String? dropdownValue2 = 'Filter II';
  String token = window.sessionStorage["token"] ?? " ";
  String _searchText = '';
  int itemCount = 0;
  // int _pageSize = 10; // Define the page size (e.g., 10 items per page)
  final String _category = '';
  final int _quantity = 0;
  final String _subCategory = '';
  List<Product> allProducts = [];
  int itemsPerPage = 10;
  int totalPages = 0;
  // int startIndex = 0;
  String? _selectedValue;
  int currentPage = 1;
  Timer? _searchDebounceTimer;
  List<Product> filteredProducts = [];
  List<Product> selectedProducts = [];
  int _previousPage = 1;
  // int _currentPage = 1;
  int _startIndex = 0;
  // List<Product> productList = [];
  // int _totalPages = 1;
  List<Map<String, dynamic>> savedProducts = [];
  String userId = window.sessionStorage['userId'] ?? '';

  List<Product> _allProducts = [];
  int _currentPage = 1;
  int _totalPages = 1;
  int _pageSize = 10;
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
          ),child: _buildMenuItem('Orders', Icons.warehouse, Colors.white, '/Customer_Order_List')),
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
        List<Product> products = [];
        if (jsonData != null) {
          if (jsonData is List) {
            products = jsonData.map((item) => Product.fromJson(item)).toList();
          } else if (jsonData is Map && jsonData.containsKey('body')) {
            products = (jsonData['body'] as List).map((item) => Product.fromJson(item)).toList();
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

    filteredProducts.sort((a, b) => a.productName.toLowerCase().compareTo(b.productName.toLowerCase()));
    // final startIndex = (currentPage - 1) * itemsPerPage;
    // final endIndex = startIndex + itemsPerPage;
    //
    setState(() {
      currentPage = 1;
    });

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



  void _updateSearch(String searchText) {
    setState(() {
      _searchText = searchText;
      _currentPage = 1;  // Reset to first page when searching
      // _updateProductList();
      _filterAndPaginateProducts();
      // _clearSearch();
    });
  }





  @override
  void dispose() {
    _searchDebounceTimer?.cancel(); // Cancel the timer when the widget is disposed
    _controller.values.forEach((controller) => controller.dispose());
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

  void initState() {
    super.initState();
    fetchProduct();
    if(widget.subText == 'hii'){
      fetchProducts(_currentPage, _pageSize);
      print('hellllloo');
      print(widget.product);
      data2 = widget.data;
      print(data2);
      print(data2['actualamount']);

      data2['total'] = data2['actualamount'];
      //print(data2['actualAmount']);

      data2.remove('items');
      print(data2);
      for (var product in widget.selectedProducts) {
        _addProduct(product);
        // _calculateTotal();
      }
      // products.add(widget.product);
    }
    else if(widget.inputText == 'hello'){

      fetchProducts(_currentPage, _pageSize);
      print('ordermodule');
      print(widget.selectedProducts);
      print('add product master');

      data2 = widget.data;

      // data2['total'] = data2['actualamount'].toString();
      //_total = double.parse(data2['total'] ?? 0);
      // _total = double.parse(data2['total']);
      //_total = data2['total'];
      print('total');
      print(_total);

      // remove.data2['items'];
      print(data2);
      for (var product in widget.selectedProducts) {
        _addProduct(product);
        _calculateTotal();
      }
    }
    else{
      fetchProducts(_currentPage, _pageSize);
      print('--song--');
      print(widget.product);
      products.add(widget.product);
      products.addAll(widget.selectedProducts);
      print('product---');
      print(products);
      print(widget.data);
      print(widget.data['total']);
      print(widget.data['Comments']);

      print('data2');
      data2 = widget.data;
      print(data2);
      _calculateTotal();
      print('----select');
      print(widget.selectedProducts);
    }
  }

  void _addProduct(Product product) {
    setState(() {
      products.insert(0, product);
      _calculateTotal();
    });
    //_navigateToSelectedProductPage();
  }

  void _handleAddButtonPress(Product product) {
    bool productExists = false;
    for (var existingProduct in products) {
      if (existingProduct.productName == product.productName && existingProduct.category == product.category && existingProduct.subCategory == product.subCategory) {
        productExists = true;
        existingProduct.quantity += product.quantity;
        existingProduct.total = (existingProduct.price * existingProduct.quantity) as double;
        break;
      }
    }
    if (!productExists) {
      Product newProduct = Product(
        productName: product.productName,
        category: product.category,
        subCategory: product.subCategory,
        selectedUOM: product.selectedUOM,
        selectedVariation: product.selectedVariation,
        discount: product.discount,
        proId: product.proId,
        price: product.price,
        tax: product.tax,
        unit: product.unit,
        quantity: product.quantity,
        total: product.total,
        totalamount: product.totalamount,
        prodId: '',
        imageId: '',
        totalAmount: product.totalAmount,
        qty: product.qty,
      );
      _addProduct(newProduct);
    }
    _calculateTotal();
    setState(() {});
  }


  void _deleteProduct(int index) {
    setState(() {
      products.removeAt(index);
      _calculateTotal();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xFFF0F4F8),
        appBar:
        AppBar(
          leading: null,
          automaticallyImplyLeading: false,
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
              child:AccountMenu(),

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
                    right: 0,
                    top: 0,
                    bottom: 0,
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          color: Colors.white,
                          height: 50,
                          child: Row(
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(left: 30,top: 5),
                                child: Text(
                                  'Selected Products',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                              const Spacer(),
                              Align(
                                alignment: Alignment.topLeft,
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 86,top: 10),
                                  child: Builder(
                                    builder: (context) {
                                      return OutlinedButton(
                                        onPressed: () {
                                          print('button');
                                          if(products.isEmpty ){
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(
                                                content: Text('Please select minimum one product'),
                                              ),
                                            );
                                          }
                                          else {
                                            print('else');
                                            if (products.isNotEmpty &&
                                                widget.inputText == '') {
                                              print('----weellls');
                                              print(data2);


                                              print(products);
                                              context.go(
                                                  '/Add_to_cart',
                                                  extra: {
                                                    'selectedProducts': products,
                                                    'data': data2,
                                                    'select': '',
                                                  });
                                            }
                                            else {
                                              data2['items'].forEach((item) => item['totalAmount'] = item['actualAmount']);
                                              List<Order> orders = widget
                                                  .selectedProducts.map((
                                                  product) =>
                                                  product.productToOrder())
                                                  .toList();
                                              print(
                                                  '-------order data'
                                              );
                                              print('product what i want');
                                              print(products);
                                              if (data2['total'] == 0 || data2['total'] == '0') {
                                                //  _total = 0;
                                              } else {
                                                if (data2['total'] is int) {
                                                  _total = _total == 0 ? data2['total'].toDouble() : _total;
                                                } else if (data2['total'] is String) {
                                                  _total = _total == 0 ? double.parse(data2['total']) : _total;
                                                }
                                              }

                                              print(_total);
                                              data2['total'] = _total.toString();
                                              print(data2['total']);
                                              context.go(
                                                  '/Draft_Edit', extra: {
                                                'selectedProducts': products,
                                                'data': data2,
                                              });
                                            }
                                            print('----Nothing else----');
                                            print(products);
                                          }
                                        },

                                        style: OutlinedButton.styleFrom(
                                          backgroundColor: Colors.blue[800],
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(5),
                                          ),
                                          side: BorderSide.none,
                                        ),
                                        child: const Text(
                                          "Save Products",
                                          style: TextStyle(color: Colors.white, fontSize: 15),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top:
                          0, left: 0),
                          child: Container(
                            margin: const EdgeInsets.symmetric(
                                vertical: 1), // Space above/below the border
                            height: 0.2,

                            // width: 1500,
                            width: constraints.maxWidth,// Border height
                            color: Colors.black, // Border color
                          ),
                        ),
                        Expanded(child: SingleChildScrollView(
                          controller: _scrollController,
                          child: Column(children: [
                            buildSearchAndTable(),
                            buildresultTable(),
                          ],),))
                      ],
                    ),
                  )
                ],
              );
            }
        )
    );
  }

  Widget buildMainContent() {
    return Center(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Container(
          height: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.1), // Soft grey shadow
                spreadRadius: 1,
                blurRadius: 3,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          padding: const EdgeInsets.only(top: 80),
          //  width: MediaQuery.of(context).size.width * 0.8,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 1111),
              buildresultTable(),
              const SizedBox(
                height: 1111,
              ),
              buildSearchField(),
              const SizedBox(height: 5),
              buildDataTable(),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildSearchAndTable() {
    return Padding(
      padding: const EdgeInsets.only(top: 0),
      child:
      Card(
        color: Colors.white,
        margin: const EdgeInsets.only(left: 150, right: 100),
        shape: RoundedRectangleBorder(
          // borderRadius: BorderRadius.circular(5),
          side: BorderSide(
            color: Colors.grey.withOpacity(0.1),
            width: 1.0,
          ),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
          ],
        ),
      ),
    );
  }

  Widget buildresultTable() {
    double maxWidth = MediaQuery.of(context).size.width;
    double maxHeight = MediaQuery.of(context).size.height;
    return Padding(
      padding: const EdgeInsets.only(top: 100),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(left: 50, right: 100),
            // surfaceTintColor: const Color(0XFFFDFAFD),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildSearchField1(),
                const SizedBox(height: 1),
                //new one
                Container(
                  decoration: const BoxDecoration(
                    border: Border(
                      top: BorderSide(color:  Colors.grey, width: 1.2),
                      bottom: BorderSide(color:  Colors.grey, width: 1.2),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 5,bottom: 5),
                    child: Table(
                      // border: TableBorder.all(color: Colors.grey),
                      columnWidths: const {
                        0: FlexColumnWidth(1),
                        1: FlexColumnWidth(2.7),
                        2: FlexColumnWidth(2),
                        3: FlexColumnWidth(1.8),
                        4: FlexColumnWidth(2),
                        5: FlexColumnWidth(1),
                        6: FlexColumnWidth(2),
                        7:FlexColumnWidth(1),
                        // 8:FlexColumnWidth(2),

                      },
                      children: const [
                        TableRow(
                          children: [
                            TableCell(
                              child: Padding(
                                padding: EdgeInsets.only(
                                  // left: 10,
                                  //   right: 10,
                                  top: 15,
                                  bottom: 5,
                                ),
                                child: Center(child: Text('SN',style: TextStyle(fontWeight: FontWeight.bold),)),
                              ),
                            ),
                            TableCell(
                              child: Padding(
                                padding: EdgeInsets.only(
                                  // left: 10,
                                  // right: 10,
                                  top: 15,
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
                                  top: 15,
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
                                  top: 15,
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
                                  top: 15,
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
                                  top: 15,
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
                                  top: 15,
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
                                  top: 15,
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
                products.isEmpty
                    ? const Center(child: Text('No data available'))
                    : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    Product product = products[index];
                    return Table(
                      border: const TableBorder(
                        bottom: BorderSide(width:1 ,color: Colors.grey),
                        //   horizontalInside: BorderSide(width: 1,color: Colors.grey), // horizontal border inside the table
                        verticalInside: BorderSide(width: 1,color: Colors.grey),
                      ),
                      columnWidths: const {
                        0: FlexColumnWidth(1),
                        1: FlexColumnWidth(2.7),
                        2: FlexColumnWidth(2),
                        3: FlexColumnWidth(1.8),
                        4: FlexColumnWidth(2),
                        5: FlexColumnWidth(1),
                        6: FlexColumnWidth(2),
                      },
                      children: [
                        TableRow(
                          children: [
                            TableCell(
                              child: Padding(
                                padding: const EdgeInsets.only(left: 10, right: 10, top: 15, bottom: 5),
                                child: Center(
                                  child: Text(
                                    (index + 1).toString(),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ),
                            TableCell(
                              child: Padding(
                                padding: const EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10),
                                child: Container(
                                  height: 35,
                                  width: 50,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(4.0),
                                  ),
                                  child: Center(
                                    child: Text(
                                      product.productName,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            TableCell(
                              child: Padding(
                                padding: const EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10),
                                child: Container(
                                  height: 35,
                                  width: 50,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(4.0),
                                  ),
                                  child: Center(
                                    child: Text(
                                      product.category,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            TableCell(
                              child: Padding(
                                padding: const EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10),
                                child: Container(
                                  height: 35,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(4.0),
                                  ),
                                  child: Center(
                                    child: Text(
                                      product.subCategory,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            TableCell(
                              child: Padding(
                                padding: const EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10),
                                child: Container(
                                  height: 35,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(4.0),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${product.price}',
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            TableCell(
                              child: Padding(
                                padding: const EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10),
                                child: Container(
                                  height: 35,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(4.0),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${product.quantity = product.quantity == 0 ? product.qty : product.quantity}',
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            TableCell(
                              child: Padding(
                                padding: const EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10),
                                child: Container(
                                  height: 35,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(4.0),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${product.total = product.total == 0 ? product.totalAmount : product.total}',
                                      // (product.price * product.quantity).toString(),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            TableCell(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 20),
                                child: InkWell(
                                  onTap: () {
                                    _deleteProduct(products.indexOf(product));
                                  },
                                  child: const Icon(
                                    Icons.remove_circle_outline,
                                    size: 18,
                                    color: Colors.blue,
                                  ),
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
          ),
          Padding(
            padding: EdgeInsets.only(top: 30,
                right: maxWidth *0.12),
            child: Align(
              alignment: Alignment.topRight,
              child: SizedBox(
                width: 220,
                height: 50,
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.blue),
                      borderRadius: BorderRadius.circular(4)
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(
                      top: 20,
                      bottom: 10,
                      left: 10,
                      right: 5,
                    ),
                    child: RichText(
                      text: TextSpan(
                        children: [
                          const TextSpan(
                            text: '         ', // Add a space character
                            style: TextStyle(
                              fontSize: 10, // Set the font size to control the width of the gap
                            ),
                          ),
                          const TextSpan(
                            text: 'Total',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                          const TextSpan(
                            text: '             ', // Add a space character
                            style: TextStyle(
                              fontSize: 10, // Set the font size to control the width of the gap
                            ),
                          ),
                          const TextSpan(
                            text: '₹',
                            style: TextStyle(
                              color: Colors.black,
                            ),
                          ),
                          // TextSpan(
                          //   text: _total == 0 ? data2['total']?.toString(): _total.toString(),
                          //   style: const TextStyle(
                          //     color: Colors.black,
                          //   ),
                          // ),
                          TextSpan(
                            text: _total == 0 ? data2['total'].toString(): _total.toString(),
                            style: const TextStyle(
                              color: Colors.black,
                            ),
                          ),

                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 80,),
          Container(
            width: maxWidth,
            // height: maxHeight * 0.9,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.1), // Soft grey shadow
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            margin: const EdgeInsets.only(left: 50, right: 100,bottom: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                buildSearchField(),
                const SizedBox(height: 5),
                buildDataTable(),
                // Scrollbar(
                //   controller: _scrollController,
                //   thickness: 6,
                //   thumbVisibility: true,
                //   child: SingleChildScrollView(
                //     controller: _scrollController,
                //     scrollDirection: Axis.horizontal,
                //     child: buildDataTable(),
                //   ),
                // ),
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
        ],
      ),
    );
  }

  Widget buildSearchField1() {
    return
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding:const  EdgeInsets.all(16.0),
                decoration:  BoxDecoration(
                  color: Colors.blue.shade600,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8.0),
                    topRight: Radius.circular(8.0),
                  ),
                ),
                child: const Text(
                  'Selected Products',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  // borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.blue[100]!),
                ),
              ),
            ],
          ),
        ],
      );
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

  Widget buildSearchField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                //   border: Border.all(color: Colors.green),
                color: Colors.blue.shade900,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8.0),
                  topRight: Radius.circular(8.0),
                ),
              ),
              child: const Text(
                'Search Products',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 5),
            Padding(
              padding: const EdgeInsets.only(right: 800,left: 30,top: 10,bottom: 10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4.0),
                ),
                child:  SizedBox(
                  height: 40,
                  width: 350,
                  child:  TextFormField(
                    //controller: ,
                    decoration:  InputDecoration(
                      prefixIcon: Icon(Icons.search,color: Colors.blue[800],
                      ),
                      hintText: 'Search for products',
                      contentPadding:  const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0),
                        borderSide: const BorderSide(color: Colors.grey), // Added blue border
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
                    //int _previousPage = 1; // Store the previous page number
                    onChanged: _updateSearch,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
      ],
    );
  }

  Widget buildDataTable() {
    double maxWidth = MediaQuery.of(context).size.width;
    double maxHeight = MediaQuery.of(context).size.height;

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

    return
      SizedBox(
        //  height: maxHeight * 0.15, // set the desired height
        width:
        maxWidth, // set the desired width// change contianer width in this place
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
              itemCount:  math.min(itemsPerPage, filteredProducts.length - (currentPage - 1) * itemsPerPage),
              //     itemCount: filteredProducts.length,
              itemBuilder: (context, index) {
                final product =filteredProducts[(currentPage - 1) * itemsPerPage + index];
                //final product = productList[index];
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
                            child: Container(
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
                          child:  Padding(
                            padding: const EdgeInsets.only(left: 10,right: 10,  top: 5,
                                bottom: 5),
                            child: IconButton(
                              onPressed: () {
                                if (product.quantity == null || product.quantity == 0) {
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
                                          },
                                        ),
                                      ],
                                    ),
                                  );
                                } else {
                                  _handleAddButtonPress(product);
                                  _scrollController.jumpTo(0);
                                  setState(() {
                                    product.quantity = 0;
                                    product.total = 0;

                                    _controller[product]?.clear();
                                  });
                                }
                              },
                              icon: const Icon(
                                Icons.add_circle_rounded,
                                color: Colors.blue,
                              ),
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
    return
      Align(
        alignment: Alignment.topLeft,
        child: Container(
          width: 200,
          height: 984,
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
    if (products.isEmpty) {
      print('---its working');
      data2['total'] = 0;
    }
    double total = 0;
    for (var product in products) {
      total += product.total;
    }
    // setState(() {});
    setState(() {
      _total = total;
    });
  }


}


