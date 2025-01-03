import 'dart:convert';
import 'dart:html';
import 'package:btb/widgets/Api%20name.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import '../widgets/text_style.dart';
import 'verify_emailid.dart';

class LoginContainer2 extends StatefulWidget {
  const LoginContainer2({super.key});

  @override
  State<LoginContainer2> createState() => _LoginContainer2State();
}

class _LoginContainer2State extends State<LoginContainer2> {
  final userName = TextEditingController();
  final password = TextEditingController();
  bool _obscureText = true;

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  Future<String?> checkLogin(String username, String password) async {
    Map tempJson = {"userName": username, "password": password};
    String url = '$apicall/public/user_master/login-authenticate';
    final response = await http.post(Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
        },
        body: json.encode(tempJson));
    if (response.statusCode == 200) {
      Map tempData = json.decode(response.body);

      if (tempData.containsKey("error")) {
        if (tempData['code'] == '401' &&
            tempData['error'] == 'INVALID EMPLOYEE NAME or PASSWORD') {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Enter valid  password")));
        } else if (tempData['code'] == '404' &&
            tempData['status'] == 'failed') {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("User name not found")));
        } else if (tempData['code'] == '403' &&
            tempData['status'] == 'failed') {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text(
                  "Your account is inactive. Please contact the administrator for assistance")));
        }
      } else {
        window.sessionStorage["userId"] = tempData['userId'];
        String role = tempData['role'];
        if (role == 'Employee') {
          window.sessionStorage["company Name"] = tempData['company Name'];
          window.sessionStorage["company"] = tempData['company'];
          window.sessionStorage["token"] = tempData['token'];
          context.go('/Home');
        } else if (role == 'Customer') {
          window.sessionStorage["company Name"] = tempData['company Name'];
          // Handle Admin role
          window.sessionStorage["company"] = tempData['company'];
          window.sessionStorage["userId"] = tempData['userId'];
          window.sessionStorage["token"] = tempData['token'];
          context.go('/Cus_Home');
        } else if (role == 'Admin') {
          window.sessionStorage["company"] = tempData['company'];
          print('data');
          print(window.sessionStorage["company"]);
          window.sessionStorage["token"] = tempData['token'];
          context.go('/User_List');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Unknown role")),
          );
        }
        return null;
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid response from this ")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxHeight >= 630) {
          return Container(
            constraints: BoxConstraints(maxWidth: constraints.maxWidth * 0.8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: constraints.maxHeight * 0.15),
                Align(
                  alignment: const Alignment(-0.14, 0.0),
                  child: Text(
                    'Login to your account',
                    style: TextStyles.login(context),
                  ),
                ),
                SizedBox(height: constraints.maxHeight * 0.03),
                Align(
                  alignment: const Alignment(-0.05, 0.0),
                  child: Text(
                    'Simplify your order management \nand gain complete control',
                    style: TextStyles.loginSub(context),
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
                          alignment: const Alignment(-0.27, 0.0),
                          child: Text(
                            'Username',
                            style: TextStyles.header3,
                          )),
                      const SizedBox(height: 10),
                      Align(
                        alignment: const Alignment(0.1, 0.0),
                        child: SizedBox(
                          height: 40,
                          width: constraints.maxWidth * 0.39,
                          child: TextFormField(
                            controller: userName,
                            style: GoogleFonts.inter(
                                color: Colors.black, fontSize: 13),
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
                              String? role = await checkLogin(
                                  userName.text, password.text);
                              if (role != null) {
                                if (role == 'Employee') {
                                  context.go('/Home');
                                } else if (role == 'Customer') {
                                  context.go('/Customer_Order_List');
                                } else if (role == 'Admin') {
                                  context.go('/User_List');
                                } else if (userName.text.isNotEmpty &&
                                    password.text.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text("Please enter password")),
                                  );
                                }
                              }
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Align(
                          alignment: const Alignment(-0.27, 0.0),
                          child: Text('Password', style: TextStyles.header3)),
                      const SizedBox(height: 10),
                      Align(
                        alignment: const Alignment(0.1, 0.0),
                        child: SizedBox(
                          height: 40,
                          width: constraints.maxWidth * 0.39,
                          child: TextFormField(
                            controller: password,
                            style: GoogleFonts.inter(
                                color: Colors.black, fontSize: 13),
                            obscureText: _obscureText,
                            decoration: InputDecoration(
                              border: const OutlineInputBorder(),
                              hintText: 'Enter your Password',
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
                            onFieldSubmitted: (value) async {
                              print('username');
                              String? role = await checkLogin(
                                  userName.text, password.text);
                              if (role != null) {
                                if (role == 'Employee') {
                                  context.go('/Home');
                                } else if (role == 'Customer') {
                                  context.go('/Customer_Order_List');
                                } else if (role == 'Admin') {
                                  context.go('/User_List');
                                } else if (userName.text.isEmpty &&
                                    password.text.isNotEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text("Please enter username")),
                                  );
                                }
                              }
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Align(
                        alignment: const Alignment(0.36, 0.2),
                        child: InkWell(
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          onTap: () {
                            Navigator.of(context).push(PageRouteBuilder(
                              pageBuilder:
                                  (context, animation, secondaryAnimation) =>
                                      const Logout(),
                            ));
                          },
                          child: Text('Forgot password ?',
                              style: TextStyles.forgot),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Align(
                        alignment: const Alignment(0.1, 0.2),
                        child: SizedBox(
                          width: 200,
                          child: ElevatedButton(
                            onPressed: () async {
                              if (userName.text.isEmpty &&
                                  password.text.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          "Please enter username & password")),
                                );
                              } else if (userName.text.isEmpty &&
                                  password.text.isNotEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text("Please enter username")),
                                );
                              } else if (userName.text.isNotEmpty &&
                                  password.text.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text("Please enter password")),
                                );
                              } else {
                                await checkLogin(userName.text, password.text);
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
                                child:
                                    Text('Login', style: TextStyles.button1)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 120),
                      Align(
                        alignment: const Alignment(0.1, 0.0),
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            children: [
                              TextSpan(
                                  text: 'Need help? ', style: TextStyles.need),
                              TextSpan(
                                  text: 'Contact Support',
                                  style: TextStyles.contact),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      )
                    ],
                  ),
                ),
              ],
            ),
          );
        } else {
          return SingleChildScrollView(
            child: Container(
              constraints: BoxConstraints(maxWidth: constraints.maxWidth * 0.8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: constraints.maxHeight * 0.15),
                  Align(
                    alignment: const Alignment(-0.14, 0.0),
                    child: Text(
                      'Login to Your account',
                      style: TextStyles.login(context),
                    ),
                  ),
                  SizedBox(height: constraints.maxHeight * 0.03),
                  Align(
                    alignment: const Alignment(-0.05, 0.0),
                    child: Text(
                      'Simplify your order management \nand gain complete control',
                      style: TextStyles.loginSub(context),
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
                            alignment: const Alignment(-0.27, 0.0),
                            child: Text(
                              'Username',
                              style: TextStyles.header3,
                            )),
                        const SizedBox(height: 10),
                        Align(
                          alignment: const Alignment(0.1, 0.0),
                          child: SizedBox(
                            height: 40,
                            width: constraints.maxWidth * 0.39,
                            child: TextFormField(
                              controller: userName,
                              style: GoogleFonts.inter(
                                  color: Colors.black, fontSize: 13),
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
                                String? role = await checkLogin(
                                    userName.text, password.text);
                                if (role != null) {
                                  if (role == 'Employee') {
                                    context.go('/Home');
                                  } else if (role == 'Customer') {
                                    context.go('/Customer_Order_List');
                                  } else if (role == 'Admin') {
                                    context.go('/User_List');
                                  } else if (userName.text.isNotEmpty &&
                                      password.text.isEmpty) {
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
                        Align(
                            alignment: const Alignment(-0.27, 0.0),
                            child: Text(
                              'Password',
                              style: TextStyles.header3,
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
                                  color: Colors.black, fontSize: 13),
                              obscureText: _obscureText,
                              decoration: InputDecoration(
                                border: const OutlineInputBorder(),
                                hintText: 'Enter your Password',
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
                              onFieldSubmitted: (value) async {
                                print('username');
                                String? role = await checkLogin(
                                    userName.text, password.text);
                                if (role != null) {
                                  if (role == 'Employee') {
                                    context.go('/Home');
                                  } else if (role == 'Customer') {
                                    context.go('/Customer_Order_List');
                                  } else if (role == 'Admin') {
                                    context.go('/User_List');
                                  } else if (userName.text.isEmpty &&
                                      password.text.isNotEmpty) {
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
                          alignment: const Alignment(0.36, 0.2),
                          child: InkWell(
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            onTap: () {
                              Navigator.of(context).push(PageRouteBuilder(
                                pageBuilder:
                                    (context, animation, secondaryAnimation) =>
                                        const Logout(),
                              ));
                            },
                            child: const Text(
                              'Forgot password ?',
                              style: TextStyle(color: Colors.blue),
                            ),
                          ),
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
                                if (userName.text.isEmpty &&
                                    password.text.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            "Please enter username & password")),
                                  );
                                } else if (userName.text.isEmpty &&
                                    password.text.isNotEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text("Please enter username")),
                                  );
                                } else if (userName.text.isNotEmpty &&
                                    password.text.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text("Please enter password")),
                                  );
                                } else {
                                  await checkLogin(
                                      userName.text, password.text);
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
                                    'Login',
                                    style: TextStyles.button1,
                                    // style: TextStyle(color: Colors.white),
                                  )),
                            ),
                          ),
                        ),
                        SizedBox(height: constraints.maxHeight * 0.06),
                        Align(
                          alignment: const Alignment(0.1, 0.0),
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 30),
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
