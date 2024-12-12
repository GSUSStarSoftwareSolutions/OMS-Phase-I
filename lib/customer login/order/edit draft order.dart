
import 'dart:html';
import 'package:adaptive_scrollbar/adaptive_scrollbar.dart';
import 'package:btb/admin/Api%20name.dart';
import 'package:btb/widgets/productclass.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
//import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

import '../../Order Module/firstpage.dart';
import '../../widgets/confirmdialog.dart';

void main(){
  runApp(EditDraftOrder(selectedProducts: const [], data: const {},));
}


class Order {
  final String prodId;

  final String? proId;
  final String productName;
  String subCategory;
  String category;
  final String unit;
  final String tax;
  int qty;
  final String discount;
  final int price;
  String? selectedUOM;
  String? selectedVariation;
  int quantity;
  double total;
  double totalAmount;
  double totalamount;
  final String imageId;

  @override
  String toString() {
    return 'Order{productName: $productName, category: $category, subCategory: $subCategory, price: $price, qty: $qty, totalAmount: $totalAmount, imageId: $imageId}';
  }

  Order({
    required this.prodId,
    required this.category,
    this.proId,
    required this.qty,
    required this.productName,
    required this.totalAmount,
    required this.subCategory,
    required this.unit,
    required this.selectedUOM,
    required this.selectedVariation,
    required this.quantity,
    required this.total,
    required this.totalamount,
    required this.tax,
    required this.discount,
    required this.price,
    required this.imageId,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      prodId: json['prodId'] ?? '',
      category: json['category'] ?? '',
      productName: json['productName'] ?? '',
      subCategory: json['subCategory'] ?? '',
      unit: json['unit'] ?? '',
      tax: json['tax'] ?? '',
      totalAmount: (json['totalAmount'] is String ? double.tryParse(json['totalAmount']) : json['totalAmount']) ?? 0.0,
      qty: (json['qty'] is String ? int.tryParse(json['qty']): json['qty'] ?? 0),
      quantity: (json['quantity'] is String ? int.tryParse(json['quantity']) : json['quantity']) ?? 0,
      total: (json['totalamount'] is String ? double.tryParse(json['total']) : json['total']) ?? 0.0,
      totalamount: (json['total'] is String ? double.tryParse(json['totalamount']) : json['totalamount']) ?? 0.0,
      discount: json['discount'] ?? '',
      selectedUOM: json['uom'] ?? 'Select',
      selectedVariation: json['variation'] ?? 'Select',
      price: json['price'] ?? 0,
      imageId: json['imageId'] ?? '',
      proId: json['proId'] ?? '',
    );
  }


  Map<String, dynamic> asMap() {
    return {
      'proId': proId,
      'productName': productName,
      'category': category,
      'subCategory': subCategory,
      'price': price,
      'tax': tax,
      'unit': unit,
      'discount': discount,
      'selectedUOM': selectedUOM,
      'selectedVariation': selectedVariation,
      'quantity': quantity,
      'total': total,
      'totalamount': totalamount,
    };
  }
  Product orderToProduct() {
    return Product(
      prodId: prodId,
      price: price,
      productName: productName,
      proId: proId,
      category: category,
      subCategory: subCategory,
      selectedVariation: selectedVariation,
      selectedUOM: selectedUOM,
      totalamount: totalamount,
      total: total,
      tax: tax,
      quantity: quantity,
      discount: discount,
      imageId: imageId,
      unit: unit,
      totalAmount: totalAmount, qty: qty,
    );
  }

  Order productToOrder() {
    return Order(
      prodId: prodId,
      price: price,
      productName: productName,
      proId: proId,
      category: category,
      subCategory: subCategory,
      selectedVariation: selectedVariation,
      selectedUOM: selectedUOM,
      totalamount: totalamount,
      total: total,
      tax: tax,
      quantity: quantity,
      discount: discount,
      imageId: imageId,
      unit: unit,
      totalAmount: totalAmount,
      qty: qty,
    );
  }
}




class EditDraftOrder extends StatefulWidget {
  // final  List<Order> selectedProducts;
  final List<Product> selectedProducts;
  final Map<String, dynamic> data;
  final Map<String, dynamic>? orderDetails;


  EditDraftOrder({
    required this.selectedProducts,
    required this.data,this.orderDetails});

  @override
  State<EditDraftOrder> createState() => _EditDraftOrderState();
}

class _EditDraftOrderState extends State<EditDraftOrder> {
  bool isOrdersSelected = false;
  int itemCount = 0;
  double _total = 0.0;
  Map<String, dynamic> data1 = {};
  double _total1 = 0.0;
  late List<Map<String, dynamic>> items;
  late Future<List<detail>> futureOrders;
  Map<String, bool> _isHovered = {
    'Orders': false,
    'Invoice': false,
    'Delivery': false,
    'Payment': false,
    'Return': false,
  };

  final ScrollController horizontalScroll = ScrollController();
  final TextEditingController deliveryAddressController = TextEditingController();
  final TextEditingController contactPersonController = TextEditingController();
  final TextEditingController contactNumberController = TextEditingController();
  final TextEditingController commentsController = TextEditingController();
  final TextEditingController CreatedDateController = TextEditingController();
  final TextEditingController orderIdController = TextEditingController();
  final TextEditingController totalController = TextEditingController();
  final TextEditingController productNameController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();
  final TextEditingController subCategoryController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController qtyController = TextEditingController();
  List<Map<String, dynamic>> selectedItems = [];
  List<Order> selectedProducts = [];
  Map<String, dynamic> data2 = {};
  List<detail>filteredData= [];
  List<Order> itemdetails = [];
  List<Product> productList = []; //updated details
  //List<Map<String, dynamic>> selectedItems = [];
  final TextEditingController _contactPersonController = TextEditingController();
  final TextEditingController _contactNumberController = TextEditingController();
  final TextEditingController  _shippingAddress = TextEditingController();
  final TextEditingController  _deliveryaddressController = TextEditingController();
  final TextEditingController  _createdDateController = TextEditingController();
  late TextEditingController _dateController;
  List<dynamic> detailJson =[];
  String _searchText = '';
  String searchQuery = '';
  String userId = window.sessionStorage['userId'] ?? '';
  final String _category = '';
  String status= '';
  String selectDate ='';
  //String orderId = '';
  String token = window.sessionStorage["token"]?? " ";
  final List<String> list = ['  Name 1', '  Name 2', '  Name3'];
  final TextEditingController ContactPersonController = TextEditingController();
  final TextEditingController InvoiceNumberController = TextEditingController();
  final TextEditingController EmailIdController = TextEditingController();



  DateTime? _selectedDate;

  bool _hasShownPopup = false;

