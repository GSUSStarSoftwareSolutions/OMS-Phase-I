void main() {
  // Manual total amount
  double totalAmount = 1000.0;

  // Discount percentage
  double discountPercentage = 10.0;

  // GST percentage
  double gstPercentage = 18.0;

  // Calculate discount
  double discount = (totalAmount * discountPercentage) / 100;
  double amountAfterDiscount = totalAmount - discount;

  // Calculate GST
  double gst = (amountAfterDiscount * gstPercentage) / 100;
  double finalAmount = amountAfterDiscount + gst;

  print('Manual Total Amount: ₹$totalAmount');
  print('Discount: ₹$discount ({$discountPercentage}%)');
  print('Amount After Discount: ₹$amountAfterDiscount');
  print('GST: ₹$gst ({$gstPercentage}%)');
  print('Final Amount: ₹$finalAmount');
}