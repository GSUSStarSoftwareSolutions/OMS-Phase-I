import 'dart:convert';
import 'dart:html';
import 'package:adaptive_scrollbar/adaptive_scrollbar.dart';
import 'package:btb/Order%20Module/firstpage.dart';
import 'package:btb/admin/Api%20name.dart';
import 'package:btb/widgets/image%20loading.dart';
import 'package:btb/widgets/productclass.dart' as ord;
import 'package:flutter/foundation.dart' show Uint8List, kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../widgets/confirmdialog.dart';

void main() {
  runApp(const ProductForm1(
    product: null,
    prodId: '',
    priceText: '',
    productText: '',
    selectedvalue2: '',
    discountText: '',
    selectedValue: '',
    selectedValue1: '',
    selectedValue3: '',
    imagePath: null,
    displayData: {},
    orderDetails: [],
  ));
}

class ProductForm1 extends StatefulWidget {
  const ProductForm1({
    super.key,
    required this.product,
    required this.prodId,
    required this.priceText,
    this.productdetails,
    required this.productText,
    required this.selectedvalue2,
    required this.discountText,
    required this.orderDetails,
    required this.selectedValue,
    required this.selectedValue1,
    required this.selectedValue3,
    required this.imagePath,
    required this.displayData,
  });

  final ord.Product? product;
  final String? priceText;
  final Map displayData;
  final List<dynamic>? productdetails;
  final String? productText;
  final List<dynamic>? orderDetails;
  final String? prodId;
  final String? selectedvalue2;
  final String? discountText;
  final String? selectedValue;
  final String? selectedValue1;
  final String? selectedValue3;
  final Uint8List? imagePath;

  @override
  State<ProductForm1> createState() => _ProductForm1State();
}

class _ProductForm1State extends State<ProductForm1> {
  String? _textInput;
  String? _priceInput;
  Map<String, dynamic> _displayData = {};
  String? discountInput;
  String storeImage = '';
  String? imageId = '';
  List<bool> _isSelected = [];
  var result;
  List<ord.Product> selectedProductList = [];
  String token = window.sessionStorage["token"] ?? " ";
  final ProId = TextEditingController();
  String searchText = ''; // Variable to store search text
  final ProCat = TextEditingController();
  String? pickedImagePath;
  bool _isFirstLoad = true;
  int selectedIndex = -1;
  bool isOrdersSelected = false;
  bool isImageBase64 = false;
  Uint8List? imageStore;
  List<ord.Product> productList = [];
  TextEditingController product1NameController = TextEditingController();
  TextEditingController product1DescriptionController = TextEditingController();
  TextEditingController product1PriceController = TextEditingController();
  bool isEditing = false;
  Uint8List? storeImageBytes1;
  String? errorMessage;
  final prodId1Controller = TextEditingController();
  final productNameController = TextEditingController();
  final ScrollController horizontalScroll = ScrollController();
  final categoryController = TextEditingController();
  final subCategoryController = TextEditingController();
  final prodIdController = TextEditingController();
  final CategoryController = TextEditingController();
  final taxController = TextEditingController();
  final unitController = TextEditingController();
  final priceController = TextEditingController();
  final discountController = TextEditingController();
  final imageIdContoller = TextEditingController();
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

  bool areRequiredFieldsFilled() {
    return productNameController.text.isNotEmpty &&
        categoryController.text.isNotEmpty &&
        taxController.text.isNotEmpty &&
        unitController.text.isNotEmpty &&
        priceController.text.isNotEmpty &&
        discountController.text.isNotEmpty;
  }