  List<Widget> _buildMenuItems(BuildContext context) {
    return [
      _buildMenuItem('Home', Icons.home_outlined, Colors.blue[900]!, '/Cus_Home'),
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
          ),child: _buildMenuItem('Orders', Icons.warehouse_outlined, Colors.white, '/Customer_Order_List')),
      _buildMenuItem('Delivery', Icons.fire_truck_outlined, Colors.blue[900]!, '/Customer_Delivery_List'),
      _buildMenuItem('Invoice', Icons.document_scanner_outlined, Colors.blue[900]!, '/Customer_Invoice_List'),
      _buildMenuItem('Payment', Icons.payment_rounded, Colors.blue[900]!, '/Customer_Payment_List'),
      _buildMenuItem('Return', Icons.keyboard_return, Colors.blue[900]!, '/Customer_Return_List'),
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
                    icon: const Icon(Icons.close, color: Colors.blue),
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
                      const Icon(Icons.warning, color: Colors.orange, size: 50),
                      const SizedBox(height: 16),
                      // Confirmation Message
                      const Text(
                        'Are You Sure',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 20),
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
                              side: const BorderSide(color: Colors.blue),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                            child: const Text(
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
                              side: const BorderSide(color: Colors.red),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                            child: const Text(
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
  Future<void> fetchCount() async {

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
      if (token == " ") {
        showDialog(
          barrierDismissible: false,
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
                            "Please log in again to continue", style: TextStyle(
                            fontSize: 12,

                            color: Colors.black,
                          ),),
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
      }
      else{
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
          List<detail> matchedCustomers = products.where((customer) {
            return customer.CusId == userId;
          }).toList();

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
    }
    } catch (e) {
      print('Error decoding JSON: $e');
// Optionally, show an error message to the user
    } finally {
      if (mounted) {
      }
    }
  }


  @override
  void initState() {
    super.initState();
    fetchCount();
    print('--addproductmaster');

    print(widget.selectedProducts);
    futureOrders = fetchOrders() as Future<List<detail>>;
    if(widget.selectedProducts.isEmpty) {
      print('---selectedproducts');
      print(widget.data['total']);
      print(widget.data['invoiceNo']);

      // widget.data['items'] = widget.selectedProducts;
      print(widget.data);
      print(_createdDateController.text);
      print('--orderdate');
      // print(widget.data['orderDate']);
      widget.data['orderDate'];
      print(widget.data['orderDate']);
      ContactPersonController.text;
      widget.data['contactNumber'];
      widget.data['contactNumber'];
      widget.data['deliveryAddress'];
      widget.data['comments'];
      print(_contactPersonController.text);
      print(widget.data['contactNumber']);
      print(widget.data['comments']);
      print( widget.data['deliveryAddress']);
      // print(_contactPersonController.text);
      print('---contractper');
      print(_contactNumberController.text);


      if (widget.data != null && widget.data['items'] != null) {
        itemdetails = widget.data['items'].map<Order>((item) => Order(
          productName: item['productName'],
          category: item['category'],
          subCategory: item['subCategory'],
          price: item['price'],
          qty: 0,
          tax: item['tax'],
          discount: item['discount'],
          selectedUOM: '',
          selectedVariation: '',
          quantity: item['qty'],
          unit: '',
          prodId: '',
          proId: '',
          total: item['totalAmount'] ?? 0.0,
          totalamount: item['actualAmount'], // Provide a default value of 0.0 if totalAmount is null
          imageId: '',
          totalAmount: 0.0,
        )).toList();

        // Convert List<Order> to List<Product>
        productList = itemdetails.map((order) => order.orderToProduct()).toList();
      }

      widget.data['orderDate'];
      print(_createdDateController.text);
      InvoiceNumberController.text = widget.data['invoiceNo'] ?? '';
      EmailIdController.text = widget.data['deliveryLocation'] ??'';
      _createdDateController.text = widget.data['orderDate'] ?? '';
      _contactPersonController.text = widget.data['contactPerson'] ?? '';
      _contactNumberController.text = widget.data['contactNumber'] ?? '';
      print('contact number length');
      print(_contactNumberController.text);
      print(_contactNumberController.text.length);
      _shippingAddress.text = widget.data['comments'] ?? '';
      _deliveryaddressController.text = widget.data['deliveryAddress'] ?? '';



      print("Selected products in SelectedProductPage: ${widget.selectedProducts}");
      items = widget.selectedProducts.map((order) {
        return {
          'productName': order.productName,
          'category': order.category,
          'subCategory': order.subCategory,
          'price': order.price,
          'qty': order.quantity,
          'totalAmount': order.totalAmount != null ? order.totalAmount : 0.0,
        };
      }).toList();
      print(widget.data['items']);
      _dateController = TextEditingController();
      _selectedDate = DateTime.now();
      _dateController.text = DateFormat('dd/MM/yyyy').format(_selectedDate!);
      InvoiceNumberController.text = widget.data['invoiceNo'] ?? '';
      _createdDateController.text = widget.data['orderDate'] ?? '';
      _contactPersonController.text = widget.data['contactPerson'] ?? '';
      _contactNumberController.text = widget.data['contactNumber'] ?? '';
      _shippingAddress.text = widget.data['comments'] ?? '';
      EmailIdController.text = widget.data['deliveryLocation'] ?? '';
      _deliveryaddressController.text = widget.data['deliveryAddress'] ?? '';

    }


    else{
      data2.remove('items');
      print('---selectedproducts');
      print('this one is else');
      print(widget.selectedProducts);
      print('---selectedproducts');
      // print(widget.selectedProducts);
      // widget.data['items'] = widget.selectedProducts;
      print(widget.data);
      print(_createdDateController.text);
      print('--orderdate');
      _calculateTotal();
      // print(widget.data['orderDate']);
      widget.data['orderDate'];
      print(widget.data['orderDate']);
      ContactPersonController.text;
      widget.data['contactNumber'];
      widget.data['contactNumber'];
      widget.data['deliveryAddress'];
      widget.data['comments'];
      print(_contactPersonController.text);
      print(widget.data['contactNumber']);
      print(widget.data['comments']);
      print( widget.data['deliveryAddress']);
      // print(_contactPersonController.text);
      print('---contractper');
      print(_contactNumberController.text);

      if (widget.data != null && widget.data['items'] != null) {
        itemdetails = widget.data['items'].map<Order>((item) => Order(
          productName: item['productName'],
          category: item['category'],
          subCategory: item['subCategory'],
          price: item['price'],
          qty: item['qty'],
          tax: item['tax'],
          discount: '',
          selectedUOM: '',
          selectedVariation: '',
          quantity: item['qty'],
          unit: '',
          prodId: '',
          proId: '',
          total: item['totalAmount'] ?? 0.0,
          totalamount: 0.0, // Provide a default value of 0.0 if totalAmount is null
          imageId: '',
          totalAmount: 0.0,
        )).toList();

        // Convert List<Order> to List<Product>
        productList = itemdetails.map((order) => order.orderToProduct()).toList();
      }



      widget.data['orderDate'];

      print(_createdDateController.text);
      InvoiceNumberController.text = widget.data['invoiceNo'] ?? '';
      _createdDateController.text = widget.data['orderDate'];
      _contactPersonController.text = widget.data['contactPerson'];
      _contactNumberController.text = widget.data['contactNumber'];
      _shippingAddress.text = widget.data['comments'];
      _deliveryaddressController.text =widget.data['deliveryAddress'];
      EmailIdController.text = widget.data['deliveryLocation'];

      // data['totalAmount'] = widget.selectedProducts['total'];
      print("Selected products in SelectedProductPage: ${widget.selectedProducts}");
      widget.data['items'] = widget.selectedProducts.map((order) {
        updateTotalAmount(0);
        // widget.data['totalAmount'] = widget.selectedProducts;
        return {
          'productName': order.productName,
          'category': order.category,
          'subCategory': order.subCategory,
          'price': order.price,
          'qty': order.quantity,
          // 'totalAmount': order.totalAmount,
          'totalAmount': order.totalAmount != 0 ? order.totalAmount : widget.data['totalAmount'],
          'tax': order.tax,
          'discount': order.discount,
          // 'actualAmount':   order.totalAmount != 0 ? order.totalAmount : widget.data['totalAmount'],
          'actualAmount': order.totalAmount,
        };
      }).toList();
      print('----total');
      _calculateTotal();
      print(widget.data['totalAmount']);
      print(widget.data['total']);
      print(widget.data['items']);
      _dateController = TextEditingController();
      _selectedDate = DateTime.now();
      String formattedDate = DateFormat('dd/MM/yyyy').format(_selectedDate!);
      // _dateController.text = _selectedDate != null ? DateFormat('dd/MM/yyy').format(_selectedDate!) : '';
      _dateController.text = formattedDate;
      //   _selectedDate = DateTime.now();
      //_dateController.text = DateFormat('dd/MM/yyyy').format(_selectedDate!);
      InvoiceNumberController.text = widget.data['invoiceNo'] ?? '';
      _createdDateController.text = widget.data['orderDate'];
      _contactPersonController.text = widget.data['contactPerson'];
      _contactNumberController.text = widget.data['contactNumber'];
      _shippingAddress.text = widget.data['comments'];
      _deliveryaddressController.text =widget.data['deliveryAddress'];

      // widget.data['items'] = widget.selectedProducts;
    }
    /// widget.selectedProducts;
    // widget.data['items'] = widget.selectedProducts;
  }

  Widget buildDataTable() {
    return LayoutBuilder(builder: (context, constraints){
      double right = constraints.maxWidth;

      return FutureBuilder<List<detail>>(
        future: futureOrders,
        builder: (context, snapshot) {

          if (snapshot.hasData) {
            filteredData = snapshot.data!.where((element) {
              final matchesSearchText= element.orderId!.toLowerCase().contains(searchQuery.toLowerCase());
              print('-----');
              print(element.orderDate);
              String orderYear = '';
              if (element.orderDate.contains('/')) {
                final dateParts = element.orderDate.split('/');
                if (dateParts.length == 3) {
                  orderYear = dateParts[2]; // Extract the year
                }
              }
              // final orderYear = element.orderDate.substring(5,9);
              if (status.isEmpty && selectDate.isEmpty) {
                return matchesSearchText; // Include all products that match the search text
              }
              if(status == 'Status' && selectDate == 'SelectYear'){
                return matchesSearchText;
              }
              if(status == 'Status' &&  selectDate.isEmpty)
              {
                return matchesSearchText;
              }
              if(selectDate == 'SelectYear' &&  status.isEmpty)
              {
                return matchesSearchText;
              }
              if (status == 'Status' && selectDate.isNotEmpty) {
                return matchesSearchText && orderYear == selectDate; // Include all products
              }
              if (status.isNotEmpty && selectDate == 'SelectYear') {
                return matchesSearchText && element.status == status;// Include all products
              }
              if (status.isEmpty && selectDate.isNotEmpty) {
                return matchesSearchText && orderYear == selectDate; // Include all products
              }

              if (status.isNotEmpty && selectDate.isEmpty) {
                return matchesSearchText && element.status == status;// Include all products
              }
              return matchesSearchText &&
                  (element.status == _category && element.orderDate == selectDate);
              //  return false;
            }).toList();

            // Print the details in the console
            filteredData.forEach((detail) {
              print('Status: ${detail.status}');
              print('Order ID: ${detail.orderId}');
              print('Created Date: ${detail.orderDate}');
              print('Reference Number: ${detail.referenceNumber}');
              print('Total Amount: ${detail.total}');
              print('Delivery Status: ${detail.deliveryStatus}');
              print('------------------------');
            });

            // Return an empty Container to not show anything in the UI
            return Container();
          } else if (snapshot.hasError) {
            return Center(child: Text("${snapshot.error}"));
          }

          return const Center(child: CircularProgressIndicator());
        },
      );
    });
  }


  Future<List<detail>> fetchOrders() async {
    if (token == " ") {
      showDialog(
        barrierDismissible: false,
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
                          "Please log in again to continue", style: TextStyle(
                          fontSize: 12,

                          color: Colors.black,
                        ),),
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
      return [];
    }
    final response = await http.get(
      Uri.parse(
          '$apicall/order_master/get_all_ordermaster'),
      headers: {
        'Authorization': 'Bearer $token',
        // Add the token to the Authorization header
      },
    );

   if (response.statusCode == 200) {
      detailJson = json.decode(response.body);
      List<detail> filteredData = detailJson.map((json) =>
          detail.fromJson(json)).toList();
      if (_searchText.isNotEmpty) {
        print(_searchText);
        filteredData = filteredData.where((detail) =>
            detail.orderId!.toLowerCase().contains(_searchText.toLowerCase()))
            .toList();
      }
      return filteredData;
    } else {
      throw Exception('Failed to load orders');

  }
  }


  void _updateOrder(Map<String, dynamic> updatedOrder) async {
    final response = await http.put(
      Uri.parse('$apicall/order_master/add_update_delete_order_master'),
      headers: <String, String>{
        'Authorization': 'Bearer $token', // Replace with your API key
        'Content-Type': 'application/json',
      },
      body: jsonEncode(updatedOrder),
    );
    if (token == " ") {
      showDialog(
        barrierDismissible: false,
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
                          "Please log in again to continue", style: TextStyle(
                          fontSize: 12,

                          color: Colors.black,
                        ),),
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
    }
    else {
      if (response.statusCode == 200) {
        fetchCount();
        print('Return Master added successfully');
        final responseBody = jsonDecode(response.body);
        final OrderID = responseBody['id'];

        await showDialog(
          barrierDismissible: false,
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(5)),
              ),
              icon: const Icon(
                Icons.check_circle_rounded,
                color: Colors.green,
                size: 25,
              ),
              title: const Padding(
                padding: EdgeInsets.only(left: 12),
                child: Text('Order Created Successfully',
                  style: TextStyle(fontSize: 15),),
              ),
              content: Padding(
                  padding: const EdgeInsets.only(left: 25),
                  child: Row(
                    children: [
                      const Text('Your Order ID is: '),
                      SelectableText('$OrderID'),
                    ],
                  )
              ),
              actions: <Widget>[
                ElevatedButton(
                  child: const Text(
                    'OK', style: TextStyle(color: Colors.white),),
                  onPressed: () {
                    context.go('/Customer_Order_List');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    side: const BorderSide(color: Colors.blue),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
              ],
            );
          },
        );

        // final responseData = jsonDecode(response.body);
        //
        // String orderId;
        //
        // try {
        //   orderId = responseData['id'];
        //
        // }catch(e){
        //   print('Error parsing orderId: $e');
        //   orderId = ''; // or some default value
        // }
        // print('from the api response');
        // print(orderId);
        //
        // context.go('/View_Draft_Order',extra: {
        //   'selectedProducts': updatedOrder,
        //   'orderId': orderId,
        //   'orderDetails':  filteredData.map((detail) => OrderDetail(
        //     orderId: detail.orderId,
        //     orderDate: detail.orderDate,
        //     items: [],
        //     // Add other fields as needed
        //   )).toList(),
        //
        // });
      } else {
        // If the server did not return a 200 OK response,
        // then throw an exception.
        throw Exception('Failed to update order.');
      }
    }

  }
  void updateTotalAmount(int productIndex) {
    if (productIndex >= 0 && productIndex < widget.selectedProducts.length) {
      double totalAmount = widget.selectedProducts[productIndex].total;
      setState(() {
        widget.data['totalAmount'] = totalAmount;
      });
    }
  }


  void _deleteProduct(int index) {
    setState(() {
      widget.data['items'].removeAt(index);
      _calculateTotal();
    });
    // _calculateTotal(); // need on the last step
  }





  void _calculateTotal() {
    double total = 0;
    double total1 = 0;

    for (var item in widget.data['items']) {
      double itemTotal = calculateTotalAmount(item);
      double itemActual = calculateActualAmount(item);

      print('Item: ${item['name']}');  // Debug info for each item
      print('Total Amount: $itemTotal');
      print('Actual Amount: $itemActual');

      total += itemTotal;
      total1 += itemActual;
    }

    setState(() {
      widget.data['total'] = total;  // Update the total rounded value
      widget.data['total1'] = total1;  // Update the total1 rounded value
    });
  }

  @override
  void dispose() {
    _contactPersonController.dispose();
    // TODO: implement dispose
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    TableRow row1 = const TableRow(
      children: [
        TableCell(
          child: Padding(
            padding: EdgeInsets.only(left: 30,top: 10,bottom: 10),
            child: Text('Delivery Details',style: TextStyle(fontSize: 19),),
          ),
        ),
        TableCell(
          child: Text(''),
        ),
      ],
    );

    TableRow row2 = const TableRow(
      children: [
        TableCell(
          child: Padding(
            padding: EdgeInsets.only(left: 30,top: 10,bottom: 10),
            child: Text('Billing Address',style: TextStyle(fontSize: 16)),
          ),
        ),
        TableCell(
          child: Padding(
            padding: EdgeInsets.only(left: 10,top: 10,bottom: 10),
            child: Text('Shipping Address',style: TextStyle(fontSize: 16)),
          ),
        ),
      ],
    );
    TableRow row3 = TableRow(
      children: [
        TableCell(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding:  EdgeInsets.only(left: 30,top: 10),
                      child:  Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Contact Person'),
                          SizedBox(width: 5,),
                          Text('*', style: TextStyle(color: Colors.red),),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10,),
                    Padding(
                      padding: const EdgeInsets.only(left: 30),
                      child: SizedBox(
                        width: screenWidth * 0.35,
                        height: 40,
                        child:
                        TextFormField(
                          controller: _contactPersonController,

                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp("[a-zA-Z ]")),
                            // Allow only letters, numbers, and single space
                            FilteringTextInputFormatter.deny(
                                RegExp(r'^\s')),
                            // Disallow starting with a space
                            FilteringTextInputFormatter.deny(
                                RegExp(r'\s\s')),
                            // Disallow multiple spaces
                          ],
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.grey.shade100, // Changed to white
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0),
                              borderSide: const BorderSide(color: Color(0xFFBBDEFB)), // Added blue border
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0),
                              borderSide: const BorderSide(color: Colors.grey), // Added blue border
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0),
                              borderSide: const BorderSide(color: Colors.blue), // Added blue border
                            ),
                            hintText: 'Enter Contact Person',
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 8),
                          ),
                          validator: (value) {
                            if (ContactPersonController.text != null && ContactPersonController.text.trim().isEmpty) {
                              return 'Please enter a product name';
                            }
                            return null;
                          },


                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Padding(
                      padding:  EdgeInsets.only(left: 30),
                      child:  Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Delivery Address'),
                          SizedBox(width: 5,),
                          Text('*', style: TextStyle(color: Colors.red),),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10,),
                    Padding(
                      padding: const EdgeInsets.only(left: 30),
                      child: SizedBox(
                        width: screenWidth * 0.35,
                        child: TextField(
                          controller: _deliveryaddressController,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.grey.shade100, // Changed to white
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0),
                              borderSide: const BorderSide(color: Color(0xFFBBDEFB)), // Added blue border
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0),
                              borderSide: const BorderSide(color: Colors.grey), // Added blue border
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0),
                              borderSide: const BorderSide(color: Colors.blue), // Added blue border
                            ),
                            hintText: 'Enter Your Address',
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp("[a-zA-Z0-9-,./ \r\n]"), // Add \r\n to the pattern
                            ),
                            // Allow only letters, numbers, and single space
                            FilteringTextInputFormatter.deny(
                                RegExp(r'^\s')),
                            // Disallow starting with a space
                            FilteringTextInputFormatter.deny(
                                RegExp(r'\s\s')),
                            // Disallow multiple spaces
                          ],
                          maxLines: 3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 30),
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 10),
                      child:  Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Contact Number'),
                          SizedBox(width: 5,),
                          Text('*', style: TextStyle(color: Colors.red),),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10,),
                    Padding(
                      padding: const EdgeInsets.only(right: 20),
                      child: SizedBox(
                        width: screenWidth * 0.2,
                        height: 40,
                        child: TextFormField(

                          controller: _contactNumberController,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.grey.shade100, // Changed to white
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0),
                              borderSide: const BorderSide(color: Color(0xFFBBDEFB)), // Added blue border
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0),
                              borderSide: const BorderSide(color: Colors.grey), // Added blue border
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0),
                              borderSide: const BorderSide(color: Colors.blue), // Added blue border
                            ),
                            hintText: 'Contact Person Number',

                            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(10), // limits to 10 digits
                          ],



                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Email Id'),
                        SizedBox(width: 5,),
                        Text('*', style: TextStyle(color: Colors.red),),
                      ],
                    ),
                    const SizedBox(height: 10,),
                    Padding(
                      padding: const EdgeInsets.only(right: 20),
                      child: SizedBox(
                        width: screenWidth * 0.2,
                        height: 40,
                        child: TextFormField(
                          controller: EmailIdController,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp("[a-zA-Z,0-9,@.]")),
                            FilteringTextInputFormatter.deny(RegExp(r'^\s')),
                            FilteringTextInputFormatter.deny(RegExp(r'\s\s')),
                          ],

                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.grey.shade100, // Changed to white
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0),
                              borderSide: const BorderSide(color: Color(0xFFBBDEFB)), // Added blue border
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0),
                              borderSide: const BorderSide(color: Colors.grey), // Added blue border
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0),
                              borderSide: const BorderSide(color: Colors.blue), // Added blue border
                            ),
                            hintText: 'Enter Email Id',
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        TableCell(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('    '),
                      Padding(
                        padding: const EdgeInsets.only(right: 10, left: 10, bottom: 5),
                        child: SizedBox(
                          height: 250,
                          child: TextField(
                            controller: _shippingAddress,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.grey.shade100, // Changed to white
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5.0),
                                borderSide: const BorderSide(color: Color(0xFFBBDEFB)), // Added blue border
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5.0),
                                borderSide: const BorderSide(color: Colors.grey), // Added blue border
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5.0),
                                borderSide: const BorderSide(color: Colors.blue), // Added blue border
                              ),
                              hintText: 'Enter Your Comments',
                            ),
                            maxLines: 5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )

        ),
      ],
    );
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        // backgroundColor: const Color(0xFFFFFFFF),
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
          body:
          LayoutBuilder(
              builder: (context, constraints){
                void _onSaveChanges() {
                  List<String> errors = [];
                  if (_deliveryaddressController.text.isEmpty) {
                    errors.add('Delivery address is required');
                  }
                  if (EmailIdController
                      .text
                      .isEmpty ||
                      !RegExp(r'^[\w-]+(\.[\w-]+)*@[a-zA-Z0-9-]+\.(com|in|net)$')
                          .hasMatch(
                          EmailIdController.text)) {
                    ScaffoldMessenger.of(
                        context)
                        .showSnackBar(
                      SnackBar(
                          content:
                          Text('Enter Valid E-mail Address')),
                    );
                  }
                  if (_contactPersonController.text.isEmpty || _contactPersonController.text.length <=2) {
                    errors.add('Please enter a contact person name.');
                  }
                  if (_contactNumberController.text.isEmpty || _contactNumberController.text.length !=10) {
                    errors.add('Please enter a valid phone number.');
                  }
                  if(_shippingAddress.text.isEmpty){
                    errors.add('Please enter shipping address.');

                  }
                  if (widget.data['items'].isEmpty) {
                    errors.add('Please Select Items are required');
                  }
                  if (errors.isNotEmpty) {
                    String errorMessage = errors.join('\n');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(errorMessage)),
                    );
                  } else {
                    print('api call success');
                    print(widget.data['items']);
                    print(widget.data['orderId']);
                    List<Map<String, dynamic>> updatedItems = [];
                    for (var item in widget.data['items']) {
                      Map<String, dynamic> updatedItem = {
                        'productName': item['productName'],
                        'category': item['category'],
                        'subCategory': item['subCategory'],
                        'price': item['price'],
                        'qty': item['qty'],
                        'actualAmount': calculateActualAmount(item),
                        'discount': item['discount'],
                        'tax': item['tax'],
                        'totalAmount': calculateTotalAmount(item),
                      };
                      updatedItems.add(updatedItem);
                    }
                    final updatedOrder = {
                      "Status": 'Not Started',
                      "orderId": widget.data['orderId'],
                      "orderDate": _dateController.text,
                      "customerId": widget.data['CusId'],
                      "deliveryLocation": EmailIdController.text,
                      "deliveryAddress": _deliveryaddressController.text,
                      "contactPerson": _contactPersonController.text,
                      "contactNumber": _contactNumberController.text,
                      "comments": _shippingAddress.text,
                      "invoiceNo": InvoiceNumberController.text,
                      "total": double.parse(widget.data['total'].toString()),
                      // "items": widget.data['items'],
                      "items": updatedItems,
                    };
                    _updateOrder(updatedOrder);
                  }
                }
                double maxHeight = constraints.maxHeight;
                double maxWidth = constraints.maxWidth;
                return Stack(
                  children: [
                    if (constraints.maxHeight <= 310) ...{
                      SingleChildScrollView(
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Container(
                            width: 200,
                            color: const Color(0xFFF7F6FA),
                            padding:
                            const EdgeInsets.only(left: 15, top: 10, right: 15),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: _buildMenuItems(context),
                            ),
                          ),
                        ),
                      )
                    } else ...{
                      Align(
                        alignment: Alignment.topLeft,
                        child: Container(
                          width: 200,
                          height: 984,
                          color: const Color(0xFFF7F6FA),
                          padding:
                          const EdgeInsets.only(left: 15, top: 10, right: 15),
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
                                IconButton(
                                  icon:
                                  const Icon(Icons.arrow_back), // Back button icon
                                  onPressed: () {
                                    context.go('/Customer_Order_List');
                                  },
                                ),
                                const Padding(
                                  padding: EdgeInsets.only(left: 30),
                                  child: Text(
                                    'Create Order',
                                    style: TextStyle(
                                      fontSize: 20,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                const Spacer(),
                                Padding(
                                  padding: const EdgeInsets.only(right: 100),
                                  child: OutlinedButton(
                                    onPressed: ()  {
                                      _onSaveChanges();
                                    },
                                    style: OutlinedButton.styleFrom(
                                      backgroundColor:
                                      Colors.blue[800], // Button background color
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                        BorderRadius.circular(5), // Rounded corners
                                      ),
                                      side: BorderSide.none, // No outline
                                    ),
                                    child: const Text(
                                      'Place Order',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),

                              ],
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(
                                vertical: 1), // Space above/below the border
                            height: 0.3,
                            // width: 1000,
                            width: constraints.maxWidth,// Border height
                            color: Colors.black, // Border color
                          ),
                          if(constraints.maxWidth >= 1300)...{
                            Expanded(child: SingleChildScrollView(
                              child: Column(children: [
                                Padding(
                                  padding: const EdgeInsets.only(right: 100),
                                  child: Container(
                                    width: maxWidth,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Padding(
                                          padding:  EdgeInsets.only(top: 50,right: maxWidth * 0.085),
                                          child: const Text(('Order Date')),
                                        ),
                                        Padding(
                                          padding:  const EdgeInsets.only(top: 10,),
                                          child: DecoratedBox(
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: const Color(0xFFEBF3FF), width: 1),
                                              borderRadius: BorderRadius.circular(10),

                                            ),
                                            child: Container(
                                              height: 39,
                                              width: maxWidth *0.13,
                                              decoration: BoxDecoration(
                                                color: Colors.white
                                                    .withOpacity(1), // Opacity is 1, fully opaque
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: Column(
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
                                                        fillColor: Colors.grey.shade200,
                                                        contentPadding: const EdgeInsets.symmetric(
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
                                        ),
                                        //this is a new copy of now

                                      ],
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 80,right: 100,top: 40),
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFFFFFFF), // background: #FFFFFF
                                      boxShadow: [BoxShadow(
                                        offset: Offset(0, 3),
                                        blurRadius: 6,
                                        color: Color(0x29000000), // box-shadow: 0px 3px 6px #00000029
                                      )],
                                      // border: Border.all(
                                      //   // border: 2px
                                      //   color: Color(0xFFB2C2D3), // border: #B2C2D3
                                      // ),
                                      borderRadius: BorderRadius.all(Radius.circular(4)), // border-radius: 8px
                                    ),
                                    child: Table(
                                      border: TableBorder.all(color: const Color(0xFFB2C2D3),borderRadius: BorderRadius.circular(4)),

                                      columnWidths: const {
                                        0: FlexColumnWidth(2),
                                        1: FlexColumnWidth(1.4),
                                      },
                                      children: [
                                        row1,
                                        row2,
                                        row3,
                                      ],
                                    ),
                                  ),
                                ),
                                buildDataTable(),
                                Padding(
                                  padding: const EdgeInsets.only
                                    (top:100, left:80, right: 100,bottom: 25),
                                  child: SizedBox(
                                    width: maxWidth*0.785,
                                    child: Container(
                                      width: maxWidth,
                                      padding: const EdgeInsets.all(0.0),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFFFFFF), // background: #FFFFFF
                                        boxShadow: const [BoxShadow(
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
                                          Padding(
                                            padding: const EdgeInsets.only(left: 30, top: 10),
                                            child: Text(
                                              'Add Products',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Container(
                                            width: maxWidth,
                                            decoration: const BoxDecoration(
                                              border: Border(
                                                top: BorderSide(color: Color(0xFFB2C2D3), width: 1.2),
                                                bottom: BorderSide(color: Color(0xFFB2C2D3), width: 1.2),
                                              ),
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.only(top: 5, bottom: 5),
                                              child: Table(
                                                columnWidths: const {
                                                  0: FlexColumnWidth(1),
                                                  1: FlexColumnWidth(2.7),
                                                  2: FlexColumnWidth(2),
                                                  3: FlexColumnWidth(1.8),
                                                  4: FlexColumnWidth(2),
                                                  5: FlexColumnWidth(1),
                                                  6: FlexColumnWidth(2),
                                                  7: FlexColumnWidth(1),
                                                  8: FlexColumnWidth(1),
                                                  9: FlexColumnWidth(1),
                                                  10: FlexColumnWidth(1),

                                                },
                                                children: const [
                                                  TableRow(
                                                    children: [
                                                      TableCell(
                                                        child: Padding(
                                                          padding: EdgeInsets.only(top: 10, bottom: 10),
                                                          child: Center(
                                                            child: Text(
                                                              'SN',
                                                              style: TextStyle(fontWeight: FontWeight.bold),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      TableCell(
                                                        child: Padding(
                                                          padding: EdgeInsets.only(top: 10, bottom: 10),
                                                          child: Center(
                                                            child: Text(
                                                              'Product Name',
                                                              style: TextStyle(fontWeight: FontWeight.bold),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      TableCell(
                                                        child: Padding(
                                                          padding: EdgeInsets.only(top: 10, bottom: 10),
                                                          child: Center(
                                                            child: Text(
                                                              'Category',
                                                              style: TextStyle(fontWeight: FontWeight.bold),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      TableCell(
                                                        child: Padding(
                                                          padding: EdgeInsets.only(top: 10, bottom: 10),
                                                          child: Center(
                                                            child: Text(
                                                              'Sub Category',
                                                              style: TextStyle(fontWeight: FontWeight.bold),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      TableCell(
                                                        child: Padding(
                                                          padding: EdgeInsets.only(top: 10, bottom: 10),
                                                          child: Center(
                                                            child: Text(
                                                              'Price',
                                                              style: TextStyle(fontWeight: FontWeight.bold),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      TableCell(
                                                        child: Padding(
                                                          padding: EdgeInsets.only(top: 10, bottom: 10),
                                                          child: Center(
                                                            child: Text(
                                                              'QTY',
                                                              style: TextStyle(fontWeight: FontWeight.bold),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      TableCell(
                                                        child: Padding(
                                                          padding: EdgeInsets.only(top: 10, bottom: 10),
                                                          child: Center(
                                                            child: Text(
                                                              'Amount',
                                                              style: TextStyle(fontWeight: FontWeight.bold),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      TableCell(
                                                        child: Padding(
                                                          padding: EdgeInsets.only(top: 10, bottom: 10),
                                                          child: Center(
                                                            child: Text(
                                                              'Disc.',
                                                              style: TextStyle(fontWeight: FontWeight.bold),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      TableCell(
                                                        child: Padding(
                                                          padding: EdgeInsets.only(top: 10, bottom: 10),
                                                          child: Center(
                                                            child: Text(
                                                              'TAX',
                                                              style: TextStyle(fontWeight: FontWeight.bold),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      TableCell(
                                                        child: Padding(
                                                          padding: EdgeInsets.only(top: 10, bottom: 10),
                                                          child: Center(
                                                            child: Text(
                                                              'Total Amount',
                                                              style: TextStyle(fontWeight: FontWeight.bold),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      TableCell(
                                                        child: Padding(
                                                          padding: EdgeInsets.only(top: 10, bottom: 10),
                                                          child: Center(
                                                            child: Text(
                                                              '    ',
                                                              style: TextStyle(fontWeight: FontWeight.bold),
                                                            ),
                                                          ),
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
                                            itemCount: widget.data['items']!= null? widget.data['items'].length : items!= null? items.length : 0,
                                            itemBuilder: (context, index) {
                                              Map<String, dynamic> item = widget.data['items']!= null? widget.data['items'][index] : items[index];
                                              return Table(
                                                border: const TableBorder(
                                                  bottom: BorderSide(width:1 ,color: Colors.grey),
                                                  //   horizontalInside: BorderSide(width: 1,color: Colors.grey), // horizontal border inside the table
                                                  verticalInside: BorderSide(width: 1,color: Colors.grey),
                                                ),
                                                // border: TableBorder.all(color: const Color(0xFFB2C2D3)),
                                                columnWidths: const {
                                                  0: FlexColumnWidth(1),
                                                  1: FlexColumnWidth(2.7),
                                                  2: FlexColumnWidth(2),
                                                  3: FlexColumnWidth(1.8),
                                                  4: FlexColumnWidth(2),
                                                  5: FlexColumnWidth(1),
                                                  6: FlexColumnWidth(2),
                                                  7: FlexColumnWidth(1),
                                                  8: FlexColumnWidth(1),
                                                  9: FlexColumnWidth(1),
                                                  10: FlexColumnWidth(1),

                                                },
                                                children: [
                                                  TableRow(
                                                    children: [
                                                      TableCell(
                                                        child: Padding(
                                                          padding: const EdgeInsets.only( left: 10,
                                                              right: 10,
                                                              top: 15,
                                                              bottom: 5),
                                                          child: Center(child: Text('${index + 1}')),
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
                                                            child: Center(child: Text(item['productName'],textAlign: TextAlign.center,)),
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
                                                            child: Center(child: Text(item['category'],textAlign: TextAlign.center,)),
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
                                                            child: Center(child: Text(item['subCategory'])),
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
                                                            child: Center(child: Text(item['price'].toString())),
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
                                                            child: Center(child: Text(item['qty'].toString())),
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
                                                            child: Center(child: Text(calculateActualAmount(item).toString())),
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
                                                            child: Center(child: Text(item['discount'].toString())),
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
                                                            child: Center(child: Text(item['tax'].toString())),
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
                                                            child: Center(child: Text(
                                                              // '${item['totalAmount']}',
                                                              calculateTotalAmount(item).toString(),
                                                            )),
                                                          ),
                                                        ),
                                                      ),
                                                      TableCell(
                                                        child: Padding(
                                                          padding: const EdgeInsets.only(left: 10, right: 10, top: 17, bottom: 5),
                                                          child: InkWell(
                                                            onTap: () {
                                                              _deleteProduct(index);
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
                                          const SizedBox(height: 8.0),
                                          Padding(
                                            padding: const EdgeInsets.only(left: 30),
                                            child: ElevatedButton(
                                              onPressed: () {
                                                print('----data2 selectedprodct');
                                                print(widget.data);
                                                widget.data['total'];
                                                //  widget.data['contactPerson']= widget.data['contactPerson'] == ''? ContactPersonController.text : widget.data['contactPerson'];

                                                print('items');
                                                print(widget.data['items']);
                                                widget.data['items'].forEach((item) => item['totalAmount'] = item['actualAmount']);
                                                print(widget.data['items']);
                                                print(widget.data['total']);
                                                //  productList = widget.data['items'];
                                                //   print(productList);
                                                widget.data['contactPerson'] = _contactPersonController.text;
                                                widget.data['deliveryAddress'] = _deliveryaddressController.text;
                                                widget.data['contactNumber'] = _contactNumberController.text;
                                                widget.data['comments'] = _shippingAddress.text;
                                                widget.data['deliveryLocation'] = EmailIdController.text;
                                                widget.data['invoiceNo'] = InvoiceNumberController.text;
                                                //  widget.data['total'] = widget.data['total'].toString();

                                                List<Product> productList = (widget.data['items'] as List)
                                                    .map((item) => Product.fromJson(item))
                                                    .toList();

                                                data1 = widget.data;

                                                //  _calculateTotal();
                                                _total1 = widget.data['items'].fold(0, (sum, item) => sum + item['actualAmount']);

                                                print(data1['actualamount']);

                                                data1['actualamount'] = _total1;

                                                print(data1['actualamount']);

                                                print( widget.data['total']);

                                                widget.data['total'] = data1['actualamount'];

                                                print( widget.data['total']);

                                                print(data1['actualamount']);

                                                print('updated productlist');
                                                print(productList);

                                                context.go('/Add_Product_items',extra: {
                                                  'product': Product(prodId: '',price: 0,productName: '',proId: '',category: '',selectedVariation: '',selectedUOM: '',subCategory: '',totalamount: 0,total: 0,tax: '',quantity: 0,discount: '',imageId: '',unit: '', totalAmount: 0.0,qty: 0), // You need to pass a Product object here
                                                  'products': const [], // You need to pass a list of Product objects here
                                                  'data': data1,
                                                  'selectedProducts': productList,
                                                  'inputText': 'hello',
                                                  'subText': 'some_text',
                                                  'notselect': '',
                                                });
                                              },
                                              // icon: Icon(Icons.add,color: Colors.white,),
                                              child: const Text('+Add Products',style: TextStyle(color: Colors.white),),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.blue[800],
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(5.0),
                                                ),
                                              ),
                                            ),
                                          ),
                                          const Divider(color: Color(0xFFB2C2D3),),
                                          Padding(
                                            padding: const EdgeInsets.only(top:9,bottom: 9),
                                            child: Align(
                                              alignment: const Alignment(0.74,0.8),
                                              child: Container(
                                                height: 40,
                                                padding: const EdgeInsets.only(left: 15,right: 10,top: 2,bottom: 2),
                                                decoration: BoxDecoration(
                                                  border: Border.all(color: Colors.blue),
                                                  borderRadius: BorderRadius.circular(3),
                                                  color: Colors.white,
                                                ),
                                                child: Padding(
                                                  padding: const EdgeInsets.only(bottom: 15,top: 5,left: 10,right: 10),
                                                  child: Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      RichText(text:
                                                      TextSpan(
                                                        children: [
                                                          const TextSpan(
                                                            text:  'Total',
                                                            style: TextStyle(
                                                                fontSize: 14,
                                                                color: Colors.blue
                                                              // fontWeight: FontWeight.bold,
                                                            ),
                                                          ),
                                                          const TextSpan(
                                                            text: '  ₹',
                                                            style: TextStyle(
                                                              color: Colors.black,
                                                            ),
                                                          ),
                                                          TextSpan(
                                                            text: '${widget.data['total']}', // String interpolation
                                                            style: const TextStyle(
                                                              color: Colors.black,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],),
                            ))
                          }
    else...{
                            Expanded(child: AdaptiveScrollbar(

                              position: ScrollbarPosition.bottom,controller: horizontalScroll,
                              child: SingleChildScrollView(
                                controller: horizontalScroll,
                                scrollDirection: Axis.horizontal,
                                child: SingleChildScrollView(
                                  child: Column(children: [
                                    Padding(
                                      padding: const EdgeInsets.only(right: 100),
                                      child: Container(
                                        width: 1700,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            Padding(
                                              padding:  EdgeInsets.only(top: 50,right: 170),
                                              child: const Text(('Order Date')),
                                            ),
                                            Padding(
                                              padding:  const EdgeInsets.only(top: 10,right: 50),
                                              child: DecoratedBox(
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color: const Color(0xFFEBF3FF), width: 1),
                                                  borderRadius: BorderRadius.circular(10),

                                                ),
                                                child: Container(
                                                  height: 39,
                                                  width: 200,
                                                  decoration: BoxDecoration(
                                                    color: Colors.white
                                                        .withOpacity(1), // Opacity is 1, fully opaque
                                                    borderRadius: BorderRadius.circular(4),
                                                  ),
                                                  child: Column(
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
                                                            fillColor: Colors.grey.shade200,
                                                            contentPadding: const EdgeInsets.symmetric(
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
                                            ),
                                            //this is a new copy of now
                                            Padding(
                                              padding: const EdgeInsets.only(left: 80,right: 50,top: 40),
                                              child: Container(
                                                decoration: const BoxDecoration(
                                                  color: Color(0xFFFFFFFF), // background: #FFFFFF
                                                  boxShadow: [BoxShadow(
                                                    offset: Offset(0, 3),
                                                    blurRadius: 6,
                                                    color: Color(0x29000000), // box-shadow: 0px 3px 6px #00000029
                                                  )],
                                                  // border: Border.all(
                                                  //   // border: 2px
                                                  //   color: Color(0xFFB2C2D3), // border: #B2C2D3
                                                  // ),
                                                  borderRadius: BorderRadius.all(Radius.circular(4)), // border-radius: 8px
                                                ),
                                                child: Table(
                                                  border: TableBorder.all(color: const Color(0xFFB2C2D3),borderRadius: BorderRadius.circular(4)),

                                                  columnWidths: const {
                                                    0: FlexColumnWidth(2),
                                                    1: FlexColumnWidth(1.4),
                                                  },
                                                  children: [
                                                    row1,
                                                    row2,
                                                    row3,
                                                  ],
                                                ),
                                              ),
                                            ),
                                            buildDataTable(),
                                            Padding(
                                              padding: const EdgeInsets.only
                                                (top:100, left:80, right: 50,bottom: 25),
                                              child: SizedBox(
                                                width: 1700,
                                                child: Container(
                                                  width: 1700,
                                                  padding: const EdgeInsets.all(0.0),
                                                  decoration: BoxDecoration(
                                                    color: const Color(0xFFFFFFFF), // background: #FFFFFF
                                                    boxShadow: const [BoxShadow(
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
                                                      Padding(
                                                        padding: const EdgeInsets.only(left: 30, top: 10),
                                                        child: Text(
                                                          'Add Products',
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                            fontWeight: FontWeight.bold,
                                                            color: Colors.grey[600],
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(height: 8),
                                                      Container(
                                                        width: 1700,
                                                        decoration: const BoxDecoration(
                                                          border: Border(
                                                            top: BorderSide(color: Color(0xFFB2C2D3), width: 1.2),
                                                            bottom: BorderSide(color: Color(0xFFB2C2D3), width: 1.2),
                                                          ),
                                                        ),
                                                        child: Padding(
                                                          padding: const EdgeInsets.only(top: 5, bottom: 5),
                                                          child: Table(
                                                            columnWidths: const {
                                                              0: FlexColumnWidth(1),
                                                              1: FlexColumnWidth(2.7),
                                                              2: FlexColumnWidth(2),
                                                              3: FlexColumnWidth(1.8),
                                                              4: FlexColumnWidth(2),
                                                              5: FlexColumnWidth(1),
                                                              6: FlexColumnWidth(2),
                                                              7: FlexColumnWidth(1),
                                                              8: FlexColumnWidth(1),
                                                              9: FlexColumnWidth(1),
                                                              10: FlexColumnWidth(1),

                                                            },
                                                            children: const [
                                                              TableRow(
                                                                children: [
                                                                  TableCell(
                                                                    child: Padding(
                                                                      padding: EdgeInsets.only(top: 10, bottom: 10),
                                                                      child: Center(
                                                                        child: Text(
                                                                          'SN',
                                                                          style: TextStyle(fontWeight: FontWeight.bold),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  TableCell(
                                                                    child: Padding(
                                                                      padding: EdgeInsets.only(top: 10, bottom: 10),
                                                                      child: Center(
                                                                        child: Text(
                                                                          'Product Name',
                                                                          style: TextStyle(fontWeight: FontWeight.bold),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  TableCell(
                                                                    child: Padding(
                                                                      padding: EdgeInsets.only(top: 10, bottom: 10),
                                                                      child: Center(
                                                                        child: Text(
                                                                          'Category',
                                                                          style: TextStyle(fontWeight: FontWeight.bold),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  TableCell(
                                                                    child: Padding(
                                                                      padding: EdgeInsets.only(top: 10, bottom: 10),
                                                                      child: Center(
                                                                        child: Text(
                                                                          'Sub Category',
                                                                          style: TextStyle(fontWeight: FontWeight.bold),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  TableCell(
                                                                    child: Padding(
                                                                      padding: EdgeInsets.only(top: 10, bottom: 10),
                                                                      child: Center(
                                                                        child: Text(
                                                                          'Price',
                                                                          style: TextStyle(fontWeight: FontWeight.bold),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  TableCell(
                                                                    child: Padding(
                                                                      padding: EdgeInsets.only(top: 10, bottom: 10),
                                                                      child: Center(
                                                                        child: Text(
                                                                          'QTY',
                                                                          style: TextStyle(fontWeight: FontWeight.bold),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  TableCell(
                                                                    child: Padding(
                                                                      padding: EdgeInsets.only(top: 10, bottom: 10),
                                                                      child: Center(
                                                                        child: Text(
                                                                          'Amount',
                                                                          style: TextStyle(fontWeight: FontWeight.bold),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  TableCell(
                                                                    child: Padding(
                                                                      padding: EdgeInsets.only(top: 10, bottom: 10),
                                                                      child: Center(
                                                                        child: Text(
                                                                          'Disc.',
                                                                          style: TextStyle(fontWeight: FontWeight.bold),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  TableCell(
                                                                    child: Padding(
                                                                      padding: EdgeInsets.only(top: 10, bottom: 10),
                                                                      child: Center(
                                                                        child: Text(
                                                                          'TAX',
                                                                          style: TextStyle(fontWeight: FontWeight.bold),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  TableCell(
                                                                    child: Padding(
                                                                      padding: EdgeInsets.only(top: 10, bottom: 10),
                                                                      child: Center(
                                                                        child: Text(
                                                                          'Total Amount',
                                                                          style: TextStyle(fontWeight: FontWeight.bold),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  TableCell(
                                                                    child: Padding(
                                                                      padding: EdgeInsets.only(top: 10, bottom: 10),
                                                                      child: Center(
                                                                        child: Text(
                                                                          '    ',
                                                                          style: TextStyle(fontWeight: FontWeight.bold),
                                                                        ),
                                                                      ),
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
                                                        itemCount: widget.data['items']!= null? widget.data['items'].length : items!= null? items.length : 0,
                                                        itemBuilder: (context, index) {
                                                          Map<String, dynamic> item = widget.data['items']!= null? widget.data['items'][index] : items[index];
                                                          return Table(
                                                            border: const TableBorder(
                                                              bottom: BorderSide(width:1 ,color: Colors.grey),
                                                              //   horizontalInside: BorderSide(width: 1,color: Colors.grey), // horizontal border inside the table
                                                              verticalInside: BorderSide(width: 1,color: Colors.grey),
                                                            ),
                                                            // border: TableBorder.all(color: const Color(0xFFB2C2D3)),
                                                            columnWidths: const {
                                                              0: FlexColumnWidth(1),
                                                              1: FlexColumnWidth(2.7),
                                                              2: FlexColumnWidth(2),
                                                              3: FlexColumnWidth(1.8),
                                                              4: FlexColumnWidth(2),
                                                              5: FlexColumnWidth(1),
                                                              6: FlexColumnWidth(2),
                                                              7: FlexColumnWidth(1),
                                                              8: FlexColumnWidth(1),
                                                              9: FlexColumnWidth(1),
                                                              10: FlexColumnWidth(1),

                                                            },
                                                            children: [
                                                              TableRow(
                                                                children: [
                                                                  TableCell(
                                                                    child: Padding(
                                                                      padding: const EdgeInsets.only( left: 10,
                                                                          right: 10,
                                                                          top: 15,
                                                                          bottom: 5),
                                                                      child: Center(child: Text('${index + 1}')),
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
                                                                        child: Center(child: Text(item['productName'],textAlign: TextAlign.center,)),
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
                                                                        child: Center(child: Text(item['category'],textAlign: TextAlign.center,)),
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
                                                                        child: Center(child: Text(item['subCategory'])),
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
                                                                        child: Center(child: Text(item['price'].toString())),
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
                                                                        child: Center(child: Text(item['qty'].toString())),
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
                                                                        child: Center(child: Text(calculateActualAmount(item).toString())),
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
                                                                        child: Center(child: Text(item['discount'].toString())),
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
                                                                        child: Center(child: Text(item['tax'].toString())),
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
                                                                        child: Center(child: Text(
                                                                          // '${item['totalAmount']}',
                                                                          calculateTotalAmount(item).toString(),
                                                                        )),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  TableCell(
                                                                    child: Padding(
                                                                      padding: const EdgeInsets.only(left: 10, right: 10, top: 17, bottom: 5),
                                                                      child: InkWell(
                                                                        onTap: () {
                                                                          _deleteProduct(index);
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
                                                      const SizedBox(height: 8.0),
                                                      Padding(
                                                        padding: const EdgeInsets.only(left: 30),
                                                        child: ElevatedButton(
                                                          onPressed: () {
                                                            print('----data2 selectedprodct');
                                                            print(widget.data);
                                                            widget.data['total'];
                                                            //  widget.data['contactPerson']= widget.data['contactPerson'] == ''? ContactPersonController.text : widget.data['contactPerson'];

                                                            print('items');
                                                            print(widget.data['items']);
                                                            widget.data['items'].forEach((item) => item['totalAmount'] = item['actualAmount']);
                                                            print(widget.data['items']);
                                                            print(widget.data['total']);
                                                            //  productList = widget.data['items'];
                                                            //   print(productList);
                                                            widget.data['contactPerson'] = _contactPersonController.text;
                                                            widget.data['deliveryAddress'] = _deliveryaddressController.text;
                                                            widget.data['contactNumber'] = _contactNumberController.text;
                                                            widget.data['comments'] = _shippingAddress.text;
                                                            widget.data['deliveryLocation'] = EmailIdController.text;
                                                            widget.data['invoiceNo'] = InvoiceNumberController.text;
                                                            //  widget.data['total'] = widget.data['total'].toString();

                                                            List<Product> productList = (widget.data['items'] as List)
                                                                .map((item) => Product.fromJson(item))
                                                                .toList();

                                                            data1 = widget.data;

                                                            //  _calculateTotal();
                                                            _total1 = widget.data['items'].fold(0, (sum, item) => sum + item['actualAmount']);

                                                            print(data1['actualamount']);

                                                            data1['actualamount'] = _total1;

                                                            print(data1['actualamount']);

                                                            print( widget.data['total']);

                                                            widget.data['total'] = data1['actualamount'];

                                                            print( widget.data['total']);

                                                            print(data1['actualamount']);

                                                            print('updated productlist');
                                                            print(productList);

                                                            context.go('/Add_Product_items',extra: {
                                                              'product': Product(prodId: '',price: 0,productName: '',proId: '',category: '',selectedVariation: '',selectedUOM: '',subCategory: '',totalamount: 0,total: 0,tax: '',quantity: 0,discount: '',imageId: '',unit: '', totalAmount: 0.0,qty: 0), // You need to pass a Product object here
                                                              'products': const [], // You need to pass a list of Product objects here
                                                              'data': data1,
                                                              'selectedProducts': productList,
                                                              'inputText': 'hello',
                                                              'subText': 'some_text',
                                                              'notselect': '',
                                                            });
                                                          },
                                                          // icon: Icon(Icons.add,color: Colors.white,),
                                                          child: const Text('+Add Products',style: TextStyle(color: Colors.white),),
                                                          style: ElevatedButton.styleFrom(
                                                            backgroundColor: Colors.blue[800],
                                                            shape: RoundedRectangleBorder(
                                                              borderRadius: BorderRadius.circular(5.0),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      const Divider(color: Color(0xFFB2C2D3),),
                                                      Padding(
                                                        padding: const EdgeInsets.only(top:9,bottom: 9),
                                                        child: Align(
                                                          alignment: const Alignment(0.74,0.8),
                                                          child: Container(
                                                            height: 40,
                                                            padding: const EdgeInsets.only(left: 15,right: 10,top: 2,bottom: 2),
                                                            decoration: BoxDecoration(
                                                              border: Border.all(color: Colors.blue),
                                                              borderRadius: BorderRadius.circular(3),
                                                              color: Colors.white,
                                                            ),
                                                            child: Padding(
                                                              padding: const EdgeInsets.only(bottom: 15,top: 5,left: 10,right: 10),
                                                              child: Row(
                                                                mainAxisSize: MainAxisSize.min,
                                                                children: [
                                                                  RichText(text:
                                                                  TextSpan(
                                                                    children: [
                                                                      const TextSpan(
                                                                        text:  'Total',
                                                                        style: TextStyle(
                                                                            fontSize: 14,
                                                                            color: Colors.blue
                                                                          // fontWeight: FontWeight.bold,
                                                                        ),
                                                                      ),
                                                                      const TextSpan(
                                                                        text: '  ₹',
                                                                        style: TextStyle(
                                                                          color: Colors.black,
                                                                        ),
                                                                      ),
                                                                      TextSpan(
                                                                        text: '${widget.data['total']}', // String interpolation
                                                                        style: const TextStyle(
                                                                          color: Colors.black,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  )
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),

                                  ],),
                                ),
                              ),
                            ))
                          }


                          //date


                        ],
                      ),
                    )
                  ],
                );
              }
          )
      ),
    );
  }
}


double calculateActualAmount(Map<String, dynamic> item) {
  double price = item['price']; // 1800

  // Calculate total amount
  double priceRound = double.parse(price.toStringAsFixed(2)); // 1800.00

  double totalAmountCalculated = (priceRound); // 2088.00
  int qty = item['qty'] ?? 0; // default to 0 if qty is null
  double totalAmountRound = totalAmountCalculated * qty;

  return double.parse(totalAmountRound.toStringAsFixed(2));
}

double calculateTotalAmount(Map<String, dynamic> item) {
  double actualAmount = item['actualAmount'];
  double totalAmount = item['totalAmount'];

  // if(actualAmount == totalAmount){
  double price = item['price']; // 8000
  String discountStr = item['discount']; // "4%"
  String taxStr = item['tax']; // "18%"

  // Remove '%' and convert to numeric values
  double discountConv = double.parse(discountStr.replaceAll('%', '')) / 100; // 0.04
  double taxConv = double.parse(taxStr.replaceAll('%', '')) / 100; // 0.18

  // Calculate discount amount
  double discountAmount = price * discountConv; // 8000 * 0.04 = 320

  // Price after discount
  double priceAfterDiscount = price - discountAmount; // 8000 - 320 = 7680

  // Calculate tax amount on the price after discount
  double taxAmount = priceAfterDiscount * taxConv; // 7680 * 0.18 = 1382.4

  // Calculate total amount
  double totalAmountCalculated = priceAfterDiscount + taxAmount; // 7680 + 1382.4 = 9062.4

  // Multiply by quantity (if applicable)
  double totalAmountRound = totalAmountCalculated * item['qty']; // Assuming qty is 1

  return double.parse(totalAmountRound.toStringAsFixed(2)); // Returns 9062.4
  // }else{
  //   return totalAmount;
  // }

}


