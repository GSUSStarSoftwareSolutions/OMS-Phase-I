import 'dart:async';
import 'dart:convert';
import 'dart:html';
import 'package:adaptive_scrollbar/adaptive_scrollbar.dart';
import 'package:btb/Order%20Module/firstpage.dart';
import 'package:btb/admin/Api%20name.dart';
import 'package:btb/widgets/confirmdialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart'as http;



void main(){
  runApp(CusEditViewScreen(selectedProducts: const {}, product: null, orderId: ''));
}

class CusEditViewScreen extends StatefulWidget {

  final Map<String, dynamic> selectedProducts;
  final detail? product;
  final String? orderId;
  final List<dynamic>? orderDetails;

  CusEditViewScreen({super.key,required this.selectedProducts,required this.product,this.orderDetails,required this.orderId});

  @override
  State<CusEditViewScreen> createState() => _CusEditViewScreenState();
}

class _CusEditViewScreenState extends State<CusEditViewScreen> {
  final _formKey = GlobalKey<FormState>();
  bool isSelected = false;

  int _selectedIndex = -1;
  Map<String, dynamic> data2 = {};
  DateTime? _selectedDate;
  final ScrollController horizontalScroll = ScrollController();
  final TextEditingController deliveryStatusController = TextEditingController();
  final TextEditingController deliveryLocationController = TextEditingController();
  List<Map<String, dynamic>> selectedItems = [];
  final TextEditingController deliveryAddressController = TextEditingController();
  final TextEditingController contactPersonController = TextEditingController();
  final TextEditingController contactNumberController = TextEditingController();
  final TextEditingController commentsController = TextEditingController();
  final List<String> list = ['  Name 1', '  Name 2', '  Name3'];
  final TextEditingController CreatedDateController = TextEditingController();
  final TextEditingController orderIdController = TextEditingController();
  final TextEditingController totalController = TextEditingController();
  final TextEditingController productNameController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();
  final TextEditingController subCategoryController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController qtyController = TextEditingController();
  final TextEditingController EmailIdController = TextEditingController();
  bool? _isChecked1 = true;
  bool _isLoading = false;
  bool _isFirstLoad = true;
  bool? _isChecked2 = true;
  List<detail> filteredData = [];
  String token = window.sessionStorage["token"]?? " ";
  List<Map> _orders = [];
  String _searchText = '';
  bool _loading = false;
  bool isEditing = false;
  late TextEditingController _dateController;
  bool? _isChecked3 = false;
  bool? _isChecked4 = false;
  bool _hasShownPopup = false;
  Timer? _timer;
  final TextEditingController totalAmountController = TextEditingController();
  bool isOrdersSelected = false;
  String _errorMessage = '';
  List<bool> _isSelected = [];
  final _orderIdController = TextEditingController();
  Map<String, bool> _isHovered = {
    'Orders': false,
    'Invoice': false,
    'Delivery': false,
    'Payment': false,
    'Return': false,
  };


