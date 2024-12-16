import 'dart:convert';
import 'package:btb/admin/Api%20name.dart';
import 'package:btb/login/confirm%20password.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import 'login.dart';
void main(){
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,home:Verify() ,));
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
        // Success response handling
        print(response.body);
        print(userName.text);
        verificationCode =userName.text;

        if(response.body == 'Invalid OTP'){
          showDialog(
            barrierDismissible: false,
            context: context,
            builder: (context) {
              return AlertDialog(
                icon: const Icon(
                    Icons.warning_rounded, color: Colors.orange, size: 25),
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
        }else{
          showDialog(
            barrierDismissible: false,
            context: context,
            builder: (context) {
              return AlertDialog(

                icon: const Icon(
                  Icons.check_circle_rounded, color: Colors.green, size: 25,),
                content: const Padding(padding: EdgeInsets.only(left: 35),
                    child: Text(
                        'Your OTP has been verified.')),
                actions: <Widget>[
                  TextButton(
                    child: const Text('OK'),
                    onPressed: () {
                      // context.go('/');
                      // context.go('/Confirm_Password',extra: {
                      //   'verificationcode': verificationCode,
                      // });
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (context, animation,
                              secondaryAnimation) =>
                              ConfirmPassword(
                                  verificationcode: verificationCode),
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

        }

      } else {
        // Handle server errors
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to otp incorrect code ${response.statusCode}')),
        );
      }
    } catch (e) {
      // Network or other unexpected error handling
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  // Future<void> _getVerificationCode() async {
  //   try {
  //     final response = await http.post(Uri.parse('$apicall/email/validate_otp'));
  //
  //     if (response.statusCode == 200) {
  //       final data = json.decode(response.body);
  //       setState(() {
  //         verificationCode = data['verification_code'];
  //       });
  //     } else {
  //       // Handle error
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text('Error fetching verification code.')),
  //       );
  //     }
  //   } catch (e) {
  //     // Handle error
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Error: $e')),
  //     );
  //   }
  // }
  @override
  void initState() {
    super.initState();
  }



  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if(constraints.maxHeight >=630){
          return Container(
            constraints: BoxConstraints(maxWidth: constraints.maxWidth * 0.5), // 80% of screen width
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: constraints.maxHeight * 0.2),
                Align(
                  alignment: Alignment(-0.30, 0.5),
                  child: SizedBox(
                    height: 35,
                    width: 100,
                    child: OutlinedButton(
                        onPressed: (){
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
                  alignment:const Alignment(-0.18, 0.5),
                  child: Text(
                    'Verify Your Email',
                    style: TextStyle(fontSize: constraints.maxWidth * 0.035, color: Colors.blue),
                  ),
                ),
                SizedBox(height: constraints.maxHeight * 0.03), // 5% of screen height
                Align(
                  alignment: const Alignment(-0.16, 0.0),
                  child: Text(
                    // ' Enter your email address and\n we\'ll send you  a link to \n reset your password',
                    'Enter the verification code\nsent to your email address,\nand we\'ll help you\nreset your password.',
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
                        alignment: const Alignment(-0.3, 0.0),
                        child: Text('Verification Code', style: TextStyle(fontWeight: FontWeight.bold),),
                      ),
                      const SizedBox(height: 10),
                      Align(
                        alignment: const Alignment(0.0, 0.8),
                        child: SizedBox(
                          height: 30,
                          width: constraints.maxWidth * 0.4,
                          child:
                          TextFormField(
                            controller: userName,
                            obscureText: _obscureText,
                            decoration: InputDecoration(
                              border: const OutlineInputBorder(),
                              hintText: 'Enter your verification code',
                              hintStyle: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.010),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: MediaQuery.of(context).size.width * 0.01,
                                vertical: MediaQuery.of(context).size.height * 0.001,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureText ? Icons.visibility_off :  Icons.visibility_rounded ,size: 18,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscureText = !_obscureText; ;
                                  });
                                },
                              ),
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter
                                  .digitsOnly,
                              LengthLimitingTextInputFormatter(
                                  6),
                              // limits to 10 digits
                            ],
                            onFieldSubmitted: (value) {
                              // Your submission logic here
                            },
                          ),
                          // TextFormField(
                          //   controller: userName,
                          //   decoration: InputDecoration(
                          //     border: const OutlineInputBorder(),
                          //     hintText: 'Enter your verification code',
                          //     hintStyle: TextStyle(fontSize:  constraints.maxWidth * 0.018),
                          //     contentPadding: EdgeInsets.symmetric(
                          //       horizontal: constraints.maxWidth * 0.02,
                          //       vertical: constraints.maxHeight * 0.001,
                          //     ),
                          //   ),
                          //   onFieldSubmitted: (value) {
                          //     // if (checkLogin(userName.text, password.text)) {
                          //     //   Navigator.push(
                          //     //     context,
                          //     //     MaterialPageRoute(builder: (context) => const DashboardPage()),
                          //     //   );
                          //     // }
                          //   },
                          // ),
                        ),
                      ),
                      const SizedBox(height: 40),

                      Align(
                        alignment: const Alignment(0.0, 0.8),
                        child: SizedBox(
                          width: constraints.maxWidth * 0.2,
                          child: ElevatedButton(
                            onPressed: (){

                              if(userName.text.isEmpty){
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Please Fill Verification Code')),
                                );
                              }else{
                                _gerVerificationcode(context,verificationCode);
                              }
                            },
                            //onPressed: _verifyCode,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[800],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            child: Align(
                                alignment: const Alignment(0.0, 0.0),
                                child:  Text('Verify', style: TextStyle(fontSize: constraints.maxWidth * 0.02, color: Colors.white),)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }
        else{
          return Container(
            constraints: BoxConstraints(maxWidth: constraints.maxWidth * 0.5), // 80% of screen width
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 40),
                  Align(
                    alignment: Alignment(-0.30, 0.5),
                    child: SizedBox(
                      height: 35,
                      width: 100,
                      child: OutlinedButton(
                        // onPressed: handleButtonPress,
                        //my copy
                          onPressed: (){
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
                    alignment:const Alignment(-0.18, 0.5),
                    child: Text(
                      'Verify Your Email',
                      style: TextStyle(fontSize: constraints.maxWidth * 0.035, color: Colors.blue),
                    ),
                  ),
                  SizedBox(height: constraints.maxHeight * 0.03), // 5% of screen height
                  Align(
                    alignment: const Alignment(-0.16, 0.0),
                    child: Text(
                      // ' Enter your email address and\n we\'ll send you  a link to \n reset your password',
                      'Enter the verification code\nsent to your email address,\nand we\'ll help you\nreset your password.',
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
                        const Align(
                          alignment: Alignment(-0.3, 0.0),
                          child: Text('Verification Code', style: TextStyle(fontWeight: FontWeight.bold),),
                        ),
                        const SizedBox(height: 10),
                        Align(
                          alignment: const Alignment(0.0, 0.8),
                          child: SizedBox(
                            height: 30,
                            width: constraints.maxWidth * 0.4,
                            child:
                            TextFormField(
                              controller: userName,
                              obscureText: _obscureText,
                              decoration: InputDecoration(
                                border: const OutlineInputBorder(),
                                hintText: 'Enter your verification code',
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: MediaQuery.of(context).size.width * 0.01,
                                  vertical: MediaQuery.of(context).size.height * 0.001,
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscureText ? Icons.visibility_off :  Icons.visibility_rounded ,size: 18,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscureText = !_obscureText; ;
                                    });
                                  },
                                ),
                              ),
                              inputFormatters: [
                                FilteringTextInputFormatter
                                    .digitsOnly,
                                LengthLimitingTextInputFormatter(
                                    6),
                                // limits to 10 digits
                              ],
                              onFieldSubmitted: (value) {
                                // Your submission logic here
                              },
                            ),
                            // TextFormField(
                            //   controller: userName,
                            //   decoration: InputDecoration(
                            //     border: const OutlineInputBorder(),
                            //     hintText: 'Enter your verification code',
                            //     hintStyle: TextStyle(fontSize:  constraints.maxWidth * 0.018),
                            //     contentPadding: EdgeInsets.symmetric(
                            //       horizontal: constraints.maxWidth * 0.02,
                            //       vertical: constraints.maxHeight * 0.001,
                            //     ),
                            //   ),
                            //   onFieldSubmitted: (value) {
                            //     // if (checkLogin(userName.text, password.text)) {
                            //     //   Navigator.push(
                            //     //     context,
                            //     //     MaterialPageRoute(builder: (context) => const DashboardPage()),
                            //     //   );
                            //     // }
                            //   },
                            // ),
                          ),
                        ),
                        const SizedBox(height: 40),

                        Align(
                          alignment: const Alignment(0.0, 0.8),
                          child: SizedBox(
                            width: constraints.maxWidth * 0.2,
                            child: ElevatedButton(
                              onPressed: (){

                                if(userName.text.isEmpty){
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Please Fill Verification Code')),
                                  );
                                }else{
                                  _gerVerificationcode(context,verificationCode);
                                }
                              },
                              //onPressed: _verifyCode,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue[800],
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              child: Align(
                                  alignment: const Alignment(0.0, 0.0),
                                  child:  Text('Verify', style: TextStyle(fontSize: constraints.maxWidth * 0.02, color: Colors.white),)),
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
    return LayoutBuilder(
        builder: (context,constraints) {
          if(constraints.maxHeight >= 630){
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
          }else{
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
                        width: MediaQuery.of(context).size.width * 0.4, // Take 70% of screen width
                        height: MediaQuery.of(context).size.width * 0.7, // Take 70% of screen width
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