import 'dart:async';
import 'dart:convert';
import 'dart:html';
import 'package:btb/admin/Api%20name.dart';
import 'package:btb/widgets/productclass.dart' as ord;
import 'package:flutter/animation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'dashboard.dart';
import '../widgets/confirmdialog.dart';
import '../widgets/custom loading.dart';
import '../widgets/pagination.dart';
import '../widgets/productdata.dart';


void main() => runApp(OpenInvoice());

class OpenInvoice extends StatefulWidget {
  const OpenInvoice({super.key});
//  final ord.Product? product;
  @override
  State<OpenInvoice> createState() => _OpenInvoiceState();
}

class _OpenInvoiceState extends State<OpenInvoice> {
  ord.Product? _selectedProduct;
  late ProductData productData;
  bool isHomeSelected = false;
  bool isOrdersSelected = false;
  Timer? _searchDebounceTimer;

  String _searchText = '';
  String _category = '';

  late TextEditingController _dateController;
  String _subCategory = '';
  int startIndex = 0;
  List<ord.Product> filteredProducts = [];
  String? dropdownValue1 = 'Delivery Status';
  String token = window.sessionStorage["token"] ?? " ";
  String? dropdownValue2 = 'Select Year';
  bool _hasShownPopup = false;
  List<Dashboard1> productList = [];
  List<Dashboard1> _filteredData = [];

  void _onSearchTextChanged(String text) {
    if (_searchDebounceTimer != null) {
      _searchDebounceTimer!.cancel(); // Cancel the previous timer
    }
    _searchDebounceTimer = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        _searchText = text;
        _filterAndPaginateProducts();
      });
    });
  }
  final ScrollController _scrollController = ScrollController();
  int currentPage = 1;
  int itemsPerPage = 10;
  bool _isRowHovered = false;
  int totalItems = 0;
  int totalPages = 0;
  bool _loading = false;
  String status='';
  String selectDate='';
  bool isLoading = false;
  //List<ord.Product> productList = [];

