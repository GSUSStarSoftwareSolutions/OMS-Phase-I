import 'dart:convert';
import 'package:btb/widgets/Api%20name.dart';
import 'package:btb/login/login.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class confirmPassword extends StatefulWidget {
  String verificationcode;

  confirmPassword({super.key, required this.verificationcode});

  @override
  State<confirmPassword> createState() => _confirmPasswordState();
}

class _confirmPasswordState extends State<confirmPassword> {
  String otp = '';
  final password = TextEditingController();
  final confirmPassword = TextEditingController();
  bool _obscureText = true;
  bool _obscureText2 = true;
  String? _passwordError;
  final _formKey = GlobalKey<FormState>();

  void initState() {
    // TODO: implement initState
    super.initState();
  }

  Future<void> _changePassword(BuildContext context, String otp,
      String newPassword, String confirmPassword) async {
    try {
      final Uri apiUri = Uri.parse(
        '$apicall/email/change_password',
      );

      final Map<String, String> headers = {
        'Content-Type': 'application/json',
      };

      final Map<String, dynamic> body = {
        'otp': widget.verificationcode,
        'newPassword': newPassword,
        'confirmPassword': confirmPassword,
      };

      final http.Response response = await http.post(
        apiUri,
        headers: headers,
        body: jsonEncode(body),
      );
      if (response.statusCode == 200) {
        showDialog(
          barrierDismissible: false,
          context: context,
          builder: (context) {
            return AlertDialog(
              icon: const Icon(
                Icons.check_circle_rounded,
                color: Colors.green,
                size: 25,
              ),
              content: const Padding(
                  padding: EdgeInsets.only(left: 35),
                  child:
                      Text('Your password has been\n changed successfully.')),
              actions: <Widget>[
                TextButton(
                  child: const Text('OK'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            LoginScr(),
                        transitionDuration: const Duration(milliseconds: 200),
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
                          return FadeTransition(
                            opacity: animation,
                            child: child,
                          );
                        },
                      ),
                    );
                  },
                ),
              ],
            );
          },
        );
      } else if (response.body == 'Invalid OTP') {
        showDialog(
          barrierDismissible: false,
          context: context,
          builder: (context) {
            return AlertDialog(
              icon: const Icon(Icons.warning_rounded,
                  color: Colors.red, size: 25),
              content: const Padding(
                padding: EdgeInsets.only(left: 65),
                child: Text('Invalid OTP'),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('OK'),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            );
          },
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Failed to change password: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          body: LayoutBuilder(builder: (context, constraints) {
            return Row(
              children: [
                if (constraints.maxHeight >= 630) ...{
                  Expanded(
                    flex: 3,
                    child: Container(
                      width: double.infinity, // Take full width
                      color: Colors.grey[100],
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 40, left: 25),
                            child: Image.asset('images/Final-Ikyam-Logo.png'),
                          ),
                          const SizedBox(height: 50),
                          Center(
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width * 0.4,
                              height: MediaQuery.of(context).size.width * 0.3,
                              child: Image.asset(
                                'images/ikyam1.png',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Container(
                      constraints:
                          BoxConstraints(maxWidth: constraints.maxWidth * 0.8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(height: constraints.maxHeight * 0.2),
                          Align(
                            alignment: const Alignment(-0.30, 0.5),
                            child: SizedBox(
                              height: 35,
                              width: 100,
                              child: OutlinedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      PageRouteBuilder(
                                        pageBuilder: (context, animation,
                                                secondaryAnimation) =>
                                            LoginScr(),
                                        transitionDuration:
                                            const Duration(milliseconds: 200),
                                        transitionsBuilder: (context, animation,
                                            secondaryAnimation, child) {
                                          return FadeTransition(
                                            opacity: animation,
                                            child: child,
                                          );
                                        },
                                      ),
                                    );
                                  },
                                  style: OutlinedButton.styleFrom(
                                    backgroundColor: Colors.blue[800],
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                    side: BorderSide.none,
                                    padding: EdgeInsets.zero,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      IconButton(
                                          onPressed: () {},
                                          icon: const Icon(
                                            Icons.arrow_circle_left_sharp,
                                            color: Colors.white,
                                            size: 17,
                                          )),
                                      const Text(
                                        'Go Back',
                                        style: TextStyle(color: Colors.white),
                                      )
                                    ],
                                  )),
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Align(
                            alignment: const Alignment(-0.016, 0.0),
                            child: Text(
                              'Create New Password',
                              style: TextStyle(
                                  fontSize: constraints.maxWidth * 0.02,
                                  color: Colors.blue),
                            ),
                          ),
                          SizedBox(height: constraints.maxHeight * 0.03),
                          Align(
                            alignment: const Alignment(-0.046, 0.0),
                            child: Text(
                              'Your New Password Must Be \nDifferent from Previously Used Password',
                              style: TextStyle(
                                  fontSize: constraints.maxWidth * 0.01),
                            ),
                          ),
                          SizedBox(height: constraints.maxHeight * 0.03),
                          Align(
                            alignment: const Alignment(0.9, 0.4),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                      height: constraints.maxHeight * 0.04),
                                  Align(
                                      alignment: const Alignment(-0.300, 0.0),
                                      child: Text(
                                        'New Password',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize:
                                                constraints.maxWidth * 0.01),
                                      )),
                                  const SizedBox(height: 5),
                                  Align(
                                    alignment: const Alignment(0.0, 0.6),
                                    child: SizedBox(
                                      height: 40,
                                      width: constraints.maxWidth * 0.2,
                                      child: TextFormField(
                                        obscureText: _obscureText,
                                        controller: password,
                                        decoration: InputDecoration(
                                          border: const OutlineInputBorder(),
                                          suffixIcon: IconButton(
                                              onPressed: () {
                                                setState(() {
                                                  _obscureText = !_obscureText;
                                                });
                                              },
                                              icon: Icon(
                                                _obscureText
                                                    ? Icons.visibility_off
                                                    : Icons.visibility_rounded,
                                                size: 18,
                                              )),
                                          hintText: 'Enter your new password',
                                          hintStyle:
                                              const TextStyle(fontSize: 15),
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 8,
                                          ),
                                        ),
                                        inputFormatters: [
                                          FilteringTextInputFormatter.allow(
                                              RegExp('.*')),
                                          FilteringTextInputFormatter.deny(
                                              RegExp(r'^\s')),
                                          FilteringTextInputFormatter.deny(
                                              RegExp(r'\s\s')),
                                        ],
                                        onFieldSubmitted: (value) async {},
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  Align(
                                      alignment: const Alignment(-0.280, 0.0),
                                      child: Text(
                                        'Confirm Password',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize:
                                                constraints.maxWidth * 0.01),
                                      )),
                                  const SizedBox(height: 5),
                                  Align(
                                    alignment: const Alignment(0.0, 0.6),
                                    child: SizedBox(
                                      height: 40,
                                      width: constraints.maxWidth * 0.2,
                                      child: TextFormField(
                                        obscureText: _obscureText2,
                                        controller: confirmPassword,
                                        decoration: InputDecoration(
                                            border: const OutlineInputBorder(),
                                            hintText:
                                                'Enter your confirm password',
                                            hintStyle:
                                                const TextStyle(fontSize: 15),
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 8,
                                            ),
                                            errorText: _passwordError,
                                            suffixIcon: IconButton(
                                                onPressed: () {
                                                  setState(() {
                                                    _obscureText2 =
                                                        !_obscureText2;
                                                  });
                                                },
                                                icon: Icon(
                                                  _obscureText2
                                                      ? Icons.visibility_off
                                                      : Icons
                                                          .visibility_rounded,
                                                  size: 18,
                                                ))),
                                        inputFormatters: [
                                          FilteringTextInputFormatter.allow(
                                              RegExp('.*')),
                                          FilteringTextInputFormatter.deny(
                                              RegExp(r'^\s')),
                                          FilteringTextInputFormatter.deny(
                                              RegExp(r'\s\s')),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 60,
                                  ),
                                  Align(
                                    alignment: const Alignment(0.0, 0.6),
                                    child: SizedBox(
                                      width: constraints.maxWidth * 0.1,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          if (password.text.isEmpty &&
                                              confirmPassword.text.isEmpty) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                  content: Text(
                                                      'New Password and Confirm Password field are required')),
                                            );
                                          } else if (password.text.isEmpty &&
                                              confirmPassword.text.isNotEmpty) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                  content: Text(
                                                      'Please Enter Password')),
                                            );
                                          } else if (password.text.isNotEmpty &&
                                              confirmPassword.text.isEmpty) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                  content: Text(
                                                      'Please Enter Confirm Password')),
                                            );
                                          } else if (password.text ==
                                              confirmPassword.text) {
                                            _changePassword(
                                                context,
                                                '',
                                                password.text,
                                                confirmPassword.text);
                                          } else {
                                            showDialog(
                                              barrierDismissible: false,
                                              context: context,
                                              builder: (context) {
                                                return AlertDialog(
                                                  icon: const Icon(
                                                    Icons
                                                        .warning_amber_outlined,
                                                    color: Colors.red,
                                                    size: 25,
                                                  ),
                                                  content: const Padding(
                                                      padding: EdgeInsets.only(
                                                          left: 35),
                                                      child: Text(
                                                          'Both Passwords do not match.')),
                                                  actions: <Widget>[
                                                    TextButton(
                                                      child: const Text('OK'),
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                      },
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
                                          }
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.blue[800],
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                        ),
                                        child: const Align(
                                            alignment: Alignment(0.0, 0.0),
                                            child: Text(
                                              'Save',
                                              style: TextStyle(
                                                  color: Colors.white),
                                            )),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                } else ...{
                  Expanded(
                    flex: 3,
                    child: Container(
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
                            const SizedBox(height: 50),
                            Center(
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width * 0.4,
                                height: MediaQuery.of(context).size.width * 0.7,
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
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Container(
                      constraints:
                          BoxConstraints(maxWidth: constraints.maxWidth * 0.8),
                      // 80% of screen width
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(height: constraints.maxHeight * 0.2),
                            Align(
                              alignment: const Alignment(-0.30, 0.5),
                              child: SizedBox(
                                height: 35,
                                width: 100,
                                child: OutlinedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        PageRouteBuilder(
                                          pageBuilder: (context, animation,
                                                  secondaryAnimation) =>
                                              LoginScr(),
                                          transitionDuration:
                                              const Duration(milliseconds: 200),
                                          transitionsBuilder: (context,
                                              animation,
                                              secondaryAnimation,
                                              child) {
                                            return FadeTransition(
                                              opacity: animation,
                                              child: child,
                                            );
                                          },
                                        ),
                                      );
                                    },
                                    style: OutlinedButton.styleFrom(
                                      backgroundColor: Colors.blue[800],
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                      side: BorderSide.none,
                                      padding: EdgeInsets.zero,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        IconButton(
                                            onPressed: () {},
                                            icon: const Icon(
                                              Icons.arrow_circle_left_sharp,
                                              color: Colors.white,
                                              size: 17,
                                            )),
                                        const Text(
                                          'Go Back',
                                          style: TextStyle(color: Colors.white),
                                        )
                                      ],
                                    )),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Align(
                              alignment: const Alignment(-0.016, 0.0),
                              child: Text(
                                'Create New Password',
                                style: TextStyle(
                                    fontSize: constraints.maxWidth * 0.02,
                                    color: Colors.blue),
                              ),
                            ),
                            SizedBox(height: constraints.maxHeight * 0.03),
                            Align(
                              alignment: const Alignment(-0.046, 0.0),
                              child: Text(
                                'Your New Password Must Be \nDifferent from Previously Used Password',
                                style: TextStyle(
                                    fontSize: constraints.maxWidth * 0.01),
                              ),
                            ),
                            SizedBox(height: constraints.maxHeight * 0.03),
                            Align(
                              alignment: const Alignment(0.9, 0.4),
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                        height: constraints.maxHeight * 0.04),
                                    Align(
                                        alignment: const Alignment(-0.300, 0.0),
                                        child: Text(
                                          'New Password',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize:
                                                  constraints.maxWidth * 0.01),
                                        )),
                                    const SizedBox(height: 5),
                                    Align(
                                      alignment: const Alignment(0.0, 0.6),
                                      child: SizedBox(
                                        height: 40,
                                        width: constraints.maxWidth * 0.2,
                                        child: TextFormField(
                                          obscureText: _obscureText,
                                          controller: password,
                                          decoration: InputDecoration(
                                            border: const OutlineInputBorder(),
                                            suffixIcon: IconButton(
                                                onPressed: () {
                                                  setState(() {
                                                    _obscureText =
                                                        !_obscureText;
                                                  });
                                                },
                                                icon: Icon(
                                                  _obscureText
                                                      ? Icons.visibility_off
                                                      : Icons
                                                          .visibility_rounded,
                                                  size: 18,
                                                )),
                                            hintText: 'Enter your new password',
                                            hintStyle: TextStyle(
                                                fontSize: constraints.maxWidth *
                                                    0.01),
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 8,
                                            ),
                                          ),
                                          inputFormatters: [
                                            FilteringTextInputFormatter.allow(
                                                RegExp('.*')),
                                            FilteringTextInputFormatter.deny(
                                                RegExp(r'^\s')),
                                            FilteringTextInputFormatter.deny(
                                                RegExp(r'\s\s')),
                                          ],
                                          onFieldSubmitted: (value) async {},
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    Align(
                                        alignment: const Alignment(-0.280, 0.0),
                                        child: Text(
                                          'Confirm Password',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize:
                                                  constraints.maxWidth * 0.01),
                                        )),
                                    const SizedBox(height: 5),
                                    Align(
                                      alignment: const Alignment(0.0, 0.6),
                                      child: SizedBox(
                                        height: 40,
                                        width: constraints.maxWidth * 0.2,
                                        child: TextFormField(
                                          obscureText: _obscureText2,
                                          controller: confirmPassword,
                                          decoration: InputDecoration(
                                              border:
                                                  const OutlineInputBorder(),
                                              hintText:
                                                  'Enter your confirm password',
                                              hintStyle: TextStyle(
                                                  fontSize:
                                                      constraints.maxWidth *
                                                          0.01),
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 10,
                                                vertical: 8,
                                              ),
                                              errorText: _passwordError,
                                              suffixIcon: IconButton(
                                                  onPressed: () {
                                                    setState(() {
                                                      _obscureText2 =
                                                          !_obscureText2;
                                                    });
                                                  },
                                                  icon: Icon(
                                                    _obscureText2
                                                        ? Icons.visibility_off
                                                        : Icons
                                                            .visibility_rounded,
                                                    size: 18,
                                                  ))),
                                          inputFormatters: [
                                            FilteringTextInputFormatter.allow(
                                                RegExp('.*')),
                                            FilteringTextInputFormatter.deny(
                                                RegExp(r'^\s')),
                                            FilteringTextInputFormatter.deny(
                                                RegExp(r'\s\s')),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 60,
                                    ),
                                    Align(
                                      alignment: const Alignment(0.0, 0.6),
                                      child: SizedBox(
                                        width: constraints.maxWidth * 0.1,
                                        child: ElevatedButton(
                                          onPressed: () {
                                            if (password.text.isEmpty &&
                                                confirmPassword.text.isEmpty) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                    content: Text(
                                                        'New Password and Confirm Password field are required')),
                                              );
                                            } else if (password.text.isEmpty &&
                                                confirmPassword
                                                    .text.isNotEmpty) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                    content: Text(
                                                        'Please Enter Password')),
                                              );
                                            } else if (password
                                                    .text.isNotEmpty &&
                                                confirmPassword.text.isEmpty) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                    content: Text(
                                                        'Please Enter Confirm Password')),
                                              );
                                            } else if (password.text ==
                                                confirmPassword.text) {
                                              _changePassword(
                                                  context,
                                                  '',
                                                  password.text,
                                                  confirmPassword.text);
                                            } else {
                                              showDialog(
                                                barrierDismissible: false,
                                                context: context,
                                                builder: (context) {
                                                  return AlertDialog(
                                                    icon: const Icon(
                                                      Icons
                                                          .warning_amber_outlined,
                                                      color: Colors.red,
                                                      size: 25,
                                                    ),
                                                    content: const Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                                left: 35),
                                                        child: Text(
                                                            'Both Passwords do not match.')),
                                                    actions: <Widget>[
                                                      TextButton(
                                                        child: const Text('OK'),
                                                        onPressed: () {
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                      ),
                                                    ],
                                                  );
                                                },
                                              );
                                            }
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.blue[800],
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                          ),
                                          child: const Align(
                                              alignment: Alignment(0.0, 0.0),
                                              child: Text(
                                                'Save',
                                                style: TextStyle(
                                                    color: Colors.white),
                                              )),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 140),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                }
              ],
            );
          }),
        );
      },
    );
  }
}
