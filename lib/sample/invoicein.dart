import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    home: InvoiceList(),
  ));
}

class InvoiceList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),  // Light background
      appBar: AppBar(
        title: Text('Invoice List'),
        backgroundColor: Colors.indigo.shade600, // Professional dark accent color
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildSearchAndFilterBar(),  // Floating search bar and filters
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: [
                  // Sample invoice rows with card design
                  _buildInvoiceCard("INV_04468", "ORD_04468", "30/09/2024", "Delivered", 39424, true),
                  _buildInvoiceCard("INV_04487", "ORD_04487", "30/09/2024", "Delivered", 254091.09, true),
                  _buildInvoiceCard("INV_04491", "ORD_04491", "01/10/2024", "Delivered", 39429.61, true),
                  _buildInvoiceCard("INV_04519", "ORD_04519", "01/10/2024", "Not Started", 84689.74, false),
                  // Add more rows if needed
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Floating search and filter bar with better design and spacing
  Widget _buildSearchAndFilterBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search by Invoice No',
                border: InputBorder.none,
                icon: Icon(Icons.search, color: Colors.grey),
              ),
            ),
          ),
          SizedBox(width: 20),
          DropdownButton<String>(
            hint: Text('Status'),
            items: ['All', 'Delivered', 'Not Started']
                .map((status) => DropdownMenuItem<String>(
              value: status,
              child: Text(status),
            ))
                .toList(),
            onChanged: (value) {},
          ),
          SizedBox(width: 20),
          DropdownButton<String>(
            hint: Text('Year'),
            items: ['2023', '2024', '2025']
                .map((year) => DropdownMenuItem<String>(
              value: year,
              child: Text(year),
            ))
                .toList(),
            onChanged: (value) {},
          ),
        ],
      ),
    );
  }

  // Card-based invoice row for better visual hierarchy and spacing
  Widget _buildInvoiceCard(String invoiceNo, String orderId, String date, String status, double amount, bool delivered) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,  // Creates depth with shadow
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildInvoiceColumn('Invoice No', invoiceNo),
            _buildInvoiceColumn('Order ID', orderId),
            _buildInvoiceColumn('Date', date),
            _buildInvoiceColumn('Amount', '\$${amount.toStringAsFixed(2)}'),
            _buildStatusChip(status, delivered), // Status badge with icon
            _buildPdfButton(),  // Interactive PDF button
          ],
        ),
      ),
    );
  }

  // Helper function to build a column with label and value
  Widget _buildInvoiceColumn(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
          const SizedBox(height: 5),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }

  // Custom status chip with color and icon for better readability
  Widget _buildStatusChip(String status, bool delivered) {
    return Chip(
      label: Text(
        status,
        style: TextStyle(
          color: delivered ? Colors.green : Colors.red,
          fontWeight: FontWeight.bold,
        ),
      ),
      avatar: delivered
          ? Icon(Icons.check_circle, color: Colors.green)
          : Icon(Icons.error, color: Colors.red),
      backgroundColor: delivered ? Colors.green.shade50 : Colors.red.shade50,
    );
  }

  // PDF icon button with hover and click effects
  Widget _buildPdfButton() {
    return IconButton(
      icon: Icon(Icons.picture_as_pdf, color: Colors.red),
      onPressed: () {
        // Add functionality for PDF download
      },
    );
  }
}
