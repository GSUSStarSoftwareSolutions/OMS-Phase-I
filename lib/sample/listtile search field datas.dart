import 'dart:convert';
import 'dart:html';

import 'package:btb/admin/Api%20name.dart';
import 'package:btb/widgets/productclass.dart' as ord;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;

import '../Order Module/firstpage.dart';


class ListTileSearchData extends StatefulWidget {
  const ListTileSearchData({super.key});

  @override
  State<ListTileSearchData> createState() => _ListTileSearchDataState();
}

class _ListTileSearchDataState extends State<ListTileSearchData> {

  List<detail> productList = [];
  String token = window.sessionStorage["token"] ?? " ";
  bool isLoading = false;


  Future<void> fetchProducts(int page, int itemsPerPage) async {
    if (isLoading) return;
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse(
          '$apicall/productmaster/get_all_productmaster?page=$page&limit=$itemsPerPage', // Changed limit to 10
        ),
        headers: {
          "Content-type": "application/json",
          "Authorization": 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        List<detail> products = [];
        if (jsonData != null) {
          if (jsonData is List) {
            products = jsonData.map((item) =>detail.fromJson(item)).toList();
          } else if (jsonData is Map && jsonData.containsKey('body')) {
            products = (jsonData['body'] as List).map((item) => detail.fromJson(item)).toList();
            //  totalItems = jsonData['totalItems'] ?? 0;

            print('pages');
            //print(totalPages);// Changed itemsPerPage to 10
          }

          setState(() {
            productList = products;
            // totalPages = (products.length / itemsPerPage).ceil();
            // print(totalPages);
            //_filterAndPaginateProducts();
          });
        }
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Error decoding JSON: $e');
      // Optionally, show an error message to the user
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    return ElevatedButton(onPressed: (){
      context.go('/Order_Placed_List', extra: {
        'product': detail,
        'item': [], // pass an empty list of maps
        'body': {},
       // 'status': detail.deliveryStatus,
        'itemsList': [], // pass an empty list of maps
        'orderDetails': productList.map((detail) => OrderDetail(
          orderId: detail.orderId,
          orderDate: detail.orderDate, items: [],
          deliveryStatus: detail.deliveryStatus,
          // Add other fields as needed
        )).toList(),
      });
    }, child: null);
  }
}
