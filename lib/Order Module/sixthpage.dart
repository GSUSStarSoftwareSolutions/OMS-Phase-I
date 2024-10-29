import 'dart:async';
import 'dart:html';
import 'package:btb/admin/Api%20name.dart';
import 'package:btb/widgets/confirmdialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import '../dashboard/dashboard.dart';
import 'firstpage.dart';

void main(){
  runApp(SixthPage(product: null));
}


class SixthPage extends StatefulWidget {
  final detail? product;
  final String? arrow;
  final Dashboard1? product1;
  final String? status;
  final String? InvNo;
  final List<dynamic>? orderDetails;
  final Map<String, dynamic>? paymentStatus;
  final List<Map<String, dynamic>>? item;
  final Map<String, dynamic>? body;
  final List<Map<String, dynamic>>? itemsList;
  const SixthPage({super.key, this.product1,this.arrow,required this.product, this.item, this.body,this.status, this.paymentStatus,this.itemsList,this.orderDetails,this.InvNo});

  @override
  _SixthPageState createState() => _SixthPageState();
}

class _SixthPageState extends State<SixthPage> with SingleTickerProviderStateMixin{
  final _formKey = GlobalKey<FormState>();
  DateTime? _selectedDate;
  Map<String, dynamic> _selectedProductMap = {};
  String token = window.sessionStorage["token"] ?? " ";
  final _orderIdController = TextEditingController();
  final List<String> list = ['  Name 1', '  Name 2', '  Name3'];
  Map<String, dynamic> data2 = {};
  List<Map> _orders = [];

  String _searchText = '';
  bool _isFirstLoad = true;
  bool _loading = false;
  bool isEditing = false;
  final TextEditingController deliveryLocationController = TextEditingController();
  final TextEditingController InvNoController = TextEditingController();
  List<Map<String, dynamic>> selectedItems = [];
  //List<dynamic> selectedItems = [];
  final TextEditingController deliveryStatusController = TextEditingController();
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
  bool? _isChecked1 = true;
  bool _isLoading = false;
  bool _hasError = false;
  detail _selectedOrder = detail(orderId: '',
      total: 0,
      deliveryStatus: '',
      status: '',
      orderDate: '',
      referenceNumber: '',
      items: []);
  bool? _isChecked2 = false;
  int _selectedIndex = -1;
  //List<Map<String, dynamic>> _orders = [];
  List<bool> _isSelected = [];
  List<OrderDetails> _searchResults = [];
  bool _firstTimeSort = true;
  // List<bool> _isSelected = [];
  List<bool> _isBlinked = [];
  List<Map<String, dynamic>> _sortedOrders = [];
  // String _selectedIndex = '';
  late TextEditingController _dateController;
  bool? _isChecked3 = false;
  bool? _isChecked4 = false;
  final TextEditingController CusIdController = TextEditingController();
  Timer? _timer;
  final TextEditingController totalAmountController = TextEditingController();
  final TextEditingController paymentStatusContoller = TextEditingController();
  bool isOrdersSelected = false;
  String _errorMessage = '';
  Map<String, dynamic> PaymentMap1 = {};
  //String sam = 'ORD_02112';
  bool _isFirstMove = true;
  late Animation<Offset> _offsetAnimation;
  late AnimationController _controller;

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
      _buildMenuItem('Home', Icons.dashboard, Colors.blue[900]!, '/Home'),
      _buildMenuItem('Customer', Icons.account_circle, Colors.blue[900]!, '/Customer'),
      _buildMenuItem('Products', Icons.image_outlined, Colors.blue[900]!, '/Product_List'),
      _buildMenuItem('Orders', Icons.warehouse, Colors.blueAccent, '/Order_List'),
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


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isFirstLoad) {
      print('didichange');
      _isFirstLoad = false;
      for (int i = 0; i < widget.orderDetails!.length; i++) {
        if (orderIdController.text == widget.orderDetails![i].orderId) {
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
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Define the slide transition animation
    _offsetAnimation = Tween<Offset>(
      begin: Offset(0.0, -1.0), // Start above the screen
      end: Offset(0.0,-0.4), // End in the center
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.bounceIn,
    ));


    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showCustomDialog();
    });
    print(widget.arrow);
    print('from firstpage');
    print(widget.orderDetails);
    print(widget.product);
    print('ho');
    print(widget.InvNo);
    InvNoController.text = widget.InvNo ?? '';
    print(InvNoController.text);
    print('hi');
    print(widget.paymentStatus!['paymentStatus']);
    // print(widget.status);
    // print(widget.paymentStatus);
    paymentStatusContoller.text = widget.paymentStatus!['paymentStatus'] ?? '';

    // widget.status =deliveryStatusController.text;
    deliveryStatusController.text = widget.status! ?? '';
    PaymentMap1 = widget.paymentStatus ?? {};

    //  print(widget.orderDetails!['Delivery Status'as int] );


    _isLoading =true;
    _timer = Timer(Duration(seconds: 1), () {
      setState(() {
        _isLoading = false;
      });
    });

    //orderIdController.text = _isSelected as String;
    // _isSelected = List<bool>.filled(widget.orderDetails!.length, false);
//original
    _isSelected = List<bool>.filled(widget.orderDetails?.length ?? 0, false);
    //
    //_isSelected = List<bool>.filled(widget.orderDetails!.length ?? 0, false);


    _orderIdController.addListener(() {
      _fetchOrders();
    });
    print('--ordermodule data sixthpage');

    orderIdController.text = widget.product!.orderId ?? '';

// Assuming widget.product!.items is a list of items
    List<dynamic> items = widget.product!.items;

