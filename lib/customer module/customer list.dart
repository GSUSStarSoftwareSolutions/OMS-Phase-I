import 'dart:async';
import 'dart:convert';
import 'dart:html';
import 'dart:math'as math;
import 'package:adaptive_scrollbar/adaptive_scrollbar.dart';
import 'package:btb/widgets/Api%20name.dart';
import 'package:btb/widgets/confirmdialog.dart';
import 'package:btb/widgets/pagination.dart';
import 'package:btb/widgets/productclass.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import '../customer login/home/home.dart';
import '../widgets/custom loading.dart';
import '../widgets/no datafound.dart';
import '../widgets/productsap.dart' as ord;
import '../widgets/text_style.dart';

void main(){
  runApp( const CusList());
}


class CusList extends StatefulWidget {
  const CusList({super.key});
  @override
  State<CusList> createState() => _CusListState();
}
class _CusListState extends State<CusList> {
  List<String> statusOptions = ['Order', 'Invoice', 'Delivery', 'Payment'];
  Timer? _searchDebounceTimer;
  String _searchText = '';
  bool isOrdersSelected = false;
  bool loading = false;
  int startIndex = 0;
  String location = '';
  String name = '';
  List<Product> filteredProducts = [];
  int currentPage = 1;
  String? dropdownValue1 = 'Status';
  late Future<List<ord.BusinessPartnerData>> futureOrders;
  List<ord.BusinessPartnerData> productList = [];
  final ScrollController _scrollController = ScrollController();
  List<dynamic> detailJson = [];
  String searchQuery = '';
  List<ord.BusinessPartnerData>filteredData = [];
  String status = '';
  String selectDate = '';
  final ScrollController horizontalScroll = ScrollController();

