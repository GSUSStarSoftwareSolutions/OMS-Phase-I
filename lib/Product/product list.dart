import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'dart:html';
import 'package:adaptive_scrollbar/adaptive_scrollbar.dart';
import 'package:btb/widgets/Api%20name.dart';
import 'package:btb/widgets/productclass.dart' as ord;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import '../customer login/home/home.dart';
import '../widgets/confirmdialog.dart';
import '../widgets/custom loading.dart';
import '../widgets/no datafound.dart';
import '../widgets/pagination.dart';
import '../widgets/productsap.dart' as ord;
import '../widgets/text_style.dart';

void main() => runApp(const MaterialApp(
  debugShowCheckedModeBanner: false,
  home: ProductPage(
    product: null,
  ),
));

class ProductPage extends StatefulWidget {
  const ProductPage({super.key, required this.product});

  final ord.Product? product;

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage>
    with SingleTickerProviderStateMixin {
  final List<String> _sortOrder = List.generate(5, (index) => 'asc');
  List<String> columns = [
    'Product Name',
    'Category Name',
    'Product Type',
    'Price',
    'Base Unit'
  ];
  List<double> columnWidths = [135, 120, 125, 80, 100];
  List<bool> columnSortState = [true, true, true, true, true];
  late ord.ProductData productData;
  bool isHomeSelected = false;
  bool isOrdersSelected = false;
  Timer? _searchDebounceTimer;
  final ScrollController horizontalScroll = ScrollController();
  late AnimationController _controller;
  final bool _isHovered1 = false;
  String companyname = window.sessionStorage["company Name"] ?? " ";
  final Map<String, bool> _isHovered = {
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
  late Animation<double> _shakeAnimation;
  String _searchText = '';
  final String _category = '';
  late TextEditingController _dateController;
  final String _subCategory = '';
  int startIndex = 0;
  List<ord.ProductData> filteredProducts = [];
  String? dropdownValue1 = 'Category';
  String token = window.sessionStorage["token"] ?? " ";
  String? dropdownValue2 = 'Sub Category';
  bool _hasShownPopup = false;
  final ScrollController _scrollController = ScrollController();
  int currentPage = 1;
  int itemsPerPage = 10;
  int totalItems = 0;
  int totalPages = 0;
  bool _loading = false;
  bool isLoading = false;
  List<ord.ProductData> productList = [];
  Future<void> fetchProducts(int page, int itemsPerPage) async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
    });
    try {
      final response = await http.get(
        Uri.parse(
          '$apicall/public/productmaster/get_all_s4hana_productmaster?page=$page&limit=$itemsPerPage',
        ),
        headers: {
          "Content-type": "application/json",
          "Authorization": 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        List<ord.ProductData> products = [];
        if (jsonData != null) {
          products = jsonData.map<ord.ProductData>((item) {
            return ord.ProductData(
              product: item['product'] ?? '',
              categoryName: item['categoryName'] ?? '',
              productType: item['productType'] ?? '',
              baseUnit: item['baseUnit'] ?? '',
              productDescription: item['productDescription'] ?? '',
              standardPrice: item['standardPrice'] ?? 0,
              currency: item['currency'] ?? 'INR',
            );
          }).toList();

          setState(() {
            productList = products;
            totalPages =
                (products.length / itemsPerPage).ceil();

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
  void _updateSearch(String searchText) {
    setState(() {
      _searchText = searchText;
      currentPage = 1;
      _filterAndPaginateProducts();
    });
  }

  void _goToPreviousPage() {
    if (currentPage > 1) {
      if (filteredProducts.length > itemsPerPage) {
        setState(() {
          currentPage--;
        });
      }
    }
  }

  void _goToNextPage() {
    if (currentPage < totalPages) {
      if (filteredProducts.length > currentPage * itemsPerPage) {
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
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          contentPadding: EdgeInsets.zero,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
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
                    const Icon(Icons.warning, color: Colors.orange, size: 50),
                    const SizedBox(height: 16),
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

  @override
  void initState() {
    super.initState();
    fetchProducts(currentPage, itemsPerPage);
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 5)
        .chain(CurveTween(curve: Curves.elasticIn))
        .animate(_controller)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _controller.reverse();
        } else if (status == AnimationStatus.dismissed) {
          _controller.forward();
        }
      });
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
          body: LayoutBuilder(builder: (context, constraints) {
            double maxWidth = constraints.maxWidth;
            double maxHeight = constraints.maxHeight;
            return Stack(
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
                                padding: EdgeInsets.only(right: 10, top: 10),
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
                    top: 60,
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: SingleChildScrollView(
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Container(
                            height: 1400,
                            width: 200,
                            color: Colors.white,
                            padding: const EdgeInsets.only(
                                left: 15, top: 10, right: 15),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: _buildMenuItems(context),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  VerticalDividerWidget(
                    height: maxHeight,
                    color: const Color(0x29000000),
                  ),
                } else ...{
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
                      if (constraints.maxWidth >= 1350) ...{
                        Expanded(
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  const SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 30, top: 10),
                                        child: Text(
                                          'Product List',
                                          style: TextStyles.heading,
                                        ),
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
                                            height: 690,
                                            width: maxWidth * 0.8,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                              BorderRadius.circular(2),
                                              boxShadow: [
                                                BoxShadow(
                                                  color:
                                                  Colors.grey.withOpacity(0.1),
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
                                                      controller: _scrollController,
                                                      thickness: 6,
                                                      thumbVisibility: true,
                                                      child: SingleChildScrollView(
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
                                                    padding: const EdgeInsets.only(
                                                        right: 30),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                      children: [
                                                        PaginationControls(
                                                          currentPage: currentPage,
                                                          totalPages:
                                                          filteredProducts
                                                              .length >
                                                              itemsPerPage
                                                              ? totalPages
                                                              : 1,
                                                          onPreviousPage:
                                                          _goToPreviousPage,
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
                      } else ...{
                        Expanded(
                            child: AdaptiveScrollbar(
                              position: ScrollbarPosition.bottom,
                              controller: horizontalScroll,
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
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 30, top: 20),
                                            child: Text(
                                              'Product List',
                                              style: TextStyles.heading,
                                            ),
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
                                                height: 690,
                                                width: 1100,
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                  BorderRadius.circular(2),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.grey
                                                          .withOpacity(0.1),
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
                                                            child:
                                                            buildDataTable2(),
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
                                                              totalPages:
                                                              filteredProducts
                                                                  .length >
                                                                  itemsPerPage
                                                                  ? totalPages
                                                                  : 1,
                                                              onPreviousPage:
                                                              _goToPreviousPage,
                                                              onNextPage:
                                                              _goToNextPage,
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
                const SizedBox(
                  height: 50,
                ),
              ],
            );
          })),
    );
  }

  Widget buildSearchField() {
    return LayoutBuilder(builder: (context, constraints) {
      return ConstrainedBox(
        constraints: const BoxConstraints(),
        child: Container(
          padding: const EdgeInsets.only(
            left: 20,
            right: 20,
            top: 2,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: constraints.maxWidth * 0.261,
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
                              style: GoogleFonts.inter(
                                  color: Colors.black, fontSize: 13),
                              decoration: InputDecoration(
                                hintText: 'Search by product name',
                                hintStyle: const TextStyle(
                                    color: Colors.grey, fontSize: 13),
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 3, horizontal: 5),
                                border: InputBorder.none,
                                suffixIcon: Padding(
                                  padding:
                                  const EdgeInsets.only(left: 10, right: 5),
                                  child: Image.asset(
                                    'images/search.png',
                                  ),
                                ),
                              ),
                              onChanged: _updateSearch,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget buildDataTable() {
    if (isLoading) {
      var width = MediaQuery.of(context).size.width;
      var height = MediaQuery.of(context).size.height;
      _loading = true;
      return Padding(
        padding: EdgeInsets.only(bottom: height * 0.100, left: width * 0.300,     top: height * 0.100,),
        child: CustomLoadingIcon(),
      );
    }

    if (filteredProducts.isEmpty) {
      var mediaQuery = MediaQuery.of(context).size.width;
      return Column(
        children: [
          Container(
            width: mediaQuery - 250,
            decoration: const BoxDecoration(
                color: Color(0xFFF7F7F7),
                border: Border.symmetric(
                    horizontal: BorderSide(color: Colors.grey, width: 0.5))),
            child: DataTable(
                showCheckboxColumn: false,
                headingRowHeight: 40,
                columns: [
                  DataColumn(
                    label: Text(
                      'Product Name',
                      style: TextStyles.subhead,
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Category',
                      style: TextStyles.subhead,
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Sub Category',
                      style: TextStyles.subhead,
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Unit',
                      style: TextStyles.subhead,
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Price',
                      style: TextStyles.subhead,
                    ),
                  ),
                ],
                rows: const []),
          ),
          Padding(
            padding: const EdgeInsets.only(
                top: 150, left: 130, bottom: 350, right: 150),
            child: CustomDatafound(),
          ),
        ],
      );
    }
    return LayoutBuilder(builder: (context, constraints) {
      var mediaQuery = MediaQuery.of(context).size.width;
      return Column(
        children: [
          Container(
            width: mediaQuery - 250,
            decoration: const BoxDecoration(
              color: Color(0xFFF7F7F7),
              border: Border.symmetric(
                  horizontal: BorderSide(color: Colors.grey, width: 0.5)),
            ),
            child: SizedBox(
              width: mediaQuery * 0.2,
              child: DataTable(
                  showCheckboxColumn: false,
                  headingRowHeight: 40,
                  columns: columns.map((column) {
                    return DataColumn(
                      label: Stack(
                        children: [
                          Container(
                            padding: null,
                            width: columnWidths[columns.indexOf(column)],
                            child: Row(
                              children: [
                                Text(
                                  column,
                                  style: TextStyles.subhead,
                                ),
                                IconButton(
                                  icon: _sortOrder[columns.indexOf(column)] ==
                                      'asc'
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
                                      _sortOrder[columns.indexOf(column)] =
                                      _sortOrder[columns.indexOf(column)] ==
                                          'asc'
                                          ? 'desc'
                                          : 'asc';
                                      _sortProducts(columns.indexOf(column),
                                          _sortOrder[columns.indexOf(column)]);
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      onSort: (columnIndex, ascending) {
                        _sortOrder;
                      },
                    );
                  }).toList(),
                  rows: List.generate(
                      math.min(
                          itemsPerPage,
                          filteredProducts.length -
                              (currentPage - 1) * itemsPerPage), (index) {
                    final product = filteredProducts[
                    (currentPage - 1) * itemsPerPage + index];
                    return DataRow(
                      color: MaterialStateProperty.resolveWith<Color>((states) {
                        if (states.contains(MaterialState.hovered)) {
                          return Colors.blue.shade500.withOpacity(
                              0.8); // Add some opacity to the dark blue
                        } else {
                          return Colors.white.withOpacity(0.9);
                        }
                      }),
                      cells: [
                        DataCell(
                          SizedBox(
                            width: columnWidths[0],
                            child: Text(
                              product.productDescription.length > 25
                                  ? '${product.productDescription.substring(0, 25)}...'
                                  : product.productDescription,
                              style: TextStyles.body,
                            ),
                          ),
                        ),
                        DataCell(
                          SizedBox(
                            width: columnWidths[1],
                            child: Text(
                              product.categoryName,
                              style: TextStyles.body,
                            ),
                          ),
                        ),
                        DataCell(
                          SizedBox(
                            width: columnWidths[2],
                            child: Text(
                              product.productType,
                              style: TextStyles.body,
                            ),
                          ),
                        ),
                        DataCell(
                          SizedBox(
                            width: columnWidths[3],
                            child: Text(
                              product.standardPrice.toString(),
                              style: TextStyles.body,
                            ),
                          ),
                        ),
                        DataCell(
                          SizedBox(
                            width: columnWidths[4],
                            child: Text(
                              product.baseUnit.toString(),
                              style: TextStyles.body,
                            ),
                          ),
                        ),
                      ],
                      onSelectChanged: (selected) {
                        if (selected != null && selected) {
                          if (filteredProducts.length <= 9) {
                          } else {}
                        }
                      },
                    );
                  })),
            ),
          ),
        ],
      );
    });
  }

  Widget buildDataTable2() {
    if (isLoading) {
      var width = MediaQuery.of(context).size.width;
      var height = MediaQuery.of(context).size.height;
      _loading = true;
      return Padding(
        padding: EdgeInsets.only(bottom: height * 0.100, left: width * 0.300,top: height * 0.100,),
        child: CustomLoadingIcon(),
      );
    }
    if (filteredProducts.isEmpty) {
      return Column(
        children: [
          Container(
            width: 1100,
            decoration: const BoxDecoration(
                color: Color(0xFFF7F7F7),
                border: Border.symmetric(
                    horizontal: BorderSide(color: Colors.grey, width: 0.5))),
            child: DataTable(
              showCheckboxColumn: false,
              headingRowHeight: 40,
              columns: [
                DataColumn(
                  label: Text(
                    'Product Name',
                    style: TextStyles.subhead,
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Category',
                    style: TextStyles.subhead,
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Sub Category',
                    style: TextStyles.subhead,
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Unit',
                    style: TextStyles.subhead,
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Price',
                    style: TextStyles.subhead,
                  ),
                ),
              ],
              rows: const [],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
                top: 150, left: 130, bottom: 350, right: 150),
            child: CustomDatafound(),
          ),
        ],
      );
    }

    return LayoutBuilder(builder: (context, constraints) {
      return Column(
        children: [
          Container(
            width: 1100,
            decoration: const BoxDecoration(
              color: Color(0xFFF7F7F7),
              border: Border.symmetric(
                  horizontal: BorderSide(color: Colors.grey, width: 0.5)),
            ),
            child: SizedBox(
              child: DataTable(
                  showCheckboxColumn: false,
                  headingRowHeight: 40,
                  columns: columns.map((column) {
                    return DataColumn(
                      label: Stack(
                        children: [
                          Container(
                            padding: null,
                            width: columnWidths[columns.indexOf(column)],
                            child: Row(
                              children: [
                                Text(
                                  column,
                                  style: TextStyles.subhead,
                                ),
                                IconButton(
                                  icon: _sortOrder[columns.indexOf(column)] ==
                                      'asc'
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
                                      _sortOrder[columns.indexOf(column)] =
                                      _sortOrder[columns.indexOf(column)] ==
                                          'asc'
                                          ? 'desc'
                                          : 'asc';
                                      _sortProducts(columns.indexOf(column),
                                          _sortOrder[columns.indexOf(column)]);
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      onSort: (columnIndex, ascending) {
                        _sortOrder;
                      },
                    );
                  }).toList(),
                  rows: List.generate(
                      math.min(
                          itemsPerPage,
                          filteredProducts.length -
                              (currentPage - 1) * itemsPerPage), (index) {
                    final product = filteredProducts[
                    (currentPage - 1) * itemsPerPage + index];
                    return DataRow(
                      color: MaterialStateProperty.resolveWith<Color>((states) {
                        if (states.contains(MaterialState.hovered)) {
                          return Colors.blue.shade500.withOpacity(
                              0.8); // Add some opacity to the dark blue
                        } else {
                          return Colors.white.withOpacity(0.9);
                        }
                      }),
                      cells: [
                        DataCell(
                          SizedBox(
                            width: columnWidths[0],
                            // Same dynamic width as column headers
                            child: Text(
                              product.productDescription,
                              style: TextStyles.body,
                            ),
                          ),
                        ),
                        DataCell(
                          SizedBox(
                            width: columnWidths[1],
                            child: Text(
                              product.categoryName,
                              style: TextStyles.body,
                            ),
                          ),
                        ),
                        DataCell(
                          SizedBox(
                            width: columnWidths[2],
                            child: Text(
                              product.productType,
                              style: TextStyles.body,
                            ),
                          ),
                        ),
                        DataCell(
                          SizedBox(
                            width: columnWidths[3],
                            child: Text(
                              product.standardPrice.toString(),
                              style: TextStyles.body,
                            ),
                          ),
                        ),
                        DataCell(
                          SizedBox(
                            width: columnWidths[4],
                            child: Text(
                              product.baseUnit.toString(),
                              style: TextStyles.body,
                            ),
                          ),
                        ),
                      ],
                      onSelectChanged: (selected) {
                        if (selected != null && selected) {
                          if (filteredProducts.length <= 9) {
                          } else {}
                        }
                      },
                    );
                  })),
            ),
          ),
        ],
      );
    });
  }

  List<Widget> _buildMenuItems(BuildContext context) {
    return [
      Column(
        children: [
          const SizedBox(
            height: 10,
          ),
          _buildMenuItem(
              'Home', Icons.home_outlined, Colors.blue[900]!, '/Home'),
          const SizedBox(
            height: 6,
          ),
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
            child: _buildMenuItem('Product', Icons.production_quantity_limits,
                Colors.white, '/Customer'),
          ),
          _buildMenuItem('Customer', Icons.account_circle_outlined,
              Colors.white, '/Customer'),
          _buildMenuItem('Orders', Icons.warehouse_outlined, Colors.blue[900]!,
              '/Order_List'),
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
    title == 'Product' ? _isHovered[title] = false : _isHovered[title] = false;
    title == 'Product' ? iconColor = Colors.white : Colors.black;
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
            padding: const EdgeInsets.only(left: 10, top: 2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(
                  icon,
                  color: iconColor,
                  size: 20,
                ),
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
  void _sortProducts(int columnIndex, String sortOrder) {
    if (sortOrder == 'asc') {
      filteredProducts.sort((a, b) {
        switch (columnIndex) {
          case 0:
            return a.productDescription
                .toLowerCase()
                .compareTo(b.productDescription.toLowerCase());
          case 1:
            return a.categoryName.compareTo(b.categoryName);
          case 2:
            return a.productType.compareTo(b.productType);
          case 3:
            return a.baseUnit.compareTo(b.baseUnit);
          case 4:
            return a.currency.compareTo(b.currency);
          default:
            return 0;
        }
      });
    } else if (sortOrder == 'desc') {
      filteredProducts.sort((a, b) {
        switch (columnIndex) {
          case 0:
            return b.productDescription
                .toLowerCase()
                .compareTo(a.productDescription.toLowerCase());
          case 1:
            return b.categoryName.compareTo(a.categoryName);
          case 2:
            return b.productType.compareTo(a.productType);
          case 3:
            return b.baseUnit.compareTo(a.baseUnit);
          case 4:
            return b.currency.compareTo(a.currency);
          default:
            return 0;
        }
      });
    }
    setState(() {});
  }
  void _filterAndPaginateProducts() {
    filteredProducts = productList.where((product) {
      final matchesSearchText = product.productDescription
          .toLowerCase()
          .contains(_searchText.toLowerCase());
      if (_category.isEmpty && _subCategory.isEmpty) {
        return matchesSearchText;
      }
      if (_category == 'Category' && _subCategory == 'Sub Category') {
        return matchesSearchText;
      }
      if (_category == 'Category' && _subCategory.isEmpty) {
        return matchesSearchText;
      }
      if (_subCategory == 'Sub Category' && _category.isEmpty) {
        return matchesSearchText;
      }
      if (_category == 'Category' && _subCategory.isNotEmpty) {
        return matchesSearchText &&
            product.productType == _subCategory;
      }
      if (_category.isNotEmpty && _subCategory == 'Sub Category') {
        return matchesSearchText &&
            product.categoryName == _category;
      }
      if (_category.isEmpty && _subCategory.isNotEmpty) {
        return matchesSearchText &&
            product.productType == _subCategory;
      }
      if (_category.isNotEmpty && _subCategory.isEmpty) {
        return matchesSearchText &&
            product.categoryName == _category;
      }
      return matchesSearchText &&
          (product.categoryName == _category &&
              product.productType == _subCategory);
    }).toList();
    totalPages = (filteredProducts.length / itemsPerPage).ceil();
    setState(() {
      currentPage = 1;
    });
  }
}

