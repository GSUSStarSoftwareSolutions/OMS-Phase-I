//import '../sprint 2 order/add productmaster sample.dart';



class Product {

  @override
  String toString() {
    return 'Product{proId: $prodId, productName: $productName, category: $category, subCategory: $subCategory, price: $price, tax: $tax, unit: $unit, discount: $discount, selectedUOM: $selectedUOM, selectedVariation: $selectedVariation, quantity: $quantity, qty: $qty, totalAmount: $totalAmount, total: $total, totalamount: $totalamount}';
  }
  final String prodId;
  final String? proId;
  final String productName;
  String subCategory;
  String category;
  final String unit;
  final String tax;
  final String discount;
  final int price;
  String? selectedUOM;
  double totalamount;
  String? selectedVariation;
  int quantity;
  int qty;
  double total;
  double totalAmount;
  final String imageId;

  Product(

      {required this.prodId,
      required this.category,
        this.proId,
        required this.productName,
      required this.subCategory,
      required this.unit,
        required this.qty,
        required this.selectedUOM,
        required this.selectedVariation,
        required this.quantity,
        required this.total,
        required this.totalAmount,
        required this.totalamount,
      required this.tax,
      required this.discount,
      required this.price,
      required this.imageId});

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      prodId: json['prodId'] ?? '',
      category: json['category'] ?? '',
      productName: json['productName'] ?? '',
      subCategory: json['subCategory'] ?? '',
      unit: json['unit'] ?? '',
      qty: (json['qty'] is String ? int.tryParse(json['qty']): json['qty'] ?? 0),
      tax: json['tax'] ?? '',
      quantity: (json['quantity'] is String? int.tryParse(json['quantity']) : json['quantity'])?? 0,
      total: (json['total'] is String? double.tryParse(json['total']) : json['total'])?? 0.0,
      totalAmount: (json['totalAmount'] is String? double.tryParse(json['totalAmount']) : json['totalAmount'])?? 0.0,
      discount: json['discount'] ?? '',
      totalamount: (json['totalamount'] is String? double.tryParse(json['totalamount']) : json['totalamount'])?? 0.0,
      selectedUOM: json['uom']?? 'Select',
      selectedVariation: json['variation']?? 'Select',
      price: json['price'] ?? 0,
      imageId: json['imageId'] ?? '',
      proId: json['proId']?? '',
    );
  }
  Map<String, dynamic> asMap() {
    return {
      'proId': proId,
      'productName': productName,
      'category': category,
      'subCategory': subCategory,
      'price': price,
      'qty': qty,
      'totalAmount':totalAmount,
      'tax': tax,
      'unit': unit,
      'imageId': imageId,
      'discount': discount,
      'electedUOM': selectedUOM,
      'electedVariation': selectedVariation,
      'quantity': quantity == 0 ? quantity: qty,
      'total': total,
      'totalamount':totalamount,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'prodId': prodId,
      'productName': productName,
      'imageId': imageId,
      'subCategory': subCategory,
      'selectedUOM': selectedUOM,
      'selectedVariation': selectedVariation,
      'totalamount': totalamount,
      'total': total,
      'tax': tax,
      'totalAmount': totalAmount,
      'imageId': imageId,
      'unit': unit,
      'discount': discount,
      'category': category,
      'price': price,
      'qty': qty,
      'quantity': quantity,
    };
  }





}