  List<Widget> _buildMenuItems(BuildContext context) {
    return [
      _buildMenuItem('Home', Icons.home_outlined, Colors.blue[900]!, '/Cus_Home'),
      Container( decoration: BoxDecoration(
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

    //_fetchOrders();


    print('sevetnhpage');
    // widget.orderId;
    fetchProducts();
    print(widget.orderId);
    orderIdController.text = widget.orderId!;
    _isSelected = List<bool>.filled(widget.orderDetails!.length, false);
    print(widget.orderDetails);
    //_isSelected = List<bool>.filled(widget.orderDetails!.length, false);
    widget.selectedProducts;
    //  orderIdController.text = widget.product!.orderId ?? '';
    // _orderIdController.addListener((){
    //   _fetchOrders();
    // });

    print('--updated details');
    if (widget.selectedProducts['total']!= null) {
      totalController.text = widget.selectedProducts['total'].toString();
    }
    // if (widget.selectedProducts['orderId']!= null) {
    //   orderIdController.text = widget.selectedProducts['orderId'].toString();
    // }
    if (widget.selectedProducts['orderDate']!= null) {
      CreatedDateController.text = widget.selectedProducts['orderDate'].toString();
    }
    if (widget.selectedProducts['contactPerson']!= null) {
      contactPersonController.text = widget.selectedProducts['contactPerson'];
    }
    if (widget.selectedProducts['deliveryAddress']!= null) {
      deliveryAddressController.text = widget.selectedProducts['deliveryAddress'];
    }
    if (widget.selectedProducts['contactNumber']!= null) {
      contactNumberController.text = widget.selectedProducts['contactNumber'];
    }
    if (widget.selectedProducts['comments']!= null) {
      commentsController.text = widget.selectedProducts['comments'];
    }
    if (widget.selectedProducts['deliveryLocation']!= null) {
      EmailIdController.text = widget.selectedProducts['deliveryLocation'];
    }
    if (widget.selectedProducts['contactPerson']!= null) {
      widget.selectedProducts['contactPerson'] = contactPersonController.text;
    }
//  widget.selectedProducts['contactPerson'] = contactPersonController.text;
    if (widget.selectedProducts != null && widget.selectedProducts['items'] != null) {
      for (var item in widget.selectedProducts['items']) {
        selectedItems.add({
          'productName': '${item['productName']}',
          'category': '${item['category']}',
          'subCategory': '${item['subCategory']}',
          'price': '${item['price']}',
          'qty': item['qty'].toString(),
          'tax': item['tax'],
          'discount': item['discount'],
          'actualAmount': item['actualAmount'],
          'totalAmount': item['totalAmount']

        });
      }

    }
    // if (data2!= null) {
    //     totalAmount = data2['total']!= null? double.parse(data2['total']) : 0.0;
    //   }

    print(widget.selectedProducts);
    //_orderIdController.addListener(_fetchOrders);
    _dateController = TextEditingController();

    _selectedDate = DateTime.now();
    _dateController.text = DateFormat.yMd().format(_selectedDate!);
  }



  @override
  void dispose() {
    //_orderIdController.removeListener(_fetchOrders);
    _dateController.dispose();
    super.dispose();
  }


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
          final jsonData = jsonDecode(response.body);
          filteredData =
              (jsonData as List).map((item) => detail.fromJson(item)).toList();

          print('api response');
          print(filteredData);
          if (mounted) {
            setState(() {});
          }
        } else {
          throw Exception('Failed to load data');
        }
      }
    } catch (e) {
      print('Error decoding JSON: $e');
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
          final responseBody = response.body;
          final jsonData = jsonDecode(responseBody);
          if (jsonData is List<dynamic>) {
            final jsonObject = jsonData.first;
            final orderDetails = OrderDetail.fromJson(jsonObject);
            _showProductDetails(orderDetails);
          } else {
            print('Failed to load order details');
          }
        } else {
          print('Failed to load order details');
        }
      }
    } catch (e) {
      // print('Error: $e');
      setState(() {
        _isLoading = false;
        // _hasError = true;
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



  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
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
                  width: screenWidth * 0.1,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: TextFormField(
                    enabled: isEditing,
                    controller: CreatedDateController,
                    readOnly: true,
                    decoration: InputDecoration(
                      suffixIcon: Padding(
                        padding: const EdgeInsets.only(right: 20),
                        child: IconButton(
                          icon: const Icon(Icons.calendar_month),
                          iconSize: 20,
                          onPressed: () {
                            _showDatePicker(context);
                          },
                        ),
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
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0),
                              borderSide: const BorderSide(color: Colors.grey),
                            ),
                            hintText: 'Contact Person Name',

                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Padding(
                      padding:  EdgeInsets.only(left: 30),
                      child: Text('Delivery Address'),
                    ),
                    const SizedBox(height: 10,),
                    Padding(
                      padding:  const EdgeInsets.only(left: 30),
                      child: SizedBox(
                        width: screenWidth * 0.35,
                        child: TextField(
                          enabled: isEditing,
                          controller: deliveryAddressController,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor:Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0),
                              borderSide: const BorderSide(color: Color(0xFFECEFF1)),
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
                        child: TextField(
                          enabled: isEditing,
                          controller: contactNumberController,

                          keyboardType:
                          TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter
                                .digitsOnly,
                            LengthLimitingTextInputFormatter(
                                10),
                            // limits to 10 digits
                          ],
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0),
                              borderSide: const BorderSide(color: Colors.grey),
                            ),

                            hintText: 'Contact Person Number',

                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 8),
                          ),
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
                        child:
                        TextFormField(
                          enabled: isEditing,
                          controller: EmailIdController,

                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0),
                              borderSide: const BorderSide(color: Colors.grey),
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
                              borderSide: const BorderSide(color: Colors.grey),
                            ),
                            //hintText: 'Enter Your Comments'
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
        appBar:  AppBar(
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
              if(constraints.maxWidth >= 1366){
                return  Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                      padding: const EdgeInsets.only(left: 0,top: 0),
                      child: Container(
                        width: 1.8, // Set the width to 1 for a vertical line
                        height: 984, // Set the height to your liking
                        decoration: const BoxDecoration(
                          border: Border(left: BorderSide(width: 1, color: Colors.grey)),
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(
                        // top: 60,
                        left: 1,
                      ),
                      width: 298,
                      height: 928
                      ,
                      decoration: BoxDecoration(
                        color: Colors.white,
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
                                      context.go('/Customer_Order_List');
                                    },
                                  ),
                                ),
                                const Padding(
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
                                  //  controller: _orderIdController, // Assign the controller to the TextFormField
                                  decoration: const InputDecoration(
                                    // labelText: 'Order ID',
                                    hintText: 'Search Order',
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
                            const SizedBox(height: 5),
                            Expanded(child: SingleChildScrollView(child: Column(
                              children: [
                                _loading
                                    ? const Center(child: CircularProgressIndicator(strokeWidth: 4))
                                    : _errorMessage.isNotEmpty
                                    ? Center(child: Text(_errorMessage))
                                    : widget.orderDetails!.isEmpty
                                    ? const Center(child: Text('No product found'))
                                    : ListView.separated(
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
                                        _timer = Timer(const Duration(seconds: 1), () {
                                          setState(() {
                                            _isLoading = false;
                                          });
                                        });
                                        setState(() {
                                          for (int i = 0; i < _isSelected.length; i++) {
                                            _isSelected[i] = i == index;
                                          }
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
                                )
                              ],
                            ),))

                          ],
                        ),
                      ),
                    ),
                    Expanded(child: SingleChildScrollView(child: Stack(
                      children: [
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          child: Padding(
                            padding: const EdgeInsets.only(
                              left: 0,
                            ),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              color: Colors.white,
                              height: 50,
                              child: Row(
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.only(left: 30),
                                    child: Text('Draft ID :',style: TextStyle(fontSize: 19),),
                                  ),
                                  const SizedBox(width:8),
                                  Text((orderIdController.text),style: const TextStyle(fontSize: 19),),
                                  //  Text(orderIdController.text),
                                  const SizedBox(width: 10,),
                                  const Spacer(),
                                  Padding(
                                    padding: const EdgeInsets.only(right: 100),
                                    child: OutlinedButton(
                                      onPressed: () {
                                        //dialog
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
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 0, left: 0),
                          child: Container(
                            margin: const EdgeInsets.symmetric(
                                vertical: 1), // Space above/below the border
                            height: 984,
                            // width: 1500,
                            width:0.5,// Border height
                            color: Colors.black, // Border color
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 49, left: 0),
                          child: Container(
                            margin: const EdgeInsets.symmetric(
                                vertical: 1), // Space above/below the border
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
                            decoration:  BoxDecoration(
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
                            child:  Padding(
                              padding: const EdgeInsets.only(top: 30),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  const Expanded(
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
                                          color:  deliveryStatusController.text == 'Not Started' ||deliveryStatusController.text == 'Picked' ||deliveryStatusController.text == 'Created'
                                              ? Colors.grey
                                              : Colors.green
                                               // default color
                                        ),
                                        Text(
                                          'Delivery',
                                          style: TextStyle(
                                            color: deliveryStatusController.text == 'Not Started' ||deliveryStatusController.text == 'Picked' ||deliveryStatusController.text == 'Created'
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
                                            color:  deliveryStatusController.text == 'Not Started' ||deliveryStatusController.text == 'Picked' ||deliveryStatusController.text == 'Created'
                                                ? Colors.grey
                                                : Colors.green
                                          // default color
                                        ),
                                        Text(
                                          'Invoice',
                                          style: TextStyle(
                                            color: deliveryStatusController.text == 'Not Started' ||deliveryStatusController.text == 'Picked' ||deliveryStatusController.text == 'Created'
                                                ? Colors.grey
                                                : Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Expanded(
                                    flex: 1,
                                    child: Column(
                                      children: [
                                        Icon(
                                          Icons.check_box,
                                          color: Colors.grey,
                                        ),
                                        Text(
                                          'Payments',
                                          style: TextStyle(
                                            color: Colors.grey,
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
                            ? const Padding(
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
                                      border: const TableBorder(
                                        bottom: BorderSide(width:1 ,color: Colors.grey),
                                        //   horizontalInside: BorderSide(width: 1,color: Colors.grey), // horizontal border inside the table
                                        verticalInside: BorderSide(width: 1,color: Colors.grey),
                                      ),
                                      // border: TableBorder.all(
                                      //     color: const Color(0xFFB2C2D3)),
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
                                      // Add this line
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
                                                          .toString(),
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
                                      padding: const EdgeInsets.only(left: 15,right: 10,top: 10,bottom: 2),
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
                      ],
                    ),))
                  ],
                );
              }else{
                return  Stack(

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
                    Container(
                      padding: const EdgeInsets.only(left: 200),
                      child: AdaptiveScrollbar(
                        position: ScrollbarPosition.bottom,controller: horizontalScroll,
                        child: SingleChildScrollView(
                          controller: horizontalScroll,
                          scrollDirection: Axis.horizontal,
                          child: Container(
                            width: 1250,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [

                                Padding(
                                  padding: const EdgeInsets.only(left: 0,top: 0),
                                  child: Container(
                                    width: 1.8, // Set the width to 1 for a vertical line
                                    height: 984, // Set the height to your liking
                                    decoration: const BoxDecoration(
                                      border: Border(left: BorderSide(width: 1, color: Colors.grey)),
                                    ),
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.only(
                                    // top: 60,
                                    left: 1,
                                  ),
                                  width: 298,
                                  height: 928
                                  ,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
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
                                                  context.go('/Customer_Order_List');
                                                },
                                              ),
                                            ),
                                            const Padding(
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
                                              //  controller: _orderIdController, // Assign the controller to the TextFormField
                                              decoration: const InputDecoration(
                                                // labelText: 'Order ID',
                                                hintText: 'Search Order',
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
                                        const SizedBox(height: 5),
                                        Expanded(child: SingleChildScrollView(child: Column(
                                          children: [
                                            _loading
                                                ? const Center(child: CircularProgressIndicator(strokeWidth: 4))
                                                : _errorMessage.isNotEmpty
                                                ? Center(child: Text(_errorMessage))
                                                : widget.orderDetails!.isEmpty
                                                ? const Center(child: Text('No product found'))
                                                : ListView.separated(
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
                                                    _timer = Timer(const Duration(seconds: 1), () {
                                                      setState(() {
                                                        _isLoading = false;
                                                      });
                                                    });
                                                    setState(() {
                                                      for (int i = 0; i < _isSelected.length; i++) {
                                                        _isSelected[i] = i == index;
                                                      }
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
                                            )
                                          ],
                                        ),))

                                      ],
                                    ),
                                  ),
                                ),
                                Expanded(child: SingleChildScrollView(child: Stack(
                                  children: [
                                    Positioned(
                                      top: 0,
                                      left: 0,
                                      right: 0,
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                          left: 0,
                                        ),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 16),
                                          color: Colors.white,
                                          height: 50,
                                          child: Row(
                                            children: [
                                              const Padding(
                                                padding: EdgeInsets.only(left: 30),
                                                child: Text('Draft ID :',style: TextStyle(fontSize: 19),),
                                              ),
                                              const SizedBox(width:8),
                                              Text((orderIdController.text),style: const TextStyle(fontSize: 19),),
                                              //  Text(orderIdController.text),
                                              const SizedBox(width: 10,),
                                              const Spacer(),
                                              Padding(
                                                padding: const EdgeInsets.only(right: 100),
                                                child: OutlinedButton(
                                                  onPressed: () {
                                                    //dialog
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
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 0, left: 0),
                                      child: Container(
                                        margin: const EdgeInsets.symmetric(
                                            vertical: 1), // Space above/below the border
                                        height: 984,
                                        // width: 1500,
                                        width:0.5,// Border height
                                        color: Colors.black, // Border color
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 49, left: 0),
                                      child: Container(
                                        margin: const EdgeInsets.symmetric(
                                            vertical: 1), // Space above/below the border
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
                                        decoration:  BoxDecoration(
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
                                        child:  Padding(
                                          padding: const EdgeInsets.only(top: 30),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                            children: [
                                              const Expanded(
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
                                                      color:  deliveryStatusController.text == 'Not Started' ||deliveryStatusController.text == 'Picked' ||deliveryStatusController.text == 'Created'
                                                          ? Colors.grey
                                                          : Colors.green, // default color
                                                    ),
                                                    Text(
                                                      'Delivery',
                                                      style: TextStyle(
                                                        color:  deliveryStatusController.text == 'Not Started' ||deliveryStatusController.text == 'Picked' ||deliveryStatusController.text == 'Created'
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
                                                      color:  deliveryStatusController.text == 'Not Started' ||deliveryStatusController.text == 'Picked' ||deliveryStatusController.text == 'Created'
                                                          ? Colors.grey
                                                          : Colors.green, // default color
                                                    ),
                                                    Text(
                                                      'Invoice',
                                                      style: TextStyle(
                                                        color:  deliveryStatusController.text == 'Not Started' ||deliveryStatusController.text == 'Picked' ||deliveryStatusController.text == 'Created'
                                                            ? Colors.grey
                                                            : Colors.black,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const Expanded(
                                                flex: 1,
                                                child: Column(
                                                  children: [
                                                    Icon(
                                                      Icons.check_box,
                                                      color: Colors.grey,
                                                    ),
                                                    Text(
                                                      'Payments',
                                                      style: TextStyle(
                                                        color: Colors.grey,
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
                                        ? const Padding(
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
                                                  border: const TableBorder(
                                                    bottom: BorderSide(width:1 ,color: Colors.grey),
                                                    //   horizontalInside: BorderSide(width: 1,color: Colors.grey), // horizontal border inside the table
                                                    verticalInside: BorderSide(width: 1,color: Colors.grey),
                                                  ),
                                                  // border: TableBorder.all(
                                                  //     color: const Color(0xFFB2C2D3)),
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
                                                  // Add this line
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
                                                                      .toString(),
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
                                                  padding: const EdgeInsets.only(left: 15,right: 10,top: 10,bottom: 2),
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
                                  ],
                                ),))
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }

            }
        )
    );
  }

  void _showProductDetails(OrderDetail orderDetails) {
    print('Selected Order:');
    print('Order ID: ${orderDetails.orderId}');
    print('Order Date: ${orderDetails.orderDate}');
    print('Contact Person: ${orderDetails.contactPerson}');
    print('Delivery Location: ${orderDetails.deliveryLocation}');
    print('total: ${orderDetails.total}');


    EmailIdController.text = orderDetails.deliveryLocation!;
    print ('--------deliver');
    print(data2['deliveryLocation']);

    print(productNameController.text);
    CreatedDateController.text = orderDetails.orderDate!;
    orderIdController.text = orderDetails.orderId!;
    deliveryLocationController.text = orderDetails.deliveryLocation!;
    contactPersonController.text = orderDetails.contactPerson!;
    deliveryAddressController.text = orderDetails.deliveryAddress!;

    contactNumberController.text = orderDetails.contactNumber!;
    commentsController.text = orderDetails.comments!;
    totalController.text = orderDetails.total.toString();
    // contactPersonController.text = orderDetails.orderDate;
    deliveryLocationController.text = orderDetails.deliveryLocation!;
    print('------------devli');
    print(data2['deliveryLocation']);

    setState(() {
      selectedItems = List<Map<String, dynamic>>.from(orderDetails.items);
    });

    print('Selected Order:');
    deliveryStatusController.text = orderDetails.status!;
    print('Order ID: ${orderDetails.orderId}');
    print('Order Date: ${orderDetails.orderDate}');
    print('Contact Person: ${orderDetails.contactPerson}');
    print('Delivery Location: ${orderDetails.deliveryLocation}');
    print('total: ${orderDetails.total}');

    for (var item in selectedItems) {
      print('Product Name: ${item['productName']}');
      print('Price: ${item['price']}');
      print('Quantity: ${item['qty']}');
      print('Category: ${item['category']}');
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
}
double calculateTotalAmount(Map<String, dynamic> item) {
  double price = item['price'];
  int qty = item['qty'];
  double totalAmount = price * qty;
  return item['totalAmount'] = totalAmount;
}

