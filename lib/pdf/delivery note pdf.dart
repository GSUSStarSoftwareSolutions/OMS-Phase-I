
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


// import 'package:your_project/Return%20Module/Return%20pdf.dart'; // Update this import path

void main() {
  runApp(DeliveryNote());
}

class DeliveryNote extends StatelessWidget {
  late  final discount = 0;
  @override
  Widget build(BuildContext context) {
    String discount;
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('PDF for Delivery Note'),
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
    final String token = 'eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJkaGFuYXNla2FyIiwiUm9sZXMiOlt7ImF1dGhvcml0eSI6ImRldmVsb3BlciJ9XSwiZXhwIjoxNzIzMjY4MDk4LCJpYXQiOjE3MjMyNjA4OTh9.GA66i8d7RzYDeZbElDpkHe0EdlBNCKZweQjwTcaMI3HPP1W_b43YKgSqomohzFXsYV-JAAVGY-6yfRT_B2l3sg';
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
    final String orderId = 'ORD_02282';
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
        final Uint8List pdfBytes = await Deliverypdf(orderDetails);
        final blob = html.Blob([pdfBytes]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute('download', 'Delivery_Note.pdf')
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
  String token = 'eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJkaGFuYXNla2FyIiwiUm9sZXMiOlt7ImF1dGhvcml0eSI6ImRldmVsb3BlciJ9XSwiZXhwIjoxNzIzMjY4MDk4LCJpYXQiOjE3MjMyNjA4OTh9.GA66i8d7RzYDeZbElDpkHe0EdlBNCKZweQjwTcaMI3HPP1W_b43YKgSqomohzFXsYV-JAAVGY-6yfRT_B2l3sg';
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


Future<Uint8List> Deliverypdf(OrderDetail orderDetails) async {
  final pdf = pw.Document();
  final logoData = await loadImage();
  final image = pw.MemoryImage(logoData);

  pw.Widget buildDetailRow(String label, String value) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Padding(
          padding: pw.EdgeInsets.only(right: 180),
          child: pw.Text(label, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        ),
        pw.SizedBox(width: 10),
        pw.Text(value),
      ],
    );
  }

  // Function to create the header
  pw.Widget buildHeader() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'Delivery Note: 0001',
              style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(width: 10),
            pw.Image(image, height: 20),
          ],
        ),
        pw.SizedBox(height: 10),
        pw.Padding(
          padding: pw.EdgeInsets.only(left: 15),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.start,
            children: [
              pw.Container(
                height: 5,
                width: 250,
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey),
                ),
              ),
              pw.Container(
                height: 5,
                width: 250,
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey200,
                  border: pw.Border.all(color: PdfColors.grey),
                ),
              ),
            ],
          ),
        ),
        pw.SizedBox(height: 10),


      ],
    );
  }

  pw.Widget buildBody(){
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children:[

        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Padding(
              padding: pw.EdgeInsets.only(top: 35),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('1120 Hamilton Street'),
                  pw.Text('Toledo OH 43607'),
                ],
              ),
            ),
            pw.Padding(
              padding: pw.EdgeInsets.only(top: 35),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.start,
                    children: [
                      pw.Padding(
                        padding: pw.EdgeInsets.only(right: 40),
                        child: pw.Text(
                          'Print Date/Time:',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                      ),
                      pw.SizedBox(width: 10),
                      pw.Text('8/8/2024 2:59:42 AM'),
                    ],
                  ),
                  pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Padding(
                        padding: pw.EdgeInsets.only(right: 84),
                        child:  pw.Text(
                          'Ship-To Party:',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                      ),

                      pw.SizedBox(width: 15),
                      pw.Text('         CP0001'),
                      // pw.Text('   ${orderDetails.orderId}'),

                    ],
                  ),

                  pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Padding(
                        padding: pw.EdgeInsets.only(right: 85),
                        child:  pw.Text(
                          'Contact',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                      ),

                      pw.SizedBox(width: 15),
                      pw.Text('     Martin Wellington'),

                    ],
                  ),

                  pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Padding(
                        padding: pw.EdgeInsets.only(right: 100),
                        child:  pw.Text(
                          'Phone:',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                      ),

                      pw.SizedBox(width: 15),
                      pw.Text('   +914564644687'),

                    ],
                  ),

                  pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Padding(
                        padding: pw.EdgeInsets.only(right: 87.5),
                        child: pw.Text(
                          'Fax:',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                      ),
                      pw.SizedBox(width: 45),
                      pw.Text('    +123-456-7890'),
                    ],
                  ),

                  pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Padding(
                        padding: pw.EdgeInsets.only(right: 58.9),
                        child:  pw.Text(
                          'E-mail:',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                      ),

                      pw.SizedBox(width: 45),
                      pw.Text('  Ikyam@gmail.com '),
                    ],
                  ),

                  pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Padding(
                        padding: pw.EdgeInsets.only(right: 90),
                        child: pw.Text(
                          'Shipment Date:',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                      ),
                      pw.SizedBox(width: 15),
                      pw.Text('09/08/2024'),
                    ],
                  ),
                  pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Padding(
                        padding: pw.EdgeInsets.only(right: 98),
                        child: pw.Text(
                          'Delivery Date:',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                      ),
                      pw.SizedBox(width: 15),
                      pw.Text('09/08/2024'),
                    ],
                  ),
                  pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Padding(
                        padding: pw.EdgeInsets.only(right: 109),
                        child: pw.Text(
                          'Incoterms:',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                      ),
                      pw.SizedBox(width: 15),
                      pw.Text('${orderDetails.contactNumber}'),
                    ],
                  ),
                  pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Padding(
                        padding: pw.EdgeInsets.only(right: 67),
                        child: pw.Text(
                          'Freight Forwarder:',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                      ),
                      pw.SizedBox(width: 15),
                      pw.Text('Miller & Son'),
                    ],
                  ),
                  // buildDetailRow('Ship-To Party:', '         CP0001'),
                  // buildDetailRow('Contact', '     Martin Wellington'),
                  // buildDetailRow('Phone:', '   +914564644687'),
                  // buildDetailRow('Fax:', '    +123-456-7890'),
                  // buildDetailRow('E-mail:', '  Ikyam@gmail.com'),
                  // buildDetailRow('Shipment Date:', '09/08/2024'),
                  // buildDetailRow('Delivery Date:', '09/08/2024'),
                  // buildDetailRow('Incoterms:', '${orderDetails.contactNumber}'),
                  // buildDetailRow('Freight Forwarder:', 'Miller & Son'),
                ],
              ),
            ),
          ],
        ),

      ]
    );
  }



  // Function to create table headers
  pw.Widget buildTableHeader() {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey),
      columnWidths: const {
        0: pw.FlexColumnWidth(0.6),
        1: pw.FlexColumnWidth(1.2),
        2: pw.FlexColumnWidth(1),
        3: pw.FlexColumnWidth(1.5),
        4: pw.FlexColumnWidth(0.6),
        5: pw.FlexColumnWidth(0.9),
        6: pw.FlexColumnWidth(0.9),
        7: pw.FlexColumnWidth(1),
      },
      children: [
        pw.TableRow(
          decoration: pw.BoxDecoration(color: PdfColors.grey200),
          children: [
            buildCell1('Item'),
            buildCell1('Our Reference/Your Reference'),
            buildCell1('Product Customer Part Number'),
            buildCell1('Product Specification IStock/ Serial No.'),
            buildCell1('Qty'),
            buildCell1('Weight'),
            buildCell1('Volume'),
            buildCell1('Notes'),
          ],
        ),
      ],
    );
  }

  // Function to create a row for each item
  pw.Widget buildItemRow(Map<String, dynamic> item) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey),
      columnWidths: const {
        0: pw.FlexColumnWidth(0.6),
        1: pw.FlexColumnWidth(1.2),
        2: pw.FlexColumnWidth(1),
        3: pw.FlexColumnWidth(1.5),
        4: pw.FlexColumnWidth(0.6),
        5: pw.FlexColumnWidth(0.9),
        6: pw.FlexColumnWidth(0.9),
        7: pw.FlexColumnWidth(1),
      },
      children: [
        pw.TableRow(
          children: [
            buildCell('+10'),
            buildCell(item['productName']),
            buildCell(item['category']),
            buildCell(''),
            buildCell(item['qty'].toString()),
            buildCell(''),
            buildCell(''),
            buildCell(''),
          ],
        ),
      ],
    );
  }

  // Function to create the footer
  pw.Widget buildFooter() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(height: 25),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.start,
          children: [
            pw.Text('Signature', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.Text('______________'),
            pw.Text('Date', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.Text('_______________'),
          ],
        ),
        pw.SizedBox(height: 5),
        pw.Text(
          'By signature the undersigned confirms that this delivery has been received in full and in good order and condition.',
        ),
        pw.SizedBox(height: 10),
        pw.Text('Ikyam Solution pvt. Ltd..,'),
        pw.Text('4th Block, New Friends Colony,'),
        pw.Text('Koramangala, Bengaluru,'),
        pw.Text('Karnataka 560034.'),
      ],
    );
  }

  // Function to build a detail row


  // Adding pages dynamically
  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: pw.EdgeInsets.all(24),
      header: (pw.Context context){
        return buildHeader();
      },
      build: (pw.Context context) {
        return [
       //   buildHeader(),
          buildBody(),
          pw.SizedBox(height: 20),
          pw.Text(
            'Shipping Instruction:',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 20),
          buildTableHeader(),
          pw.ListView.builder(
            itemCount: orderDetails.items.length,
            itemBuilder: (context, index) {
              return buildItemRow(orderDetails.items[index]);
            },
          ),
          pw.SizedBox(height: 20),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.start,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.start,
                    children: [
                      pw.Text('Gross Weight'),
                      // pw.Text('     ${orderDetails.total} INR'),
                    ],
                  ),
                  pw.SizedBox(height: 5),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.start,
                    children: [
                      pw.Text('Gross Volume'),
                      // pw.Text('       1634.97 INR'),
                    ],
                  ),
                  pw.SizedBox(height: 5),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.start,
                    children: [
                      pw.Text('Package details'),
                      // pw.Text('       ${orderDetails.total} INR'),
                    ],
                  ),
                ],
              ),
            ],
          ),
          buildFooter(),
        ];
      },
    ),
  );

  return pdf.save();
}

