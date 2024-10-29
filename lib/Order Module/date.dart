// import 'package:flutter/material.dart';
// import 'package:custom_date_range_picker/custom_date_range_picker.dart'; // Import the package
// import 'package:intl/intl.dart'; // To format the selected date range
//
// void main() {
//   runApp(MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Date Range Picker Example',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: DateRangePickerDemo(),
//     );
//   }
// }
//
// class DateRangePickerDemo extends StatefulWidget {
//   @override
//   _DateRangePickerDemoState createState() => _DateRangePickerDemoState();
// }
//
// class _DateRangePickerDemoState extends State<DateRangePickerDemo> {
//   // Variables to store the selected date range
//   DateTime? _startDate;
//   DateTime? _endDate;
//
//   // Date format for display purposes
//   final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');
//
//   // Function to open the Custom Date Range Picker
//   Future<void> _openDateRangePicker(BuildContext context) async {
//     // No 'await' here since the method returns void.
//     showCustomDateRangePicker(
//       context,
//       dismissible: true, // Whether the dialog can be dismissed
//       minimumDate: DateTime(2000),
//       maximumDate: DateTime(2100),
//       endDate: _endDate,
//       startDate: _startDate,
//       onApplyClick: (start, end) {
//         setState(() {
//           _startDate = start;
//           _endDate = end;
//         });
//       },
//       onCancelClick: () {
//         setState(() {
//           _startDate = null;
//           _endDate = null;
//         });
//       },
//       backgroundColor: Colors.blue,
//       primaryColor: Colors.white,
//     );
//   }
//
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Custom Date Range Picker Example'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             // Display the selected "From Date"
//             TextField(
//               readOnly: true,
//               decoration: InputDecoration(
//                 labelText: 'From Date',
//                 hintText: _startDate != null
//                     ? _dateFormat.format(_startDate!) // Show the formatted start date
//                     : 'Select From Date',
//                 suffixIcon: Icon(Icons.calendar_today),
//                 border: OutlineInputBorder(),
//               ),
//               onTap: () => _openDateRangePicker(context), // Open the date range picker
//             ),
//             SizedBox(height: 20),
//
//             // Display the selected "To Date"
//             TextField(
//               readOnly: true,
//               decoration: InputDecoration(
//                 labelText: 'To Date',
//                 hintText: _endDate != null
//                     ? _dateFormat.format(_endDate!) // Show the formatted end date
//                     : 'Select To Date',
//                 suffixIcon: Icon(Icons.calendar_today),
//                 border: OutlineInputBorder(),
//               ),
//               onTap: () => _openDateRangePicker(context), // Open the date range picker
//             ),
//           ],
//         ),
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
      home: MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final _fromDateController = TextEditingController();
  final _toDateController = TextEditingController();
  DateTime _fromDate = DateTime.now();
  DateTime _toDate = DateTime.now().add(const Duration(days: 1));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Date Picker Dialog Box'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            InkWell(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => Dialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    elevation: 0.0,
                    backgroundColor: Colors.transparent,
                    child: StatefulBuilder(
                      builder: (context, setState) {
                        return Container(
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              const Text(
                                'Select Date Range',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: <Widget>[
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        const Text('From Date1'),
                                        const SizedBox(height: 8),
                                        InkWell(
                                          onTap: () async {
                                            final DateTime? picked = await showDatePicker(
                                              context: context,
                                              initialDate: _fromDate,
                                              firstDate: DateTime(2020),
                                              lastDate: DateTime(2030),
                                            );
                                            if (picked != null) {
                                              setState(() {
                                                _fromDate = picked;
                                                _fromDateController.text =
                                                '${_fromDate.day}/${_fromDate.month}/${_fromDate.year}';
                                              });
                                            }
                                          },
                                          child: Text(
                                            '${_fromDate.day}/${_fromDate.month}/${_fromDate.year}',
                                            style: const TextStyle(fontSize: 18),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        const Text('To Date'),
                                        const SizedBox(height: 8),
                                        InkWell(
                                          onTap: () async {
                                            final DateTime? picked = await showDatePicker(
                                              context: context,
                                              initialDate: _toDate,
                                              firstDate: _fromDate,
                                              lastDate: DateTime(2030),
                                            );
                                            if (picked != null) {
                                              setState(() {
                                                _toDate = picked;
                                                _toDateController.text =
                                                '${_toDate.day}/${_toDate.month}/${_toDate.year}';
                                              });
                                            }
                                          },
                                          child: Text(
                                            '${_toDate.day}/${_toDate.month}/${_toDate.year}',
                                            style: const TextStyle(fontSize: 18),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text('OK'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                );
                // showDialog(
                //   context: context,
                //   builder: (context) => Dialog(
                //     child: Padding(
                //       padding: const EdgeInsets.all(16.0),
                //       child: Column(
                //         mainAxisSize: MainAxisSize.min,
                //         children: <Widget>[
                //           Text('Select From Date'),
                //           SizedBox(height: 16),
                //           InkWell(
                //             onTap: () async {
                //               final DateTime? picked = await showDatePicker(
                //                 context: context,
                //                 initialDate: _fromDate,
                //                 firstDate: DateTime(2020),
                //                 lastDate: DateTime(2030),
                //               );
                //               if (picked != null) {
                //                 setState(() {
                //                   _fromDate = picked;
                //                 });
                //               }
                //             },
                //             child: Text(
                //               '${_fromDate.day}/${_fromDate.month}/${_fromDate.year}',
                //               style: TextStyle(fontSize: 18),
                //             ),
                //           ),
                //           SizedBox(height: 16),
                //           Text('Select To Date'),
                //           SizedBox(height: 16),
                //           InkWell(
                //             onTap: () async {
                //               final DateTime? picked = await showDatePicker(
                //                 context: context,
                //                 initialDate: _toDate,
                //                 firstDate: _fromDate,
                //                 lastDate: DateTime(2030),
                //               );
                //               if (picked != null) {
                //                 setState(() {
                //                   _toDate = picked;
                //                 });
                //               }
                //             },
                //             child: Text(
                //               '${_toDate.day}/${_toDate.month}/${_toDate.year}',
                //               style: TextStyle(fontSize: 18),
                //             ),
                //           ),
                //           ElevatedButton(
                //             onPressed: () {
                //               Navigator.of(context).pop();
                //               _fromDateController.text =
                //               '${_fromDate.day}/${_fromDate.month}/${_fromDate.year}';
                //               _toDateController.text =
                //               '${_toDate.day}/${_toDate.month}/${_toDate.year}';
                //             },
                //             child: Text('OK'),
                //           ),
                //         ],
                //       ),
                //     ),
                //   ),
                // );
              },
              child: const Icon(Icons.date_range),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _fromDateController,
              decoration: const InputDecoration(
                labelText: 'From Date',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _toDateController,
              decoration: const InputDecoration(
                labelText: 'To Date',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
// //not bad
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart'; // For formatting dates
//
// void main() {
//   runApp(MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Date Range Picker',
//       theme: ThemeData(
//         primarySwatch: Colors.teal,
//       ),
//       home: DateRangePickerPage(),
//     );
//   }
// }
//
// class DateRangePickerPage extends StatefulWidget {
//   @override
//   _DateRangePickerPageState createState() => _DateRangePickerPageState();
// }
//
// class _DateRangePickerPageState extends State<DateRangePickerPage> {
//   DateTimeRange? selectedDateRange;
//
//   // Format dates for display
//   String getFormattedDate(DateTime date) {
//     return DateFormat('yyyy-MM-dd').format(date);
//   }
//
//   Future<void> pickDateRange(BuildContext context) async {
//     DateTimeRange? picked = await showDateRangePicker(
//       context: context,
//       firstDate: DateTime(2000),
//       lastDate: DateTime(2100),
//       initialDateRange: selectedDateRange,
//       builder: (context, child) {
//         return Align(
//           alignment: Alignment.bottomCenter, // Adjust alignment to bottom
//           child: Theme(
//             data: Theme.of(context).copyWith(
//               colorScheme: ColorScheme.light(
//                 primary: Colors.purple, // Header background color
//                 onPrimary: Colors.white, // Header text color
//                 onSurface: Colors.black, // Calendar text color
//               ),
//               textButtonTheme: TextButtonThemeData(
//                 style: TextButton.styleFrom(backgroundColor: Colors.purple),
//               ),
//             ),
//             child: child!,
//           ),
//         );
//       },
//     );
//
//     if (picked != null) {
//       setState(() {
//         selectedDateRange = picked;
//       });
//     }
//   }
//
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Date Range Picker'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Text(
//                 selectedDateRange == null
//                     ? 'No Date Range Selected'
//                     : 'From: ${getFormattedDate(selectedDateRange!.start)}\nTo: ${getFormattedDate(selectedDateRange!.end)}',
//                 textAlign: TextAlign.center,
//                 style: TextStyle(fontSize: 18, color: Colors.grey[700]),
//               ),
//               SizedBox(height: 20),
//               ElevatedButton(
//                 onPressed: () => pickDateRange(context),
//                 child: Text('Select Date Range'),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.teal,
//                   padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
//                   textStyle: TextStyle(fontSize: 16),
//                 ),
//               ),
//               SizedBox(height: 30),
//               if (selectedDateRange != null)
//                 ElevatedButton(
//                   onPressed: () {
//                     // Handle filter action
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       SnackBar(
//                         content: Text(
//                           'Filtered from ${getFormattedDate(selectedDateRange!.start)} to ${getFormattedDate(selectedDateRange!.end)}',
//                         ),
//                       ),
//                     );
//                   },
//                   child: Text('Filter Dates'),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.green,
//                     padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
//                     textStyle: TextStyle(fontSize: 16),
//                   ),
//                 ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

