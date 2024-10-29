import 'dart:convert';
import 'dart:html';
import 'dart:io' as io;
import 'package:btb/admin/Api%20name.dart';
import 'package:btb/widgets/confirmdialog.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;




class SecondPage extends StatefulWidget {
  const SecondPage({super.key,});


  @override
  State<SecondPage> createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage> {
  String? pickedImagePath;
  String token = window.sessionStorage["token"] ?? " ";
  String? imagePath;
  io.File? selectedImage;
  bool _hasShownPopup = false;
  bool isOrdersSelected = false;
  String? errorMessage;
  bool purchaseOrderError = false;
  final TextEditingController priceController = TextEditingController();
  final TextEditingController discountController = TextEditingController();
  final TextEditingController imageIdController = TextEditingController();
  final List<String> list = ['Select', 'Select 1', 'Select 2', 'Select 3'];
  String dropdownValue = 'Select';
  final List<String> list1 = ['Select', '12%', '18%', '28%', '10%'];
  String? selectedDropdownItem;
  String dropdownValue1 = 'Select';
  String imageName = '';
  List<Uint8List> selectedImages = [];
  String storeImage = '';
  final List<String> list2 = ['Select', 'PCS', 'NOS', 'PKT'];
  String dropdownValue2 = 'Select';
  final List<String> list3 = ['Select', 'Yes', 'No'];
  String dropdownValue3 = 'Select';
  final _validate = GlobalKey<FormState>();
  var result;
  final TextEditingController productNameController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();
  final TextEditingController subCategoryController = TextEditingController();
  final TextEditingController taxController = TextEditingController();
  final TextEditingController unitController = TextEditingController();
  bool isHomeSelected = false;
  final _formKey = GlobalKey<FormState>();

  // Function to check if all required fields are filled
  bool areRequiredFieldsFilled() {
    return productNameController.text.isNotEmpty &&
        dropdownValue != 'Select' &&
        // dropdownValue3 != 'Select' &&
        dropdownValue1 != 'Select' &&
        dropdownValue2 != 'Select' &&
        dropdownValue3 != 'Select' &&
        priceController.text.isNotEmpty &&
        discountController.text.isNotEmpty &&
        selectedImages.isNotEmpty;
  }
  Future<void> filePicker() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);

