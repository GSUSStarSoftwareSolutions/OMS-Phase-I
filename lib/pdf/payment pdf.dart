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
              downloadPaymentReceipt();
            },
            child: Text('Download PDF'),
          ),
        ),
      ),
    );
  }

  Future<List<dynamic>> _fetchAllProductMaster() async {
    final String token = 'eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJkaGFuYXNla2FyIiwiUm9sZXMiOlt7ImF1dGhvcml0eSI6ImRldmVsb3BlciJ9XSwiZXhwIjoxNzI2MjMyNzIxLCJpYXQiOjE3MjYyMjU1MjF9.MuqH__17xFPLPnEoBCwcVz7LFWzcLPq15hlgBdEp0X6c_3QIzKFg0Abx1Sopf9ET3GQfteeeznewktmPR6rNJw';
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





  Future downloadPaymentReceipt() async {
    final String orderId = 'ORD_04916';
    try {
      final productMasterData = await _fetchAllProductMaster();
      final orderDetails = await _fetchOrderDetails(orderId);
      for (var product in productMasterData) {
        for (var item in orderDetails!.items) {
          if (product['productName'] == item['productName']) {
            item['tax'] = product['tax'];
            item['discount'] = product['discount'];
            item['discountamount'] = (double.parse(item['totalAmount'].toString()) * double.parse(item['discount'].replaceAll('%', ''))) / 100;
            item['taxamount'] = ((double.parse(item['totalAmount'].toString()) -
                double.parse(item['discountamount'].toString())) *
                double.parse(item['tax'].replaceAll('%', '').toString())) / 100;
          }
        }
      }

      if (orderDetails != null) {
        final Uint8List pdfBytes = await PaymentReceipt(orderDetails);
        final blob = html.Blob([pdfBytes]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute('download', 'Payment Receipt.pdf')
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
  String token = 'eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJkaGFuYXNla2FyIiwiUm9sZXMiOlt7ImF1dGhvcml0eSI6ImRldmVsb3BlciJ9XSwiZXhwIjoxNzI2MjMyNzIxLCJpYXQiOjE3MjYyMjU1MjF9.MuqH__17xFPLPnEoBCwcVz7LFWzcLPq15hlgBdEp0X6c_3QIzKFg0Abx1Sopf9ET3GQfteeeznewktmPR6rNJw';
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
          print('json');
          print(jsonObject);
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


Future<Uint8List> PaymentReceipt(OrderDetail orderDetails) async {
  final pdf = pw.Document();
  //double total = 0;
  String? total;
  double _total = 0.0;
  double tax = 0.0;


  // double calculateTax() {
  //   //double tax = 0.0;
  //   for (var item in orderDetails.items) {
  //     double? taxAmount = double.tryParse(item['taxamount'].toString());
  //     if (taxAmount != null) {
  //       tax += taxAmount;
  //     } else {
  //       print('Error parsing tax amount: ${item['taxamount']}');
  //     }
  //   }
  //   return tax;
  // }

  double calculateTax() {
    double tax = 0.0;
    for (var item in orderDetails.items) {
      tax += double.parse(item['taxamount'].toString());
    }
    return tax;
  }
  //original
  // double calculateTax() {
  //   //double tax = 0.0;
  //   for (var item in orderDetails.items) {
  //     tax += item['taxamount'] as double;
  //   }
  //   return tax;
  // }
  // double calculateTax() {
  //   double totalTax = 0.0;
  //
  //   for (var item in orderDetails.items) {
  //     // Calculate the tax amount for each item
  //     item['taxamount'] = ((double.parse(item['totalAmount'].toString()) -
  //         double.parse(item['discountamount'].toString())) *
  //         double.parse(item['tax'].replaceAll('%', '').toString())) /
  //         100;
  //
  //     // Add the tax amount to the totalTax
  //     totalTax += double.parse(item['taxamount'].toString());
  //   }
  //
  //   return totalTax;
  // }




  // double calculateTax() {
  //   //double tax = 0.0;
  //   for (var item in orderDetails.items) {
  //     tax += double.parse(item['taxamount'].toString()).toString() as double;
  //   }
  //   return tax;
  // }

  double calculateTotal() {
    double total = 0.0;
    for (var item in orderDetails.items) {
      total += double.parse((item['qty'] * double.parse(item['totalamoun2'].toString())).toString());
    }
    return total;
  }


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


  double calculateTaxAmountTotal(List<dynamic> items) {
    double totalTaxAmount = 0.0;

    for (var item in items) {
      var itemMap = item as Map<String, dynamic>;

      double totalAmount = double.parse(itemMap['totalAmount'].toString());
      double discountAmount = double.parse(itemMap['discountamount'].toString());
      double taxPercentage = double.parse(itemMap['tax'].replaceAll('%', ''));

      double taxAmount = ((totalAmount - discountAmount) * taxPercentage) / 100;
      totalTaxAmount += taxAmount;
    }

    return totalTaxAmount;
  }


  //double totalWithTax = calculateTax() + calculateTotal();
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
                'Payment ID:  ${orderDetails.paymentId}',
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
      pageFormat: PdfPageFormat.a4,
      margin: pw.EdgeInsets.all(24),
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
                  width: 250,
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color:  PdfColors.grey),
                    // borderRadius: pw.BorderRadius.circular(3.5), // Set border radius here
                  ),
                ),
                // pw.SizedBox(width: 300,),
                pw.Container(
                  height: 5,
                  width: 250,
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
                          padding: pw.EdgeInsets.only(right: 75),
                          child:  pw.Text(
                            'Customer Name:',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          ),
                        ),
                        pw.SizedBox(width: 29),
                        pw.Text('${orderDetails.contactPerson}')

                      ],
                    ),
                    //pw.SizedBox(height: 4),
                    // pw.Row(
                    // crossAxisAlignment: pw.CrossAxisAlignment.start,
                    // children: [
                    // pw.Padding(
                    // padding: pw.EdgeInsets.only(right: 77),
                    // child: pw.Text(
                    // 'Invoice Number:',
                    // style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    // ),
                    // ),
                    //
                    //
                    // pw.SizedBox(width: 15),
                    // pw.Text('INV_02276'),
                    // ],
                    // ),
                    pw.SizedBox(height: 4),
                    pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Padding(
                          padding: pw.EdgeInsets.only(right: 48),
                          child:  pw.Text(
                            'Payment Date:',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          ),
                        ),

                        pw.SizedBox(width: 75),
                        pw.Text('${orderDetails.paymentDate}'),

                      ],
                    ),
                    pw.SizedBox(height: 4),
                    pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Padding(
                          padding: pw.EdgeInsets.only(right: 71),
                          child: pw.Text(
                            'Order ID:',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          ),
                        ),
                        pw.SizedBox(width: 79),
                        pw.Text('${orderDetails.orderId}'),
                      ],
                    ),
                    pw.SizedBox(height: 4),
                    pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Padding(
                          padding: pw.EdgeInsets.only(right: 62),
                          child:  pw.Text(
                            'Invoice No',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          ),
                        ),

                        pw.SizedBox(width: 72),
                        pw.Text('   ${orderDetails.InvNo}'),
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
                        pw.SizedBox(width: 25),
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
          //
          //pw.Text('Chennai 600002'),
          pw.SizedBox(height: 20),
          //original
          // ...orderDetails.items.map((item) {
          //   print('print');
          //   print(item);
          //
          //   //  total += (item['qty'] * double.parse(item['totalamoun2'].toString()));
          //
          //
          //   return  pw.Container(
          //     decoration: pw.BoxDecoration(
          //         border: pw.Border.all(color: PdfColors.grey)
          //     ),
          //
          //     child: pw.Column(
          //         crossAxisAlignment:pw.CrossAxisAlignment.start,
          //         children: [
          //           pw.Table(
          //             border: pw.TableBorder.all(color: PdfColors.grey),
          //             columnWidths: const {
          //               0: pw.FlexColumnWidth(1),
          //               1: pw.FlexColumnWidth(1),
          //               2: pw.FlexColumnWidth(1),
          //               3: pw.FlexColumnWidth(1),
          //             },
          //             children: [
          //               // ...orderDetails.items.map((item) {
          //               pw.TableRow(
          //                 decoration: pw.BoxDecoration(color: PdfColors.grey200),
          //                 children: [
          //                   buildCell1('Payment Mode'),
          //                   buildCell1('Gross Amount'),
          //                   buildCell1('Paid Amount'),
          //                   buildCell1('Remaining Amount'),
          //                 ],
          //               ),
          //             ],
          //           ),
          //           pw.Table(
          //             border: pw.TableBorder.all(color: PdfColors.grey),
          //             columnWidths: const {
          //               0: pw.FlexColumnWidth(1),
          //               1: pw.FlexColumnWidth(1),
          //               2: pw.FlexColumnWidth(1),
          //               3: pw.FlexColumnWidth(1),
          //             },
          //             children: [
          //               pw.TableRow(
          //                 children: [
          //                   //    for(var item in items)
          //                   buildCell(orderDetails.paymentMode.toString()),
          //                   buildCell(orderDetails.total.toString()),
          //                   buildCell(orderDetails.paidAmount.toString()),
          //                   buildCell(orderDetails.payableAmount.toString()),
          //                   //  buildCell((item['totalamoun2'] = item['price'] - double.parse(item['discountamount'].toString())).toString()),
          //                   // buildCell((item['totalamoun2'] = item['price'] - double.parse(item['discountamount'].toString())).toString()),
          //                   // buildCell(
          //                   //     (_total = double.parse((item['qty']
          //                   //         * double.parse(item['totalamoun2'].toString()
          //                   //         )).toString())).toString()
          //                   // ),
          //                   //  buildCell(double.parse(total.toString()) as String),
          //                 ],
          //               ),
          //             ],
          //           ),
          //           // pw.Padding(
          //           //   padding: pw.EdgeInsets.only(left:55,right: 20,top: 5),
          //           //   child: pw.Row(
          //           //     mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          //           //     children: [
          //           //       pw.Text('Gross Actual Price:',style: pw.TextStyle(fontSize: 10)),
          //           //       //izedBox(width: 50,),
          //           //       pw.Text('${item['price'].toString()} INR / 1 Each',style: pw.TextStyle(fontSize: 10)),
          //           //       pw.Text('${item['totalAmount']} INR',style: pw.TextStyle(fontSize:10)),
          //           //       // Text('Gross Discount (%): -21.00 %'),
          //           //       // Text('State sales tax (%): 5.50 %'),
          //           //       // if (salesOrderNumber.isNotEmpty)
          //           //       //   Text('Sales Order Number: $salesOrderNumber'),
          //           //       // Text('No cash discount allowed'),
          //           //     ],
          //           //   ),
          //           // ),
          //           // pw.Padding(
          //           //   padding: pw.EdgeInsets.only(left:55,right: 20 ),
          //           //   child: pw.Row(
          //           //     mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          //           //     children: [
          //           //       pw.Text('Gross Discount (%):',style: pw.TextStyle(fontSize: 10)),
          //           //       //izedBox(width: 50,),
          //           //       pw.Text('${item['discount']}',style: pw.TextStyle(fontSize: 10)),
          //           //       pw.Text('-${item['discountamount']}',style: pw.TextStyle(fontSize: 10)),
          //           //
          //           //       // Text('Gross Discount (%): -21.00 %'),
          //           //       // Text('State sales tax (%): 5.50 %'),
          //           //       // if (salesOrderNumber.isNotEmpty)
          //           //       //   Text('Sales Order Number: $salesOrderNumber'),
          //           //       // Text('No cash discount allowed'),
          //           //     ],
          //           //   ),
          //           // ),
          //           // pw.Padding(
          //           //   padding: pw.EdgeInsets.only(left:55,right: 20 ),
          //           //   child: pw.Row(
          //           //     mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          //           //     children: [
          //           //       pw. Text('State sales tax (%)',style: pw.TextStyle(fontSize: 10)),
          //           //       //izedBox(width: 50,),
          //           //       pw.Text('${item['tax']}',style: pw.TextStyle(fontSize: 10)),
          //           //       pw.Text('${(item['taxamount'])}',style: pw.TextStyle(fontSize: 10)),
          //           //     ],
          //           //   ),
          //           // ),
          //           // pw.Padding(
          //           //   padding: pw.EdgeInsets.only(left:55,bottom: 5),
          //           //   child: pw.Row(
          //           //     mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          //           //     children: [
          //           //       pw.Text('No cash discount allowed',style: pw.TextStyle(fontSize: 10)),
          //           //       // pw.Text('                                                                                                                 '),
          //           //     ],
          //           //   ),
          //           // ),
          //         ]
          //     ),
          //   );
          // },
          // ),


          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey),
                columnWidths: const {
                  0: pw.FlexColumnWidth(1),
                  1: pw.FlexColumnWidth(1),
                  2: pw.FlexColumnWidth(1),
                  3: pw.FlexColumnWidth(1),
                },
                children: [
                  pw.TableRow(
                    decoration: pw.BoxDecoration(color: PdfColors.grey200),
                    children: [
                      buildCell1('Payment Mode'),
                      buildCell1('Gross Amount'),
                      buildCell1('Paid Amount'),
                      buildCell1('Remaining Amount'),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      buildCell(orderDetails.paymentMode.toString()),
                      buildCell(orderDetails.total.toString()),
                      buildCell(orderDetails.paidAmount.toString()),
                      buildCell(orderDetails.payableAmount.toString()),
                    ],
                  ),
                ],
              ),
              // Display item details in a separate table
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey),
                columnWidths: const {
                  0: pw.FlexColumnWidth(1),
                  1: pw.FlexColumnWidth(1),
                  2: pw.FlexColumnWidth(1),
                  3: pw.FlexColumnWidth(1),
                },
                children: [
                  for (var item in orderDetails.items.where((item) => item != null))
                    if (item['paymentMode'] != null &&
                          item['total'] != null &&
                      item['paidAmount'] != null &&
                      item['payableAmount'] != null)
                    pw.TableRow(
                      children: [
                        buildCell(item['paymentMode'].toString()),
                        buildCell(item['total'].toString()),
                        buildCell(item['paidAmount'].toString()),
                        buildCell(item['payableAmount'].toString()),
                      ],
                    ),
                ],
              ),
            ],
          ),


          pw.SizedBox(height: 20),

          // Totals

          // pw.Padding(padding: pw.EdgeInsets.only(left: 250,right: 50),
          //   child:pw.Row(
          //     mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          //     children: [
          //       pw.Column(mainAxisAlignment: pw.MainAxisAlignment.end,
          //         crossAxisAlignment: pw.CrossAxisAlignment.end,
          //         children: [
          //           pw.Row(
          //             mainAxisAlignment: pw.MainAxisAlignment.start,
          //             children: [
          //               pw.Text('Total Item Gross Value:'),
          //               pw.Text('     ${calculateTotalAmount1(orderDetails.items).toStringAsFixed(2)} INR'),
          //             ],
          //           ),
          //           pw.SizedBox(height: 5), // add a gap of 10 units
          //           pw.Row(
          //             mainAxisAlignment: pw.MainAxisAlignment.start,
          //             children: [
          //               pw.Text('GST:'),
          //               pw.Text(' ${calculateTaxAmountTotal(orderDetails.items).toStringAsFixed(2)} INR'),
          //             ],
          //           ),
          //           pw.SizedBox(height: 5), // add a gap of 10 units
          //           pw.Row(
          //             mainAxisAlignment: pw.MainAxisAlignment.start,
          //             children: [
          //               pw.Text('Total With Tax:'),
          //               pw.Text(' ${(calculateTaxAmountTotal(orderDetails.items) + calculateTotalAmount1(orderDetails.items)).toStringAsFixed(2) } INR'),
          //             ],
          //           ),
          //         ],
          //       ),
          //     ],
          //   ),
          // ),

          pw.SizedBox(height: 350),
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