  Future<void> fetchData(String productName, String category) async {
    try {
      final response = await http.get(
        Uri.parse('$apicall/productmaster/search_by_productname/$productName'),
        headers: {
          "Content-Type": "application/json",
          'Authorization': 'Bearer $token'
        },
      );

      if (response.statusCode == 200) {
        final responseBody = response.body;
        final jsonData = jsonDecode(responseBody);
        if (jsonData != null) {
          if (jsonData is List) {
            final List<dynamic> jsonDataList = jsonData;
            final List<ord.Product> products = jsonDataList
                .map<ord.Product>((item) => ord.Product.fromJson(item))
                .toList();

            // Limit the number of products to 10
            final limitedProducts = products.take(10).toList();

            setState(() {
              productList = limitedProducts;
            });
          } else if (jsonData is Map) {
            final List<dynamic>? jsonDataList = jsonData['body'];
            if (jsonDataList != null) {
              final List<ord.Product> products = jsonDataList
                  .map<ord.Product>((item) => ord.Product.fromJson(item))
                  .toList();

              // Limit the number of products to 10
              final limitedProducts = products.take(10).toList();

              setState(() {
                productList = limitedProducts;
              });
            } else {
              setState(() {
                productList = []; // Initialize with an empty list
              });
            }
          } else {
            setState(() {
              productList = []; // Initialize with an empty list
            });
          }
        } else {
          setState(() {
            productList = []; // Initialize with an empty list
          });
        }
      } else {
        throw Exception('Failed to load data');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  Future fetchImage(String imageId) async {
    print('---------inside Image Fetch Api---------');
    String url =
        'https://tn4l1nop44.execute-api.ap-south-1.amazonaws.com/stage1/api/v1_aws_s3_bucket/view/$imageId';
    print('-------------imageUrl--------------');
    print(imageId);
    print(url);
    final response = await http.get(
      Uri.parse(url),
    );
    if (response.statusCode == 200) {
      try {
        setState(() {
          print('------type-----');
          print(response.bodyBytes);
          print(response.runtimeType);
          storeImageBytes1 = response.bodyBytes;
          print('--storeImageBytes1--');
          print(storeImageBytes1);
        });
      } catch (e) {
        print('-------------');
        print('Error:$e');
      }
    }
  }

  List<Widget> _buildMenuItems(BuildContext context) {
    return [
      _buildMenuItem('Home', Icons.home_outlined, Colors.blue[900]!, '/Home'),
      _buildMenuItem(
          'Customer', Icons.account_circle, Colors.blue[900]!, '/Customer'),
      Container(
          decoration: BoxDecoration(
            color: Colors.blue[800],
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8), // Radius for top-left corner
              topRight: Radius.circular(8), // No radius for top-right corner
              bottomLeft: Radius.circular(8), // Radius for bottom-left corner
              bottomRight:
                  Radius.circular(8), // No radius for bottom-right corner
            ),
          ),
          child: _buildMenuItem(
              'Products', Icons.image_outlined, Colors.black, '/Product_List')),
      _buildMenuItem(
          'Orders', Icons.warehouse_outlined, Colors.blue[900]!, '/Order_List'),
      _buildMenuItem('Invoice', Icons.document_scanner_outlined,
          Colors.blue[900]!, '/Invoice'),
      _buildMenuItem('Delivery', Icons.fire_truck_outlined, Colors.blue[900]!,
          '/Delivery_List'),
      _buildMenuItem('Payment', Icons.payment_outlined, Colors.blue[900]!,
          '/Payment_List'),
      _buildMenuItem(
          'Return', Icons.keyboard_return, Colors.blue[900]!, '/Return_List'),
      _buildMenuItem('Reports', Icons.insert_chart_outlined, Colors.blue[900]!,
          '/Report_List'),
    ];
  }

  Widget _buildMenuItem(
      String title, IconData icon, Color iconColor, String route) {
    iconColor = _isHovered[title] == true ? Colors.blue : Colors.black87;
    title == 'Products' ? _isHovered[title] = false : _isHovered[title] = false;
    title == 'Products' ? iconColor = Colors.white : Colors.black;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered[title] = true),
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
            padding: const EdgeInsets.only(left: 5, top: 5),
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
  void dispose() {
    product1NameController.dispose();
    product1DescriptionController.dispose();
    product1PriceController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isFirstLoad) {
      print('didichange');
      _isFirstLoad = false;
      for (int i = 0; i < widget.orderDetails!.length; i++) {
        if (prodIdController.text == widget.orderDetails![i].orderId) {
          setState(() {
            var selectedItem = widget.orderDetails![i];
            widget.orderDetails!.removeAt(i);
            widget.orderDetails!.insert(0, selectedItem);
            for (int j = 0; j < _isSelected.length; j++) {
              _isSelected[j] = j == 0;
            }
          });
          break;
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    //fetchProducts();
    if (widget.product != null) {
      productNameController.text = widget.product!.productName;
      categoryController.text = widget.product!.category;
      prodIdController.text = widget.product!.prodId;
      subCategoryController.text = widget.product!.subCategory;
      CategoryController.text = widget.product!.category;
      taxController.text = widget.product!.tax;
      unitController.text = widget.product!.unit;
      priceController.text = widget.product!.price.toString();
      discountController.text = widget.product!.discount;
      imageIdContoller.text = widget.product!.imageId;
      isEditing = false;
      loadImage(widget.product!.imageId);
      print('------Prodid------');
      print(prodIdController.text);

      //}
    } else {
      print('orderdeta');
      print(widget.orderDetails);
      _displayData = Map.from(widget.displayData);
      print(widget.displayData['price']);
      print(widget.discountText);
      priceController.text = widget.priceText!;
      discountController.text = widget.discountText!;

      productNameController.text = widget.productText!;
      unitController.text = widget.selectedvalue2!;
      taxController.text = widget.selectedValue3!;
      categoryController.text = widget.selectedValue!;
      prodIdController.text = widget.prodId!;
      subCategoryController.text = widget.selectedValue1!;
      loadImage(widget.displayData['imageId'] ?? "");
      print("----imagePath-----");
      print("---imagename----");
      print(priceController.text);
      print(taxController.text);
      print(discountController.text);
      // print(widget.displayData['imageId'] ?? " ");
    }
  }

  bool isBase64(String str) {
    const base64Pattern = r'^[A-Za-z0-9+/]+={0,2}$';
    final regex = RegExp(base64Pattern);
    return regex.hasMatch(str);
  }

  Future<void> deleteProductById(String productId) async {
    try {
      final Uri apiUri = Uri.parse(
        '$apicall/productmaster/delete_productmaster_by_id/$productId',
      );
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      };
      final http.Response response = await http.delete(apiUri,
        headers: headers,
      );

      if (response.statusCode == 200) {
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
                  // Close Button
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        // Warning Icon
                        const Icon(Icons.check_circle_rounded,
                            color: Colors.green, size: 50),
                        const SizedBox(height: 16),
                        // Confirmation Message
                        const Text(
                          'Product Deleted Successfuly',
                          style: TextStyle(
                            fontSize: 18,
                            //  fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                // Handle No action
                                context.go('/Product_List');
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                side: const BorderSide(color: Colors.blue),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                              ),
                              child: const Text(
                                'OK',
                                style: TextStyle(
                                  color: Colors.white,
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
        );
      } else {
        print('Failed to delete product: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void searchSelect(String productName) async {
    // print(token);
    try {
      // Make an HTTP request to fetch data from the API
      final response = await http.get(
        Uri.parse('$apicall/productmaster/search_by_productname/$productName'),
        headers: {
          "Content-Type": "application/json",
          'Authorization': 'Bearer $token'
        },
      );

      // Check if the request was successful
      if (response.statusCode == 200) {
        //print(token);
        // Parse the response body
        final jsonData = jsonDecode(response.body);
        // Convert the JSON data into a list of Product objects
        final List<ord.Product> products = jsonData
            .map<ord.Product>((item) => ord.Product.fromJson(item))
            .toList();
        // Update the state to reflect the fetched products
        setState(() {
          productList = products;
        });
      } else {
        // Handle error if the request was not successful
        throw Exception('Failed to load data');
      }
    } catch (error) {
      // Handle any errors that occur during the process
      print('Error: $error');
    }
  }

  void handleTextFormFieldTap() async {
    String productName = 'ProductName';
    String category = 'category';
    await fetchData(productName, category);
  }

  Future<void> checkimage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
      maxWidth: 150,
    );

    if (pickedImage != null) {
      pickedImagePath = pickedImage.path;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Image selected")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Image selection cancelled")),
      );
    }
  }

  Future<void> fetchProducts(String prodId) async {
    final response = await http.get(
      Uri.parse(
        '$apicall/productmaster/get_all_productmaster',
      ),
      headers: {
        "Content-type": "application/json",
        "Authorization": 'Bearer $token'
      },
    );

    if (response.statusCode == 200) {
      try {
        final jsonData = jsonDecode(response.body);
        if (jsonData != null) {
          if (jsonData is List) {
            final products =
                jsonData.map((item) => ord.Product.fromJson(item)).toList();
            final product =
                products.firstWhere((element) => element.prodId == prodId);
            setState(() {
              productNameController.text = product.productName;
              categoryController.text = product.category;
              subCategoryController.text = product.subCategory;
              taxController.text = product.tax;
              unitController.text = product.unit;
              priceController.text = product.price.toString();
              discountController.text = product.discount;
              imageIdContoller.text = product.imageId;
              print('image name');
              print(imageIdContoller.text);
              loadImage(imageIdContoller.text);
              //await loadImage(imageIdContoller.text);
            });
          } else if (jsonData is Map) {
            if (jsonData.containsKey('body')) {
              final products = jsonData['body']
                  .map((item) => ord.Product.fromJson(item))
                  .toList();
              final product =
                  products.firstWhere((element) => element.prodId == prodId);
              setState(() {
                productNameController.text = product.productName;
                categoryController.text = product.category;
                subCategoryController.text = product.subCategory;
                taxController.text = product.tax;
                unitController.text = product.unit;
                priceController.text = product.price.toString();
                discountController.text = product.discount;
                imageIdContoller.text = product.imageId;
                print('image size');
                print(imageIdContoller.text);
              });
            } else {
              print('No product found');
            }
          } else {
            print('No product found');
          }
        } else {
          print('No product found');
        }
      } catch (e) {
        print('Error decoding JSON: $e');
      }
    } else {
      throw Exception('Failed to load data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
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
            const SizedBox(
              width: 10,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: AccountMenu(),
            ),
          ],
        ),
        body: LayoutBuilder(builder: (context, constraints) {
          double maxHeight = constraints.maxHeight;
          double maxWidth = constraints.maxWidth;

          return Stack(
            children: [
              if (constraints.maxWidth >= 1336) ...{
                Container(
                  width: maxWidth,
                  height: maxHeight, //height
                  child: Stack(
                    children: [
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
                      Container(
                        margin: const EdgeInsets.only(
                          top: 60,
                          left: 201,
                        ),
                        width: 259,
                        //height: 980,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            SizedBox(
                              height: 33,
                              width: 80,
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    left: 5, right: 3, bottom: 5),
                                child: TextFormField(
                                  decoration: const InputDecoration(
                                    hintText: 'Search product',
                                    contentPadding: EdgeInsets.all(8),
                                    border: OutlineInputBorder(),
                                    prefixIcon: Icon(
                                      Icons.search_outlined,
                                      color: Colors.blue,
                                    ),
                                  ),
                                  onChanged: (value) {
                                    setState(() {
                                      searchText = value.toLowerCase();
                                    });
                                  },
                                  // final List<OrderDetail> filteredOrderDetails = searchText.isNotEmpty
                                  // ? widget.orderDetails!.where((orderDetail) =>
                                  // orderDetail.orderDate.toLowerCase().contains(searchText.toLowerCase())
                                  // ).toList()
                                  //     : widget.orderDetails!;
                                  //
                                  // ...
                                  //
                                  // itemCount: filteredOrderDetails.length,
                                  //
                                  // itemBuilder: (context, index) {
                                  // final OrderDetail orderDetail = filteredOrderDetails[index];
                                  // ...
                                  // }
                                  //  onChanged: _onSearchChanged(),
                                  // onChanged: (value) {
                                  // //  token = window.sessionStorage["token"] ?? " ";
                                  //   setState(() {
                                  //     searchText = value; // Update searchText
                                  //   });
                                  //   //_newData();
                                  //   // fetchImage(); // Fetch data
                                  // },
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Container(
                                height: maxHeight * 0.83,
                                //500,//maxHeight * 0.83,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: ListView.separated(
                                  itemCount: searchText.isNotEmpty
                                      ? widget.orderDetails!
                                      .where((orderDetail) => orderDetail
                                      .orderDate
                                      .toLowerCase()
                                      .contains(
                                      searchText.toLowerCase()))
                                      .length
                                      : widget.orderDetails!.length,
                                  // searchText.isNotEmpty
                                  //     ? widget.orderDetails!.length : widget.orderDetails!.where((orderDetail) =>
                                  //     orderDetail.orderDate.toLowerCase().contains(searchText.toLowerCase())
                                  // ).length,
                                  itemBuilder: (context, index) {
                                    // final OrderDetail orderDetail = widget.orderDetails![index];
                                    //original
                                    final OrderDetail orderDetail = (searchText
                                        .isNotEmpty
                                        ? widget.orderDetails!
                                        .where((orderDetail) => orderDetail
                                        .orderDate
                                        .toLowerCase()
                                        .contains(
                                        searchText.toLowerCase()))
                                        .toList()[index]
                                        : widget.orderDetails![index]);
                                    //   final OrderDetail orderDetail = orderDetails[index];
                                    // final OrderDetail orderDetail = searchText.isNotEmpty ?
                                    // widget.orderDetails!.where((orderDetail) => orderDetail.orderDate.toLowerCase().contains(searchText.toLowerCase())
                                    // ).length :widget.orderDetails![index];
                                    bool isSelected = orderDetail.orderId ==
                                        prodIdController.text;
                                    // widget.orderDetails!.sort((a, b) {
                                    //   if (a.orderId ==
                                    //       prodIdController.text) {
                                    //     return -1; // selected product name comes first
                                    //   } else if (b.orderId ==
                                    //       prodIdController.text) {
                                    //     return 1; // selected product name comes first
                                    //   } else {
                                    //     final aIsNumber = a.orderId[0]
                                    //         .contains(RegExp(r'[0-90]'));
                                    //     final bIsNumber = b.orderId[0]
                                    //         .contains(RegExp(r'[0-90]'));
                                    //
                                    //     if (aIsNumber && !bIsNumber) {
                                    //       return 1;
                                    //     } else if (!aIsNumber && bIsNumber) {
                                    //       return -1;
                                    //     } else {
                                    //       return a.orderId
                                    //           .compareTo(b.orderId);
                                    //     }
                                    //   }
                                    // });
                                    // widget.orderDetails!.sort((a, b) {
                                    //   if (a.orderId == prodIdController.text) {
                                    //     return -1; // selected product name comes first
                                    //   } else if (b.orderId == prodIdController.text) {
                                    //     return 1; // selected product name comes first
                                    //   } else {
                                    //     final aIsNumber = a.orderId[0].contains(RegExp(r'[0-90]'));
                                    //     final bIsNumber = b.orderId[0].contains(RegExp(r'[0-90]'));
                                    //
                                    //     if (aIsNumber && !bIsNumber) {
                                    //       return 1;
                                    //     } else if (!aIsNumber && bIsNumber) {
                                    //       return -1;
                                    //     } else {
                                    //       return a.orderId.compareTo(b.orderId);
                                    //     }
                                    //   }
                                    // });
                                    return GestureDetector(
                                      onTap: () async {
                                        setState(() {
                                          // _isLoading = true;
                                          for (int i = 0;
                                          i < _isSelected.length;
                                          i++) {
                                            _isSelected[i] = i == index;
                                          }
                                          prodIdController.text =
                                          orderDetail.orderId!;
                                        });
                                        await Future.delayed(
                                            const Duration(milliseconds: 2));
                                        await fetchProducts(
                                            orderDetail.orderId!);

                                        //context.go('/dasbaord/productpage/ontap');
                                        //                                     setState(() {
                                        //                                       prodIdController.text = orderDetail.orderId!;
                                        //                                      // productNameController.text = orderDetail.orderDate!;
                                        //
                                        //                                       print(prodIdController.text);
                                        //                                        //You need to set the other controllers here, but you don't have these properties in OrderDetail
                                        //                                        // categoryController.text = orderDetail.category;
                                        //                                        // subCategoryController.text = orderDetail.subCategory;
                                        //                                        // taxController.text = orderDetail.tax;
                                        //                                        // unitController.text = orderDetail.unit;
                                        //                                        // priceController.text = orderDetail.price.toString();
                                        //                                        // discountController.text = orderDetail.discount;
                                        //                                        // imageIdContoller.text = orderDetail.imageId;
                                        //                                       print('---iamde');
                                        //                                       // widget.dia
                                        //                                       _displayData['imageId'] = imageIdContoller.text;
                                        // // widget.displayData['imageId'] =
                                        // //     imageIdContoller.text;
                                        //                                       // widget.displayData['imageId'] =_displayData['imageId'];
                                        //                                       print(imageIdContoller.text);
                                        //                                       // fetchImage(orderDetail.imageId); // You don't have imageId in OrderDetail
                                        //                                     });
                                      },
                                      child: Container(
                                        decoration: isSelected
                                            ? BoxDecoration(
                                            color: Colors.lightBlue[
                                            100]) // selected color
                                            : null,
                                        child: ListTile(
                                          title: Text(
                                            '${orderDetail.orderDate}',
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                          subtitle: Text(
                                              '${orderDetail.orderCategory}'),
                                          // You don't have category in OrderDetail
                                          tileColor: isSelected
                                              ? Colors.lightBlue[100]
                                              : null,
                                        ),
                                      ),
                                    );
                                  },
                                  separatorBuilder:
                                      (BuildContext context, int index) {
                                    return const Divider();
                                  },
                                )),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 201),
                        child: Container(
                          // Space above/below the border
                          width: 0.8, // Border height
                          color: Colors.grey, // Border color
                        ),
                      ),
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 202),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            color: Colors.white,
                            height: 60,
                            child: Row(
                              children: [
                                IconButton(
                                  icon: const Icon(
                                      Icons.arrow_back), // Back button icon
                                  onPressed: () {
                                    context.go('/Product_List');
                                    // Navigator.of(context).push(PageRouteBuilder(
                                    //   pageBuilder: (context, animation,
                                    //       secondaryAnimation) =>
                                    //       const ProductPage(product: null),
                                    // ));
                                  },
                                ),
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
                                    padding: const EdgeInsets.only(
                                        top: 15, right: 30),
                                    child: OutlinedButton(
                                      onPressed: () {
                                        showDialog(
                                          barrierDismissible: false,
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                BorderRadius.circular(15.0),
                                              ),
                                              contentPadding: EdgeInsets.zero,
                                              content: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  // Close Button
                                                  Align(
                                                    alignment:
                                                    Alignment.topRight,
                                                    child: IconButton(
                                                      icon: const Icon(Icons.close,
                                                          color: Colors.red),
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                    const EdgeInsets.all(
                                                        16.0),
                                                    child: Column(
                                                      children: [
                                                        // Warning Icon
                                                        const Icon(Icons.warning,
                                                            color:
                                                            Colors.orange,
                                                            size: 50),
                                                        const SizedBox(height: 16),
                                                        // Confirmation Message
                                                        const Text(
                                                          'Are You Sure',
                                                          style: TextStyle(
                                                            fontSize: 18,
                                                            fontWeight:
                                                            FontWeight.bold,
                                                            color: Colors.black,
                                                          ),
                                                        ),
                                                        const SizedBox(height: 20),
                                                        // Buttons
                                                        Row(
                                                          mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceEvenly,
                                                          children: [
                                                            ElevatedButton(
                                                              onPressed: () {
                                                                // Handle Yes action
                                                                deleteProductById(
                                                                    '${prodIdController.text}');
                                                                // context.go('/');
                                                                // Navigator.of(context).pop();
                                                              },
                                                              style:
                                                              ElevatedButton
                                                                  .styleFrom(
                                                                backgroundColor:
                                                                Colors
                                                                    .white,
                                                                side: const BorderSide(
                                                                    color: Colors
                                                                        .blue),
                                                                shape:
                                                                RoundedRectangleBorder(
                                                                  borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                      10.0),
                                                                ),
                                                              ),
                                                              child: const Text(
                                                                'Yes',
                                                                style:
                                                                TextStyle(
                                                                  color: Colors
                                                                      .blue,
                                                                ),
                                                              ),
                                                            ),
                                                            ElevatedButton(
                                                              onPressed: () {
                                                                // Handle No action
                                                                Navigator.of(
                                                                    context)
                                                                    .pop();
                                                              },
                                                              style:
                                                              ElevatedButton
                                                                  .styleFrom(
                                                                backgroundColor:
                                                                Colors
                                                                    .white,
                                                                side: const BorderSide(
                                                                    color: Colors
                                                                        .red),
                                                                shape:
                                                                RoundedRectangleBorder(
                                                                  borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                      10.0),
                                                                ),
                                                              ),
                                                              child: const Text(
                                                                'No',
                                                                style:
                                                                TextStyle(
                                                                  color: Colors
                                                                      .red,
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
                                        );
                                      },
                                      style: OutlinedButton.styleFrom(
                                        backgroundColor: Colors.red[900],
                                        // Button background color
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              5), // Rounded corners
                                        ),
                                        side: BorderSide.none, // No outline
                                      ),
                                      child: const Text(
                                        'Delete',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w100,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding:
                                  const EdgeInsets.only(right: 30, top: 3),
                                  child: OutlinedButton(
                                    onPressed: () {
                                      print('---- image path-----');
                                      print(storeImageBytes1);
                                      print(priceController.text);
                                      print(discountController.text);
                                      print(subCategoryController.text);
                                      print(categoryController.text);
                                      print(unitController.text);
                                      print(taxController.text);
                                      print(productNameController.text);
                                      print('hii');
                                      // widget.displayData['imageId'] = imageIdContoller.text;
                                      print(
                                          widget.displayData['imageId'] ?? "");
                                      _displayData['imageId'] ?? "";
                                      print('checkk what is this');
                                      print(_displayData['imageId'] ?? "");
                                      widget.displayData['imageId'] ?? "";
                                      print(imageIdContoller.text);
                                      final inputText = categoryController.text;
                                      final subText =
                                          subCategoryController.text;
                                      final unitText = unitController.text;
                                      final taxText = taxController.text;
                                      final prodText = prodIdController.text;

                                      if (storeImageBytes1 != null &&
                                          productNameController
                                              .text.isNotEmpty &&
                                          priceController.text.isNotEmpty &&
                                          discountController.text.isNotEmpty) {
                                        _textInput = productNameController.text;
                                        _priceInput = priceController.text;
                                        discountInput = discountController.text;
                                        print('list details these are all');
                                        print(widget.orderDetails);
                                        context.go('/Edit_Product', extra: {
                                          'prodId': prodText,
                                          'textInput': _textInput ?? '',
                                          'priceInput': _priceInput ?? '',
                                          'discountInput': discountInput ?? '',
                                          'inputText': inputText,
                                          'subText': subText,
                                          'unitText': unitText,
                                          'taxText': taxText,
                                          'imagePath': storeImageBytes1,
                                          'imageId': _displayData['imageId'] ??
                                              imageIdContoller.text ??
                                              '',
                                          'productData': {},
                                          // or pass the actual product data
                                        });

                                        // context.go('/dashboard/productpage/:Edit/Edit', extra: {
                                        //   'prodId': prodText ?? '',
                                        //   'textInput': _textInput ?? '',
                                        //   'priceInput': _priceInput ?? '',
                                        //   'discountInput': discountInput ?? '',
                                        //   'inputText': inputText ?? '',
                                        //   'subText': subText ?? '',
                                        //   'unitText': unitText ?? '',
                                        //   'taxText': taxText ?? '',
                                        //   'imagePath': storeImageBytes1,
                                        //   'imageId': _displayData['imageId']?? imageIdContoller.text?? '',
                                        //   'productData': {}, // or pass the actual product data
                                        // });
                                      } else {
                                        // Handle case when imagePath is null or other required fields are empty
                                        print(
                                            'Error: Image path is null or other required fields are empty.');
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
                                      isEditing ? 'Edit' : 'Edit',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        //fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 43, left: 201),
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                              vertical: 10), // Space above/below the border
                          height: 1, // Border height
                          color: Colors.grey, // Border color
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 0, left: 450),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 10),
                          // Space above/below the border
                          height: constraints.maxHeight,
                          // width: 1500,
                          width: 2,
                          // Border height
                          color: Colors.grey[300], // Border color
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 480, top: 100, bottom: 40, right: 20),
                        child: SingleChildScrollView(
                          child: Container(
                            width: maxWidth * 0.82,
                            height: maxHeight * 0.83,
                            color: Colors.white,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                FutureBuilder(
                                  future: Future.delayed(const Duration(seconds: 2)),
                                  // 2-second buffer
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      // Display the custom loading icon while waiting
                                      return Padding(
                                        padding: EdgeInsets.only(
                                            top: maxHeight * 0.12),
                                        child: Container(
                                          margin: EdgeInsets.only(
                                              left: maxWidth * 0.12),
                                          width: maxWidth * 0.2,
                                          height: 300,
                                          decoration: BoxDecoration(
                                            color: Colors.grey[300],
                                            borderRadius:
                                            BorderRadius.circular(4),
                                          ),
                                          child: Center(
                                              child:
                                              ImageLoadingIcon()), // Custom icon here
                                        ),
                                      );
                                    } else {
                                      return storeImageBytes1 != null
                                          ? Padding(
                                        padding: EdgeInsets.only(
                                            top: maxHeight * 0.12),
                                        child: Container(
                                          margin: EdgeInsets.only(
                                              left: maxWidth * 0.12),
                                          width: maxWidth * 0.2,
                                          height: 300,
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                                color: Colors.grey),
                                            color: Colors.white70,
                                            borderRadius:
                                            BorderRadius.circular(8),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.blue
                                                    .withOpacity(0.1),
                                                spreadRadius: 1,
                                                blurRadius: 3,
                                                offset:
                                                const Offset(0, 1),
                                              ),
                                            ],
                                          ),
                                          child: Image.memory(
                                              storeImageBytes1!),
                                        ),
                                      )
                                          : Padding(
                                        padding: EdgeInsets.only(
                                            top: maxHeight * 0.12),
                                        child: Container(
                                          margin: EdgeInsets.only(
                                              left: maxWidth * 0.12),
                                          width: maxWidth * 0.2,
                                          height: 300,
                                          decoration: BoxDecoration(
                                            color: Colors.grey[300],
                                            borderRadius:
                                            BorderRadius.circular(4),
                                          ),
                                          child: const Center(
                                              child: Text(
                                                  'No Image Found.')),
                                        ),
                                      );
                                    }
                                  },
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildFirstWidget2(
                                      context), // Use the ProductForm widget here
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              } else ...{
                Container(
                  width: 1500,
                  child: Stack(
                    children: [
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
                      Container(
                        padding: const EdgeInsets.only(left: 200),
                        child: AdaptiveScrollbar(
                            position: ScrollbarPosition.bottom,
                            controller: horizontalScroll,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              controller: horizontalScroll,
                              child: Container(
                                width: 1300,
                                height: 984,
                                child: Container(
                                  child: Stack(
                                    children: [
                                      Container(
                                        // Space above/below the border
                                        width: 0.8, // Border height
                                        color: Colors.grey, // Border color
                                      ),
                                      Positioned(
                                        top: 0,
                                        left: 1,
                                        right: 0,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16),
                                          color: Colors.white,
                                          height: 60,
                                          child: Row(
                                            children: [
                                              IconButton(
                                                icon: const Icon(
                                                    Icons.arrow_back),
                                                // Back button icon
                                                onPressed: () {
                                                  context.go('/Product_List');
                                                  // Navigator.of(context).push(PageRouteBuilder(
                                                  //   pageBuilder: (context, animation,
                                                  //       secondaryAnimation) =>
                                                  //       const ProductPage(product: null),
                                                  // ));
                                                },
                                              ),
                                              const Padding(
                                                padding:
                                                EdgeInsets.only(left: 20),
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
                                                  padding:
                                                  const EdgeInsets.only(
                                                      top: 15, right: 30),
                                                  child: OutlinedButton(
                                                    onPressed: () {
                                                      showDialog(
                                                        barrierDismissible:
                                                        false,
                                                        context: context,
                                                        builder: (BuildContext
                                                        context) {
                                                          return AlertDialog(
                                                            shape:
                                                            RoundedRectangleBorder(
                                                              borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                  15.0),
                                                            ),
                                                            contentPadding:
                                                            EdgeInsets.zero,
                                                            content: Column(
                                                              mainAxisSize:
                                                              MainAxisSize
                                                                  .min,
                                                              children: [
                                                                // Close Button
                                                                Align(
                                                                  alignment:
                                                                  Alignment
                                                                      .topRight,
                                                                  child:
                                                                  IconButton(
                                                                    icon: const Icon(
                                                                        Icons
                                                                            .close,
                                                                        color: Colors
                                                                            .red),
                                                                    onPressed:
                                                                        () {
                                                                      Navigator.of(
                                                                          context)
                                                                          .pop();
                                                                    },
                                                                  ),
                                                                ),
                                                                Padding(
                                                                  padding:
                                                                  const EdgeInsets
                                                                      .all(
                                                                      16.0),
                                                                  child: Column(
                                                                    children: [
                                                                      // Warning Icon
                                                                      const Icon(
                                                                          Icons
                                                                              .warning,
                                                                          color: Colors
                                                                              .orange,
                                                                          size:
                                                                          50),
                                                                      const SizedBox(
                                                                          height:
                                                                          16),
                                                                      // Confirmation Message
                                                                      const Text(
                                                                        'Are You Sure',
                                                                        style:
                                                                        TextStyle(
                                                                          fontSize:
                                                                          18,
                                                                          fontWeight:
                                                                          FontWeight.bold,
                                                                          color:
                                                                          Colors.black,
                                                                        ),
                                                                      ),
                                                                      const SizedBox(
                                                                          height:
                                                                          20),
                                                                      // Buttons
                                                                      Row(
                                                                        mainAxisAlignment:
                                                                        MainAxisAlignment.spaceEvenly,
                                                                        children: [
                                                                          ElevatedButton(
                                                                            onPressed:
                                                                                () {
                                                                              // Handle Yes action
                                                                              deleteProductById('${prodIdController.text}');
                                                                              // context.go('/');
                                                                              // Navigator.of(context).pop();
                                                                            },
                                                                            style:
                                                                            ElevatedButton.styleFrom(
                                                                              backgroundColor: Colors.white,
                                                                              side: const BorderSide(color: Colors.blue),
                                                                              shape: RoundedRectangleBorder(
                                                                                borderRadius: BorderRadius.circular(10.0),
                                                                              ),
                                                                            ),
                                                                            child:
                                                                            const Text(
                                                                              'Yes',
                                                                              style: TextStyle(
                                                                                color: Colors.blue,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          ElevatedButton(
                                                                            onPressed:
                                                                                () {
                                                                              // Handle No action
                                                                              Navigator.of(context).pop();
                                                                            },
                                                                            style:
                                                                            ElevatedButton.styleFrom(
                                                                              backgroundColor: Colors.white,
                                                                              side: const BorderSide(color: Colors.red),
                                                                              shape: RoundedRectangleBorder(
                                                                                borderRadius: BorderRadius.circular(10.0),
                                                                              ),
                                                                            ),
                                                                            child:
                                                                            const Text(
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
                                                      );
                                                    },
                                                    style: OutlinedButton
                                                        .styleFrom(
                                                      backgroundColor:
                                                      Colors.red[900],
                                                      // Button background color
                                                      shape:
                                                      RoundedRectangleBorder(
                                                        borderRadius:
                                                        BorderRadius.circular(
                                                            5), // Rounded corners
                                                      ),
                                                      side: BorderSide
                                                          .none, // No outline
                                                    ),
                                                    child: const Text(
                                                      'Delete',
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                        FontWeight.w100,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    right: 30, top: 3),
                                                child: OutlinedButton(
                                                  onPressed: () {
                                                    print(
                                                        '---- image path-----');
                                                    print(storeImageBytes1);
                                                    print(priceController.text);
                                                    print(discountController
                                                        .text);
                                                    print(subCategoryController
                                                        .text);
                                                    print(categoryController
                                                        .text);
                                                    print(unitController.text);
                                                    print(taxController.text);
                                                    print(productNameController
                                                        .text);
                                                    print('hii');
                                                    // widget.displayData['imageId'] = imageIdContoller.text;
                                                    print(widget.displayData[
                                                    'imageId'] ??
                                                        "");
                                                    _displayData['imageId'] ??
                                                        "";
                                                    print(
                                                        'checkk what is this');
                                                    print(_displayData[
                                                    'imageId'] ??
                                                        "");
                                                    widget.displayData[
                                                    'imageId'] ??
                                                        "";
                                                    print(
                                                        imageIdContoller.text);
                                                    final inputText =
                                                        categoryController.text;
                                                    final subText =
                                                        subCategoryController
                                                            .text;
                                                    final unitText =
                                                        unitController.text;
                                                    final taxText =
                                                        taxController.text;
                                                    final prodText =
                                                        prodIdController.text;

                                                    if (storeImageBytes1 !=
                                                        null &&
                                                        productNameController
                                                            .text.isNotEmpty &&
                                                        priceController
                                                            .text.isNotEmpty &&
                                                        discountController
                                                            .text.isNotEmpty) {
                                                      _textInput =
                                                          productNameController
                                                              .text;
                                                      _priceInput =
                                                          priceController.text;
                                                      discountInput =
                                                          discountController
                                                              .text;
                                                      print(
                                                          'list details these are all');
                                                      print(
                                                          widget.orderDetails);
                                                      context.go(
                                                          '/Edit_Product',
                                                          extra: {
                                                            'prodId': prodText,
                                                            'textInput':
                                                            _textInput ??
                                                                '',
                                                            'priceInput':
                                                            _priceInput ??
                                                                '',
                                                            'discountInput':
                                                            discountInput ??
                                                                '',
                                                            'inputText':
                                                            inputText,
                                                            'subText': subText,
                                                            'unitText':
                                                            unitText,
                                                            'taxText': taxText,
                                                            'imagePath':
                                                            storeImageBytes1,
                                                            'imageId': _displayData[
                                                            'imageId'] ??
                                                                imageIdContoller
                                                                    .text ??
                                                                '',
                                                            'productData': {},
                                                            // or pass the actual product data
                                                          });

                                                      // context.go('/dashboard/productpage/:Edit/Edit', extra: {
                                                      //   'prodId': prodText ?? '',
                                                      //   'textInput': _textInput ?? '',
                                                      //   'priceInput': _priceInput ?? '',
                                                      //   'discountInput': discountInput ?? '',
                                                      //   'inputText': inputText ?? '',
                                                      //   'subText': subText ?? '',
                                                      //   'unitText': unitText ?? '',
                                                      //   'taxText': taxText ?? '',
                                                      //   'imagePath': storeImageBytes1,
                                                      //   'imageId': _displayData['imageId']?? imageIdContoller.text?? '',
                                                      //   'productData': {}, // or pass the actual product data
                                                      // });
                                                    } else {
                                                      // Handle case when imagePath is null or other required fields are empty
                                                      print(
                                                          'Error: Image path is null or other required fields are empty.');
                                                    }
                                                  },
                                                  style:
                                                  OutlinedButton.styleFrom(
                                                    backgroundColor:
                                                    Colors.blue[800],
                                                    // Button background color
                                                    shape:
                                                    RoundedRectangleBorder(
                                                      borderRadius:
                                                      BorderRadius.circular(
                                                          5), // Rounded corners
                                                    ),
                                                    side: BorderSide
                                                        .none, // No outline
                                                  ),
                                                  child: Text(
                                                    isEditing ? 'Edit' : 'Edit',
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      //fontWeight: FontWeight.bold,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            top: 43, left: 1),
                                        child: Container(
                                          margin: const EdgeInsets.symmetric(
                                              vertical: 10),
                                          // Space above/below the border
                                          height: 1,
                                          // Border height
                                          color: Colors.grey, // Border color
                                        ),
                                      ),
                                      Container(
                                        margin: const EdgeInsets.only(
                                          top: 60,
                                          left: 1,
                                        ),
                                        width: 259,
                                        //   height: 980,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                          BorderRadius.circular(4),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                          children: [
                                            SizedBox(
                                              height: 35,
                                              width: 80,
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 5,
                                                    right: 3,
                                                    bottom: 5),
                                                child: TextFormField(
                                                  decoration:
                                                  const InputDecoration(
                                                    hintText: 'Search product',
                                                    contentPadding:
                                                    EdgeInsets.all(8),
                                                    border:
                                                    OutlineInputBorder(),
                                                    prefixIcon: Icon(
                                                      Icons.search_outlined,
                                                      color: Colors.blue,
                                                    ),
                                                  ),
                                                  onChanged: (value) {
                                                    setState(() {
                                                      searchText =
                                                          value.toLowerCase();
                                                    });
                                                  },
                                                  // final List<OrderDetail> filteredOrderDetails = searchText.isNotEmpty
                                                  // ? widget.orderDetails!.where((orderDetail) =>
                                                  // orderDetail.orderDate.toLowerCase().contains(searchText.toLowerCase())
                                                  // ).toList()
                                                  //     : widget.orderDetails!;
                                                  //
                                                  // ...
                                                  //
                                                  // itemCount: filteredOrderDetails.length,
                                                  //
                                                  // itemBuilder: (context, index) {
                                                  // final OrderDetail orderDetail = filteredOrderDetails[index];
                                                  // ...
                                                  // }
                                                  //  onChanged: _onSearchChanged(),
                                                  // onChanged: (value) {
                                                  // //  token = window.sessionStorage["token"] ?? " ";
                                                  //   setState(() {
                                                  //     searchText = value; // Update searchText
                                                  //   });
                                                  //   //_newData();
                                                  //   // fetchImage(); // Fetch data
                                                  // },
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 5),
                                            Container(
                                                height: 390,
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                  BorderRadius.circular(10),
                                                ),
                                                child: ListView.separated(
                                                  itemCount: searchText.isNotEmpty
                                                      ? widget.orderDetails!
                                                      .where((orderDetail) =>
                                                      orderDetail
                                                          .orderDate
                                                          .toLowerCase()
                                                          .contains(
                                                          searchText
                                                              .toLowerCase()))
                                                      .length
                                                      : widget
                                                      .orderDetails!.length,
                                                  // searchText.isNotEmpty
                                                  //     ? widget.orderDetails!.length : widget.orderDetails!.where((orderDetail) =>
                                                  //     orderDetail.orderDate.toLowerCase().contains(searchText.toLowerCase())
                                                  // ).length,
                                                  itemBuilder:
                                                      (context, index) {
                                                    // final OrderDetail orderDetail = widget.orderDetails![index];
                                                    //original
                                                    final OrderDetail orderDetail = (searchText
                                                        .isNotEmpty
                                                        ? widget.orderDetails!
                                                        .where((orderDetail) =>
                                                        orderDetail
                                                            .orderDate
                                                            .toLowerCase()
                                                            .contains(
                                                            searchText
                                                                .toLowerCase()))
                                                        .toList()[index]
                                                        : widget.orderDetails![
                                                    index]);
                                                    //   final OrderDetail orderDetail = orderDetails[index];
                                                    // final OrderDetail orderDetail = searchText.isNotEmpty ?
                                                    // widget.orderDetails!.where((orderDetail) => orderDetail.orderDate.toLowerCase().contains(searchText.toLowerCase())
                                                    // ).length :widget.orderDetails![index];
                                                    bool isSelected =
                                                        orderDetail.orderId ==
                                                            prodIdController
                                                                .text;
                                                    // widget.orderDetails!.sort((a, b) {
                                                    //   if (a.orderId ==
                                                    //       prodIdController.text) {
                                                    //     return -1; // selected product name comes first
                                                    //   } else if (b.orderId ==
                                                    //       prodIdController.text) {
                                                    //     return 1; // selected product name comes first
                                                    //   } else {
                                                    //     final aIsNumber = a.orderId[0]
                                                    //         .contains(RegExp(r'[0-90]'));
                                                    //     final bIsNumber = b.orderId[0]
                                                    //         .contains(RegExp(r'[0-90]'));
                                                    //
                                                    //     if (aIsNumber && !bIsNumber) {
                                                    //       return 1;
                                                    //     } else if (!aIsNumber && bIsNumber) {
                                                    //       return -1;
                                                    //     } else {
                                                    //       return a.orderId
                                                    //           .compareTo(b.orderId);
                                                    //     }
                                                    //   }
                                                    // });
                                                    // widget.orderDetails!.sort((a, b) {
                                                    //   if (a.orderId == prodIdController.text) {
                                                    //     return -1; // selected product name comes first
                                                    //   } else if (b.orderId == prodIdController.text) {
                                                    //     return 1; // selected product name comes first
                                                    //   } else {
                                                    //     final aIsNumber = a.orderId[0].contains(RegExp(r'[0-90]'));
                                                    //     final bIsNumber = b.orderId[0].contains(RegExp(r'[0-90]'));
                                                    //
                                                    //     if (aIsNumber && !bIsNumber) {
                                                    //       return 1;
                                                    //     } else if (!aIsNumber && bIsNumber) {
                                                    //       return -1;
                                                    //     } else {
                                                    //       return a.orderId.compareTo(b.orderId);
                                                    //     }
                                                    //   }
                                                    // });
                                                    return GestureDetector(
                                                      onTap: () async {
                                                        setState(() {
                                                          // _isLoading = true;
                                                          for (int i = 0;
                                                          i <
                                                              _isSelected
                                                                  .length;
                                                          i++) {
                                                            _isSelected[i] =
                                                                i == index;
                                                          }
                                                          prodIdController
                                                              .text =
                                                          orderDetail
                                                              .orderId!;
                                                        });
                                                        await Future.delayed(
                                                            const Duration(
                                                                milliseconds:
                                                                2));
                                                        await fetchProducts(
                                                            orderDetail
                                                                .orderId!);

                                                        //context.go('/dasbaord/productpage/ontap');
                                                        //                                     setState(() {
                                                        //                                       prodIdController.text = orderDetail.orderId!;
                                                        //                                      // productNameController.text = orderDetail.orderDate!;
                                                        //
                                                        //                                       print(prodIdController.text);
                                                        //                                        //You need to set the other controllers here, but you don't have these properties in OrderDetail
                                                        //                                        // categoryController.text = orderDetail.category;
                                                        //                                        // subCategoryController.text = orderDetail.subCategory;
                                                        //                                        // taxController.text = orderDetail.tax;
                                                        //                                        // unitController.text = orderDetail.unit;
                                                        //                                        // priceController.text = orderDetail.price.toString();
                                                        //                                        // discountController.text = orderDetail.discount;
                                                        //                                        // imageIdContoller.text = orderDetail.imageId;
                                                        //                                       print('---iamde');
                                                        //                                       // widget.dia
                                                        //                                       _displayData['imageId'] = imageIdContoller.text;
                                                        // // widget.displayData['imageId'] =
                                                        // //     imageIdContoller.text;
                                                        //                                       // widget.displayData['imageId'] =_displayData['imageId'];
                                                        //                                       print(imageIdContoller.text);
                                                        //                                       // fetchImage(orderDetail.imageId); // You don't have imageId in OrderDetail
                                                        //                                     });
                                                      },
                                                      child: Container(
                                                        decoration: isSelected
                                                            ? BoxDecoration(
                                                            color: Colors
                                                                .lightBlue[
                                                            100]) // selected color
                                                            : null,
                                                        child: ListTile(
                                                          title: Text(
                                                            '${orderDetail.orderDate}',
                                                            style: const TextStyle(
                                                                fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                          ),
                                                          subtitle: Text(
                                                              '${orderDetail.orderCategory}'),
                                                          // You don't have category in OrderDetail
                                                          tileColor: isSelected
                                                              ? Colors
                                                              .lightBlue[100]
                                                              : null,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                  separatorBuilder:
                                                      (BuildContext context,
                                                      int index) {
                                                    return const Divider();
                                                  },
                                                )),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 250),
                                        child: Container(
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 10),
                                          // Space above/below the border
                                          height: constraints.maxHeight,
                                          // width: 1500,
                                          width: 2,
                                          // Border height
                                          color:
                                          Colors.grey[300], // Border color
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            top: 55,
                                            bottom: 30,
                                            right: 5,
                                            left: 270),
                                        child: SingleChildScrollView(
                                          scrollDirection: Axis.vertical,
                                          child: Container(
                                            color: Colors.white,
                                            width: 1000,
                                            height: 800,
                                            child: Row(
                                              crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                              MainAxisAlignment.start,
                                              children: [
                                                FutureBuilder(
                                                  future: Future.delayed(
                                                      const Duration(seconds: 2)),
                                                  // 2-second buffer
                                                  builder: (context, snapshot) {
                                                    if (snapshot
                                                        .connectionState ==
                                                        ConnectionState
                                                            .waiting) {
                                                      // Display the custom loading icon while waiting
                                                      return Padding(
                                                        padding:
                                                        const EdgeInsets.only(
                                                            top: 80),
                                                        child: Container(
                                                          margin:
                                                          const EdgeInsets.only(
                                                              left: 50),
                                                          width: 300,
                                                          height: 300,
                                                          decoration:
                                                          BoxDecoration(
                                                            color: Colors
                                                                .grey[300],
                                                            borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                                4),
                                                          ),
                                                          child: Center(
                                                              child:
                                                              ImageLoadingIcon()), // Custom icon here
                                                        ),
                                                      );
                                                    } else {
                                                      return storeImageBytes1 !=
                                                          null
                                                          ? Padding(
                                                        padding: const EdgeInsets
                                                            .only(
                                                            top: 80),
                                                        child: Container(
                                                          margin: const EdgeInsets
                                                              .only(
                                                              left:
                                                              50),
                                                          width: 300,
                                                          height: 300,
                                                          decoration:
                                                          BoxDecoration(
                                                            border: Border.all(
                                                                color: Colors
                                                                    .grey),
                                                            color: Colors
                                                                .white70,
                                                            borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                                8),
                                                            boxShadow: [
                                                              BoxShadow(
                                                                color: Colors
                                                                    .blue
                                                                    .withOpacity(
                                                                    0.1),
                                                                spreadRadius:
                                                                1,
                                                                blurRadius:
                                                                3,
                                                                offset:
                                                                const Offset(
                                                                    0,
                                                                    1),
                                                              ),
                                                            ],
                                                          ),
                                                          child: Image.memory(
                                                              storeImageBytes1!),
                                                        ),
                                                      )
                                                          : Padding(
                                                        padding: const EdgeInsets
                                                            .only(
                                                            top: 80),
                                                        child: Container(
                                                          margin: const EdgeInsets
                                                              .only(
                                                              left:
                                                              50),
                                                          width: 300,
                                                          height: 300,
                                                          decoration:
                                                          BoxDecoration(
                                                            color: Colors
                                                                .grey[
                                                            300],
                                                            borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                                4),
                                                          ),
                                                          child: const Center(
                                                              child: Text(
                                                                  'No Image Found.')),
                                                        ),
                                                      );
                                                    }
                                                  },
                                                ),
                                                const SizedBox(width: 5),
                                                Expanded(
                                                  child: _buildFirstWidget(
                                                      context), // Use the ProductForm widget here
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            )),
                      ),
                    ],
                  ),
                )
              }






            ],
          );




          /// For web view
        }),
      ),
    );
  }


  Widget _buildFirstWidget2(context) {
    return LayoutBuilder(builder: (context, constraints) {
      double maxHeight = constraints.maxHeight;
      double maxWidth = constraints.maxWidth;
      // For larger screens (like web view)
      return Padding(
        padding: const EdgeInsets.only(
          left: 50,
          top: 30,
          right: 80,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Text(
                    'Product  Name',
                    style: TextStyle(
                      color: Colors.blue[900],
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(2),
                      border: Border.all(color: Colors.blue[100]!),
                    ),
                    child: TextFormField(
                      controller: productNameController,
                      decoration: InputDecoration(
                        fillColor: Colors.white,
                        enabled: isEditing,
                        contentPadding:
                        const EdgeInsets.symmetric(horizontal: 10),
                        border: InputBorder.none,
                        filled: true,
                        // hintText: 'Enter product Name',
                        errorText: errorMessage,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp("[a-zA-Z0-9 ]")),
                        // Allow only letters, numbers, and single space
                        FilteringTextInputFormatter.deny(RegExp(r'^\s')),
                        // Disallow starting with a space
                        FilteringTextInputFormatter.deny(RegExp(r'\s\s')),
                        // Disallow multiple spaces
                      ],
                      validator: (value) {
                        if (value != null && value.trim().isEmpty) {
                          return 'Please enter a product name';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Text(
                          'Category',
                          style: TextStyle(
                            color: Colors.blue[900],
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(2),
                            border: Border.all(color: Colors.blue[100]!),
                          ),
                          child: TextFormField(
                            controller: categoryController,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              enabled: isEditing,
                              border: InputBorder.none,
                              hintText: 'Enter Category',
                              contentPadding:
                              const EdgeInsets.symmetric(horizontal: 10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Text(
                          'Sub Category',
                          style: TextStyle(
                            color: Colors.blue[900],
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(2),
                            border: Border.all(color: Colors.blue[100]!),
                          ),
                          child: TextFormField(
                            controller: subCategoryController,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              enabled: isEditing,
                              border: InputBorder.none,
                              hintText: 'Enter Sub Category',
                              contentPadding:
                              const EdgeInsets.symmetric(horizontal: 10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Text(
                          'Tax',
                          style: TextStyle(
                            color: Colors.blue[900],
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(2),
                            border: Border.all(color: Colors.blue[100]!),
                          ),
                          child: TextFormField(
                            controller: taxController,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              enabled: isEditing,
                              border: InputBorder.none,
                              hintText: 'Enter tax',
                              contentPadding:
                              const EdgeInsets.symmetric(horizontal: 10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Text(
                          'Unit',
                          style: TextStyle(
                            color: Colors.blue[900],
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(2),
                            border: Border.all(color: Colors.blue[100]!),
                          ),
                          child: TextFormField(
                            controller: unitController,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              enabled: isEditing,
                              border: InputBorder.none,
                              hintText: 'Enter Unit',
                              contentPadding:
                              const EdgeInsets.symmetric(horizontal: 10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Text(
                          'Price ',
                          style: TextStyle(
                            color: Colors.blue[900],
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(2),
                            border: Border.all(color: Colors.blue[100]!),
                          ),
                          child: TextFormField(
                            controller: priceController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(
                                  10), // limits to 10 digits
                            ],
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              enabled: isEditing,
                              border: InputBorder.none,
                              hintText: 'Enter Price',
                              contentPadding:
                              const EdgeInsets.symmetric(horizontal: 10),
                            ),
                            onChanged: (value) {
                              if (value.isNotEmpty && !isNumeric(value)) {
                                setState(() {
                                  errorMessage = 'Please enter numbers only';
                                });
                              } else {
                                setState(() {
                                  errorMessage = null;
                                });
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Text(
                          'Discount',
                          style: TextStyle(
                            color: Colors.blue[900],
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(2),
                            border: Border.all(color: Colors.blue[100]!),
                          ),
                          child: TextFormField(
                            controller: discountController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(
                                  10), // limits to 10 digits
                            ],
                            decoration: InputDecoration(
                              filled: true,
                              enabled: isEditing,
                              border: InputBorder.none,
                              // fillColor: isEditing
                              //     ? Colors.white
                              //     : Colors.grey[100],
                              fillColor: Colors.white,
                              hintText: 'Enter Discount',
                              contentPadding:
                              const EdgeInsets.symmetric(horizontal: 10),
                            ),
                            onChanged: (value) {
                              if (value.isNotEmpty && !isNumeric(value)) {
                                setState(() {
                                  errorMessage = 'Please enter numbers only';
                                });
                              } else {
                                setState(() {
                                  errorMessage = null;
                                });
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }




  final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  Future<void> checkSave() async {
    if (!areRequiredFieldsFilled()) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  "Please fill in all required fields and select an image")),
        );
      }
      return;
    }

    final productData = {
      "productName": productNameController.text,
      "category": categoryController.text,
      "subCategory": subCategoryController.text,
      "tax": taxController.text,
      "unit": unitController.text,
      "price": int.parse(priceController.text),
      "discount": discountController.text,
    };

    final productUrl = '$apicall/productmaster/update_productmaster';

    final productResponse = await http.put(
      Uri.parse(productUrl),
      headers: {
        "Content-Type": "application/json",
        'Authorization': 'Bearer $token'
      },
      body: json.encode(productData),
    );

    if (productResponse.statusCode == 200) {
      final responseData = json.decode(productResponse.body);

      if (responseData.containsKey("error")) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to add product: error")),
        );
      } else {
        scaffoldMessengerKey.currentState?.showSnackBar(
          const SnackBar(content: Text("Your message")),
        );

        // Create a new product with the image
        final selectedProduct = ord.Product(
          productName: productNameController.text,
          category: categoryController.text,
          subCategory: subCategoryController.text,
          tax: taxController.text,
          unit: unitController.text,
          price: int.parse(priceController.text),
          discount: discountController.text,
          imageId: imageIdContoller.text,
          prodId: '',
          selectedUOM: '',
          selectedVariation: '',
          quantity: 0,
          total: 0,
          totalamount: 0,
          totalAmount: 0.0,
          qty: 0,
        );

        // Add the selected product to the list
        selectedProductList.add(selectedProduct);

        // Navigate to the next page with the selectedProductList
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to add product")),
      );
    }
  }

  @override
  Widget _buildFirstWidget(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      double maxHeight = constraints.maxHeight;
      double maxWidth = constraints.maxWidth;
      // For larger screens (like web view)
      return Padding(
        padding: const EdgeInsets.only(
          left: 50,
          top: 10,
          right: 125,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Text(
                    'Product  Name',
                    style: TextStyle(
                      color: Colors.blue[900],
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(2),
                      border: Border.all(color: Colors.blue[100]!),
                    ),
                    child: TextFormField(
                      controller: productNameController,
                      decoration: InputDecoration(
                        fillColor: Colors.white,
                        enabled: isEditing,
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 10),
                        border: InputBorder.none,
                        filled: true,
                        // hintText: 'Enter product Name',
                        errorText: errorMessage,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp("[a-zA-Z0-9 ]")),
                        // Allow only letters, numbers, and single space
                        FilteringTextInputFormatter.deny(RegExp(r'^\s')),
                        // Disallow starting with a space
                        FilteringTextInputFormatter.deny(RegExp(r'\s\s')),
                        // Disallow multiple spaces
                      ],
                      validator: (value) {
                        if (value != null && value.trim().isEmpty) {
                          return 'Please enter a product name';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Text(
                          'Category',
                          style: TextStyle(
                            color: Colors.blue[900],
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(2),
                            border: Border.all(color: Colors.blue[100]!),
                          ),
                          child: TextFormField(
                            controller: categoryController,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              enabled: isEditing,
                              border: InputBorder.none,
                              hintText: 'Enter Category',
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Text(
                          'Sub Category',
                          style: TextStyle(
                            color: Colors.blue[900],
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(2),
                            border: Border.all(color: Colors.blue[100]!),
                          ),
                          child: TextFormField(
                            controller: subCategoryController,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              enabled: isEditing,
                              border: InputBorder.none,
                              hintText: 'Enter Sub Category',
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Text(
                          'Tax',
                          style: TextStyle(
                            color: Colors.blue[900],
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(2),
                            border: Border.all(color: Colors.blue[100]!),
                          ),
                          child: TextFormField(
                            controller: taxController,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              enabled: isEditing,
                              border: InputBorder.none,
                              hintText: 'Enter tax',
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Text(
                          'Unit',
                          style: TextStyle(
                            color: Colors.blue[900],
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(2),
                            border: Border.all(color: Colors.blue[100]!),
                          ),
                          child: TextFormField(
                            controller: unitController,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              enabled: isEditing,
                              border: InputBorder.none,
                              hintText: 'Enter Unit',
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Text(
                          'Price ',
                          style: TextStyle(
                            color: Colors.blue[900],
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(2),
                            border: Border.all(color: Colors.blue[100]!),
                          ),
                          child: TextFormField(
                            controller: priceController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(
                                  10), // limits to 10 digits
                            ],
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              enabled: isEditing,
                              border: InputBorder.none,
                              hintText: 'Enter Price',
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                            ),
                            onChanged: (value) {
                              if (value.isNotEmpty && !isNumeric(value)) {
                                setState(() {
                                  errorMessage = 'Please enter numbers only';
                                });
                              } else {
                                setState(() {
                                  errorMessage = null;
                                });
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Text(
                          'Discount',
                          style: TextStyle(
                            color: Colors.blue[900],
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(2),
                            border: Border.all(color: Colors.blue[100]!),
                          ),
                          child: TextFormField(
                            controller: discountController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(
                                  10), // limits to 10 digits
                            ],
                            decoration: InputDecoration(
                              filled: true,
                              enabled: isEditing,
                              border: InputBorder.none,
                              // fillColor: isEditing
                              //     ? Colors.white
                              //     : Colors.grey[100],
                              fillColor: Colors.white,
                              hintText: 'Enter Discount',
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                            ),
                            onChanged: (value) {
                              if (value.isNotEmpty && !isNumeric(value)) {
                                setState(() {
                                  errorMessage = 'Please enter numbers only';
                                });
                              } else {
                                setState(() {
                                  errorMessage = null;
                                });
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  bool isNumeric(String value) {
    return double.tryParse(value) != null;
  }

  void loadImage(String imageUrl) {
    try {
      fetchImage(imageUrl);
      // Debugging information
      print('Image loaded successfully');
    } catch (e) {
      // Handle error
      print('Error loading image: $e');
    }
  }
}