// Iterate over the items list


    if (widget.product != null) {
      //data2['deliveryLocation'] = widget.product.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          orderIdController.text = widget.product!.orderId ?? '';
          print('orderIdController.text');
          print(orderIdController.text);
          print(widget.product!.orderDate);
          CreatedDateController.text = widget.product!.orderDate;
          totalController.text = widget.product!.total.toString();
          deliveryAddressController.text = widget.product!.deliveryAddress!;
          contactPersonController.text = widget.product!.contactPerson!;
          contactNumberController.text = widget.product!.contactNumber!;
          commentsController.text = widget.product!.comments!;
          // deliveryLocationController.text = widget.product!.deliveryLocation!;
          deliveryLocationController.text = widget.product!.deliveryLocation!;
          CusIdController.text = widget.product!.CusId!;
          // widget.product!.items = widget.body[it];

          displayItemDetails();
        });
      });
      _selectedOrder = widget.product!;
      print('-----orderId');
      //List<bool> orderId = (_selectedOrder.orderId ?? '') as List<bool>;

      //print(orderId);


      //List<bool> _isSelected = List<bool>.filled(orderId.length, false);
      // print(_isSelected);
      print('selectinde');
      print(_selectedIndex);

      print(_isSelected);
    } else {
      print('Product is null');
    }


    if (widget.body != null) {
      print('Body: ${widget.body}');
      print('Items List: ${widget.itemsList}');
      print('Order Date: ${widget.body?['orderDate']}');
      print('Delivery Location: ${widget.body?['deliveryLocation']}');
      print('Delivery Address: ${widget.body?['deliveryAddress']}');
      print('Contact Person: ${widget.body?['contactPerson']}');
      print('Contact Number: ${widget.body?['contactNumber']}');
      print('Comments: ${widget.body?['comments']}');
      print('Total: ${widget.body?['total']}');
      print('id: ${widget.body?['id']}');

      for (var item in items) {
        if (item['orderId'] == orderIdController.text) {
          print('Order Master Id: ${item['orderMasterItemId']}');
        }
      }

      if (widget.body?['items'] != null) {
        for (var item in widget.body?['items']) {

          print('  Product Name: ${item['productName']}');
          print(' OrderMasterId: ${item['orderMasterItemId']}');
          print('  Category: ${item['category']}');
          print('  Sub Category: ${item['subCategory']}');
          print('  Price: ${item['price'].toString()}');
          print('  Qty: ${item['qty'].toString()}');
          print('  discount: ${item['discount'].toString()}');
          print('  tax: ${item['tax'].toString()}');
          print('  actualAmount: ${item['actualAmount'].toString()}');
          print('  Total Amount: ${item['totalAmount'].toString()}');
          print(''); // empty line for separation
          selectedItems = List.from(widget.body?['items']);
        }
      } else {
        print('No items');
      }

      if (widget.body != null) {
        print('hi');
        deliveryAddressController.text = widget.body?['deliveryAddress'] ?? '';
        deliveryLocationController.text = widget.body?['deliveryLocation'] ?? '';
        CusIdController.text = widget.body?['customerId'] ??'';
        print(CusIdController.text);
      // deliveryLocationController.text = widget.body?['deliveryLocation'] ?? '';
        contactPersonController.text = widget.body?['contactPerson'] ?? '';
        contactNumberController.text = widget.body?['contactNumber'] ?? '';
        commentsController.text = widget.body?['comments'] ?? '';
        CreatedDateController.text = widget.body?['orderDate'] ?? '';
        totalController.text = widget.body?['total'] ?? '';

        widget.body?['orderId'];
      }
    } else {
      print('Body is null');
    }

    if (widget.product != null) {
      _selectedOrder = widget.product!;
    } else {
      print('Error: Product is null');
    }

    if (widget.itemsList != null) {
      // access widget.itemsList here
    } else {
      print('ItemsList is null');
    }
    _dateController = TextEditingController();

    _selectedDate = DateTime.now();
    _dateController.text = DateFormat.yMd().format(_selectedDate!);
    fetchProducts();
  }



  void _showCustomDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent the dialog from being dismissed manually
      builder: (BuildContext context) {
        _controller.forward(); // Start the slide-in animation

        // Close the dialog after 2 seconds with slide-out animation
        Future.delayed(Duration(seconds: 2), () {
          _controller.reverse(); // Start the slide-out animation
          Future.delayed(Duration(milliseconds: 500), () {
            Navigator.of(context).pop(); // Close the dialog after animation
          });
        });

        return SlideTransition(
          position: _offsetAnimation,
          child: AlertDialog(
            elevation: 3,
            shape: RoundedRectangleBorder(
              side: BorderSide(color: Colors.blue, width: 1), // Set border color and width
              borderRadius: BorderRadius.all(Radius.circular(4)),
            ),
            backgroundColor: Colors.white,
            content: Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Your order ID is: ',
                      style: TextStyle(fontSize: 14, color: Colors.black),
                    ),
                  ),
                  Expanded(
                    child: SelectableText(
                      '${orderIdController.text}',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    //   _orderIdController.removeListener(_fetchOrders);
    _dateController.dispose();

    super.dispose();
  }
//this is the original
  Future<void> _fetchOrders() async {
    setState(() {
      _loading = true;
      _orders = []; // clear the orders list
      _errorMessage = ''; // clear the error message
    });
    try {
      final orderId = orderIdController.text
          .trim(); // trim to remove whitespace
      final url = orderId.isEmpty
          ? '$apicall/order_master/get_all_ordermaster'
          : '$apicall/order_master/search_by_orderid/$orderId';
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token', // Replace with your API key
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final responseBody = response.body;
        print('-res--');
        print(responseBody);
        if (responseBody != null) {
          final jsonData = jsonDecode(responseBody).cast<
              Map<dynamic, dynamic>>();
          setState(() {
            _orders =
                jsonData; // update _orders with all orders or search results
            _errorMessage = ''; // clear the error message
          });
        } else {
          setState(() {
            _orders = []; // clear the orders list
            _errorMessage = 'Failed to load orders';
          });
        }
      } else {
        setState(() {
          _orders = []; // clear the orders list
          _errorMessage = 'Failed to load orders';
        });
      }
    } catch (e) {
      setState(() {
        _orders = []; // clear the orders list
        _errorMessage = 'Error: $e';
      });
    } finally {
      // setState(() {
      //   _loading = true;
      // });
    }
  }

  Future<void> _fetchOrderDetails(String orderId) async {

    try {
      final url = '$apicall/order_master/search_by_orderid/$orderId';
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token', // Replace with your API key
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final responseBody = response.body;
        print('search');
        print(responseBody);
        // print(responseBody['status' as int]);
        final jsonData = jsonDecode(responseBody);
        if (jsonData is List<dynamic>) {
          final jsonObject = jsonData.first;


          print(jsonObject);
          final orderDetails = OrderDetail.fromJson(jsonObject);
          print('orderDetails');
          //  print(orderDetails);
          _showProductDetails(orderDetails);
        } else {
          print('Failed to load order details');
        }
      } else {
        print('Failed to load order details');
      }
    } catch (e) {
      // print('Error: $e');
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }finally {
      // Timer(Duration(seconds: 10), () {
      //   setState(() {
      //     _isLoading = false;
      //   });
      // });
      //}
      setState(() {
        _isLoading = true;
      });
    }
  }


  List<detail> filteredData = [];

  Future<void> fetchProducts() async {
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
        filteredData = (jsonData as List).map((item) => detail.fromJson(item)).toList();

        print('api response');
        print(filteredData);
        if (mounted) {
          setState(() {});
        }
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Error decoding JSON: $e');
    }
  }

