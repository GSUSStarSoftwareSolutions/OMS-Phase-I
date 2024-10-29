import 'dart:convert';
import 'package:btb/admin/Api%20name.dart';
import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:http/http.dart' as http;
import '../Order Module/firstpage.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  late  final discount = 0;
  @override
  Widget build(BuildContext context) {
    String discount;
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('PDF Downloader'),
        ),
        body: Center(
          child: ElevatedButton(
            onPressed: () {
              downloadPdf();
            },
            child: Text('Download PDF'),
          ),
        ),
      ),
    );
  }

  Future<List<dynamic>> _fetchAllProductMaster() async {
    final String token = 'eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJkaGFuYXNla2FyIiwiUm9sZXMiOlt7ImF1dGhvcml0eSI6ImRldmVsb3BlciJ9XSwiZXhwIjoxNzIzMTE0OTQ0LCJpYXQiOjE3MjMxMDc3NDR9.1UxLslHM3GivBHoBr8pS02OxD6dC5IRG4ryxiUdgzIJmFjSCwftf6Kme4rPLb-ZOjzOoAaxueSzKxiLmjnmSFg';
    try {
      final response = await http.get(
        Uri.parse('$apicall/productmaster/get_all_productmaster'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Product Master Data:');
        print(data);
        // print('discount');
        // print(data['discount']);
        return data;
      } else {
        print('Failed to fetch product master data.');
        return [];
      }
    } catch (e) {
      print('Error fetching product master data: $e');
      return [];
    }
  }


  Future downloadPdf() async {
    final String orderId = 'ORD_03534';
    try {
      final productMasterData = await _fetchAllProductMaster();
      final orderDetails = await _fetchOrderDetails(orderId);
      for (var product in productMasterData) {
        for (var item in orderDetails!.items) {
          if (product['productName'] == item['productName']) {
            item['tax'] = product['tax'];
            print('price');
            print(item['price']);
            item['discount'] = product['discount'];
            item['ActualTotalAmount'] = item['price'] * item['qty'];
           // item['discountAmount'] = item['AcutaltotalAmount'] * double.parse(item['discount'].replaceAll('%', '')) / 100;
            // item['discountAmount'] =double.parse(item['discount'].replaceAll('%', '')) / 100;
            item['discountamount'] = (double.parse(item['totalAmount'].toString()) * double.parse(item['discount'].replaceAll('%', ''))) / 100;
            item['taxamount'] = ((double.parse(item['totalAmount'].toString()) -
                double.parse(item['discountamount'].toString())) *
                double.parse(item['tax'].replaceAll('%', '').toString())) / 100;
          }
        }
      }

      if (orderDetails != null) {
        final Uint8List pdfBytes = await Invoicepdf1(orderDetails);
        final blob = html.Blob([pdfBytes]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute('download', 'Invoice.pdf')
          ..click();
        html.Url.revokeObjectUrl(url);
      } else {
        print('Failed to fetch order details.');
      }
    } catch (e) {
      print('Error generating PDF: $e');
    }
  }

// Future downloadPdf() async {
//   final String orderId = 'ORD_02282';
//   try {
//     final  productMasterData = await _fetchAllProductMaster();
//     final orderDetails = await _fetchOrderDetails(orderId);
//     for (var product in productMasterData) {
//       print('Product: ${product['productName']}, Discount: ${product['discount']}');
//       for(var item in orderDetails!.items){
//         if(product['productName'] == item['productName']){
//           print('true');
//           print(product['discount']);
//           print(product['tax']);
//           item['tax'] =product['tax'];
//           item['discount'] =  product['discount'];
//           item['discountamount'] = (item['price'] * double.parse(item['discount'].replaceAll('%', ''))) / 100;
//           item['taxamount'] = (item['discountamount'] * double.parse(item['tax'].replaceAll('%', ''))) / 100;
//         //  item['taxamount'] = (item['price'] - double.parse(item['discountamount'])) / 100;
//           //item['taxamount'] = (item['discountamount'] * item['tax'] / 100);
//           // item['discountamount'] = (item['discount'] )/ 100;
//           print(item['tax']);
//
//
//          print(item['discount']);
//         }
//       }
//     }
//     //List <Product>ProductList =productMasterData;
//     // print('hellooo');
//     // print(ProductList);
//     // print('check');
//     // print(ProductList['discount' as int]);
//
//
//
//     if (orderDetails != null) {
//       for (var item in orderDetails.items) {
//        // final discountElement = productMasterData.firstWhere((element) =>
//         // element.productName == item.productName &&
//         //     element['category'] == item.category &&
//         //     element['subCategory'] == item.subCategory &&
//         //     element['price'] == item.price,
//         //     orElse: () => null);
//        // print('discount');
//        // print(discountElement);
//         final Uint8List pdfBytes = await Returnpdf(orderDetails);
//         final blob = html.Blob([pdfBytes]);
//         final url = html.Url.createObjectUrlFromBlob(blob);
//         final anchor = html.AnchorElement(href: url)
//           ..setAttribute('download', 'invoice.pdf')
//           ..click();
//         html.Url.revokeObjectUrl(url);
//         // if (discountElement != null) {
//         //   print('Discount Element:');
//         // //  print(discountElement);
//         // //  final discount = discountElement['discount'];
//         //
//         // } else {
//         //   print('No matching product found in product master data.');
//         // }
//       }
//     } else {
//       print('Failed to fetch order details.');
//     }
//   } catch (e) {
//     print('Error generating PDF: $e');
//   }
// }
}

Future<Uint8List> loadImage() async {
  final ByteData data = await rootBundle.load('images/Final-Ikyam-Logo.png');
  return data.buffer.asUint8List();
}


Future<OrderDetail?> _fetchOrderDetails(String orderId) async {
  String token = 'eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJkaGFuYXNla2FyIiwiUm9sZXMiOlt7ImF1dGhvcml0eSI6ImRldmVsb3BlciJ9XSwiZXhwIjoxNzI1NjA2NjA5LCJpYXQiOjE3MjU1OTk0MDl9.a0XS5AykjKk62PBbfGessANRveTtU5wawjPRnHj73Zi1t-Xh3b2-2G_CksANLOaANHiy-4AlsCYwOZFY8GmExA';
  try {
    final url = '$apicall/order_master/search_by_orderid/$orderId';
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      final responseBody = response.body;
      print('onTap');
      print(responseBody);
      if (responseBody != null) {
        final jsonData = jsonDecode(responseBody);
        if (jsonData is List<dynamic>) {
          final jsonObject = jsonData.first;
          return OrderDetail.fromJson(jsonObject);
        } else {
          print('Failed to load order details');
        }
      } else {
        print('Failed to load order details');
      }
    } else {
      print('Failed to load order details');
    }
  } catch (e) {
    print('Error: $e');
  }
  return null;
}


