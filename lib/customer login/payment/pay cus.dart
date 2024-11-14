import 'dart:async';
import 'dart:html';
import 'dart:math';
import 'package:adaptive_scrollbar/adaptive_scrollbar.dart';
import 'package:btb/Order%20Module/firstpage.dart';
import 'package:btb/admin/Api%20name.dart';
import 'package:btb/widgets/confirmdialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:confetti/confetti.dart';
void main(){
  runApp(const MaterialApp(home:  CusPayment(productMap: {},),)
  );
}
class CusPayment extends StatefulWidget {
  final Map<String, dynamic> productMap;
  const CusPayment({super.key,required this.productMap,});
  @override
  _CusPaymentState createState() => _CusPaymentState();

}
class _CusPaymentState extends State<CusPayment> {
  final ScrollController horizontalScroll = ScrollController();
  String? _selectedReason = 'Payment mode';
  String userId = window.sessionStorage['userId'] ?? '';
  final _reasonController = TextEditingController();
  DateTime? selectedDate;
  String token = window.sessionStorage["token"] ?? " ";
  final List<String> list = ['UPI', 'Credit/Debit Card', 'Cash'];
  Map<String, dynamic> data2 = {};
  bool isEditing = false;

  String status = '';
  bool isLoading = false;
  int itemsPerPage = 10;
  int currentPage = 1;
  String _searchText = '';

  String selectDate = '';
  int totalItems = 0;
  int totalPages = 0;
  List<Map<String, dynamic>> selectedItems = [];
  final TextEditingController orderIdController = TextEditingController();
  bool _isLoading = false;
  final TextEditingController PayableController = TextEditingController();
  final TextEditingController PaidController = TextEditingController();
  List<Map<String, dynamic>> _sortedOrders = [];
  late TextEditingController _dateController;
  final TextEditingController InvController = TextEditingController();
  final TextEditingController GrossAmountController = TextEditingController();
  late TextEditingController AmountController = TextEditingController();
  bool isOrdersSelected = false;
  String _errorMessage = '';
  List<detail> productList = [];
  late ConfettiController _confettiController;
  bool _isReasonEnabled = false;
  List<detail>filteredData = [];
  bool _isFirstMove = true;


  Map<String, bool> _isHovered = {
    'Orders': false,
    'Invoice': false,
    'Delivery': false,
    'Payment': false,
    'Return': false,
    'Credit Notes': false,
  };


