// import 'package:flutter/material.dart';
// import 'package:syncfusion_flutter_datagrid/datagrid.dart';
//
//
// void main() {
//   runApp(MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: DataGridPage(),
//     );
//   }
// }
//
// class DataGridPage extends StatefulWidget {
//   @override
//   _DataGridPageState createState() => _DataGridPageState();
// }
//
// class _DataGridPageState extends State<DataGridPage> {
//   late EmployeeDataSource _employeeDataSource;
//
//   List<Employee> _employees = <Employee>[];
//
//   @override
//   void initState() {
//     super.initState();
//     _employees = getEmployeeData();
//     _employeeDataSource = EmployeeDataSource(employees: _employees);
//   }
//
//   List<Employee> getEmployeeData() {
//     return [
//       Employee(1001, 'John', 'Manager', 10000, 'Delivered'),
//       Employee(1002, 'Jane', 'Engineer', 9000, 'In Progress'),
//       Employee(1003, 'Robert', 'Designer', 8000, 'Shipped'),
//       Employee(1004, 'Lucy', 'Developer', 12000, 'Delivered'),
//       Employee(1005, 'Emma', 'Tester', 7000, 'Cancelled'),
//     ];
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         appBar: AppBar(
//           title: Text('DataGrid with Column Filters and Drag & Drop'),
//         ),
//         body: SfDataGrid(
//           source: _employeeDataSource,
//           allowSorting: true,
//           allowFiltering: true, // Enables filtering for columns
//           allowColumnsResizing: true, // Enables column resizing
//           allowColumnsDragging: true,
//           allowSwiping: true,
//           allowExpandCollapseGroup: true,
//           columnWidthMode: ColumnWidthMode.fill,
//           columns: <GridColumn>[
//             GridColumn(
//               columnName: 'id',
//               label: Container(
//                 padding: EdgeInsets.all(8.0),
//                 alignment: Alignment.center,
//                 child: Text(
//                   'Order ID',
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               ),
//               allowFiltering: true,
//             ),
//             GridColumn(
//               columnName: 'name',
//               label: Container(
//                 padding: EdgeInsets.all(8.0),
//                 alignment: Alignment.center,
//                 child: Text(
//                   'Name',
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               ),
//               allowFiltering: true,
//             ),
//             GridColumn(
//               columnName: 'role',
//               label: Container(
//                 padding: EdgeInsets.all(8.0),
//                 alignment: Alignment.center,
//                 child: Text(
//                   'Role',
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               ),
//               allowFiltering: true,
//             ),
//             GridColumn(
//               columnName: 'salary',
//               label: Container(
//                 padding: EdgeInsets.all(8.0),
//                 alignment: Alignment.center,
//                 child: Text(
//                   'Salary',
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               ),
//               allowFiltering: true,
//             ),
//             GridColumn(
//               columnName: 'status',
//               label: Container(
//                 padding: EdgeInsets.all(8.0),
//                 alignment: Alignment.center,
//                 child: Text(
//                   'Status',
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               ),
//               allowFiltering: true,
//             ),
//           ],
//         )
//
//     );
//   }
// }
//
// // Employee Model
// class Employee {
//   Employee(this.id, this.name, this.role, this.salary, this.status);
//
//   final int id;
//   final String name;
//   final String role;
//   final double salary;
//   final String status;
// }
//
// // Employee DataSource
// class EmployeeDataSource extends DataGridSource {
//
//   EmployeeDataSource({required List<Employee> employees}) {
//     _employeeData = employees
//         .map<DataGridRow>((e) => DataGridRow(cells: [
//       DataGridCell<int>(columnName: 'id', value: e.id),
//       DataGridCell<String>(columnName: 'name', value: e.name),
//       DataGridCell<String>(columnName: 'role', value: e.role),
//       DataGridCell<double>(columnName: 'salary', value: e.salary),
//       DataGridCell<String>(columnName: 'status', value: e.status),
//     ]))
//         .toList();
//   }
//
//   List<DataGridRow> _employeeData = [];
//
//   @override
//   List<DataGridRow> get rows => _employeeData;
//
//   @override
//   DataGridRowAdapter buildRow(DataGridRow row) {
//     return DataGridRowAdapter(cells: [
//       Container(
//         alignment: Alignment.center,
//         padding: EdgeInsets.all(8.0),
//         child: Text(row.getCells()[0].value.toString()),
//       ),
//       Container(
//         alignment: Alignment.center,
//         padding: EdgeInsets.all(8.0),
//         child: Text(row.getCells()[1].value.toString()),
//       ),
//       Container(
//         alignment: Alignment.center,
//         padding: EdgeInsets.all(8.0),
//         child: Text(row.getCells()[2].value.toString()),
//       ),
//       Container(
//         alignment: Alignment.center,
//         padding: EdgeInsets.all(8.0),
//         child: Text(row.getCells()[3].value.toString()),
//       ),
//       Container(
//         alignment: Alignment.center,
//         padding: EdgeInsets.all(8.0),
//         child: Text(row.getCells()[4].value.toString()),
//       ),
//     ]);
//   }
// }
