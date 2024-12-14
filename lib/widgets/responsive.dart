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
//       title: 'Invoice Page',
//       home: ProductScreen(),
//     );
//   }
// }
//
// class ProductScreen extends StatefulWidget {
//   @override
//   _ProductScreenState createState() => _ProductScreenState();
// }
//
// class _ProductScreenState extends State<ProductScreen> {
//   final TextEditingController _productController = TextEditingController();
//   List<Map<String, dynamic>> addedProducts = [];
//   List<String> productSuggestions = ['Apple', 'Banana', 'Cherry', 'Date', 'Eggfruit'];
//   Map<String, double> productPrices = {
//     'Apple': 2.0,
//     'Banana': 1.0,
//     'Cherry': 3.0,
//     'Date': 2.5,
//     'Eggfruit': 4.0,
//   };
//
//   void addProduct(String product) {
//     double price = productPrices[product]!;
//     setState(() {
//       addedProducts.add({
//         'name': product,
//         'quantity': 1,
//         'price': price,
//         'amount': price * 1,
//       });
//       _productController.clear();
//     });
//   }
//
//   double getSubTotal() {
//     return addedProducts.fold(0.0, (sum, product) => sum + product['amount']);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Invoice Page'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Container(
//               padding: EdgeInsets.all(8),
//               decoration: BoxDecoration(
//                 border: Border.all(color: Colors.grey),
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: Column(
//                 children: [
//                   TextField(
//                     controller: _productController,
//                     decoration: InputDecoration(
//                       hintText: 'Search product',
//                       contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
//                       border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//                     ),
//                     onChanged: (value) {
//                       setState(() {});
//                     },
//                   ),
//                   if (_productController.text.isNotEmpty)
//                     Container(
//                       margin: EdgeInsets.only(top: 8),
//                       padding: EdgeInsets.all(8),
//                       decoration: BoxDecoration(
//                         color: Colors.grey[100],
//                         borderRadius: BorderRadius.circular(8),
//                         border: Border.all(color: Colors.grey),
//                       ),
//                       child: Column(
//                         children: productSuggestions
//                             .where((product) => product
//                             .toLowerCase()
//                             .contains(_productController.text.toLowerCase()))
//                             .map((product) => GestureDetector(
//                           onTap: () {
//                             addProduct(product);
//                           },
//                           child: Padding(
//                             padding: const EdgeInsets.symmetric(vertical: 8),
//                             child: Row(
//                               children: [
//                                 Icon(Icons.add_circle_outline, color: Colors.blue),
//                                 SizedBox(width: 8),
//                                 Text(product),
//                               ],
//                             ),
//                           ),
//                         ))
//                             .toList(),
//                       ),
//                     ),
//                 ],
//               ),
//             ),
//             SizedBox(height: 16),
//             Expanded(
//               child: Column(
//                 children: [
//                   Row(
//                     children: [
//                       Expanded(flex: 3, child: Text('Product Name', style: TextStyle(fontWeight: FontWeight.bold))),
//                       Expanded(flex: 1, child: Text('Qty', style: TextStyle(fontWeight: FontWeight.bold))),
//                       Expanded(flex: 2, child: Text('Price', style: TextStyle(fontWeight: FontWeight.bold))),
//                       Expanded(flex: 2, child: Text('Amount', style: TextStyle(fontWeight: FontWeight.bold))),
//                     ],
//                   ),
//                   Divider(thickness: 1),
//                   Expanded(
//                     child: ListView.builder(
//                       itemCount: addedProducts.length,
//                       itemBuilder: (context, index) {
//                         final product = addedProducts[index];
//                         return Padding(
//                           padding: const EdgeInsets.symmetric(vertical: 4),
//                           child: Row(
//                             children: [
//                               Expanded(flex: 3, child: Text(product['name'])),
//                               Expanded(flex: 1, child: Text('${product['quantity']}')),
//                               Expanded(flex: 2, child: Text('₹${product['price']}')),
//                               Expanded(flex: 2, child: Text('₹${product['amount'].toStringAsFixed(2)}')),
//                             ],
//                           ),
//                         );
//                       },
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             Divider(height: 32, thickness: 1),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   'Sub Total:',
//                   style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                 ),
//                 Text(
//                   '₹${getSubTotal().toStringAsFixed(2)}',
//                   style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: InvoicePage(),
    );
  }
}

class InvoicePage extends StatefulWidget {
  @override
  _InvoicePageState createState() => _InvoicePageState();
}

class _InvoicePageState extends State<InvoicePage> {
  final List<Map<String, dynamic>> _products = [
    {'name': 'Product 1', 'price': 100},
    {'name': 'Product 2', 'price': 200},
    {'name': 'Product 3', 'price': 300},
  ];

  final List<Map<String, dynamic>> _selectedProducts = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Invoice Page'),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: DataTable(
                    columnSpacing: constraints.maxWidth * 0.05,
                    columns: [
                      DataColumn(label: Text('Product Description')),
                      DataColumn(label: Text('Quantity')),
                      DataColumn(label: Text('Price')),
                      DataColumn(label: Text('Amount')),
                    ],
                    rows: _selectedProducts.map((product) {
                      return DataRow(cells: [
                        DataCell(_buildProductSearchField(product)),
                        DataCell(_buildQuantityField(product)),
                        DataCell(Text(product['price'].toString())),
                        DataCell(Text((product['qty'] * product['price']).toStringAsFixed(2))),
                      ]);
                    }).toList(),
                  ),
                ),
                SizedBox(height: 16.0),
                Align(
                  alignment: Alignment.centerLeft,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _selectedProducts.add({
                          'name': '',
                          'price': 0,
                          'qty': 1,
                        });
                      });
                    },
                    child: Text('Add Product'),
                  ),
                ),
                SizedBox(height: 16.0),
                Container(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'Sub Total: ₹${_calculateSubTotal().toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductSearchField(Map<String, dynamic> product) {
    return Autocomplete<String>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty) {
          return const Iterable<String>.empty();
        }
        return _products
            .where((p) => p['name']
            .toLowerCase()
            .contains(textEditingValue.text.toLowerCase()))
            .map((p) => p['name']);
      },
      onSelected: (String selection) {
        final selectedProduct = _products.firstWhere((p) => p['name'] == selection);
        setState(() {
          product['name'] = selectedProduct['name'];
          product['price'] = selectedProduct['price'];
        });
      },
      fieldViewBuilder: (
          BuildContext context,
          TextEditingController textEditingController,
          FocusNode focusNode,
          VoidCallback onFieldSubmitted,
          ) {
        textEditingController.text = product['name'];
        return TextField(
          controller: textEditingController,
          focusNode: focusNode,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Search Product',
          ),
        );
      },
    );
  }

  Widget _buildQuantityField(Map<String, dynamic> product) {
    return TextField(
      keyboardType: TextInputType.number,
      onChanged: (value) {
        setState(() {
          product['qty'] = int.tryParse(value) ?? 1;
        });
      },
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        hintText: 'Enter Qty',
      ),
    );
  }

  double _calculateSubTotal() {
    return _selectedProducts.fold(0.0, (sum, product) {
      return sum + (product['qty'] * product['price']);
    });
  }
}

