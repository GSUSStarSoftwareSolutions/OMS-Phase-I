// import 'package:flutter/material.dart';
//
// void main() {
//   runApp(MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//  return MaterialApp(
//       home: Scaffold(
//         appBar: AppBar(
//           title: Text('Resizable & Draggable Table with Filters'),
//         ),
//         body: ResizableDraggableTable(),
//       ),
//     );
//   }
// }
//
// class ResizableDraggableTable extends StatefulWidget {
//   @override
//   _ResizableDraggableTableState createState() => _ResizableDraggableTableState();
// }
//
// class _ResizableDraggableTableState extends State<ResizableDraggableTable> {
//   List<String> columns = ['Name', 'Age', 'Gender'];
//   List<double> columnWidths = [150.0, 100.0, 120.0];
//
//   // Sorting state for each column: true = ascending, false = descending
//   List<bool> columnSortState = [true, true, true];
//
//   // Sample data
//   List<Map<String, dynamic>> rows = [
//     {'Name': 'Alice', 'Age': 25, 'Gender': 'Female'},
//     {'Name': 'Bob', 'Age': 30, 'Gender': 'Male'},
//     {'Name': 'Charlie', 'Age': 22, 'Gender': 'Male'},
//   ];
//
//   // Handle column sorting (A-Z or Z-A)
//   void sortColumn(int index) {
//     setState(() {
//       columnSortState[index] = !columnSortState[index];
//       rows.sort((a, b) {
//         if (columnSortState[index]) {
//           return a[columns[index]].toString().compareTo(b[columns[index]].toString());
//         } else {
//           return b[columns[index]].toString().compareTo(a[columns[index]].toString());
//         }
//       });
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         // Build column headers with draggable, resizable, and filter functionality
//         Row(
//           children: List.generate(columns.length, (index) {
//             return buildDraggableResizableHeader(index);
//           }),
//         ),
//         // Build rows
//         Expanded(
//           child: ListView(
//             children: rows.map((row) {
//               return Row(
//                 children: List.generate(columns.length, (index) {
//                   return Container(
//                     width: columnWidths[index],
//                     padding: EdgeInsets.all(8.0),
//                     child: Text(row[columns[index]].toString()),
//                   );
//                 }),
//               );
//             }).toList(),
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget buildDraggableResizableHeader(int index) {
//     return GestureDetector(
//       onHorizontalDragUpdate: (details) {
//         setState(() {
//           columnWidths[index] += details.delta.dx;
//           columnWidths[index] = columnWidths[index].clamp(50.0, 300.0); // Prevent too small or too large
//         });
//       },
//       child: DragTarget<int>(
//         onAccept: (draggedIndex) {
//           setState(() {
//             // Swap the columns when a column is dropped on another column
//             final tempColumn = columns[index];
//             columns[index] = columns[draggedIndex];
//             columns[draggedIndex] = tempColumn;
//
//             // Swap the widths accordingly
//             final tempWidth = columnWidths[index];
//             columnWidths[index] = columnWidths[draggedIndex];
//             columnWidths[draggedIndex] = tempWidth;
//
//             // Swap the sorting states accordingly
//             final tempSort = columnSortState[index];
//             columnSortState[index] = columnSortState[draggedIndex];
//             columnSortState[draggedIndex] = tempSort;
//           });
//         },
//         builder: (context, candidateData, rejectedData) {
//           return Draggable<int>(
//             data: index,
//             feedback: Material(
//               color: Colors.transparent,
//               child: Container(
//                 width: columnWidths[index],
//                 height: 50.0,
//                 alignment: Alignment.center,
//                 child: Text(
//                   columns[index],
//                   style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//                 ),
//                 color: Colors.grey[400],
//               ),
//             ),
//             childWhenDragging: Container(
//               width: columnWidths[index],
//               height: 50.0,
//               alignment: Alignment.center,
//               child: Text(
//                 columns[index],
//                 style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//               ),
//               color: Colors.grey[300],
//             ),
//             child: Container(
//               width: columnWidths[index],
//               height: 50.0,
//               alignment: Alignment.center,
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Text(
//                           columns[index],
//                           style: TextStyle(
//                               fontWeight: FontWeight.bold, fontSize: 16),
//                           textAlign: TextAlign.center,
//                         ),
//                         IconButton(
//                           icon: Icon(
//                             columnSortState[index]
//                                 ? Icons.arrow_upward
//                                 : Icons.arrow_downward,
//                             size: 16,
//                           ),
//                           onPressed: () => sortColumn(index),
//                         ),
//                       ],
//                     ),
//                   ),
//                   // Resize Handle with proper cursor indication
//                   MouseRegion(
//                     cursor: SystemMouseCursors.resizeColumn,
//                     child: GestureDetector(
//                       onHorizontalDragUpdate: (details) {
//                         setState(() {
//                           columnWidths[index] += details.delta.dx;
//                           columnWidths[index] =
//                               columnWidths[index].clamp(50.0, 300.0);
//                         });
//                       },
//                       child: Container(
//                         width: 5.0,
//                         color: Colors.black,
//                         alignment: Alignment.centerRight,
//                         child: Icon(Icons.drag_handle, size: 15, color: Colors.white),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               color: Colors.grey[200],
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Resizable & Draggable Table with Filters'),
        ),
        body: ResizableDraggableTable(),
      ),
    );
  }
}

