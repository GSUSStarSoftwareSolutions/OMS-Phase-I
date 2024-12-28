import 'dart:convert';
import 'package:btb/widgets/Api%20name.dart';
import 'package:btb/login/login.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import '../widgets/text_style.dart';



class Createscr extends StatefulWidget {
  const Createscr({super.key});

  @override
  State<Createscr> createState() => _CreatescrState();
}

class _CreatescrState extends State<Createscr> {
  final userName = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  final confirmPassword = TextEditingController();
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

  Future<String?> checkLogin(String email, String password) async {
    String url = '$apicall/public/user_master/add_password/$email/$password';
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
          builder: (BuildContext context)  {
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid response from server")),
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          body: Container(
            constraints: BoxConstraints(maxWidth: constraints.maxWidth * 0.8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: constraints.maxHeight * 0.18),
                Align(
                  alignment: const Alignment(0.05, 0.0),
                  child: Text(
                      'Create an Account',
                      style: TextStyles.login(context)
                  ),
                ),
                SizedBox(height: constraints.maxHeight * 0.03),
                Align(
                  alignment: const Alignment(0.9, 0.4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: constraints.maxHeight * 0.04),
                      Align(
                          alignment:const Alignment(-0.33, 0.0),
                          child: Text(
                            'Email Address',
                            style: TextStyles.header3,
                          )),
                      const SizedBox(height: 10),
                      Align(
                        alignment: const Alignment(0.1, 0.0),
                        child: SizedBox(
                          height: 40,
                          width: constraints.maxWidth * 0.39,
                          child: TextFormField(
                            controller: email,
                            style: GoogleFonts.inter(
                                color: Colors.black,
                                fontSize: 13),
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
                              FilteringTextInputFormatter.allow(RegExp(r'[a-z0-9@._]')),
                            ],
                          ),

                        ),
                      ),
                      const SizedBox(height: 10),
                      Align(
                          alignment:const Alignment(-0.32, 0.0),
                          child: Text(
                            'New Password',
                            style:TextStyles.header3,
                          )),
                      const SizedBox(height: 10),
                      Align(
                        alignment: const Alignment(0.1, 0.0),
                        child: SizedBox(
                          height: 40,
                          width: constraints.maxWidth * 0.39,
                          child: TextFormField(
                            controller: password,
                            style: GoogleFonts.inter(
                                color: Colors.black,
                                fontSize: 13),
                            obscureText: _obscureText1,
                            decoration: InputDecoration(
                              border: const OutlineInputBorder(),
                              hintText: 'Enter your new password',
                              hintStyle: const TextStyle(fontSize: 13),
                              contentPadding: const EdgeInsets.symmetric(
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
                      Align(
                          alignment: const Alignment(-0.29, 0.0),
                          child: Text(
                            'Confirm Password',
                            style: TextStyles.header3,
                          )),
                      const SizedBox(height: 10),
                      Align(
                        alignment: const Alignment(0.1, 0.0),
                        child: SizedBox(
                          height: 40,
                          width: constraints.maxWidth * 0.39,
                          child: TextFormField(
                            controller: confirmPassword,
                            style: GoogleFonts.inter(
                                color: Colors.black,
                                fontSize: 13),
                            obscureText: _obscureText,
                            decoration: InputDecoration(
                              border: const OutlineInputBorder(),
                              hintText: 'Enter your confirm password',
                              hintStyle: const TextStyle(fontSize: 13),
                              contentPadding: const EdgeInsets.symmetric(
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
                              if (password.text.isEmpty &&
                                  confirmPassword.text.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          "Password & Confirm Password can't be empty")),
                                );
                              } else if (password.text.isEmpty &&
                                  confirmPassword.text.isNotEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text("Please Enter Password")),
                                );
                              } else if (password.text.isNotEmpty &&
                                  confirmPassword.text.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          "Please Enter Confirm Password")),
                                );
                              } else if (password.text !=
                                  confirmPassword.text) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text("Password doesn't match")),
                                );
                              } else if (email.text.isEmpty &&
                                  password.text == confirmPassword.text) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                      Text("Please Enter Email Address")),
                                );
                              } else {
                                await checkLogin(email.text, password.text);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[800],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            child:  Align(
                                alignment: const Alignment(0.0, 0.0),
                                child: Text(
                                  'Create Account',
                                  style: TextStyles.button1,
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
                                  style:TextStyles.need
                              ),
                              TextSpan(
                                text: 'Log in',
                                style:
                                TextStyles.contact,
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>  LoginScr()),
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