  String token = window.sessionStorage["token"] ?? " ";
  String? dropdownValue2 = 'Select Year';
  final List<String> _sortOrder = List.generate(6, (index) => 'asc');
  List<String> columns = ['Customer ID','Customer Name','City','Mobile Number','Email ID'];
  List<double> columnWidths = [130, 145, 139, 160, 135,];
  List<bool> columnSortState = [true, true, true,true,true];
  int itemsPerPage = 10;
  int totalItems = 0;
  int totalPages = 0;
  bool isLoading = false;
  final Map<String, bool> _isHovered = {
    'Home': false,
    'Customer': false,
    'Products': false,
    'Orders': false,
  };
  List<Widget> _buildMenuItems(BuildContext context) {
    return [
      Column(
        children: [
          const SizedBox(
            height: 10,
          ),
          _buildMenuItem('Home', Icons.home_outlined,
              Colors.blue[900]!, '/Home'),
          _buildMenuItem('Product', Icons.production_quantity_limits,
              Colors.blue[900]!, '/Product_List'),
          Container(
              height: 42,
              decoration: BoxDecoration(
                color: Colors.blue[800],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                  bottomLeft: Radius.circular(8),
                  bottomRight:
                  Radius.circular(8),
                ),
              ),
              child: _buildMenuItem(
                  'Customer', Icons.account_circle_outlined, Colors.white, '/Customer')),
          const SizedBox(height: 6,),
          _buildMenuItem(
              'Orders', Icons.warehouse_outlined, Colors.blue[900]!, '/Order_List'),
        ],
      ),
      const SizedBox(
        height: 6,
      ),
    ];
  }

  Widget _buildMenuItem(
      String title, IconData icon, Color iconColor, String route) {
    iconColor = _isHovered[title] == true ? Colors.blue : Colors.black87;
    title == 'Customer' ? _isHovered[title] = false : _isHovered[title] = false;
    title == 'Customer' ? iconColor = Colors.white : Colors.black;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(
            () => _isHovered[title] = true,
      ),
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
            padding: const EdgeInsets.only(left: 10,top:2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(icon, color: iconColor,size: 20,),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: TextStyle(
                    color: iconColor,
                    fontSize: 15,
                    decoration: TextDecoration.none,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


  Future<void> fetchProducts(int page, int itemsPerPage) async {
    if (isLoading) return;
    setState(() {
      isLoading = true;
    });
    try {
      final response = await http.get(
        Uri.parse(
          '$apicall/public/customer_master/get_all_s4hana_customermaster?page=$page&limit=$itemsPerPage',
        ),
        headers: {
          "Content-type": "application/json",
          "Authorization": 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        List<ord.BusinessPartnerData> products = [];
        if (jsonData != null) {
          products = jsonData.map<ord.BusinessPartnerData>((item) {
            return ord.BusinessPartnerData(
              customerName: item['customerName'] ?? '',
              businessPartner: item['customer'] ?? '',
              businessPartnerName: '',
              customer: item['customer'] ?? '',
              addressID: item['addressID'] ?? '',
              cityName: item['cityName'] ?? '',
              postalCode: item['postalCode'] ?? '',
              streetName: item['streetName'] ?? '',
              region: item['region'] ?? '',
              telephoneNumber1: item['telephoneNumber1'] ?? '',
              country: item['country'] ?? '',
              districtName: item['districtName'] ?? '',
              emailAddress: item['emailAddress'] ?? '',
              mobilePhoneNumber: item['mobilePhoneNumber'] ?? '',
            );
          }).toList();
          setState(() {
            productList = products;
            totalPages = (products.length / itemsPerPage).ceil();
            _filterAndPaginateProducts();
          });
        }
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }
  void _filterAndPaginateProducts() {
    filteredData = productList.
    where((product) {
      final matchesSearchText= product.customer.toLowerCase().contains(_searchText.toLowerCase()) || product.customerName.toLowerCase().contains(_searchText.toLowerCase());
      return matchesSearchText;
    }).toList();
    totalPages = (filteredData.length / itemsPerPage).ceil();    setState(() {    currentPage = 1;  });}
  void _updateSearch(String searchText) {
    setState(() {
      _searchText = searchText;
      currentPage = 1;
      _filterAndPaginateProducts();
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
    }
  }

  @override
  void initState() {
    super.initState();
    fetchProducts(currentPage, itemsPerPage);
  }
  @override
  void dispose() {
    _searchDebounceTimer
        ?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.grey[50],
        body: LayoutBuilder(
            builder: (context,constraints) {
              double maxWidth = constraints.maxWidth;
              double maxHeight = constraints.maxHeight;
              return
                Stack(
                  children: [
                    Container(
                      color: Colors.white,
                      height: 60.0,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 15, top: 10),
                                child: Image.asset(
                                  "images/Final-Ikyam-Logo.png",
                                  height: 35.0,
                                ),
                              ),
                              const Spacer(),
                              const Row(
                                children: [
                                  Padding(
                                    padding:
                                    EdgeInsets.only(right: 10, top: 10),
                                    child: AccountMenu(),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 7,
                          ),
                          const Divider(
                            height: 3.0,
                            thickness: 3.0,
                            color: Color(0x29000000),
                          ),
                        ],
                      ),
                    ),

                    if (constraints.maxHeight <= 500) ...{
                      Positioned(
                        top:60,
                        left:0,
                        right:0,
                        bottom: 0,child:   SingleChildScrollView(
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Container(
                              height: 1400,
                              width: 200,
                              color: Colors.white,
                              padding:
                              const EdgeInsets.only(left: 15, top: 10, right: 15),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: _buildMenuItems(context),
                              ),
                            ),
                          ),

                        ),

                      ),),

                      VerticalDividerWidget(
                        height: maxHeight,
                        color: const Color(0x29000000),
                      ),
                    }else ...{
                      Align(
                        alignment: Alignment.topLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 62),
                          child: Container(
                            height: 1400,
                            width: 200,
                            color: Colors.white,
                            padding:
                            const EdgeInsets.only(left: 15, top: 10, right: 15),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: _buildMenuItems(context),
                            ),
                          ),
                        ),
                      ),
                      VerticalDividerWidget(
                        height: maxHeight,
                        color: const Color(0x29000000),
                      ),
                    },

                    Positioned(
                      left: 201,
                      top: 60,
                      right: 0,
                      bottom: 0,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if(constraints.maxWidth >= 1350)...{
                            Expanded(
                                child: SingleChildScrollView(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(left: 30,top: 20),
                                            child: Text('Customer List',style: TextStyles.heading,),
                                          ),

                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Padding(
                                              padding: const EdgeInsets.only(
                                                left: 30,
                                                top: 20,
                                                right: 30,
                                                bottom: 15,
                                              ),
                                              child: Container(
                                                height: 640,
                                                width: maxWidth * 0.8,
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius: BorderRadius.circular(2),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.grey.withOpacity(0.1),
                                                      spreadRadius: 3,
                                                      blurRadius: 3,
                                                      offset: const Offset(0, 3),
                                                    ),
                                                  ],
                                                ),
                                                child: SizedBox(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                    children: [
                                                      buildSearchField(),
                                                      const SizedBox(height: 10),
                                                      Expanded(
                                                        child: Scrollbar(
                                                          controller:
                                                          _scrollController,
                                                          thickness: 6,
                                                          thumbVisibility: true,
                                                          child:
                                                          SingleChildScrollView(
                                                            controller:
                                                            _scrollController,
                                                            scrollDirection:
                                                            Axis.horizontal,
                                                            child: buildDataTable(),
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        height: 1,
                                                      ),
                                                      Padding(
                                                        padding:
                                                        const EdgeInsets.only(
                                                            right: 30),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                          MainAxisAlignment.end,
                                                          children: [
                                                            PaginationControls(
                                                              currentPage:
                                                              currentPage,
                                                              totalPages: filteredData
                                                                  .length >
                                                                  itemsPerPage
                                                                  ? totalPages
                                                                  : 1,
                                                              onPreviousPage: _goToPreviousPage,
                                                              onNextPage: _goToNextPage,
                                                              // onLastPage: _goToLastPage,
                                                            ),
                                                          ],
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              )),
                                        ],
                                      ),
                                    ],
                                  ),
                                )),
                          }
                          else...{
                            Expanded(
                                child: AdaptiveScrollbar(
                                  position: ScrollbarPosition.bottom,controller: horizontalScroll,
                                  child: SingleChildScrollView(
                                    controller: horizontalScroll,
                                    scrollDirection: Axis.horizontal,
                                    child: SingleChildScrollView(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(left: 30,top: 20),
                                                child: Text('Customer List',style: TextStyles.heading,),
                                              ),

                                            ],
                                          ),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Padding(
                                                  padding: const EdgeInsets.only(
                                                      left: 30,
                                                      top: 20,
                                                      right: 30,
                                                      bottom: 15),
                                                  child: Container(
                                                    height: 755,
                                                    width: 1100,
                                                    decoration:BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius: BorderRadius.circular(2),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors.grey.withOpacity(0.1),
                                                          spreadRadius: 3,
                                                          blurRadius: 3,
                                                          offset: const Offset(0, 3),
                                                        ),
                                                      ],
                                                    ),
                                                    child: SizedBox(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                        CrossAxisAlignment.start,
                                                        children: [
                                                          buildSearchField(),
                                                          const SizedBox(height: 10),
                                                          Expanded(
                                                            child: Scrollbar(
                                                              controller:
                                                              _scrollController,
                                                              thickness: 6,
                                                              thumbVisibility: true,
                                                              child:
                                                              SingleChildScrollView(
                                                                controller:
                                                                _scrollController,
                                                                scrollDirection:
                                                                Axis.horizontal,
                                                                child: buildDataTable2(),
                                                              ),
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            height: 1,
                                                          ),
                                                          Padding(
                                                            padding:
                                                            const EdgeInsets.only(
                                                                right: 30),
                                                            child: Row(
                                                              mainAxisAlignment:
                                                              MainAxisAlignment.end,
                                                              children: [
                                                                PaginationControls(
                                                                  currentPage:
                                                                  currentPage,
                                                                  totalPages: filteredData
                                                                      .length >
                                                                      itemsPerPage
                                                                      ? totalPages
                                                                      : 1,
                                                                  onPreviousPage: _goToPreviousPage,
                                                                  onNextPage: _goToNextPage,
                                                                  // onLastPage: _goToLastPage,
                                                                ),
                                                              ],
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  )),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                )),
                          }

                        ],
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
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: constraints.maxWidth * 0.265,
                          maxHeight: 39,
                        ),
                        child: Container(
                          height: 35,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(2),
                            border: Border.all(color: Colors.grey),
                          ),
                          child: TextFormField(
                            style: GoogleFonts.inter(    color: Colors.black,    fontSize: 13),
                            decoration:  InputDecoration(
                                hintText: 'Search by Customer ID or Customer Name',
                                hintStyle: const TextStyle(fontSize: 13,color: Colors.grey),
                                contentPadding: const EdgeInsets.symmetric(vertical: 3,horizontal: 5),
                                border: InputBorder.none,
                                suffixIcon: Padding(
                                  padding: const EdgeInsets.only(left: 10, right: 5),
                                  child: Image.asset(
                                    'images/search.png',
                                  ),
                                )
                            ),
                            onChanged: _updateSearch,
                          ),
                        ),
                      ),
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

  Widget buildDataTable2() {

    if (isLoading) {
      loading = true;
      var width = MediaQuery.of(context).size.width;
      var height = MediaQuery.of(context).size.height;
      return Padding(
        padding: EdgeInsets.only(top: height * 0.100,bottom: height * 0.100,left: width * 0.300),
        child: CustomLoadingIcon(),
      );
    }

    if (filteredData.isEmpty) {
      return
        Column(
          children: [
            Container(
              width:1100,
              decoration:const BoxDecoration(
                  color: Color(0xFFF7F7F7),
                  border: Border.symmetric(horizontal: BorderSide(color: Colors.grey,width: 0.5))
              ),
              child: DataTable(
                  showCheckboxColumn: false,
                  headingRowHeight: 40,
                  columns: [
                    DataColumn(label: Text('Customer ID',style:TextStyles.subhead,)),
                    DataColumn(label: Text('Customer Name',style:TextStyles.subhead,)),
                    DataColumn(label: Text(
                      'City',style:TextStyles.subhead,)),
                    DataColumn(label: Text(
                      'Mobile Number',style:TextStyles.subhead,)),
                    DataColumn(label: Text(
                      'Email ID',style:TextStyles.subhead,)),
                  ],
                  rows: const []
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 150,left: 130,bottom: 350,right: 150),
              child: CustomDatafound(),
            ),
          ],
        );
    }

    void sortProducts(int columnIndex, String sortDirection) {
      if (sortDirection == 'asc') {
        filteredData.sort((a, b) {
          if (columnIndex == 0) {
            return a.customer.compareTo(b.customer);
          } else if (columnIndex == 1) {
            return a.businessPartner.compareTo(b.businessPartner);
          } else if (columnIndex == 2) {
            return a.cityName.compareTo(b.cityName);
          } else if (columnIndex == 3) {
            return a.telephoneNumber1.toLowerCase().compareTo(b.telephoneNumber1.toLowerCase());
          } else if (columnIndex == 4) {
            return a.emailAddress.compareTo(b.emailAddress);
          } else {
            return 0;
          }
        });
      } else {
        filteredData.sort((a, b) {
          if (columnIndex == 0) {
            return b.customer.compareTo(a.customer);
          } else if (columnIndex == 1) {
            return b.businessPartner.compareTo(a.businessPartner);
          } else if (columnIndex == 2) {
            return b.cityName.compareTo(a.cityName);
          } else if (columnIndex == 3) {
            return b.telephoneNumber1.toLowerCase().compareTo(a.telephoneNumber1.toLowerCase());
          } else if (columnIndex == 4) {
            return b.emailAddress.compareTo(a.emailAddress);
          } else {
            return 0;
          }
        });
      }
      setState(() {});
    }

    return LayoutBuilder(builder: (context, constraints){

      return
        Column(
          children: [
            Container(
              width: 1100,
              decoration:const BoxDecoration(
                  color: Color(0xFFF7F7F7),
                  border: Border.symmetric(horizontal: BorderSide(color: Colors.grey,width: 0.5))
              ),
              child: DataTable(
                showCheckboxColumn: false,
                headingRowHeight: 40,
                columns: columns.map((column) {
                  return
                    DataColumn(
                      label: Stack(
                        children: [
                          SizedBox(
                            width: columnWidths[columns.indexOf(column)],
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                    column,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyles.subhead
                                ),

                                IconButton(
                                  icon: _sortOrder[columns.indexOf(column)] == 'asc'
                                      ? SizedBox(
                                      width: 12,
                                      child: Image.asset(
                                        "images/ix_sort.png",
                                        color: Colors.blue,
                                      ))
                                      : SizedBox(
                                      width: 12,
                                      child: Image.asset(
                                        "images/ix_sort.png",
                                        color: Colors.blue,
                                      )),
                                  onPressed: () {
                                    setState(() {
                                      _sortOrder[columns.indexOf(column)] = _sortOrder[columns.indexOf(column)] == 'asc' ? 'desc' : 'asc';
                                      sortProducts(columns.indexOf(column), _sortOrder[columns.indexOf(column)]);
                                    });
                                  },
                                ),

                              ],
                            ),
                          ),
                        ],
                      ),
                      onSort: (columnIndex, ascending){
                        _sortOrder;
                      },
                    );
                }).toList(),
                rows:
                List.generate(
                    math.min(itemsPerPage, filteredData.length - (currentPage - 1) * itemsPerPage),(index){
                  final detail = filteredData.skip((currentPage - 1) * itemsPerPage).elementAt(index);
                  return DataRow(
                      color: MaterialStateProperty.resolveWith<Color>((states) {
                        if (states.contains(MaterialState.hovered)) {
                          return Colors.blue.shade500.withOpacity(0.8);
                        } else {
                          return Colors.white.withOpacity(0.9);
                        }
                      }),
                      cells:
                      [

                        DataCell(
                            Text(detail.customer,   style: TextStyles.body,)),
                        DataCell(
                          Text(detail.customerName,   style: TextStyles.body,),
                        ),
                        DataCell(
                          Text(detail.cityName,   style: TextStyles.body,),
                        ),
                        DataCell(
                          SizedBox(
                            width: columnWidths[3],
                            child: Text(detail.telephoneNumber1.toString(),   style: TextStyles.body,),
                          ),
                        ),
                        DataCell(
                          Text(detail.emailAddress.toString(),   style: TextStyles.body,),
                        ),
                      ],
                      onSelectChanged: (selected){
                        if(selected != null && selected){
                          if (filteredData.length <= 9) {
                            context.go('/Cus_Details',extra:{
                              'orderId': detail.customer
                            });
                          } else {
                            context.go('/Cus_Details',extra:{
                              'orderId': detail.customer
                            });

                          };
                        }
                      }

                  );
                }),
              ),
            ),
          ],
        );
    });
  }

  Widget buildDataTable() {

    if (isLoading) {
      loading = true;
      var width = MediaQuery.of(context).size.width;
      var height = MediaQuery.of(context).size.height;
      return Padding(
        padding: EdgeInsets.only(top: height * 0.100,bottom: height * 0.100,left: width * 0.300),
        child: CustomLoadingIcon(),
      );
    }

    if (filteredData.isEmpty) {
      double right = MediaQuery.of(context).size.width;
      return
        Column(
          children: [
            Container(
              width: right - 100,
              decoration:const BoxDecoration(
                  color: Color(0xFFF7F7F7),
                  border: Border.symmetric(horizontal: BorderSide(color: Colors.grey,width: 0.5))
              ),
              child: DataTable(
                  showCheckboxColumn: false,
                  headingRowHeight: 40,
                  columns: [
                    DataColumn(label: Text('Customer ID',style:TextStyles.subhead,)),
                    DataColumn(label: Text('Customer Name',style:TextStyles.subhead,)),
                    DataColumn(label: Text('City',style:TextStyles.subhead,)),
                    DataColumn(label: Text('Mobile Number',style:TextStyles.subhead,)),
                    DataColumn(label: Text('Email ID',style:TextStyles.subhead,)),
                  ],
                  rows: const []

              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 150,left: 130,bottom: 350,right: 150),
              child: CustomDatafound(),
            ),
          ],

        );

    }


    void sortProducts(int columnIndex, String sortDirection) {
      if (sortDirection == 'asc') {
        filteredData.sort((a, b) {
          if (columnIndex == 0) {
            return a.customer.compareTo(b.customer);
          } else if (columnIndex == 1) {
            return a.businessPartner.compareTo(b.businessPartner);
          } else if (columnIndex == 2) {
            return a.cityName.compareTo(b.cityName);

          } else if (columnIndex == 3) {
            return a.telephoneNumber1.compareTo(b.telephoneNumber1);

          } else if (columnIndex == 4) {
            return a.emailAddress.toLowerCase().compareTo(b.emailAddress.toLowerCase());
          } else {
            return 0;
          }
        });
      } else {
        filteredData.sort((a, b) {
          if (columnIndex == 0) {
            return b.customer.compareTo(a.customer);
          } else if (columnIndex == 1) {
            return b.businessPartner.compareTo(a.businessPartner);
          } else if (columnIndex == 2) {
            return b.cityName.compareTo(a.cityName);
          } else if (columnIndex == 3) {
            return b.telephoneNumber1.toLowerCase().compareTo(a.telephoneNumber1.toLowerCase());
          } else if (columnIndex == 4) {
            return b.emailAddress.compareTo(a.emailAddress);
          } else {
            return 0;
          }
        });
      }
      setState(() {});
    }

    return LayoutBuilder(builder: (context, constraints){
      double right = MediaQuery.of(context).size.width * 0.92;
      return
        Column(
          children: [
            Container(
              width: right - 100,
              decoration:const BoxDecoration(
                  color: Color(0xFFF7F7F7),
                  border: Border.symmetric(horizontal: BorderSide(color: Colors.grey,width: 0.5))
              ),
              child: DataTable(
                showCheckboxColumn: false,
                headingRowHeight: 40,
                columns: columns.map((column) {
                  return
                    DataColumn(
                      label: Stack(
                        children: [
                          SizedBox(
                            width: columnWidths[columns.indexOf(column)],
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                    column,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyles.subhead
                                ),

                                IconButton(
                                  icon: _sortOrder[columns.indexOf(column)] == 'asc'
                                      ? SizedBox(
                                      width: 12,
                                      child: Image.asset(
                                        "images/ix_sort.png",
                                        color: Colors.blue,
                                      ))
                                      : SizedBox(
                                      width: 12,
                                      child: Image.asset(
                                        "images/ix_sort.png",
                                        color: Colors.blue,
                                      )),
                                  onPressed: () {
                                    setState(() {
                                      _sortOrder[columns.indexOf(column)] = _sortOrder[columns.indexOf(column)] == 'asc' ? 'desc' : 'asc';
                                      sortProducts(columns.indexOf(column), _sortOrder[columns.indexOf(column)]);
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      onSort: (columnIndex, ascending){
                        _sortOrder;
                      },
                    );
                }).toList(),
                rows:
                List.generate(
                    math.min(itemsPerPage, filteredData.length - (currentPage - 1) * itemsPerPage),(index){
                  final detail = filteredData.skip((currentPage - 1) * itemsPerPage).elementAt(index);
                  return DataRow(
                      color: MaterialStateProperty.resolveWith<Color>((states) {
                        if (states.contains(MaterialState.hovered)) {
                          return Colors.blue.shade500.withOpacity(0.8);
                        } else {
                          return Colors.white.withOpacity(0.9);
                        }
                      }),
                      cells:
                      [
                        DataCell(Text(detail.customer,   style: TextStyles.body,)),
                        DataCell(Text(detail.customerName,   style: TextStyles.body,),),
                        DataCell(Text(detail.cityName,   style: TextStyles.body,),),
                        DataCell(
                          SizedBox(
                            width: columnWidths[3],
                            child: Text(detail.telephoneNumber1.toString(),   style: TextStyles.body,),
                          ),
                        ),
                        DataCell(Text(detail.emailAddress.toString(),   style: TextStyles.body,),),
                      ],
                      onSelectChanged: (selected){
                        if(selected != null && selected){
                          if (filteredData.length <= 9) {
                            context.go('/Cus_Details',extra:{
                              'orderId': detail.customer
                            });
                          } else {
                            context.go('/Cus_Details',extra:{
                              'orderId': detail.customer
                            });
                          }
                        }
                      }
                  );
                }),
              ),
            ),
          ],
        );
    });
  }
}
class CusDetail {
  String? customer;
  String? businessPartnerName;
  String? telephoneNumber1;
  String? location;
  String? email;
  double? postalCode;
  CusDetail({
    this.customer,
    this.businessPartnerName,
    this.telephoneNumber1,
    this.location,
    this.email,
    this.postalCode
  });

  factory CusDetail.fromJson(Map<String, dynamic> json) {
    return CusDetail(
      customer: json['customerId'] ?? '',
      businessPartnerName: json['customerName'] ?? '',
      email: json['email'] ?? '',
      telephoneNumber1: json['telephoneNumber1No'] ?? '',
      location: json['deliveryLocation'] ?? '',
      postalCode: json['returnCredit'] ?? 0.0,

    );
  }
  factory CusDetail.fromString(String jsonString) {
    final jsonMap = jsonDecode(jsonString);
    return CusDetail.fromJson(jsonMap);
  }
  @override
  String toString() {
    return 'cus ID: $customer, Order Date: $businessPartnerName, Total: $telephoneNumber1, Status: $Location, Delivery Status: $postalCode';
  }
  String toJson() {
    return jsonEncode({
      "customer": customer,
      "businessPartnerName": businessPartnerName,
      "email": email,
      "telephoneNumber1": telephoneNumber1,
      "Location": location,
      "postalCode": postalCode,

    });
  }
}