class ResizableDraggableTable extends StatefulWidget {
  @override
  _ResizableDraggableTableState createState() => _ResizableDraggableTableState();
}

class _ResizableDraggableTableState extends State<ResizableDraggableTable> {
  List<String> columns = ['Name', 'Age', 'Gender'];
  List<double> columnWidths = [150.0, 100.0, 120.0];

  // Sorting state for each column: true = ascending, false = descending
  List<bool> columnSortState = [true, true, true];

  // Sample data
  List<Map<String, dynamic>> rows = [
    {'Name': 'Alice', 'Age': 25, 'Gender': 'Female'},
    {'Name': 'Bob', 'Age': 30, 'Gender': 'Male'},
    {'Name': 'Charlie', 'Age': 22, 'Gender': 'Male'},
  ];


  // Handle column sorting (A-Z or Z-A)
  void sortColumn(int index) {
    setState(() {
      columnSortState[index] = !columnSortState[index];
      rows.sort((a, b) {
        if (columnSortState[index]) {
          return a[columns[index]].toString().compareTo(b[columns[index]].toString());
        } else {
          return b[columns[index]].toString().compareTo(a[columns[index]].toString());
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return
      DataTable(
        columns: columns.map((column) {
          return DataColumn(
            label: Stack(
              children: [
                Container(
                  width: columnWidths[columns.indexOf(column)],
                  child: Row(
                    children: [
                      Text(
                        column,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      IconButton(
                        icon: Icon(
                          columnSortState[columns.indexOf(column)]
                              ? Icons.arrow_upward
                              : Icons.arrow_downward,
                          size: 16,
                        ),
                        onPressed: () => sortColumn(columns.indexOf(column)),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  right: 0,
                  child: MouseRegion(
                    cursor: SystemMouseCursors.resizeColumn,
                    child: GestureDetector(
                      onHorizontalDragUpdate: (details) {
                        setState(() {
                          columnWidths[columns.indexOf(column)] += details.delta.dx;
                          columnWidths[columns.indexOf(column)] =
                              columnWidths[columns.indexOf(column)].clamp(50.0, 300.0);
                        });
                      },
                      child: Container(
                        width: 5.0,
                        color: Colors.black,
                        alignment: Alignment.centerRight,
                        child: Icon(Icons.drag_handle, size: 15, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            onSort: (columnIndex, ascending) {
              sortColumn(columnIndex);
            },
          );
        }).toList(),
        rows: rows.map((row) {
          return DataRow(
            cells: columns.map((column) {
              return DataCell(
                Text(row[column].toString()),
              );
            }).toList(),
          );
        }).toList(),
      );
  }
}


