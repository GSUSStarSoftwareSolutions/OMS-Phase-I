
import 'dart:convert';
import 'dart:html';
import 'dart:typed_data';
import 'package:btb/Return%20Module/return%20first%20page.dart';
import 'package:btb/admin/Api%20name.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;

import '../widgets/confirmdialog.dart';


void main(){
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
      home: ReturnView(returnMaster: ReturnMaster(reason: '',returnDate: '',returnId: '',email: '',contactPerson: '',items: [],invoiceNumber: '',status: '',notes: '', returnCredit: 0, orderId: '',ShippAddress: '',ContactNumber: '', initiatedBy: '', customerId: ''),)));
}




class ReturnView extends StatefulWidget {
  final ReturnMaster? returnMaster;

  ReturnView({super.key,required this.returnMaster});
  @override
  State<ReturnView> createState() {
    return _ReturnViewState();
  }
}

class _ReturnViewState extends State<ReturnView> {

  String? _selectedReason;
  bool isEditing = false;
  int? _selectedIndex;
  final _controller = TextEditingController();
  List<dynamic> _orderDetails = [];
  Uint8List? _imageBytes;
  String _enteredValues = '';
  bool _showImage = false;
  final List<String> list = [
    'Reason for return',' Option 1', '  Option 2'];
  int Index =1 ;
  bool isOrdersSelected = false;
  double totalAmount = 0.0;
  final totalController = TextEditingController();
  List<String> storeImages = [];
  List<String> imageSizeStrings = [];
  final TextEditingController _dateController = TextEditingController();

  final TextEditingController NotesController = TextEditingController();
  final TextEditingController EmailAddressController = TextEditingController();
  final TextEditingController ContactpersonController = TextEditingController();
  final _reasonController = TextEditingController();


  String _enteredValue = '';

  String token = window.sessionStorage["token"] ?? " ";
  double _totalAmount = 0;


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
      _buildMenuItem('Home', Icons.home_outlined, Colors.blue[900]!, '/Home'),
      _buildMenuItem('Customer', Icons.account_circle_outlined, Colors.blue[900]!, '/Customer'),
      _buildMenuItem('Products', Icons.image_outlined, Colors.blue[900]!, '/Product_List'),
      _buildMenuItem('Orders', Icons.warehouse_outlined, Colors.blue[900]!, '/Order_List'),
      _buildMenuItem('Delivery', Icons.fire_truck_outlined, Colors.blue[900]!, '/Delivery_List'),
      _buildMenuItem('Invoice', Icons.document_scanner_outlined, Colors.blue[900]!, '/Invoice'),

