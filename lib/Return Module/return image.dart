import 'dart:convert';
import 'dart:html';
import 'dart:io' as io;
import 'package:btb/admin/Api%20name.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../Order Module/add productmaster sample.dart';
import '../widgets/confirmdialog.dart';
import '../widgets/productclass.dart';


void main(){
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: ReturnImage(orderDetails: [], storeImages: [],imageSizeString: [], imageSizeStrings: [], orderDetailsMap: {}) ,));
}


class ReturnImage extends StatefulWidget {
  final List<dynamic>? orderDetails;
  List<String> storeImages = [];
  List<String> imageSizeString = [];
  List<String> imageSizeStrings = [];
  final Map<String, dynamic> orderDetailsMap;



  ReturnImage({super.key,required this.orderDetails,required this.storeImages, required this.imageSizeStrings,required this.orderDetailsMap,required this.imageSizeString});

  @override
  _ReturnImageState createState() => _ReturnImageState();
}

class _ReturnImageState extends State<ReturnImage> {
  //List<String>? _selectedProduct = ['select a reason'];
  String? _selectedProduct;
  String storeImage = '';
  var result;
  String imageId = '';
  bool isOrdersSelected = false;
  String imageSizeString ='';
  //String _imageSizeStrings ='';
  List<Uint8List> selectedImages = [];
  List<String> imageNameList = [];
  final TextEditingController imagenameController = TextEditingController();
  final TextEditingController imageIdController = TextEditingController();
  String? imagePath;
  String token = window.sessionStorage["token"] ?? " ";
  io.File? selectedImage;
  List<Order> _orders = [];
  Map<String, bool> _isHovered = {
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
  //final List<Order> _orders = widget.orderDetails.map((item) => Order.fromJson(item)).toList();

  List<Widget> _buildMenuItems(BuildContext context) {
    return [
      _buildMenuItem('Home', Icons.home_outlined, Colors.blue[900]!, '/Home'),
      _buildMenuItem('Customer', Icons.account_circle_outlined, Colors.blue[900]!, '/Customer'),
      _buildMenuItem('Products', Icons.image_outlined, Colors.blue[900]!, '/Product_List'),
      _buildMenuItem('Orders', Icons.warehouse_outlined, Colors.blue[900]!, '/Order_List'),
      _buildMenuItem('Delivery', Icons.fire_truck_outlined, Colors.blue[900]!, '/Delivery_List'),
      _buildMenuItem('Invoice', Icons.document_scanner_outlined, Colors.blue[900]!, '/Invoice'),

      _buildMenuItem('Payment', Icons.payment_rounded, Colors.blue[900]!, '/Payment_List'),
      Container(
          decoration: BoxDecoration(
            color: Colors.blue[800]  ,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8), // Radius for top-left corner
              topRight: Radius.circular(8), // No radius for top-right corner
              bottomLeft: Radius.circular(8), // Radius for bottom-left corner
              bottomRight: Radius.circular(8), // No radius for bottom-right corner
            ),
          ),
          child: _buildMenuItem('Return', Icons.keyboard_return, Colors.white, '/Return_List')),
      _buildMenuItem('Reports', Icons.insert_chart_outlined, Colors.blue[900]!, '/Report_List'),
    ];
  }

  Widget _buildMenuItem(String title, IconData icon, Color iconColor, String route) {
    iconColor = _isHovered[title] == true ? Colors.blue : Colors.black87;
    title == 'Return'? _isHovered[title] = false :  _isHovered[title] = false;
    title == 'Return'? iconColor = Colors.white : Colors.black;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered[title] = true),
      onExit: (_) => setState(() => _isHovered[title] = false),
      child: GestureDetector(
        onTap: () {
          context.go(route);
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 5,right: 20),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: _isHovered[title]! ? Colors.black12 : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.only(left: 5,top: 5),
            child: Row(
              children: [
                Icon(icon, color: iconColor),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: TextStyle(
                    color: iconColor,
                    fontSize: 16,
                    decoration: TextDecoration.none, // Remove underline
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }



  Future<Uint8List> fetchImageFromApi(String imageId) async {
    final url = 'https://tn4l1nop44.execute-api.ap-south-1.amazonaws.com/stage1/api/v1_aws_s3_bucket/view/${imageId}';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      print('Image fetched: $imageId'); // Print image id
      print('Image size: ${response.bodyBytes.length * 0.001} bytes');


      return response.bodyBytes; // Return the image data as Uint8List

    } else {
      throw Exception('Failed to load image');
    }
  }


  Future<List<Product>> fetchAllProducts() async {
    final response = await http.get(
      Uri.parse('$apicall/productmaster/get_all_productmaster'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      List<Product> products = (jsonDecode(response.body) as List)
          .map((jsonProduct) => Product.fromJson(jsonProduct))
          .toList();
      return products;
    } else {
      throw Exception('Failed to load products');
    }
  }

  Future<void> printImageId() async {
    List<Product> allProducts = await fetchAllProducts();

    Order selectedOrder = _orders.firstWhere((order) => order.productName == _selectedProduct);

    Product matchingProduct = allProducts.firstWhere((product) => product.productName == selectedOrder.productName);


    setState(() {
      imageId = matchingProduct.imageId;
    });
    if (matchingProduct!= null) {
      print('Image ID: ${matchingProduct.imageId}');

    } else {
      print('No matching product found');
    }
  }

  // Future<void> filePicker() async {
  //   final result = await FilePicker.platform.pickFiles(type: FileType.image);
  //
  //   if (result == null) {
  //     // User canceled the picker
  //     return;
  //   } else {
  //     setState(() {
  //       selectedImages.clear(); // Clear previous selections
  //     });
  //
  //     //List<Uint8List> imagesToUpload = [];
  //
  //     for (var element in result.files) {
  //       // Check if the file size exceeds 1MB (1MB = 1024 * 1024 bytes)
  //       if (element.size > 1024 * 1024) {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           SnackBar(
  //             content: Text('File size exceeds 1MB. Please choose a smaller file.'),
  //           ),
  //         );
  //         return; // Exit the function if the file size is too large
  //       }
  //
  //     //  imagesToUpload.add(element.bytes!);
  //     }
  //
  //     setState(() {
  //       selectedImages = imagesToUpload;
  //       imageIdController.text = result.files.first.name;
  //       storeImage = result.files.first.name;
  //     });
  //
  //     await uploadImage(result.files.first.name); // Upload the valid image
  //   }
  // }

  Future<void> uploadImage(String name) async {
    String url =
        'https://tn4l1nop44.execute-api.ap-south-1.amazonaws.com/stage1/api/v1_aws_s3_bucket/upload';
    try {
      // Prepare the multipart request
      var request = http.MultipartRequest('POST', Uri.parse(url));

      // Find the selected image by its name (assuming one image is selected)
      final image = selectedImages.isNotEmpty ? selectedImages[0] : null;

      if (image != null) {
        // Add the file to the request
        request.files.add(http.MultipartFile.fromBytes(
          'file',
          image,
          filename: name,
        ));

        // Send the request
        var streamedResponse = await request.send();
        // Get the response
        var response = await http.Response.fromStream(streamedResponse);

        // Check if the request was successful
        if (response.statusCode == 200) {
          print('Image uploaded successfully!');
          print(response.body);
        } else {
          print('Failed to upload image. Status code: ${response.statusCode}');
        }
      } else {
        print('No file selected');
      }
    } catch (e) {
      print('Error uploading image: $e');
    }
  }
  //
  Future<void> filePicker() async {
    result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result == null) {
      return;
    } else {
      setState(() {
        selectedImages.clear(); // Clear previous selections
      });
      for (var element in result!.files) {
        if(element.size > 1024 * 1024){
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('File size exceeds 1MB. Please choose a smaller file.'),
            ),
          );
          return;
        }
        setState(() async {
          String imageSizeName = element.name;
          //imageIdController.text = element.name;
          print(widget.storeImages); //this one
          // Calculate image size in KB or MB
          int imageSizeInBytes = element.bytes!.length;
          double imageSizeInKB = imageSizeInBytes / 1024;
          double imageSizeInMB = imageSizeInKB / 1024;


          if (imageSizeInMB > 1) {
            imageSizeString = '${imageSizeInMB.toStringAsFixed(2)} MB';
          } else {
            imageSizeString = '${imageSizeInKB.toStringAsFixed(2)} KB';
          }


          print('Image size: $imageSizeString');


          //imageIdController.text = element.name;
          // imagenameController.text = element.name;
          print('name');
          print(imageIdController.text);
          // imageNameList.add(imageIdController.text);

          //print(imageNameList);

          // if (widget.imageSizeString == null && widget.imageSizeString.isNotEmpty) {
          //   widget.imageSizeString.add();
          // } else {
          //   imageNameList.add(element.name);
          // }
          if (widget.imageSizeString != null && widget.imageSizeString.isNotEmpty) {
            widget.imageSizeString.add(imageSizeName);

          } else {
            widget.imageSizeString = [imageSizeName];
          }

          print('image Name: $imageSizeName');

          if (widget.imageSizeStrings != null && widget.imageSizeStrings.isNotEmpty) {
            widget.imageSizeStrings.add(imageSizeString);

          } else {
            widget.imageSizeStrings = [imageSizeString];
          }
          print('image size');
          print(widget.imageSizeStrings);

          // Post api call.
         await  uploadImage(element.name); // Pass image bytes to uploadImage
          selectedImages.add(element.bytes!);
        });
      }
    }
  }
  //
  // Future<void> uploadImage(String name) async {
  //   String url =
  //       'https://tn4l1nop44.execute-api.ap-south-1.amazonaws.com/stage1/api/v1_aws_s3_bucket/upload';
  //   try {
  //     if (result != null) {
  //       for (var element in result!.files) {
  //         // Prepare the multipart request
  //         var request = http.MultipartRequest('POST', Uri.parse(url));
  //
  //         // Add the file to the request
  //         request.files.add(http.MultipartFile.fromBytes(
  //           'file',
  //           element.bytes!,
  //           filename: element.name,
  //         ));
  //
  //         // Send the request
  //         var streamedResponse = await request.send();
  //         // Get the response
  //         var response = await http.Response.fromStream(streamedResponse);
  //
  //         // Check if the request was successful
  //         if (response.statusCode == 200) {
  //           print('Image uploaded successfully!');
  //           print(response.body);
  //         } else {
  //           print(
  //               'Failed to upload image. Status code: ${response.statusCode}');
  //         }
  //       }
  //     } else {
  //       print('No file selected');
  //     }
  //   } catch (e) {
  //     print('Error uploading image: $e');
  //   }
  // }



