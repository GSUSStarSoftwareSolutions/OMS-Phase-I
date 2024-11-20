import 'dart:convert';
import 'dart:html';
import 'package:btb/admin/Api%20name.dart';
import 'package:btb/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../Order Module/firstpage.dart';
import '../admin/admin list.dart';
import '../customer login/order/order list.dart';
import '../dashboard/dashboard.dart';
import 'verify_emailid.dart';

void main() => runApp(MaterialApp(
      home: LoginContainer2(),
    ));

class LoginContainer2 extends StatefulWidget {
  const LoginContainer2({super.key});

  @override
  State<LoginContainer2> createState() => _LoginContainer2State();
}

class _LoginContainer2State extends State<LoginContainer2> {
  final userName = TextEditingController();
  final Password = TextEditingController();
  bool _obscureText = true;

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  Future<String?> checkLogin(String username, String password) async {
    Map tempJson = {"userName": username, "password": password};
    String url =
        '$apicall/user_master/login-authenticate';
    final response = await http.post(Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
        },
        body: json.encode(tempJson));
    if (response.statusCode == 200) {
      Map tempData = json.decode(response.body);
      if (tempData.containsKey("error")) {
        // Handle empty input fields with appropriate messages
        if (userName.text.isEmpty && Password.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Please enter username & password")),
          );
        } else if (userName.text.isNotEmpty && Password.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Please enter password")),
          );
        } else if (userName.text.isEmpty && Password.text.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Please enter username")),
          );
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Something went wrong")));
        }
      } else {
        window.sessionStorage["userId"] = tempData['userId'];
        // Check the role and handle accordingly
        String role = tempData['role'];
        if (role == 'Employee') {
          // Handle Employee role
          window.sessionStorage["token"] = tempData['token'];
          context.go('/Home'); // Navigate to Employee-specific home
        } else if (role == 'Customer') {
          // Handle Admin role
          window.sessionStorage["userId"] = tempData['userId'];
          window.sessionStorage["token"] = tempData['token'];
         //  String userId = tempData['userId'];
        //  Provider.of<UserRoleProvider>(context, listen: false).setRole(role);
          context.go('/Cus_Home');
          // Navigate to Admin-specific home
        } else if (role == 'Admin') {
          // Handle Admin role
          window.sessionStorage["token"] = tempData['token'];
          context.go('/User_List');
          // Navigate to Admin-specific home
        }
        // else if (role == 'User') {
        //   // Handle Admin role
        //   window.sessionStorage["token"] = tempData['token'];
        //   Navigator.push(
        //     context,
        //     PageRouteBuilder(
        //       pageBuilder: (context, animation, secondaryAnimation) =>
        //           AdminList(),
        //       transitionDuration: const Duration(milliseconds: 200),
        //       transitionsBuilder: (context, animation, secondaryAnimation, child) {
        //         return FadeTransition(
        //           opacity: animation,
        //           child: child,
        //         );
        //       },
        //     ),
        //   );
        // //  context.go('/AdminHome');
        //   // Navigate to Admin-specific home
        // }
        else {
          // Handle other roles, if needed
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Unknown role")),
          );
        }
        return null;
      }
    } else {
      // Handle non-200 responses
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid response from server")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if(constraints.maxHeight >= 650){
          return Container(
            constraints: BoxConstraints(maxWidth: constraints.maxWidth * 0.8),
            // 80% of screen width
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: constraints.maxHeight * 0.15),
                // 10% of screen height
                Align(
                  alignment: Alignment(-0.14, 0.0),
                  child: Text(
                    'Login to Your account',
                    style: TextStyle(
                        fontSize: constraints.maxWidth * 0.023,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue),
                  ),
                ),
                SizedBox(height: constraints.maxHeight * 0.03),
                // 5% of screen height
                Align(
                  alignment: Alignment(-0.05, 0.0),
                  child: Text(
                    'Simplify your order management \nand gain complete control',
                    style: TextStyle(fontSize: constraints.maxWidth * 0.020),
                  ),
                ),
                SizedBox(height: constraints.maxHeight * 0.03),
                // 5% of screen height
                Align(
                  alignment: const Alignment(0.9, 0.4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: constraints.maxHeight * 0.04),
                      const Align(
                          alignment: Alignment(-0.27, 0.0),
                          child: Text(
                            'Username',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          )),
                      const SizedBox(height: 10),
                      Align(
                        alignment: const Alignment(0.1, 0.0),
                        child: SizedBox(
                          height: 40,
                          width: constraints.maxWidth * 0.39,
                          child: TextFormField(
                            controller: userName,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'Enter your username',
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 8,
                              ),
                            ),
                            onFieldSubmitted: (value) async {
                              print('username');
                              String? role =
                              await checkLogin(userName.text, Password.text);
                              if (role != null) {
                                if(role == 'Employee'){
                                  context.go('/Home');
                                }else if(role == 'Customer'){
                                  context.go('/Customer_Order_List');
                                }else if(role == 'Admin'){
                                  context.go('/User_List');
                                }else if(userName.text.isNotEmpty && Password.text.isEmpty){
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content:
                                        Text("Please enter password")),
                                  );
                                }

                              }
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Align(
                          alignment: Alignment(-0.27, 0.0),
                          child: Text(
                            'Password',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          )),
                      const SizedBox(height: 10),
                      Align(
                        alignment: const Alignment(0.1, 0.0),
                        child: SizedBox(
                          height: 40,
                          width: constraints.maxWidth * 0.39,
                          child: TextFormField(
                            controller: Password,
                            obscureText: _obscureText,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'Enter your Password',
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 8,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureText
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  size: 20,
                                ),
                                onPressed:
                                _togglePasswordVisibility, // Toggle password visibility
                              ),
                            ),
                            onFieldSubmitted: (value) async {
                              print('username');
                              String? role =
                              await checkLogin(userName.text, Password.text);
                              if (role != null) {
                                if(role == 'Employee'){
                                  context.go('/Home');
                                }else if(role == 'Customer'){
                                  context.go('/Customer_Order_List');
                                }else if(role == 'Admin'){
                                  context.go('/User_List');
                                }else if(userName.text.isEmpty && Password.text.isNotEmpty){
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content:
                                        Text("Please enter username")),
                                  );
                                }

                              }
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Align(
                          alignment: Alignment(0.36, 0.2),
                          child: InkWell(
                            splashColor: Colors.transparent,
                            // remove splash effect
                            highlightColor: Colors.transparent,
                            // remove highlight effect
                            onTap: () {
                              Navigator.of(context).push(PageRouteBuilder(
                                pageBuilder:
                                    (context, animation, secondaryAnimation) =>
                                    Logout(),
                              ));
                            },
                            child: Text(
                              'Forgot password ?',
                              style: TextStyle(color: Colors.blue),
                            ),
                          )
                        // child: Text('Forgot password ?'),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Align(
                        alignment: const Alignment(0.1, 0.2),
                        child: SizedBox(
                          width:200,
                          child: ElevatedButton(
                            onPressed: () async {
                              // bool isValid = await checkLogin(userName.text, Password.text);
                              // if (isValid) {
                              //   context.go('/Home');
                              //   ScaffoldMessenger.of(context).showSnackBar(
                              //     const SnackBar(content: Text("Something went wrong")),
                              //   );
                              // }
                              await checkLogin(userName.text, Password.text);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[800],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            child: const Align(
                                alignment: Alignment(0.0, 0.0),
                                child: Text(
                                  'Login',
                                  style: TextStyle(color: Colors.white),
                                )),
                          ),
                        ),
                      ),
                      const SizedBox(height: 120),
                      Align(
                        alignment: const Alignment(0.1, 0.0),
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: const TextSpan(
                            children: [
                              TextSpan(
                                text: 'Need help? ',
                                style: TextStyle(
                                  color: Colors.black,
                                ),
                              ),
                              TextSpan(
                                text: 'Contact Support',
                                style: TextStyle(
                                  color: Colors.blue,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 5,)
                    ],
                  ),
                ),
              ],
            ),
          );
        }
        else{
          return SingleChildScrollView(
            child: Container(
              constraints: BoxConstraints(maxWidth: constraints.maxWidth * 0.8),
              // 80% of screen width
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: constraints.maxHeight * 0.15),
                  // 10% of screen height
                  Align(
                    alignment: Alignment(-0.14, 0.0),
                    child: Text(
                      'Login to Your account',
                      style: TextStyle(
                          fontSize: constraints.maxWidth * 0.023,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue),
                    ),
                  ),
                  SizedBox(height: constraints.maxHeight * 0.03),
                  // 5% of screen height
                  Align(
                    alignment: Alignment(-0.05, 0.0),
                    child: Text(
                      'Simplify your order management \nand gain complete control',
                      style: TextStyle(fontSize: constraints.maxWidth * 0.020),
                    ),
                  ),
                  SizedBox(height: constraints.maxHeight * 0.03),
                  // 5% of screen height
                  Align(
                    alignment: const Alignment(0.9, 0.4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: constraints.maxHeight * 0.04),
                        const Align(
                            alignment: Alignment(-0.27, 0.0),
                            child: Text(
                              'Username',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            )),
                        const SizedBox(height: 10),
                        Align(
                          alignment: const Alignment(0.1, 0.0),
                          child: SizedBox(
                            height: 40,
                            width: constraints.maxWidth * 0.39,
                            child: TextFormField(
                              controller: userName,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                hintText: 'Enter your username',
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 8,
                                ),
                              ),
                              onFieldSubmitted: (value) async {
                                print('username');
                                String? role =
                                await checkLogin(userName.text, Password.text);
                                if (role != null) {
                                  if(role == 'Employee'){
                                    context.go('/Home');
                                  }else if(role == 'Customer'){
                                    context.go('/Customer_Order_List');
                                  }else if(role == 'Admin'){
                                    context.go('/User_List');
                                  }else if(userName.text.isNotEmpty && Password.text.isEmpty){
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content:
                                          Text("Please enter password")),
                                    );
                                  }
            
                                }
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Align(
                            alignment: Alignment(-0.27, 0.0),
                            child: Text(
                              'Password',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            )),
                        const SizedBox(height: 10),
                        Align(
                          alignment: const Alignment(0.1, 0.0),
                          child: SizedBox(
                            height: 40,
                            width: constraints.maxWidth * 0.39,
                            child: TextFormField(
                              controller: Password,
                              obscureText: _obscureText,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                hintText: 'Enter your Password',
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 8,
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscureText
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    size: 20,
                                  ),
                                  onPressed:
                                  _togglePasswordVisibility, // Toggle password visibility
                                ),
                              ),
                              onFieldSubmitted: (value) async {
                                print('username');
                                String? role =
                                await checkLogin(userName.text, Password.text);
                                if (role != null) {
                                  if(role == 'Employee'){
                                    context.go('/Home');
                                  }else if(role == 'Customer'){
                                    context.go('/Customer_Order_List');
                                  }else if(role == 'Admin'){
                                    context.go('/User_List');
                                  }else if(userName.text.isEmpty && Password.text.isNotEmpty){
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content:
                                          Text("Please enter username")),
                                    );
                                  }
            
                                }
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Align(
                            alignment: Alignment(0.36, 0.2),
                            child: InkWell(
                              splashColor: Colors.transparent,
                              // remove splash effect
                              highlightColor: Colors.transparent,
                              // remove highlight effect
                              onTap: () {
                                Navigator.of(context).push(PageRouteBuilder(
                                  pageBuilder:
                                      (context, animation, secondaryAnimation) =>
                                      Logout(),
                                ));
                              },
                              child: Text(
                                'Forgot password ?',
                                style: TextStyle(color: Colors.blue),
                              ),
                            )
                          // child: Text('Forgot password ?'),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Align(
                          alignment: const Alignment(0.1, 0.2),
                          child: SizedBox(
                            width: constraints.maxWidth * 0.2,
                            child: ElevatedButton(
                              onPressed: () async {
                                // bool isValid = await checkLogin(userName.text, Password.text);
                                // if (isValid) {
                                //   context.go('/Home');
                                //   ScaffoldMessenger.of(context).showSnackBar(
                                //     const SnackBar(content: Text("Something went wrong")),
                                //   );
                                // }
                                await checkLogin(userName.text, Password.text);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue[800],
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              child: const Align(
                                  alignment: Alignment(0.0, 0.0),
                                  child: Text(
                                    'Login',
                                    style: TextStyle(color: Colors.white),
                                  )),
                            ),
                          ),
                        ),
                        const SizedBox(height: 140),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 30),
                          child: Align(
                            alignment: const Alignment(0.1, 0.0),
                            child: RichText(
                              textAlign: TextAlign.center,
                              text: const TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'Need help? ',
                                    style: TextStyle(
                                      color: Colors.black,
                                    ),
                                  ),
                                  TextSpan(
                                    text: 'Contact Support',
                                    style: TextStyle(
                                      color: Colors.blue,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      
      },
    );
  }
}

class ImageContainer extends StatelessWidget {
  const ImageContainer({super.key});
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context,constraints){
        if(constraints.maxHeight >=630){
          return Container(
            width: double.infinity, // Take full width
            color: Colors.grey[100],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 40, left: 25),
                  child: Image.asset('images/Final-Ikyam-Logo.png'),
                ),
                const SizedBox(height: 50), // You can adjust this value
                Center(
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width *
                        0.4, // Take 70% of screen width
                    height: MediaQuery.of(context).size.width *
                        0.3, // Take 70% of screen width
                    child: Image.asset(
                      'images/ikyam1.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ],
            ),
          );
        }
        else{
          return Container(
            width: double.infinity, // Take full width
            color: Colors.grey[100],
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 40, left: 25),
                    child: Image.asset('images/Final-Ikyam-Logo.png'),
                  ),
                  const SizedBox(height: 50), // You can adjust this value
                  Center(
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width *
                            0.4, // Take 70% of screen width
                        height: MediaQuery.of(context).size.width *
                            0.3, // Take 70% of screen width
                        child: SingleChildScrollView(
                          child: Image.asset(
                            'images/ikyam1.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    
                  ),
                ],
              ),
            ),
          );
        }
       
      }
    );
    
  }
}
