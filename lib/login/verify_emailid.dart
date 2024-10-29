import 'dart:convert';
import 'package:btb/admin/Api%20name.dart';
import 'package:btb/login/login.dart';
import 'package:btb/login/verification%20screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;




void main(){
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,home:Logout() ,));
}

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
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  //String token = 'eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJkaGFuYXNla2FyIiwiUm9sZXMiOlt7ImF1dGhvcml0eSI6ImRldmVsb3BlciJ9XSwiZXhwIjoxNzI0MDY4OTA2LCJpYXQiOjE3MjQwNjE3MDZ9.fMytRq63vAUoY6EznqxAMZypkrKXhipw2_EzcGI1u1WlPybusWBGrhifQ3e5KxMhKfeuJ6Tn2Jda5KCiBaxVhg';

  // Future<void> _forgetPassword() async {
  //   try {
  //     final Uri apiUri = Uri.parse(
  //       '$apicall/email/forget_password',
  //     );
  //
  //     final Map<String, String> headers = {
  //       'Content-Type': 'application/json',
  //     };
  //
  //     final Map<String, dynamic> body = {
  //       'email': emailController.text,
  //     };
  //
  //     final http.Response response = await http.post(
  //       apiUri,
  //       headers: headers,
  //       body: jsonEncode(body),
  //     );
  //
  //     if (response.statusCode == 200) {
  //       // Success response handling
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text('Mail sent successfully')),
  //       );
  //     } else {
  //       // Handle server errors
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text('Failed to send mail: ${response.statusCode}'),
  //         ),
  //       );
  //     }
  //   } catch (e) {
  //     // Network or other unexpected error handling
  //     print('Error: $e');
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Error: $e')),
  //     );
  //   }
  // }

  //
  // Future<void> resetPassword(String email) async {
  //   final url = Uri.parse('$apicall/email/forget_password');
  //
  //   final response = await http.post(
  //     url,
  //     headers:{
  //       "Content-Type": "application/json",
  //      // "Authorization": 'Bearer $token',
  //
  //     },
  //     body: jsonEncode({
  //       'email': email,
  //     }),
  //   );
  //
  //   if (response.statusCode == 200) {
  //     // If the server returns an OK response, parse the JSON
  //     print('Password reset email sent successfully.');
  //   } else {
  //     // If the server did not return an OK response, throw an exception
  //     print('Failed to send password reset email.');
  //   }
  // }








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
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              icon: Icon(Icons.check_circle_rounded,color: Colors.green,size: 25,),
              content: const Padding(padding:
              EdgeInsets.only(left: 35),
                  child: Text(
                      'A verification code has been \nsent successfully.Please \ncheck your email.')
              ),
              actions: [
                TextButton(
                  child: Text('OK'),
                  onPressed: () {
                    // context.go('/');
                    //   context.go('/Forget_password');
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation,
                            secondaryAnimation) =>
                            Verify(),
                        transitionDuration:
                        const Duration(milliseconds: 5),
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
                ),
              ],
            );
          },
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send mail: ${response.statusCode}')),
        );
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: Network or CORS issue')),
      );
    }
  }






  // void _handleResetPassword() {
  //   final email = emailController.text;
  //   resetPassword(email);
  // }


  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          constraints: BoxConstraints(maxWidth: constraints.maxWidth * 0.5), // 80% of screen width
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: constraints.maxHeight * 0.2), // 10% of screen height
              Align(
                alignment: Alignment(-0.30, 0.5),
                child: SizedBox(
                  height: 35,
                  width: constraints.maxWidth * 0.15,
                  child: OutlinedButton(
                    // onPressed: handleButtonPress,
                    //my copy
                    onPressed: (){
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
                           LoginScr(
                          ),
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
                     // mainAxisSize: MainAxisSize.min,
                      //crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        IconButton(onPressed: (){}, icon: Icon(Icons.arrow_circle_left_sharp,color: Colors.white,size: 17,)),
                        Text('Go Back',style: TextStyle(color: Colors.white),)
                      ],
                    )

                  ),
                ),
              ),
              SizedBox(height: 10,),
              Align(
                alignment: Alignment(-0.20, 0.5),
                child: Text(
                  'Password Reset',
                  style: TextStyle(fontSize: constraints.maxWidth * 0.035, color: Colors.blue),
                ),
              ),
              SizedBox(height: constraints.maxHeight * 0.03), // 5% of screen height
              Align(
                alignment: Alignment(-0.14, 0.0),
                child: Text(
                  ' Enter your email address and\n we\'ll send you  a link to \n reset your password',
                  style: TextStyle(fontSize: constraints.maxWidth * 0.023),
                ),
              ),
              SizedBox(height: constraints.maxHeight * 0.03), // 5% of screen height
              Align(
                alignment: const Alignment(0.9, 0.4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: constraints.maxHeight * 0.04),
                    Align(
                      alignment: const Alignment(-0.325, 0.0),
                      child: Text('Email Address', style: TextStyle(fontSize: constraints.maxWidth * 0.015,fontWeight: FontWeight.bold),),
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
                            border: OutlineInputBorder(),
                            hintText: 'Enter your E-mail Address',
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: constraints.maxWidth * 0.02,
                              vertical: constraints.maxHeight * 0.001,
                            ),
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp("[a-zA-Z,0-9,@.]")),
                            FilteringTextInputFormatter.deny(RegExp(r'^\s')),
                            FilteringTextInputFormatter.deny(RegExp(r'\s\s')),
                          ],
                          // validator: (value) {
                          //              if (value == null || value.isEmpty) {
                          //                  return 'Please enter an email';
                          //                }
                          //              return null;
                          //            },
                          // onFieldSubmitted: (value) {
                          //   // if (checkLogin(userName.text, password.text)) {
                          //   //   Navigator.push(
                          //   //     context,
                          //   //     MaterialPageRoute(builder: (context) => const DashboardPage()),
                          //   //   );
                          //   // }
                          // },
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),

                    Align(
                      alignment: const Alignment(0.0, 0.8),
                      child: SizedBox(
                        width: constraints.maxWidth * 0.2,
                        child: ElevatedButton(
                          onPressed: (){
                            if(emailController.text.isEmpty || !RegExp(r'^[\w-]+(\.[\w-]+)*@gmail\.com$').hasMatch(emailController.text)){
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(
                                    'Enter Valid E-mail Address')),
                              );
                            }else{

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
                              alignment: Alignment(0.0, 0.0),
                              child:  Text('Reset', style: TextStyle(fontSize: constraints.maxWidth * 0.02, color: Colors.white),)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 160),
                    Align(
                      alignment: const Alignment(0.1, 0.0),
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'Need help? ',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: constraints.maxWidth * 0.02,
                              ),
                            ),
                            TextSpan(
                              text: 'Contact Support',
                              style: TextStyle(
                                color: Colors.blue,
                                fontSize: constraints.maxWidth * 0.02,
                              ),
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
              width: MediaQuery.of(context).size.width * 0.4, // Take 70% of screen width
              height: MediaQuery.of(context).size.width * 0.3, // Take 70% of screen width
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