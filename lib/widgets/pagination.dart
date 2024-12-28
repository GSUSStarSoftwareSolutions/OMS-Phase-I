import 'package:flutter/material.dart';
class PaginationControls extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final VoidCallback onPreviousPage;
  final VoidCallback onNextPage;

  PaginationControls({
    required this.currentPage,
    required this.totalPages,
    required this.onPreviousPage,
    required this.onNextPage,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: Icon(Icons.chevron_left),
          onPressed: currentPage > 1 ? onPreviousPage : null,
        ),
        Text('Page $currentPage of $totalPages'),
        IconButton(
          icon: Icon(Icons.chevron_right),
          onPressed: currentPage < totalPages ? onNextPage : null,
        ),
      ],
    );
  }
}