//this is duplicate
//   Future<void> filePicker() async {
//     result = await FilePicker.platform.pickFiles(type: FileType.image);
//     if (result == null) {
//     } else {
//       setState(() {
//         selectedImages.clear(); // Clear previous selections
//       });
//       for (var element in result!.files) {
//         setState(() {
//           String imageSizeName = element.name;
//           print(widget.storeImages); //this one
//           // Calculate image size in KB or MB
//           int imageSizeInBytes = element.bytes!.length;
//           double imageSizeInKB = imageSizeInBytes / 1024;
//           double imageSizeInMB = imageSizeInKB / 1024;
//
//
//           if (imageSizeInMB > 1) {
//             imageSizeString = '${imageSizeInMB.toStringAsFixed(2)} MB';
//           } else {
//             imageSizeString = '${imageSizeInKB.toStringAsFixed(2)} KB';
//           }
//
//           print('Image size: $imageSizeString');
//           imagenameController.text = element.name;
//           print('name');
//           print(imagenameController.text);
//
//
//                 if (widget.imageSizeString != null && widget.imageSizeString.isNotEmpty) {
//                   widget.imageSizeString.add(imageSizeName);
//
//                 } else {
//                   widget.imageSizeString = [imageSizeName];
//                 }
//
//           if (widget.imageSizeStrings != null && widget.imageSizeStrings.isNotEmpty) {
//             widget.imageSizeStrings.add(imageSizeString);
//
//           } else {
//             widget.imageSizeStrings = [imageSizeString];
//           }
//           print('image size');
//           print(widget.imageSizeStrings);
//
//           // Post api call.
//           uploadImage(element.name); // Pass image bytes to uploadImage
//           selectedImages.add(element.bytes!);
//         });
//       }
//     }
//   }
//
//   Future<void> uploadImage(String name) async {
//     String url =
//         'https://tn4l1nop44.execute-api.ap-south-1.amazonaws.com/stage1/api/v1_aws_s3_bucket/upload';
//     try {
//       if (result != null) {
//         for (var element in result!.files) {
//           // Prepare the multipart request
//           var request = http.MultipartRequest('POST', Uri.parse(url));
//
//           // Add the file to the request
//           request.files.add(http.MultipartFile.fromBytes(
//             'file',
//             element.bytes!,
//             filename: element.name,
//           ));
//
//           // Send the request
//           var streamedResponse = await request.send();
//           // Get the response
//           var response = await http.Response.fromStream(streamedResponse);
//
//           // Check if the request was successful
//           if (response.statusCode == 200) {
//             print('Image uploaded successfully!');
//             print(response.body);
//           } else {
//             print(
//                 'Failed to upload image. Status code: ${response.statusCode}');
//           }
//         }
//       } else {
//         print('No file selected');
//       }
//     } catch (e) {
//       print('Error uploading image: $e');
//     }
//   }

  @override
  void initState() {
    super.initState();
    print('return image fi');
    print(widget.storeImages);
    print(widget.imageSizeString);
    print(widget.imageSizeStrings);
    print(widget.orderDetails);

    print(widget.orderDetailsMap['reason']);
    //print(widget.orderDetails['productName']);
    print(widget.orderDetailsMap['totalAmount2']);

    if (widget.orderDetails != null) {
      _orders = widget.orderDetails!.map((item) => Order.fromJson(item)).toList();
    } else {
      _orders = []; // or you can initialize it with an empty list
    }
  }
  // @override
  // void initState() {
  //   //// TODO: implement initState
  //   super.initState();
  //   print('return image fi');
  //   print(widget.storeImages);
  //   print(widget.imageSizeString);
  //   print(widget.imageSizeStrings);
  //   print(widget.orderDetails);
  //   print(widget.orderDetailsMap['reason']);
  //   //print(widget.orderDetails['productName']);
  //   print(widget.orderDetailsMap['totalAmount2']);
  //
  //   _orders = widget.orderDetails.map((item) => Order.fromJson(item)).toList();
  // }


  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size.width;
    return Scaffold(
        backgroundColor: Color(0xFFF0F4F8),
        appBar:
        AppBar(
          automaticallyImplyLeading: false,
          leading: null,
          backgroundColor: const Color(0xFFFFFFFF),
          title: Image.asset("images/Final-Ikyam-Logo.png"),
          // Set background color to white
          elevation: 2.0,
          shadowColor: const Color(0xFFFFFFFF),
          // Set shadow color to black
          actions: [
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  icon: const Icon(Icons.notifications),
                  onPressed: () {
                    // Handle notification icon press
                  },
                ),
              ),
            ),
            const SizedBox(width: 10,),
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child:
              AccountMenu(),
            ),
          ],
        ),
        body: LayoutBuilder(
            builder: (context, constraints){
            return Stack(
                children: [
                  if(constraints.maxHeight <= 500)...{
                    SingleChildScrollView(
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Container(
                          width: 200,
                          color: const Color(0xFFF7F6FA),
                          padding: const EdgeInsets.only(left: 15, top: 10,right: 15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: _buildMenuItems(context),
                          ),
                        ),
                      ),
                    )

                  }
                  else...{
                    Align(
                      alignment: Alignment.topLeft,
                      child: Container(
                        width: 200,
                        color: const Color(0xFFF7F6FA),
                        padding: const EdgeInsets.only(left: 15, top: 10,right: 15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: _buildMenuItems(context),
                        ),
                      ),
                    ),
                  },
                  Padding(
                    padding: const EdgeInsets.only(left: 200,top: 0),
                    child: Container(
                      width: 1, // Set the width to 1 for a vertical line
                      height: 900, // Set the height to your liking
                      decoration: BoxDecoration(
                        border: Border(left: BorderSide(width: 1, color: Colors.grey)),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 201),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        color: Colors.white,
                        height: 50,
                        child: Row(
                          children: [
                            IconButton(
                              icon:
                              const Icon(Icons.arrow_back), // Back button icon
                              onPressed: () {
                                context.go('/Create_return_back',
                                    extra: {
                                      'storeImage': 'hi',
                                      'imageSizeString': widget.imageSizeString,
                                      'imageSizeStrings': widget.imageSizeStrings,
                                      'storeImages': widget.storeImages,
                                      'orderDetails': widget.orderDetails,
                                      'orderDetailsMap': widget.orderDetailsMap,
                                    }
                                );
                                // context.go('/Arrow_back/Create_return',
                                //     extra: {
                                //       'storeImage': 'hi',
                                //       'imageSizeString': widget.imageSizeString,
                                //       'imageSizeStrings': widget.imageSizeStrings,
                                //       'storeImages': widget.storeImages,
                                //       'orderDetails': widget.orderDetails,
                                //       'orderDetailsMap': widget.orderDetailsMap,
                                //     }
                                // );
                                // Navigator.push(
                                //   context,
                                //   PageRouteBuilder(
                                //     pageBuilder: (context, animation,
                                //         secondaryAnimation) =>
                                //         CreateReturn(orderDetailsMap: const {}, storeImage: '', imageSizeStrings: const [], storeImages: const [], orderDetails: const [],imageSizeString: '',),
                                //     transitionDuration:
                                //     const Duration(milliseconds: 200),
                                //     transitionsBuilder: (context, animation,
                                //         secondaryAnimation, child) {
                                //       return FadeTransition(
                                //         opacity: animation,
                                //         child: child,
                                //       );
                                //     },
                                //   ),
                                // );

                              },
                            ),
                            const Padding(
                              padding: EdgeInsets.only(left: 30),
                              child: Text(
                                'Order Return',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const Spacer(),
                            Align(
                              alignment: Alignment.topRight,
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    top: 12, right: 130),
                                child: OutlinedButton(
                                  onPressed: () {
                                    if(_selectedProduct == null || _selectedProduct!.isEmpty ){
                                      ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text("Please Select Product")));
                                    }else if(imageSizeString.isNotEmpty && _selectedProduct!.isEmpty){
                                      ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text("Please Select Product")));
                                    }else if(imageSizeString.isEmpty && _selectedProduct!.isNotEmpty){
                                      ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text("Please Select Image")));
                                    }
                                    else if(imageSizeString.isNotEmpty && _selectedProduct!.isNotEmpty){
                                      print('---test');
                                      //  print(storeImage);
                                      print('dddd');
                                      print(widget.orderDetailsMap);
                                      // List<String> tempStoreImages = [...widget.storeImages];
                                      // widget.storeImages = _selectedProduct as List<String>;
                                      //  widget.storeImages.add(_selectedProduct as String);
                                      widget.storeImages = [...widget.storeImages, _selectedProduct as String];
                                      print(widget.storeImages);
                                      print(_selectedProduct);
                                      print(widget.imageSizeStrings);
                                      // print(imageIdController);

                                      // context.go(
                                      //   '/Add_Image/Create_return',
                                      //   extra: {
                                      //     'storeImage': 'hi',
                                      //     'imageSizeString': widget.imageSizeString,
                                      //     'imageSizeStrings': widget.imageSizeStrings,
                                      //     'storeImages': widget.storeImages,
                                      //     'orderDetails': widget.orderDetails,
                                      //     'orderDetailsMap': widget.orderDetailsMap,
                                      //   }
                                      // );
                                      context.go(
                                          '/Create_return_image',
                                          extra: {
                                            'storeImage': 'hi',
                                            'imageSizeString': widget.imageSizeString,
                                            'imageSizeStrings': widget.imageSizeStrings,
                                            'storeImages': widget.storeImages,
                                            'orderDetails': widget.orderDetails,
                                            'orderDetailsMap': widget.orderDetailsMap,
                                          }
                                      );

                                      // Navigator.push(
                                      //   context,
                                      //   PageRouteBuilder(
                                      //     pageBuilder: (context, animation,
                                      //         secondaryAnimation) =>
                                      //         CreateReturn(
                                      //           storeImage: 'hi',
                                      //           imageSizeString: widget.imageSizeString,
                                      //           imageSizeStrings: widget.imageSizeStrings,
                                      //           storeImages: widget.storeImages,
                                      //           orderDetails: widget.orderDetails,
                                      //           orderDetailsMap: widget.orderDetailsMap,),
                                      //     transitionDuration:
                                      //     const Duration(milliseconds: 200),
                                      //     transitionsBuilder: (context, animation,
                                      //         secondaryAnimation, child) {
                                      //       return FadeTransition(
                                      //         opacity: animation,
                                      //         child: child,
                                      //       );
                                      //     },
                                      //   ),
                                      // );
                                    }
                                    else{
                                      ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text("Please Pick Image")));
                                    }
                                    // if(imageSizeString.isNotEmpty && _selectedProduct!.isNotEmpty){
                                    //   print('---test');
                                    //   //  print(storeImage);
                                    //   print('dddd');
                                    //   print(widget.orderDetailsMap);
                                    //  // List<String> tempStoreImages = [...widget.storeImages];
                                    //   // widget.storeImages = _selectedProduct as List<String>;
                                    // //  widget.storeImages.add(_selectedProduct as String);
                                    //   widget.storeImages = [...widget.storeImages, _selectedProduct as String];
                                    //   print(widget.storeImages);
                                    //   print(_selectedProduct);
                                    //   print(widget.imageSizeStrings);
                                    //   // print(imageIdController);
                                    //
                                    //   // context.go(
                                    //   //   '/Add_Image/Create_return',
                                    //   //   extra: {
                                    //   //     'storeImage': 'hi',
                                    //   //     'imageSizeString': widget.imageSizeString,
                                    //   //     'imageSizeStrings': widget.imageSizeStrings,
                                    //   //     'storeImages': widget.storeImages,
                                    //   //     'orderDetails': widget.orderDetails,
                                    //   //     'orderDetailsMap': widget.orderDetailsMap,
                                    //   //   }
                                    //   // );
                                    //   context.go(
                                    //       '/Create_return_image',
                                    //       extra: {
                                    //         'storeImage': 'hi',
                                    //         'imageSizeString': widget.imageSizeString,
                                    //         'imageSizeStrings': widget.imageSizeStrings,
                                    //         'storeImages': widget.storeImages,
                                    //         'orderDetails': widget.orderDetails,
                                    //         'orderDetailsMap': widget.orderDetailsMap,
                                    //       }
                                    //   );
                                    //
                                    //   // Navigator.push(
                                    //   //   context,
                                    //   //   PageRouteBuilder(
                                    //   //     pageBuilder: (context, animation,
                                    //   //         secondaryAnimation) =>
                                    //   //         CreateReturn(
                                    //   //           storeImage: 'hi',
                                    //   //           imageSizeString: widget.imageSizeString,
                                    //   //           imageSizeStrings: widget.imageSizeStrings,
                                    //   //           storeImages: widget.storeImages,
                                    //   //           orderDetails: widget.orderDetails,
                                    //   //           orderDetailsMap: widget.orderDetailsMap,),
                                    //   //     transitionDuration:
                                    //   //     const Duration(milliseconds: 200),
                                    //   //     transitionsBuilder: (context, animation,
                                    //   //         secondaryAnimation, child) {
                                    //   //       return FadeTransition(
                                    //   //         opacity: animation,
                                    //   //         child: child,
                                    //   //       );
                                    //   //     },
                                    //   //   ),
                                    //   // );
                                    // }else if(_selectedProduct == null || _selectedProduct!.isEmpty ){
                                    //   ScaffoldMessenger.of(context).showSnackBar(
                                    //       const SnackBar(content: Text("Please Select Product")));
                                    // }
                                    // else{
                                    //   ScaffoldMessenger.of(context).showSnackBar(
                                    //       const SnackBar(content: Text("Please Pick Image")));
                                    // }

                                  },
                                  style: OutlinedButton.styleFrom(
                                    backgroundColor:
                                    Colors.blue[800],
                                    // Button background color
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                      BorderRadius.circular(
                                          5), // Rounded corners
                                    ),
                                    side: BorderSide.none, // No outline
                                  ),
                                  child: const Text(
                                    'Save',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w100,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 50 ,left: 200),
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                          vertical: 1),
                      // Space above/below the border
                      height: 0.3, // Border height
                      color: Colors.black, // Border color
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      print('---imagePath---');
                      filePicker();
                    },
                    child: Padding(
                      padding:  EdgeInsets.only(left: size* 0.35,top: size * 0.075,bottom: size * 0.1,right:
                      size *0.3),
                      child: Card(
                        //margin: EdgeInsets.only(left: maxWidth * 0.08, top: maxHeight * 0.27,bottom: maxHeight * 0.3),
                        child: Container(
                          width:size,
                          height: 500,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              //in this place u need to show in the ui
                              if (selectedImages.isNotEmpty)
                                for (var imageBytes in selectedImages)
                                  Expanded(
                                    child: Image.memory(
                                      imageBytes,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                              Icon(Icons.cloud_upload_outlined,
                                  color: Colors.blue[900], size: 50),
                              const SizedBox(height: 8),
                              const Text(
                                'Click to upload image',
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'PNG, JPG or GIF Recommended size below 1MB',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  //SizedBox(height: 60,),
                  Padding(
                      padding: EdgeInsets.only(top: 500, left: size * 0.34, right: size * 0.3),
                      child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (widget.orderDetails != null)
                                const SizedBox(height: 40,),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Select Product'),
                                  const SizedBox(height: 10,),
                                  SizedBox(
                                    height: 40,
                                    width: size,
                                    child: DropdownButtonFormField(
                                      decoration: InputDecoration(
                                        filled: true,
                                        fillColor: Colors.white,
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(2.0),
                                          borderSide: const BorderSide(color: Colors.blue), // Set border color here
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(5.0),
                                          borderSide: const BorderSide(color: Colors.blue), // Set focused border color here
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(5.0),
                                          borderSide: const BorderSide(color: Colors.blue), // Set enabled border color here
                                        ),
                                        hintText: 'Select Product Name',
                                        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                                        suffixIcon: const Icon(Icons.arrow_drop_down_circle_rounded, color: Colors.blueAccent,), // Add arrow down icon here
                                      ),
                                      icon: Container(),
                                      value: _selectedProduct,

                                      onChanged: (newValue) {
                                        setState(() {
                                          _selectedProduct = newValue as String;
                                          // widget.storeImages = [_selectedProduct as String];
                                          // widget.storeImages.add(_selectedProduct as String);
                                          if (_selectedProduct != null) {
                                            //printImageId(); // Call the printImageId function
                                          }
                                        });
                                      },
                                      items: widget.orderDetails!.map((item) {
                                        String productName = item['productName'];
                                        String category = item['category'];
                                        String uniqueProduct = '$productName-$category';
                                        return DropdownMenuItem(
                                          value: uniqueProduct,
                                          child: Text(productName),
                                        );
                                      }).toList(),
                                      isExpanded: true,
                                    ),
                                  )
                                ],
                              )
                            ],
                          )
                      )
                  )
                  // Padding(
                  //     padding:  EdgeInsets.only(top: 500,left: size * 0.34,right: size*0.3),
                  //     child: Padding(
                  //         padding: const EdgeInsets.all(16.0),
                  //         child: Column(
                  //           mainAxisAlignment: MainAxisAlignment.center,
                  //           children: [
                  //             if(widget.orderDetails != null)
                  //             const SizedBox(height: 40,),
                  //             Column(
                  //               crossAxisAlignment: CrossAxisAlignment.start,
                  //               children: [
                  //                 const Text('Select Product'),
                  //                 const SizedBox(height: 10,),
                  //                 SizedBox(height: 40,
                  //                   width: size,
                  //                   child:DropdownButtonFormField(
                  //                     decoration: InputDecoration(
                  //                       filled: true,
                  //                       fillColor: Colors.white,
                  //                       border: OutlineInputBorder(
                  //                         borderRadius: BorderRadius.circular(2.0),
                  //                         borderSide: const BorderSide(color: Colors.blue), // Set border color here
                  //                       ),
                  //                       focusedBorder: OutlineInputBorder(
                  //                         borderRadius: BorderRadius.circular(5.0),
                  //                         borderSide: const BorderSide(color: Colors.blue), // Set focused border color here
                  //                       ),
                  //                       enabledBorder: OutlineInputBorder(
                  //                         borderRadius: BorderRadius.circular(5.0),
                  //                         borderSide: const BorderSide(color: Colors.blue), // Set enabled border color here
                  //                       ),
                  //                       hintText: 'Select Product Name',
                  //                       contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                  //                       suffixIcon: const Icon(Icons.arrow_drop_down_circle_rounded,color: Colors.blueAccent,), // Add arrow down icon here
                  //                     ),
                  //                     icon: Container(),
                  //                     value: _selectedProduct,
                  //
                  //                     onChanged: (newValue) {
                  //                       setState(() {
                  //                         _selectedProduct = newValue as String;
                  //                         // widget.storeImages = [_selectedProduct as String];
                  //                         // widget.storeImages.add(_selectedProduct as String);
                  //                         if (_selectedProduct != null) {
                  //                           //printImageId(); // Call the printImageId function
                  //                         }
                  //                       });
                  //                     },
                  //                     items: widget.orderDetails!.map((item) {
                  //                       return DropdownMenuItem(
                  //                         value: item['productName'],
                  //                         child: Text(item['productName'] ?? 'Unknown Product'),
                  //                       );
                  //                     }).toList(),
                  //                     isExpanded: true,
                  //                   ),
                  //                 )
                  //               ],
                  //             )
                  //           ],
                  //         )
                  //     )
                  // )
                ]
            );
          }
        )
    );
  }
}

