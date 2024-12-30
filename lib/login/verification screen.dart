import 'dart:convert';
import 'package:btb/widgets/Api%20name.dart';
import 'package:btb/login/confirm%20password.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import 'login.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Verify(),
  ));
}

class Verify extends StatefulWidget {
  const Verify({super.key});

  @override
  State<Verify> createState() => _VerifyState();
}

class _VerifyState extends State<Verify> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Row(
        children: [
          Expanded(
            flex: 3,
            child: ImageContainer1(),
          ),
          Expanded(
            flex: 3,
            child: VerificationScr(),
          ),
        ],
      ),
    );
  }
}

class VerificationScr extends StatefulWidget {
  const VerificationScr({super.key});

  @override
  State<VerificationScr> createState() => _VerificationScrState();
}

class _VerificationScrState extends State<VerificationScr> {
  final userName = TextEditingController();
  bool _obscureText = true;
  String verificationCode = '';

  Future<void> _gerVerificationcode(BuildContext context, String otp) async {
    try {
      final Uri apiUri = Uri.parse(
        '$apicall/email/validate_otp',
      );

      final Map<String, String> headers = {
        'Content-Type': 'application/json',
      };

      final Map<String, dynamic> body = {
        'otp': userName.text,
      };

      final http.Response response = await http.post(
        apiUri,
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        verificationCode = userName.text;
        if (response.body == 'Invalid OTP') {
          showDialog(
            barrierDismissible: false,
            context: context,
            builder: (context) {
              return AlertDialog(
                icon: const Icon(Icons.warning_rounded,
                    color: Colors.orange, size: 25),
                content: const Padding(
                  padding: EdgeInsets.only(left: 75),
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
                    child: Text('Your OTP has been verified.')),
                actions: <Widget>[
                  TextButton(
                    child: const Text('OK'),
                    onPressed: () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
                                  confirmPassword(
                                      verificationcode: verificationCode),
                          transitionDuration: const Duration(milliseconds: 5),
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
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Failed to otp incorrect code ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxHeight >= 630) {
          return Container(
            constraints: BoxConstraints(maxWidth: constraints.maxWidth * 0.5),
            // 80% of screen width
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
                              pageBuilder:
                                  (context, animation, secondaryAnimation) =>
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
                  alignment: const Alignment(-0.18, 0.5),
                  child: Text(
                    'Verify Your Email',
                    style: TextStyle(
                        fontSize: constraints.maxWidth * 0.035,
                        color: Colors.blue),
                  ),
                ),
                SizedBox(height: constraints.maxHeight * 0.03),
                Align(
                  alignment: const Alignment(-0.16, 0.0),
                  child: Text(
                    'Enter the verification code\nsent to your email address,\nand we\'ll help you\nreset your password.',
                    style: TextStyle(fontSize: constraints.maxWidth * 0.023),
                  ),
                ),
                SizedBox(height: constraints.maxHeight * 0.03),
                Align(
                  alignment: const Alignment(0.9, 0.4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: constraints.maxHeight * 0.04),
                      const Align(
                        alignment: Alignment(-0.3, 0.0),
                        child: Text(
                          'Verification Code',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Align(
                        alignment: const Alignment(0.0, 0.8),
                        child: SizedBox(
                          height: 30,
                          width: constraints.maxWidth * 0.4,
                          child: TextFormField(
                            controller: userName,
                            obscureText: _obscureText,
                            decoration: InputDecoration(
                              border: const OutlineInputBorder(),
                              hintText: 'Enter your verification code',
                              hintStyle: TextStyle(
                                  fontSize: MediaQuery.of(context).size.width *
                                      0.010),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal:
                                    MediaQuery.of(context).size.width * 0.01,
                                vertical:
                                    MediaQuery.of(context).size.height * 0.001,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureText
                                      ? Icons.visibility_off
                                      : Icons.visibility_rounded,
                                  size: 18,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscureText = !_obscureText;
                                    ;
                                  });
                                },
                              ),
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(6),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      Align(
                        alignment: const Alignment(0.0, 0.8),
                        child: SizedBox(
                          width: constraints.maxWidth * 0.2,
                          child: ElevatedButton(
                            onPressed: () {
                              if (userName.text.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          'Please Fill Verification Code')),
                                );
                              } else {
                                _gerVerificationcode(context, verificationCode);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[800],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            child: Align(
                                alignment: const Alignment(0.0, 0.0),
                                child: Text(
                                  'Verify',
                                  style: TextStyle(
                                      fontSize: constraints.maxWidth * 0.02,
                                      color: Colors.white),
                                )),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        } else {
          return Container(
            constraints: BoxConstraints(maxWidth: constraints.maxWidth * 0.5),
            // 80% of screen width
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
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
                                pageBuilder:
                                    (context, animation, secondaryAnimation) =>
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
                    alignment: const Alignment(-0.18, 0.5),
                    child: Text(
                      'Verify Your Email',
                      style: TextStyle(
                          fontSize: constraints.maxWidth * 0.035,
                          color: Colors.blue),
                    ),
                  ),
                  SizedBox(height: constraints.maxHeight * 0.03),
                  Align(
                    alignment: const Alignment(-0.16, 0.0),
                    child: Text(
                      'Enter the verification code\nsent to your email address,\nand we\'ll help you\nreset your password.',
                      style: TextStyle(fontSize: constraints.maxWidth * 0.023),
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
                          alignment: Alignment(-0.3, 0.0),
                          child: Text(
                            'Verification Code',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Align(
                          alignment: const Alignment(0.0, 0.8),
                          child: SizedBox(
                            height: 30,
                            width: constraints.maxWidth * 0.4,
                            child: TextFormField(
                              controller: userName,
                              obscureText: _obscureText,
                              decoration: InputDecoration(
                                border: const OutlineInputBorder(),
                                hintText: 'Enter your verification code',
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal:
                                      MediaQuery.of(context).size.width * 0.01,
                                  vertical: MediaQuery.of(context).size.height *
                                      0.001,
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscureText
                                        ? Icons.visibility_off
                                        : Icons.visibility_rounded,
                                    size: 18,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscureText = !_obscureText;
                                      ;
                                    });
                                  },
                                ),
                              ),
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(6),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                        Align(
                          alignment: const Alignment(0.0, 0.8),
                          child: SizedBox(
                            width: constraints.maxWidth * 0.2,
                            child: ElevatedButton(
                              onPressed: () {
                                if (userName.text.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            'Please Fill Verification Code')),
                                  );
                                } else {
                                  _gerVerificationcode(
                                      context, verificationCode);
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue[800],
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              child: Align(
                                  alignment: const Alignment(0.0, 0.0),
                                  child: Text(
                                    'Verify',
                                    style: TextStyle(
                                        fontSize: constraints.maxWidth * 0.02,
                                        color: Colors.white),
                                  )),
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

class ImageContainer1 extends StatelessWidget {
  const ImageContainer1({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxHeight >= 630) {
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
        );
      } else {
        return Container(
          width: double.infinity,
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
        );
      }
    });
  }
}
