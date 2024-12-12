import 'dart:convert';
import 'dart:html';

import 'package:btb/admin/Api%20name.dart';
import 'package:btb/login/login.dart';
import 'package:btb/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;

void main() => runApp(MaterialApp(
      home: createscr(),
    ));

class createscr extends StatefulWidget {
  const createscr({super.key});

  @override
  State<createscr> createState() => _createscrState();
}

class _createscrState extends State<createscr> {
  final userName = TextEditingController();
  final Email = TextEditingController();
  final Password = TextEditingController();
  final ConfirmPassword = TextEditingController();
  bool _obscureText = true;
  bool _obscureText1 = true;

  void _togglePasswordVisibility1() {
    setState(() {
      _obscureText1 = !_obscureText1;
    });
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  Future<String?> checkLogin(String Email, String password) async {
    String url = '$apicall/user_master/add_password/$Email/$password';
    //   'https://mjl9lz64l7.execute-api.ap-south-1.amazonaws.com/stage1/api/user_master/add_password/$Email/$password';
    final response = await http.put(Uri.parse(url), headers: {
      "Content-Type": "application/json",
    });
    if (response.statusCode == 200) {
      final addResponseBody = jsonDecode(response.body);
      if (addResponseBody['status'] == 'failed' &&
          addResponseBody['code'] == '404') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please entered register Mail ID.'),
            duration: Duration(seconds: 2), // Optional duration
          ),
        );
      } else if (addResponseBody['status'] == 'failed' &&
          addResponseBody['code'] == '400') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please password must be strong.'),
            duration: Duration(seconds: 2), // Optional duration
          ),
        );
      }
      else {
        showDialog(
          barrierDismissible: false,
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              contentPadding: EdgeInsets.zero,
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Icon(Icons.check_circle,
                            color: Colors.green, size: 40),
                        const SizedBox(height: 16),
                        const Text(
                          'Password set Successfully',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                context.go('/');
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                side: const BorderSide(color: Colors.blue),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                              ),
                              child: const Text(
                                'Go to Login',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
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
        return Scaffold(
          body: Container(
            constraints: BoxConstraints(maxWidth: constraints.maxWidth * 0.8),
            // 80% of screen width
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: constraints.maxHeight * 0.18),
                // 10% of screen height
                Align(
                  alignment: Alignment(0.05, 0.0),
                  child: Text(
                    'Create an Account',
                    style: TextStyle(
                        fontSize: constraints.maxWidth * 0.023,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue),
                  ),
                ),
                SizedBox(height: constraints.maxHeight * 0.03),
                Align(
                  alignment: Alignment(0.9, 0.4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: constraints.maxHeight * 0.04),
                      const Align(
                          alignment: Alignment(-0.33, 0.0),
                          child: Text(
                            'Email Address',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          )),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment(0.1, 0.0),
                        child: SizedBox(
                          height: 40,
                          width: constraints.maxWidth * 0.39,
                          child: TextFormField(
                            controller: Email,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'Enter your email address',
                              hintStyle: TextStyle(fontSize: 13),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 8,
                              ),
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'[a-z0-9@._]')), // Allows lowercase, digits, and common email symbols
                            ],
                          ),

                        ),
                      ),
                      const SizedBox(height: 10),
                      const Align(
                          alignment: Alignment(-0.32, 0.0),
                          child: Text(
                            'New Password',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          )),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment(0.1, 0.0),
                        child: SizedBox(
                          height: 40,
                          width: constraints.maxWidth * 0.39,
                          child: TextFormField(
                            controller: Password,
                            obscureText: _obscureText1,
                            decoration: InputDecoration(
                              border: const OutlineInputBorder(),
                              hintText: 'Enter your new password',
                              hintStyle: TextStyle(fontSize: 13),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 8,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureText1
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  size: 20,
                                ),
                                onPressed:
                                    _togglePasswordVisibility1, // Toggle password visibility
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Align(
                          alignment: Alignment(-0.29, 0.0),
                          child: Text(
                            'Confirm Password',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          )),
                      const SizedBox(height: 10),
                      Align(
                        alignment: const Alignment(0.1, 0.0),
                        child: SizedBox(
                          height: 40,
                          width: constraints.maxWidth * 0.39,
                          child: TextFormField(
                            controller: ConfirmPassword,
                            obscureText: _obscureText,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'Enter your confirm password',
                              hintStyle: TextStyle(fontSize: 13),
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
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Align(
                        alignment: const Alignment(0.1, 0.2),
                        child: SizedBox(
                          width: constraints.maxWidth * 0.25,
                          child: ElevatedButton(
                            onPressed: () async {
                              if (Password.text.isEmpty &&
                                  ConfirmPassword.text.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          "Password & Confirm Password can't be empty")),
                                );
                              } else if (Password.text.isEmpty &&
                                  ConfirmPassword.text.isNotEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text("Please Enter Password")),
                                );
                              } else if (Password.text.isNotEmpty &&
                                  ConfirmPassword.text.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          "Please Enter Confirm Password")),
                                );
                              } else if (Password.text !=
                                  ConfirmPassword.text) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text("Password doesn't match")),
                                );
                              } else if (Email.text.isEmpty &&
                                  Password.text == ConfirmPassword.text) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                          Text("Please Enter Email Address")),
                                );
                              } else {
                                await checkLogin(Email.text, Password.text);
                              }
                              // bool isValid = await checkLogin(userName.text, Password.text);
                              // if (isValid) {
                              //   context.go('/Home');
                              //   ScaffoldMessenger.of(context).showSnackBar(
                              //     const SnackBar(content: Text("Something went wrong")),
                              //   );
                              // }
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
                                  'Create Account',
                                  style: TextStyle(color: Colors.white),
                                )),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      Align(
                        alignment: const Alignment(0.1, 0.0),
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'Already have an account ? ',
                                style: TextStyle(
                                  color: Colors.black,
                                ),
                              ),
                              TextSpan(
                                text: 'Log in',
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => LoginScr()),
                                    );
                                  },
                              ),
                            ],
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
      },
    );
  }
}

class ImageContainer1 extends StatelessWidget {
  const ImageContainer1({super.key});

  @override
  Widget build(BuildContext context) {
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
}
