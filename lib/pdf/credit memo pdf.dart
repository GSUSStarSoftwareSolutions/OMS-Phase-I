
//import 'package:btb/Return%20Module/Return%20pdf.dart';
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
import '../Return Module/return first page.dart';


// import 'package:your_project/Return%20Module/Return%20pdf.dart'; // Update this import path

void main() {
  runApp(CreditMemo());
}

class CreditMemo extends StatefulWidget {
  @override
  State<CreditMemo> createState() => _CreditMemoState();
}

class _CreditMemoState extends State<CreditMemo> {
  late  final discount = 0;

  @override
  Widget build(BuildContext context) {
    String discount;
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('PDF for Credit Memo'),
        ),
        body: Center(
          child: ElevatedButton(
            onPressed: () {
              downloadCreditMemoPdf("RTRN_04357");
            },
            child: Text('Download PDF'),
          ),
        ),
      ),
    );
  }



  Future<void> downloadCreditMemoPdf(String orderId) async {
   // final String orderId2 = 'RTRN_04365';
    try {
      final returnMasters = await _fetchAllReturnMaster(orderId);

      print(returnMasters);

      final orderDetails = returnMasters.toList().cast<ReturnMaster>();
      //final orderDetails = returnMasters.map<ReturnMaster>((returnMaster) => ReturnMaster.fromJson(returnMaster as Map<String, dynamic>)).toList().cast<ReturnMaster>();
      if (orderDetails.isNotEmpty) {
        final Uint8List pdfBytes = await CreditMemoPdf(orderDetails);
        final blob = html.Blob([pdfBytes]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute('download', 'Credit_Memo.pdf')
          ..click();
        html.Url.revokeObjectUrl(url);
      } else {
        print('Failed to generate order details.');
      }
    } catch (e) {
      print('Error generating PDF: $e');
    }
  }

  Future<List<ReturnMaster>> _fetchAllReturnMaster(String orderId) async {
    String orderId1 = orderId;
    const String token = 'eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJkaGFuYXNla2FyIiwiUm9sZXMiOlt7ImF1dGhvcml0eSI6ImRldmVsb3BlciJ9XSwiZXhwIjoxNzI3MTg1NDYyLCJpYXQiOjE3MjcxNzgyNjJ9.gtSeEeobAvwxkJfChTs4W4NJHMIq6Sung7XEZTwnhLbAOgqHGROtmn6YSJS7g5smNXlWQmUNAMMh91cFAoe9OA';
    try {
      final response = await http.get(
        Uri.parse('$apicall/return_master/get_all_returnmaster'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Return Master Data:');
        print(data);

        final returnMaster = data.firstWhere((returnMaster) => returnMaster['returnId'] == orderId1, orElse: () => null);

        if (returnMaster != null) {
             // Convert the matched data to a ReturnMaster object
             final returnMasterObject = ReturnMaster.fromJson(returnMaster as Map<String, dynamic>);
             print(returnMasterObject);
             return [returnMasterObject]; // Return a list containing the matched data
           } else {
             return []; // Return an empty list if no matched data is found
           }
         //orderId == response['returnId'] that specific data will be return
        //return data.map<ReturnMaster>((returnMaster) => ReturnMaster.fromJson(returnMaster as Map<String, dynamic>)).toList();
      } else {
        print('Failed to fetch return master data.');
        return [];
      }
    } catch (e) {
      print('Error fetching return master data: $e');
      return [];
    }
  }
  //original
  // Future<List<dynamic>> _fetchAllReturnMaster() async {
  //   final String token = 'eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJkaGFuYXNla2FyIiwiUm9sZXMiOlt7ImF1dGhvcml0eSI6ImRldmVsb3BlciJ9XSwiZXhwIjoxNzI3MTU3NzEyLCJpYXQiOjE3MjcxNTA1MTJ9.7d9Tq57TtgJDo4oc-MWFpFUYH2B9UTWD1-Z7sv3Aqtz9lA2JOByYL9Kz7B9VbVG5iMNGXZ14httrLAQaZNn0_Q';
  //   try {
  //     final response = await http.get(
  //       Uri.parse('$apicall/return_master/get_all_returnmaster'),
  //       headers: {
  //         'Authorization': 'Bearer $token',
  //       },
  //     );
  //     if (response.statusCode == 200) {
  //       final data = jsonDecode(response.body);
  //       print('Product Master Data:');
  //       print(data);
  //       // print('discount');
  //       // print(data['discount']);
  //       return data;
  //     } else {
  //       print('Failed to fetch product master data.');
  //       return [];
  //     }
  //   } catch (e) {
  //     print('Error fetching product master data: $e');
  //     return [];
  //   }
  // }
  //
  // Future<void> downloadCreditMemoPdf() async {
  //   final String orderId = 'ORD_03534';
  //   try {
  //     final productMasterData = await _fetchAllReturnMaster();
  //     final orderDetails = {
  //       'items': productMasterData.map((product) {
  //         return {
  //           'productName': product['productName'],
  //           'totalAmount': product['totalAmount'],
  //           'tax': product['tax'],
  //           'discount': product['discount'],
  //         };
  //       }).toList(),
  //     };
  //
  //     if (orderDetails != null) {
  //       final Uint8List pdfBytes = await CreditMemoPdf(orderDetails);
  //       final blob = html.Blob([pdfBytes]);
  //       final url = html.Url.createObjectUrlFromBlob(blob);
  //       final anchor = html.AnchorElement(href: url)
  //         ..setAttribute('download', 'Credit_Memo.pdf')
  //         ..click();
  //       html.Url.revokeObjectUrl(url);
  //     } else {
  //       print('Failed to generate order details.');
  //     }
  //   } catch (e) {
  //     print('Error generating PDF: $e');
  //   }
  // }
  // duplicate
  // Future downloadCreditMemoPdf() async {
  //   final String orderId = 'ORD_03534';
  //   try {
  //     final productMasterData = await _fetchAllProductMaster();
  //     final orderDetails = await _fetchOrderDetails(orderId);
  //     for (var product in productMasterData) {
  //       for (var item in orderDetails!.items) {
  //         if (product['productName'] == item['productName']) {
  //           item['tax'] = product['tax'];
  //           item['discount'] = product['discount'];
  //           item['discountamount'] = (double.parse(item['totalAmount'].toString()) * double.parse(item['discount'].replaceAll('%', ''))) / 100;
  //           item['taxamount'] = ((double.parse(item['totalAmount'].toString()) -
  //               double.parse(item['discountamount'].toString())) *
  //               double.parse(item['tax'].replaceAll('%', '').toString())) / 100;
  //         }
  //       }
  //     }
  //
  //     if (orderDetails != null) {
  //       final Uint8List pdfBytes = await CreditMemoPdf(orderDetails);
  //       final blob = html.Blob([pdfBytes]);
  //       final url = html.Url.createObjectUrlFromBlob(blob);
  //       final anchor = html.AnchorElement(href: url)
  //         ..setAttribute('download', 'Credit_Memo.pdf')
  //         ..click();
  //       html.Url.revokeObjectUrl(url);
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
  String token = 'eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJkaGFuYXNla2FyIiwiUm9sZXMiOlt7ImF1dGhvcml0eSI6ImRldmVsb3BlciJ9XSwiZXhwIjoxNzI1NjA3Nzc3LCJpYXQiOjE3MjU2MDA1Nzd9.stF0hO6T4ue3A_ayQw8BVgBg2Nov1k2_uwrc1BdlyJcWwEl8ycxIedJrTAuMCLJD8o7K7k6PQkWb1IFrD-hSqA';
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


Future<Uint8List> CreditMemoPdf(List<ReturnMaster> returnMasters) async {
  final pdf = pw.Document();
  double _total = 0.0;

  print(returnMasters);
  String returnId = '';
  String returnDate = '';
  String returnCredit = '';
  String invoiceNo = '';
  String orderId = '';
  String contactNumber = '';
  String shippingAddress = '';


  for (var returnMaster in returnMasters) {
    print('Return ID: ${returnMaster.returnId}');
    print('Return Date: ${returnMaster.returnDate}');
    print('Invoice Number: ${returnMaster.invoiceNumber}');
    print('Invoice Number: ${returnMaster.orderId}');
    returnId = returnMaster.returnId!;
    returnDate = returnMaster.returnDate!;
    returnCredit = returnMaster.returnCredit!.toString();
    invoiceNo = returnMaster.invoiceNumber.toString();
    orderId = returnMaster.orderId!;
    shippingAddress = returnMaster.ShippAddress!;
    contactNumber = returnMaster.ContactNumber!;

    print(returnId);
    print(returnDate);
    print(returnCredit);
    print(orderId);
    // print(ShippingAddress);
    // print(ContactNumber);
    // ... and so on
  }

// Now you can use returnId, returnDate, and returnCredit outside the loop
  print('Return ID: $returnId');
  print('Return Date: $returnDate');
  print('Return Credit: $returnCredit');
  print('Return Credit: $invoiceNo');
  print(orderId);
  // print(ShippingAddress);
  // print(ContactNumber);



  double calculateTotalPrice(List<ReturnMaster> returnMasters) {
    double totalPrice = 0;

    for (var returnMaster in returnMasters) {
      for (var item in returnMaster.items) {

        totalPrice += item.price * item.returnQty;
      }
    }

    return totalPrice;
  }

  double totalPrice = calculateTotalPrice(returnMasters);
  print('Total Price: $totalPrice');

  // double calculateTotalAmount1(List<dynamic> items) {
  //   double totalAmount = 0.0;
  //
  //   for (var item in items) {
  //     var itemMap = item as Map<String, dynamic>;
  //
  //     double qty = double.tryParse(itemMap['qty']?.toString() ?? '0') ?? 0.0;
  //     double totalAmountPerItem = double.tryParse(itemMap['totalamoun2']?.toString() ?? '0') ?? 0.0;
  //
  //     totalAmount += qty * totalAmountPerItem;
  //   }
  //
  //   return totalAmount;
  // }
  //
  //
  // double calculateTaxAmountTotal(List<dynamic> items) {
  //   double totalTaxAmount = 0.0;
  //
  //   for (var item in items) {
  //     var itemMap = item as Map<String, dynamic>;
  //
  //     double totalAmount = double.parse(itemMap['totalAmount'].toString());
  //     double discountAmount = double.parse(itemMap['discountamount'].toString());
  //     double taxPercentage = double.parse(itemMap['tax'].replaceAll('%', ''));
  //
  //     double taxAmount = ((totalAmount - discountAmount) * taxPercentage) / 100;
  //     totalTaxAmount += taxAmount;
  //   }
  //
  //   return totalTaxAmount;
  // }

  final logoData = await loadImage();

  //final pdf = pw.Document();
  final image = pw.MemoryImage(logoData);

  pw.Widget buildHeader() {
    return
      pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
      pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          //   pw.Image(logo, height: 50), // Company logo
          pw.Text(
            'Credit Memo: CM0001',
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
    ]
      );
  }

  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
     margin: pw.EdgeInsets.all(24),
      header: (pw.Context context){
        return buildHeader();
      },
      build: (pw.Context context) {
        return[
            // pw.SizedBox(height: 10),
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
           // pw.SizedBox(height: 10),
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
                  padding: pw.EdgeInsets.only(top: 70),
                  child:  pw.Column(
                     mainAxisAlignment: pw.MainAxisAlignment.end,
                     crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [

                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.start,
                        children: [
                          pw.SizedBox(height: 10),


                          pw.Padding(
                            padding: pw.EdgeInsets.only(right: 85),
                            child:  pw.Text(
                              'Date:',
                              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                            ),
                          ),
                          pw.SizedBox(width: 48),
                          pw.Text('          $returnDate')

                        ],
                      ),
                      pw.SizedBox(height: 4),
                      pw.Row(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Padding(
                            padding: pw.EdgeInsets.only(right: 41),
                            child:  pw.Text(
                              'Credit Memo Number:',
                              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                            ),
                          ),

                          pw.SizedBox(width: 15),
                          pw.Text('         CM0001'),
                          // pw.Text('   ${orderDetails.orderId}'),

                        ],
                      ),
                      pw.SizedBox(height: 4),
                      pw.Row(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Padding(
                            padding: pw.EdgeInsets.only(right: 9.5),
                            child:  pw.Text(
                              'Reference Invoice Number:',
                              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                            ),
                          ),

                          pw.SizedBox(width: 32),
                          pw.Text('$invoiceNo'),

                        ],
                      ),
                      pw.SizedBox(height: 4),
                      pw.Row(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Padding(
                            padding: pw.EdgeInsets.only(right: 44),
                            child:  pw.Text(
                              'Sales Order Number:',
                              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                            ),
                          ),

                          pw.SizedBox(width: 15),
                         pw.Text('   $orderId'),

                        ],
                      ),
                      pw.SizedBox(height: 4),
                      pw.Row(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Padding(
                            padding: pw.EdgeInsets.only(right: 4.5),
                            child: pw.Text(
                              'Customer Return Number:',
                              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                            ),
                          ),
                          pw.SizedBox(width: 28),
                          pw.Text('$returnId'),
                        ],
                      ),
                      pw.SizedBox(height: 4),
                      pw.Row(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Padding(
                            padding: pw.EdgeInsets.only(right: 45),
                            child:  pw.Text(
                              'Fulfillment Date:',
                              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                            ),
                          ),
                          pw.SizedBox(width: 46),
                         pw.Text('   $returnDate'),
                        ],
                      ),
                      pw.SizedBox(height: 4),
                      pw.Row(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Padding(
                            padding: pw.EdgeInsets.only(right: 65),
                            child: pw.Text(
                              'Customer Number:',
                              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                            ),
                          ),
                          pw.SizedBox(width: 15),
                          pw.Text('$contactNumber'),
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
          pw.Text('$shippingAddress'),
            // pw.Text('1120 Hamilton Street'),
            // pw.Text('Chennai 600002'),
            // pw.Text('${orderDetails.deliveryAddress}'),
            //pw.Text('Chennai 600002'),
            pw.SizedBox(height: 20),
        //   ...returnMasters.expand((returnMaster) => returnMaster.items.map((item) => [

          ...returnMasters.map((returnMaster) {
            print('print');
            print(returnMaster);
            print(returnMasters);

            return pw.Container(
              decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey)
              ),

              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
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
                      pw.TableRow(
                        decoration: pw.BoxDecoration(color: PdfColors.grey200),
                        children: [
                          buildCell1('Line'),
                          buildCell1('Product'),
                          buildCell1('Description'),
                          buildCell1('Return Qty'),
                          buildCell1('Net Price'),
                          buildCell1('Net Value'),
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
                    children: returnMaster.items.map((item) {
                      return pw.TableRow(
                        children: [
                          buildCell('+10'),
                          buildCell(item.productName.toString()),
                          buildCell(item.category.toString()),
                          buildCell(item.returnQty.toString()),
                          buildCell('${item.price.toString()} / 1 Each'),
                          buildCell('${(item.invoiceAmount / item.qty * item.returnQty).toStringAsFixed(2)} (including tax + disc.)'),
                        ],
                      );
                    }).toList(),
                  ),
                ],
              ),
            );
          }),
        // ...returnMasters.map((returnMaster) {
        //       print('print');
        //       print(returnMaster);
        //       print(returnMasters);
        //
        //       return  pw.Container(
        //         decoration: pw.BoxDecoration(
        //             border: pw.Border.all(color: PdfColors.grey)
        //         ),
        //
        //         child: pw.Column(
        //             crossAxisAlignment:pw.CrossAxisAlignment.start,
        //             children: [
        //
        //               pw.Table(
        //                 border: pw.TableBorder.all(color: PdfColors.grey),
        //                 columnWidths: const {
        //                   0: pw.FlexColumnWidth(0.6),
        //                   1: pw.FlexColumnWidth(1.2),
        //                   2: pw.FlexColumnWidth(1),
        //                   3: pw.FlexColumnWidth(0.6),
        //                   4: pw.FlexColumnWidth(1),
        //                   5: pw.FlexColumnWidth(1),
        //                 },
        //                 children: [
        //                   // ...orderDetails.items.map((item) {
        //                   pw.TableRow(
        //                     decoration: pw.BoxDecoration(color: PdfColors.grey200),
        //                     children: [
        //                       buildCell1('Line'),
        //                       buildCell1('Product'),
        //                       buildCell1('Description'),
        //                       buildCell1('Qty'),
        //                       buildCell1('Net Price'),
        //                       buildCell1('Net Value'),
        //                     ],
        //                   ),
        //                 ],
        //               ),
        //               pw.Table(
        //                 border: pw.TableBorder.all(color: PdfColors.grey),
        //                 columnWidths: const {
        //                   0: pw.FlexColumnWidth(0.6),
        //                   1: pw.FlexColumnWidth(1.2),
        //                   2: pw.FlexColumnWidth(1),
        //                   3: pw.FlexColumnWidth(0.6),
        //                   4: pw.FlexColumnWidth(1),
        //                   5: pw.FlexColumnWidth(1),
        //                 },
        //                 children: [
        //                   pw.TableRow(
        //                     children: [
        //                       buildCell('+10'),
        //                       buildCell(item['productName']),
        //                       buildCell(item['category']),
        //                       buildCell(item['qty'].toString()),
        //                       // buildCell(item['price'].toString()),
        //                       // buildCell(item['totalAmount'].toString()),
        //                       buildCell((item['totalamoun2'] = item['price'] - double.parse(item['discountamount'].toString())).toString()),
        //                       buildCell(
        //                           (_total = double.parse((item['qty']
        //                               * double.parse(item['totalamoun2'].toString()
        //                               )).toString())).toString()
        //                       ),
        //                     ],
        //                   ),
        //                 ],
        //               ),
        //
        //
        //
        //               // pw.Table(
        //               //   border: pw.TableBorder.all(color: PdfColors.grey),
        //               //   columnWidths: const {
        //               //     0: pw.FlexColumnWidth(0.6),
        //               //     1: pw.FlexColumnWidth(1.2),
        //               //     2: pw.FlexColumnWidth(1),
        //               //     3: pw.FlexColumnWidth(0.6),
        //               //     4: pw.FlexColumnWidth(1),
        //               //     5: pw.FlexColumnWidth(1),
        //               //   },
        //               //   children: [
        //               //     pw.TableRow(
        //               //       decoration: pw.BoxDecoration(color: PdfColors.grey200),
        //               //       children: [
        //               //         buildCell1('Line'),
        //               //         buildCell1('Product'),
        //               //         buildCell1('Description'),
        //               //         buildCell1('QTY'),
        //               //         buildCell1('Gross Price'),
        //               //         buildCell1('Gross Value'),
        //               //       ],
        //               //     ),
        //               //     pw.TableRow(
        //               //       children: [
        //               //         buildCell('20'),
        //               //         buildCell(' A00162'),
        //               //         buildCell('Laptop'),
        //               //         buildCell('1 Each'),
        //               //         buildCell('14,691.83 INR / 1 Each'),
        //               //         buildCell('14,691.83 INR'),
        //               //       ],
        //               //     ),
        //               //   ],
        //               // ),
        //
        //               pw.Padding(
        //                 padding: pw.EdgeInsets.only(left:55,right: 20,top: 5),
        //                 child: pw.Row(
        //                   mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        //                   children: [
        //                     pw.Text('List Price:',style: pw.TextStyle(fontSize: 10)),
        //                     //izedBox(width: 50,),
        //                     pw.Text('${item['totalAmount']} INR / 1 Each',style: pw.TextStyle(fontSize: 10)),
        //                     pw.Text('${item['totalAmount']} INR',style: pw.TextStyle(fontSize:10)),
        //
        //                     // Text('Gross Discount (%): -21.00 %'),
        //                     // Text('State sales tax (%): 5.50 %'),
        //                     // if (salesOrderNumber.isNotEmpty)
        //                     //   Text('Sales Order Number: $salesOrderNumber'),
        //                     // Text('No cash discount allowed'),
        //                   ],
        //                 ),
        //               ),
        //               pw.Padding(
        //                 padding: pw.EdgeInsets.only(left:55,right: 20 ),
        //                 child: pw.Row(
        //                   mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        //                   children: [
        //                     pw.Text('For Customer portal',style: pw.TextStyle(fontSize: 10)),
        //                     //izedBox(width: 50,),
        //                     pw.Text('${item['discount']}',style: pw.TextStyle(fontSize: 10)),
        //                     pw.Text('-${item['discountamount']}',style: pw.TextStyle(fontSize: 10)),
        //
        //                     // Text('Gross Discount (%): -21.00 %'),
        //                     // Text('State sales tax (%): 5.50 %'),
        //                     // if (salesOrderNumber.isNotEmpty)
        //                     //   Text('Sales Order Number: $salesOrderNumber'),
        //                     // Text('No cash discount allowed'),
        //                   ],
        //                 ),
        //               ),
        //               pw.Padding(
        //                 padding: pw.EdgeInsets.only(left:55,right: 20 ),
        //                 child: pw.Row(
        //                   mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        //                   children: [
        //                     pw. Text('State sales tax (%)',style: pw.TextStyle(fontSize: 10)),
        //                     //izedBox(width: 50,),
        //                     pw.Text('${item['tax']}',style: pw.TextStyle(fontSize: 10)),
        //                     pw.Text('${(item['taxamount'])}',style: pw.TextStyle(fontSize: 10)),
        //
        //                     // Text('Gross Discount (%): -21.00 %'),
        //                     // Text('State sales tax (%): 5.50 %'),
        //                     // if (salesOrderNumber.isNotEmpty)
        //                     //   Text('Sales Order Number: $salesOrderNumber'),
        //                     // Text('No cash discount allowed'),
        //                   ],
        //                 ),
        //               ),
        //               pw.SizedBox(height: 5),
        //             ]
        //         ),
        //       );
        //     },),

            pw.SizedBox(height: 20),

            // Totals
          //original tottals
          //   pw.Padding(padding: pw.EdgeInsets.only(left: 250,right: 50),
          //     child:pw.Row(
          //       mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          //       children: [
          //         pw.Column(mainAxisAlignment: pw.MainAxisAlignment.end,
          //           crossAxisAlignment: pw.CrossAxisAlignment.end,
          //           children: [
          //             pw.Row(
          //               mainAxisAlignment: pw.MainAxisAlignment.start,
          //               children: [
          //                 pw.Text('Total Item Gross Value:'),
          //                 pw.Text('     $returnCredit INR'),
          //               ],
          //             ),
          //             pw.SizedBox(height: 5), // add a gap of 10 units
          //             pw.Row(
          //               mainAxisAlignment: pw.MainAxisAlignment.start,
          //               children: [
          //                 pw.Text('GST:'),
          //                 pw.Text(' $totalPrice INR'),
          //               ],
          //             ),
          //             pw.SizedBox(height: 5), // add a gap of 10 units
          //             pw.Row(
          //               mainAxisAlignment: pw.MainAxisAlignment.start,
          //               children: [
          //                 pw.Text('Total:'),
          //                 pw.Text(' ${(double.parse(returnCredit)- double.parse(totalPrice.toString())).toStringAsFixed(2) } INR'),
          //               ],
          //             ),
          //           ],
          //         ),
          //       ],
          //     ),
          //   ),

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





