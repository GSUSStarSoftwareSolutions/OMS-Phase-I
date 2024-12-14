class ProductData {
  final String product;
  final String categoryName;
  final String productType;
  final String baseUnit;
  final String productDescription;
  final String standardPrice;
  final String currency;

  ProductData({
    required this.product,
    required this.categoryName,
    required this.productType,
    required this.baseUnit,
    required this.productDescription,
    required this.standardPrice,
    required this.currency,
  });

  // Factory method to create a Product object from JSON data
  factory ProductData.fromJson(Map<String, dynamic> json) {
    return ProductData(
      product: json['Product'] ?? '',
      categoryName: json['CategoryName'] ?? '',
      productType: json['ProductType'] ?? '',
      baseUnit: json['BaseUnit'] ?? '',
      productDescription: json['ProductDescription'] ?? '',
      standardPrice: json['currency'] ?? '',
      currency: json['StandardPrice'] ?? '',
    );
  }
}


class BusinessPartnerData {
  final String businessPartner;
  final String businessPartnerName;
  final String customer;
  final String addressID;
  final String cityName;
  final String postalCode;
  final String streetName;
  final String region;
  final String telephoneNumber1;
  final String country;
  final String districtName;
  final String emailAddress;
  final String mobilePhoneNumber;

  BusinessPartnerData({
    required this.businessPartner,
    required this.businessPartnerName,
    required this.customer,
    required this.addressID,
    required this.cityName,
    required this.postalCode,
    required this.streetName,
    required this.region,
    required this.telephoneNumber1,
    required this.country,
    required this.districtName,
    required this.emailAddress,
    required this.mobilePhoneNumber,
  });

  // Factory method to create a BusinessPartnerData object from JSON data
  factory BusinessPartnerData.fromJson(Map<String, dynamic> json) {
    return BusinessPartnerData(
      businessPartner: json['BusinessPartner'] ?? '',
      businessPartnerName: json['BusinessPartnerName'] ?? '',
      customer: json['Customer'] ?? '',
      addressID: json['AddressID'] ?? '',
      cityName: json['CityName'] ?? '',
      postalCode: json['PostalCode'] ?? '',
      streetName: json['StreetName'] ?? '',
      region: json['Region'] ?? '',
      telephoneNumber1: json['TelephoneNumber1'] ?? '',
      country: json['Country'] ?? '',
      districtName: json['DistrictName'] ?? '',
      emailAddress: json['EmailAddress'] ?? '',
      mobilePhoneNumber: json['MobilePhoneNumber'] ?? '',
    );
  }
}
