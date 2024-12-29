class ProductData {
  late final String productName;
  final String category;
  final String subCategory;
  final String tax;
  final String unit;
  final String price;
  final String discount;

  ProductData({
    required this.productName,
    required this.category,
    required this.subCategory,
    required this.tax,
    required this.unit,
    required this.price,
    required this.discount,
  });

  factory ProductData.fromJson(Map<String, dynamic> json) {
    return ProductData(
      category: json['category'] ?? '',
      productName: json['productName'] ?? '',
      subCategory: json['subCategory'] ?? '',
      unit: json['unit'] ?? '',
      tax: json['tax'] ?? '',
      discount: json['discount'] ?? '',
      price: json['price'] ?? 0,
    );
  }
}
