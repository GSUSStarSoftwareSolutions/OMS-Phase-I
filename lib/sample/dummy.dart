import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: AuthPage(),
    );
  }
}

class AuthPage extends StatefulWidget {
  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool isLoginPage = true;  // Toggle between Login and SignUp

  // Controllers for the fields
  final _tenantController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String userRole = '';  // Will store user role (admin/employee)

  // Function to check if the tenant exists
  Future<String> checkTenantExists(String tenantName) async {
    // Simulate an API call to check if tenant exists
    await Future.delayed(Duration(seconds: 1));
    return tenantName == "ExistingCompany" ? 'exists' : 'not_exists';
  }

  // Function to check user role based on tenant and email
  Future<String> checkUserRole(String tenantName, String email) async {
    // Simulate an API call to get user role
    await Future.delayed(Duration(seconds: 1));
    if (email == "admin@company.com" && tenantName == "ExistingCompany") {
      return 'admin';
    } else if (email == "employee@company.com" && tenantName == "ExistingCompany") {
      return 'employee';
    }
    return 'not_found';
  }

  // Login method
  void _login() async {
    String tenant = _tenantController.text;
    String email = _emailController.text;
    String password = _passwordController.text;

    if (tenant.isEmpty || email.isEmpty || password.isEmpty) {
      return;  // Handle error for missing fields
    }

    String role = await checkUserRole(tenant, email);

    if (role == 'admin' || role == 'owner') {
      // Allow login and admin features
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => AdminDashboard()),
      );
    } else if (role == 'employee') {
      // Allow employee login, redirect to employee dashboard
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => EmployeeDashboard()),
      );
    } else {
      // Show error if company doesn't exist or invalid credentials
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Error'),
          content: Text('Invalid company or user role.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  // SignUp method
  void _signUp() async {
    String tenant = _tenantController.text;
    String email = _emailController.text;
    String password = _passwordController.text;

    if (tenant.isEmpty || email.isEmpty || password.isEmpty) {
      return;  // Handle error for missing fields
    }

    String tenantStatus = await checkTenantExists(tenant);

    if (tenantStatus == 'not_exists') {
      // New tenant creation process (only for admins)
      userRole = 'admin';  // If the user is authorized, set as admin/owner
    } else {
      // Assign user as an employee if tenant exists
      userRole = 'employee';
    }

    // Proceed with the signup process
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => WelcomePage(userRole: userRole)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isLoginPage ? 'Login' : 'Sign Up'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Tenant Name (Company) field
            TextFormField(
              controller: _tenantController,
              decoration: InputDecoration(labelText: 'Company Name (Tenant)'),
            ),
            // Email field
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            // Password field
            TextFormField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            // Login or Sign Up button
            ElevatedButton(
              onPressed: isLoginPage ? _login : _signUp,
              child: Text(isLoginPage ? 'Login' : 'Sign Up'),
            ),
            // Toggle between Login and Sign Up
            TextButton(
              onPressed: () {
                setState(() {
                  isLoginPage = !isLoginPage; // Toggle the view
                });
              },
              child: Text(isLoginPage
                  ? 'Don\'t have an account? Sign Up'
                  : 'Already have an account? Login'),
            ),
          ],
        ),
      ),
    );
  }
}

// Dummy Admin Dashboard
class AdminDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Admin Dashboard')),
      body: Center(child: Text('Welcome Admin')),
    );
  }
}

// Dummy Employee Dashboard
class EmployeeDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Employee Dashboard')),
      body: Center(child: Text('Welcome Employee')),
    );
  }
}

// Dummy Welcome Page after SignUp
class WelcomePage extends StatelessWidget {
  final String userRole;
  WelcomePage({required this.userRole});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Welcome')),
      body: Center(
        child: Text('Welcome, $userRole! You have successfully signed up.'),
      ),
    );
  }
}
