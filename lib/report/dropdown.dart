import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DropdownExample(),
    );
  }
}

class DropdownExample extends StatefulWidget {
  @override
  _DropdownExampleState createState() => _DropdownExampleState();
}

class _DropdownExampleState extends State<DropdownExample> {
  // Initial selected value
  String selectedValue = 'Download';

  // List of items for the dropdown
  final List<String> dropdownItems = ['Order', 'Invoice'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dropdown Example'),
      ),
      body: Center(
        child: DropdownButton<String>(
          // The value to display in the dropdown
          value: selectedValue,

          // The function to execute when a new item is selected
          onChanged: (String? newValue) {
            setState(() {
              selectedValue = newValue!; // Update the selected value
            });
          },

          // The list of dropdown items
          items: [
            DropdownMenuItem(
              value: 'Download',
              child: Text('Download'), // Always show 'Download'
            ),
            ...dropdownItems.map((String item) {
              return DropdownMenuItem(
                value: item,
                child: Text(item),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