// Future<Uint8List> Deliverypdf(OrderDetail orderDetails) async {
//   final pdf = pw.Document();
//
//   final logoData = await loadImage();
//
//   //final pdf = pw.Document();
//   final image = pw.MemoryImage(logoData);
//
//   pdf.addPage(
//     pw.Page(
//       pageFormat: PdfPageFormat.a4,
//       build: (pw.Context context) {
//         return pw.Column(
//           crossAxisAlignment: pw.CrossAxisAlignment.start,
//           children: [
//             pw.Row(
//               mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//               children: [
//                 //   pw.Image(logo, height: 50), // Company logo
//                 pw.Text(
//                   'Delivery Note: 0001',
//                   style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
//                 ),
//                 pw.SizedBox(width: 10,),
//                 pw.Image(image, height: 20,),
//               ],
//             ),
//             pw.Row(
//               mainAxisAlignment: pw.MainAxisAlignment.end,
//               children: [
//
//               ],
//             ),
//             pw.SizedBox(height: 10),
//             pw.Row(
//                 mainAxisAlignment: pw.MainAxisAlignment.start,
//                 children: [
//                   pw.Container(
//                     height: 5,
//                     width: 250,
//                     decoration: pw.BoxDecoration(
//                       border: pw.Border.all(color:  PdfColors.grey),
//                       // borderRadius: pw.BorderRadius.circular(3.5), // Set border radius here
//                     ),
//                   ),
//                   // pw.SizedBox(width: 300,),
//                   pw.Container(
//                     height: 5,
//                     width: 250,
//                     decoration: pw.BoxDecoration(
//                       color: PdfColors.grey200,
//                       border: pw.Border.all(color:  PdfColors.grey),
//                       //  borderRadius: pw.BorderRadius.circular(3.5), // Set border radius here
//                     ),
//                   ),
//                 ]
//             ),
//           //  pw.SizedBox(height: 10),
//             // Invoice Header
//             pw.Row(
//               crossAxisAlignment: pw.CrossAxisAlignment.start,
//               mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//               children: [
//                 pw.Padding(
//                   padding: pw.EdgeInsets.only(top: 35),
//                   child: pw.Column(
//                     mainAxisAlignment: pw.MainAxisAlignment.start,
//                     crossAxisAlignment: pw.CrossAxisAlignment.start,
//                     children: [
//                       pw.Text('1120 Hamilton Street'),
//                       pw.Text('Toledo OH 43607'),
//                     ],
//                   ),
//                 ),
//
//                 pw.Padding(
//                   padding: pw.EdgeInsets.only(top: 35),
//                   child:  pw.Column(
//                     mainAxisAlignment: pw.MainAxisAlignment.end,
//                     crossAxisAlignment: pw.CrossAxisAlignment.end,
//                     children: [
//
//                       pw.Row(
//                         mainAxisAlignment: pw.MainAxisAlignment.start,
//                         children: [
//                           //pw.SizedBox(height: 10),
//
//
//                           pw.Padding(
//                             padding: pw.EdgeInsets.only(right: 40),
//                             child:  pw.Text(
//                               'Print Date/Time:',
//                               style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
//                             ),
//                           ),
//                           pw.SizedBox(width: 10),
//                           pw.Text('8/8/2024 2:59:42 AM')
//
//                         ],
//                       ),
//                       //pw.SizedBox(height: 4),
//                       // pw.Row(
//                       // crossAxisAlignment: pw.CrossAxisAlignment.start,
//                       // children: [
//                       // pw.Padding(
//                       // padding: pw.EdgeInsets.only(right: 77),
//                       // child: pw.Text(
//                       // 'Invoice Number:',
//                       // style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
//                       // ),
//                       // ),
//                       //
//                       //
//                       // pw.SizedBox(width: 15),
//                       // pw.Text('INV_02276'),
//                       // ],
//                       // ),
//
//                       pw.Row(
//                         crossAxisAlignment: pw.CrossAxisAlignment.start,
//                         children: [
//                           pw.Padding(
//                             padding: pw.EdgeInsets.only(right: 84),
//                             child:  pw.Text(
//                               'Ship-To Party:',
//                               style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
//                             ),
//                           ),
//
//                           pw.SizedBox(width: 15),
//                           pw.Text('         CP0001'),
//                           // pw.Text('   ${orderDetails.orderId}'),
//
//                         ],
//                       ),
//
//                       pw.Row(
//                         crossAxisAlignment: pw.CrossAxisAlignment.start,
//                         children: [
//                           pw.Padding(
//                             padding: pw.EdgeInsets.only(right: 85),
//                             child:  pw.Text(
//                               'Contact',
//                               style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
//                             ),
//                           ),
//
//                           pw.SizedBox(width: 15),
//                           pw.Text('     Martin Wellington'),
//
//                         ],
//                       ),
//
//                       pw.Row(
//                         crossAxisAlignment: pw.CrossAxisAlignment.start,
//                         children: [
//                           pw.Padding(
//                             padding: pw.EdgeInsets.only(right: 100),
//                             child:  pw.Text(
//                               'Phone:',
//                               style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
//                             ),
//                           ),
//
//                           pw.SizedBox(width: 15),
//                           pw.Text('   +914564644687'),
//
//                         ],
//                       ),
//
//                       pw.Row(
//                         crossAxisAlignment: pw.CrossAxisAlignment.start,
//                         children: [
//                           pw.Padding(
//                             padding: pw.EdgeInsets.only(right: 87.5),
//                             child: pw.Text(
//                               'Fax:',
//                               style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
//                             ),
//                           ),
//                           pw.SizedBox(width: 45),
//                           pw.Text('    +123-456-7890'),
//                         ],
//                       ),
//
//                       pw.Row(
//                         crossAxisAlignment: pw.CrossAxisAlignment.start,
//                         children: [
//                           pw.Padding(
//                             padding: pw.EdgeInsets.only(right: 58.9),
//                             child:  pw.Text(
//                               'E-mail:',
//                               style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
//                             ),
//                           ),
//
//                           pw.SizedBox(width: 45),
//                           pw.Text('  Ikyam@gmail.com '),
//                         ],
//                       ),
//
//                       pw.Row(
//                         crossAxisAlignment: pw.CrossAxisAlignment.start,
//                         children: [
//                           pw.Padding(
//                             padding: pw.EdgeInsets.only(right: 90),
//                             child: pw.Text(
//                               'Shipment Date:',
//                               style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
//                             ),
//                           ),
//                           pw.SizedBox(width: 15),
//                           pw.Text('09/08/2024'),
//                         ],
//                       ),
//                       pw.Row(
//                         crossAxisAlignment: pw.CrossAxisAlignment.start,
//                         children: [
//                           pw.Padding(
//                             padding: pw.EdgeInsets.only(right: 98),
//                             child: pw.Text(
//                               'Delivery Date:',
//                               style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
//                             ),
//                           ),
//                           pw.SizedBox(width: 15),
//                           pw.Text('09/08/2024'),
//                         ],
//                       ),
//                       pw.Row(
//                         crossAxisAlignment: pw.CrossAxisAlignment.start,
//                         children: [
//                           pw.Padding(
//                             padding: pw.EdgeInsets.only(right: 109),
//                             child: pw.Text(
//                               'Incoterms:',
//                               style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
//                             ),
//                           ),
//                           pw.SizedBox(width: 15),
//                           pw.Text('${orderDetails.contactNumber}'),
//                         ],
//                       ),
//                       pw.Row(
//                         crossAxisAlignment: pw.CrossAxisAlignment.start,
//                         children: [
//                           pw.Padding(
//                             padding: pw.EdgeInsets.only(right: 67),
//                             child: pw.Text(
//                               'Freight Forwarder:',
//                               style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
//                             ),
//                           ),
//                           pw.SizedBox(width: 15),
//                           pw.Text('Miller & Son'),
//                         ],
//                       ),
//                     ],
//                   ),
//                 )
//               ],
//             ),
//             pw.SizedBox(height: 20),
//
//             // Ship-to Address
//             pw.Text(
//               'Shipping Instruction:',
//               style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
//             ),
//
//             // pw.Text('${orderDetails.deliveryAddress}'),
//             //pw.Text('Chennai 600002'),
//             pw.SizedBox(height: 20),
//             ...orderDetails.items.map((item) {
//               print('print');
//               print(item);
//
//               return  pw.Container(
//                 decoration: pw.BoxDecoration(
//                     border: pw.Border.all(color: PdfColors.grey)
//                 ),
//
//                 child: pw.Column(
//                     crossAxisAlignment:pw.CrossAxisAlignment.start,
//                     children: [
//
//                       pw.Table(
//                         border: pw.TableBorder.all(color: PdfColors.grey),
//                         columnWidths: const {
//                           0: pw.FlexColumnWidth(0.6),
//                           1: pw.FlexColumnWidth(1.2),
//                           2: pw.FlexColumnWidth(1),
//                           3: pw.FlexColumnWidth(1.5),
//                           4: pw.FlexColumnWidth(0.6),
//                           5: pw.FlexColumnWidth(0.9),
//                           6: pw.FlexColumnWidth(0.9),
//                           7: pw.FlexColumnWidth(1),
//                         },
//                         children: [
//                           // ...orderDetails.items.map((item) {
//                           pw.TableRow(
//                             decoration: pw.BoxDecoration(color: PdfColors.grey200),
//                             children: [
//                               buildCell1('Item'),
//                               buildCell1('Our Reference/Your Reference'),
//                               buildCell1('Product Customer Part Number'),
//                               buildCell1('Product Specification IStock/ Serial No.'),
//                               buildCell1('Qty'),
//                               buildCell1('Weight'),
//                               buildCell1('Volume'),
//                               buildCell1('Notes'),
//                             ],
//                           ),
//                         ],
//                       ),
//                       pw.Table(
//                         border: pw.TableBorder.all(color: PdfColors.grey),
//                         columnWidths: const {
//                           0: pw.FlexColumnWidth(0.6),
//                           1: pw.FlexColumnWidth(1.2),
//                           2: pw.FlexColumnWidth(1),
//                           3: pw.FlexColumnWidth(1.5),
//                           4: pw.FlexColumnWidth(0.6),
//                           5: pw.FlexColumnWidth(0.9),
//                           6: pw.FlexColumnWidth(0.9),
//                           7: pw.FlexColumnWidth(1),
//                         },
//                         children: [
//
//                           pw.TableRow(
//                             children: [
//                               buildCell('+10'),
//                               buildCell(item['productName']),
//                               buildCell(item['category']),
//                               buildCell(''),
//                               buildCell(item['qty'].toString()),
//                               buildCell(''),
//                               buildCell(''),
//                               buildCell(''),
//                             ],
//                           ),
//                         ],
//                       ),
//
//
//
//                       // pw.Table(
//                       //   border: pw.TableBorder.all(color: PdfColors.grey),
//                       //   columnWidths: const {
//                       //     0: pw.FlexColumnWidth(0.6),
//                       //     1: pw.FlexColumnWidth(1.2),
//                       //     2: pw.FlexColumnWidth(1),
//                       //     3: pw.FlexColumnWidth(0.6),
//                       //     4: pw.FlexColumnWidth(1),
//                       //     5: pw.FlexColumnWidth(1),
//                       //   },
//                       //   children: [
//                       //     pw.TableRow(
//                       //       decoration: pw.BoxDecoration(color: PdfColors.grey200),
//                       //       children: [
//                       //         buildCell1('Line'),
//                       //         buildCell1('Product'),
//                       //         buildCell1('Description'),
//                       //         buildCell1('QTY'),
//                       //         buildCell1('Gross Price'),
//                       //         buildCell1('Gross Value'),
//                       //       ],
//                       //     ),
//                       //     pw.TableRow(
//                       //       children: [
//                       //         buildCell('20'),
//                       //         buildCell(' A00162'),
//                       //         buildCell('Laptop'),
//                       //         buildCell('1 Each'),
//                       //         buildCell('14,691.83 INR / 1 Each'),
//                       //         buildCell('14,691.83 INR'),
//                       //       ],
//                       //     ),
//                       //   ],
//                       // ),
//                     ]
//                 ),
//               );
//             },),
//
//             pw.SizedBox(height: 20),
//
//             // Totals
//             pw.Row(
//               mainAxisAlignment: pw.MainAxisAlignment.start,
//               children: [
//                 pw.Column(mainAxisAlignment: pw.MainAxisAlignment.start,
//                   crossAxisAlignment: pw.CrossAxisAlignment.start,
//                   children: [
//                     pw.Row(
//                       mainAxisAlignment: pw.MainAxisAlignment.start,
//                       children: [
//                         pw.Text('Gross Weight'),
//                        // pw.Text('     ${orderDetails.total} INR'),
//                       ],
//                     ),
//                     pw.SizedBox(height: 5), // add a gap of 10 units
//                     pw.Row(
//                       mainAxisAlignment: pw.MainAxisAlignment.start,
//                       children: [
//                         pw.Text('Gross Volume'),
//                  //       pw.Text('       1634.97 INR'),
//                       ],
//                     ),
//                     pw.SizedBox(height: 5), // add a gap of 10 units
//                     pw.Row(
//                       mainAxisAlignment: pw.MainAxisAlignment.start,
//                       children: [
//
//                         pw.Text('Package details'),
//                     //    pw.Text('       ${orderDetails.total} INR'),
//                       ],
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//
//             pw.SizedBox(height: 25),
//             //pw.SizedBox(height: 180),
//             pw.Row(
//               mainAxisAlignment: pw.MainAxisAlignment.start,
//               children: [
//
//                 pw.Text('Signature',style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
//                     pw.Text('______________'),
//                 pw.Text('Date',style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
//                 pw.Text('_______________')
//               ],
//             ),
//             pw.SizedBox(height: 5),
//             pw.Text('By signature the undersigned confirms that this delivery has been received in full and in good order and condition.'),
//
//             // Company Information
//             pw.Row(
//               mainAxisAlignment: pw.MainAxisAlignment.start,
//               children: [
//                 pw.Column(
//                   crossAxisAlignment: pw.CrossAxisAlignment.start,
//                   children: [
//                     pw.SizedBox(height: 10),
//                     pw.Row(
//                         children: [
//                           pw.Text(
//                               'Ikyam Solution pvt. Ltd..,'
//                           ),
//                           // pw.Text(
//                           //   'Registered Office:',style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
//                           //
//                           // ),
//                           //  pw.SizedBox(width: 5),
//
//                         ]
//                     ),
//                     //  pw.SizedBox(height: 10),
//                     pw.Row(
//                         children: [
//                           // pw.Text(
//                           //   'Address:',style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
//                           //
//                           // ),
//                           // pw.SizedBox(width: 5),
//                           pw.Text(
//                               '4th Block, New Friends Colony,\n'
//                             // 'Koramangala, Bengaluru,\n'
//                             // 'Karnataka 560034.',
//                           ),
//
//
//                         ]
//                     ),
//                     pw.Row(
//                         children: [
//                           pw.SizedBox(height: 5),
//                           pw.Text(
//                               'Koramangala, Bengaluru,\n'
//                             // 'Karnataka 560034.',
//                           ),
//
//
//                         ]
//                     ),
//                     pw.Row(
//                         children: [
//                           pw.SizedBox(height: 5),
//                           pw.Text(
//
//                             'Karnataka 560034.',
//                           ),
//
//                         ]
//                     ),
//                     pw.SizedBox(height: 5),
//                   ],
//                 ),
//               ],
//             ),
//           ],
//         );
//       },
//     ),
//   );
//
//   return pdf.save();
// }












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