Future<Uint8List> Invoicepdf1(OrderDetail orderDetails) async {
  final pdf = pw.Document();
  double _total = 0.0;


  double calculateTaxAmountTotal(List<dynamic> items) {
    double totalTaxAmount = 0.0;

    for (var item in items) {
      //var itemMap = item as Map<String, dynamic>;

      item['taxamount'] = ((item['price'] -
          (item['price'] * (double.parse(item['discount'].replaceAll('%', '')) / 100))
      ) * (double.parse(item['tax'].replaceAll('%', '').toString()))
          / 100) * item['qty'];
      // double totalAmount = double.parse(itemMap['totalAmount'].toString());
      // double discountAmount = double.parse(itemMap['discountamount'].toString());
      // double taxPercentage = double.parse(itemMap['tax'].replaceAll('%', ''));
      //
      // double taxAmount = ((totalAmount - discountAmount) * taxPercentage) / 100;
      totalTaxAmount += item['taxamount'];
    }

    return totalTaxAmount;
  }
  // double calculateTaxAmountTotal(List<dynamic> items) {
  //   double totalAmountWithTax = 0.0;
  //
  //   for (var item in items) {
  //     var itemMap = item as Map<String, dynamic>;
  //
  //     double price = double.parse(itemMap['price'].toString());
  //     double qty = double.parse(itemMap['qty'].toString());
  //     double discountPercentage = double.parse(itemMap['discount'].replaceAll('%', ''));
  //     double taxPercentage = double.parse(itemMap['tax'].replaceAll('%', ''));
  //
  //     double totalAmount = price * qty;
  //     double discountAmount = (price * discountPercentage) / 100;
  //     double taxableAmount = totalAmount - discountAmount;
  //     double taxAmount = (taxableAmount * taxPercentage) / 100;
  //     double itemTotalAmountWithTax = taxableAmount + taxAmount;
  //
  //     totalAmountWithTax += itemTotalAmountWithTax;
  //   }
  //
  //   return totalAmountWithTax;
  // }

  double calculateTotalAmount1(List<dynamic> items) {
    double totalAmount = 0.0;

    for (var item in items) {
      var itemMap = item as Map<String, dynamic>;

      double qty = double.tryParse(itemMap['qty']?.toString() ?? '0') ?? 0.0;
      double totalAmountPerItem = double.tryParse(itemMap['totalamoun2']?.toString() ?? '0') ?? 0.0;

      totalAmount += qty * totalAmountPerItem;
    }

    return totalAmount;
  }

  final logoData = await loadImage();

  //final pdf = pw.Document();
  final image = pw.MemoryImage(logoData);

  pw.Widget buildHeader() {
    return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              //   pw.Image(logo, height: 50), // Company logo
              pw.Text(
                'Invoice: ${orderDetails.InvNo}',
                style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(width: 10,),
              pw.Image(image, height: 20,),
            ],
          ),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.end,
            children: [

            ],
          ),
          pw.SizedBox(height: 10),
        ]);
  }

  pdf.addPage(
    pw.MultiPage(
      margin: pw.EdgeInsets.all(24),
      pageFormat: PdfPageFormat.a4,
      header: (pw.Context context){
        return buildHeader();
      },
      build: (pw.Context context) {
        return [
          pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.start,
              children: [
                pw.Container(
                  height: 5,
                  width: 280,
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color:  PdfColors.grey),
                    // borderRadius: pw.BorderRadius.circular(3.5), // Set border radius here
                  ),
                ),
                // pw.SizedBox(width: 300,),
                pw.Container(
                  height: 5,
                  width: 280,
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey200,
                    border: pw.Border.all(color:  PdfColors.grey),
                    //  borderRadius: pw.BorderRadius.circular(3.5), // Set border radius here
                  ),
                ),
              ]
          ),
          pw.SizedBox(height: 10),
          // Invoice Header
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                mainAxisAlignment: pw.MainAxisAlignment.start,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Low Plumbing Heating',
                    style: pw.TextStyle(),
                  ),
                  pw.Text('1120 Hamilton Street'),
                  pw.Text('Toledo OH 43607'),
                ],
              ),
              pw.Padding(
                padding: pw.EdgeInsets.only(top: 50),
                child:  pw.Column(
                  // mainAxisAlignment: pw.MainAxisAlignment.end,
                  // crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [

                    pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Padding(
                          padding: pw.EdgeInsets.only(right: 100),
                          child:  pw.Text(
                            'Date:',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          ),
                        ),
                        pw.SizedBox(width: 33),
                        pw.Text('          ${orderDetails.orderDate}')

                      ],
                    ),
                    pw.SizedBox(height: 4),
                    pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Padding(
                          padding: pw.EdgeInsets.only(right: 46),
                          child:  pw.Text(
                            'Sales Order Number:',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          ),
                        ),

                        pw.SizedBox(width: 15),
                        pw.Text('   ${orderDetails.orderId}'),

                      ],
                    ),
                    pw.SizedBox(height: 4),
                    pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Padding(
                          padding: pw.EdgeInsets.only(right: 71),
                          child: pw.Text(
                            'Delivery Number:',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          ),
                        ),
                        pw.SizedBox(width: 45),
                        pw.Text('   00001'),
                      ],
                    ),
                    pw.SizedBox(height: 4),
                    pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Padding(
                          padding: pw.EdgeInsets.only(right: 62),
                          child:  pw.Text(
                            'Fulfillment Date:',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          ),
                        ),

                        pw.SizedBox(width: 30),
                        pw.Text('   ${orderDetails.orderDate}'),
                      ],
                    ),
                    pw.SizedBox(height: 4),
                    pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Padding(
                          padding: pw.EdgeInsets.only(right: 67),
                          child: pw.Text(
                            'Customer Number:',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          ),
                        ),
                        pw.SizedBox(width: 15),
                        pw.Text('${orderDetails.contactNumber}'),
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
          pw.SizedBox(height: 20),

          // Ship-to Address
          pw.Text(
            'Ship-to Address:',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
          pw.Text('${orderDetails.deliveryAddress}'),
          //pw.Text('Chennai 600002'),
          pw.SizedBox(height: 20),
          ...orderDetails.items.map((item) {
            print('print');
            print(item);

            return  pw.Container(
              decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey)
              ),

              child: pw.Column(
                  crossAxisAlignment:pw.CrossAxisAlignment.start,
                  children: [

                    pw.Table(
                      border: pw.TableBorder.all(color: PdfColors.grey),
                      columnWidths: const {
                        0: pw.FlexColumnWidth(0.6),
                        1: pw.FlexColumnWidth(1.2),
                        2: pw.FlexColumnWidth(1),
                        3: pw.FlexColumnWidth(0.6),
                        4: pw.FlexColumnWidth(1),
                        5: pw.FlexColumnWidth(1),
                      },
                      children: [
                        // ...orderDetails.items.map((item) {
                        pw.TableRow(
                          decoration: pw.BoxDecoration(color: PdfColors.grey200),
                          children: [
                            buildCell1('Line'),
                            buildCell1('Product'),
                            buildCell1('Description'),
                            buildCell1('QTY'),
                            buildCell1('Gross Price'),
                            buildCell1('Gross Value'),
                          ],
                        ),
                      ],
                    ),
                    pw.Table(
                      border: pw.TableBorder.all(color: PdfColors.grey),
                      columnWidths: const {
                        0: pw.FlexColumnWidth(0.6),
                        1: pw.FlexColumnWidth(1.2),
                        2: pw.FlexColumnWidth(1),
                        3: pw.FlexColumnWidth(0.6),
                        4: pw.FlexColumnWidth(1),
                        5: pw.FlexColumnWidth(1),
                      },
                      children: [

                        pw.TableRow(
                          children: [
                            buildCell('+10'),
                            buildCell(item['productName']),
                            buildCell(item['category']),
                            buildCell(item['qty'].toString()),
                            buildCell((item['totalamoun2'] = (item['price'] - (item['price'] * (double.parse(item['discount'].replaceAll('%', '')) / 100)))).toString()),
                            // buildCell(
                            //     (item['totalamoun2'] =
                            //         (item['price'] *
                            //             double.parse(item['discount'].replaceAll('%', '')) / 100).toString())
                            //         * item['qty'] - item['price']),
                            buildCell(
                                (_total = double.parse((item['qty']
                                    * double.parse(item['totalamoun2'].toString()
                                    )).toString())).toString()
                            ),
                            // buildCell(item['price'].toString()),
                            // buildCell(item['totalAmount'].toString()),

                          ],
                        ),
                      ],
                    ),

                    // pw.Table(
                    //   border: pw.TableBorder.all(color: PdfColors.grey),
                    //   columnWidths: const {
                    //     0: pw.FlexColumnWidth(0.6),
                    //     1: pw.FlexColumnWidth(1.2),
                    //     2: pw.FlexColumnWidth(1),
                    //     3: pw.FlexColumnWidth(0.6),
                    //     4: pw.FlexColumnWidth(1),
                    //     5: pw.FlexColumnWidth(1),
                    //   },
                    //   children: [
                    //     pw.TableRow(
                    //       decoration: pw.BoxDecoration(color: PdfColors.grey200),
                    //       children: [
                    //         buildCell1('Line'),
                    //         buildCell1('Product'),
                    //         buildCell1('Description'),
                    //         buildCell1('QTY'),
                    //         buildCell1('Gross Price'),
                    //         buildCell1('Gross Value'),
                    //       ],
                    //     ),
                    //     pw.TableRow(
                    //       children: [
                    //         buildCell('20'),
                    //         buildCell(' A00162'),
                    //         buildCell('Laptop'),
                    //         buildCell('1 Each'),
                    //         buildCell('14,691.83 INR / 1 Each'),
                    //         buildCell('14,691.83 INR'),
                    //       ],
                    //     ),
                    //   ],
                    // ),

                    pw.Padding(
                      padding: pw.EdgeInsets.only(left:55,right: 20,top: 5),
                      child: pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text('Gross Actual Price:',style: pw.TextStyle(fontSize: 10)),
                          //izedBox(width: 50,),
                          pw.Text('${item['price']} INR / 1 Each',style: pw.TextStyle(fontSize: 10)),
                          pw.Text('${item['AcutaltotalAmount'] = item['price'] * item['qty']} INR',style: pw.TextStyle(fontSize:10)),

                          // Text('Gross Discount (%): -21.00 %'),
                          // Text('State sales tax (%): 5.50 %'),
                          // if (salesOrderNumber.isNotEmpty)
                          //   Text('Sales Order Number: $salesOrderNumber'),
                          // Text('No cash discount allowed'),
                        ],
                      ),
                    ),
                    pw.Padding(
                      padding: pw.EdgeInsets.only(left:55,right: 20 ),
                      child: pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text('Gross Discount (%):',style: pw.TextStyle(fontSize: 10)),
                          //izedBox(width: 50,),
                          pw.Text('${item['discount']}',style: pw.TextStyle(fontSize: 10)),
                      //    pw.Text('${item['discountAmount']}',style: pw.TextStyle(fontSize: 10)),
                          pw.Text('-${item['discountamount'] =  item['AcutaltotalAmount'] * double.parse(item['discount'].replaceAll('%', '')) / 100}',style: pw.TextStyle(fontSize: 10)),

                          // Text('Gross Discount (%): -21.00 %'),
                          // Text('State sales tax (%): 5.50 %'),
                          // if (salesOrderNumber.isNotEmpty)
                          //   Text('Sales Order Number: $salesOrderNumber'),
                          // Text('No cash discount allowed'),
                        ],
                      ),
                    ),
                    pw.Padding(
                      padding: pw.EdgeInsets.only(left:55,right: 20 ),
                      child: pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw. Text('State sales tax (%)',style: pw.TextStyle(fontSize: 10)),
                          //izedBox(width: 50,),
                          pw.Text('${item['tax']}',style: pw.TextStyle(fontSize: 10)),
           // item['taxamount'] = (item['totalamoun2'] * double.parse(item['tax'].replaceAll('%', '').toString())) / 100,
                          pw.Text('${(item['taxamount'] = ((item['price'] -
                              (item['price'] * (double.parse(item['discount'].replaceAll('%', '')) / 100))
                          ) * (double.parse(item['tax'].replaceAll('%', '').toString()))
                              / 100) * item['qty']).toStringAsFixed(2)}', style: pw.TextStyle(fontSize: 10)),
            //pw.Text('${item['taxamount'].toStringAsFixed(2)}', style: pw.TextStyle(fontSize: 10)),
                     //     pw.Text('${(item['taxamount'] = item['totalamoun2'] *  double.parse(item['tax'].replaceAll('%', '').toString())) / 100).toStringAsFixed(2)}',style: pw.TextStyle(fontSize: 10)),

                          // Text('Gross Discount (%): -21.00 %'),
                          // Text('State sales tax (%): 5.50 %'),
                          // if (salesOrderNumber.isNotEmpty)
                          //   Text('Sales Order Number: $salesOrderNumber'),
                          // Text('No cash discount allowed'),
                        ],
                      ),
                    ),
                    pw.Padding(
                      padding: pw.EdgeInsets.only(left:55,bottom: 5),
                      child: pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text('No cash discount allowed',style: pw.TextStyle(fontSize: 10)),
                          // pw.Text('                                                                                                                 '),
                        ],
                      ),
                    ),
                  ]
              ),
            );
          },),

          pw.SizedBox(height: 20),

          // Totals
          pw.Padding(padding: pw.EdgeInsets.only(left: 250,right: 50),
            child:pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(mainAxisAlignment: pw.MainAxisAlignment.end,
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.start,
                      children: [
                        pw.Text('Total Item Gross Value:'),
                        pw.Text('     ${calculateTotalAmount1(orderDetails.items).toStringAsFixed(2)} INR'),
                      ],
                    ),
                    pw.SizedBox(height: 5), // add a gap of 10 units
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.start,
                      children: [
                        pw.Text('GST:'),
                        pw.Text(' ${calculateTaxAmountTotal(orderDetails.items).toStringAsFixed(2)} INR'),
                      ],
                    ),
                    pw.SizedBox(height: 5), // add a gap of 10 units
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.start,
                      children: [

                        pw.Text('Gross Total:'),
                        pw.Text(' ${(calculateTaxAmountTotal(orderDetails.items) + calculateTotalAmount1(orderDetails.items)).toStringAsFixed(2)} INR')                        ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          pw.SizedBox(height: 50),
          //pw.SizedBox(height: 180),

          // Company Information
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.start,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.SizedBox(height: 10),
                  pw.Row(
                      children: [
                        pw.Text(
                            'Ikyam Solution pvt. Ltd..,'
                        ),
                        // pw.Text(
                        //   'Registered Office:',style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        //
                        // ),
                        //  pw.SizedBox(width: 5),

                      ]
                  ),
                  //  pw.SizedBox(height: 10),
                  pw.Row(
                      children: [
                        // pw.Text(
                        //   'Address:',style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        //
                        // ),
                        // pw.SizedBox(width: 5),
                        pw.Text(
                            '4th Block, New Friends Colony,\n'
                          // 'Koramangala, Bengaluru,\n'
                          // 'Karnataka 560034.',
                        ),


                      ]
                  ),
                  pw.Row(
                      children: [
                        pw.SizedBox(height: 5),
                        pw.Text(
                            'Koramangala, Bengaluru,\n'
                          // 'Karnataka 560034.',
                        ),


                      ]
                  ),
                  pw.Row(
                      children: [
                        pw.SizedBox(height: 5),
                        pw.Text(

                          'Karnataka 560034.',
                        ),

                      ]
                  ),
                  pw.SizedBox(height: 5),
                ],
              ),
            ],
          ),
        ];
      },
    ),
  );

  return pdf.save();
}












pw.Widget buildCell1(String text) {
  return pw.Padding(
    padding: pw.EdgeInsets.all(8.0),
    child: pw.Text(text, style: pw.TextStyle(fontSize: 10,fontWeight: pw.FontWeight.bold)),
  );
}

pw.Widget buildCell(String text) {
  return pw.Padding(
    padding: pw.EdgeInsets.all(8.0),
    child: pw.Text(text, style: pw.TextStyle(fontSize: 10)),
  );
}