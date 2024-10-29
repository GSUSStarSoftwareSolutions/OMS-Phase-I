import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Order Management',
      theme: ThemeData(
        primaryColor: Color(0xFF2D3E50), // Deep Blue Gray
        hintColor: Color(0xFFFF6F61),  // Coral Accent Color
        backgroundColor: Color(0xFFF5F7FA), // Soft Light Gray
        scaffoldBackgroundColor: Color(0xFFF5F7FA), // Light Gray Background
        appBarTheme: AppBarTheme(
          elevation: 6, // Gives depth to the AppBar
          shadowColor: Color(0xFFB0BEC5), // Subtle shadow for AppBar
        ),
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Order Management"),
        elevation: 6, // Custom elevation for a clean shadow effect
        shadowColor: Color(0xFFB0BEC5), // Matching shadow color
        backgroundColor: Color(0xFF2D3E50), // AppBar Color
        actions: [
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {},
            color: Colors.white, // AppBar icon color
          ),
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {},
            color: Colors.white, // AppBar icon color
          ),
        ],
      ),
      drawer: Drawer(
        child: Container(
          color: Color(0xFF2D3E50), // Drawer background color
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Color(0xFF2D3E50), // Header color
                ),
                child: Text(
                  'Menu',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
              ),
              ListTile(
                leading: Icon(Icons.home, color: Colors.white),
                title: Text(
                  'Dashboard',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  // Handle navigation
                },
              ),
              ListTile(
                leading: Icon(Icons.shopping_cart, color: Colors.white),
                title: Text(
                  'Orders',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  // Handle navigation
                },
              ),
              ListTile(
                leading: Icon(Icons.account_circle, color: Colors.white),
                title: Text(
                  'Profile',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  // Handle navigation
                },
              ),
            ],
          ),
        ),
      ),
      body: Center(
        child: Text(
          'Welcome to the Order Management App',
          style: TextStyle(
            fontSize: 20,
            color: Color(0xFF2D3E50), // Matching the primary color
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFFFF6F61), // Coral Accent color for action buttons
        onPressed: () {
          // Action on button press
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
