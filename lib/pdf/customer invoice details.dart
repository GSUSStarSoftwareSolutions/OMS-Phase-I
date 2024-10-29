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
    const String token = 'dmrBkn_ktN-u8c2Kej22qTEPyPhEDSNNk0RvuTtftgNFxDy223lG4wXrswEyA';
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

  /// Fetches products for a given order ID.
  Future<List<dynamic>>fetchProducts(String orderId) async {
    const token = 'eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJkaGFuYXNla2FyIiwiUm9sZXMiOlt7ImF1dGhvcml0eSI6ImRldmVsb3BlciJ9XSwiZXhwIjoxNzI2NTUwOTkzLCJpYXQiOjE3MjY1NDM3OTN9.rld2WZLY1ike7K1ykjgT11WV5hxJ6WLzYxtkvCmJZeDteUqK3m1Run-GGxlDdNlDus6oLCCLCtC1lbKZl1k38Q';

    try {
      final response = await http.get(
        Uri.parse(
          '$apicall/order_master/get_all_ordermaster_by_customer/$orderId',
        ),
        headers: {
          "Content-type": "application/json",
          "Authorization": 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        print('Response Body: ${response.body}');
        return jsonDecode(response.body);

      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Error decoding JSON: $e');
      rethrow; // Re-throw the exception to handle it in the caller function
    }
  }

  /// Downloads the PDF for a given order ID.
  Future<void> downloadPdf() async {
    const String orderId = 'CUST_05143';
    try {
      final orderDetails = await fetchProducts(orderId);

      if (orderDetails != null) {
        print('hi');
        print(orderDetails);
        final orderDetailJson = orderDetails.first;
       final orderDetail = OrderDetail.fromJson(orderDetailJson);
        final Uint8List pdfBytes = await CustomerInvoiceList(orderDetails);
        final blob = html.Blob([pdfBytes]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute('download', 'Customer_Invoice.pdf')
          ..click();
        html.Url.revokeObjectUrl(url);
      } else {
        print('Failed to fetch order details.');
      }
    } catch (e) {
      print('Error generating PDF: $e');
    }
  }

}

Future<Uint8List> loadImage() async {
  final ByteData data = await rootBundle.load('images/Final-Ikyam-Logo.png');
  return data.buffer.asUint8List();
}





Future<Uint8List> CustomerInvoiceList(List<dynamic> orderDetails) async {
  final pdf = pw.Document();

  final tableHeaders = [
    pw.Center(child:pw.Text('Invoice No')),
    pw.Center(child:pw.Text('Payment ID')),
    pw.Center(child:pw.Text('Payment Date')),
    pw.Center(child:pw.Text('Amount')),
    pw.Center(child:pw.Text('Paid Amount')),
    pw.Center(child:pw.Text('Status')),
  ];

   final tableData = [];

   // Loop through the API response and extract the required data
  for (var order in orderDetails) {
    tableData.add([
      pw.Center(child:pw.Text(order['invoiceNo'].toString())),
      pw.Center(child:pw.Text(order['paymentId'].toString())),
      pw.Center(child:pw.Text(order['paymentDate'].toString())),
      pw.Center(child:pw.Text(order['total'].toString())),
      pw.Center(child:pw.Text(order['paidAmount'].toString())),
      pw.Center(child:pw.Text(order['paymentStatus'].toString())),
    ]);
  }


  final table = pw.Table(
    columnWidths: const {
      0: pw.FlexColumnWidth(0.9),
      1: pw.FlexColumnWidth(0.9),
      2: pw.FlexColumnWidth(0.9),
      3: pw.FlexColumnWidth(0.6),
      4: pw.FlexColumnWidth(0.6),
      5: pw.FlexColumnWidth(0.6),
    },
    border: pw.TableBorder.all(color: PdfColors.grey),
    children: [
      pw.TableRow(
        decoration: pw.BoxDecoration(color: PdfColors.grey200),
        children: tableHeaders,
      ),
      ...tableData.map((row) => pw.TableRow(
        decoration: pw.BoxDecoration(color: PdfColors.white),
        children: row,
      )),
    ],
  );

 // Create a table widget


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
              // pw.Text(
              //   'ORDER ID:  ${orderDetails.orderId}',
              //   style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
              // ),
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

          pw.SizedBox(height: 10),
          table,

          pw.SizedBox(height: 20),
          pw.SizedBox(height: 320),
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
                      ]
                  ),
                  pw.Row(
                      children: [

                        pw.Text(
                            '4th Block, New Friends Colony,\n'
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