  List<Widget> _buildMenuItems(BuildContext context) {
    return [
      _buildMenuItem('Orders', Icons.warehouse, Colors.blue[900]!, '/Customer_Order_List'),
      _buildMenuItem('Invoice', Icons.document_scanner_rounded, Colors.blue[900]!, '/Customer_Invoice_List'),
      _buildMenuItem('Delivery', Icons.fire_truck_outlined, Colors.blue[900]!, '/Customer_Delivery_List'),
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
    ),child: _buildMenuItem('Payment', Icons.payment_outlined, Colors.white, '/Customer_Payment_List')),
      _buildMenuItem('Return', Icons.keyboard_return, Colors.blue[900]!, '/Customer_Return_List'),
      // _buildMenuItem('Credit Notes', Icons.credit_card_outlined, Colors.blue[900]!, '/Customer_Credit_List'),
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

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));

    if (widget.productMap != null) {
      if (widget.productMap['paymentStatus'] == 'partial payment') {
        _initPartialPaymentFields();
      } else if (widget.productMap['paymentStatus'] == 'cleared') {
        _initClearedFields();
      } else {
        _initDefaultFields();
      }
    }
  }

  void _initPartialPaymentFields() {
    if (widget.productMap['orderId'] != null) {
      fetchProducts(widget.productMap['orderId'] ?? '');
    }
    GrossAmountController.text = _formatAmount(widget.productMap['grossAmount']);
    InvController.text = widget.productMap['invoiceNo'] ?? '';
    PaidController.text = widget.productMap['paidAmount'] ?? '';
    PayableController.text = _formatAmount(widget.productMap['payableAmount']);
    AmountController.text = PayableController.text;
  }

  void _initClearedFields() {
    if (widget.productMap['orderId'] != null) {
      fetchProducts(widget.productMap['orderId'] ?? '');
    }
    GrossAmountController.text = _formatAmount(widget.productMap['grossAmount']);
    InvController.text = widget.productMap['invoiceNo'] ?? '';
    PaidController.text = widget.productMap['paidAmount'] ?? '';
    PayableController.text = _formatAmount(widget.productMap['payableAmount']);
    AmountController.text = PayableController.text;
  }

  void _initDefaultFields() {
    GrossAmountController.text = _formatAmount(widget.productMap['grossAmount']);
    InvController.text = widget.productMap['invoiceNo'] ?? '';
    PaidController.text = widget.productMap['paidAmount'] ?? '';
    PayableController.text = _formatAmount(widget.productMap['payableAmount']);
    AmountController.text = GrossAmountController.text;
  }

  String _formatAmount(String? amount) {
    if (amount != null) {
      return double.parse(amount).toStringAsFixed(2);
    } else {
      return '';
    }
  }




  @override
  void dispose() {
    _confettiController.dispose();
    _dateController.dispose();
    GrossAmountController.dispose();
    PayableController.dispose();
    InvController.dispose();
    PaidController.dispose();
    AmountController.dispose();
    super.dispose();
  }

  void _filterAndPaginateProducts() {
    filteredData = productList.where((product) {
      final matchesSearchText= product.orderId!.toLowerCase().contains(_searchText.toLowerCase());
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

  Future<void> fetchProducts(String orderId) async {
    String? orderId = widget.productMap['orderId'] ?? '';

    if (isLoading) return;
    if (!mounted) return;
    setState(() {
      isLoading = true;
    });
    try {
      final response = await http.get(
        Uri.parse(
          '$apicall/payment_master/get_all_transactionmaster/${orderId}',
          // Changed limit to 10
        ),
        headers: {
          "Content-type": "application/json",
          "Authorization": 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
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
              productList = products;
              _filterAndPaginateProducts();
            });
          }
        }
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      // Optionally, show an error message to the user
    } finally {
      if(mounted){
        setState(() {
          isLoading = false;
        });
      }

    }
  }

  Future<void> checkPayment(String Amount) async {

    String url = "$apicall/payment_master/add_payment_master/$Amount";
    Map<String, dynamic> data = {
      "grossAmount": GrossAmountController.text,
      "invoice": InvController.text,
      "paymentMode": _selectedReason,
      "userId": userId
    };

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token'
    };

    final response = await http.post(Uri.parse(url), headers: headers, body: jsonEncode(data));

    if (response.statusCode == 200) {
      // Parse response body
      final addResponseBody = jsonDecode(response.body);

      if (addResponseBody['status'] == 'success') {
        // Payment successful
        showDialog(
          barrierDismissible: false,
          context: context,
          builder: (BuildContext context) {
            return Stack(
                children:[
                  Positioned(
                    top: 0, // Adjust for top placement
                    left: 0,
                    right: 0,
                    child: Align(
                      alignment: Alignment.topCenter, // Center the confetti at the top
                      child: ConfettiWidget(
                        confettiController: _confettiController,
                        blastDirection: pi / 2, // Blast downwards
                        emissionFrequency: 0.05,
                        numberOfParticles: 30,
                        gravity: 0.3,
                        colors: const [Colors.red, Colors.blue, Colors.green, Colors.yellow],
                      ),
                    ),
                  ),
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
                              const Icon(Icons.check_circle_rounded, color: Colors.green, size: 50),
                              const SizedBox(height: 16),
                              const Text(
                                'Payment Received Successfully',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      context.go('/Customer_Payment_List');
                                      // Navigator.push(
                                      //   context,
                                      //   PageRouteBuilder(
                                      //     pageBuilder: (context, animation, secondaryAnimation) => PaymentList(),
                                      //     transitionDuration: const Duration(milliseconds: 50),
                                      //     transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                      //       return FadeTransition(opacity: animation, child: child);
                                      //     },
                                      //   ),
                                      // );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue,
                                      side: const BorderSide(color: Colors.blue),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10.0),
                                      ),
                                    ),
                                    child: const Text('OK', style: TextStyle(color: Colors.white)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ]
            );
          },
        );
        _confettiController.play();
      } else if (addResponseBody['status'] == 'failure') {
        // Payment failed due to exceeding amount
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Paid amount exceeds the gross amount.'),
          ),
        );
      } else {
        // Handle other cases
      }
    } else {
      // If the response code is not 200, print the error
    }
  }


  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
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
                      padding: const EdgeInsets.only(left: 15, top: 10,right: 15),
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
                  Expanded(
                      child:
                      SingleChildScrollView(
                        child:
                        Stack(
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
                                    IconButton(
                                      icon: const Icon(
                                          Icons.arrow_back), // Back button icon
                                      onPressed: () {
                                        context.go('/Customer_Payment_List');
                                        // Navigator.of(context).push(PageRouteBuilder(
                                        //   pageBuilder: (context, animation,
                                        //       secondaryAnimation) =>
                                        //       const ProductPage(product: null),
                                        // ));
                                      },
                                    ),
                                    const Padding(
                                      padding: EdgeInsets.only(left: 10),
                                      child: Text('Payment ',style: TextStyle(fontSize: 19),),
                                    ),
                                    const SizedBox(width:8),
                                    Text((orderIdController.text),style: const TextStyle(fontSize: 19),),
                                    //  Text(orderIdController.text),
                                    const SizedBox(width: 10,),
                                    const Spacer(),
                                    //     deliveryStatusController.text == 'Delivered' ||deliveryStatusController.text == 'In Progress' ? Container():
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
                            if(constraints.maxWidth >= 1200)...{
                              Padding(
                                padding: const EdgeInsets.only(top:
                                70,left: 20,right:20),
                                child:

                                Container(

                                  child: Column(children:
                                  [
                                    Padding(
                                      padding: const EdgeInsets.only(left: 90, top: 30,right: 120),
                                      child: Container(
                                        height: 100,
                                        width: maxWidth,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFFFFFF), // background: #FFFFFF
                                          boxShadow: [const BoxShadow(
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
                                          padding: const EdgeInsets.only(top: 10),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                            children: [
                                              Expanded(
                                                flex: 1,
                                                child: Column(
                                                  children: [

                                                    const Text(
                                                      'Total Amount To Pay',
                                                      style: TextStyle(
                                                          color: Colors.black,fontSize: 25
                                                      ),
                                                    ),
                                                    const SizedBox(height: 10,),
                                                    ValueListenableBuilder(
                                                        valueListenable: GrossAmountController,
                                                        builder: (context,value,child) {
                                                          return Text(
                                                            '${widget.productMap['paymentStatus'] == 'partial payment'? PayableController.text : GrossAmountController.text } INR',
                                                            // '${AmountController.text}  INR',
                                                            style: const TextStyle(
                                                                color: Colors.black,
                                                                fontSize: 20
                                                            ),
                                                          );
                                                        }
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
                                      padding: const EdgeInsets.only(top: 70,left: 50,right: 50),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Column(
                                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                            children: [
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [

                                                  Text('${widget.productMap['invoiceNo']}',style: const TextStyle(fontSize: 20,),),

                                                  widget.productMap['paymentStatus'] == 'cleared'
                                                      ? Container()
                                                      : SizedBox(
                                                    width:80,
                                                    height: 30,
                                                    child:
                                                    OutlinedButton(
                                                      //   autofocus: widget.productMap['paymentStatus']  != 'cleared',
                                                      // onPressed: handleButtonPress,
                                                      //my copy
                                                        onPressed: (){
                                                          if( _selectedReason == null || _selectedReason!.isEmpty ||  _selectedReason == 'Payment mode'){
                                                            ScaffoldMessenger.of(context).showSnackBar(
                                                              const SnackBar(
                                                                content: Text('Please Select Payment Mode'),
                                                                //  backgroundColor: Colors.red,
                                                              ),
                                                            );
                                                          }
                                                          else if (AmountController.text.isEmpty || double.tryParse(AmountController.text) == null || double.tryParse(AmountController.text)! <= 0) {
                                                            ScaffoldMessenger.of(context).showSnackBar(
                                                              const SnackBar(
                                                                content: Text('Please Enter Valid Amount'),
                                                              ),
                                                            );
                                                          }
                                                          else{
                                                            checkPayment(AmountController.text);
                                                          }

                                                        },
                                                        style: OutlinedButton.styleFrom(
                                                          backgroundColor: Colors.white,
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius: BorderRadius.circular(8),
                                                          ),
                                                          side: const BorderSide(color: Colors.blue),
                                                          padding: EdgeInsets.zero,
                                                        ),
                                                        child: Row(
                                                          mainAxisAlignment: MainAxisAlignment.start,
                                                          // mainAxisSize: MainAxisSize.min,
                                                          //crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            TextButton.icon(
                                                              onPressed: () {
                                                                if( _selectedReason == null || _selectedReason!.isEmpty ||  _selectedReason == 'Payment mode'){
                                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                                    const SnackBar(
                                                                      content: Text('Please Select Payment Mode'),
                                                                      //  backgroundColor: Colors.red,
                                                                    ),
                                                                  );
                                                                }
                                                                else if (AmountController.text.isEmpty || double.tryParse(AmountController.text) == null || double.tryParse(AmountController.text)! <= 0) {
                                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                                    const SnackBar(
                                                                      content: Text('Please Enter Valid Amount'),
                                                                    ),
                                                                  );
                                                                }
                                                                else{
                                                                  checkPayment(AmountController.text);
                                                                }
                                                              },
                                                              icon: const Icon(Icons.account_balance_wallet, color: Colors.blue, size: 18),
                                                              label: const Text(
                                                                'Pay',
                                                                style: TextStyle(color: Colors.blue),
                                                              ),
                                                            )

                                                          ],
                                                        )

                                                    ),
                                                  ) ,

                                                ],),

                                            ],
                                          ),


                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 50,right: 50,top: 30),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(color: Colors.grey),
                                          borderRadius: BorderRadius.circular(8),
                                          boxShadow: const [
                                            BoxShadow(
                                              color: Color(0xff00000029),
                                              offset: Offset(0, 3),
                                              blurRadius: 6,
                                            ),
                                          ],
                                          color: const Color(0xFFFFFFFF),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(16.0),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  // const SizedBox(width: 16),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        const Row(
                                                          mainAxisSize: MainAxisSize.min,
                                                          children: [
                                                            Padding(
                                                              padding:  EdgeInsets.only(bottom: 13),
                                                              child: Text('Payment Mode',),
                                                            ),

                                                          ],
                                                        ),
                                                        //  const SizedBox(height: 5,),
                                                        Padding( padding: const EdgeInsets.only(bottom: 8),
                                                          child: SizedBox(
                                                            height: 35,
                                                            child: DropdownButtonFormField<String>(
                                                              decoration: InputDecoration(
                                                                filled: true,
                                                                fillColor: Colors.grey.shade200,
                                                                border: OutlineInputBorder(
                                                                  borderRadius: BorderRadius.circular(5.0),
                                                                  borderSide: BorderSide.none, // Remove border by setting borderSide to BorderSide.none
                                                                ),
                                                                contentPadding: const EdgeInsets.symmetric(
                                                                    horizontal: 8, vertical: 8),
                                                              ),

                                                              value: _selectedReason,
                                                              onChanged: (String? value) {
                                                                setState(() {
                                                                  _selectedReason = value!;
                                                                  _reasonController.text = value;
                                                                });
                                                              },
                                                              items:<String>['Payment mode', 'UPI', 'Credit/Debit Card', 'Cash'].map<DropdownMenuItem<String>>((String value) {
                                                                return DropdownMenuItem<String>(
                                                                  enabled: widget.productMap['paymentStatus']  != 'cleared',
                                                                  value: value,
                                                                  child: Text(value,style: TextStyle(color: value == 'Reason for return' ? Colors.grey : Colors.grey,),),
                                                                );
                                                              }).toList(),
                                                              isExpanded: true,
                                                              //     hint: const Text('Reason for return'),
                                                            ),
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                  const SizedBox(width: 36),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        const Row(
                                                          mainAxisSize: MainAxisSize.min,
                                                          children: [
                                                            Text('Gross Amount'),

                                                          ],
                                                        ),
                                                        const SizedBox(height: 5,),
                                                        Padding(
                                                          padding: const EdgeInsets.only(top: 13),
                                                          child: SizedBox(
                                                            height: 40,
                                                            child:  Text(GrossAmountController.text,style: const TextStyle(color: Colors.grey),),
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
                                                        const Row(
                                                          mainAxisSize: MainAxisSize.min,
                                                          children: [
                                                            Text('Paid Amount'),

                                                          ],
                                                        ),
                                                        const SizedBox(height: 5,),
                                                        Padding(
                                                          padding: const EdgeInsets.only(top: 13),
                                                          child: SizedBox(
                                                            height: 40,
                                                            child:  Text(PaidController.text,style: const TextStyle(color: Colors.grey),),

                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                  const SizedBox(width: 16),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        const Row(
                                                          mainAxisSize: MainAxisSize.min,
                                                          children: [
                                                            Text('Remaining Amount'),

                                                          ],
                                                        ),
                                                        const SizedBox(height: 5,),
                                                        Padding(
                                                          padding: const EdgeInsets.only(top: 13),
                                                          child: SizedBox(
                                                            height: 40,
                                                            child:  Text(PayableController.text,style: const TextStyle(color: Colors.grey),),
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                  const SizedBox(width: 16),
                                                  // Expanded(
                                                  //   child: Column(
                                                  //     crossAxisAlignment: CrossAxisAlignment.start,
                                                  //     children: [
                                                  //       const Row(
                                                  //         mainAxisSize: MainAxisSize.min,
                                                  //         children: [
                                                  //           Padding(
                                                  //             padding: const EdgeInsets.only(bottom: 13),
                                                  //             child: Text('Credit Amount',),
                                                  //           ),
                                                  //
                                                  //         ],
                                                  //       ),
                                                  //       //  const SizedBox(height: 5,),
                                                  //       Padding( padding: const EdgeInsets.only(bottom: 8),
                                                  //         child: SizedBox(
                                                  //           height: 35,
                                                  //           child: DropdownButtonFormField<String>(
                                                  //             decoration: InputDecoration(
                                                  //               filled: true,
                                                  //               fillColor: Colors.grey.shade200,
                                                  //               border: OutlineInputBorder(
                                                  //                 borderRadius: BorderRadius.circular(5.0),
                                                  //                 borderSide: BorderSide.none, // Remove border by setting borderSide to BorderSide.none
                                                  //               ),
                                                  //               contentPadding: const EdgeInsets.symmetric(
                                                  //                   horizontal: 8, vertical: 8),
                                                  //             ),
                                                  //             value: _selectedReason,
                                                  //             onChanged: (String? value) {
                                                  //               setState(() {
                                                  //                 _selectedReason = value!;
                                                  //                 _reasonController.text = value;
                                                  //               });
                                                  //             },
                                                  //             items:<String>['Credit Amount', 'UPI', 'Credit/Debit Card', 'Cash'].map<DropdownMenuItem<String>>((String value) {
                                                  //               return DropdownMenuItem<String>(
                                                  //                 value: value,
                                                  //                 child: Text(value,style: TextStyle(color: value == 'Reason for return' ? Colors.grey : Colors.grey,),),
                                                  //               );
                                                  //             }).toList(),
                                                  //             isExpanded: true,
                                                  //             //     hint: const Text('Reason for return'),
                                                  //           ),
                                                  //         ),
                                                  //       )
                                                  //     ],
                                                  //   ),
                                                  // ),
                                                  // const SizedBox(width: 16),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        const Row(
                                                          mainAxisSize: MainAxisSize.min,
                                                          children: [
                                                            Padding(
                                                              padding:  EdgeInsets.only(bottom: 13),
                                                              child: Text('Amount to Pay'),
                                                            ),
                                                          ],
                                                        ),
                                                        Padding(
                                                          padding: const EdgeInsets.only(bottom: 8),
                                                          child: SizedBox(
                                                            height: 35,
                                                            child:
                                                            TextFormField(
                                                              enabled: widget.productMap['paymentStatus']  != 'cleared',
                                                              controller: AmountController,
                                                              //controller: AmountController =widget.productMap['paymentStatus'] == 'partial payment' ? PayableController :GrossAmountController ,
                                                              decoration: InputDecoration(
                                                                filled: true,
                                                                fillColor: Colors.grey.shade200,
                                                                border: OutlineInputBorder(
                                                                  borderRadius: BorderRadius.circular(5.0),
                                                                  borderSide: BorderSide.none,
                                                                ),
                                                                contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                                                                hintText: 'Enter Amount',
                                                                // errorText: _errorText,
                                                              ),
                                                              inputFormatters: [
                                                                FilteringTextInputFormatter.allow(RegExp("[a-zA-Z,0-9,@.]")),
                                                                FilteringTextInputFormatter.deny(RegExp(r'^\s')),
                                                                FilteringTextInputFormatter.deny(RegExp(r'\s\s')),
                                                              ],
                                                              // onChanged: (value){
                                                              //   AmountController.text = value;
                                                              // },
                                                            ),
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 50, top: 70,right: 50,bottom: 10),
                                      child: Container(
                                        // decoration: BoxDecoration(
                                        //   border: Border.all(color: Colors.grey),
                                        //   borderRadius: BorderRadius.circular(8),
                                        //   boxShadow: const [
                                        //     BoxShadow(
                                        //       color: Color(0xff00000029),
                                        //       offset: Offset(0, 3),
                                        //       blurRadius: 6,
                                        //     ),
                                        //   ],
                                        //   color: const Color(0xFFFFFFFF),
                                        // ),
                                          child: Column(
                                            children: [
                                              const Row(
                                                children: [
                                                  Text('Payment History',style: TextStyle(fontWeight: FontWeight.bold),),
                                                ],
                                              ),
                                              SizedBox(height: 20,),
                                              Container(
                                                width: maxWidth,
                                                decoration: BoxDecoration(
                                                  border: Border.all(color: Colors.grey),
                                                  borderRadius: BorderRadius.circular(8),
                                                  boxShadow: const [
                                                    BoxShadow(
                                                      color: Color(0xff00000029),
                                                      offset: Offset(0, 3),
                                                      blurRadius: 6,
                                                    ),
                                                  ],
                                                  color: const Color(0xFFFFFFFF),
                                                ),
                                                child: Padding(
                                                  padding: const EdgeInsets.only(),
                                                  child: DataTable(
                                                    showCheckboxColumn: false,
                                                    headingRowHeight: 40,
                                                    columns: [
                                                      //DataColumn(label: Container(child: Text('      '))),
                                                      DataColumn(
                                                        label: Padding(
                                                          padding: const EdgeInsets.only(left: 10),
                                                          child: Text(
                                                            'Payment ID',
                                                            style: TextStyle(
                                                              color: Colors.indigo[900],
                                                              fontSize: 13,
                                                              fontWeight: FontWeight.bold,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      DataColumn(
                                                        label: Padding(
                                                          padding: const EdgeInsets.only(left: 5),
                                                          child: Text(
                                                            'Payment Date',
                                                            style: TextStyle(
                                                              color: Colors.indigo[900],
                                                              fontSize: 13,
                                                              fontWeight: FontWeight.bold,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      DataColumn(
                                                        label: Text(
                                                          'Payment Mode',
                                                          style: TextStyle(
                                                            color: Colors.indigo[900],
                                                            fontSize: 13,
                                                            fontWeight: FontWeight.bold,
                                                          ),
                                                        ),
                                                      ),
                                                      DataColumn(
                                                        label: Text(
                                                          'Paid Amount',
                                                          style: TextStyle(
                                                            color: Colors.indigo[900],
                                                            fontSize: 13,
                                                            fontWeight: FontWeight.bold,
                                                          ),
                                                        ),
                                                      ),
                                                      DataColumn(
                                                        label: Text(
                                                          'Paid By',
                                                          style: TextStyle(
                                                            color: Colors.indigo[900],
                                                            fontSize: 13,
                                                            fontWeight: FontWeight.bold,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                    rows: List.generate(filteredData.length, (index){
                                                      final detail = filteredData.elementAt(index);
                                                      return DataRow(
                                                          color: MaterialStateProperty.resolveWith<Color>((states) {
                                                            if (states.contains(MaterialState.hovered)) {
                                                              return Colors.blue.shade500.withOpacity(0.8); // Dark blue with opacity
                                                            }  else {
                                                              return Colors.white.withOpacity(0.9);
                                                            }
                                                          }
                                                          ),
                                                          cells: [
                                                            DataCell(
                                                              Padding(
                                                                padding: const EdgeInsets.only(left: 5),
                                                                child: Text(detail.transactionsId!),
                                                              ),
                                                            ),
                                                            DataCell(
                                                              Padding(
                                                                padding: const EdgeInsets.only(left: 5),
                                                                child: Text(detail.paymentDate!),
                                                              ),
                                                            ),
                                                            DataCell(
                                                              Padding(
                                                                padding: const EdgeInsets.only(left: 5),
                                                                child: Text(detail.paymentMode!),
                                                              ),
                                                            ),
                                                            DataCell(
                                                              Padding(
                                                                padding: const EdgeInsets.only(left: 5),
                                                                child: Text(detail.exactPaidAmount!.toStringAsFixed(2)),
                                                              ),
                                                            ),
                                                            DataCell(
                                                              Padding(
                                                                padding: const EdgeInsets.only(left: 5),
                                                                child: Text(detail.paidBy!),
                                                              ),
                                                            ),
                                                          ]
                                                      );
                                                    }),

                                                  ),
                                                ),
                                              ),
                                            ],
                                          )
                                      ),
                                    ),
                                  ],),
                                ),
                              ),
                            }else...{
                              Padding(
                                                              padding: const EdgeInsets.only(top:
                                                              70,left: 20,right:20),
                                                              child:

                                                              AdaptiveScrollbar(
                              position: ScrollbarPosition.bottom,controller: horizontalScroll,
                              child: SingleChildScrollView(
                                controller: horizontalScroll,
                                scrollDirection: Axis.horizontal,
                                child: Container(
                                  width: 1700,

                                  child: Column(children:
                                  [
                                    Padding(
                                      padding: const EdgeInsets.only(left: 90, top: 30,right: 120),
                                      child: Container(
                                        height: 100,
                                        width: 1400,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFFFFFF), // background: #FFFFFF
                                          boxShadow: [const BoxShadow(
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
                                          padding: const EdgeInsets.only(top: 10),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                            children: [
                                              Expanded(
                                                flex: 1,
                                                child: Column(
                                                  children: [

                                                    const Text(
                                                      'Total Amount To Pay',
                                                      style: TextStyle(
                                                          color: Colors.black,fontSize: 25
                                                      ),
                                                    ),
                                                    const SizedBox(height: 10,),
                                                    ValueListenableBuilder(
                                                        valueListenable: GrossAmountController,
                                                        builder: (context,value,child) {
                                                          return Text(
                                                            '${widget.productMap['paymentStatus'] == 'partial payment'? PayableController.text : GrossAmountController.text } INR',
                                                            // '${AmountController.text}  INR',
                                                            style: const TextStyle(
                                                                color: Colors.black,
                                                                fontSize: 20
                                                            ),
                                                          );
                                                        }
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
                                      padding: const EdgeInsets.only(top: 70,left: 50,right: 50),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Column(
                                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                            children: [
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [

                                                  Text('${widget.productMap['invoiceNo']}',style: const TextStyle(fontSize: 20,),),

                                                  widget.productMap['paymentStatus'] == 'cleared'
                                                      ? Container()
                                                      : SizedBox(
                                                    width:80,
                                                    height: 30,
                                                    child:
                                                    OutlinedButton(
                                                      //   autofocus: widget.productMap['paymentStatus']  != 'cleared',
                                                      // onPressed: handleButtonPress,
                                                      //my copy
                                                        onPressed: (){
                                                          if( _selectedReason == null || _selectedReason!.isEmpty ||  _selectedReason == 'Payment mode'){
                                                            ScaffoldMessenger.of(context).showSnackBar(
                                                              const SnackBar(
                                                                content: Text('Please Select Payment Mode'),
                                                                //  backgroundColor: Colors.red,
                                                              ),
                                                            );
                                                          }
                                                          else if (AmountController.text.isEmpty || double.tryParse(AmountController.text) == null || double.tryParse(AmountController.text)! <= 0) {
                                                            ScaffoldMessenger.of(context).showSnackBar(
                                                              const SnackBar(
                                                                content: Text('Please Enter Valid Amount'),
                                                              ),
                                                            );
                                                          }
                                                          else{
                                                            checkPayment(AmountController.text);
                                                          }

                                                        },
                                                        style: OutlinedButton.styleFrom(
                                                          backgroundColor: Colors.white,
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius: BorderRadius.circular(8),
                                                          ),
                                                          side: const BorderSide(color: Colors.blue),
                                                          padding: EdgeInsets.zero,
                                                        ),
                                                        child: Row(
                                                          mainAxisAlignment: MainAxisAlignment.start,
                                                          // mainAxisSize: MainAxisSize.min,
                                                          //crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            TextButton.icon(
                                                              onPressed: () {
                                                                if( _selectedReason == null || _selectedReason!.isEmpty ||  _selectedReason == 'Payment mode'){
                                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                                    const SnackBar(
                                                                      content: Text('Please Select Payment Mode'),
                                                                      //  backgroundColor: Colors.red,
                                                                    ),
                                                                  );
                                                                }
                                                                else if (AmountController.text.isEmpty || double.tryParse(AmountController.text) == null || double.tryParse(AmountController.text)! <= 0) {
                                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                                    const SnackBar(
                                                                      content: Text('Please Enter Valid Amount'),
                                                                    ),
                                                                  );
                                                                }
                                                                else{
                                                                  checkPayment(AmountController.text);
                                                                }
                                                              },
                                                              icon: const Icon(Icons.account_balance_wallet, color: Colors.blue, size: 18),
                                                              label: const Text(
                                                                'Pay',
                                                                style: TextStyle(color: Colors.blue),
                                                              ),
                                                            )

                                                          ],
                                                        )

                                                    ),
                                                  ) ,

                                                ],),

                                            ],
                                          ),


                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 50,right: 50,top: 30),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(color: Colors.grey),
                                          borderRadius: BorderRadius.circular(8),
                                          boxShadow: const [
                                            BoxShadow(
                                              color: Color(0xff00000029),
                                              offset: Offset(0, 3),
                                              blurRadius: 6,
                                            ),
                                          ],
                                          color: const Color(0xFFFFFFFF),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(16.0),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  // const SizedBox(width: 16),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        const Row(
                                                          mainAxisSize: MainAxisSize.min,
                                                          children: [
                                                            Padding(
                                                              padding:  EdgeInsets.only(bottom: 13),
                                                              child: Text('Payment Mode',),
                                                            ),

                                                          ],
                                                        ),
                                                        //  const SizedBox(height: 5,),
                                                        Padding( padding: const EdgeInsets.only(bottom: 8),
                                                          child: SizedBox(
                                                            height: 35,
                                                            child: DropdownButtonFormField<String>(
                                                              decoration: InputDecoration(
                                                                filled: true,
                                                                fillColor: Colors.grey.shade200,
                                                                border: OutlineInputBorder(
                                                                  borderRadius: BorderRadius.circular(5.0),
                                                                  borderSide: BorderSide.none, // Remove border by setting borderSide to BorderSide.none
                                                                ),
                                                                contentPadding: const EdgeInsets.symmetric(
                                                                    horizontal: 8, vertical: 8),
                                                              ),

                                                              value: _selectedReason,
                                                              onChanged: (String? value) {
                                                                setState(() {
                                                                  _selectedReason = value!;
                                                                  _reasonController.text = value;
                                                                });
                                                              },
                                                              items:<String>['Payment mode', 'UPI', 'Credit/Debit Card', 'Cash'].map<DropdownMenuItem<String>>((String value) {
                                                                return DropdownMenuItem<String>(
                                                                  enabled: widget.productMap['paymentStatus']  != 'cleared',
                                                                  value: value,
                                                                  child: Text(value,style: TextStyle(color: value == 'Reason for return' ? Colors.grey : Colors.grey,),),
                                                                );
                                                              }).toList(),
                                                              isExpanded: true,
                                                              //     hint: const Text('Reason for return'),
                                                            ),
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                  const SizedBox(width: 36),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        const Row(
                                                          mainAxisSize: MainAxisSize.min,
                                                          children: [
                                                            Text('Gross Amount'),

                                                          ],
                                                        ),
                                                        const SizedBox(height: 5,),
                                                        Padding(
                                                          padding: const EdgeInsets.only(top: 13),
                                                          child: SizedBox(
                                                            height: 40,
                                                            child:  Text(GrossAmountController.text,style: const TextStyle(color: Colors.grey),),
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
                                                        const Row(
                                                          mainAxisSize: MainAxisSize.min,
                                                          children: [
                                                            Text('Paid Amount'),

                                                          ],
                                                        ),
                                                        const SizedBox(height: 5,),
                                                        Padding(
                                                          padding: const EdgeInsets.only(top: 13),
                                                          child: SizedBox(
                                                            height: 40,
                                                            child:  Text(PaidController.text,style: const TextStyle(color: Colors.grey),),

                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                  const SizedBox(width: 16),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        const Row(
                                                          mainAxisSize: MainAxisSize.min,
                                                          children: [
                                                            Text('Remaining Amount'),

                                                          ],
                                                        ),
                                                        const SizedBox(height: 5,),
                                                        Padding(
                                                          padding: const EdgeInsets.only(top: 13),
                                                          child: SizedBox(
                                                            height: 40,
                                                            child:  Text(PayableController.text,style: const TextStyle(color: Colors.grey),),
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                  const SizedBox(width: 16),
                                                  // Expanded(
                                                  //   child: Column(
                                                  //     crossAxisAlignment: CrossAxisAlignment.start,
                                                  //     children: [
                                                  //       const Row(
                                                  //         mainAxisSize: MainAxisSize.min,
                                                  //         children: [
                                                  //           Padding(
                                                  //             padding: const EdgeInsets.only(bottom: 13),
                                                  //             child: Text('Credit Amount',),
                                                  //           ),
                                                  //
                                                  //         ],
                                                  //       ),
                                                  //       //  const SizedBox(height: 5,),
                                                  //       Padding( padding: const EdgeInsets.only(bottom: 8),
                                                  //         child: SizedBox(
                                                  //           height: 35,
                                                  //           child: DropdownButtonFormField<String>(
                                                  //             decoration: InputDecoration(
                                                  //               filled: true,
                                                  //               fillColor: Colors.grey.shade200,
                                                  //               border: OutlineInputBorder(
                                                  //                 borderRadius: BorderRadius.circular(5.0),
                                                  //                 borderSide: BorderSide.none, // Remove border by setting borderSide to BorderSide.none
                                                  //               ),
                                                  //               contentPadding: const EdgeInsets.symmetric(
                                                  //                   horizontal: 8, vertical: 8),
                                                  //             ),
                                                  //             value: _selectedReason,
                                                  //             onChanged: (String? value) {
                                                  //               setState(() {
                                                  //                 _selectedReason = value!;
                                                  //                 _reasonController.text = value;
                                                  //               });
                                                  //             },
                                                  //             items:<String>['Credit Amount', 'UPI', 'Credit/Debit Card', 'Cash'].map<DropdownMenuItem<String>>((String value) {
                                                  //               return DropdownMenuItem<String>(
                                                  //                 value: value,
                                                  //                 child: Text(value,style: TextStyle(color: value == 'Reason for return' ? Colors.grey : Colors.grey,),),
                                                  //               );
                                                  //             }).toList(),
                                                  //             isExpanded: true,
                                                  //             //     hint: const Text('Reason for return'),
                                                  //           ),
                                                  //         ),
                                                  //       )
                                                  //     ],
                                                  //   ),
                                                  // ),
                                                  // const SizedBox(width: 16),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        const Row(
                                                          mainAxisSize: MainAxisSize.min,
                                                          children: [
                                                            Padding(
                                                              padding:  EdgeInsets.only(bottom: 13),
                                                              child: Text('Amount to Pay'),
                                                            ),
                                                          ],
                                                        ),
                                                        Padding(
                                                          padding: const EdgeInsets.only(bottom: 8),
                                                          child: SizedBox(
                                                            height: 35,
                                                            child:
                                                            TextFormField(
                                                              enabled: widget.productMap['paymentStatus']  != 'cleared',
                                                              controller: AmountController,
                                                              //controller: AmountController =widget.productMap['paymentStatus'] == 'partial payment' ? PayableController :GrossAmountController ,
                                                              decoration: InputDecoration(
                                                                filled: true,
                                                                fillColor: Colors.grey.shade200,
                                                                border: OutlineInputBorder(
                                                                  borderRadius: BorderRadius.circular(5.0),
                                                                  borderSide: BorderSide.none,
                                                                ),
                                                                contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                                                                hintText: 'Enter Amount',
                                                                // errorText: _errorText,
                                                              ),
                                                              inputFormatters: [
                                                                FilteringTextInputFormatter.allow(RegExp("[a-zA-Z,0-9,@.]")),
                                                                FilteringTextInputFormatter.deny(RegExp(r'^\s')),
                                                                FilteringTextInputFormatter.deny(RegExp(r'\s\s')),
                                                              ],
                                                              // onChanged: (value){
                                                              //   AmountController.text = value;
                                                              // },
                                                            ),
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 50, top: 70,right: 50,bottom: 10),
                                      child: Container(
                                        // decoration: BoxDecoration(
                                        //   border: Border.all(color: Colors.grey),
                                        //   borderRadius: BorderRadius.circular(8),
                                        //   boxShadow: const [
                                        //     BoxShadow(
                                        //       color: Color(0xff00000029),
                                        //       offset: Offset(0, 3),
                                        //       blurRadius: 6,
                                        //     ),
                                        //   ],
                                        //   color: const Color(0xFFFFFFFF),
                                        // ),
                                          child: Column(
                                            children: [
                                              const Row(
                                                children: [
                                                  Text('Payment History',style: TextStyle(fontWeight: FontWeight.bold),),
                                                ],
                                              ),
                                              SizedBox(height: 20,),
                                              Container(
                                                width: 1700,
                                                decoration: BoxDecoration(
                                                  border: Border.all(color: Colors.grey),
                                                  borderRadius: BorderRadius.circular(8),
                                                  boxShadow: const [
                                                    BoxShadow(
                                                      color: Color(0xff00000029),
                                                      offset: Offset(0, 3),
                                                      blurRadius: 6,
                                                    ),
                                                  ],
                                                  color: const Color(0xFFFFFFFF),
                                                ),
                                                child: Padding(
                                                  padding: const EdgeInsets.only(),
                                                  child: DataTable(
                                                    showCheckboxColumn: false,
                                                    headingRowHeight: 40,
                                                    columns: [
                                                      //DataColumn(label: Container(child: Text('      '))),
                                                      DataColumn(
                                                        label: Padding(
                                                          padding: const EdgeInsets.only(left: 10),
                                                          child: Text(
                                                            'Payment ID',
                                                            style: TextStyle(
                                                              color: Colors.indigo[900],
                                                              fontSize: 13,
                                                              fontWeight: FontWeight.bold,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      DataColumn(
                                                        label: Padding(
                                                          padding: const EdgeInsets.only(left: 5),
                                                          child: Text(
                                                            'Payment Date',
                                                            style: TextStyle(
                                                              color: Colors.indigo[900],
                                                              fontSize: 13,
                                                              fontWeight: FontWeight.bold,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      DataColumn(
                                                        label: Text(
                                                          'Payment Mode',
                                                          style: TextStyle(
                                                            color: Colors.indigo[900],
                                                            fontSize: 13,
                                                            fontWeight: FontWeight.bold,
                                                          ),
                                                        ),
                                                      ),
                                                      DataColumn(
                                                        label: Text(
                                                          'Paid Amount',
                                                          style: TextStyle(
                                                            color: Colors.indigo[900],
                                                            fontSize: 13,
                                                            fontWeight: FontWeight.bold,
                                                          ),
                                                        ),
                                                      ),
                                                      DataColumn(
                                                        label: Text(
                                                          'Paid By',
                                                          style: TextStyle(
                                                            color: Colors.indigo[900],
                                                            fontSize: 13,
                                                            fontWeight: FontWeight.bold,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                    rows: List.generate(filteredData.length, (index){
                                                      final detail = filteredData.elementAt(index);
                                                      return DataRow(
                                                          color: MaterialStateProperty.resolveWith<Color>((states) {
                                                            if (states.contains(MaterialState.hovered)) {
                                                              return Colors.blue.shade500.withOpacity(0.8); // Dark blue with opacity
                                                            }  else {
                                                              return Colors.white.withOpacity(0.9);
                                                            }
                                                          }
                                                          ),
                                                          cells: [
                                                            DataCell(
                                                              Padding(
                                                                padding: const EdgeInsets.only(left: 5),
                                                                child: Text(detail.transactionsId!),
                                                              ),
                                                            ),
                                                            DataCell(
                                                              Padding(
                                                                padding: const EdgeInsets.only(left: 5),
                                                                child: Text(detail.paymentDate!),
                                                              ),
                                                            ),
                                                            DataCell(
                                                              Padding(
                                                                padding: const EdgeInsets.only(left: 5),
                                                                child: Text(detail.paymentMode!),
                                                              ),
                                                            ),
                                                            DataCell(
                                                              Padding(
                                                                padding: const EdgeInsets.only(left: 5),
                                                                child: Text(detail.exactPaidAmount!.toStringAsFixed(2)),
                                                              ),
                                                            ),
                                                            DataCell(
                                                              Padding(
                                                                padding: const EdgeInsets.only(left: 5),
                                                                child: Text(detail.paidBy!),
                                                              ),
                                                            ),
                                                          ]
                                                      );
                                                    }),

                                                  ),
                                                ),
                                              ),
                                            ],
                                          )
                                      ),
                                    ),
                                  ],),
                                ),
                              ),
                                                              ),
                                                            ),
                            }







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




  void _showDatePicker(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2015),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        _dateController.text = DateFormat('dd-MM-yyyy').format(selectedDate!);
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

