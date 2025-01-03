import 'dart:convert';
import 'package:btb/widgets/Api%20name.dart';
import 'package:btb/login/login.dart';
import 'package:btb/login/verification%20screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import '../widgets/text_style.dart';

class Logout extends StatefulWidget {
  const Logout({super.key});

  @override
  State<Logout> createState() => _LoginScrState();
}

class _LoginScrState extends State<Logout> {
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
            child: LogoutContainer1(),
          ),
        ],
      ),
    );
  }
}

class LogoutContainer1 extends StatefulWidget {
  const LogoutContainer1({super.key});

  @override
  State<LogoutContainer1> createState() => _LogoutContainer1State();
}

class _LogoutContainer1State extends State<LogoutContainer1> {
  final emailController = TextEditingController();

  Future<void> _forgetPassword(BuildContext context, String email) async {
    try {
      final Uri apiUri = Uri.parse(
        '$apicall/email/forget_password',
      );

      final Map<String, String> headers = {
        'Content-Type': 'application/json',
      };

      final Map<String, dynamic> body = {
        'email': email,
      };

      final http.Response response = await http.post(
        apiUri,
        headers: headers,
        body: jsonEncode(body),
      );

      print(response);

      if (response.statusCode == 200) {
        if (response.body == 'email not found') {
          showDialog(
            barrierDismissible: false,
            context: context,
            builder: (context) {
              return AlertDialog(
                icon: const Icon(Icons.warning_rounded,
                    color: Colors.orange, size: 25),
                content: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Email address not found'),
                  ],
                ),
                actions: [
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
        } else if (response.body == 'Reset password email sent successfully') {
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
                content: Padding(
                    padding: const EdgeInsets.only(left: 35),
                    child: Text(
                      'A verification code has been \nsent successfully.Please \ncheck your email.',
                      style: TextStyles.contact1,
                    )),
                actions: [
                  TextButton(
                    child: const Text('OK'),
                    onPressed: () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
                                  const Verify(),
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
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Something went wrong')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to send mail: ${response.statusCode}')),
        );
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Network or CORS issue')),
      );
    }
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
                // 10% of screen height
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
                  alignment: const Alignment(-0.20, 0.5),
                  child:
                      Text('Password Reset', style: TextStyles.pass(context)),
                ),
                SizedBox(height: constraints.maxHeight * 0.03),
                // 5% of screen height
                Align(
                  alignment: const Alignment(-0.14, 0.0),
                  child: Text(
                      ' Enter your email address and\n we\'ll send you  a link to \n reset your password',
                      style: TextStyles.subhead1),
                ),
                SizedBox(height: constraints.maxHeight * 0.03),
                Align(
                  alignment: const Alignment(0.9, 0.4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: constraints.maxHeight * 0.04),
                      Align(
                        alignment: const Alignment(-0.325, 0.0),
                        child: Text('Email Address',
                            style: TextStyles.email(context)),
                      ),
                      const SizedBox(height: 10),
                      Align(
                        alignment: const Alignment(0.0, 0.8),
                        child: SizedBox(
                          height: 40,
                          width: constraints.maxWidth * 0.4,
                          child: TextFormField(
                            controller: emailController,
                            style: GoogleFonts.inter(
                                color: Colors.black, fontSize: 13),
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              hintStyle: TextStyle(fontSize: 15),
                              hintText: 'Enter your email',
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 8,
                              ),
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp("[a-zA-Z,0-9,@.]")),
                              FilteringTextInputFormatter.deny(RegExp(r'^\s')),
                              FilteringTextInputFormatter.deny(RegExp(r'\s\s')),
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
                              if (emailController.text.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                          Text('Enter Valid E-mail Address')),
                                );
                              } else {
                                _forgetPassword(context, emailController.text);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[800],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            child: Align(
                                alignment: const Alignment(0.0, 0.0),
                                child:
                                    Text('Reset', style: TextStyles.button1)),
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
                  const SizedBox(height: 40), // 10% of screen height
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
                    alignment: const Alignment(-0.20, 0.5),
                    child: Text(
                      'Password Reset',
                      style: TextStyle(
                          fontSize: constraints.maxWidth * 0.035,
                          color: Colors.blue),
                    ),
                  ),
                  SizedBox(height: constraints.maxHeight * 0.03),
                  Align(
                    alignment: const Alignment(-0.14, 0.0),
                    child: Text(
                      ' Enter your email address and\n we\'ll send you  a link to \n reset your password',
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
                        Align(
                          alignment: const Alignment(-0.325, 0.0),
                          child: Text(
                            'Email Address',
                            style: TextStyle(
                                fontSize: constraints.maxWidth * 0.015,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Align(
                          alignment: const Alignment(0.0, 0.8),
                          child: SizedBox(
                            height: 30,
                            width: constraints.maxWidth * 0.4,
                            child: TextFormField(
                              controller: emailController,
                              decoration: InputDecoration(
                                border: const OutlineInputBorder(),
                                hintText: 'Enter your E-mail Address',
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: constraints.maxWidth * 0.02,
                                  vertical: constraints.maxHeight * 0.001,
                                ),
                              ),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                    RegExp("[a-zA-Z,0-9,@.]")),
                                FilteringTextInputFormatter.deny(
                                    RegExp(r'^\s')),
                                FilteringTextInputFormatter.deny(
                                    RegExp(r'\s\s')),
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
                                if (emailController.text.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content:
                                            Text('Enter Valid E-mail Address')),
                                  );
                                } else {
                                  _forgetPassword(
                                      context, emailController.text);
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue[800],
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              child: Align(
                                  alignment: const Alignment(0.0, 0.0),
                                  child: Text(
                                    'Reset',
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
          width: double.infinity,
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
