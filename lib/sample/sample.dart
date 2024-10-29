// // // import 'package:flutter/material.dart';
// // //
// // // void main() {
// // //   runApp(MyApp());
// // // }
// // //
// // // class MyApp extends StatelessWidget {
// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return MaterialApp(
// // //       home: Scaffold(
// // //         backgroundColor: Colors.white,
// // //         appBar: AppBar(
// // //           title: Text('Dropdowns'),
// // //         ),
// // //         body: Center(
// // //           child: Row(
// // //             mainAxisAlignment: MainAxisAlignment.spaceAround,
// // //             children: [
// // //               SizedBox(
// // //                 width: 200, // Set a fixed width for the dropdown
// // //                 child: DropdownButtonFormField<String>(
// // //                   decoration: InputDecoration(
// // //                     border: OutlineInputBorder(
// // //                       borderRadius: BorderRadius.circular(25),
// // //                       borderSide: BorderSide.none,
// // //                     ),
// // //                     filled: true,
// // //                     fillColor: Colors.white,
// // //                   ),
// // //                   value: 'Select FY',
// // //                   items: ['Select FY', 'FY2023', 'FY2024'].map((String value) {
// // //                     return DropdownMenuItem<String>(
// // //                       value: value,
// // //                       child: Text(value),
// // //                     );
// // //                   }).toList(),
// // //                   onChanged: (String? newValue) {
// // //                     print(newValue);
// // //                   },
// // //                   icon: Icon(Icons.arrow_drop_down_circle_outlined,
// // //                       color: Colors.blue),
// // //                   iconSize: 30.0,
// // //                   style: TextStyle(color: Colors.black, fontSize: 16.0),
// // //                 ),
// // //               ),
// // //               SizedBox(
// // //                 width: 152, // Set a fixed width for the dropdown
// // //                 height: 30,
// // //                 child: DropdownButtonFormField<String>(
// // //                   decoration: const InputDecoration(
// // //                     // border: InputBorder.none,
// // //                     border: OutlineInputBorder(
// // //                     borderSide: BorderSide(color: Colors.lightBlue)
// // //                     ),
// // //                     filled: true,
// // //                     hintText: 'Select Year',
// // //                   //  hintStyle,
// // //                     fillColor: Colors.white,
// // //                     contentPadding: EdgeInsets.symmetric(vertical: 5,horizontal: 5)
// // //                   ),
// // //                   value: 'Select Region',
// // //                   items: ['Select Region', 'Region A', 'Region B']
// // //                       .map((String value) {
// // //                     return DropdownMenuItem<String>(
// // //                       value: value,
// // //                       child: Text(value),
// // //                     );
// // //                   }).toList(),
// // //                   onChanged: (String? newValue) {
// // //                     print(newValue);
// // //                   },
// // //                   icon: Icon(Icons.arrow_drop_down_circle,
// // //                       color: Colors.blue),
// // //                   iconSize: 15.0,
// // //                   style: TextStyle(color: Colors.black, fontSize: 12.0),
// // //                 ),
// // //               ),
// // //             ],
// // //           ),
// // //         ),
// // //       ),
// // //     );
// // //   }
// // // }
// // //
// // //
// //
// //
// // import 'package:flutter/material.dart';
// //
// // void main() {
// //   runApp(MyApp());
// // }
// //
// // class MyApp extends StatelessWidget {
// //   @override
// //   Widget build(BuildContext context) {
// //     return MaterialApp(
// //       debugShowCheckedModeBanner: false,
// //       home: Scaffold(
// //         appBar: AppBar(title: Text('Collapsible Sidebar Example')),
// //         body: Row(
// //           children: [
// //             Sidebar(),
// //             Expanded(
// //               child: Center(
// //                 child: Text('Main Content Area'),
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }
// //
// // class Sidebar extends StatefulWidget {
// //   @override
// //   _SidebarState createState() => _SidebarState();
// // }
// //
// // class _SidebarState extends State<Sidebar> {
// //   bool isExpanded = true;
// //   int? hoveredIndex;
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Align(
// //       alignment: Alignment.topLeft,
// //       child: Container(
// //         height: MediaQuery.of(context).size.height,
// //         width: isExpanded ? 200 : 70, // Adjust width based on state
// //         color: const Color(0xFFF7F6FA),
// //         padding: const EdgeInsets.only(top: 30),
// //         child: Column(
// //           crossAxisAlignment: CrossAxisAlignment.start,
// //           children: [
// //             _buildMenuItem(
// //               index: 0,
// //               icon: Icons.dashboard,
// //               label: 'Home',
// //               onTap: () {
// //                 // Handle Home navigation
// //               },
// //             ),
// //             const SizedBox(height: 20),
// //             _buildMenuItem(
// //               index: 1,
// //               icon: Icons.image_outlined,
// //               label: 'Products',
// //               onTap: () {
// //                 // Handle Products navigation
// //               },
// //             ),
// //             const SizedBox(height: 20),
// //             _buildMenuItem(
// //               index: 2,
// //               icon: Icons.warehouse,
// //               label: 'Orders',
// //               onTap: () {
// //                 // Handle Orders navigation
// //               },
// //             ),
// //             const SizedBox(height: 20),
// //             _buildMenuItem(
// //               index: 3,
// //               icon: Icons.fire_truck_outlined,
// //               label: 'Delivery',
// //               onTap: () {
// //                 // Handle Delivery navigation
// //               },
// //             ),
// //             const SizedBox(height: 20),
// //             _buildMenuItem(
// //               index: 4,
// //               icon: Icons.document_scanner_rounded,
// //               label: 'Invoice',
// //               onTap: () {
// //                 // Handle Invoice navigation
// //               },
// //             ),
// //             const SizedBox(height: 20),
// //             _buildMenuItem(
// //               index: 5,
// //               icon: Icons.payment_outlined,
// //               label: 'Payment',
// //               onTap: () {
// //                 // Handle Payment navigation
// //               },
// //             ),
// //             const SizedBox(height: 20),
// //             _buildMenuItem(
// //               index: 6,
// //               icon: Icons.backspace_sharp,
// //               label: 'Return',
// //               onTap: () {
// //                 // Handle Return navigation
// //               },
// //             ),
// //             const SizedBox(height: 20),
// //             _buildMenuItem(
// //               index: 7,
// //               icon: Icons.insert_chart,
// //               label: 'Reports',
// //               onTap: () {
// //                 // Handle Reports navigation
// //               },
// //             ),
// //             Spacer(),
// //             IconButton(
// //               icon: Icon(isExpanded
// //                   ? Icons.arrow_back_ios
// //                   : Icons.arrow_forward_ios),
// //               onPressed: () {
// //                 setState(() {
// //                   isExpanded = !isExpanded;
// //                 });
// //               },
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// //
// //   Widget _buildMenuItem({
// //     required int index,
// //     required IconData icon,
// //     required String label,
// //     required VoidCallback onTap,
// //   }) {
// //     return MouseRegion(
// //       onEnter: (_) => setState(() => hoveredIndex = index),
// //       onExit: (_) => setState(() => hoveredIndex = null),
// //       child: InkWell(
// //         onTap: () {
// //           if (!isExpanded) {
// //             setState(() {
// //               isExpanded = true;
// //             });
// //           }
// //           onTap();
// //         },
// //         child: Container(
// //           color: hoveredIndex == index ? Colors.blue.withOpacity(0.3) : Colors.transparent, // Change color on hover
// //           padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
// //           child: Row(
// //             children: [
// //               Icon(icon, color: Colors.indigo[900]),
// //               if (isExpanded)
// //                 Padding(
// //                   padding: const EdgeInsets.only(left: 8.0),
// //                   child: Text(
// //                     label,
// //                     style: TextStyle(color: Colors.indigo[900], fontSize: 16),
// //                   ),
// //                 ),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }
// //
//
//
// import 'dart:async';
// import 'package:flutter/material.dart';
//
// void main() {
//   runApp(MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter DataTable Demo',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//         hoverColor: Colors.blueAccent, // Add this line
//       ),
//       home: ProductTable(),
//     );
//   }
// }
//
// class Product {
//   final String productName;
//   final String category;
//   final String subCategory;
//   final String unit;
//   final double price;
//
//   Product({
//     required this.productName,
//     required this.category,
//     required this.subCategory,
//     required this.unit,
//     required this.price,
//   });
// }
//
// class ProductTable extends StatefulWidget {
//   @override
//   _ProductTableState createState() => _ProductTableState();
// }
//
// class _ProductTableState extends State<ProductTable> {
//   // Track the currently clicked product and blinking state
//   var _selectedProduct;
//   var _blinkProduct;
//   Timer? _blinkTimer;
//
//   // Define blink duration and interval
//   static const blinkDuration = Duration(seconds: 1);
//   static const blinkInterval = Duration(milliseconds: 500);
//
//   @override
//   void dispose() {
//     // Cancel the timer when the widget is disposed
//     _blinkTimer?.cancel();
//     super.dispose();
//   }
//
//   void _startBlinking(Product product) {
//     setState(() {
//       _blinkProduct = product;
//     });
//
//     // Start blinking
//     _blinkTimer = Timer.periodic(blinkInterval, (timer) {
//       if (mounted) {
//         setState(() {
//           _blinkProduct = (_blinkProduct == product) ? null : product;
//         });
//       }
//     });
//
//     // Stop blinking after a fixed duration
//     Future.delayed(blinkDuration, () {
//       _blinkTimer?.cancel();
//       if (mounted) {
//         setState(() {
//           _blinkProduct = null;
//         });
//       }
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final filteredProducts = [
//       Product(productName: 'Camera', category: 'Electronics', subCategory: 'Gadgets', unit: 'Piece', price: 299.99),
//       Product(productName: 'Phone', category: 'Electronics', subCategory: 'Smartphones', unit: 'Piece', price: 699.99),
//       Product(productName: 'Laptop', category: 'Computers', subCategory: 'Laptops', unit: 'Piece', price: 999.99),
//     ];
//
//     return Scaffold(
//         appBar: AppBar(
//         title: Text('Product Table'),
//     ),
//     body: SingleChildScrollView(
//     scrollDirection: Axis.horizontal,
//     child: DataTable(
//     columns: [
//     DataColumn(label: Text('Product Name')),
//     DataColumn(label: Text('Category')),
//     DataColumn(label: Text('Subcategory')),
//     DataColumn(label: Text('Unit')),
//     DataColumn(label: Text('Price')),
//     ],
//     rows: filteredProducts.map((product) {
//     final isSelected = _selectedProduct == product;
//     final isBlinking = _blinkProduct == product;
//     final rowColor = isBlinking ? Colors.lightBlueAccent : (isSelected ? Colors.grey[200]! : Colors.white);
//
//     return DataRow(
//     color: MaterialStateColor.resolveWith(
//     (states) => states.contains(MaterialState.hovered) ? Colors.blueAccent : rowColor,
//     ),
//     cells: [
//     DataCell(
//     GestureDetector(
//     onTap: () {
//     setState(() {
//     _selectedProduct = product;
//     });
//     _startBlinking(product); // Start blinking effect
//     // Replace with your navigation logic
//     print('Clicked product: ${product.productName}');
//     },
//     child: Container(
//     padding: const EdgeInsets.all(8.0),
//     child: Text(
//     product.productName,
//     style: TextStyle(
//     fontSize: 16,
//     color: isSelected ? Colors.deepOrange[200] : const Color(0xFFFFB315),
//     ),
//     ),
//     ),
//     ),
//     ),
//     DataCell(
//     GestureDetector(
//     onTap: () {
//     setState(() {
//     _selectedProduct = product;
//     });
//     _startBlinking(product); // Start blinking effect
//     // Replace with your navigation logic
//     print('Clicked product: ${product.productName}');
//     },
//     child: Container(
//     padding: const EdgeInsets.all(8.0),
//     child: Text(
//     product.category,
//     style: const TextStyle(color: Color(0xFFA6A6A6), fontSize: 16),
//     ),
//     ),
//     ),
//     ),
//     DataCell(
//     GestureDetector(
//     onTap: () {
//     setState(() {
//     _selectedProduct = product;
//     });
//     _startBlinking(product); // Start blinking effect
//     // Replace with your navigation logic
//     print('Clicked product: ${product.productName}');
//     },
//     child: Container(
//     padding: const EdgeInsets.all(8.0),
//     child: Text(
//     product.category,
//     style: const TextStyle(color: Color(0xFFA6A6A6), fontSize: 16),
//     ),
//     ),
//     ),
//     ),// Replace with your navigation logic
//       DataCell(
//       GestureDetector(
//       onTap: () {
//       setState(() {
//       _selectedProduct = product;
//       });
//       _startBlinking(product); // Start blinking effect
//       // Replace with your navigation logic
//       print('Clicked product: ${product.productName}');
//       },
//       child: Container(
//       padding: const EdgeInsets.all(8.0),
//       child: Text(
//       product.unit,
//       style: const TextStyle(color: Color(0xFFA6A6A6), fontSize: 16),
//       ),
//       ),
//       ),
//       ),
//       DataCell(
//       GestureDetector(
//       onTap: () {
//       setState(() {
//       _selectedProduct = product;
//       });
//       _startBlinking(product); // Start blinking effect
//       // Replace with your navigation logic
//       print('Clicked product: ${product.productName}');
//       },
//       child: Container(
//       padding: const EdgeInsets.all(8.0),
//       child: Text(
//       product.price.toString(),
//       style: const TextStyle(color: Color(0xFFA6A6A6), fontSize: 16),
//       ),
//       ),
//       ),
//       ),
//       ],
//       );
//     }).toList(),
//     ),
//     ),
//     );
//   }
// }




//
// import 'package:flutter/material.dart';
//
// void main() {
//   runApp(MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         appBar: AppBar(
//           title: Text('Clickable DataTable Rows'),
//         ),
//         body: MyDataTable(),
//       ),
//     );
//   }
// }
//
// class MyDataTable extends StatefulWidget {
//   @override
//   _MyDataTableState createState() => _MyDataTableState();
// }
//
// class _MyDataTableState extends State<MyDataTable> {
//   int? _selectedRowIndex;
//   List<bool> _isHovered = List.generate(10, (index) => false);
//
//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       scrollDirection: Axis.horizontal,
//       child: DataTable(
//
//         showCheckboxColumn: false,
//         columns: const [
//           DataColumn(label: Text('Name')),
//           DataColumn(label: Text('Age')),
//           DataColumn(label: Text('City')),
//         ],
//         rows: List.generate(
//           10,
//               (index) =>
//
//                   DataRow(
//             color: _selectedRowIndex == index
//                 ? MaterialStateProperty.all(Colors.blue.withOpacity(0.2))
//                 : _isHovered[index]
//                 ? MaterialStateProperty.all(Colors.blue.withOpacity(0.1))
//                 : MaterialStateProperty.all(Colors.transparent),
//             cells: [
//               DataCell(Text('Person $index')),
//               DataCell(Text('${20 + index}')),
//               DataCell(Text('City $index')),
//             ],
//             onSelectChanged: (selected) {
//               setState(() {
//                 _selectedRowIndex = selected! ? index : null;
//               });
//             },
//           ),
//         ),
//       ),
//     );
//   }
//
//   void _onMouseEnter(int index) {
//     setState(() {
//       _isHovered[index] = true;
//     });
//   }
//
//   void _onMouseExit(int index) {
//     setState(() {
//       _isHovered[index] = false;
//     });
//   }
// }
//
// import 'package:flutter/material.dart';
//
// void main() {
//   runApp(MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         appBar: AppBar(
//           title: Text('Hover Effect on Table Row'),
//         ),
//         body: DataTable(
//           showCheckboxColumn: false,
//           columns: [
//             DataColumn(label: Text('Column 1')),
//             DataColumn(label: Text('Column 2')),
//           ],
//           rows: List.generate(
//             10,
//                 (index) => DataRow(
//               cells: [
//                 DataCell(Text('Cell $index')),
//                 DataCell(Text('Cell $index')),
//               ],
//               onSelectChanged: (selected) {
//                 if (selected != null && selected) {
//                   print('Row $index pressed');
//                 }
//               },
//               color: MaterialStateProperty.resolveWith<Color>((states) {
//                 if (states.contains(MaterialState.hovered)) {
//                   return Colors.blue.withOpacity(0.1);
//                 } else {
//                   return Colors.transparent;
//                 }
//               }),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }




import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(home:MyApp() ,));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Alert Box Demo',
      home: Scaffold(
        appBar: AppBar(
          title: Text('Alert Box Demo'),
        ),
        body: Center(
          child: ElevatedButton(
            child: Text('Show Alert'),
            onPressed: () {
              _showAlert(context);
            },
          ),
        ),
      ),
    );
  }

  void _showAlert(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return
          AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            contentPadding: EdgeInsets.zero,
            content:
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Close Button
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon: Icon(Icons.close, color: Colors.red),
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
                      Icon(Icons.check_circle_rounded, color: Colors.green, size: 50),
                      SizedBox(height: 16),
                      // Confirmation Message
                      Text(
                        'Product Added Successfully',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 20),
                      // Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [

                          ElevatedButton(
                            onPressed: () {
                              // Handle No action
                              // Navigator.of(context).pop();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              side: BorderSide(color: Colors.blue),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                            child: Text(
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
  }
}