//  Future<void> _fetchOrderDetails(String orderId) async {
//   setState(() {
//    _isLoading = true;
//    _hasError = false;
//  });
//
// try {
//     final url = '$apicall/order_master/search_by_orderid/$orderId';
//     final response = await http.get(
//          Uri.parse(url),
//        headers: {
//          'Authorization': 'Bearer $token', // Replace with your API key
//          'Content-Type': 'application/json',
//        },
//      );
//
//      if (response.statusCode == 200) {
//        final responseBody = response.body;
//        final jsonData = jsonDecode(responseBody);
//        if (jsonData is List<dynamic>) {
//          final jsonObject = jsonData.first;
//          final orderDetails = OrderDetail.fromJson(jsonObject);
//          _showProductDetails(orderDetails);
//        } else {
//          print('Failed to load order details');
//          setState(() {
//            _hasError = true;
//          });
//        }
//      } else {
//        print('Failed to load order details');
//        setState(() {
//          _hasError = true;
//        });
//      }
//    } catch (e) {
//      print('Error: $e');
//      setState(() {
//        _hasError = true;
//      });
//    } finally {
//      setState(() {
//        _isLoading = false;
//      });
//    }
//  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    TableRow row1 = TableRow(
      children: [
        const TableCell(
          child: Padding(
            padding: EdgeInsets.only(left: 30,top: 10,bottom: 10),
            child: Text('Delivery Details'),
          ),
        ),

        TableCell(
          child: Row(
            children: [
              const Spacer(),
              const Text(
                'Order Date',
                style: TextStyle(
                  //    fontSize: 16,// fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 5),
              DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFEBF3FF), width: 1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Container(
                  height: 35,
                  width: screenWidth* 0.1,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: TextFormField(
                    enabled: isEditing,
                    controller: CreatedDateController,
                    readOnly: true,
                    decoration: InputDecoration(
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.calendar_month),
                        iconSize: 20,
                        onPressed: () {
                          _showDatePicker(context);
                        },
                      ),
                      hintText: _selectedDate != null
                          ? DateFormat('yyyy-MM-dd').format(_selectedDate!)
                          : 'Select Date',
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      border: InputBorder.none,
                      filled: true,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );

    TableRow row2 = const TableRow(
      children: [
        TableCell(
          child: Padding(
            padding: EdgeInsets.only(left: 30,top: 10,bottom: 10),
            child: Text('Billing Address'),
          ),
        ),
        TableCell(
          child: Padding(
            padding: EdgeInsets.only(left: 10,top: 10,bottom: 10),
            child: Text('Shipping Address'),
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
                      child: Text('Contact Person'),
                    ),
                    const SizedBox(height: 10,),
                    Padding(
                      padding:  const EdgeInsets.only(left: 30),
                      child: SizedBox(
                          width: screenWidth * 0.35,
                          height: 40,
                          child:
                          TextFormField(
                            enabled: isEditing,
                            controller: contactPersonController,
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 8),
                              filled: true,
                              fillColor:Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5.0),
                                borderSide: BorderSide(color: Color(0xFFECEFF1)),
                              ),
                              hintText: 'Contact Person Name',


                            ),
                          )
                          // DropdownButtonFormField<String>(
                          //   value: data2['deliveryLocation'] != null &&
                          //       list.contains(data2['deliveryLocation'])
                          //       ? data2['deliveryLocation']
                          //       : null,
                          //   decoration: InputDecoration(
                          //     filled: true,
                          //     fillColor: Colors.white,
                          //     border: OutlineInputBorder(
                          //       borderRadius: BorderRadius.circular(5.0),
                          //       borderSide: BorderSide(color: Color(0xFFECEFF1)),
                          //     ),
                          //     hintText: 'Select Location',
                          //     contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          //   ),
                          //   onChanged: isEditing ? (String? value) {
                          //     setState(() {
                          //       data2['deliveryLocation'] = value!;
                          //     });
                          //   } : null, // Disable onChanged if not in editing mode
                          //   items: list.map<DropdownMenuItem<String>>((String value) {
                          //     return DropdownMenuItem<String>(
                          //       enabled: isEditing, // Disable items if not in editing mode
                          //       value: value,
                          //       child: Text(value),
                          //     );
                          //   }).toList(),
                          //   isExpanded: true,
                          //   iconDisabledColor: Colors.grey,
                          //   isDense: true,
                          //   selectedItemBuilder: (BuildContext context) {
                          //     return list.map((String value) {
                          //       return Text(
                          //         data2['deliveryLocation'] != null &&
                          //             list.contains(data2['deliveryLocation'])
                          //             ? data2['deliveryLocation']
                          //             : 'Select Location',
                          //         style: TextStyle(color: Colors.grey),
                          //       );
                          //     }).toList();
                          //   },
                          // )


                      ),
                    ),
                    const SizedBox(height: 20),
                    const Padding(
                      padding:  EdgeInsets  .only(left: 30),
                      child: Text('Delivery Address'),
                    ),
                    const SizedBox(height: 10,),
                    Padding(
                      padding:  const EdgeInsets.only(left: 30),
                      child: SizedBox(
                        width: screenWidth * 0.35,
                        child:
                        TextFormField(
                          enabled: isEditing,
                          controller: deliveryAddressController,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor:Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0),
                              borderSide: BorderSide(color: Color(0xFFECEFF1)),
                            ),
                            hintText: 'Enter Your Address',
                          ),
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
                      child: Text('Contact Number'),
                    ),
                    const SizedBox(height: 10,),
                    Padding(
                      padding: const EdgeInsets.only(right: 20),
                      child: SizedBox(
                        width: screenWidth * 0.2,
                        height: 40,
                        child: TextFormField(
                          enabled: isEditing,
                          controller: contactNumberController,

                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0),
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                            hintText: 'Enter Email Id',
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 8),
                          ),
                          keyboardType:
                          TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter
                                .digitsOnly,
                            LengthLimitingTextInputFormatter(
                                10),
                            // limits to 10 digits
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text('Email Id'),
                    const SizedBox(height: 10,),
                    Padding(
                      padding: const EdgeInsets.only(right: 20),
                      child: SizedBox(
                        width: screenWidth * 0.2,
                        height: 40,
                        child: TextField(
                          enabled: isEditing,
                          controller: deliveryLocationController,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0),
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                            hintText: 'Enter Email Id',
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 8),
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
                      padding: const EdgeInsets.only(right: 10,left: 10,bottom: 5),
                      child: SizedBox(
                        height: 250,
                        child: TextField(
                          enabled: isEditing,
                          controller: commentsController,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0),
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                            // hintText: 'Enter Your Comments'


                          ),
                          maxLines: 5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
    return Scaffold(
        backgroundColor: const Color(0xFFF0F4F8),
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: null,
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
            builder: (context, constraints){
              double maxHeight = constraints.maxHeight;
              double maxWidth = constraints.maxWidth;


              return  Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: Container(
                      width: 200,
                      height: 984,
                      color: const Color(0xFFF7F6FA),
                      padding: const EdgeInsets.only(left: 20, top: 30),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: _buildMenuItems(context),
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 1), // Space above/below the border
                    height: 984,
                    // width: 1500,
                    width:0.5,// Border height
                    color: Colors.black, // Border color
                  ),
                  Container(
                    margin: const EdgeInsets.only(
                      // top: 51,
                      left:1,
                    ),
                    width: 298,
                    height: 933,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFFFF),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 5),
                                child: IconButton(
                                  icon:
                                  const Icon(Icons.arrow_back), // Back button icon
                                  onPressed: () {
                                    //  order_complete
                                    // widget.arrow == 'open_order' ? context.go('/Open_Order') :
                                    context.go(widget.arrow == 'open_order' ? '/Open_Order' : widget.arrow == 'Home' ? '/Home' : '/Order_List');
                                    //  context.go(widget.arrow == 'open_order' ?'/Open_Order' :  '/Order_List');
                                    // Navigator.push(
                                    //   context,
                                    //   MaterialPageRoute(
                                    //       builder: (context) =>
                                    //       const Orderspage()),
                                    // );
                                  },
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(left: 15,top: 10),
                                child: Text(
                                  'Order List',
                                  style: TextStyle(
                                    fontSize: 19,
                                    //  fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                          // Divider(),
                          Padding(
                            padding: const EdgeInsets.only(top: 0, left: 0),
                            child: Container(
                              margin: const EdgeInsets.symmetric(
                                  vertical: 5), // Space above/below the border
                              height: 0.5,
                              // width: 1500,
                              width: constraints.maxWidth,// Border height
                              color: Colors.black, // Border color
                            ),
                          ),
                          SizedBox(
                            height: 50,
                            width: 60,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  left: 15, right: 15, bottom: 5,top: 5),
                              child: TextFormField(
                                //controller: _orderIdController,
                                // Assign the controller to the TextFormField
                                decoration: const InputDecoration(
                                  // labelText: 'Order ID',
                                  hintText: 'Search Order',
                                  hintStyle: TextStyle(color: Colors.grey),
                                  contentPadding: EdgeInsets.all(8),
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.search_outlined),
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    _searchText = value.toLowerCase();
                                  });
                                },
                              ),
                            ),
                          ),
                          Expanded(child: SingleChildScrollView(child: Column(
                            children: [
                              _loading
                                  ? const Center(child: CircularProgressIndicator(strokeWidth: 4))
                                  : _errorMessage.isNotEmpty
                                  ? Center(child: Text(_errorMessage))
                                  : widget.orderDetails!.isEmpty
                                  ? const Center(child: Text('No product found'))
                                  : SingleChildScrollView(
                                child: ListView.separated(
                                  shrinkWrap: true,
                                  itemCount: _searchText.isNotEmpty
                                      ? widget.orderDetails!.where((orderDetail) =>
                                  orderDetail.orderId.toLowerCase().contains(_searchText.toLowerCase()) ||
                                      orderDetail.orderDate.toLowerCase().contains(_searchText.toLowerCase())
                                  ).length
                                      : widget.orderDetails!.length,
                                  itemBuilder: (context, index) {
                                    final isSelected = _isSelected[index];
                                    final orderDetail = _searchText.isNotEmpty
                                        ? widget.orderDetails!.where((orderDetail) =>
                                    orderDetail.orderId.toLowerCase().contains(_searchText.toLowerCase()) ||
                                        orderDetail.orderDate.toLowerCase().contains(_searchText.toLowerCase())
                                    ).elementAt(index)
                                        : widget.orderDetails![index];

                                    return GestureDetector(
                                      onTap: () async {
                                        _timer = Timer(Duration(seconds: 1), () {
                                          setState(() {
                                            _isLoading = false;
                                          });
                                        });

                                        setState(() {
                                          _isLoading = false;
                                          for (int i = 0; i < _isSelected.length; i++) {
                                            _isSelected[i] = i == index;
                                          }
                                          print('sixthpage deliverystatus');
                                          //  print();
                                          orderIdController.text = orderDetail.orderId;
                                        });
                                        await _fetchOrderDetails(orderDetail.orderId);
                                        //in this place write api to fetch datas?? _showProductDetails(orderDetail);
                                      },
                                      child: AnimatedContainer(
                                        duration: const Duration(milliseconds: 200),
                                        decoration: BoxDecoration(
                                          color: isSelected ? Colors.lightBlue[100] : Colors.white,
                                        ),
                                        child: ListTile(
                                          title: Text('Order ID: ${orderDetail.orderId}'),
                                          subtitle: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text('Order Date: ${orderDetail.orderDate}'),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                  separatorBuilder: (context, index) {
                                    return const Divider();
                                  },
                                ),
                              )
                            ],
                          ),)),
                          const SizedBox(height: 1),


                        ],

                      ),
                    ),

                  ),
                  Container(
                    width: 0.8, // Set the width to 1 for a vertical line
                    height: 984, // Set the height to your liking
                    decoration: BoxDecoration(
                      border: Border(left: BorderSide(width: 1, color: Colors.black54)),
                    ),
                  ),
                  Expanded(
                      child:
                      SingleChildScrollView(
                        child: Stack(
                          // mainAxisAlignment: MainAxisAlignment.start,
                          // crossAxisAlignment: CrossAxisAlignment.start,
                          // mainAxisSize: MainAxisSize.max,
                          children: [
                            Positioned(
                              top: 0,
                              left: 0,
                              right: 0,
                              child: Container(
                                // padding: const EdgeInsets.only(),
                                color: Colors.white,
                                height: 50,
                                child: Row(
                                  children: [
                                    const Padding(
                                      padding: EdgeInsets.only(left: 20),
                                      child: Text('Order ID :',style: TextStyle(fontSize: 19),),
                                    ),
                                    const SizedBox(width:8),
                                    SelectableText((orderIdController.text),style: const TextStyle(fontSize: 19),),
                                    //  Text(orderIdController.text),
                                    const SizedBox(width: 10,),
                                    const Spacer(),
                                    deliveryStatusController.text == 'Delivered' ||deliveryStatusController.text == 'In Progress' ? Container():
                                    Padding(
                                      padding: const EdgeInsets.only(right: 30),
                                      child: OutlinedButton(
                                        onPressed: () {
                                          print(deliveryStatusController.text);
                                          if(deliveryStatusController.text == 'Delivered' ||deliveryStatusController.text == 'In Progress' ){
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(content: Text('You Should Not Able To Edit')),
                                            );
                                          }
                                          else
                                          {
                                            print(InvNoController.text);
                                            Map<String, dynamic> data = {
                                              'deliveryLocation': deliveryLocationController.text,
                                              'CusId': CusIdController.text,
                                              'orderDate': CreatedDateController.text,
                                              'orderId': orderIdController.text,
                                              'invoiceNo': InvNoController.text,
                                              'contactPerson': contactPersonController.text,
                                              'deliveryAddress': deliveryAddressController.text,
                                              'contactNumber': contactNumberController.text,
                                              'comments': commentsController.text,
                                              'total': totalController.text,
                                              'items': selectedItems.map((item) =>
                                              {
                                                'productName': item['productName'],
                                                'orderMasterItemId': item['orderMasterItemId'],
                                                'category': item['category'],
                                                'subCategory': item['subCategory'],
                                                'price': item['price'],
                                                'qty': item['qty'],
                                                'discount': item['discount'],
                                                'tax': item['tax'],
                                                'actualAmount': item['actualAmount'],
                                                'totalAmount': item['totalAmount'],
                                              }).toList(),
                                            };
                                            print('sixthpage from');
                                            print(data);
                                            context.go('/Edit_Order', extra: data);
                                            Map<String, dynamic> orderDetailsMap = widget.orderDetails!.map((e) => e.toJson()).toList().asMap().cast<String, String>();
                                          }
                                        },

                                        style: OutlinedButton.styleFrom(
                                          backgroundColor:
                                          Colors.white, // Button background color
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                            BorderRadius.circular(5),
                                            // Rounded corners
                                          ),
                                          // side: BorderSide.none,
                                          // No outline
                                        ),
                                        child: const Text(
                                          'Edit',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(right: 50),
                                      child: OutlinedButton(
                                        onPressed: () {
                                          String orderIdValue = orderIdController.text;
                                          //    orderIdController.text = detailInstance.orderId;
                                          // orderIdValue = detailInstance.orderId;
                                          print('location');
                                          print(data2['deliveryLocation']);
                                          print(CreatedDateController.text);
                                          print(filteredData);
                                          _selectedProductMap = {
                                            'name': contactPersonController.text,
                                          };
                                          context.go('/Documents',extra: {
                                            //'string': 'hi',
                                            'selectedProductMap': _selectedProductMap,
                                            'deliveryStatus': deliveryStatusController.text,
                                            'paymentStatus':PaymentMap1,
                                            'InvNo':InvNoController.text,
                                            'Total':totalController.text,
                                            'Location':data2['deliveryLocation'],
                                            'Date': CreatedDateController.text,
                                            'contactNo':contactNumberController.text,
                                            'orderId': orderIdController.text,
                                            'orderDetails': filteredData.map((detailInstance) => OrderDetail(
                                              orderId: detailInstance.orderId,
                                              orderDate: detailInstance.orderDate, items: [],
                                              // Add other fields as needed
                                            )).toList(),
                                          });
                                          // Navigator.push(
                                          //   context,
                                          //   MaterialPageRoute(
                                          //       builder: (context) =>
                                          //       const EighthPage()),
                                          // );
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
                                          'Documents',
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
                            ),

                            Padding(
                              padding: const EdgeInsets.only(top: 40, left: 0),
                              child: Container(
                                margin: const EdgeInsets.symmetric(
                                    vertical: 10), // Space above/below the border
                                height: 0.5,
                                // width: 1500,
                                width: constraints.maxWidth,// Border height
                                color: Colors.black, // Border color
                              ),
                            ),

                            Padding(
                              padding: const EdgeInsets.only(left: 50, top: 100,right: 50),
                              child: Container(
                                height: 100,
                                width: maxWidth,
                                decoration: BoxDecoration(
                                  color: Color(0xFFFFFFFF), // background: #FFFFFF
                                  boxShadow: [BoxShadow(
                                    offset: Offset(0, 3),
                                    blurRadius: 6,
                                    color: Color(0x29000000), // box-shadow: 0px 3px 6px #00000029
                                  )],
                                  border: Border.all(
                                    // border: 2px
                                    color: Color(0xFFB2C2D3), // border: #B2C2D3
                                  ),
                                  borderRadius: BorderRadius.all(Radius.circular(8)), // border-radius: 8px
                                ),
                                child:  Padding(
                                  padding: EdgeInsets.only(top: 30),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Expanded(
                                        flex: 1,
                                        child: Column(
                                          children: [
                                            Icon(
                                              Icons.check_box,
                                              color: Colors.green,
                                            ),
                                            Text(
                                              'Order Placed',
                                              style: TextStyle(
                                                color: Colors.black,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: Column(
                                          children: [
                                            Icon(
                                              Icons.check_box,
                                              color: deliveryStatusController.text == 'Not Started'
                                                  ? Colors.grey
                                                  :  deliveryStatusController.text == 'Delivered'
                                                  ? Colors.green
                                                  : Colors.grey, // default color
                                            ),
                                            Text(
                                              'Invoice',
                                              style:TextStyle(
                                                color: deliveryStatusController.text == 'Not Started'
                                                    ? Colors.grey
                                                    : deliveryStatusController.text == 'In Progress'
                                                    ? Colors.grey
                                                    : Colors.black,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: Column(
                                          children: [
                                            Icon(
                                              Icons.check_box,
                                              color: deliveryStatusController.text == 'Not Started'
                                                  ? Colors.grey
                                                  :  deliveryStatusController.text == 'Delivered'
                                                  ? Colors.green
                                                  : Colors.grey, // default color
                                            ),
                                            Text(
                                              deliveryStatusController.text == 'In Progress' ? '    Delivery\n(In Progress)' : 'Delivered',
                                              style: TextStyle(
                                                color: deliveryStatusController.text == 'Not Started'
                                                    ? Colors.grey
                                                    : deliveryStatusController.text == 'In Progress'
                                                    ? Colors.grey
                                                    : Colors.black,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: Column(
                                          children: [
                                            Icon(
                                              Icons.check_box,
                                              color:  paymentStatusContoller.text == 'partial payment' || paymentStatusContoller.text=='cleared'? Colors.green: Colors.grey,
                                            ),
                                            Text(
                                              'Payments',
                                              style: TextStyle(
                                                color: paymentStatusContoller.text == 'partial payment' || paymentStatusContoller.text=='cleared'? Colors.black: Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),


                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 50,right: 50,top: 250),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Color(0xFFFFFFFF), // background: #FFFFFF
                                  boxShadow: [BoxShadow(
                                    offset: Offset(0, 3),
                                    blurRadius: 6,
                                    color: Color(0x29000000), // box-shadow: 0px 3px 6px #00000029
                                  )],
                                  border: Border.all(
                                    // border: 2px
                                    color: Color(0xFFB2C2D3), // border: #B2C2D3
                                  ),
                                  borderRadius: BorderRadius.all(Radius.circular(8)), // border-radius: 8px
                                ),
                                // decoration: BoxDecoration(
                                //   border: Border.all(color: const Color(0xFFB2C2D3)),
                                //   borderRadius: BorderRadius.circular(3.5), // Set border radius here
                                // ),
                                child: Table(
                                  border: TableBorder.all(color: const Color(0xFFB2C2D3)),

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
                            _isLoading
                                ? Padding(
                              padding: EdgeInsets.only(top: 400),
                              child: SpinKitWave(
                                color: Colors.blue,
                                size: 30.0,
                              ),
                            )
                                : Container(),
                            Padding(
                              padding:  const EdgeInsets.only(left: 50, top: 650,right: 50),
                              child: Container(
                                // height: 150,
                                width: maxWidth,
                                //   padding: const EdgeInsets.all(0.0),
                                decoration: BoxDecoration(
                                  color: Color(0xFFFFFFFF), // background: #FFFFFF
                                  boxShadow: [BoxShadow(
                                    offset: Offset(0, 3),
                                    blurRadius: 6,
                                    color: Color(0x29000000), // box-shadow: 0px 3px 6px #00000029
                                  )],
                                  border: Border.all(
                                    // border: 2px
                                    color: Color(0xFFB2C2D3), // border: #B2C2D3
                                  ),
                                  borderRadius: BorderRadius.all(Radius.circular(8)), // border-radius: 8px
                                ),
                                // decoration: BoxDecoration(
                                //   border: Border.all(color: const Color(0xFFB2C2D3), width:
                                //   2),
                                //   borderRadius: BorderRadius.circular(5.0),
                                // ),
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
                                    Container(
                                      width: maxWidth,
                                      decoration: BoxDecoration(
                                        border: Border(
                                          top: BorderSide(color: const Color(0xFFB2C2D3), width: 1.2),
                                          bottom: BorderSide(color: const Color(0xFFB2C2D3), width: 1.2),
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
                                            7: FlexColumnWidth(2),
                                            8: FlexColumnWidth(2),
                                            9: FlexColumnWidth(2),
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
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    ListView.builder(
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      itemCount: selectedItems.length,
                                      itemBuilder: (context, index) {
                                        var item = selectedItems[index];
                                        // int index = selectedItems.indexOf(item) + 1;
                                        return Table(

                                          border: TableBorder(
                                            bottom: BorderSide(width:1 ,color: Colors.grey),
                                            //   horizontalInside: BorderSide(width: 1,color: Colors.grey), // horizontal border inside the table
                                            verticalInside: BorderSide(width: 1,color: Colors.grey),
                                          ),
                                          // border: TableBorder.all(
                                          //     color: const Color(0xFFB2C2D3)),
                                          // Add this line
                                          columnWidths: const {
                                            0: FlexColumnWidth(1),
                                            1: FlexColumnWidth(2.7),
                                            2: FlexColumnWidth(2),
                                            3: FlexColumnWidth(1.8),
                                            4: FlexColumnWidth(2),
                                            5: FlexColumnWidth(1),
                                            6: FlexColumnWidth(2),
                                            7: FlexColumnWidth(2),
                                            8: FlexColumnWidth(2),
                                            9: FlexColumnWidth(2),
                                          },

                                          children: [
                                            TableRow(
                                              children: [
                                                TableCell(
                                                  child: Padding(
                                                    padding: const EdgeInsets.only(
                                                        left: 10,
                                                        right: 10,
                                                        top: 15,
                                                        bottom: 15),
                                                    child: Center(
                                                      child: Text(
                                                        ' ${index + 1}',
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
                                                        borderRadius: BorderRadius
                                                            .circular(4.0),
                                                      ),
                                                      child: Center(
                                                        child: Text(
                                                          item['productName'],
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
                                                        borderRadius: BorderRadius
                                                            .circular(4.0),
                                                      ),
                                                      child: Center(
                                                        child: Text(
                                                          item['category'],
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
                                                        borderRadius: BorderRadius
                                                            .circular(4.0),
                                                      ),
                                                      child: Center(
                                                        child: Text(
                                                          item['subCategory'],
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
                                                        borderRadius: BorderRadius
                                                            .circular(4.0),
                                                      ),
                                                      child: Center(
                                                        child: Text(
                                                          item['price'].toString(),
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
                                                        bottom: 10
                                                    ),
                                                    child: Container(
                                                      height: 35,
                                                      decoration: BoxDecoration(
                                                        color: Colors.grey.shade200,
                                                        borderRadius: BorderRadius
                                                            .circular(4.0),
                                                      ),
                                                      child: Center(
                                                        child: Text(
                                                          item['qty'].toString(),
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
                                                        bottom: 10
                                                    ),
                                                    child: Container(
                                                      height: 35,
                                                      decoration: BoxDecoration(
                                                        color: Colors.grey.shade200,
                                                        borderRadius: BorderRadius
                                                            .circular(4.0),
                                                      ),
                                                      child: Center(
                                                        child: Text(
                                                          item['actualAmount']
                                                              .toString(),
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
                                                        bottom: 10
                                                    ),
                                                    child: Container(
                                                      height: 35,
                                                      decoration: BoxDecoration(
                                                        color: Colors.grey.shade200,
                                                        borderRadius: BorderRadius
                                                            .circular(4.0),
                                                      ),
                                                      child: Center(
                                                        child: Text(
                                                          item['discount']
                                                              .toString(),
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
                                                        bottom: 10
                                                    ),
                                                    child: Container(
                                                      height: 35,
                                                      decoration: BoxDecoration(
                                                        color: Colors.grey.shade200,
                                                        borderRadius: BorderRadius
                                                            .circular(4.0),
                                                      ),
                                                      child: Center(
                                                        child: Text(
                                                          item['tax']
                                                              .toString(),
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
                                                        bottom: 10
                                                    ),
                                                    child: Container(
                                                      height: 35,
                                                      decoration: BoxDecoration(
                                                        color: Colors.grey.shade200,
                                                        borderRadius: BorderRadius
                                                            .circular(4.0),
                                                      ),
                                                      child: Center(
                                                        child: Text(
                                                         item['totalAmount']
                                                              .toStringAsFixed(2),
                                                          textAlign: TextAlign
                                                              .center,
                                                        ),
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
                                    Padding(
                                      padding: const EdgeInsets.only(top: 9,bottom: 9),
                                      child: Align(
                                        alignment: const Alignment(0.9,0.8),
                                        child: Container(
                                          height: 40,
                                          padding: const EdgeInsets.only(left: 15,right: 10,top: 2,bottom: 2),
                                          decoration: BoxDecoration(
                                            border: Border.all(color: Colors.blue),
                                            borderRadius: BorderRadius.circular(2.0),
                                            color: Colors.white,
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.only(bottom: 2),
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
                                                      text:
                                                      totalController.text,
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


                            // if(_isLoading)...{
                            //   // Expanded(
                            //   //   child: SingleChildScrollView(
                            //   //     child: Stack(
                            //   //       children: [
                            //   Padding(
                            //     padding: const EdgeInsets.only(left: 90, top: 100,right: 120),
                            //     child: Container(
                            //       height: 100,
                            //       width: maxWidth,
                            //       decoration: BoxDecoration(
                            //         color: Color(0xFFFFFFFF), // background: #FFFFFF
                            //         boxShadow: [BoxShadow(
                            //           offset: Offset(0, 3),
                            //           blurRadius: 6,
                            //           color: Color(0x29000000), // box-shadow: 0px 3px 6px #00000029
                            //         )],
                            //         border: Border.all(
                            //           // border: 2px
                            //           color: Color(0xFFB2C2D3), // border: #B2C2D3
                            //         ),
                            //         borderRadius: BorderRadius.all(Radius.circular(8)), // border-radius: 8px
                            //       ),
                            //       child: const Padding(
                            //         padding: EdgeInsets.only(top: 30),
                            //         child: Row(
                            //           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            //           children: [
                            //             Expanded(
                            //               flex: 1,
                            //               child: Column(
                            //                 children: [
                            //                   Icon(
                            //                     Icons.check_box,
                            //                     color: Colors.green,
                            //                   ),
                            //                   Text(
                            //                     'Order Placed',
                            //                     style: TextStyle(
                            //                       color: Colors.black,
                            //                     ),
                            //                   ),
                            //                 ],
                            //               ),
                            //             ),
                            //             Expanded(
                            //               flex: 1,
                            //               child: Column(
                            //                 children: [
                            //                   Icon(
                            //                     Icons.check_box,
                            //                     color: Colors.grey,
                            //                   ),
                            //                   Text(
                            //                     'Invoice',
                            //                     style: TextStyle(
                            //                       color: Colors.grey,
                            //                     ),
                            //                   ),
                            //                 ],
                            //               ),
                            //             ),
                            //             Expanded(
                            //               flex: 1,
                            //               child: Column(
                            //                 children: [
                            //                   Icon(
                            //                     Icons.check_box,
                            //                     color: Colors.grey,
                            //                   ),
                            //                   Text(
                            //                     'Payments',
                            //                     style: TextStyle(
                            //                       color: Colors.grey,
                            //                     ),
                            //                   ),
                            //                 ],
                            //               ),
                            //             ),
                            //             Expanded(
                            //               flex: 1,
                            //               child: Column(
                            //                 children: [
                            //                   Icon(
                            //                     Icons.check_box,
                            //                     color: Colors.grey,
                            //                   ),
                            //                   Text(
                            //                     'Delivery',
                            //                     style: TextStyle(
                            //                       color: Colors.grey,
                            //                     ),
                            //                   ),
                            //                 ],
                            //               ),
                            //             ),
                            //           ],
                            //         ),
                            //       ),
                            //     ),
                            //   ),
                            //   Padding(
                            //     padding: const EdgeInsets.only(left: 90,right: 120,top: 250),
                            //     child: Container(
                            //       decoration: BoxDecoration(
                            //         color: Color(0xFFFFFFFF), // background: #FFFFFF
                            //         boxShadow: [BoxShadow(
                            //           offset: Offset(0, 3),
                            //           blurRadius: 6,
                            //           color: Color(0x29000000), // box-shadow: 0px 3px 6px #00000029
                            //         )],
                            //         border: Border.all(
                            //           // border: 2px
                            //           color: Color(0xFFB2C2D3), // border: #B2C2D3
                            //         ),
                            //         borderRadius: BorderRadius.all(Radius.circular(8)), // border-radius: 8px
                            //       ),
                            //       // decoration: BoxDecoration(
                            //       //   border: Border.all(color: const Color(0xFFB2C2D3)),
                            //       //   borderRadius: BorderRadius.circular(3.5), // Set border radius here
                            //       // ),
                            //       child: Table(
                            //         border: TableBorder.all(color: const Color(0xFFB2C2D3)),
                            //
                            //         columnWidths: const {
                            //           0: FlexColumnWidth(2),
                            //           1: FlexColumnWidth(1.4),
                            //         },
                            //         children: [
                            //           row1,
                            //           row2,
                            //           row3,
                            //         ],
                            //       ),
                            //     ),
                            //   ),
                            //   Padding(
                            //     padding:  const EdgeInsets.only(left: 90, top: 650,right: 120),
                            //     child: Container(
                            //       // height: 150,
                            //       width: maxWidth,
                            //       //   padding: const EdgeInsets.all(0.0),
                            //       decoration: BoxDecoration(
                            //         color: Color(0xFFFFFFFF), // background: #FFFFFF
                            //         boxShadow: [BoxShadow(
                            //           offset: Offset(0, 3),
                            //           blurRadius: 6,
                            //           color: Color(0x29000000), // box-shadow: 0px 3px 6px #00000029
                            //         )],
                            //         border: Border.all(
                            //           // border: 2px
                            //           color: Color(0xFFB2C2D3), // border: #B2C2D3
                            //         ),
                            //         borderRadius: BorderRadius.all(Radius.circular(8)), // border-radius: 8px
                            //       ),
                            //       // decoration: BoxDecoration(
                            //       //   border: Border.all(color: const Color(0xFFB2C2D3), width:
                            //       //   2),
                            //       //   borderRadius: BorderRadius.circular(5.0),
                            //       // ),
                            //       child: Column(
                            //         crossAxisAlignment: CrossAxisAlignment.start,
                            //         children: [
                            //           Padding(
                            //             padding: const EdgeInsets.only(left: 30, top: 10),
                            //             child: Text(
                            //               'Add Products',
                            //               style: TextStyle(
                            //                 fontSize: 16,
                            //                 fontWeight: FontWeight.bold,
                            //                 color: Colors.grey[600],
                            //               ),
                            //             ),
                            //           ),
                            //           Container(
                            //             width: maxWidth,
                            //             decoration: BoxDecoration(
                            //               border: Border(
                            //                 top: BorderSide(color: const Color(0xFFB2C2D3), width: 1.2),
                            //                 bottom: BorderSide(color: const Color(0xFFB2C2D3), width: 1.2),
                            //               ),
                            //             ),
                            //             child: Padding(
                            //               padding: const EdgeInsets.only(top: 5, bottom: 5),
                            //               child: Table(
                            //                 columnWidths: const {
                            //                   0: FlexColumnWidth(1),
                            //                   1: FlexColumnWidth(2.7),
                            //                   2: FlexColumnWidth(2),
                            //                   3: FlexColumnWidth(1.8),
                            //                   4: FlexColumnWidth(2),
                            //                   5: FlexColumnWidth(1),
                            //                   6: FlexColumnWidth(2),
                            //                 },
                            //                 children: const [
                            //                   TableRow(
                            //                     children: [
                            //                       TableCell(
                            //                         child: Padding(
                            //                           padding: EdgeInsets.only(top: 10, bottom: 10),
                            //                           child: Center(
                            //                             child: Text(
                            //                               'SN',
                            //                               style: TextStyle(fontWeight: FontWeight.bold),
                            //                             ),
                            //                           ),
                            //                         ),
                            //                       ),
                            //                       TableCell(
                            //                         child: Padding(
                            //                           padding: EdgeInsets.only(top: 10, bottom: 10),
                            //                           child: Center(
                            //                             child: Text(
                            //                               'Product Name',
                            //                               style: TextStyle(fontWeight: FontWeight.bold),
                            //                             ),
                            //                           ),
                            //                         ),
                            //                       ),
                            //                       TableCell(
                            //                         child: Padding(
                            //                           padding: EdgeInsets.only(top: 10, bottom: 10),
                            //                           child: Center(
                            //                             child: Text(
                            //                               'Category',
                            //                               style: TextStyle(fontWeight: FontWeight.bold),
                            //                             ),
                            //                           ),
                            //                         ),
                            //                       ),
                            //                       TableCell(
                            //                         child: Padding(
                            //                           padding: EdgeInsets.only(top: 10, bottom: 10),
                            //                           child: Center(
                            //                             child: Text(
                            //                               'Sub Category',
                            //                               style: TextStyle(fontWeight: FontWeight.bold),
                            //                             ),
                            //                           ),
                            //                         ),
                            //                       ),
                            //                       TableCell(
                            //                         child: Padding(
                            //                           padding: EdgeInsets.only(top: 10, bottom: 10),
                            //                           child: Center(
                            //                             child: Text(
                            //                               'Price',
                            //                               style: TextStyle(fontWeight: FontWeight.bold),
                            //                             ),
                            //                           ),
                            //                         ),
                            //                       ),
                            //                       TableCell(
                            //                         child: Padding(
                            //                           padding: EdgeInsets.only(top: 10, bottom: 10),
                            //                           child: Center(
                            //                             child: Text(
                            //                               'QTY',
                            //                               style: TextStyle(fontWeight: FontWeight.bold),
                            //                             ),
                            //                           ),
                            //                         ),
                            //                       ),
                            //                       TableCell(
                            //                         child: Padding(
                            //                           padding: EdgeInsets.only(top: 10, bottom: 10),
                            //                           child: Center(
                            //                             child: Text(
                            //                               'Total Amount',
                            //                               style: TextStyle(fontWeight: FontWeight.bold),
                            //                             ),
                            //                           ),
                            //                         ),
                            //                       ),
                            //                     ],
                            //                   ),
                            //                 ],
                            //               ),
                            //             ),
                            //           ),
                            //           ListView.builder(
                            //             shrinkWrap: true,
                            //             physics: const NeverScrollableScrollPhysics(),
                            //             itemCount: selectedItems.length,
                            //             itemBuilder: (context, index) {
                            //               var item = selectedItems[index];
                            //               // int index = selectedItems.indexOf(item) + 1;
                            //               return Table(
                            //                 border: TableBorder(
                            //                   bottom: BorderSide(width:1 ,color: Colors.grey),
                            //                   //   horizontalInside: BorderSide(width: 1,color: Colors.grey), // horizontal border inside the table
                            //                   verticalInside: BorderSide(width: 1,color: Colors.grey),
                            //                 ),
                            //                 // border: TableBorder.all(
                            //                 //     color: const Color(0xFFB2C2D3)),
                            //                 // Add this line
                            //                 columnWidths: const {
                            //                   0: FlexColumnWidth(1),
                            //                   1: FlexColumnWidth(2.7),
                            //                   2: FlexColumnWidth(2),
                            //                   3: FlexColumnWidth(1.8),
                            //                   4: FlexColumnWidth(2),
                            //                   5: FlexColumnWidth(1),
                            //                   6: FlexColumnWidth(2),
                            //                 },
                            //
                            //                 children: [
                            //                   TableRow(
                            //                     children: [
                            //                       TableCell(
                            //                         child: Padding(
                            //                           padding: const EdgeInsets.only(
                            //                               left: 10,
                            //                               right: 10,
                            //                               top: 15,
                            //                               bottom: 15),
                            //                           child: Center(
                            //                             child: Text(
                            //                               ' ${index + 1}',
                            //                             ),
                            //                           ),
                            //                         ),
                            //                       ),
                            //                       TableCell(
                            //                         child: Padding(
                            //                           padding: const EdgeInsets.only(
                            //                               left: 10,
                            //                               right: 10,
                            //                               top: 10,
                            //                               bottom: 10),
                            //                           child: Container(
                            //                             height: 35,
                            //                             decoration: BoxDecoration(
                            //                               color: Colors.grey.shade200,
                            //                               borderRadius: BorderRadius
                            //                                   .circular(4.0),
                            //                             ),
                            //                             child: Center(
                            //                               child: Text(
                            //                                 item['productName'],
                            //                                 textAlign: TextAlign
                            //                                     .center,
                            //                               ),
                            //                             ),
                            //                           ),
                            //                         ),
                            //                       ),
                            //                       TableCell(
                            //                         child: Padding(
                            //                           padding: const EdgeInsets.only(
                            //                               left: 10,
                            //                               right: 10,
                            //                               top: 10,
                            //                               bottom: 10),
                            //                           child: Container(
                            //                             height: 35,
                            //                             decoration: BoxDecoration(
                            //                               color: Colors.grey.shade200,
                            //                               borderRadius: BorderRadius
                            //                                   .circular(4.0),
                            //                             ),
                            //                             child: Center(
                            //                               child: Text(
                            //                                 item['category'],
                            //                                 textAlign: TextAlign
                            //                                     .center,
                            //                               ),
                            //                             ),
                            //                           ),
                            //                         ),
                            //                       ),
                            //                       TableCell(
                            //                         child: Padding(
                            //                           padding: const EdgeInsets.only(
                            //                               left: 10,
                            //                               right: 10,
                            //                               top: 10,
                            //                               bottom: 10),
                            //                           child: Container(
                            //                             height: 35,
                            //                             decoration: BoxDecoration(
                            //                               color: Colors.grey.shade200,
                            //                               borderRadius: BorderRadius
                            //                                   .circular(4.0),
                            //                             ),
                            //                             child: Center(
                            //                               child: Text(
                            //                                 item['subCategory'],
                            //                                 textAlign: TextAlign
                            //                                     .center,
                            //                               ),
                            //                             ),
                            //                           ),
                            //                         ),
                            //                       ),
                            //                       TableCell(
                            //                         child: Padding(
                            //                           padding: const EdgeInsets.only(
                            //                               left: 10,
                            //                               right: 10,
                            //                               top: 10,
                            //                               bottom: 10),
                            //                           child: Container(
                            //                             height: 35,
                            //                             decoration: BoxDecoration(
                            //                               color: Colors.grey.shade200,
                            //                               borderRadius: BorderRadius
                            //                                   .circular(4.0),
                            //                             ),
                            //                             child: Center(
                            //                               child: Text(
                            //                                 item['price'].toString(),
                            //                                 textAlign: TextAlign
                            //                                     .center,
                            //                               ),
                            //                             ),
                            //                           ),
                            //                         ),
                            //                       ),
                            //                       TableCell(
                            //                         child: Padding(
                            //                           padding: const EdgeInsets.only(
                            //                               left: 10,
                            //                               right: 10,
                            //                               top: 10,
                            //                               bottom: 10
                            //                           ),
                            //                           child: Container(
                            //                             height: 35,
                            //                             decoration: BoxDecoration(
                            //                               color: Colors.grey.shade200,
                            //                               borderRadius: BorderRadius
                            //                                   .circular(4.0),
                            //                             ),
                            //                             child: Center(
                            //                               child: Text(
                            //                                 item['qty'].toString(),
                            //                                 textAlign: TextAlign
                            //                                     .center,
                            //                               ),
                            //                             ),
                            //                           ),
                            //                         ),
                            //                       ),
                            //                       TableCell(
                            //                         child: Padding(
                            //                           padding: const EdgeInsets.only(
                            //                               left: 10,
                            //                               right: 10,
                            //                               top: 10,
                            //                               bottom: 10
                            //                           ),
                            //                           child: Container(
                            //                             height: 35,
                            //                             decoration: BoxDecoration(
                            //                               color: Colors.grey.shade200,
                            //                               borderRadius: BorderRadius
                            //                                   .circular(4.0),
                            //                             ),
                            //                             child: Center(
                            //                               child: Text(
                            //                                 item['totalAmount']
                            //                                     .toString(),
                            //                                 textAlign: TextAlign
                            //                                     .center,
                            //                               ),
                            //                             ),
                            //                           ),
                            //                         ),
                            //                       ),
                            //                     ],
                            //                   ),
                            //                 ],
                            //               );
                            //             },
                            //           ),
                            //           Padding(
                            //             padding: const EdgeInsets.only(top: 9,bottom: 9),
                            //             child: Align(
                            //               alignment: const Alignment(0.9,0.8),
                            //               child: Container(
                            //                 height: 40,
                            //                 padding: const EdgeInsets.only(left: 15,right: 10,top: 2,bottom: 2),
                            //                 decoration: BoxDecoration(
                            //                   border: Border.all(color: Colors.blue),
                            //                   borderRadius: BorderRadius.circular(2.0),
                            //                   color: Colors.white,
                            //                 ),
                            //                 child: Padding(
                            //                   padding: const EdgeInsets.only(bottom: 2),
                            //                   child: Row(
                            //                     mainAxisSize: MainAxisSize.min,
                            //                     children: [
                            //                       RichText(text:
                            //                       TextSpan(
                            //                         children: [
                            //                           const TextSpan(
                            //                             text:  'Total',
                            //                             style: TextStyle(
                            //                                 fontSize: 14,
                            //                                 color: Colors.blue
                            //                               // fontWeight: FontWeight.bold,
                            //                             ),
                            //                           ),
                            //                           const TextSpan(
                            //                             text: '  ₹',
                            //                             style: TextStyle(
                            //                               color: Colors.black,
                            //                             ),
                            //                           ),
                            //                           TextSpan(
                            //                             text:
                            //                             totalController.text,
                            //                             style: const TextStyle(
                            //                               color: Colors.black,
                            //                             ),
                            //                           ),
                            //                         ],
                            //                       ),
                            //                       )
                            //                     ],
                            //                   ),
                            //                 ),
                            //               ),
                            //             ),
                            //           ),
                            //         ],
                            //       ),
                            //     ),
                            //   ),
                            //   //       ],
                            //   //     ),
                            //   //   ),
                            //   // )
                            //
                            // }else if(_hasError)...{
                            //
                            //   NetworkIssue(),
                            //   // Padding(
                            //   // padding: EdgeInsets.only(top:400),
                            //   // child:Center(
                            //   // child:  SpinKitWave(
                            //   //
                            //   // color: Colors.blue,
                            //   // size: 50.0,
                            //   // ),
                            //   // ),
                            //   // ),
                            // }
                            // else...{
                            //     Padding(
                            //       padding: EdgeInsets.only(top:400),
                            //       child:Center(
                            //         child:  SpinKitWave(
                            //           color: Colors.blue,
                            //           size: 50.0,
                            //         ),
                            //       ),
                            //     ),
                            //
                            //   }




                          ],
                        ),
                      )
                  )


                ],
              );
            }
        )


    );
  }

  void _showProductDetails(OrderDetail selectedOrderDetails) {
    //final selectedOrderDetails = widget.orderDetails![selectedOrderDetails];
    //final selectedOrderDetails = _orders[index];
    print('Selected Order:');
    print(': ${selectedOrderDetails.InvNo}');
    print('status of the product: ${selectedOrderDetails.Payment}');
    print('status of the product: ${selectedOrderDetails.status}');
    print('Delivery Status: ${selectedOrderDetails.Status}');
    print('Order ID: ${selectedOrderDetails.orderId}');
    print('Order Date: ${selectedOrderDetails.orderDate}');
    print('Contact Person: ${selectedOrderDetails.contactPerson}');
    print('Delivery Location: ${selectedOrderDetails.deliveryLocation}');
    print('total: ${selectedOrderDetails.total}');
    data2['deliveryLocation'] = selectedOrderDetails.deliveryLocation;
    print('--------deliver');
    print(data2['deliveryLocation']);

    print(productNameController.text);
    InvNoController.text = selectedOrderDetails.InvNo!;
    deliveryStatusController.text = selectedOrderDetails.status!;
    paymentStatusContoller.text = selectedOrderDetails.Payment!;
    print('--------delive11r');
    print(deliveryStatusController.text);
    CreatedDateController.text = selectedOrderDetails.orderDate!;
    orderIdController.text = selectedOrderDetails.orderId!;
   // InvNoController.text = selectedOrderDetails.InvNo!;
    deliveryLocationController.text = selectedOrderDetails.deliveryLocation!;
    contactPersonController.text = selectedOrderDetails.contactPerson!;
    deliveryAddressController.text = selectedOrderDetails.deliveryAddress!;
    contactNumberController.text = selectedOrderDetails.contactNumber!;
    commentsController.text = selectedOrderDetails.comments!;
    totalController.text = selectedOrderDetails.total.toString();
    // contactPersonController.text = _orders[index]['orderDate'];
    // deliveryLocationController.text = _orders[selectedOrderDetails]['deliveryLocation'];
    print('------------devli');
    print(data2['deliveryLocation']);
    final selectedOrder = selectedOrderDetails;
    setState(() {
      selectedItems = List<Map<String, dynamic>>.from(selectedOrder.items);
    });

    print('Selected Order:');
    print('Order ID: ${selectedOrder.orderId}');
    print('Order Date: ${selectedOrder.orderDate}');
    print('Contact Person: ${selectedOrder.contactPerson}');
    print('Delivery Location: ${selectedOrder.deliveryLocation}');
    print('total: ${selectedOrder.total}');

    for (var item in selectedItems) {
      print('Product Name: ${item['productName']}');
      print('orderMasterItemId: ${item['orderMasterItemId']}');
      print('Price: ${item['price']}');
      print('Quantity: ${item['qty']}');
      print('Category: ${item['category']}');
      print('tax: ${item['tax']}');
      print('discount: ${item['discount']}');
      print('Sub Category: ${item['subCategory']}');
      print('Total Amount: ${item['totalAmount']}');
      print('------------------------');

      // Add more fields to print as needed
    }
  }



  void _showDatePicker(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2015),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('dd-MM-yyyy').format(_selectedDate!);
      });
    }
  }
  void displayItemDetails() {
    for (var item in widget.product!.items) {
      selectedItems.add({
        'orderMasterItemId': item['orderMasterItemId'],
        'productName': item['productName'],
        'category': item['category'],
        'subCategory': item['subCategory'],
        'price': item['price'],
        'qty': item['qty'],
        'tax': item['tax'],
        'discount': item['discount'],
        'actualAmount': item['actualAmount'],
        'totalAmount': item['totalAmount'],
      });
    }
  }



  Widget tableHeader(String text) {
    return TableCell(
      child: Container(
        color: Colors.grey[300],
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget tableCell(String text) {
    return TableCell(
      verticalAlignment: TableCellVerticalAlignment.middle,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
            6, 2, 6, 2),
        child: Container(
          height: 35,
          padding: const EdgeInsets.all(8.0),
          child: Center(child: Text(text)),
        ),
      ),
    );
    //TableCell(
    //               verticalAlignment:
    //               TableCellVerticalAlignment.middle,
    //               child: Padding(
    //                 padding: const EdgeInsets.fromLTRB(
    //                     6, 2, 6, 2),
    //                 child: Container(
    //                   height: 35,
    //                   decoration: BoxDecoration(
    //                     color: Colors.grey[300],
    //                   ),
    //                   child: Center(
    //                     child: Text(
    //                       item['productName'],
    //                       style: const TextStyle(
    //                         color: Colors.black,
    //                       ),
    //                     ),
    //                   ),
    //                 ),
    //               ),
    //             ),
  }

}

class OrderDetails {
  String orderId;
  String orderDate;
  String contactPerson;
  String deliveryLocation;
  double total;
  List<OrderItem> items;

  OrderDetails({
    required this.orderId,
    required this.orderDate,
    required this.contactPerson,
    required this.deliveryLocation,
    required this.total,
    required this.items,
  });
}

class OrderItem {
  String productName;
  double price;
  int qty;
  String category;
  String subCategory;
  double totalAmount;
  String orderMasterItemId;

  OrderItem({
    required this.productName,
    required this.price,
    required this.qty,
    required this.category,
    required this.subCategory,
    required this.totalAmount,
    required this.orderMasterItemId,
  });
}

