// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// void main(){
//   runApp(MaterialApp(home: SidebarMenu(),));
// }
// class SidebarMenu extends StatefulWidget {
//   @override
//   _SidebarMenuState createState() => _SidebarMenuState();
// }
//
// class _SidebarMenuState extends State<SidebarMenu> {
//   // Create a map to store hover states for each button
//   Map<String, bool> _isHovered = {
//     'Home': false,
//     'Products': false,
//     'Orders': false,
//     'Invoice': false,
//     'Delivery': false,
//     'Payment': false,
//     'Return': false,
//     'Reports': false,
//   };
//
//   @override
//   Widget build(BuildContext context) {
//     return Align(
//       alignment: Alignment.topLeft,
//       child: Container(
//         width: 200,
//         height: 984,
//         color: const Color(0xFFF7F6FA),
//         padding: const EdgeInsets.only(left: 5, top: 30),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: _buildMenuItems(context),
//         ),
//       ),
//     );
//   }
//
//   List<Widget> _buildMenuItems(BuildContext context) {
//     return [
//       _buildMenuItem('Home', Icons.dashboard, Colors.indigo[900]!, '/Home'),
//       _buildMenuItem('Products', Icons.image_outlined, Colors.indigo[900]!, '/Product_List'),
//       _buildMenuItem('Orders', Icons.warehouse, Colors.blue[900]!, '/Order_List'),
//       _buildMenuItem('Invoice', Icons.document_scanner_rounded, Colors.blue[900]!, '/Invoice'),
//       _buildMenuItem('Delivery', Icons.fire_truck_outlined, Colors.blue[900]!, '/Delivery_List'),
//       _buildMenuItem('Payment', Icons.payment_outlined, Colors.blueAccent, '/Payment_List'),
//       _buildMenuItem('Return', Icons.backspace_sharp, Colors.blue[900]!, '/Return_List'),
//       _buildMenuItem('Reports', Icons.insert_chart, Colors.blue[900]!, '/Report_List'),
//     ];
//   }
//
//   Widget _buildMenuItem(String title, IconData icon, Color iconColor, String route) {
//     return MouseRegion(
//       cursor: SystemMouseCursors.click,
//       onEnter: (_) => setState(() => _isHovered[title] = true),
//       onExit: (_) => setState(() => _isHovered[title] = false),
//       child: GestureDetector(
//         onTap: () {
//           context.go(route);
//         },
//         child: Container(
//           margin: const EdgeInsets.only(bottom: 10,right: 20),
//           padding: const EdgeInsets.symmetric(vertical: 8),
//           decoration: BoxDecoration(
//             color: _isHovered[title]! ? Colors.blue.withOpacity(0.1) : Colors.transparent,
//             borderRadius: BorderRadius.circular(8),
//           ),
//           child: Row(
//             children: [
//               Icon(icon, color: iconColor),
//               const SizedBox(width: 10),
//               Text(
//                 title,
//                 style: TextStyle(
//                   color: iconColor,
//                   fontSize: 16,
//                   decoration: TextDecoration.none, // Remove underline
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

void main() {
  runApp(ProductFormApp());
}

class ProductFormApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.indigoAccent),
          ),
        ),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Add Product'),
          backgroundColor: Colors.indigo,
        ),
        body: ProductForm(),
      ),
    );
  }
}

class ProductForm extends StatefulWidget {
  @override
  _ProductFormState createState() => _ProductFormState();
}

class _ProductFormState extends State<ProductForm> {
  final _formKey = GlobalKey<FormState>();
  File? _image;
  final ImagePicker _picker = ImagePicker();

  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _discountController = TextEditingController();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImageUploadSection(),
            SizedBox(height: 20),
            _buildInputSection('Product Information', [
              _buildTextFormField('Product Name', _productNameController),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildDropdown('Category', ['Electronics', 'Clothing'])),
                  SizedBox(width: 16),
                  Expanded(child: _buildDropdown('Sub Category', ['Phones', 'Laptops'])),
                ],
              ),
            ]),
            SizedBox(height: 20),
            _buildInputSection('Pricing', [
              Row(
                children: [
                  Expanded(child: _buildTextFormField('Price', _priceController)),
                  SizedBox(width: 16),
                  Expanded(child: _buildTextFormField('Discount', _discountController)),
                ],
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildDropdown('Tax', ['5%', '18%'])),
                  SizedBox(width: 16),
                  Expanded(child: _buildDropdown('Unit', ['Piece', 'Kg'])),
                ],
              ),
            ]),
            SizedBox(height: 30),
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  // Image Upload Section
  Widget _buildImageUploadSection() {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        height: 180,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey[300]!, width: 1),
        ),
        child: _image == null
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_a_photo, size: 50, color: Colors.grey[400]),
              SizedBox(height: 8),
              Text('Upload Product Image', style: TextStyle(color: Colors.grey[400])),
            ],
          ),
        )
            : ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.file(
            _image!,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  // Section with Header and Inputs
  Widget _buildInputSection(String header, List<Widget> inputs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(header, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo)),
        SizedBox(height: 12),
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: inputs,
          ),
        ),
      ],
    );
  }

  // TextFormField Builder
  Widget _buildTextFormField(String label, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey[600]),
      ),
    );
  }

  // Dropdown Builder
  Widget _buildDropdown(String label, List<String> items) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
      ),
      items: items.map((item) {
        return DropdownMenuItem(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: (value) {},
    );
  }

  // Save Button
  Widget _buildSaveButton() {
    return Center(
      child: ElevatedButton.icon(
        onPressed: () {
          // Save action
        },
        icon: Icon(Icons.save, color: Colors.white),
        label: Text('Save Product'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.indigo,
          padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
          textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}