// Example method for fetching products
  Future<void> fetchProducts(int? page, int? itemsPerPage) async {
    if (isLoading) return;
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse(
          '$apicall/dashboard/get_open_invoices_list?page=$page&limit=$itemsPerPage',
        ),
        headers: {
          "Content-type": "application/json",
          "Authorization": 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final responseBody = response.body;
        final jsonData = jsonDecode(responseBody);
        print(jsonData);

        List<Dashboard1> products = [];

        if (jsonData is List) {
          products = jsonData.map((item) => Dashboard1.fromJson(item)).toList();
        } else if (jsonData is Map && jsonData.containsKey('body')) {
          products = (jsonData['body'] as List).map((item) => Dashboard1.fromJson(item)).toList();
        }

       // print('products: $products');

        int totalCount = products.length; // Initialize total count

//        print('Current Page: $page');
        setState(() {
          //productList = products.where((product) => product.status == 'completed').toList();
          productList = products;
         // print('productList: $productList');

          // Calculate the total pages using the total count
          totalPages = (totalCount / itemsPerPage!).ceil();
          print('Total Pages: $totalPages');
          _filterAndPaginateProducts();
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Error: $e');
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
            double maxHeight = constraints.maxHeight;
            double maxWidth = constraints.maxWidth;
            return Stack(
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
                          onPressed: ()  {
                            context.go('/Home');
                          },
                          icon: Icon(Icons.dashboard,
                              color: isHomeSelected
                                  ? Colors.blueAccent
                                  : Colors.blueAccent),
                          label: Text(
                            'Home',
                            style: TextStyle(color: Colors.blueAccent,fontSize: 16),
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextButton.icon(
                          onPressed: () {
                            context.go('/Product_List');
                            setState(() {
                              isOrdersSelected = false;
                              // Handle button press19
                            });
                          },
                          icon: Icon(Icons.image_outlined,
                              color: Colors.indigo[900]),
                          label:  Text(
                            'Products',
                            style: TextStyle(color: Colors.indigo[900],fontSize: 16),
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextButton.icon(
                          onPressed: () {
                            context.go('/Order_List');
                            //context.go('/Products/Orderspage/:Orders');
                            setState(() {
                              isOrdersSelected = false;
                              // Handle button press19
                            });
                          },
                          icon:
                          Icon(Icons.warehouse, color: Colors.blue[900]),
                          label: Text(
                            'Orders',
                            style: TextStyle(
                                color: Colors.indigo[900],fontSize: 16
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextButton.icon(
                          onPressed: () {},
                          icon: Icon(Icons.fire_truck_outlined,
                              color: Colors.blue[900]),
                          label: Text(
                            'Delivery',
                            style: TextStyle(color: Colors.indigo[900],fontSize: 16),
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextButton.icon(
                          onPressed: () {},
                          icon: Icon(Icons.document_scanner_rounded,
                              color: Colors.blue[900]),
                          label: Text(
                            'Invoice',
                            style: TextStyle(color: Colors.indigo[900],fontSize: 16),
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextButton.icon(
                          onPressed: () {},
                          icon: Icon(Icons.payment_outlined,
                              color: Colors.blue[900]),
                          label: Text(
                            'Payment',
                            style: TextStyle(color: Colors.indigo[900],fontSize: 16),
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextButton.icon(
                          onPressed: () {
                            context.go('/Return_List');
                            // context.go('/Home/Products/:Return');
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
                          onPressed: () {},
                          icon: Icon(Icons.insert_chart,
                              color: Colors.blue[900]),
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
                  padding: const EdgeInsets.only( left: 192),
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 10), // Space above/below the border
                    width: 1, // Border height
                    color: Colors.grey, // Border color
                  ),
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 203),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      color: Color(0xFFFFFDFF),
                      height: 50,
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(
                                Icons.arrow_back), // Back button icon
                            onPressed: () {
                              context.go(
                                  '/Home');
                              // Navigator.of(context).push(PageRouteBuilder(
                              //   pageBuilder: (context, animation,
                              //       secondaryAnimation) =>
                              //   const ProductPage(product: null),
                              // ));
                            },
                          ),
                          const Padding(
                            padding: EdgeInsets.only(left: 20),
                            child: Text(
                              'Open Invoice',
                              style: TextStyle(
                                fontSize: 20,
                                //fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const Spacer(),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 33, left: 202),
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                        vertical: 16), // Space above/below the border
                    height: 1, // Border height
                    color: Colors.grey, // Border color
                  ),
                ),
                Padding(
                  padding:  EdgeInsets.only(left: 300, top: 120,right: maxWidth * 0.062,bottom: 15),
                  child: Container(
                    width: maxWidth,
                    height: 700,
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
                        //  height: 1300,
                        width: maxWidth * 0.79,
                        // padding: EdgeInsets.only(),
                        // margin: EdgeInsets.only(left: 400, right: 100),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            buildSearchField(),
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
                            SizedBox(),
                            Padding(
                              padding: const EdgeInsets.only(right:30),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  PaginationControls(
                                    currentPage: currentPage,
                                    totalPages: _filteredData.length > itemsPerPage ? totalPages : 1,//totalPages//totalPages,
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
                const SizedBox(height: 50,),
              ],
            );
          }
          )
      ),
    );
  }


  Widget buildSearchField() {
    double maxWidth1 = MediaQuery.of(context).size.width;
    return LayoutBuilder(builder: (context, constraints) {
      return ConstrainedBox(
        constraints: BoxConstraints(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.only(top: 20, left: 30),
                  child: Container(
                    width: maxWidth1 * 0.2, // reduced width
                    height: 35, // reduced height
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(2),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: TextFormField(
                      decoration: const InputDecoration(
                        hintText: 'Search',
                        hintStyle: TextStyle(color: Colors.grey,fontSize: 13),
                        contentPadding:
                        EdgeInsets.only(bottom: 20,left: 10) ,// adjusted padding
                        border: InputBorder.none,
                        suffixIcon: Padding(
                          padding: EdgeInsets.only(right: 2),
                          child: Icon(Icons.search_outlined, color: Colors.indigo,size: 20,),
                        ),
                      ),
                      onChanged: _updateSearch,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //  const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.only(left: 30),
                      child: Container(
                        width: maxWidth1 * 0.1, // reduced width
                        height: 35, // reduced height
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(2),
                          border: Border.all(color: Colors.grey),
                        ),
                        child: DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            contentPadding:
                            EdgeInsets.only(bottom: 15,left: 9), // adjusted padding
                            border: InputBorder.none,
                            filled: true,
                            fillColor: Colors.white,
                            suffixIcon: Padding(
                              padding: EdgeInsets.only(right: 5),
                              child: Icon(Icons.arrow_drop_down_circle_rounded,
                                  color: Colors.indigo, size: 16),
                            ),
                          ),
                          icon: Container(),
                          value: dropdownValue1,
                          onChanged: (String? newValue) {
                            setState(() {
                              dropdownValue1 = newValue;
                              status = newValue ?? '';
                              _filterAndPaginateProducts();
                            });
                          },
                          items: <String>[
                            'Delivery Status',
                            'Not Started',
                            'Completed',
                          ]
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                value,
                                style: TextStyle(fontSize: 13,color: value == 'Delivery Status' ? Colors.grey : Colors.black,),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
                // const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        width: maxWidth1 * 0.095, // reduced width
                        height: 35, // reduced height
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(2),
                          border: Border.all(color: Colors.grey),
                        ),
                        child: DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            contentPadding:
                            EdgeInsets.only(bottom: 15,left: 10), // adjusted padding
                            border: InputBorder.none,
                            filled: true,
                            fillColor: Colors.white,
                            suffixIcon: Padding(
                              padding: EdgeInsets.only(right: 5),
                              child: Icon(Icons.arrow_drop_down_circle_rounded,
                                  color: Colors.indigo, size: 16),
                            ),
                          ),
                          icon: Container(),
                          value: dropdownValue2,
                          onChanged: (String? newValue) {
                            setState(() {
                              selectDate = newValue ?? '';
                              dropdownValue2 = newValue;
                              _filterAndPaginateProducts();
                            });
                          },
                          items: <String>['Select Year', '2023', '2024', '2025']
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                value,
                                style: TextStyle(fontSize: 13, color: value == 'Select Year' ? Colors.grey : Colors.black,),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      );
    });
  }


  Widget buildDataTable() {
    var _mediaQuery = MediaQuery.of(context).size.width;
    if (isLoading) {
      _loading = true;
      var width = MediaQuery.of(context).size.width;
      var Height = MediaQuery.of(context).size.height;
      // Show loading indicator while data is being fetched
      return Padding(
        padding: EdgeInsets.only(bottom: Height * 0.100,left: width * 0.300),
        child: CustomLoadingIcon(), // Replace this with your custom GIF widget
      );
    }

    if (_filteredData.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: 250, left: 500),
        child: Text('No products found'),
      );
    }
    return  Column(
      children: [
        Container(
          width: _mediaQuery * 0.78,
          // height: 300,
          decoration:  BoxDecoration(
              color: Color(0xFFECEFF1),
              //   color: Color(0xFFF7F7F7),
              border: Border.symmetric(horizontal: BorderSide(color: Colors.grey,width: 0.5))
          ),
          child: DataTable(
            headingRowHeight: 40,
            columns: [
              DataColumn(label: Container(
                  child: Padding(
                    padding: EdgeInsets.only(left: 16),
                    child: Text('Status',style:TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo[900],
                      fontSize: 15,
                    ),),
                  ))),
              DataColumn(label: Container(child: Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Text('Order ID',style:TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo[900],
                  fontSize: 15,
                ),),
              ))),
              DataColumn(label: Container(child: Text(
                'Created Date',style:TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.indigo[900],
                fontSize: 15,
              ),))),
              DataColumn(label: Container(child: Text(
                'Reference Number',style:TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.indigo[900],
                fontSize: 15,
              ),))),
              DataColumn(label: Container(child: Text(
                'Total Amount',style:TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.indigo[900],
                fontSize: 15,
              ),))),
              DataColumn(label: Container(child: Padding(
                padding: const EdgeInsets.only(left: 2),
                child: Text('Delivery Status',style:  TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo[900],
                  fontSize: 15,
                ),),
              ))),
            ],
            rows:
            _filteredData
                .where((dashboard) => dashboard.status == 'Completed') // Filter the data
                .skip((currentPage - 1) * itemsPerPage)
                .take(itemsPerPage)
                .map((dashboard)
            // _filteredData.skip((currentPage - 1) * itemsPerPage)
            //     .take(itemsPerPage)
            //     .map((dashboard)
            {
              final isSelected = false;
              return DataRow(
                  color: MaterialStateColor.resolveWith(
                          (states) => isSelected ? Colors.grey[200]! : Colors.white),
                  cells: [
                    DataCell(
                      Container(
                        child: Text(
                          dashboard.status,
                          style: TextStyle(
                            // fontSize: 15,
                            color: dashboard.status == 'Completed'
                                ? Colors.green
                                : isSelected
                                ? Colors.deepOrange[200]
                                : const Color(0xFFFFB315),
                          ),
                        ),
                      ),
                    ),
                    DataCell(Container( child: Text(
                      dashboard.orderId,style:
                    TextStyle(color: Color(0xFFA6A6A6),
                        //   fontSize: 15,
                        fontStyle: FontStyle.normal),))),
                    DataCell(Container( child: Padding(
                      padding: const EdgeInsets.only(left: 5),
                      child: Text(
                        dashboard.createdDate,
                        style:TextStyle(color:
                        Color(0xFFA6A6A6),

                            fontStyle: FontStyle.normal),),
                    ))),
                    DataCell(Container(child: Padding(
                      padding: const EdgeInsets.only(left: 50),
                      child: Text(dashboard.referenceNumber.toString(),
                        style: TextStyle(color: Color(0xFFA6A6A6),
                            fontStyle: FontStyle.normal),),
                    ))),
                    DataCell(Container(child: Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: Text(dashboard.totalAmount.toString(),
                        style: TextStyle(color:
                        Color(0xFFA6A6A6),
                            fontStyle: FontStyle.normal),),
                    ))),
                    DataCell(Container(child: Padding(
                      padding: const EdgeInsets.only(left: 15),
                      child: Text(dashboard.deliveryStatus.toString(),
                        style: TextStyle(color:
                        Color(0xFFA6A6A6),
                            fontStyle: FontStyle.normal),),
                    ))),
                  ]);
            }).toList(),
          ),
        ),
      ],
    );
  }


  void _filterAndPaginateProducts() {

    _filteredData = productList.where((product) {

      final matchesSearchText= product.orderId.toLowerCase().contains(_searchText.toLowerCase());
      print('-----');
      print(product.createdDate);
      String orderYear = '';
      if (product.createdDate.contains('-')) {
        final dateParts = product.createdDate.split('-');
        if (dateParts.length == 3) {
          orderYear = dateParts[0]; // Extract the year
        }
      }
      if (status.isEmpty && selectDate.isEmpty) {
        return matchesSearchText; // Include all products that match the search text
      }
      if(status == 'Delivery Status' && selectDate == 'Select Year'){
        return matchesSearchText;
      }
      if(status == 'Delivery Status' &&  selectDate.isEmpty)
      {
        return matchesSearchText;
      }
      if(selectDate == 'Select Year' &&  status.isEmpty)
      {
        return matchesSearchText;
      }
      if (status == 'Delivery Status' && selectDate.isNotEmpty) {
        return matchesSearchText && orderYear == selectDate; // Include all products
      }
      if (status.isNotEmpty && selectDate == 'Select Year') {
        return matchesSearchText && product.deliveryStatus == status;// Include all products
      }
      if (status.isEmpty && selectDate.isNotEmpty) {
        return matchesSearchText && orderYear == selectDate; // Include all products
      }

      if (status.isNotEmpty && selectDate.isEmpty) {
        return matchesSearchText && product.deliveryStatus == status;// Include all products
      }
      return matchesSearchText &&
          (product.deliveryStatus == status && orderYear == selectDate);
      //  return false;
    }).toList();
    setState(() {
      print('fileterpaginate');
      print(_filteredData);
      currentPage = 1;
    });

  }

}



