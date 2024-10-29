import 'package:flutter/material.dart';
class PaginationControls extends StatelessWidget {
  final int currentPage;
  final int totalPages;
 // final VoidCallback onFirstPage;
  final VoidCallback onPreviousPage;
  final VoidCallback onNextPage;
 // final VoidCallback onLastPage;

  PaginationControls({
    required this.currentPage,
    required this.totalPages,
    //required this.onFirstPage,
    required this.onPreviousPage,
    required this.onNextPage,
    //required this.onLastPage,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // IconButton(
        //   icon: Icon(Icons.first_page),
        //   onPressed: currentPage > 1 ? onFirstPage : null,
        // ),
        IconButton(
          icon: Icon(Icons.chevron_left),
          onPressed: currentPage > 1 ? onPreviousPage : null,
        ),
        Text('Page $currentPage of $totalPages'),
        IconButton(
          icon: Icon(Icons.chevron_right),
          onPressed: currentPage < totalPages ? onNextPage : null,
        ),
        // IconButton(
        //   icon: Icon(Icons.last_page),
        //   onPressed: currentPage < totalPages ? onLastPage : null,
        // ),
      ],
    );
  }
}