    if (result == null) {
      // User canceled the picker
      return;
    } else {
      setState(() {
        selectedImages.clear(); // Clear previous selections
      });

      for (var element in result.files) {
        // Check if the file size exceeds 1MB (1MB = 1024 * 1024 bytes)
        if (element.size > 1024 * 1024) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('File size exceeds 1MB. Please choose a smaller file.'),
            ),
          );
          return; // Exit the function if the file size is too large
        }

        setState(() {
          imageIdController.text = element.name;
          storeImage = element.name;
          selectedImages.add(element.bytes!); // Add valid image to UI
        });

        await uploadImage(element.name); // Upload the valid image
      }
    }
  }

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


  Future<void> addProductMaster() async {
    List<String> errors = [];

    final productMasterData = {
      "productName": productNameController.text,
      "category": dropdownValue,
      "subCategory": dropdownValue3,
      "tax": dropdownValue1,
      "unit": dropdownValue2,
      "price": double.parse(priceController.text),
      "discount": discountController.text,
      "imageId": storeImage,
    };

    try {
      final getAllResponse = await http.get(
          Uri.parse(
              '$apicall/productmaster/get_all_productmaster'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json'
          });

      if (getAllResponse.statusCode == 200) {
        final jsonData = jsonDecode(getAllResponse.body);
        final productMasters = jsonData;

        bool isProductMasterExists = false;

        for (var productMaster in productMasters) {
          if (productMaster['productName'] == productNameController.text &&
              productMaster['category'] == dropdownValue &&
              productMaster['subCategory'] == dropdownValue3) {
            isProductMasterExists = true;
            break;
          }
        }

        if (isProductMasterExists) {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                icon: Icon(Icons.warning_sharp, color: Colors.red, size: 25,),
                content: Text('A product with the same details already exists.'),
                actions: <Widget>[
                  TextButton(
                    child: Text('OK'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
        } else {
          final addApiUrl = '$apicall/productmaster/add_productmaster';

          final addResponse = await http.post(Uri.parse(addApiUrl),
              headers: {
                'Authorization': 'Bearer $token',
                'Content-Type': 'application/json'
              },
              body: jsonEncode(productMasterData));

          final addResponseBody = jsonDecode(addResponse.body);

          if (addResponse.statusCode == 200 && addResponseBody['status'] == 'success') {
            print('Product added successfully');
            showDialog(
              barrierDismissible: false,
              context: context,
              builder: (BuildContext context) {
                return  AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  contentPadding: EdgeInsets.zero,
                  content:
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Close Button
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
                                    context.go('/Product_List');
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
                //   AlertDialog(
                //   shape: const RoundedRectangleBorder(
                //       borderRadius: BorderRadius.all(Radius.circular(5))),
                //   icon: const Icon(
                //     Icons.check_circle_rounded,
                //     color: Colors.green,
                //     size: 25,
                //   ),
                //   title: const Text("Success"),
                //   content:
                //   Column(
                //     mainAxisSize: MainAxisSize.min,
                //     children: [
                //       // Close Button
                //       Align(
                //         alignment: Alignment.topRight,
                //         child: IconButton(
                //           icon: Icon(Icons.close, color: Colors.red),
                //           onPressed: () {
                //             Navigator.of(context).pop();
                //           },
                //         ),
                //       ),
                //       Padding(
                //         padding: const EdgeInsets.all(16.0),
                //         child: Column(
                //           children: [
                //             // Warning Icon
                //             Icon(Icons.warning, color: Colors.orange, size: 50),
                //             SizedBox(height: 16),
                //             // Confirmation Message
                //             Text(
                //               'Are You Sure',
                //               style: TextStyle(
                //                 fontSize: 18,
                //                 fontWeight: FontWeight.bold,
                //                 color: Colors.black,
                //               ),
                //             ),
                //             SizedBox(height: 20),
                //             // Buttons
                //             Row(
                //               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                //               children: [
                //                 ElevatedButton(
                //                   onPressed: () {
                //                     // Handle Yes action
                //                     context.go('/',extra: {
                //                       'cameFromRoute': true,
                //                     });
                //                     //  Navigator.push(
                //                     //    context,
                //                     //    PageRouteBuilder(
                //                     //      pageBuilder: (context, animation,
                //                     //          secondaryAnimation) =>
                //                     //          LoginScr(),
                //                     //      transitionDuration:
                //                     //      const Duration(milliseconds: 5),
                //                     //      transitionsBuilder: (context, animation,
                //                     //          secondaryAnimation, child) {
                //                     //        return FadeTransition(
                //                     //          opacity: animation,
                //                     //          child: child,
                //                     //        );
                //                     //      },
                //                     //    ),
                //                     //  );
                //                     // Navigator.of(context).pop();
                //                   },
                //                   style: ElevatedButton.styleFrom(
                //                     backgroundColor: Colors.white,
                //                     side: BorderSide(color: Colors.blue),
                //                     shape: RoundedRectangleBorder(
                //                       borderRadius: BorderRadius.circular(10.0),
                //                     ),
                //                   ),
                //                   child: Text(
                //                     'Yes',
                //                     style: TextStyle(
                //                       color: Colors.blue,
                //                     ),
                //                   ),
                //                 ),
                //                 ElevatedButton(
                //                   onPressed: () {
                //                     // Handle No action
                //                     Navigator.of(context).pop();
                //                   },
                //                   style: ElevatedButton.styleFrom(
                //                     backgroundColor: Colors.white,
                //                     side: BorderSide(color: Colors.red),
                //                     shape: RoundedRectangleBorder(
                //                       borderRadius: BorderRadius.circular(10.0),
                //                     ),
                //                   ),
                //                   child: Text(
                //                     'No',
                //                     style: TextStyle(
                //                       color: Colors.red,
                //                     ),
                //                   ),
                //                 ),
                //               ],
                //             ),
                //           ],
                //         ),
                //       ),
                //     ],
                //   ),
                //   // const Padding(
                //   //   padding: EdgeInsets.only(left: 26),
                //   //   child: Text("Product added successfully"),
                //   // ),
                //   // Row(
                //   //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                //   //   children: [
                //   //     ElevatedButton(
                //   //       onPressed: () {
                //   //         // Handle Yes action
                //   //         context.go('/',extra: {
                //   //           'cameFromRoute': true,
                //   //         });
                //   //         //  Navigator.push(
                //   //         //    context,
                //   //         //    PageRouteBuilder(
                //   //         //      pageBuilder: (context, animation,
                //   //         //          secondaryAnimation) =>
                //   //         //          LoginScr(),
                //   //         //      transitionDuration:
                //   //         //      const Duration(milliseconds: 5),
                //   //         //      transitionsBuilder: (context, animation,
                //   //         //          secondaryAnimation, child) {
                //   //         //        return FadeTransition(
                //   //         //          opacity: animation,
                //   //         //          child: child,
                //   //         //        );
                //   //         //      },
                //   //         //    ),
                //   //         //  );
                //   //         // Navigator.of(context).pop();
                //   //       },
                //   //       style: ElevatedButton.styleFrom(
                //   //         backgroundColor: Colors.white,
                //   //         side: BorderSide(color: Colors.blue),
                //   //         shape: RoundedRectangleBorder(
                //   //           borderRadius: BorderRadius.circular(10.0),
                //   //         ),
                //   //       ),
                //   //       child: Text(
                //   //         'Yes',
                //   //         style: TextStyle(
                //   //           color: Colors.blue,
                //   //         ),
                //   //       ),
                //   //     ),
                //   //     ElevatedButton(
                //   //       onPressed: () {
                //   //         // Handle No action
                //   //         Navigator.of(context).pop();
                //   //       },
                //   //       style: ElevatedButton.styleFrom(
                //   //         backgroundColor: Colors.white,
                //   //         side: BorderSide(color: Colors.red),
                //   //         shape: RoundedRectangleBorder(
                //   //           borderRadius: BorderRadius.circular(10.0),
                //   //         ),
                //   //       ),
                //   //       child: Text(
                //   //         'No',
                //   //         style: TextStyle(
                //   //           color: Colors.red,
                //   //         ),
                //   //       ),
                //   //     ),
                //   //   ],
                //   // ),
                //   // actions: [
                //   //   TextButton(
                //   //     child: const Text("OK"),
                //   //     onPressed: () {
                //   //       Navigator.of(context).pop();
                //   //       context.go('Product_List');
                //   //     },
                //   //   ),
                //   // ],
                // );
              },
            );
          }
          else if (addResponseBody['status'] == 'product already exists') {
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  icon: Icon(Icons.warning_sharp, color: Colors.red, size: 25,),
                  content: Text('Product already exists.'),
                  actions: <Widget>[
                    TextButton(
                      child: Text('OK'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              },
            );
          } else {
            print('Error adding product master: ${addResponse.statusCode}');
          }
        }
      } else {
        print('Failed to load product masters');
      }
    } catch (e) {
      print('Error: $e');
      rethrow; // rethrow the exception
    }
  }



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


  List<Widget> _buildMenuItems(BuildContext context) {
    return [
      _buildMenuItem('Home', Icons.dashboard, Colors.blue[900]!, '/Home'),
      _buildMenuItem('Customer', Icons.account_circle, Colors.blue[900]!, '/Customer'),
      Container(
          decoration: BoxDecoration(
            color: Colors.white ,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8), // Radius for top-left corner
              topRight: Radius.circular(0), // No radius for top-right corner
              bottomLeft: Radius.circular(8), // Radius for bottom-left corner
              bottomRight: Radius.circular(0), // No radius for bottom-right corner
            ),
          ),
          child: _buildMenuItem('Products', Icons.image_outlined, Colors.black, '/Product_List')),
      _buildMenuItem('Orders', Icons.warehouse, Colors.blue[900]!, '/Order_List'),
      _buildMenuItem('Invoice', Icons.document_scanner_rounded, Colors.blue[900]!, '/Invoice'),
      _buildMenuItem('Delivery', Icons.fire_truck_outlined, Colors.blue[900]!, '/Delivery_List'),
      _buildMenuItem('Payment', Icons.payment_outlined, Colors.blue[900]!, '/Payment_List'),
      _buildMenuItem('Return', Icons.backspace_sharp, Colors.blue[900]!, '/Return_List'),
      _buildMenuItem('Reports', Icons.insert_chart, Colors.blue[900]!, '/Report_List'),
    ];
  }

  Widget _buildMenuItem(String title, IconData icon, Color iconColor, String route) {
    iconColor = _isHovered[title] == true ? Colors.black87 : Colors.white;
    title == 'Products'? _isHovered[title] = false :  _isHovered[title] = false;
    title == 'Products'? iconColor = Colors.black : Colors.white;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered[title] = true),
      onExit: (_) => setState(() => _isHovered[title] = false),
      child: GestureDetector(
        onTap: () {
          context.go(route);
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: _isHovered[title]! ? Colors.white : Colors.transparent,
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


  // Future<void> addProductMaster() async {
  //   List<String> errors = [];
  //
  //   // if (productNameController.text.isEmpty) errors.add('Product name');
  //   // if (dropdownValue == 'Select') errors.add('Category');
  //   // if (dropdownValue1 == 'Select') errors.add('Sub category');
  //   // if (dropdownValue2 == 'Select') errors.add('Unit');
  //   // if (dropdownValue3 == 'Select') errors.add('Tax');
  //   // if (priceController.text.isEmpty) errors.add('Price');
  //   // if (discountController.text.isEmpty) errors.add('Discount');
  //   // if (selectedImages.isEmpty) errors.add('Image');
  //   //
  //   // if (errors.isNotEmpty) {
  //   //   _showSnackBar('Please fill in the following fields: ${errors.join(', ')}');
  //   //   return;
  //   // }
  //
  //
  //   final productMasterData = {
  //     "productName": productNameController.text,
  //     "category": dropdownValue,
  //     "subCategory": dropdownValue3,
  //     "tax": dropdownValue1,
  //     "unit": dropdownValue2,
  //     "price": double.parse(priceController.text),
  //     "discount": discountController.text,
  //     "imageId": storeImage,
  //   };
  //
  //   try {
  //     final getAllResponse = await http.get(
  //         Uri.parse(
  //         '$apicall/productmaster/get_all_productmaster'),
  //         headers: {
  //           'Authorization': 'Bearer $token',
  //           'Content-Type': 'application/json'
  //         });
  //
  //     if (getAllResponse.statusCode == 200) {
  //       final jsonData = jsonDecode(getAllResponse.body);
  //       final productMasters = jsonData;
  //
  //       bool isProductMasterExists = false;
  //
  //       for (var productMaster in productMasters) {
  //         if (productMaster['productName'] == productNameController.text &&
  //             productMaster['category'] == dropdownValue &&
  //             productMaster['subCategory'] ==  dropdownValue3
  //             // productMaster['tax'] == productMasterData['tax'] &&
  //             // productMaster['unit'] == productMasterData['unit'] &&
  //             // productMaster['price'] == productMasterData['price'].toString() &&
  //             // productMaster['discount'] == productMasterData['discount'] &&
  //             // productMaster['imageId'] == productMasterData['imageId']
  //         )
  //         {
  //           isProductMasterExists = true;
  //           break;
  //         }
  //       }
  //
  //       if (isProductMasterExists) {
  //         showDialog(
  //                context: context,
  //                builder: (context) {
  //                  return AlertDialog(
  //                    icon: Icon(Icons.warning_sharp,color: Colors.red,size: 25,),
  //                    content: Text('A product with the same details already exists.'),
  //                    actions: <Widget>[
  //                      TextButton(
  //                        child: Text('OK'),
  //                        onPressed: () {
  //                          Navigator.of(context).pop();
  //                        },
  //                      ),
  //                    ],
  //                  );
  //                },
  //              );
  //       } else {
  //         final addApiUrl = '$apicall/productmaster/add_productmaster';
  //
  //         final addResponse = await http.post(Uri.parse(addApiUrl),
  //             headers: {
  //               'Authorization': 'Bearer $token',
  //               'Content-Type': 'application/json'
  //             },
  //             body: jsonEncode(productMasterData));
  //
  //         if (addResponse.statusCode == 200) {
  //           print('A Product added successfully');
  //              showDialog(
  //                context: context,
  //                builder: (BuildContext context) {
  //                  return AlertDialog(
  //                    shape: const RoundedRectangleBorder(
  //                        borderRadius: BorderRadius.all(Radius.circular(5))),
  //                    icon: const Icon(
  //                      Icons.check_circle_rounded,
  //                      color: Colors.green,
  //                      size: 25,
  //                    ),
  //                    title: const Text("Success"),
  //                    content: const Padding(
  //                      padding: EdgeInsets.only(left: 26),
  //                      child: Text("Product added successfully"),
  //                    ),
  //                    actions: [
  //                      TextButton(
  //                        child: const Text("OK"),
  //                        onPressed: () {
  //                          Navigator.of(context).pop();
  //                          context.go('/Product_List');
  //                        },
  //                      ),
  //                    ],
  //                  );
  //                },
  //              );
  //         } else {
  //           print('Error adding product master: ${addResponse.statusCode}');
  //         }
  //       }
  //     } else {
  //       print('Failed to load product masters');
  //     }
  //   } catch (e) {
  //     print('Error: $e');
  //     rethrow; // rethrow the exception
  //   }
  // }





  @override
  Widget build(BuildContext context) {
    return
      Scaffold(
          backgroundColor: const Color(0xFFFFFFFF),
          appBar:
          AppBar(
            leading: null,
            automaticallyImplyLeading: false,
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
                child:  AccountMenu(),
              ),
            ],
          ),
          body:
          LayoutBuilder(
              builder: (context, constraints){
                double maxWidth = constraints.maxWidth;
                double maxHeight = constraints.maxHeight;
                return Stack(children: [

                  Align(
                    // Added Align widget for the left side menu
                    alignment: Alignment.topLeft,
                    child: Container(
                      height: 1400,
                      width: 200,
                      color: const Color(0xFF0974A1),
                      padding: const EdgeInsets.only(left: 20, top: 30),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: _buildMenuItems(context),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only( left: 190),
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 10), // Space above/below the border
                      width: 1, // Border height
                      color: Colors.grey, // Border color
                    ),
                  ),
                  Positioned(
                    top: 0,
                    left: 0,
right: 0,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 205),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        color: Colors.white,
                        height: 60,
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(
                                  Icons.arrow_back), // Back button icon
                              onPressed: () {
                                context.go(
                                    '/Product_List');
                                // Navigator.of(context).push(PageRouteBuilder(
                                //   pageBuilder: (context, animation,
                                //       secondaryAnimation) =>
                                //   const ProductPage(product: null),
                                // ));
                              },
                            ),
                            const Padding(
                              padding: EdgeInsets.only(left: 20),
                              child: Text(
                                'Add New Product',
                                style: TextStyle(
                                  fontSize: 20,
                                  // fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 43, left: 200),
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                          vertical: 10), // Space above/below the border
                      height: 1, // Border height
                      color: Colors.grey, // Border color
                    ),
                  ),
Row(
  children: [
    Padding(
      padding: const EdgeInsets.only(left: 250),
      child: GestureDetector(
        onTap: () {
          print('---imagePath---');
          // print(imagePath);
          // print(selectedImage);
          filePicker();
        },
        child: Card(
          margin: EdgeInsets.only(left: maxWidth * 0.08, top: 220,bottom: maxHeight * 0.35),

          child: Flex(
            direction: Axis.vertical, // use vertical direction
            children: [
              Flexible(
                flex: 2, // take up 3 parts of the available space
                child: Container(
                  width: maxWidth * 0.3,
                  height: maxHeight * 1.2,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    color: Colors.white70,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.1), // Soft grey shadow
                        spreadRadius: 1,
                        blurRadius: 1,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  // decoration: BoxDecoration(
                  //   color: Colors.grey[300],
                  //   borderRadius: BorderRadius.circular(4),
                  // ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (selectedImages.isNotEmpty)
                        for (var imageBytes in selectedImages)
                          Flexible(
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
            ],
          ),
        ),
      ),
    ),
    const SizedBox(
      height: 10,
    ),
    Expanded(
      child: Card(
        margin: EdgeInsets.only(left: maxWidth * 0.08, top: maxHeight * 0.2,right: maxWidth * 0.1),
        color: Colors.white,
        elevation: 0.0,
        child: Form(
          key: _validate,
          child: Flex(
            direction: Axis.vertical,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Name field
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Align(
                      alignment: const Alignment(-1.0,-0.3),
                      child: RichText(
                        text:  TextSpan(
                          children: [
                            TextSpan(
                              text: 'Product Name ',
                              style: TextStyle(
                                color: Colors.black87,
                                fontSize: 16,// Set the product name to black color
                              ),
                            ),
                            const TextSpan(
                              text: '*',
                              style: TextStyle(
                                color: Colors.red, // Set the asterisk to red color
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(2),
                        border: Border.all(color: Colors.blue[100]!),
                      ),
                      child: Align(
                        alignment: const Alignment(0.1, 0.0),
                        child: SizedBox(
                          height: 40,
                          width: constraints.maxWidth * 0.5,
                          child: Form(
                            key: _formKey,
                            child: TextFormField(
                              controller: productNameController,
                              decoration: InputDecoration(
                                fillColor: Colors.white,
                                contentPadding:
                                const EdgeInsets.symmetric(horizontal: 10, vertical: 13),
                                border: InputBorder.none,
                                filled: true,
                                hintText: 'Enter Product Name',
                                hintStyle: const TextStyle(color: Colors.grey),
                              ),
                              inputFormatters: [
                                // Allow only letters, numbers, and single space
                                FilteringTextInputFormatter.deny(
                                    RegExp(r'^\s')),
                                // Disallow starting with a space
                                FilteringTextInputFormatter.deny(
                                    RegExp(r'\s\s')),
                                // Disallow multiple spaces
                              ],
                              // No inputFormatters to allow all characters
                              validator: (value) {
                                if (value != null && value.trim().isEmpty) {
                                  return 'Please enter a product name';
                                }
                                return null;
                              },
                              // validator: (value) {
                              //   final RegExp specialCharRegExp =
                              //   RegExp(r'[!@#$%^&*(),.?":{}|<>]');
                              //   if (value != null && value.trim().isEmpty) {
                              //     return 'Please enter a product name';
                              //   } else if (value != null && specialCharRegExp.hasMatch(value)) {
                              //     WidgetsBinding.instance.addPostFrameCallback((_) {
                              //       ScaffoldMessenger.of(context).showSnackBar(
                              //         const SnackBar(
                              //           content: Text('Special characters are not allowed!'),
                              //         ),
                              //       );
                              //     });
                              //   }else{
                              //     addProductMaster();
                              //   }
                              //   return null;
                              // },
                              maxLines: 1,
                              minLines: 1,
                            )
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              // const SizedBox(height: 5),
              Row(
                children: [
                  Flexible(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Category field
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Align(
                            alignment: const  Alignment(-1.0,-0.3),
                            child: RichText(
                              text:  TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'Category ',
                                    style: TextStyle(
                                      color: Colors.black87,
                                      fontSize: 16,// Set the product name to black color
                                    ),
                                  ),
                                  const TextSpan(
                                    text: '*',
                                    style: TextStyle(
                                      color: Colors.red, // Set the asterisk to red color
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(2),
                              border: Border.all(color: Colors.blue[100]!),
                            ),
                            child: SizedBox(
                              height: 50,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                child: DropdownButton<String>(
                                  value: dropdownValue,
                                  icon:  Icon(Icons.arrow_drop_down_circle_rounded,color: Colors.blue[800],),
                                  iconSize: 18, // Size of the icon
                                  elevation: 16,
                                  style: const TextStyle(color: Colors.black),
                                  underline: Container(), // We don't need the default underline since we're using a custom border
                                  onChanged: (String? value) {
                                    setState(() {
                                      dropdownValue = value!;
                                    });
                                  },
                                  items: list.map<DropdownMenuItem<String>>((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value,style: const TextStyle(color: Colors.grey),),
                                    );
                                  }).toList(),
                                  isExpanded: true,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Flexible(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Sub Category field
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Align(
                            alignment: const Alignment(-1.0,-0.3),
                            child: RichText(
                              text:  TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'Sub Category ',
                                    style: TextStyle(
                                        color: Colors.black87,
                                        fontSize: 16// Set the product name to black color
                                    ),
                                  ),
                                  const TextSpan(
                                    text: '*',
                                    style: TextStyle(
                                      color: Colors.red, // Set the asterisk to red color
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(2),
                              border: Border.all(color:
                              Colors.blue[100]!),
                            ),
                            child: Padding(
                              padding:
                              const EdgeInsets.symmetric(
                                  horizontal: 10),
                              child: DropdownButton<String>(
                                value: dropdownValue3,
                                icon:  Icon(Icons.arrow_drop_down_circle_rounded,color: Colors.blue[800],),
                                iconSize: 18,
                                // Size of the icon
                                elevation: 16,
                                style: const TextStyle(
                                    color: Colors.black),
                                underline: Container(),
                                // We don't need the default underline since we're using a custom border
                                onChanged: (String? value) {
                                  setState(() {
                                    dropdownValue3 = value!;
                                  });
                                },
                                items: list3.map<
                                    DropdownMenuItem<
                                        String>>(
                                        (String value) {
                                      return DropdownMenuItem<
                                          String>(
                                        value: value,
                                        child: Text(value,style: const TextStyle(color: Colors.grey),),
                                      );
                                    }).toList(),
                                isExpanded: true,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Align(
                            alignment:  const Alignment(-1.0,-0.3),
                            child: RichText(
                              text:  TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'Tax ',
                                    style: TextStyle(
                                      color: Colors.black87,
                                      fontSize: 16,// Set the product name to black color
                                    ),
                                  ),
                                  const TextSpan(
                                    text: '*',
                                    style: TextStyle(
                                      color: Colors
                                          .red, // Set the asterisk to red color
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                              BorderRadius.circular(2),
                              border: Border.all(
                                  color: Colors.blue[100]!),
                            ),
                            child: SizedBox(
                              height: 50,
                              child: Padding(
                                padding:
                                const EdgeInsets.symmetric(
                                    horizontal: 10),
                                child: SizedBox(
                                  height: 40,
                                  width: constraints.maxWidth * 0.5,
                                  child: DropdownButton<String>(
                                    value: dropdownValue1,
                                    icon:   Icon(Icons.arrow_drop_down_circle_rounded,color: Colors.blue[800],),
                                    iconSize: 18,
                                    // Size of the icon
                                    elevation: 16,
                                    style: const TextStyle(
                                        color: Colors.black),
                                    underline: Container(),
                                    // We don't need the default underline since we're using a custom border
                                    onChanged: (String? value) {
                                      setState(() {
                                        dropdownValue1 = value!;
                                      });
                                    },
                                    items: list1.map<
                                        DropdownMenuItem<
                                            String>>(
                                            (String value) {
                                          return DropdownMenuItem<
                                              String>(
                                            value: value,
                                            child: Text(value,style: const TextStyle(color: Colors.grey),),
                                          );
                                        }).toList(),
                                    isExpanded: true,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Align(
                            alignment: const Alignment(-1.0,-0.3),
                            child: RichText(
                              text:  TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'Unit ',
                                    style: TextStyle(
                                      color: Colors.black87, //
                                      fontSize: 16,// Set the product name to black color
                                    ),
                                  ),
                                  const TextSpan(
                                    text: '*',
                                    style: TextStyle(
                                      color: Colors
                                          .red, // Set the asterisk to red color
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                              BorderRadius.circular(2),
                              border: Border.all(
                                  color: Colors.blue[100]!),
                            ),
                            child: SizedBox(
                              height: 50,

                              child: Padding(
                                padding:
                                const EdgeInsets.symmetric(
                                    horizontal: 10),
                                child: SizedBox(
                                  height: 40,
                                  width: constraints.maxWidth * 0.5,
                                  child: DropdownButton<String>(
                                    value: dropdownValue2,
                                    icon:   Icon(Icons.arrow_drop_down_circle_rounded,color: Colors.blue[800],),
                                    iconSize: 18,
                                    // Size of the icon
                                    elevation: 16,
                                    style: const TextStyle(
                                        color: Colors.black),
                                    underline: Container(),
                                    // We don't need the default underline since we're using a custom border
                                    onChanged: (String? value) {
                                      setState(() {
                                        dropdownValue2 = value!;
                                      });
                                    },
                                    items: list2.map<
                                        DropdownMenuItem<
                                            String>>(
                                            (String value) {
                                          return DropdownMenuItem<
                                              String>(
                                            value: value,
                                            child: Text(value,style:const TextStyle(color: Colors.grey),),
                                          );
                                        }).toList(),
                                    isExpanded: true,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Align(
                            alignment:const Alignment(-1.0,-0.3),
                            child: RichText(
                              text:  TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'Price ',
                                    style: TextStyle(
                                      color: Colors.black87,

                                      fontSize: 16,// Set the product name to black color
                                    ),
                                  ),
                                  const TextSpan(
                                    text: '*',
                                    style: TextStyle(
                                      color: Colors
                                          .red, // Set the asterisk to red color
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                              BorderRadius.circular(2),
                              border: Border.all(
                                  color: Colors.blue[100]!),
                            ),
                            child: TextFormField(
                              controller: priceController,
                              keyboardType:
                              TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter
                                    .digitsOnly,
                                LengthLimitingTextInputFormatter(
                                    10),
                                // limits to 10 digits
                              ],
                              decoration: InputDecoration(
                                fillColor: Colors.white,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 10,vertical: 13),
                                border: InputBorder.none,
                                filled: true,
                                hintText: 'Enter Price',
                                hintStyle: TextStyle(color: Colors.grey),
                                errorText: errorMessage,
                              ),
                              onChanged: (value) {
                                if (value.isNotEmpty &&
                                    !isNumeric(value)) {
                                  setState(() {
                                    errorMessage =
                                    'Please enter numbers only';
                                  });
                                } else {
                                  setState(() {
                                    errorMessage = null;
                                  });
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Align(
                            alignment: const Alignment(-1.0,-0.3),
                            child: RichText(
                              text:  TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'Discount ',
                                    style: TextStyle(
                                      color: Colors.black87,
                                      fontSize: 16,// Set the product name to black color
                                    ),
                                  ),
                                  const TextSpan(
                                    text: '*',
                                    style: TextStyle(
                                      color: Colors
                                          .red, // Set the asterisk to red color
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(2),
                              border: Border.all(color: Colors.blue[100]!),
                            ),
                            child: TextFormField(
                              controller: discountController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(2),
                              ],
                              decoration: InputDecoration(
                                fillColor: Colors.white,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 10,vertical: 13),
                                border: InputBorder.none,
                                filled: true,
                                hintText: 'Enter Discount',
                                hintStyle: TextStyle(color: Colors.grey),
                                errorText: errorMessage,
                              ),
                              onChanged: (value) {
                                if (value.isNotEmpty && !isNumeric(value)) {
                                  setState(() {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text("Please enter decimal number only")),
                                    );
                                  });
                                } else {
                                  setState(() {
                                    errorMessage = null;
                                  });
                                  if (value.isNotEmpty) {
                                    discountController.text = '$value%';
                                    discountController.selection = TextSelection.fromPosition(
                                      TextPosition(offset: discountController.text.length - 1),
                                    );
                                  } else {
                                    discountController.text = value;
                                  }
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40,),
              Align(
                alignment: Alignment.bottomLeft,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Align(
                      alignment: const Alignment(0.8,0.7),
                      child: OutlinedButton(
                        onPressed: () {
                          dropdownValue = 'Select';
                          dropdownValue3 = 'Select';
                          dropdownValue1 = 'Select';
                          dropdownValue2 = 'Select';
                          productNameController.clear();
                          priceController.clear();
                          selectedImages.clear();
                          imageIdController.clear();
                          discountController.clear();
                          setState(() {});

                          // Optionally, display a message
                          ScaffoldMessenger.of(context)
                              .showSnackBar(
                            const SnackBar(
                                content: Text("Form cleared")),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors
                              .grey[300], // Blue background color
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                5), // Rounded corners
                          ),
                          side: BorderSide.none, // No outline
                        ),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: 15,
                            // Increase font size if desired
                            // Bold text
                            color: Colors
                                .indigo[900], // White text color
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Align(alignment: Alignment.bottomLeft,
                      child: OutlinedButton(
                        onPressed: () async {
                          print('--------------');
                          // print(productNameController.text);
                          print('-------saveTo');
                          if (productNameController.text.isEmpty &&
                              dropdownValue == 'Select' &&
                              // dropdownValue3 != 'Select' &&
                              dropdownValue1 == 'Select' &&
                              dropdownValue2 == 'Select' &&
                              dropdownValue3 == 'Select' &&
                              priceController.text.isEmpty &&
                              discountController.text.isEmpty &&
                              selectedImages.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Please Fill all required Fields")),
                            );
                          } else if (productNameController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Please Enter Product Name")),
                            );
                          } else if (dropdownValue == 'Select') {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Please Select Category")),
                            );
                          } else if (dropdownValue3 == 'Select') {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Please Select Sub Category")),
                            );
                          } else if (dropdownValue1 == 'Select') {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Please Select Tax")),
                            );
                          }else if (dropdownValue2 == 'Select') {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Please Select Unit")),
                            );
                          }   else if (priceController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Please Enter Price")),
                            );
                          } else if (discountController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Please Enter Discount")),
                            );
                          }  else if (selectedImages.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Please Select Image")),
                            );
                          }
                          else{
                            await addProductMaster();
                          }
                          },

                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.blue[800],
                          // Blue background color
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                5), // Rounded corners
                          ),
                          side: BorderSide.none, // No outline
                        ),
                        child: const Text(
                          "Save",
                          style: TextStyle(
                              color: Colors.white, fontSize: 15),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  ],
)

                ]);
              }
          )
      ); // Use the ProductForm widget here

  }

  void _showSnackBar(String message) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
      );
    }
}

bool isNumeric(String value) {
  return double.tryParse(value) != null;
}

customerFieldDecoration(
    {required String hintText, required bool error, Function? onTap}) {
  return InputDecoration(
    constraints: BoxConstraints(maxHeight: error == true ? 50 : 30),
    hintText: hintText,
    hintStyle: const TextStyle(fontSize: 11),
    border:
    const OutlineInputBorder(borderSide: BorderSide(color: Colors.blue)),
    counterText: '',
    contentPadding: const EdgeInsets.fromLTRB(12, 00, 0, 0),
    enabledBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Color(0xff9FB3C8))),
    focusedBorder:
    const OutlineInputBorder(borderSide: BorderSide(color: Colors.blue)),
  );
}

