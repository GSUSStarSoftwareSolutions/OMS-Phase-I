import 'dart:convert';
import 'package:btb/admin/Api%20name.dart';
import 'package:btb/login/login.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/image.dart';



void main(){
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: ConfirmPassword(verificationcode: '',),));
}

class ConfirmPassword extends StatefulWidget {
  String verificationcode;
   ConfirmPassword({super.key,required this.verificationcode});

  @override
  State<ConfirmPassword> createState() => _ConfirmPasswordState();
}




class _ConfirmPasswordState extends State<ConfirmPassword> {

  String otp = '';

  final Password = TextEditingController();
  final ConfirmPassword = TextEditingController();
  bool _obscureText = true;
  bool _obscureText2 = true;

  String? _passwordError;
  final _formKey = GlobalKey<FormState>();

  void initState() {
    // TODO: implement initState
    super.initState();
    print('verification code');
    print(widget.verificationcode);
   // otp = widget.verificationcode;
  }

  Future<void> _changePassword(BuildContext context, String otp, String newPassword, String confirmPassword) async {
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


        // Success response handling
        print(response.body);

        // if (response.statusCode == 200) {
         // final responseBody = jsonDecode(response.body);
          if (response.statusCode == 200) {
            // Success response handling
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  icon: Icon(
                    Icons.check_circle_rounded, color: Colors.green, size: 25,),
                  content: Padding(padding: EdgeInsets.only(left: 35),
                      child: Text(
                          'Your password has been\n changed successfully .')),
                  actions: <Widget>[
                    TextButton(
                      child: Text('OK'),
                      onPressed: () {
                        // context.go('/');
                        // context.go('/');
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
                    ),
                  ],
                );
              },
            );
          } else if (response.body == 'Invalid OTP') {
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  icon: Icon(
                      Icons.warning_rounded, color: Colors.red, size: 25),
                  content: Padding(
                    padding: EdgeInsets.only(left: 65),
                    child: Text('Invalid OTP'),
                  ),
                  actions: <Widget>[
                    TextButton(
                      child: Text('OK'),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ],
                );
              },
            );
          //}
        } else {
          // Handle server errors
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(
                'Failed to change password: ${response.statusCode}')),
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

  @override
  Widget build(BuildContext context) {
    return  LayoutBuilder(
      builder: (context,constraints){
        return Scaffold(
          body: Row(
            children: [
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
                ),
              ),
              Expanded(
                flex: 3,
                child: Container(
                  constraints: BoxConstraints(maxWidth: constraints.maxWidth * 0.8), // 80% of screen width
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: constraints.maxHeight * 0.2), // 10% of screen height
                      Align(
                        alignment: Alignment(-0.016, 0.0),
                        //     alignment: Alignment(-0.20, 0.5),
                        child:  Text(
                          'Create New Password',
                          style: TextStyle(fontSize: constraints.maxWidth * 0.02, color: Colors.blue),
                        ),
                      ),
                      SizedBox(height: constraints.maxHeight * 0.03), // 5% of screen height
                      Align(
                        alignment: Alignment(-0.046, 0.0),
                        child:  Text(
                          'Your New Password Must Be \nDifferent from Previously Used Password',
                          style: TextStyle(fontSize: constraints.maxWidth * 0.01),
                        ),
                      ),
                      SizedBox(height: constraints.maxHeight * 0.03), // 5% of screen height
                      Align(
                        alignment: const Alignment(0.9,0.4),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: constraints.maxHeight * 0.04),
                              Align(
                                  alignment:  Alignment(-0.300, 0.0),
                                  child: Text('New Password',style: TextStyle(
                                      fontWeight: FontWeight.bold,fontSize: constraints.maxWidth * 0.01
                                  ),)),
                              const SizedBox(height: 5),
                              Align(
                                alignment: const Alignment(0.0, 0.6),
                                child: SizedBox(
                                  height: constraints.maxHeight * 0.04,
                                  width: constraints.maxWidth * 0.2,
                                  child: TextFormField(
                                    obscureText: _obscureText,
                                    controller: Password,
                                    decoration:  InputDecoration(
                                      border: OutlineInputBorder(),
                                      suffixIcon: IconButton(onPressed: (){
                                        setState(() {
                                          _obscureText = !_obscureText;
                                        });
                                      }, icon: Icon(_obscureText ? Icons.visibility_off :  Icons.visibility_rounded ,size: 18,)),
                                      hintText: 'Enter your password',
                                      hintStyle: TextStyle(fontSize: constraints.maxWidth * 0.01),
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 8,
                                      ),
                                    ),
                                    inputFormatters: [
                                      // FilteringTextInputFormatter
                                      //     .digitsOnly,
                                      // LengthLimitingTextInputFormatter
                                      //   (
                                      //     10),W
                                      FilteringTextInputFormatter.allow(RegExp('.*' )),
                                     // limits to 10 digits
                                      FilteringTextInputFormatter.deny(
                                          RegExp(r'^\s')),
                                      // Disallow starting with a space
                                      FilteringTextInputFormatter.deny(
                                          RegExp(r'\s\s')),
                                      // Disallow multiple spaces
                                    ],
                                    onFieldSubmitted: (value) async {
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              Align(
                                  alignment:  Alignment(-0.280, 0.0),
                                  //alignment:Alignment(-0.4, 0.0),
                                  child:  Text('Confirm Password',style: TextStyle(
                                      fontWeight: FontWeight.bold,fontSize: constraints.maxWidth * 0.01
                                  ),)),
                              const SizedBox(height: 5),
                              Align(
                                alignment: const Alignment(0.0, 0.6),
                                child: SizedBox(
                                  height: constraints.maxHeight * 0.040,
                                  width: constraints.maxWidth * 0.2,
                                  child: TextFormField(
                                    obscureText: _obscureText2,
                                    controller: ConfirmPassword,
                                    decoration:  InputDecoration(
                                        border: OutlineInputBorder(),
                                        hintText: 'Enter your confirm password',

                                        hintStyle: TextStyle(fontSize: constraints.maxWidth * 0.01),
                                        contentPadding: EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 8,
                                        ),

                                        errorText: _passwordError,
                                        suffixIcon: IconButton( onPressed: (){
                                          setState(() {
                                            _obscureText2 = !_obscureText2;
                                          });
                                        }, icon: Icon(_obscureText2 ? Icons.visibility_off :  Icons.visibility_rounded ,size: 18,)

                                        )


                                    ),

                                    inputFormatters: [
                                      // FilteringTextInputFormatter
                                      //     .digitsOnly,
                                      // LengthLimitingTextInputFormatter
                                      //   (
                                      //     10),
                                      FilteringTextInputFormatter.allow(RegExp('.*' )),
                                      // FilteringTextInputFormatter.allow(
                                      //     RegExp("[a-zA-Z0-9!@#%&*^()\$.,/:;'{}-_ ]")),
                                      // limits to 10 digits
                                      FilteringTextInputFormatter.deny(
                                          RegExp(r'^\s')),
                                      // Disallow starting with a space
                                      FilteringTextInputFormatter.deny(
                                          RegExp(r'\s\s')),
                                      // Disallow multiple spaces
                                    ],
                                    // validator: (value) {
                                    //   if (value != userName.text) {
                                    //     return 'Passwords do not match';
                                    //   }
                                    //   return null;
                                    // },
                                  ),
                                ),
                              ),
                              SizedBox(height: 60,),
                              Align(
                                alignment: const Alignment(0.0, 0.6),
                                // alignment: const Alignment(0.1, 0.2),
                                child: SizedBox(
                                  width: constraints.maxWidth * 0.1,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      if(Password.text.isEmpty && ConfirmPassword.text.isEmpty){
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text(
                                              'Password and Confirm Password fields cannot be empty.')),
                                        );

                                      }else if(Password.text.isEmpty && ConfirmPassword.text.isNotEmpty){
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text(
                                              'Please Enter Password.')),
                                        );
                                      }else if(Password.text.isNotEmpty && ConfirmPassword.text.isEmpty){
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text(
                                              'Please Enter Confirm Password.')),
                                        );
                                      }else if (Password.text == ConfirmPassword.text) {
                                        // passwords match, proceed with saving
                                        _changePassword(context, '', Password.text, ConfirmPassword.text);
                                      }
                                        else {
                                        showDialog(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              icon: Icon(
                                                Icons.warning_amber_outlined, color: Colors.red, size: 25,),
                                              content: Padding(padding: EdgeInsets.only(left: 35),
                                                  child: Text(
                                                      'Passwords do not match.')),
                                              actions: <Widget>[
                                                TextButton(
                                                  child: Text('OK'),
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                    // context.go('/');
                                                    //context.go('/');

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
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                    child: const Align(
                                        alignment: Alignment(0.0, 0.0),
                                        child:  Text('Save',style: TextStyle(color: Colors.white),)),
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
            ],
          ),
        );
      },


    );
  }
}



//
// class ImageContainer3 extends StatelessWidget {
//   const ImageContainer3({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//
//     return
//       Container(
//       width: double.infinity, // Take full width
//       color: Colors.grey[100],
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Padding(
//             padding: const EdgeInsets.only(top: 40, left: 25),
//             child: Image.asset('images/Final-Ikyam-Logo.png'),
//           ),
//           const SizedBox(height: 50), // You can adjust this value
//           Center(
//             child: SizedBox(
//               width: MediaQuery.of(context).size.width * 0.4, // Take 70% of screen width
//               height: MediaQuery.of(context).size.width * 0.3, // Take 70% of screen width
//               child: Image.asset(
//                 'images/ikyam1.png',
//                 fit: BoxFit.cover,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }



