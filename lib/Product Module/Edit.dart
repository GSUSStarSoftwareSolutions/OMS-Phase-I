import 'dart:convert';
import 'dart:io' as io;

import 'dart:html';
import 'package:adaptive_scrollbar/adaptive_scrollbar.dart';
import 'package:btb/admin/Api%20name.dart';
import 'package:btb/widgets/productclass.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import '../Order Module/firstpage.dart';
import '../widgets/confirmdialog.dart';
import '../widgets/productclass.dart' as ord;
import '../widgets/productdata.dart';


void main(){
  runApp(const EditOrder(textInput: '', priceInput: '', productData: {}, prodId: '', discountInput: '', inputText: '', subText: '', unitText: '', taxText: '', imagePath: null, imageId: ''));
}


class EditOrder extends StatefulWidget {
  final String? textInput;
  final String? priceInput;
  final Map productData;
  final String? discountInput;
  final String inputText;
  //final List<dynamic>? orderDetails;
  final String prodId;
  final String subText;
  final String unitText;
  final String taxText;
  final Uint8List? imagePath;
  final String imageId;
  const EditOrder({
    super.key,
    required this.textInput,
    required this.priceInput,
    required this.productData,
    required this.prodId,
    required this.discountInput,
    required this.inputText,
    required this.subText,
    required this.unitText,
   // this.orderDetails,
    required this.taxText,
    required this.imagePath,
    required this.imageId,
  });
  @override
  State<EditOrder> createState() => _EditOrderState();
}
class _EditOrderState extends State<EditOrder> {
  String? pickedImagePath;
  String token = window.sessionStorage["token"] ?? " ";
  String? imagePath;
  io.File? selectedImage;
  bool isOrdersSelected = false;
  String? errorMessage;
  bool purchaseOrderError = false;
  final TextEditingController priceController = TextEditingController();
  final TextEditingController discountController = TextEditingController();
  final TextEditingController imageIdController = TextEditingController();
  final List<String> list = ['Select', 'Select 1', 'Select 2', 'Select 3'];
  String dropdownValue = 'Select';
  final List<String> list1 = ['select', '12', '18', '28', '10'];
  String? selectedDropdownItem;
  Uint8List? storeImageBytes1;
  String dropdownValue1 = 'select';
  String imageName = '';
  //List<ord.Product> filteredProducts = [];
  List<Uint8List> selectedImages = [];
  List<dynamic> detailJson =[];
  String _searchText = '';
  String storeImage = '';
  final List<String> list2 = ['select', 'PCS', 'NOS', 'PKT'];
  String dropdownValue2 = 'select';
  final List<String> list3 = ['select', 'Yes', 'No'];
  String dropdownValue3 = 'select';
  List<ProductData> selectedProductList = [];
  final _validate = GlobalKey<FormState>();
  var result;
  final TextEditingController productNameController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();
  final TextEditingController subCategoryController = TextEditingController();
  final TextEditingController taxController = TextEditingController();
  final TextEditingController imageIdContoller = TextEditingController();
  final TextEditingController unitController = TextEditingController();
  final TextEditingController prodIdController = TextEditingController();
  bool isHomeSelected = false;
  List<ord.Product> productList = [];
  String? _selectedValue;
  String? _selectedValue1;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  String? _selectedValue2;
  String? _selectedValue3;
  final ScrollController horizontalScroll = ScrollController();
  List<Product> filteredProducts = [];
  String updatedImageName = '';
  @override
  void initState() {
    super.initState();
    //fetchProducts1();
    // print('hi koo');
    // print(filteredProducts);
    _selectedValue = widget.inputText;
    _selectedValue1 = widget.subText;
    _selectedValue2 = widget.unitText;
    _selectedValue3 = widget.taxText;
    priceController.text = widget.priceInput!;
    discountController.text = widget.discountInput!;
    productNameController.text = widget.textInput!;
    storeImageBytes1 = widget.imagePath;
    prodIdController.text = widget.prodId;
    // print(_selectedValue);
    // print(_selectedValue2);
    // print(_selectedValue3);
    // print(_selectedValue1);
    // print(priceController.text);
    // print(discountController.text);
    // print(prodIdController.text);
    // print('-----imageName----');
    // print(widget.imageId);
    // print(storeImage);
    // print(widget.imagePath);
    // print('-----imagepath');
    print('updateimage');
    print(widget.imageId);
    loadImage(widget.imageId);


  }
  void loadImage(String imageUrl) {
    try {
      fetchImage(imageUrl);
      // Debugging information
      print('Image loaded successfully');
    } catch (e) {
      // Handle error
      print('Error loading image: $e');
    }
  }// Function to check if all required fields are filled
  bool areRequiredFieldsFilled() {
    return productNameController.text.isNotEmpty &&
        _selectedValue != 'Select' &&
        _selectedValue1 != 'Select' &&
        _selectedValue2 != 'select' &&
        _selectedValue3 != 'select' &&
        priceController.text.isNotEmpty &&
        discountController.text.isNotEmpty;
  }

  Future<void> filePicker(BuildContext context) async {
    result = await FilePicker.platform.pickFiles(type: FileType.image);

    if (result == null) {
      print("No file selected");
    } else {
      setState(() {
        selectedImages.clear(); // Clear previous selections
      });

      for (var element in result!.files) {
        if (element.size > 1024 * 1024) {
          // If the file size is greater than 1MB, show a scaffold message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Please upload an image below 1MB.'),
            ),
          );
          setState(() {
            selectedImages.clear(); // Clear previous selections
          });
        } else {
          setState(() {
            print('Selected Image:');
            print(element.name);
            imageIdController.text = element.name;
            storeImage = element.name;

            // Call the uploadImage function with the image bytes
            uploadImage(element.name); // Pass image bytes to uploadImage

            selectedImages.add(element.bytes!);
          });
        }
      }
    }
  }

  // Future<void> filePicker() async {
  //   result = await FilePicker.platform.pickFiles(type: FileType.image);
  //   if (result == null) {
  //     print("No file selected");
  //   } else {
  //     setState(() {
  //       selectedImages.clear(); // Clear previous selections
  //     });
  //     for (var element in result!.files) {
  //       setState(() {
  //         print('jiiii');
  //         print(element.name);
  //         imageIdController.text = element.name;
  //         storeImage = element.name;
  //         // Post api call.
  //         uploadImage(element.name); // Pass image bytes to uploadImage
  //         selectedImages.add(element.bytes!);
  //       });
  //       // Store the image data
  //     }
  //   }
  // }
  Future<void> uploadImage(String name) async {
    String url =
        'https://tn4l1nop44.execute-api.ap-south-1.amazonaws.com/stage1/api/v1_aws_s3_bucket/upload';
    try {
      if (result != null) {
        for (var element in result!.files) {
          // Prepare the multipart request
          var request = http.MultipartRequest('POST', Uri.parse(url));

          // Add the file to the request
          request.files.add(http.MultipartFile.fromBytes(
            'file',
            element.bytes!,
            filename: element.name,
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
            print(
                'Failed to upload image. Status code: ${response.statusCode}');
          }
        }
      } else {
        print('No file selected');
      }
    } catch (e) {
      print('Error uploading image: $e');
    }
  }

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
  //         // Send the request
  //         var streamedResponse = await request.send();
  //         // Get the response
  //         var response = await http.Response.fromStream(streamedResponse);
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


  void fetchImage(String imageId) async {
    print('----img-----');
    print(storeImage);
    String url =
        'https://tn4l1nop44.execute-api.ap-south-1.amazonaws.com/stage1/api/v1_aws_s3_bucket/view/$imageId';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      try {
        setState(() {
          storeImageBytes1 = response.bodyBytes;
        });
      } catch (e) {
        print('-------------');
        print('Error:$e');
      }
    }
  }



  Future<void> fetchProducts() async {

    try {
      final response = await http.get(
        Uri.parse(
          '$apicall/productmaster/get_all_productmaster', // Changed limit to 10
        ),
        headers: {
          "Content-type": "application/json",
          "Authorization": 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);


        filteredProducts = (jsonData as List).map((item) {
          return Product(
              prodId: item['prodId'],
              productName: item['productName'],
              category: item['category'],
              subCategory: item['subCategory'],
              tax: item['tax'],
              unit: item['unit'],
              price: item['price'],
              discount: item['discount'],
              imageId: item['imageId'],
              selectedVariation: '',
              selectedUOM: '',
              quantity: 0,
              qty: 0,
              totalamount: 0,
              totalAmount: 0,
              total: 0
          );
        }).toList();



//        Ensure that the storeImage is updated
    storeImage = '';
    uploadImage(storeImage);

    // Create a mutable copy of the unmodifiable map, ensuring the map is not null
    final mutableProductData = Map<String, dynamic>.from(widget.productData);

    // Modify the mutable copy
    mutableProductData['imageId'] = storeImage.isEmpty ? widget.imageId : storeImage;

    // Use the mutable map in the GoRouter navigation
    context.go('/Edit_View_Screen', extra: {
    'displayData': mutableProductData,
    'imagePath': storeImageBytes1!, // This is only used if not null
    'product': null,
    'orderDetails':filteredProducts.map((detail) => OrderDetail(
    orderId: detail.prodId,
    orderDate: detail.productName,
    orderCategory: detail.category,
    items: [],
    // Add other fields as needed
    )).toList(),
    'productText': widget.textInput ?? '', // Default to empty string if null
    'selectedValue': widget.inputText,
    'selectedValue1': widget.subText,
    'selectedValue3': widget.taxText,
    'selectedvalue2': widget.unitText,
    'priceText': widget.priceInput ?? '',
    'discountText': widget.discountInput ?? '',
    'prodId': prodIdController.text, // Ensure prodId is being passed
    });
      }
    } catch (e) {
      print('Error decoding JSON: $e');
      // Optionally, show an error message to the user
    }
  }


  Future<void> checkSave() async {


    // Create a map to store product data
    final productData = {
      "prodId": prodIdController.text,
      "productName": productNameController.text,
      "category": _selectedValue,
      "subCategory": _selectedValue1,
      "tax": _selectedValue3,
      "unit": _selectedValue2,
      "price": double.parse(priceController.text),
      "discount": discountController.text,
      "imageId": storeImage == "" ? widget.imageId : storeImage,
    };

    // Print product data for debugging
    _printProductData(productData);

    // API endpoint URL
    try {
      final getAllResponse = await http.get(
        Uri.parse('$apicall/productmaster/get_all_productmaster'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json'
        });

      if (getAllResponse.statusCode == 200) {
       // List<ord.Product> products = [];
        final jsonData = jsonDecode(getAllResponse.body);
        final productMasters = jsonData;


         filteredProducts = (jsonData as List).map((item) {
          return Product(
            prodId: item['prodId'],
            productName: item['productName'],
            category: item['category'],
            subCategory: item['subCategory'],
            tax: item['tax'],
            unit: item['unit'],
            price: item['price'],
            discount: item['discount'],
            imageId: item['imageId'],
            selectedVariation: '',selectedUOM: '',quantity: 0,qty: 0,totalamount: 0,totalAmount: 0,total: 0
          );
        }).toList();


        //final productMasters = jsonData.map((item) => ord.Product.fromJson(item)).toList();

        //   products = jsonData.map((item) => ord.Product.fromJson(item)).toList();

        print('hi');
    //    print(products);
        print(productMasters);
        print(filteredProducts);

        bool isProductMasterExists = false;


     //   print(isProductMasterExists);



        for (var productMaster in productMasters) {
          if (productMaster['productName'] == productNameController.text &&
              productMaster['category'] == _selectedValue &&
              productMaster['subCategory'] ==  _selectedValue1 &&
          productMaster['tax'] == _selectedValue3 &&
          productMaster['unit'] == _selectedValue2 &&
          productMaster['price'] == double.parse(priceController.text) &&
          productMaster['discount'] == discountController.text
          //productMaster['imageId'] == productMasterData['imageId']
          )
          {
            isProductMasterExists = true;
            break;
          }
        }

        if (isProductMasterExists) {
          showDialog(
            barrierDismissible: false,
            context: context,
            builder: (context) {
              return AlertDialog(
                icon: const Icon(Icons.warning_sharp,color: Colors.red,size: 25,),
                content: const SelectableText('A product details with the same details already exists.'),
                actions: <Widget>[
                  TextButton(
                    child: const Text('OK'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
        } else {
          final addApiUrl = '$apicall/productmaster/update_productmaster';

          final addResponse = await http.put(Uri.parse(addApiUrl),
              headers: {
                'Authorization': 'Bearer $token',
                'Content-Type': 'application/json'
              },
              body: jsonEncode(productData));

          if (addResponse.statusCode == 200) {
            print('A product details updated successfully');


            final getAllResponseAgain = await http.get(
              Uri.parse('$apicall/productmaster/get_all_productmaster'),
              headers: {
                'Authorization': 'Bearer $token',
                'Content-Type': 'application/json'
              },
            );

            if (getAllResponseAgain.statusCode == 200) {
              final jsonDataAgain = jsonDecode(getAllResponseAgain.body);
              final productMastersAgain = jsonDataAgain;

              // Update filteredProducts list with new product details
              filteredProducts = (jsonDataAgain as List).map((item) {
                return Product(
                    prodId: item['prodId'],
                    productName: item['productName'],
                    category: item['category'],
                    subCategory: item['subCategory'],
                    tax: item['tax'],
                    unit: item['unit'],
                    price: item['price'],
                    discount: item['discount'],
                    imageId: item['imageId'],
                    selectedVariation: '',
                    selectedUOM: '',
                    quantity: 0,
                    qty: 0,
                    totalamount: 0,
                    totalAmount: 0,
                    total: 0
                );
              }).toList();

              // List<detail> filteredProducts = await fetchProducts1();
              //  List<detail> filteredProducts = productMasters.map((productMaster) => detail(
              //                prodId: productMaster['prodId'],
              //                productName: productMaster['productName'],
              //                category: productMaster['category'], orderDate: '',
              //    orderId: '',deliveryStatus: '',deliveryLocation: '',deliveryAddress: '',total: 0,items: [],referenceNumber: '',status: ''
              //
              //              )).toList();
              //  List<detail> filteredProducts = productMasters.cast<detail>();
              showDialog(
                barrierDismissible: false,
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(5))),
                    icon: const Icon(
                      Icons.check_circle_rounded,
                      color: Colors.green,
                      size: 25,
                    ),
                    title: const Text("Success"),
                    content: const Padding(
                      padding: EdgeInsets.only(left: 26),
                      child: Text("Product Updated successfully"),
                    ),
                    actions: [
                      TextButton(
                        child: const Text("OK"),
                        onPressed: () async {
                          print(filteredProducts);
                          print('after chaning price');
                          print(priceController.text);
                          // Navigator.of(context).pop();
                          // context.go('/Home/Products/Add_Product/Products')
                          uploadImage(storeImage);
                          widget.productData['imageId'] =
                          storeImage == ""
                              ? widget.imageId
                              : storeImage;
                          widget.productData['productName'] =
                              productNameController.text;
                          widget.productData['category'] =
                              _selectedValue;
                          widget.productData['subCategory'] =
                              _selectedValue1;
                          widget.productData['tax'] = _selectedValue3;
                          widget.productData['unit'] = _selectedValue2;
                          widget.productData['price'] =
                              priceController.text;
                          widget.productData['discount'] =
                              discountController.text;


                          print('hellow');
                          print(productMasters);


                          // filteredProducts = productMasters;


                          context.go('/Update_Product_View', extra: {
                            'displayData': widget.productData,
                            'product': null,
                            'imagePath': null,
                            'orderDetails': filteredProducts.map((detail) =>
                                OrderDetail(
                                  orderId: detail.prodId,
                                  orderDate: detail.productName,
                                  orderCategory: detail.category,
                                  items: [],
                                  // Add other fields as needed
                                )).toList(),
                            'productText': widget.productData['productName'],
                            'selectedValue': widget.productData['category'],
                            'selectedValue1': widget.productData['subCategory'],
                            'selectedValue3': widget.productData['tax'],
                            'selectedvalue2': widget.productData['unit'],
                            //  'priceText': widget.productData['price'],
                            'priceText': widget.productData['price'],
                            'discountText': widget.productData['discount'],
                            'prodId': widget.prodId,
                          });
                          // context.go('/dashboard/productpage/ontap/Edit/Update', extra: {
                          //   'displayData':  widget.productData,
                          //   'product': null,
                          //   'imagePath': null,
                          //   'orderDetails': filteredProducts.map((detail) => OrderDetail(
                          //     orderId: detail.prodId,
                          //     orderDate: detail.productName,
                          //     orderCategory: detail.category,
                          //     items: [],
                          //     // Add other fields as needed
                          //   )).toList(),
                          //   'productText':  widget.productData['productName'],
                          //   'selectedValue': widget.productData['category'],
                          //   'selectedValue1':  widget.productData['subCategory'],
                          //   'selectedValue3': widget.productData['tax'],
                          //   'selectedvalue2': widget.productData['unit'],
                          //   //  'priceText': widget.productData['price'],
                          //   'priceText': widget.productData['price'],
                          //   'discountText': widget.productData['discount'],
                          //   'prodId': widget.prodId,
                          // });

                        },
                      ),
                    ],
                  );
                },
              );
            } } else {
            print('Error adding product master: ${addResponse.statusCode}');
          }
        }
      }else{
        print('Failed to load product masters');
      }
    } catch (e) {
      _showErrorDialog('An error occurred: $e');
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
      _buildMenuItem('Home', Icons.home_outlined, Colors.blue[900]!, '/Home'),
      _buildMenuItem('Customer', Icons.account_circle, Colors.blue[900]!, '/Customer'),
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
          child: _buildMenuItem('Products', Icons.image_outlined, Colors.white, '/Product_List')),
      _buildMenuItem('Orders', Icons.warehouse_outlined, Colors.blue[900]!, '/Order_List'),
      _buildMenuItem('Invoice', Icons.document_scanner_outlined, Colors.blue[900]!, '/Invoice'),
      _buildMenuItem('Delivery', Icons.fire_truck_outlined, Colors.blue[900]!, '/Delivery_List'),
      _buildMenuItem('Payment', Icons.payment_outlined, Colors.blue[900]!, '/Payment_List'),
      _buildMenuItem('Return', Icons.insert_chart_outlined, Colors.blue[900]!, '/Return_List'),
      _buildMenuItem('Reports', Icons.insert_chart_outlined, Colors.blue[900]!, '/Report_List'),
    ];
  }

  Widget _buildMenuItem(String title, IconData icon, Color iconColor, String route) {
    iconColor = _isHovered[title] == true ? Colors.blue : Colors.black87;
    title == 'Products'? _isHovered[title] = false :  _isHovered[title] = false;
    title == 'Products'? iconColor = Colors.white : Colors.black;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered[title] = true),
      onExit: (_) => setState(() => _isHovered[title] = false),
      child: GestureDetector(
        onTap: () {
          context.go(route);
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 5,right: 20,),
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

// Helper functions

  bool _areRequiredFieldsFilled() {
    return productNameController.text.isNotEmpty &&
        priceController.text.isNotEmpty &&
        discountController.text.isNotEmpty;
  }

  void _showSnackBarForRequiredFields() {
    if (mounted) {
      if (productNameController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please Enter Product Name")),
        );
      } else if (priceController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please enter the price")),
        );
      } else if (discountController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please enter the discount")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please fill all required fields")),
        );
      }
    }
  }

  void _printProductData(Map<String, dynamic> productData) {
    print('---------productData------');
    print(widget.imageId);
    print(storeImage);
    print('-----imageid-------');
    print(productData);
    print(storeImage);
    print('----prodid');
    print(prodIdController.text);
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          icon: const Icon(Icons.warning_sharp, color: Colors.red, size: 25),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          icon: const Icon(Icons.check_circle, color: Colors.green, size: 25),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // void checkSave(
  //     String ProductName,
  //     String category,
  //     String subCategory,
  //     String tax,
  //     String unit,
  //     double price,
  //     String discount,
  //     String imageId,
  //     ) async {
  //   if (!areRequiredFieldsFilled()) {
  //     // if (mounted) {
  //     //   ScaffoldMessenger.of(context).showSnackBar(
  //     //     const SnackBar(content: Text("Please fill all required fields")),
  //     //   );
  //     // }
  //     if (mounted) {
  //       if (productNameController.text.isEmpty &&
  //           priceController.text.isEmpty &&
  //           discountController.text.isEmpty
  //       ) {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           const SnackBar(content: Text("Please fill all required fields")),
  //         );
  //       } else if (productNameController.text.isEmpty) {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           const SnackBar(content: Text("Please Enter Product Name")),
  //         );
  //       }  else if (priceController.text.isEmpty) {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           const SnackBar(content: Text("Please enter the price")),
  //         );
  //       } else if (discountController.text.isEmpty) {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           const SnackBar(content: Text("Please enter the discount")),
  //         );
  //       }
  //     }
  //     return;
  //   }
  //   final productData = {
  //     "prodId": prodIdController.text,
  //     "productName": productNameController.text,
  //     "category": _selectedValue,
  //     "subCategory": _selectedValue1,
  //     "tax": _selectedValue3,
  //     "unit": _selectedValue2,
  //     "price": double.parse(priceController.text),
  //     "discount": discountController.text,
  //     "imageId": storeImage == "" ? widget.imageId : storeImage,
  //   };
  //   print('---------productData------');
  //   print(widget.imageId);
  //   print(storeImage);
  //   print('-----imageid-------');
  //   print(imageId);
  //   print(productData);
  //   print(storeImage);
  //   print('----prodid');
  //   print(prodIdController.text);
  //
  //   final  url =
  //       '$apicall/productmaster/update_productmaster';
  //   final response = await http.put(
  //     Uri.parse(url),
  //     headers: {
  //       "Content-Type": "application/json",
  //       'Authorization': 'Bearer $token'
  //     },
  //     body: json.encode(productData),
  //   );
  //   if (response.statusCode == 200) {
  //     final responseData = json.decode(response.body);
  //
  //     if (responseData.containsKey("error")) {
  //       showDialog(
  //         context: context,
  //         builder: (context) {
  //           return
  //             AlertDialog(
  //             icon: Icon(Icons.warning_sharp,color: Colors.red,size: 25,),
  //             content: Text('A product master with the same details already exists.'),
  //             actions: <Widget>[
  //               TextButton(
  //                 child: Text('OK'),
  //                 onPressed: () {
  //                   Navigator.of(context).pop();
  //                 },
  //               ),
  //             ],
  //           );
  //         },
  //       );
  //     }
  //
  //   } else {
  //     showDialog(
  //       context: context,
  //       builder: (context) {
  //         return AlertDialog(
  //           icon: Icon(Icons.warning_sharp,color: Colors.red,size: 25,),
  //           content: Text('Product Updated Successfully.'),
  //           actions: <Widget>[
  //             TextButton(
  //               child: Text('OK'),
  //               onPressed: () {
  //                 Navigator.of(context).pop();
  //               },
  //             ),
  //           ],
  //         );
  //       },
  //     );
  //   }
  // }


  //


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color(0xFFFFFFFF),
        appBar: AppBar(
          title: Image.asset("images/Final-Ikyam-Logo.png"),
          backgroundColor:
          const Color(0xFFFFFFFF), // Set background color to white
          elevation: 4.0,
          shadowColor: const Color(0xFFFFFFFF), // Set shadow color to black
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
              child: AccountMenu(),

            ),
          ],
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            final screenWidth = MediaQuery.of(context).size.width;

            double maxWidth = constraints.maxWidth;
            double maxHeight = constraints.maxHeight;
            if(constraints.maxWidth >= 1366){
              return Stack(children: [

                Align(
                  // Added Align widget for the left side menu
                  alignment: Alignment.topLeft,
                  child: Container(
                    height: 1400,
                    width: 200,
                    color: const Color(0xFFF7F6FA),
                    padding: const EdgeInsets.only(left: 15, top: 10,right: 15),
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
                Padding(
                  padding: const EdgeInsets.only(left: 203),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    color: const Color(0xFFFFFDFF),
                    height: 60,
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back), // Back button icon
                          onPressed: () async {

                            print('hi'
                            );
                            await fetchProducts();
                            print(filteredProducts);


                            // Debug prints for verification


                            // Ensure that `storeImageBytes1` and `prodIdController` are not null before proceeding


                            // print('prodId: ${prodIdController.text}');
                            // context.go('/Edit_Product', extra: {
                            //   'displayData': mutableProductData,
                            //   'imagePath': storeImageBytes1! ?? '', // This is only used if not null
                            //   'product': null,
                            //   'productText': widget.textInput ?? '', // Default to empty string if null
                            //   'selectedValue': widget.inputText ?? '',
                            //   'selectedValue1': widget.subText ?? '',
                            //   'selectedValue3': widget.taxText ?? '',
                            //   'selectedvalue2': widget.unitText ?? '',
                            //   'priceText': widget.priceInput ?? '',
                            //   'discountText': widget.discountInput ?? '',
                            //   'prodId': prodIdController.text ?? '', // Ensure prodId is being passed
                            // });

                          },
                          // onPressed: () {
                          //
                          //
                          //   // Debug prints for verification
                          //
                          //
                          //   // Ensure that `storeImageBytes1` and `prodIdController` are not null before proceeding
                          //
                          //     // Ensure that the storeImage is updated
                          //     storeImage = '';
                          //     uploadImage(storeImage);
                          //
                          //     // Create a mutable copy of the unmodifiable map, ensuring the map is not null
                          //     final mutableProductData = Map<String, dynamic>.from(widget.productData);
                          //
                          //     // Modify the mutable copy
                          //     mutableProductData['imageId'] = storeImage.isEmpty ? widget.imageId : storeImage;
                          //
                          //     // Use the mutable map in the GoRouter navigation
                          //   context.go('/Edit_View_Screen', extra: {
                          //     'displayData': mutableProductData,
                          //     'imagePath': storeImageBytes1!, // This is only used if not null
                          //     'product': null,
                          //     'orderDetails':filteredProducts.map((detail) => OrderDetail(
                          //       orderId: detail.prodId,
                          //       orderDate: detail.productName,
                          //       orderCategory: detail.category,
                          //       items: [],
                          //       // Add other fields as needed
                          //     )).toList(),
                          //     'productText': widget.textInput ?? '', // Default to empty string if null
                          //     'selectedValue': widget.inputText,
                          //     'selectedValue1': widget.subText,
                          //     'selectedValue3': widget.taxText,
                          //     'selectedvalue2': widget.unitText,
                          //     'priceText': widget.priceInput ?? '',
                          //     'discountText': widget.discountInput ?? '',
                          //     'prodId': prodIdController.text, // Ensure prodId is being passed
                          //   });
                          //     print('prodId: ${prodIdController.text}');
                          //     // context.go('/Edit_Product', extra: {
                          //     //   'displayData': mutableProductData,
                          //     //   'imagePath': storeImageBytes1! ?? '', // This is only used if not null
                          //     //   'product': null,
                          //     //   'productText': widget.textInput ?? '', // Default to empty string if null
                          //     //   'selectedValue': widget.inputText ?? '',
                          //     //   'selectedValue1': widget.subText ?? '',
                          //     //   'selectedValue3': widget.taxText ?? '',
                          //     //   'selectedvalue2': widget.unitText ?? '',
                          //     //   'priceText': widget.priceInput ?? '',
                          //     //   'discountText': widget.discountInput ?? '',
                          //     //   'prodId': prodIdController.text ?? '', // Ensure prodId is being passed
                          //     // });
                          //
                          // },
                        ),



                        // IconButton(
                        //   icon: const Icon(
                        //       Icons.arrow_back), // Back button icon
                        //   onPressed: () {
                        //     print('prodId');
                        //     print(prodIdController.text);
                        //     storeImage = '';
                        //     uploadImage(storeImage);
                        //     // fetchImage(storeImage);
                        //     widget.productData['imageId'] = storeImage == ""
                        //         ? widget.imageId  : storeImage;
                        //
                        //     context.go('/Edit_Product', extra: {
                        //       'displayData': widget.productData,
                        //       'imagePath': storeImageBytes1!,
                        //       'product': null,
                        //       'productText': widget.textInput!,
                        //       'selectedValue': widget.inputText,
                        //       'selectedValue1': widget.subText,
                        //       'selectedValue3': widget.taxText,
                        //       'selectedvalue2': widget.unitText,
                        //       'priceText': widget.priceInput!,
                        //       'discountText': widget.discountInput!,
                        //       'prodId': prodIdController.text,
                        //
                        //     });
                        //
                        //
                        //   },
                        // ),
                        const Padding(
                          padding: EdgeInsets.only(left: 20),
                          child: Text(
                            'Edit',
                            style: TextStyle(
                              fontSize: 25,
                              // fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const Spacer(),
                        Align(
                          alignment: Alignment.topRight,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 15, right: 30),
                            child: OutlinedButton(
                              onPressed: () {
                                _selectedValue = widget.inputText;
                                _selectedValue1 = widget.subText;
                                _selectedValue2 = widget.unitText;
                                _selectedValue3 = widget.taxText;
                                productNameController.text = widget.textInput!;
                                priceController.text = widget.priceInput!;
                                discountController.text = widget.discountInput!;
                                selectedImages.clear();

                                storeImageBytes1 = widget.imagePath;
                                print(storeImageBytes1);
                                print('---wel');
                                print(widget.imageId);
                                loadImage(widget.imageId);
                                //uploadImage(widget.imageId);
                              },
                              style: OutlinedButton.styleFrom(
                                backgroundColor:
                                Colors.grey[300], // Blue background color
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      5), // Rounded corners
                                ),
                                side: BorderSide.none, // No outline
                              ),
                              child: Text(
                                'Cancel',
                                style: TextStyle(
                                  fontSize: 14,
                                  // fontWeight: FontWeight.bold,
                                  // Increase font size if desired
                                  // Bold text
                                  color: Colors.indigo[900], // White text color
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 5,right: 30),
                          child: OutlinedButton(
                            onPressed: () async {
                              if (productNameController.text.isEmpty &&
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
                              }    else if (priceController.text.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Please Enter Price")),
                                );
                              } else if (discountController.text.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Please Enter Discount")),
                                );
                              }else{
                                await checkSave();
                              }

                              //  print(storeImage);
                              // await  checkSave(
                              //    // productNameController.text,
                              //    // _selectedValue!, // Replace with actual value
                              //    // _selectedValue1!, // Replace with actual value
                              //    // _selectedValue3!, // Replace with actual value
                              //    // _selectedValue2!, // Replace with actual value
                              //    // double.parse(
                              //    //     priceController.text.toString()),
                              //    // discountController.text,
                              //    // storeImage,
                              //  );
                              //
                              //  // fetchImage(storeImage);
                              //
                              //
                              //  // showDialog(
                              //  //   context: context,
                              //  //   builder: (BuildContext context) {
                              //  //     return AlertDialog(
                              //  //       shape: const RoundedRectangleBorder(
                              //  //           borderRadius: BorderRadius.all(Radius.circular(5))),
                              //  //       icon: const Icon(
                              //  //         Icons.check_circle_rounded,
                              //  //         color: Colors.green,
                              //  //         size: 25,
                              //  //       ),
                              //  //       title: const Text("Success"),
                              //  //       content: const Padding(
                              //  //         padding: EdgeInsets.only(left: 26),
                              //  //         child: Text("Product Updated successfully"),
                              //  //       ),
                              //  //       actions: [
                              //  //         TextButton(
                              //  //           child: const Text("OK"),
                              //  //           onPressed: () {
                              //  //             //Navigator.of(context).pop();
                              //  //             context.go('/dashboard/productpage/ontap/Edit/Update', extra: {
                              //  //               'displayData':  widget.productData,
                              //  //               'product': null,
                              //  //               'imagePath': null,
                              //  //               'productText': widget.productData['productName'],
                              //  //               'selectedValue': widget.productData['category'],
                              //  //               'selectedValue1': widget.productData['subCategory'],
                              //  //               'selectedValue3': widget.productData['tax'],
                              //  //               'selectedvalue2': widget.productData['unit'],
                              //  //               'priceText': widget.productData['price'],
                              //  //               'discountText': widget.productData['discount'],
                              //  //               'prodId': widget.prodId,
                              //  //             });
                              //  //           },
                              //  //         ),
                              //  //       ],
                              //  //     );
                              //  //   },
                              //  // );
                              //
                              //
                              //  //old
                              //    // checkSave(
                              //    //   productNameController.text,
                              //    //   _selectedValue!, // Replace with actual value
                              //    //   _selectedValue1!, // Replace with actual value
                              //    //   _selectedValue3!, // Replace with actual value
                              //    //   _selectedValue2!, // Replace with actual value
                              //    //   double.parse(
                              //    //       priceController.text.toString()),
                              //    //   discountController.text,
                              //    //   storeImage,
                              //    // );
                              //    // uploadImage(storeImage);
                              //    // // fetchImage(storeImage);
                              //    // widget.productData['imageId'] =
                              //    // storeImage == ""
                              //    //     ? widget.imageId
                              //    //     : storeImage;
                              //    // widget.productData['productName'] =
                              //    //     productNameController.text;
                              //    // widget.productData['category'] =
                              //    //     _selectedValue;
                              //    // widget.productData['subCategory'] =
                              //    //     _selectedValue1;
                              //    // widget.productData['tax'] = _selectedValue3;
                              //    // widget.productData['unit'] = _selectedValue2;
                              //    // widget.productData['price'] =
                              //    //     priceController.text;
                              //    // widget.productData['discount'] =
                              //    //     discountController.text;
                              //    //
                              //    // ScaffoldMessenger.of(context).showSnackBar(
                              //    //   const SnackBar(
                              //    //       content: Text(
                              //    //           "Product updated successfully")),
                              //    // );
                              //    // context.go(
                              //    //     '${PageName.subsubpage2Main}/${PageName.subpage2Main}');
                              //    //router maha dev
                              //


                            },
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Colors
                                  .blue[800], // Button background color
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    5), // Rounded corners
                              ),
                              side: BorderSide.none, // No outline
                            ),
                            child: const Text(
                              'Save',
                              style: TextStyle(
                                fontSize: 14,
                                // fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
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
                      padding: const EdgeInsets.only(left: 200),
                      child: GestureDetector(
                        onTap: () {
                          print('---imagePath---');
                          print(imagePath);
                          print(selectedImage);
                          filePicker(context);
                        },
                        child: Card(
                          margin: EdgeInsets.only(left: maxWidth * 0.08, top: maxHeight * 0.27, bottom: maxHeight * 0.29),
                          child: Flex(
                            direction: Axis.vertical,
                            children: [
                              Flexible(
                                flex: 4,
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
                                        blurRadius: 3,
                                        offset: const Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                  // decoration: BoxDecoration(
                                  //   color: Colors.grey[300],
                                  //   borderRadius: BorderRadius.circular(4),
                                  // ),
                                  child:

                                  Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      if (selectedImages.isEmpty)...[
                                        widget.imagePath!= null
                                            ? Opacity(
                                            opacity: 0.5,
                                            child: Image.memory(widget.imagePath!,
                                              fit: BoxFit.cover,
                                              width: 400, // Adjust as needed
                                              height: 300,
                                            ))
                                            : const Text("Image is Null"),
                                      ] else...[
                                        for (var imageBytes in selectedImages)
                                          Opacity(
                                            opacity: 0.3,
                                            child: Image.memory(
                                              imageBytes,
                                              fit: BoxFit.cover,

                                            ),
                                          ),
                                      ],
                                      Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.cloud_upload_outlined, color: Colors.blue[900], size: 50),
                                          const SizedBox(height: 8),
                                          const Text(
                                              'Click to upload image',
                                              textAlign: TextAlign.center,style: TextStyle(color: Colors.black)
                                          ),
                                          const SizedBox(height: 8),
                                          const Text(
                                            'PNG, JPG, or GIF Recommended size below 1MB',
                                            textAlign: TextAlign.center,style: TextStyle(color: Colors.black),
                                          ),
                                        ],
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
                    // Padding(
                    // padding: EdgeInsets.only(left: 250),
                    // child: GestureDetector(
                    // onTap: () {
                    // print('---imagePath---');
                    // print(imagePath);
                    // print(selectedImage);
                    // filePicker();
                    // },
                    // child: Card(
                    // margin: EdgeInsets.only(left: maxWidth * 0.08, top: maxHeight * 0.27, bottom: maxHeight * 0.29),
                    // child: Flex(
                    // direction: Axis.vertical,
                    // children: [
                    // Flexible(
                    // flex: 4,
                    // child: Container(
                    // width: maxWidth * 0.3,
                    // height: maxHeight * 1.2,
                    // decoration: BoxDecoration(
                    // border: Border.all(color: Colors.grey),
                    // color: Colors.white70,
                    // borderRadius: BorderRadius.circular(8),
                    // boxShadow: [
                    // BoxShadow(
                    // color: Colors.blue.withOpacity(0.1),
                    // spreadRadius: 1,
                    // blurRadius: 3,
                    // offset: const Offset(0, 1),
                    // ),
                    // ],
                    // ),
                    // child: Stack(
                    // alignment: Alignment.center,
                    // children: [
                    // // Display image
                    // if (selectedImages.isEmpty) ...[
                    // widget.imagePath != null
                    // ? Image.memory(
                    // widget.imagePath!,
                    // fit: BoxFit.cover,
                    // width: double.infinity,
                    // height: double.infinity,
                    // )
                    //     : const Text("Image is Null"),
                    // ] else ...[
                    // for (var imageBytes in selectedImages)
                    // Image.memory(
                    // imageBytes,
                    // fit: BoxFit.cover,
                    // width: double.infinity,
                    // height: double.infinity,
                    // ),
                    // ],
                    // // Apply blur effect over the image
                    // Positioned.fill(
                    // child: BackdropFilter(
                    // filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), // Adjust blur intensity
                    // child: Container(
                    // color: Colors.transparent, // Keeping container transparent to see the blur effect
                    // ),
                    // ),
                    // ),
                    // // Overlaying text content
                    // Column(
                    // mainAxisAlignment: MainAxisAlignment.center,
                    // children: [
                    // Icon(Icons.cloud_upload_outlined, color: Colors.white, size: 50),
                    // const SizedBox(height: 8),
                    // const Text(
                    // 'Click to upload image',
                    // textAlign: TextAlign.center,
                    // style: TextStyle(
                    // color: Colors.white,
                    // fontSize: 16,
                    // ),
                    // ),
                    // const SizedBox(height: 8),
                    // const Text(
                    // 'PNG, JPG, or GIF\nRecommended size below 1MB',
                    // textAlign: TextAlign.center,
                    // style: TextStyle(
                    // color: Colors.white,
                    // fontSize: 12,
                    // ),
                    // ),
                    // ],
                    // ),
                    // ],
                    // ),
                    // ),
                    // ),
                    // ],
                    // ),
                    // ),
                    // ),
                    // ),


                    // Padding(
                    //   padding: EdgeInsets.only(left: 250),
                    //   child: GestureDetector(
                    //     onTap: () {
                    //       print('---imagePath---');
                    //       print(imagePath);
                    //       print(selectedImage);
                    //       filePicker();
                    //     },
                    //     child: Card(
                    //       margin: EdgeInsets.only(left: maxWidth * 0.08, top: maxHeight * 0.27, bottom: maxHeight * 0.29),
                    //       child: Flex(
                    //         direction: Axis.vertical,
                    //         children: [
                    //           Flexible(
                    //             flex: 4,
                    //             child: Container(
                    //               width: maxWidth * 0.3,
                    //               height: maxHeight * 1.2,
                    //               decoration: BoxDecoration(
                    //                 border: Border.all(color: Colors.grey),
                    //                 color: Colors.white70,
                    //                 borderRadius: BorderRadius.circular(8),
                    //                 boxShadow: [
                    //                   BoxShadow(
                    //                     color: Colors.blue.withOpacity(0.1), // Soft grey shadow
                    //                     spreadRadius: 1,
                    //                     blurRadius: 3,
                    //                     offset: const Offset(0, 1),
                    //                   ),
                    //                 ],
                    //               ),
                    //               // decoration: BoxDecoration(
                    //               //   color: Colors.grey[300],
                    //               //   borderRadius: BorderRadius.circular(4),
                    //               // ),
                    //               child: Stack(
                    //                 alignment: Alignment.center,
                    //                 children: [
                    //                   if (selectedImages.isEmpty)...[
                    //                     widget.imagePath!= null
                    //                         ? Image.memory(widget.imagePath!)
                    //                         : const Text("Image is Null"),
                    //                   ] else...[
                    //                     for (var imageBytes in selectedImages)
                    //                       Image.memory(
                    //                         imageBytes,
                    //                         fit: BoxFit.cover,
                    //                         width: 300, // Adjust as needed
                    //                         height: 300, // Adjust as needed
                    //                       ),
                    //                   ],
                    //                   Column(
                    //                     mainAxisAlignment: MainAxisAlignment.center,
                    //                     children: [
                    //                       Icon(Icons.cloud_upload_outlined, color: Colors.blue[900], size: 50),
                    //                       const SizedBox(height: 8),
                    //                       const Text(
                    //                         'Click to upload image',
                    //                         textAlign: TextAlign.center,
                    //                       ),
                    //                       const SizedBox(height: 8),
                    //                       const Text(
                    //                         'PNG, JPG, or GIF Recommended size below 1MB',
                    //                         textAlign: TextAlign.center,
                    //                         style: TextStyle(fontSize: 12),
                    //                       ),
                    //                     ],
                    //                   ),
                    //                 ],
                    //               ),
                    //             ),
                    //           ),
                    //         ],
                    //       ),
                    //     ),
                    //   ),
                    // ),

                    const SizedBox(
                      height: 10,
                    ),
                    Expanded(
                      child: Card(
                        margin: EdgeInsets.only(left: maxWidth * 0.08, top:maxWidth* 0.10,right: maxWidth * 0.1),
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
                                  Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: RichText(
                                      text:  const TextSpan(
                                        children: [
                                          TextSpan(
                                            text: 'Product Name ',
                                            style: TextStyle(
                                              color: Colors.black87,
                                              fontSize: 16,/// Set the product name to black color
                                            ),
                                          ),
                                          TextSpan(
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
                                  const SizedBox(height: 2),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Container(
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(2),
                                        border: Border.all(
                                            color: Colors.blue[100]!),
                                      ),
                                      child: TextFormField(
                                        // LAST ONE
                                        //initialValue: widget.textInput,
                                        controller: productNameController,
                                        decoration: InputDecoration(
                                          fillColor: Colors.white,
                                          contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 10,vertical: 13),
                                          border: InputBorder.none,
                                          filled: true,
                                          hintText: 'Enter Product Name',
                                          hintStyle: const TextStyle(color: Colors.grey),
                                          errorText: errorMessage,
                                        ),
                                        inputFormatters: [
                                          // FilteringTextInputFormatter.allow(
                                          //     RegExp("[a-zA-Z0-9 ]")),
                                          // Allow only letters, numbers, and single space
                                          FilteringTextInputFormatter.deny(
                                              RegExp(r'^\s')),
                                          // Disallow starting with a space
                                          FilteringTextInputFormatter.deny(
                                              RegExp(r'\s\s')),
                                          // Disallow multiple spaces
                                        ],
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
                                        //     checkSave();
                                        //   }
                                        //   return null;
                                        // },
                                        minLines: 1,
                                        maxLines: 1,
                                        // expands: true,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              Row(
                                children: [
                                  Flexible(
                                    flex: 2,
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(4.0),
                                          child: Align(
                                            alignment: const  Alignment(-1.0,-0.3),

                                            child: RichText(
                                              text:  const TextSpan(
                                                children: [
                                                  TextSpan(
                                                    text: 'Category ',
                                                    style: TextStyle(
                                                      color: Colors.black87,
                                                      fontSize: 16,//// Set the product name to black color
                                                    ),
                                                  ),
                                                  TextSpan(
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
                                                child:
                                                DropdownButtonHideUnderline(
                                                  child: DropdownButton<String>(
                                                    value: _selectedValue,
                                                    onChanged:
                                                        (String? newValue) {
                                                      setState(() {
                                                        _selectedValue =
                                                        newValue!;
                                                      });
                                                    },
                                                    items: <String>[
                                                      widget.inputText,
                                                      'Select 1',
                                                      'Select 2',
                                                      'Select 3'
                                                    ].map<
                                                        DropdownMenuItem<
                                                            String>>(
                                                            (String value) {
                                                          return DropdownMenuItem<
                                                              String>(
                                                            value: value,
                                                            child: Text(value),
                                                          );
                                                        }).toList(),
                                                    icon:  Icon(Icons.arrow_drop_down_circle_rounded,color: Colors.blue[800],),
                                                    iconSize: 18,
                                                    isExpanded:
                                                    true, // Ensures the dropdown fills the width
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
                                  Flexible(
                                    flex: 2,
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(4.0),
                                          child: Align(
                                            alignment: const Alignment(-1.0,-0.3),
                                            child: RichText(
                                              text:  const TextSpan(
                                                children: [
                                                  TextSpan(
                                                    text: 'Sub Category ',
                                                    style: TextStyle(
                                                      color: Colors
                                                          .black87, //
                                                      fontSize: 16,// Set the product name to black color
                                                    ),
                                                  ),
                                                  TextSpan(
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
                                                child:
                                                DropdownButtonHideUnderline(
                                                  child: DropdownButton<String>(
                                                    value: _selectedValue1,
                                                    onChanged:
                                                        (String? newValue) {
                                                      setState(() {
                                                        _selectedValue1 =
                                                        newValue!;
                                                      });
                                                    },
                                                    items: <String>[
                                                      widget.subText,
                                                      'Yes',
                                                      'No'
                                                    ].map<
                                                        DropdownMenuItem<
                                                            String>>(
                                                            (String value) {
                                                          return DropdownMenuItem<
                                                              String>(
                                                            value: value,
                                                            child: Text(value),
                                                          );
                                                        }).toList(),
                                                    icon:  Icon(Icons.arrow_drop_down_circle_rounded,color: Colors.blue[800],),
                                                    iconSize: 18,
                                                    isExpanded: true, // Ensures the dropdown fills the width
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
                                          child: RichText(
                                            text:  const TextSpan(
                                              children: [
                                                TextSpan(
                                                  text: 'Tax ',
                                                  style: TextStyle(
                                                    color: Colors
                                                        .black87,
                                                    fontSize: 16,// Set the product name to black color
                                                  ),
                                                ),
                                                TextSpan(
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
                                                child:
                                                DropdownButtonHideUnderline(
                                                  child: DropdownButton<String>(
                                                    value: _selectedValue3,
                                                    onChanged:
                                                        (String? newValue) {
                                                      setState(() {
                                                        _selectedValue3 =
                                                        newValue!;
                                                      });
                                                    },
                                                    items: <String>[
                                                      widget.taxText,
                                                      '12%    ',
                                                      '18%    ',
                                                      '20%    ',
                                                      '10%    '
                                                    ].map<
                                                        DropdownMenuItem<
                                                            String>>(
                                                            (String value) {
                                                          return DropdownMenuItem<
                                                              String>(
                                                            value: value,
                                                            child: Text(value),
                                                          );
                                                        }).toList(),
                                                    icon:  Icon(Icons.arrow_drop_down_circle_rounded,color: Colors.blue[800],),
                                                    iconSize: 18,
                                                    isExpanded:
                                                    true, // Ensures the dropdown fills the width
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
                                          child: RichText(
                                            text: const TextSpan(
                                              children: [
                                                TextSpan(
                                                  text: 'Unit ',
                                                  style: TextStyle(
                                                    color: Colors
                                                        .black87,
                                                    fontSize: 16,// Set the product name to black color
                                                  ),
                                                ),
                                                TextSpan(
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
                                                child:
                                                DropdownButtonHideUnderline(
                                                  child: DropdownButton<String>(
                                                    value: _selectedValue2,
                                                    onChanged:
                                                        (String? newValue) {
                                                      setState(() {
                                                        _selectedValue2 =
                                                        newValue!;
                                                      });
                                                    },
                                                    items: <String>[
                                                      widget.unitText,
                                                      'NOS   ',
                                                      'PCS   ',
                                                      'PKT    '
                                                    ].map<
                                                        DropdownMenuItem<
                                                            String>>(
                                                            (String value) {
                                                          return DropdownMenuItem<
                                                              String>(
                                                            value: value,
                                                            child: Text(value),
                                                          );
                                                        }).toList(),
                                                    icon:  Icon(Icons.arrow_drop_down_circle_rounded,color: Colors.blue[800],),
                                                    iconSize: 18,
                                                    isExpanded:
                                                    true, // Ensures the dropdown fills the width
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
                                              text:  const TextSpan(
                                                children: [
                                                  TextSpan(
                                                    text: 'Price ',
                                                    style: TextStyle(
                                                      color: Colors
                                                          .black87, // Set the product name to black color
                                                    ),
                                                  ),
                                                  TextSpan(
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
                                                contentPadding:
                                                const EdgeInsets.symmetric(
                                                    horizontal: 10,vertical: 13),
                                                border: InputBorder.none,
                                                filled: true,
                                                hintText: 'Enter Price',
                                                hintStyle: const TextStyle(color: Colors.grey),
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
                                              text:  const TextSpan(
                                                children: [
                                                  TextSpan(
                                                    text: 'Discount ',
                                                    style: TextStyle(
                                                      color: Colors
                                                          .black87,
                                                      fontSize: 16,
                                                      // Set the product name to black color
                                                    ),
                                                  ),
                                                  TextSpan(
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
                                              // initialValue:
                                              //     widget.discountInput,
                                              controller: discountController,
                                              keyboardType:
                                              TextInputType.number,
                                              inputFormatters: [
                                                FilteringTextInputFormatter
                                                    .digitsOnly,
                                                LengthLimitingTextInputFormatter(
                                                    2),
                                                // limits to 10 digits
                                              ],
                                              decoration: InputDecoration(
                                                fillColor: Colors.white,
                                                contentPadding:
                                                const EdgeInsets.symmetric(
                                                    horizontal: 10,vertical: 13),
                                                border: InputBorder.none,
                                                filled: true,
                                                hintText: 'Enter Discount',
                                                hintStyle: const TextStyle(color: Colors.grey),
                                                errorText: errorMessage,
                                              ),
                                              onChanged: (value) {
                                                if (value.isNotEmpty &&
                                                    !isNumeric(value)) {
                                                  setState(() {
                                                    ScaffoldMessenger.of(
                                                        context)
                                                        .showSnackBar(
                                                      const SnackBar(
                                                          content: Text(
                                                              "Please enter decimal number only")),
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
                              const SizedBox(height: 8),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                )

              ]);
            }else{
              return Stack(children: [

                Align(
                  // Added Align widget for the left side menu
                  alignment: Alignment.topLeft,
                  child: Container(
                    height: 1400,
                    width: 200,
                    color: const Color(0xFFF7F6FA),
                    padding: const EdgeInsets.only(left: 15, top: 10,right: 15),
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
                Container(
                    width: 1500,
                    padding: EdgeInsets.only(left: 200),
                    child: Container(
                      width: 1000,
                      height: 800,
                      child: Stack(
                          children : [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              color: const Color(0xFFFFFDFF),
                              height: 60,
                              child: Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.arrow_back), // Back button icon
                                    onPressed: () async {

                                      print('hi'
                                      );
                                      await fetchProducts();
                                      print(filteredProducts);


                                      // Debug prints for verification


                                      // Ensure that `storeImageBytes1` and `prodIdController` are not null before proceeding


                                      // print('prodId: ${prodIdController.text}');
                                      // context.go('/Edit_Product', extra: {
                                      //   'displayData': mutableProductData,
                                      //   'imagePath': storeImageBytes1! ?? '', // This is only used if not null
                                      //   'product': null,
                                      //   'productText': widget.textInput ?? '', // Default to empty string if null
                                      //   'selectedValue': widget.inputText ?? '',
                                      //   'selectedValue1': widget.subText ?? '',
                                      //   'selectedValue3': widget.taxText ?? '',
                                      //   'selectedvalue2': widget.unitText ?? '',
                                      //   'priceText': widget.priceInput ?? '',
                                      //   'discountText': widget.discountInput ?? '',
                                      //   'prodId': prodIdController.text ?? '', // Ensure prodId is being passed
                                      // });

                                    },
                                    // onPressed: () {
                                    //
                                    //
                                    //   // Debug prints for verification
                                    //
                                    //
                                    //   // Ensure that `storeImageBytes1` and `prodIdController` are not null before proceeding
                                    //
                                    //     // Ensure that the storeImage is updated
                                    //     storeImage = '';
                                    //     uploadImage(storeImage);
                                    //
                                    //     // Create a mutable copy of the unmodifiable map, ensuring the map is not null
                                    //     final mutableProductData = Map<String, dynamic>.from(widget.productData);
                                    //
                                    //     // Modify the mutable copy
                                    //     mutableProductData['imageId'] = storeImage.isEmpty ? widget.imageId : storeImage;
                                    //
                                    //     // Use the mutable map in the GoRouter navigation
                                    //   context.go('/Edit_View_Screen', extra: {
                                    //     'displayData': mutableProductData,
                                    //     'imagePath': storeImageBytes1!, // This is only used if not null
                                    //     'product': null,
                                    //     'orderDetails':filteredProducts.map((detail) => OrderDetail(
                                    //       orderId: detail.prodId,
                                    //       orderDate: detail.productName,
                                    //       orderCategory: detail.category,
                                    //       items: [],
                                    //       // Add other fields as needed
                                    //     )).toList(),
                                    //     'productText': widget.textInput ?? '', // Default to empty string if null
                                    //     'selectedValue': widget.inputText,
                                    //     'selectedValue1': widget.subText,
                                    //     'selectedValue3': widget.taxText,
                                    //     'selectedvalue2': widget.unitText,
                                    //     'priceText': widget.priceInput ?? '',
                                    //     'discountText': widget.discountInput ?? '',
                                    //     'prodId': prodIdController.text, // Ensure prodId is being passed
                                    //   });
                                    //     print('prodId: ${prodIdController.text}');
                                    //     // context.go('/Edit_Product', extra: {
                                    //     //   'displayData': mutableProductData,
                                    //     //   'imagePath': storeImageBytes1! ?? '', // This is only used if not null
                                    //     //   'product': null,
                                    //     //   'productText': widget.textInput ?? '', // Default to empty string if null
                                    //     //   'selectedValue': widget.inputText ?? '',
                                    //     //   'selectedValue1': widget.subText ?? '',
                                    //     //   'selectedValue3': widget.taxText ?? '',
                                    //     //   'selectedvalue2': widget.unitText ?? '',
                                    //     //   'priceText': widget.priceInput ?? '',
                                    //     //   'discountText': widget.discountInput ?? '',
                                    //     //   'prodId': prodIdController.text ?? '', // Ensure prodId is being passed
                                    //     // });
                                    //
                                    // },
                                  ),



                                  // IconButton(
                                  //   icon: const Icon(
                                  //       Icons.arrow_back), // Back button icon
                                  //   onPressed: () {
                                  //     print('prodId');
                                  //     print(prodIdController.text);
                                  //     storeImage = '';
                                  //     uploadImage(storeImage);
                                  //     // fetchImage(storeImage);
                                  //     widget.productData['imageId'] = storeImage == ""
                                  //         ? widget.imageId  : storeImage;
                                  //
                                  //     context.go('/Edit_Product', extra: {
                                  //       'displayData': widget.productData,
                                  //       'imagePath': storeImageBytes1!,
                                  //       'product': null,
                                  //       'productText': widget.textInput!,
                                  //       'selectedValue': widget.inputText,
                                  //       'selectedValue1': widget.subText,
                                  //       'selectedValue3': widget.taxText,
                                  //       'selectedvalue2': widget.unitText,
                                  //       'priceText': widget.priceInput!,
                                  //       'discountText': widget.discountInput!,
                                  //       'prodId': prodIdController.text,
                                  //
                                  //     });
                                  //
                                  //
                                  //   },
                                  // ),
                                  const Padding(
                                    padding: EdgeInsets.only(left: 20),
                                    child: Text(
                                      'Edit',
                                      style: TextStyle(
                                        fontSize: 25,
                                        // fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  const Spacer(),
                                  Align(
                                    alignment: Alignment.topRight,
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 15, right: 30),
                                      child: OutlinedButton(
                                        onPressed: () {
                                          _selectedValue = widget.inputText;
                                          _selectedValue1 = widget.subText;
                                          _selectedValue2 = widget.unitText;
                                          _selectedValue3 = widget.taxText;
                                          productNameController.text = widget.textInput!;
                                          priceController.text = widget.priceInput!;
                                          discountController.text = widget.discountInput!;
                                          selectedImages.clear();

                                          storeImageBytes1 = widget.imagePath;
                                          print(storeImageBytes1);
                                          print('---wel');
                                          print(widget.imageId);
                                          loadImage(widget.imageId);
                                          //uploadImage(widget.imageId);
                                        },
                                        style: OutlinedButton.styleFrom(
                                          backgroundColor:
                                          Colors.grey[300], // Blue background color
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                                5), // Rounded corners
                                          ),
                                          side: BorderSide.none, // No outline
                                        ),
                                        child: Text(
                                          'Cancel',
                                          style: TextStyle(
                                            fontSize: 14,
                                            // fontWeight: FontWeight.bold,
                                            // Increase font size if desired
                                            // Bold text
                                            color: Colors.indigo[900], // White text color
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 5,right: 30),
                                    child: OutlinedButton(
                                      onPressed: () async {
                                        if (productNameController.text.isEmpty &&
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
                                        }    else if (priceController.text.isEmpty) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text("Please Enter Price")),
                                          );
                                        } else if (discountController.text.isEmpty) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text("Please Enter Discount")),
                                          );
                                        }else{
                                          await checkSave();
                                        }

                                        //  print(storeImage);
                                        // await  checkSave(
                                        //    // productNameController.text,
                                        //    // _selectedValue!, // Replace with actual value
                                        //    // _selectedValue1!, // Replace with actual value
                                        //    // _selectedValue3!, // Replace with actual value
                                        //    // _selectedValue2!, // Replace with actual value
                                        //    // double.parse(
                                        //    //     priceController.text.toString()),
                                        //    // discountController.text,
                                        //    // storeImage,
                                        //  );
                                        //
                                        //  // fetchImage(storeImage);
                                        //
                                        //
                                        //  // showDialog(
                                        //  //   context: context,
                                        //  //   builder: (BuildContext context) {
                                        //  //     return AlertDialog(
                                        //  //       shape: const RoundedRectangleBorder(
                                        //  //           borderRadius: BorderRadius.all(Radius.circular(5))),
                                        //  //       icon: const Icon(
                                        //  //         Icons.check_circle_rounded,
                                        //  //         color: Colors.green,
                                        //  //         size: 25,
                                        //  //       ),
                                        //  //       title: const Text("Success"),
                                        //  //       content: const Padding(
                                        //  //         padding: EdgeInsets.only(left: 26),
                                        //  //         child: Text("Product Updated successfully"),
                                        //  //       ),
                                        //  //       actions: [
                                        //  //         TextButton(
                                        //  //           child: const Text("OK"),
                                        //  //           onPressed: () {
                                        //  //             //Navigator.of(context).pop();
                                        //  //             context.go('/dashboard/productpage/ontap/Edit/Update', extra: {
                                        //  //               'displayData':  widget.productData,
                                        //  //               'product': null,
                                        //  //               'imagePath': null,
                                        //  //               'productText': widget.productData['productName'],
                                        //  //               'selectedValue': widget.productData['category'],
                                        //  //               'selectedValue1': widget.productData['subCategory'],
                                        //  //               'selectedValue3': widget.productData['tax'],
                                        //  //               'selectedvalue2': widget.productData['unit'],
                                        //  //               'priceText': widget.productData['price'],
                                        //  //               'discountText': widget.productData['discount'],
                                        //  //               'prodId': widget.prodId,
                                        //  //             });
                                        //  //           },
                                        //  //         ),
                                        //  //       ],
                                        //  //     );
                                        //  //   },
                                        //  // );
                                        //
                                        //
                                        //  //old
                                        //    // checkSave(
                                        //    //   productNameController.text,
                                        //    //   _selectedValue!, // Replace with actual value
                                        //    //   _selectedValue1!, // Replace with actual value
                                        //    //   _selectedValue3!, // Replace with actual value
                                        //    //   _selectedValue2!, // Replace with actual value
                                        //    //   double.parse(
                                        //    //       priceController.text.toString()),
                                        //    //   discountController.text,
                                        //    //   storeImage,
                                        //    // );
                                        //    // uploadImage(storeImage);
                                        //    // // fetchImage(storeImage);
                                        //    // widget.productData['imageId'] =
                                        //    // storeImage == ""
                                        //    //     ? widget.imageId
                                        //    //     : storeImage;
                                        //    // widget.productData['productName'] =
                                        //    //     productNameController.text;
                                        //    // widget.productData['category'] =
                                        //    //     _selectedValue;
                                        //    // widget.productData['subCategory'] =
                                        //    //     _selectedValue1;
                                        //    // widget.productData['tax'] = _selectedValue3;
                                        //    // widget.productData['unit'] = _selectedValue2;
                                        //    // widget.productData['price'] =
                                        //    //     priceController.text;
                                        //    // widget.productData['discount'] =
                                        //    //     discountController.text;
                                        //    //
                                        //    // ScaffoldMessenger.of(context).showSnackBar(
                                        //    //   const SnackBar(
                                        //    //       content: Text(
                                        //    //           "Product updated successfully")),
                                        //    // );
                                        //    // context.go(
                                        //    //     '${PageName.subsubpage2Main}/${PageName.subpage2Main}');
                                        //    //router maha dev
                                        //


                                      },
                                      style: OutlinedButton.styleFrom(
                                        backgroundColor: Colors
                                            .blue[800], // Button background color
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              5), // Rounded corners
                                        ),
                                        side: BorderSide.none, // No outline
                                      ),
                                      child: const Text(
                                        'Save',
                                        style: TextStyle(
                                          fontSize: 14,
                                          // fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 43),
                              child: Container(
                                margin: const EdgeInsets.symmetric(
                                    vertical: 10), // Space above/below the border
                                height: 1, // Border height
                                width: 1500,
                                color: Colors.grey, // Border color
                              ),
                            ),
                            AdaptiveScrollbar(
                              position: ScrollbarPosition.bottom,
                              controller: horizontalScroll,
                              child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  controller: horizontalScroll,
                                  child:  Padding(
                                    padding: const EdgeInsets.only(left: 50,right: 50,top: 80,),
                                    child: Container(
                                      child: SingleChildScrollView(
                                        scrollDirection: Axis.vertical,
                                        child: Container(
                                          color: Colors.white,
                                          width: 1000,
                                          height: 500,
                                          child: Stack(
                                            children: [
                                              Row(
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets.only(left: 30,bottom: 20),
                                                    child: GestureDetector(
                                                      onTap: () {
                                                        print('---imagePath---');
                                                        print(imagePath);
                                                        print(selectedImage);
                                                        filePicker(context);
                                                      },
                                                      child: Card(
                                                        margin: EdgeInsets.only(left: 30, top: 120,bottom: 70),
                                                        child: Flex(
                                                          direction: Axis.vertical,
                                                          children: [
                                                            Flexible(
                                                              flex: 2,
                                                              child: Container(
                                                                width: 400,
                                                                height: 300,
                                                                decoration: BoxDecoration(
                                                                  border: Border.all(color: Colors.grey),
                                                                  color: Colors.white70,
                                                                  borderRadius: BorderRadius.circular(8),
                                                                  boxShadow: [
                                                                    BoxShadow(
                                                                      color: Colors.blue.withOpacity(0.1), // Soft grey shadow
                                                                      spreadRadius: 1,
                                                                      blurRadius: 3,
                                                                      offset: const Offset(0, 1),
                                                                    ),
                                                                  ],
                                                                ),
                                                                // decoration: BoxDecoration(
                                                                //   color: Colors.grey[300],
                                                                //   borderRadius: BorderRadius.circular(4),
                                                                // ),
                                                                child:

                                                                Stack(
                                                                  alignment: Alignment.center,
                                                                  children: [
                                                                    if (selectedImages.isEmpty)...[
                                                                      widget.imagePath!= null
                                                                          ? Opacity(
                                                                          opacity: 0.5,
                                                                          child: Image.memory(widget.imagePath!,
                                                                            fit: BoxFit.cover,
                                                                            width: 400, // Adjust as needed
                                                                            height: 300,
                                                                          ))
                                                                          : const Text("Image is Null"),
                                                                    ] else...[
                                                                      for (var imageBytes in selectedImages)
                                                                        Opacity(
                                                                          opacity: 0.3,
                                                                          child: Image.memory(
                                                                            imageBytes,
                                                                            fit: BoxFit.cover,

                                                                          ),
                                                                        ),
                                                                    ],
                                                                    Column(
                                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                                      children: [
                                                                        Icon(Icons.cloud_upload_outlined, color: Colors.blue[900], size: 50),
                                                                        const SizedBox(height: 8),
                                                                        const Text(
                                                                            'Click to upload image',
                                                                            textAlign: TextAlign.center,style: TextStyle(color: Colors.black)
                                                                        ),
                                                                        const SizedBox(height: 8),
                                                                        const Text(
                                                                          'PNG, JPG, or GIF Recommended size below 1MB',
                                                                          textAlign: TextAlign.center,style: TextStyle(color: Colors.black),
                                                                        ),
                                                                      ],
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
                                                  // Padding(
                                                  // padding: EdgeInsets.only(left: 250),
                                                  // child: GestureDetector(
                                                  // onTap: () {
                                                  // print('---imagePath---');
                                                  // print(imagePath);
                                                  // print(selectedImage);
                                                  // filePicker();
                                                  // },
                                                  // child: Card(
                                                  // margin: EdgeInsets.only(left: maxWidth * 0.08, top: maxHeight * 0.27, bottom: maxHeight * 0.29),
                                                  // child: Flex(
                                                  // direction: Axis.vertical,
                                                  // children: [
                                                  // Flexible(
                                                  // flex: 4,
                                                  // child: Container(
                                                  // width: maxWidth * 0.3,
                                                  // height: maxHeight * 1.2,
                                                  // decoration: BoxDecoration(
                                                  // border: Border.all(color: Colors.grey),
                                                  // color: Colors.white70,
                                                  // borderRadius: BorderRadius.circular(8),
                                                  // boxShadow: [
                                                  // BoxShadow(
                                                  // color: Colors.blue.withOpacity(0.1),
                                                  // spreadRadius: 1,
                                                  // blurRadius: 3,
                                                  // offset: const Offset(0, 1),
                                                  // ),
                                                  // ],
                                                  // ),
                                                  // child: Stack(
                                                  // alignment: Alignment.center,
                                                  // children: [
                                                  // // Display image
                                                  // if (selectedImages.isEmpty) ...[
                                                  // widget.imagePath != null
                                                  // ? Image.memory(
                                                  // widget.imagePath!,
                                                  // fit: BoxFit.cover,
                                                  // width: double.infinity,
                                                  // height: double.infinity,
                                                  // )
                                                  //     : const Text("Image is Null"),
                                                  // ] else ...[
                                                  // for (var imageBytes in selectedImages)
                                                  // Image.memory(
                                                  // imageBytes,
                                                  // fit: BoxFit.cover,
                                                  // width: double.infinity,
                                                  // height: double.infinity,
                                                  // ),
                                                  // ],
                                                  // // Apply blur effect over the image
                                                  // Positioned.fill(
                                                  // child: BackdropFilter(
                                                  // filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), // Adjust blur intensity
                                                  // child: Container(
                                                  // color: Colors.transparent, // Keeping container transparent to see the blur effect
                                                  // ),
                                                  // ),
                                                  // ),
                                                  // // Overlaying text content
                                                  // Column(
                                                  // mainAxisAlignment: MainAxisAlignment.center,
                                                  // children: [
                                                  // Icon(Icons.cloud_upload_outlined, color: Colors.white, size: 50),
                                                  // const SizedBox(height: 8),
                                                  // const Text(
                                                  // 'Click to upload image',
                                                  // textAlign: TextAlign.center,
                                                  // style: TextStyle(
                                                  // color: Colors.white,
                                                  // fontSize: 16,
                                                  // ),
                                                  // ),
                                                  // const SizedBox(height: 8),
                                                  // const Text(
                                                  // 'PNG, JPG, or GIF\nRecommended size below 1MB',
                                                  // textAlign: TextAlign.center,
                                                  // style: TextStyle(
                                                  // color: Colors.white,
                                                  // fontSize: 12,
                                                  // ),
                                                  // ),
                                                  // ],
                                                  // ),
                                                  // ],
                                                  // ),
                                                  // ),
                                                  // ),
                                                  // ],
                                                  // ),
                                                  // ),
                                                  // ),
                                                  // ),


                                                  // Padding(
                                                  //   padding: EdgeInsets.only(left: 250),
                                                  //   child: GestureDetector(
                                                  //     onTap: () {
                                                  //       print('---imagePath---');
                                                  //       print(imagePath);
                                                  //       print(selectedImage);
                                                  //       filePicker();
                                                  //     },
                                                  //     child: Card(
                                                  //       margin: EdgeInsets.only(left: maxWidth * 0.08, top: maxHeight * 0.27, bottom: maxHeight * 0.29),
                                                  //       child: Flex(
                                                  //         direction: Axis.vertical,
                                                  //         children: [
                                                  //           Flexible(
                                                  //             flex: 4,
                                                  //             child: Container(
                                                  //               width: maxWidth * 0.3,
                                                  //               height: maxHeight * 1.2,
                                                  //               decoration: BoxDecoration(
                                                  //                 border: Border.all(color: Colors.grey),
                                                  //                 color: Colors.white70,
                                                  //                 borderRadius: BorderRadius.circular(8),
                                                  //                 boxShadow: [
                                                  //                   BoxShadow(
                                                  //                     color: Colors.blue.withOpacity(0.1), // Soft grey shadow
                                                  //                     spreadRadius: 1,
                                                  //                     blurRadius: 3,
                                                  //                     offset: const Offset(0, 1),
                                                  //                   ),
                                                  //                 ],
                                                  //               ),
                                                  //               // decoration: BoxDecoration(
                                                  //               //   color: Colors.grey[300],
                                                  //               //   borderRadius: BorderRadius.circular(4),
                                                  //               // ),
                                                  //               child: Stack(
                                                  //                 alignment: Alignment.center,
                                                  //                 children: [
                                                  //                   if (selectedImages.isEmpty)...[
                                                  //                     widget.imagePath!= null
                                                  //                         ? Image.memory(widget.imagePath!)
                                                  //                         : const Text("Image is Null"),
                                                  //                   ] else...[
                                                  //                     for (var imageBytes in selectedImages)
                                                  //                       Image.memory(
                                                  //                         imageBytes,
                                                  //                         fit: BoxFit.cover,
                                                  //                         width: 300, // Adjust as needed
                                                  //                         height: 300, // Adjust as needed
                                                  //                       ),
                                                  //                   ],
                                                  //                   Column(
                                                  //                     mainAxisAlignment: MainAxisAlignment.center,
                                                  //                     children: [
                                                  //                       Icon(Icons.cloud_upload_outlined, color: Colors.blue[900], size: 50),
                                                  //                       const SizedBox(height: 8),
                                                  //                       const Text(
                                                  //                         'Click to upload image',
                                                  //                         textAlign: TextAlign.center,
                                                  //                       ),
                                                  //                       const SizedBox(height: 8),
                                                  //                       const Text(
                                                  //                         'PNG, JPG, or GIF Recommended size below 1MB',
                                                  //                         textAlign: TextAlign.center,
                                                  //                         style: TextStyle(fontSize: 12),
                                                  //                       ),
                                                  //                     ],
                                                  //                   ),
                                                  //                 ],
                                                  //               ),
                                                  //             ),
                                                  //           ),
                                                  //         ],
                                                  //       ),
                                                  //     ),
                                                  //   ),
                                                  // ),

                                                  const SizedBox( height: 10,),
                                                  Expanded(
                                                    child: Card(
                                                      margin: EdgeInsets.only(left:80, top: 60
                                                          ,right: 100  ,bottom: 10),
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
                                                                Padding(
                                                                  padding: const EdgeInsets.all(4.0),
                                                                  child: RichText(
                                                                    text:  const TextSpan(
                                                                      children: [
                                                                        TextSpan(
                                                                          text: 'Product Name ',
                                                                          style: TextStyle(
                                                                            color: Colors.black87,
                                                                            fontSize: 16,/// Set the product name to black color
                                                                          ),
                                                                        ),
                                                                        TextSpan(
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
                                                                const SizedBox(height: 2),
                                                                Padding(
                                                                  padding: const EdgeInsets.all(8.0),
                                                                  child: Container(
                                                                    height: 40,
                                                                    width: constraints.maxWidth * 0.7,
                                                                    decoration: BoxDecoration(
                                                                      color: Colors.white,
                                                                      borderRadius: BorderRadius.circular(2),
                                                                      border: Border.all(
                                                                          color: Colors.blue[100]!),
                                                                    ),
                                                                    child: TextFormField(
                                                                      // LAST ONE
                                                                      //initialValue: widget.textInput,
                                                                      controller: productNameController,
                                                                      decoration: InputDecoration(
                                                                        fillColor: Colors.white,
                                                                        contentPadding:
                                                                        const EdgeInsets.symmetric(
                                                                            horizontal: 10,vertical: 13),
                                                                        border: InputBorder.none,
                                                                        filled: true,
                                                                        hintText: 'Enter Product Name',
                                                                        hintStyle: const TextStyle(color: Colors.grey),
                                                                        errorText: errorMessage,
                                                                      ),
                                                                      inputFormatters: [
                                                                        // FilteringTextInputFormatter.allow(
                                                                        //     RegExp("[a-zA-Z0-9 ]")),
                                                                        // Allow only letters, numbers, and single space
                                                                        FilteringTextInputFormatter.deny(
                                                                            RegExp(r'^\s')),
                                                                        // Disallow starting with a space
                                                                        FilteringTextInputFormatter.deny(
                                                                            RegExp(r'\s\s')),
                                                                        // Disallow multiple spaces
                                                                      ],
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
                                                                      //     checkSave();
                                                                      //   }
                                                                      //   return null;
                                                                      // },
                                                                      minLines: 1,
                                                                      maxLines: 1,
                                                                      // expands: true,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),

                                                            Row(
                                                              children: [
                                                                Flexible(
                                                                  flex: 2,
                                                                  child: Column(
                                                                    crossAxisAlignment:
                                                                    CrossAxisAlignment.start,
                                                                    children: [
                                                                      Padding(
                                                                        padding: const EdgeInsets.all(4.0),
                                                                        child: Align(
                                                                          alignment: const  Alignment(-1.0,-0.3),

                                                                          child: RichText(
                                                                            text:  const TextSpan(
                                                                              children: [
                                                                                TextSpan(
                                                                                  text: 'Category ',
                                                                                  style: TextStyle(
                                                                                    color: Colors.black87,
                                                                                    fontSize: 16,//// Set the product name to black color
                                                                                  ),
                                                                                ),
                                                                                TextSpan(
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
                                                                              child:
                                                                              DropdownButtonHideUnderline(
                                                                                child: DropdownButton<String>(
                                                                                  value: _selectedValue,
                                                                                  onChanged:
                                                                                      (String? newValue) {
                                                                                    setState(() {
                                                                                      _selectedValue =
                                                                                      newValue!;
                                                                                    });
                                                                                  },
                                                                                  items: <String>[
                                                                                    widget.inputText,
                                                                                    'Select 1',
                                                                                    'Select 2',
                                                                                    'Select 3'
                                                                                  ].map<
                                                                                      DropdownMenuItem<
                                                                                          String>>(
                                                                                          (String value) {
                                                                                        return DropdownMenuItem<
                                                                                            String>(
                                                                                          value: value,
                                                                                          child: Text(value),
                                                                                        );
                                                                                      }).toList(),
                                                                                  icon:  Icon(Icons.arrow_drop_down_circle_rounded,color: Colors.blue[800],),
                                                                                  iconSize: 18,
                                                                                  isExpanded:
                                                                                  true, // Ensures the dropdown fills the width
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
                                                                Flexible(
                                                                  flex: 2,
                                                                  child: Column(
                                                                    crossAxisAlignment:
                                                                    CrossAxisAlignment.start,
                                                                    children: [
                                                                      Padding(
                                                                        padding: const EdgeInsets.all(4.0),
                                                                        child: Align(
                                                                          alignment: const Alignment(-1.0,-0.3),
                                                                          child: RichText(
                                                                            text:  const TextSpan(
                                                                              children: [
                                                                                TextSpan(
                                                                                  text: 'Sub Category ',
                                                                                  style: TextStyle(
                                                                                    color: Colors
                                                                                        .black87, //
                                                                                    fontSize: 16,// Set the product name to black color
                                                                                  ),
                                                                                ),
                                                                                TextSpan(
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
                                                                              child:
                                                                              DropdownButtonHideUnderline(
                                                                                child: DropdownButton<String>(
                                                                                  value: _selectedValue1,
                                                                                  onChanged:
                                                                                      (String? newValue) {
                                                                                    setState(() {
                                                                                      _selectedValue1 =
                                                                                      newValue!;
                                                                                    });
                                                                                  },
                                                                                  items: <String>[
                                                                                    widget.subText,
                                                                                    'Yes',
                                                                                    'No'
                                                                                  ].map<
                                                                                      DropdownMenuItem<
                                                                                          String>>(
                                                                                          (String value) {
                                                                                        return DropdownMenuItem<
                                                                                            String>(
                                                                                          value: value,
                                                                                          child: Text(value),
                                                                                        );
                                                                                      }).toList(),
                                                                                  icon:  Icon(Icons.arrow_drop_down_circle_rounded,color: Colors.blue[800],),
                                                                                  iconSize: 18,
                                                                                  isExpanded: true, // Ensures the dropdown fills the width
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
                                                                        child: RichText(
                                                                          text:  const TextSpan(
                                                                            children: [
                                                                              TextSpan(
                                                                                text: 'Tax ',
                                                                                style: TextStyle(
                                                                                  color: Colors
                                                                                      .black87,
                                                                                  fontSize: 16,// Set the product name to black color
                                                                                ),
                                                                              ),
                                                                              TextSpan(
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
                                                                              child:
                                                                              DropdownButtonHideUnderline(
                                                                                child: DropdownButton<String>(
                                                                                  value: _selectedValue3,
                                                                                  onChanged:
                                                                                      (String? newValue) {
                                                                                    setState(() {
                                                                                      _selectedValue3 =
                                                                                      newValue!;
                                                                                    });
                                                                                  },
                                                                                  items: <String>[
                                                                                    widget.taxText,
                                                                                    '12%    ',
                                                                                    '18%    ',
                                                                                    '20%    ',
                                                                                    '10%    '
                                                                                  ].map<
                                                                                      DropdownMenuItem<
                                                                                          String>>(
                                                                                          (String value) {
                                                                                        return DropdownMenuItem<
                                                                                            String>(
                                                                                          value: value,
                                                                                          child: Text(value),
                                                                                        );
                                                                                      }).toList(),
                                                                                  icon:  Icon(Icons.arrow_drop_down_circle_rounded,color: Colors.blue[800],),
                                                                                  iconSize: 18,
                                                                                  isExpanded:
                                                                                  true, // Ensures the dropdown fills the width
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
                                                                        child: RichText(
                                                                          text: const TextSpan(
                                                                            children: [
                                                                              TextSpan(
                                                                                text: 'Unit ',
                                                                                style: TextStyle(
                                                                                  color: Colors
                                                                                      .black87,
                                                                                  fontSize: 16,// Set the product name to black color
                                                                                ),
                                                                              ),
                                                                              TextSpan(
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
                                                                              child:
                                                                              DropdownButtonHideUnderline(
                                                                                child: DropdownButton<String>(
                                                                                  value: _selectedValue2,
                                                                                  onChanged:
                                                                                      (String? newValue) {
                                                                                    setState(() {
                                                                                      _selectedValue2 =
                                                                                      newValue!;
                                                                                    });
                                                                                  },
                                                                                  items: <String>[
                                                                                    widget.unitText,
                                                                                    'NOS   ',
                                                                                    'PCS   ',
                                                                                    'PKT    '
                                                                                  ].map<
                                                                                      DropdownMenuItem<
                                                                                          String>>(
                                                                                          (String value) {
                                                                                        return DropdownMenuItem<
                                                                                            String>(
                                                                                          value: value,
                                                                                          child: Text(value),
                                                                                        );
                                                                                      }).toList(),
                                                                                  icon:  Icon(Icons.arrow_drop_down_circle_rounded,color: Colors.blue[800],),
                                                                                  iconSize: 18,
                                                                                  isExpanded:
                                                                                  true, // Ensures the dropdown fills the width
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
                                                                            text:  const TextSpan(
                                                                              children: [
                                                                                TextSpan(
                                                                                  text: 'Price ',
                                                                                  style: TextStyle(
                                                                                    color: Colors
                                                                                        .black87, // Set the product name to black color
                                                                                  ),
                                                                                ),
                                                                                TextSpan(
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
                                                                              contentPadding:
                                                                              const EdgeInsets.symmetric(
                                                                                  horizontal: 10,vertical: 13),
                                                                              border: InputBorder.none,
                                                                              filled: true,
                                                                              hintText: 'Enter Price',
                                                                              hintStyle: const TextStyle(color: Colors.grey),
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
                                                                            text:  const TextSpan(
                                                                              children: [
                                                                                TextSpan(
                                                                                  text: 'Discount ',
                                                                                  style: TextStyle(
                                                                                    color: Colors
                                                                                        .black87,
                                                                                    fontSize: 16,
                                                                                    // Set the product name to black color
                                                                                  ),
                                                                                ),
                                                                                TextSpan(
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
                                                                            // initialValue:
                                                                            //     widget.discountInput,
                                                                            controller: discountController,
                                                                            keyboardType:
                                                                            TextInputType.number,
                                                                            inputFormatters: [
                                                                              FilteringTextInputFormatter
                                                                                  .digitsOnly,
                                                                              LengthLimitingTextInputFormatter(
                                                                                  2),
                                                                              // limits to 10 digits
                                                                            ],
                                                                            decoration: InputDecoration(
                                                                              fillColor: Colors.white,
                                                                              contentPadding:
                                                                              const EdgeInsets.symmetric(
                                                                                  horizontal: 10,vertical: 13),
                                                                              border: InputBorder.none,
                                                                              filled: true,
                                                                              hintText: 'Enter Discount',
                                                                              hintStyle: const TextStyle(color: Colors.grey),
                                                                              errorText: errorMessage,
                                                                            ),
                                                                            onChanged: (value) {
                                                                              if (value.isNotEmpty &&
                                                                                  !isNumeric(value)) {
                                                                                setState(() {
                                                                                  ScaffoldMessenger.of(
                                                                                      context)
                                                                                      .showSnackBar(
                                                                                    const SnackBar(
                                                                                        content: Text(
                                                                                            "Please enter decimal number only")),
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
                                                            const SizedBox(height: 8),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                              ),
                            )

                          ]
                      ),
                    )
                )


              ]);
            }



          },
        ), // Use the ProductForm widget here
      ),
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