      _buildMenuItem('Payment', Icons.payment_rounded, Colors.blue[900]!, '/Payment_List'),
      Container(
          decoration: BoxDecoration(
            color: Colors.blue[800]  ,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8), // Radius for top-left corner
              topRight: Radius.circular(8), // No radius for top-right corner
              bottomLeft: Radius.circular(8), // Radius for bottom-left corner
              bottomRight: Radius.circular(8), // No radius for bottom-right corner
            ),
          ),
          child: _buildMenuItem('Return', Icons.keyboard_return, Colors.blueAccent, '/Return_List')),
      _buildMenuItem('Reports', Icons.insert_chart_outlined, Colors.blue[900]!, '/Report_List'),
    ];
  }

  Widget _buildMenuItem(String title, IconData icon, Color iconColor, String route) {
    iconColor = _isHovered[title] == true ? Colors.blue : Colors.black87;
    title == 'Return'? _isHovered[title] = false :  _isHovered[title] = false;
    title == 'Return'? iconColor = Colors.white : Colors.black;
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


  Future<void> _fetchOrderDetails() async {
    final orderId = _controller.text.trim();
    final url = orderId.isEmpty
        ? '$apicall/order_master/get_all_ordermaster/'
        : '$apicall/order_master/search_by_orderid/$orderId';

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      print('Response: $jsonData');
      final orderData = jsonData.firstWhere(
              (order) => order['orderId'] == orderId, orElse: () => null);

      if (orderData != null) {
        setState(() {
          _orderDetails = orderData['items'].map((item) => {
            'productName': item['productName'],
            'qty': item['qty'],
            'totalAmount': item['totalAmount'],
            'price': item['price'],
            'category': item['category'],
            'subCategory': item['subCategory']
          }).toList();
        });
      } else {
        setState(() {
          _orderDetails = [{'productName': 'not found'}];
        });
      }
    } else {
      setState(() {
        _orderDetails = [{'productName': 'Error fetching order details'}];
      });
    }
  }

  @override
  void initState() {
    super.initState();
    print('ontap');
    if (widget.returnMaster != null) {
      print(widget.returnMaster!.status);
      _controller.text = widget.returnMaster!.invoiceNumber ?? '';
      _reasonController.text = widget.returnMaster!.reason ?? '';
      ContactpersonController.text = widget.returnMaster!.contactPerson ?? '';
      EmailAddressController.text = widget.returnMaster!.email ?? '';
      NotesController.text = widget.returnMaster!.notes ?? '';
      _orderDetails = widget.returnMaster!.items;
      totalController.text = widget.returnMaster!.returnCredit.toString();
      _dateController.text = widget.returnMaster!.returnDate ?? '';
    } else {
      print('widget.returnMaster is null');
    }
  }

  // @override
  // void initState() {
  // TODO: implement initState
  //   super.initState();
  //   print('ontap');
  //   print(widget.returnMaster!.status);
  //
  //   //widget.returnMaster!.invoiceNumber =
  //
  //       _controller.text = widget.returnMaster!.invoiceNumber!;
  //       _reasonController.text = widget.returnMaster!.reason!;
  //       ContactpersonController.text = widget.returnMaster!.contactPerson!;
  //       EmailAddressController.text = widget.returnMaster!.email!;
  //       NotesController.text = widget.returnMaster!.notes!;
  //       _orderDetails = widget.returnMaster!.items;
  //       totalController.text = widget.returnMaster!.totalCredit.toString();
  //   _dateController.text = widget.returnMaster!.returnDate!;
  //
  // }


  Future<void> fetchImage(String imageId) async {
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
          _imageBytes = response.bodyBytes;
          print('--_imageBytes--');
          print(_imageBytes);
        });
      } catch (e) {
        print('-------------');
        print('Error:$e');
      }
    } else {
      print('Failed to load image');
    }
  }



  void _showImageDialog(BuildContext context, String imageId) async {
    await fetchImage(imageId);

    if (_imageBytes != null) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            backgroundColor: Colors.black,
            // Black background for full-screen effect
            insetPadding: EdgeInsets.zero,
            // Remove padding to achieve full screen
            child: Stack(
              children: [
                SizedBox(
                  width: MediaQuery
                      .of(context)
                      .size
                      .width, // Set to screen width
                  height: MediaQuery
                      .of(context)
                      .size
                      .height, // Set to screen height
                  child: Padding(
                    padding: const EdgeInsets.only(top: 50,bottom: 50),
                    child: Image.memory(
                      _imageBytes!,
                      fit: BoxFit.contain, // Adjust the image's fit if necessary
                    ),
                  ),
                ),
                Positioned(
                  top: 20,
                  right: 20,
                  child: IconButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: Icon(
                      Icons.cancel_outlined,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    } else {
      print('Image not available');
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF0F4F8),
      appBar:
      AppBar(
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
            child
                :
            AccountMenu(),
          ),
        ],
      ),
      body: LayoutBuilder(
          builder: (context, constraints){
            double maxHeight = constraints.maxHeight;
            double maxWidth = constraints.maxWidth;
            return Stack(
              //   crossAxisAlignment: CrossAxisAlignment.start,
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
                    height: 900, // Set the height to your liking
                    decoration: BoxDecoration(
                      border: Border(left: BorderSide(width: 1, color: Colors.grey)),
                    ),
                  ),
                ),
                Positioned(
                    left: 201,
                    right: 0,
                    top: 0,
                    bottom: 0,
                    child:
                    Column(
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
                                  context.go('/Return_List');
                                  // Navigator.push(
                                  //   context,
                                  //   MaterialPageRoute(
                                  //       builder: (context) =>
                                  //       const Returnpage()),
                                  // );
                                },
                              ),
                              const Padding(
                                padding: EdgeInsets.only(left: 30,top: 5),
                                child: Text(
                                  'Order Return',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(
                              vertical: 1),
                          // Space above/below the border
                          height: 0.3, // Border height
                          color: Colors.black, // Border color
                        ),
                        Expanded(child: SingleChildScrollView(child: Column(children: [
                          Padding(
                            padding: const EdgeInsets.only(right:100),
                            child: SizedBox(
                              width: maxWidth,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                // mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding:  EdgeInsets.only(right: maxWidth * 0.08,
                                        //   * 0.089,
                                        top: 20),
                                    child:  Text('Return Date',style: TextStyle(fontSize: maxWidth * 0.0090),),
                                  ),
                                  // Padding(
                                  //   padding:  EdgeInsets.only(right: maxWidth * 0.089,top: 50),
                                  //   child: const Text(('Return Date')),
                                  // ),


                                  DecoratedBox(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: const Color(0xFFEBF3FF), width: 1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: SizedBox(
                                      height: 39,
                                      width: maxWidth *0.13,
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
                                                fillColor: Colors.white,
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
                                  // SizedBox(height: 20.h),

                                ],
                              ),

                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 50,right: 100,top: 50),
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0xFF00000029),
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
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text('Invoice Number'),
                                              const SizedBox(height: 5,),
                                              SizedBox(
                                                height: 40,
                                                child: TextFormField(
                                                  enabled: isEditing,
                                                  controller: _controller,
                                                  onEditingComplete: _fetchOrderDetails,
                                                  decoration: InputDecoration(
                                                      filled: true,
                                                      contentPadding: const EdgeInsets.symmetric(vertical: 10,horizontal: 12),
                                                      fillColor: Colors.grey.shade200,
                                                      border: OutlineInputBorder(
                                                        borderRadius: BorderRadius.circular(5.0),
                                                        borderSide: BorderSide.none,
                                                      ),
                                                      hintText: 'INV1900039'

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
                                              Text('Reason'),
                                              const SizedBox(height: 5,),
                                              SizedBox(
                                                height: 40,
                                                child:
                                                TextFormField(
                                                  enabled: isEditing,
                                                  controller: _reasonController,
                                                  decoration:  InputDecoration(
                                                      filled: true,
                                                      fillColor: Colors.grey.shade200,
                                                      border: OutlineInputBorder(
                                                        borderRadius: BorderRadius.circular(5.0),
                                                        borderSide: BorderSide.none,
                                                      ),
                                                      contentPadding: const EdgeInsets.symmetric(vertical: 10,horizontal: 12),
                                                      hintText: 'Person Name'
                                                  ),
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
                                              Text('Contact Person'),
                                              const SizedBox(height: 5,),
                                              SizedBox(
                                                height: 40,
                                                child: TextFormField(
                                                  enabled: isEditing,
                                                  controller: ContactpersonController,
                                                  decoration:  InputDecoration(
                                                      filled: true,
                                                      fillColor: Colors.grey.shade200,
                                                      border: OutlineInputBorder(
                                                        borderRadius: BorderRadius.circular(5.0),
                                                        borderSide: BorderSide.none,
                                                      ),
                                                      contentPadding: const EdgeInsets.symmetric(vertical: 10,horizontal: 12),
                                                      hintText: 'Person Name'
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
                                              Text('Email'),
                                              const SizedBox(height: 5,),
                                              SizedBox(
                                                height: 40,
                                                child: TextFormField(
                                                  enabled: isEditing,
                                                  controller: EmailAddressController,
                                                  decoration:  InputDecoration(
                                                      filled: true,
                                                      fillColor: Colors.grey.shade200,
                                                      border: OutlineInputBorder(
                                                        borderRadius: BorderRadius.circular(5.0),
                                                        borderSide: BorderSide.none,
                                                      ),
                                                      contentPadding: const EdgeInsets.symmetric(vertical: 10,horizontal: 12),
                                                      hintText: 'Person Email'

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
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Padding(
                            padding: const EdgeInsets.only(left: 50,right: 100,top: 30),
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFFFFF),
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0xFF00000029),
                                    offset: Offset(0, 3),
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.only(top: 10,left: 30),
                                    child: Text(
                                      'Add Products',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        fontFamily: 'Titillium Web',
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
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
                                          1: FlexColumnWidth(3),
                                          2: FlexColumnWidth(2),
                                          3: FlexColumnWidth(2),
                                          4: FlexColumnWidth(2),
                                          5: FlexColumnWidth(1),
                                          6: FlexColumnWidth(1.2),
                                          7: FlexColumnWidth(2),
                                          8: FlexColumnWidth(2),
                                        },
                                        children: const [
                                          TableRow(
                                              children: [
                                                TableCell(child: Padding(
                                                  padding: EdgeInsets.only(top: 10, bottom: 10),
                                                  child: Center(
                                                    child: Text(
                                                      "SN",
                                                      style: TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        //  fontSize: 12,
                                                      ),
                                                    ),
                                                  ),
                                                ),),
                                                TableCell(child: Padding(
                                                  padding: EdgeInsets.only(top: 10, bottom: 10),
                                                  child: Center(
                                                    child: Text(
                                                      'Product Name',
                                                      style: TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        //  fontSize: 12,
                                                      ),
                                                    ),
                                                  ),
                                                ),),
                                                TableCell(child: Padding(
                                                  padding: EdgeInsets.only(top: 10, bottom: 10),
                                                  child: Center(
                                                    child: Text(
                                                      "Category",
                                                      style: TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        // fontSize: 12,
                                                      ),
                                                    ),
                                                  ),
                                                ),),
                                                TableCell(child: Padding(
                                                  padding: EdgeInsets.only(top: 10, bottom: 10),
                                                  child: Center(
                                                    child: Text(
                                                      "Sub Category",
                                                      style: TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        // fontSize: 12,
                                                      ),
                                                    ),
                                                  ),
                                                ),),
                                                TableCell(child: Padding(
                                                  padding: EdgeInsets.only(top: 10, bottom: 10),
                                                  child: Center(
                                                    child: Text(
                                                      "Price",
                                                      style: TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        // fontSize: 12,
                                                      ),
                                                    ),
                                                  ),
                                                ),),
                                                TableCell(child: Padding(
                                                  padding: EdgeInsets.only(top: 10, bottom: 10),
                                                  child: Center(
                                                    child: Text(
                                                      "QTY",
                                                      style: TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        // fontSize: 12,
                                                      ),
                                                    ),
                                                  ),
                                                ),),
                                                TableCell(child: Padding(
                                                  padding: EdgeInsets.only(top: 10, bottom: 10),
                                                  child: Center(
                                                    child: Text(
                                                      "Return QTY",
                                                      style: TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        //  fontSize: 12,
                                                      ),
                                                    ),
                                                  ),
                                                ),),
                                                TableCell(child: Padding(
                                                  padding: EdgeInsets.only(top: 10, bottom: 10),
                                                  child: Center(
                                                    child: Text(
                                                      "Invoice Amount",
                                                      style: TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        //  fontSize: 12,
                                                      ),
                                                    ),
                                                  ),
                                                ),),
                                                TableCell(child: Padding(
                                                  padding: EdgeInsets.only(top: 10, bottom: 10),
                                                  child: Center(
                                                    child: Text(
                                                      "Credit Request",
                                                      style: TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        // fontSize: 12,
                                                      ),
                                                    ),
                                                  ),
                                                ),),
                                              ]
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                  ListView.builder(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: _orderDetails.length,
                                    itemBuilder: (context, index) {
                                      // if (widget.returnMaster == null) return Container(); // or some other placeholder
                                      //     Map<String, dynamic> item = widget.returnMaster!.items[index] as Map<String, dynamic>;
                                      return Table(
                                        border: TableBorder(
                                          bottom: BorderSide(width:1 ,color: Colors.grey),
                                          //   horizontalInside: BorderSide(width: 1,color: Colors.grey), // horizontal border inside the table
                                          verticalInside: BorderSide(width: 1,color: Colors.grey),
                                        ),
                                        // border: TableBorder.all(color: Colors.blue),
                                        //  Color(0xFFFFFFFF)
                                        columnWidths: const {
                                          0: FlexColumnWidth(1),
                                          1: FlexColumnWidth(3),
                                          2: FlexColumnWidth(2),
                                          3: FlexColumnWidth(2),
                                          4: FlexColumnWidth(2),
                                          5: FlexColumnWidth(1),
                                          6: FlexColumnWidth(1.2),
                                          7: FlexColumnWidth(2),
                                          8: FlexColumnWidth(2),
                                        },

                                        children: [
                                          TableRow(
                                              children:[
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
                                                      child: Center(child: Text(_orderDetails[index].productName,textAlign: TextAlign.center,)),
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
                                                      child: Center(child: Text(_orderDetails[index].category,textAlign: TextAlign.center,)),
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
                                                      child: Center(child: Text(_orderDetails[index].subCategory)),
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
                                                      child: Center(child: Text(_orderDetails[index].price.toString())),
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
                                                      child: Center(child: Text(_orderDetails[index].qty.toString())),
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
                                                        child: TextFormField(
                                                          initialValue: (_orderDetails[index].returnQty.toString()),
                                                          enabled: isEditing,
                                                          textAlign: TextAlign.center, // Center alignment
                                                          decoration: const InputDecoration(
                                                              border: InputBorder.none, // Remove underline
                                                              contentPadding: EdgeInsets.only(
                                                                  bottom: 12
                                                              )
                                                          ),

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
                                                      child: Center(child: Text(_orderDetails[index].invoiceAmount.toString())),
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
                                                      child: Center(child: Text(_orderDetails[index].creditRequest.toString() != null?_orderDetails[index].creditRequest.toString() : '0'),
                                                      ),
                                                    ),
                                                  ),

                                                ),
                                              ]
                                          )
                                        ],

                                      );
                                    },
                                  ),
                                  const SizedBox(height: 8),
                                  Padding(
                                    padding: const EdgeInsets.only(right: 25 ,top: 5,bottom: 5),
                                    child: Align(
                                      alignment: Alignment.centerRight,
                                      child: Container(
                                        height: 40,
                                        padding: const EdgeInsets.only(left: 15,right: 10,top: 6,bottom: 2),
                                        decoration: BoxDecoration(
                                          border: Border.all(color: const Color(0xFF0277BD)),
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
                                                    text:  'Total Credit',
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
                                                    text: totalController.text,
                                                    style: const TextStyle(
                                                      color: Colors.black,
                                                    ),
                                                  ) ],
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

                          const SizedBox(height: 16),
                          Padding(
                            padding: const EdgeInsets.only(left: 50,right: 100,top: 30),
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFFFFF),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0xFF00000029),
                                    offset: Offset(0, 3),
                                    blurRadius: 6,
                                  ),
                                ],
                                border: Border.all(color:  Colors.grey, ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [

                                  const SizedBox(height: 8),
                                  const Row(
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(left: 30),
                                        child: Text(
                                          'Image Upload',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                            fontFamily: 'Titillium Web',
                                          ),
                                        ),
                                      ),
                                      Spacer(),


                                    ],
                                  ),
                                  const Divider(
                                    color: Color(0xFFB2C2D3), // Choose a color that contrasts with the background
                                    thickness: 1, // Set a non-zero thickness
                                  ),
                                  // Divider(color: Color(0xFF00000029),),

                                  const SizedBox(height: 8),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 5,left:40,bottom: 5),
                                    child:
                                    Column(
                                      children:
                                      List.generate(_orderDetails.length, (index) {
                                        if(_orderDetails[index].imageId.trim().isNotEmpty) {
                                          return Column(
                                            children: [
                                              Row(
                                                children: [
                                                  IconButton(
                                                    onPressed: (){
                                                      _showImageDialog(context, _orderDetails[index].imageId);
                                                    },
                                                    icon: Icon(
                                                      Icons.info_outline_rounded,
                                                      color: Colors.blue,
                                                    ),
                                                  ),
                                                  Text(
                                                    '${_orderDetails[index].imageId}',
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                  Visibility(
                                                    visible: _showImage,
                                                    child: Container(
                                                      width: 200,
                                                      height: 200,
                                                      child: _imageBytes != null
                                                          ? Image.memory(
                                                        _imageBytes!,
                                                        fit: BoxFit.contain,
                                                      )
                                                          : Center(
                                                        child: CircularProgressIndicator(),
                                                      ),
                                                    ),
                                                  )
                                                ],
                                              ),
                                              if (_selectedIndex == index && _imageBytes != null)
                                                Container(
                                                  width:50,
                                                  height: 60,
                                                  padding: EdgeInsets.all(8.0),
                                                  color: Colors.blue[50],
                                                  child: Image.memory(_imageBytes!),
                                                ),
                                            ],
                                          );
                                        } else{
                                          return SizedBox.shrink();
                                        }}
                                      ),

                                    ),


                                  ),
                                  // Padding(
                                  //   padding: const EdgeInsets.only(top: 5,left:40,bottom: 5),
                                  //   child: Column(
                                  //           children: List.generate(_orderDetails.length, (index) {
                                  //           return Text('Image ID:    ${_orderDetails[index].imageId}',style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),);
                                  //          }),),
                                  // )
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Padding(
                            padding: const EdgeInsets.only(left: 50,right: 100,top: 30),
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFFFFF),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0xFF00000029),
                                    offset: Offset(0, 3),
                                    blurRadius: 6,
                                  ),
                                ],
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Notes', style: TextStyle(fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 8),
                                    TextFormField(
                                      enabled: isEditing,
                                      controller: NotesController,
                                      decoration: InputDecoration(
                                        filled: true,
                                        fillColor: Colors.grey.shade200,
                                        border: InputBorder.none,
                                      ),
                                      maxLines: 5, // To make it a single line text field
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],),))

                      ],
                    ))

              ],
            );
          }
      ),
    );
  }
}



