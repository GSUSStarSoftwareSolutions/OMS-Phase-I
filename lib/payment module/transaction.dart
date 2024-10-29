import 'dart:async';
import 'dart:convert';
import 'dart:math'as math;
import 'package:btb/admin/Api%20name.dart';
import 'package:btb/widgets/confirmdialog.dart';
import 'package:btb/widgets/pagination.dart';
import 'package:btb/widgets/productclass.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import '../../widgets/custom loading.dart';
import 'package:btb/Order%20Module/firstpage.dart';
import '../../widgets/no datafound.dart';
import 'dart:html';

void main(){
  runApp( PaymentTransaction());
}


class PaymentTransaction extends StatefulWidget {
  String? orderId;
   PaymentTransaction({super.key,this.orderId});
  @override
  State<PaymentTransaction> createState() => _PaymentTransactionState();
}

class _PaymentTransactionState extends State<PaymentTransaction> {
  Timer? _searchDebounceTimer;
  String _searchText = '';
  bool isOrdersSelected = false;
  bool _loading = false;
  detail? _selectedProduct;
  DateTime? _selectedDate;
  late TextEditingController _dateController;
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
  String selectDate = '';


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








  Future<void> fetchProducts(String orderId) async {
    String? orderId = widget.orderId;

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


  void _updateSearch(String searchText) {
    setState(() {
      _searchText = searchText;
      currentPage = 1;  // Reset to first page when searching
      _filterAndPaginateProducts();
      // _clearSearch();
    });
  }

  void _goToPreviousPage() {

    if (currentPage > 1) {
      if(filteredData.length > itemsPerPage) {
        setState(() {
          currentPage--;
        });
      }

    }
  }

  void _goToNextPage() {

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
    fetchProducts(widget.orderId!);
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
              double maxHeight = constraints.maxHeight;
              return
                Stack(
                  children: [
                    Align(
                      // Added Align widget for the left side menu
                      alignment: Alignment.topLeft,
                      child: Container(
                        height: 1400,
                        width: 200,
                        color: const Color(0xFFF7F6FA),
                        padding: const EdgeInsets.only(left: 20, top: 30),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextButton.icon(
                              onPressed: () {

                                context.go('/Home');
                                // context.go('/Orders/Home');

                              },
                              icon: Icon(
                                  Icons.dashboard, color: Colors.indigo[900]),
                              label: Text(
                                'Home',
                                style: TextStyle(color: Colors.indigo[900],fontSize: 16),
                              ),
                            ),
                            const SizedBox(height: 20),
                            TextButton.icon(
                              onPressed: () {
                                context.go('/Product_List');
                                // context.go('/Orders/Products');
                              },
                              icon: Icon(Icons.image_outlined,
                                  color: Colors.indigo[900]),
                              label: Text(
                                'Products',
                                style: TextStyle(color: Colors.indigo[900],fontSize: 16),
                              ),
                            ),
                            const SizedBox(height: 20),
                            TextButton.icon(
                              onPressed: () {
                                context.go('/Order_List');

                              },
                              icon: Icon(Icons.warehouse,
                                  color: Colors.indigo[800]),
                              label:  Text(
                                'Orders',
                                style: TextStyle(
                                    color: Colors.indigo[800],fontSize: 16
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            TextButton.icon(
                              onPressed: () {
                                context.go('/Invoice');
                              },
                              icon: Icon(Icons.document_scanner_rounded,
                                  color: Colors.blue[900]),
                              label: Text(
                                'Invoice',
                                style: TextStyle(color: Colors.indigo[900],fontSize: 16),
                              ),
                            ),
                            const SizedBox(height: 20),
                            TextButton.icon(
                              onPressed: () {
                                context.go('/Delivery_List');
                              },
                              icon: Icon(Icons.fire_truck_outlined,
                                color: Colors.indigo[800],),
                              label: Text(
                                'Delivery',
                                style: TextStyle(color:Colors.indigo[900],fontSize: 16),
                              ),
                            ),

                            const SizedBox(height: 20),
                            TextButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.payment_outlined,
                                  color: Colors.blueAccent),
                              label: const Text(
                                'Payment',
                                style: TextStyle(color: Colors.blueAccent,fontSize: 16),
                              ),
                            ),
                            const SizedBox(height: 20),
                            TextButton.icon(
                              onPressed: () {
                                context.go('/Return_List');
                                //context.go('/Orders/Return/:Return');
                              },
                              icon: Icon(Icons.backspace_sharp,
                                  color: Colors.blue[900]),
                              label: Text(
                                'Return',
                                style: TextStyle(color: Colors.indigo[900],fontSize: 16),
                              ),
                            ),
                            const SizedBox(height: 20),
                            TextButton.icon(
                              onPressed: () {
                                context.go('/Report_List');
                              },
                              icon: Icon(
                                  Icons.insert_chart, color: Colors.blue[900]),
                              label: Text(
                                'Reports',
                                style: TextStyle(color: Colors.indigo[900],fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 200,top: 0),
                      child: Container(
                        width: 1, // Set the width to 1 for a vertical line
                        height: 1400, // Set the height to your liking
                        decoration: const BoxDecoration(
                          border: Border(left: BorderSide(width: 1, color: Colors.grey)),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 201),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          color: Colors.white,
                          height: 50,
                          child: const Row(
                            children: [
                              Padding(
                                padding: EdgeInsets.only(left: 20),
                                child: Text(
                                  'Payment Transaction',
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 40, left: 200),
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                            vertical: 10),
                        // Space above/below the border
                        height: 0.3, // Border height
                        color: Colors.black, // Border color
                      ),
                    ),
                    Padding(
                      padding:  EdgeInsets.only(
                          left:
                          300, top: 120, right: maxWidth * 0.062,bottom: 15),
                      child: Container(
                        width: maxWidth,
                        height: 700,
                        // decoration: BoxDecoration(
                        //   color: Colors.white, // or any other color that fits your design
                        //   borderRadius: BorderRadius.all(Radius.circular(10.0)), // adds a subtle rounded corner
                        //   border: Border.all(
                        //     color: Color(0xFFE5E5E5), // a light grey border
                        //     width: 1.0,
                        //   ),
                        //   boxShadow: [
                        //     BoxShadow(
                        //       color: Color(0xFFC7C5B8).withOpacity(0.2), // a soft, warm shadow
                        //       spreadRadius: 0.5,
                        //       blurRadius: 4, // increased blur radius for a softer shadow
                        //       offset: Offset(0, 4), // increased offset for a more pronounced shadow
                        //     ),
                        //   ],
                        // ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          // boxShadow: [
                          //   BoxShadow(
                          //     color: Colors.blue.withOpacity(0.1), // Soft grey shadow
                          //     spreadRadius: 1,
                          //     blurRadius: 3,
                          //     offset: const Offset(0, 1),
                          //   ),
                          // ],
                        ),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: SizedBox(
                            width: maxWidth * 0.79,
                            // padding: EdgeInsets.only(),
                            // margin: EdgeInsets.only(left: 400, right: 100),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // buildSearchField(),
                                const SizedBox(height: 10),
                                Scrollbar(
                                  controller: _scrollController,
                                  thickness: 6,
                                  thumbVisibility: true,
                                  child: SingleChildScrollView(
                                    controller: _scrollController,
                                    scrollDirection: Axis.horizontal,
                                    child: buildDataTable(),
                                  ),
                                ),
                                //Divider(color: Colors.grey,height: 1,)
                                const SizedBox(),
                                Padding(
                                  padding: const EdgeInsets.only(right:30),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      PaginationControls(
                                        currentPage: currentPage,
                                        totalPages: filteredData.length > itemsPerPage ? totalPages : 1,// totalPages,
                                        onPreviousPage: _goToPreviousPage,
                                        onNextPage: _goToNextPage,
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
                              hintText: 'Search',
                              hintStyle: const TextStyle(fontSize: 13,color: Colors.grey),
                              contentPadding: const EdgeInsets.only(bottom: 20,left: 10), // adjusted padding
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
                              child: DropdownButtonFormField<String>(
                                decoration: const InputDecoration(
                                  contentPadding: EdgeInsets.only(bottom: 15,left: 10),// adjusted padding
                                  border: InputBorder.none,
                                  filled: true,
                                  focusColor: Color(0xFFF0F4F8),
                                  fillColor: Colors.white,
                                  hintText: 'Category',
                                  hintStyle: TextStyle(color: Colors.grey),
                                ),
                                icon: Padding(
                                  padding: const EdgeInsets.only(right: 10),
                                  child: Icon(Icons.arrow_drop_down_circle_rounded, color: Colors.blue[800], size: 16),
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
                                  'payment cleared',
                                ].map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value, style: TextStyle(color: value == 'Status' ? Colors.grey : Colors.black,fontSize: 13)),
                                  );
                                }).toList(),
                                isExpanded: true,
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
                              child: DropdownButtonFormField<String>(
                                decoration: const InputDecoration(
                                  contentPadding: EdgeInsets.only(bottom: 22,left: 10),
                                  border: InputBorder.none,
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                                icon: Padding(
                                  padding: const EdgeInsets.only(right: 10),
                                  child: Icon(Icons.arrow_drop_down_circle_rounded, color: Colors.blue[800], size: 16),
                                ),
                                value: dropdownValue2,
                                focusColor: const Color(0xFFF0F4F8),
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
      double right = MediaQuery.of(context).size.width;
      return
        Column(
          children: [
            Container(
              width: right * 0.78,

              decoration:const BoxDecoration(
                  color: Color(0xFFF7F7F7),
                  border: Border.symmetric(horizontal: BorderSide(color: Colors.grey,width: 0.5))
              ),
              child: DataTable(
                  showCheckboxColumn: false,
                  headingRowHeight: 40,
                  columns: [
                    DataColumn(label: Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Text('Order ID',style:TextStyle(
                          color: Colors.indigo[900],
                          fontSize: 13,
                          fontWeight: FontWeight.bold
                      ),),
                    )),
                    DataColumn(label: Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: Text('Delivered Date',style:TextStyle(
                          color: Colors.indigo[900],
                          fontSize: 13,
                          fontWeight: FontWeight.bold
                      ),),
                    )),
                    DataColumn(label: Text(
                      'Invoice Number',style:TextStyle(
                        color: Colors.indigo[900],
                        fontSize: 13,
                        fontWeight: FontWeight.bold
                    ),)),
                    DataColumn(label: Text(
                      'Payment Date',style:  TextStyle(

                        color: Colors.indigo[900],
                        fontSize: 13,
                        fontWeight: FontWeight.bold
                    ),)),
                    DataColumn(label: Container(child: Text(
                      'Payment Mode',style:  TextStyle(

                        color: Colors.indigo[900],
                        fontSize: 13,
                        fontWeight: FontWeight.bold
                    ),))),
                    DataColumn(label: Container(child: Text(
                      'Payment Status',style:  TextStyle(

                        color: Colors.indigo[900],
                        fontSize: 13,
                        fontWeight: FontWeight.bold
                    ),))),
                    DataColumn(label: Container(child: Text(
                      'Payable Amount',style:  TextStyle(

                        color: Colors.indigo[900],
                        fontSize: 13,
                        fontWeight: FontWeight.bold
                    ),))),
                  ],
                  rows: []

              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 150,left: 130,bottom: 350,right: 150),
              child: CustomDatafound(),
            ),
          ],
        );

    }
    return LayoutBuilder(builder: (context, constraints){
      // double padding = constraints.maxWidth * 0.065;
      double right = MediaQuery.of(context).size.width;


      return
        Column(
          children: [
            Container(
              width: right * 0.78,

              decoration:const BoxDecoration(
                  color: Color(0xFFF7F7F7),
                  border: Border.symmetric(horizontal: BorderSide(color: Colors.grey,width: 0.5))
              ),
              child:
              DataTable(
                showCheckboxColumn: false,
                headingRowHeight: 40,
                columns: [
                  DataColumn(label: const Text('      ')),
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
                      'Gross Amount',
                      style: TextStyle(
                        color: Colors.indigo[900],
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
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
                      }
                      ),
                      cells: [
                        DataCell(
                          Checkbox(
                            value: isSelected,
                            checkColor: Colors.white,
                            activeColor: Colors.blue[800],
                            onChanged: (selected) {
                              setState(() {
                                _selectedProduct = selected! ? detail : null;
                              });
                            },
                          ),
                        ),
                        DataCell(
                          Padding(
                            padding: const EdgeInsets.only(left: 5),
                            child: Text(
                              detail.transactionsId!,
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ),
                        ),
                        DataCell(
                          Text(
                            detail.paymentDate!,
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ),
                        DataCell(
                          Padding(
                            padding: const EdgeInsets.only(left: 2),
                            child: Text(
                              detail.paymentMode!,
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ),
                        ),
                        DataCell(
                          Padding(
                            padding: const EdgeInsets.only(left: 13),
                            child: Text(
                              detail.paidAmount.toString(),
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ),
                        ),
                        DataCell(
                          Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: Text(
                              detail.grossAmount.toString(),
                              style: const TextStyle(
                                color:Colors.grey,
                              ),
                            ),
                          ),
                        ),


                      ],
                    );
                  },
                ),
              ),
              // DataTable(
              //     showCheckboxColumn: false,
              //     headingRowHeight: 40,
              //     columns: [
              //       DataColumn(label: Container(child: Padding(
              //         padding: const EdgeInsets.only(left: 10),
              //         child: Text('Order ID',style:TextStyle(
              //             color: Colors.indigo[900],
              //             fontSize: 13,
              //             fontWeight: FontWeight.bold
              //         ),),
              //       ))),
              //       DataColumn(label: Container(
              //           child: Padding(
              //             padding: const EdgeInsets.only(left: 20),
              //             child: Text('Delivered Date',style:TextStyle(
              //                 color: Colors.indigo[900],
              //                 fontSize: 13,
              //                 fontWeight: FontWeight.bold
              //             ),),
              //           ))),
              //       DataColumn(label: Container(child: Text(
              //         'Invoice Number',style:TextStyle(
              //           color: Colors.indigo[900],
              //           fontSize: 13,
              //           fontWeight: FontWeight.bold
              //       ),))),
              //       DataColumn(label: Container(child: Text(
              //         'Payment Date',style:TextStyle(
              //           color: Colors.indigo[900],
              //           fontSize: 13,
              //           fontWeight: FontWeight.bold
              //       ),))),
              //       DataColumn(label: Container(child: Text(
              //         'Payment Mode',style:  TextStyle(
              //
              //           color: Colors.indigo[900],
              //           fontSize: 13,
              //           fontWeight: FontWeight.bold
              //       ),))),
              //       DataColumn(label: Container(child: Text(
              //         'Payment Status',style:  TextStyle(
              //
              //           color: Colors.indigo[900],
              //           fontSize: 13,
              //           fontWeight: FontWeight.bold
              //       ),))),
              //       DataColumn(label: Container(child: Padding(
              //         padding: const EdgeInsets.only(right: 50),
              //         child: Text(
              //           'Amount',style:  TextStyle(
              //
              //             color: Colors.indigo[900],
              //             fontSize: 13,
              //             fontWeight: FontWeight.bold
              //         ),),
              //       ))),
              //
              //     ],
              //     rows:
              //     List.generate(
              //         math.min(itemsPerPage, filteredData.length - (currentPage - 1) * itemsPerPage),(index){
              //       final detail = filteredData.skip((currentPage - 1) * itemsPerPage).elementAt(index);
              //       final isSelected = _selectedProduct == detail;
              //       // final isSelected = _selectedProduct == detail;
              //       //final product = filteredData[(currentPage - 1) * itemsPerPage + index];
              //       return DataRow(
              //           color: MaterialStateProperty.resolveWith<Color>((states) {
              //             if (states.contains(MaterialState.hovered)) {
              //               return Colors.blue.shade500.withOpacity(0.8); // Add some opacity to the dark blue
              //             } else {
              //               return Colors.white.withOpacity(0.9);
              //             }
              //           }),
              //           cells:
              //           [
              //             DataCell(
              //                 Padding(
              //                   padding: const EdgeInsets.only(left: 5),
              //                   child: Text(detail.deliveryId!,style:
              //                   TextStyle(
              //                     // fontSize: 16,
              //                       color: Colors.grey),),
              //                 )),
              //             DataCell(
              //                 Text(detail.contactPerson!, style: TextStyle(
              //                   //fontSize: 16,
              //                   color:Colors.grey,),)),
              //
              //             DataCell(
              //               Padding(
              //                 padding: const EdgeInsets.only(left: 2),
              //                 child: Text(detail.modifiedAt!,style: TextStyle(
              //                   // fontSize: 16,
              //                     color: Colors.grey)),
              //               ),
              //             ),
              //
              //             DataCell(
              //               Padding(
              //                 padding: const EdgeInsets.only(left: 13),
              //                 child: Text(detail.total.toString(),style: TextStyle(
              //                   // fontSize: 16,
              //                     color: Colors.grey)),
              //               ),
              //             ),
              //             DataCell(
              //               Padding(
              //                 padding: const EdgeInsets.only(left: 10),
              //                 child: Text(detail.deliveryStatus,style: TextStyle(
              //                   //fontSize: 16,
              //                     color: detail.deliveryStatus == "In Progress" ? Colors.orange
              //                         :
              //                     detail.deliveryStatus == "Delivered" ? Colors.green: Colors.grey)),
              //               ),
              //             ),
              //
              //             DataCell(
              //               Padding(
              //                 padding: const EdgeInsets.only(left: 10),
              //                 child: Text(detail.deliveryStatus,style: TextStyle(
              //                   //fontSize: 16,
              //                     color: detail.deliveryStatus == "In Progress" ? Colors.orange
              //                         :
              //                     detail.deliveryStatus == "Delivered" ? Colors.green: Colors.grey)),
              //               ),
              //             ),
              //             DataCell(
              //               Padding(
              //                 padding: const EdgeInsets.only(left: 10),
              //                 child: Text(detail.deliveryStatus,style: TextStyle(
              //                   //fontSize: 16,
              //                     color: detail.deliveryStatus == "In Progress" ? Colors.orange
              //                         :
              //                     detail.deliveryStatus == "Delivered" ? Colors.green: Colors.grey)),
              //               ),
              //             ),
              //
              //           ],
              //           onSelectChanged: (selected){
              //             if(selected != null && selected){
              //               //final detail = filteredData[(currentPage - 1) * itemsPerPage + index];
              //
              //               if (filteredData.length <= 9) {
              //                 print(detail.deliveryStatus);
              //                 // Navigator.push(
              //                 //   context,
              //                 //   PageRouteBuilder(
              //                 //     pageBuilder:
              //                 //         (context, animation, secondaryAnimation) =>
              //                 //         DeliveryConfirm(
              //                 //           deliverystatus: detail.deliveryStatus,
              //                 //           deliveryId: detail.deliveryId,),
              //                 //     transitionDuration:
              //                 //     const Duration(milliseconds: 50),
              //                 //     transitionsBuilder: (context, animation,
              //                 //         secondaryAnimation, child) {
              //                 //       return FadeTransition(
              //                 //         opacity: animation,
              //                 //         child: child,
              //                 //       );
              //                 //     },
              //                 //   ),
              //                 // );
              //                 // context.go('/OrdersList', extra: {
              //                 //   'product': detail,
              //                 //   'item': [], // pass an empty list of maps
              //                 //   'body': {},
              //                 //   'itemsList': [], // pass an empty list of maps
              //                 //   'orderDetails': productList.map((detail) => OrderDetail(
              //                 //     orderId: detail.orderId,
              //                 //     orderDate: detail.orderDate, items: [],
              //                 //     // Add other fields as needed
              //                 //   )).toList(),
              //                 // });
              //               } else {
              //                 // Navigator.push(
              //                 //   context,
              //                 //   PageRouteBuilder(
              //                 //     pageBuilder:
              //                 //         (context, animation, secondaryAnimation) => DeliveryConfirm(
              //                 //       deliverystatus: detail.deliveryStatus,
              //                 //       deliveryId: detail.deliveryId,),
              //                 //     transitionDuration:
              //                 //     const Duration(milliseconds: 50),
              //                 //     transitionsBuilder: (context, animation,
              //                 //         secondaryAnimation, child) {
              //                 //       return FadeTransition(
              //                 //         opacity: animation,
              //                 //         child: child,
              //                 //       );
              //                 //     },
              //                 //   ),
              //                 // );
              //
              //
              //               };
              //               // context.go('/OrdersList', extra: {
              //               //   'product': detail,
              //               //   'item': [], // pass an empty list of maps
              //               //   'body': {},
              //               //   'itemsList': [], // pass an empty list of maps
              //               //   'orderDetails':filteredData.map((detail) => OrderDetail(
              //               //     orderId: detail.orderId,
              //               //     orderDate: detail.orderDate, items: [],
              //               //     // Add other fields as needed
              //               //   )).toList(),
              //               // });
              //             }
              //           }
              //       );
              //     })
              //   // List.generate(
              //   //   5, // number of rows
              //   //       (index) {
              //   //     return DataRow(
              //   //       cells: [
              //   //         DataCell(Text('ORD_000 ${index + 1}')),
              //   //         DataCell(Padding(
              //   //           padding: const EdgeInsets.only(left: 25),
              //   //           child: Text('26/08/2024'),
              //   //         )),
              //   //         DataCell(Padding(
              //   //           padding: const EdgeInsets.only(left: 15),
              //   //           child: Text('INV_000${index + 1}'),
              //   //         )),
              //   //         DataCell(Padding(
              //   //           padding: const EdgeInsets.only(left: 5),
              //   //           child: Text('26/08/2024'),
              //   //         )),
              //   //         DataCell(Padding(
              //   //           padding: const EdgeInsets.only(left: 25),
              //   //           child: Text('UPI'),
              //   //         )),
              //   //         DataCell(Padding(
              //   //           padding: const EdgeInsets.only(left: 15),
              //   //           child: Text('Success'),
              //   //         )),
              //   //         DataCell(Padding(
              //   //           padding: const EdgeInsets.only(left: 5),
              //   //           child: Text('10000'),
              //   //         )),
              //   //       ],
              //   //     );
              //   //   },
              //   // ),
              //
              // ),
            ),
          ],
        );
    });
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