String removeCharAt(String str, int index) {
  return str.substring(0, index) + str.substring(index + 1);
}

DataRow dataRow(int sn, String productName, String brand, String category, String subCategory, String price, int qty, int returnQty, String invoiceAmount, String creditRequest) {
  return DataRow(cells: [
    DataCell(
      Container(
        decoration: const BoxDecoration(
          color: Color(0xFFEEEEEE),
        ),
        child: Center(
          child: Text(sn.toString()),
        ),
      ),
    ),
    DataCell(
      Container(
        decoration: const BoxDecoration(
          color: Color(0xFFEEEEEE),
        ),
        child: Center(
          child: Text(productName),
        ),
      ),
    ),
    DataCell(
      Container(
        decoration: const BoxDecoration(
          color: Color(0xFFEEEEEE),
        ),
        child: Center(
          child: Text(brand),
        ),
      ),
    ),
    DataCell(
      Container(
        decoration: const BoxDecoration(
          color: Color(0xFFEEEEEE),
        ),
        child: Center(
          child: Text(category),
        ),
      ),
    ),
    DataCell(
      Container(
        decoration: const BoxDecoration(
          color: Color(0xFFEEEEEE),
        ),
        child: Center(
          child: Text(subCategory),
        ),
      ),
    ),
    DataCell(
      Container(
        decoration: const BoxDecoration(
          color: Color(0xFFEEEEEE),
        ),
        child: Center(
          child: Text(price),
        ),
      ),
    ),
    DataCell(
      Container(
        decoration: const BoxDecoration(
          color: Color(0xFFEEEEEE),
        ),
        child: Center(
          child: Text(qty.toString()),
        ),
      ),
    ),
    DataCell(
      Container(
        decoration: const BoxDecoration(
          color: Color(0xFFEEEEEE),
        ),
        child: Center(
          child: Text(returnQty.toString()),
        ),
      ),
    ),
    DataCell(
      Container(
        decoration: const BoxDecoration(
          color: Color(0xFFEEEEEE),
        ),
        child: Center(
          child: Text(invoiceAmount),
        ),
      ),
    ),
    DataCell(
      Container(
        decoration: const BoxDecoration(
          color: Color(0xFFEEEEEE),
        ),
        child: Center(
          child: Text(creditRequest),
        ),
      ),
    ),
  ]);
}







