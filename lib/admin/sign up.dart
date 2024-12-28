import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:html';
import 'package:btb/admin/Api%20name.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import '../login/login screen.dart';
import '../widgets/text_style.dart';

void main() {
  runApp(MaterialApp(
    home: comLog(),
  ));
}

class comLog extends StatefulWidget {
  comLog({
    super.key,
  });

  @override
  State<comLog> createState() => _comLogState();
}

class _comLogState extends State<comLog> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Row(
        children: [
          Expanded(
            flex: 3,
            child: ImageContainer(),
          ),
          Expanded(
            flex: 3,
            child: ComUI(),
          ),
        ],
      ),
    );
  }
}







class ComUI extends StatefulWidget {
  const ComUI({super.key});

  @override
  State<ComUI> createState() => _ComUIState();
}

class _ComUIState extends State<ComUI> {
  final companyName = TextEditingController();
  final Password = TextEditingController();
  final userName = TextEditingController();
  final emailAddress = TextEditingController();
  final mobileNo = TextEditingController();


  bool _obscureText = true;

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }
  Future<String?> checkLogin() async {
    Map tempJson = {
      "companyName": companyName.text,
      "email": emailAddress.text,
      "mobileNumber":mobileNo.text,
      "password": Password.text,
      "userName": userName.text
    };
    String url =
        '$apicall/public/company/add';
    final response = await http.post(Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
        },
        body: json.encode(tempJson));
    if (response.statusCode == 200) {
      Map tempData = json.decode(response.body);
      if (tempData.containsKey("error")) {
        // Handle empty input fields with appropriate messages
        if (tempData['status'] == 'failed' &&
            tempData['code'] == '400') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please password must be strong.'),
              duration: Duration(seconds: 2), // Optional duration
            ),
          );
        }else if(tempData['status'] == 'failed' && tempData['error'] == "Company name already exists"){
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Company Name Already Exist'),
              duration: Duration(seconds: 2), // Optional duration
            ),
          );
        }

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
                          'Account Created Successfully',
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
                                'Ok',
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
        const SnackBar(content: Text("Invalid response from this ")),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if(constraints.maxHeight >= 630){
          return Container(
            constraints: BoxConstraints(maxWidth: constraints.maxWidth * 0.8),
            // 80% of screen width
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: constraints.maxHeight * 0.1),
                // 10% of screen height
                Align(
                  alignment: Alignment(-0.14, 0.0),
                  child: Text(
                    'Sign Up to Get Started!',
                    // style: TextStyles.Login,
                    style: TextStyles.login1(context),
                  ),
                ),
                SizedBox(height: constraints.maxHeight * 0.03),
                // 5% of screen height
                Align(
                  alignment: Alignment(-0.05, 0.0),
                  child: Text(
                    'Simplify your orders and take control with ease.',
                    // style: TextStyles.,
                    style: TextStyles.loginSub(context),
                  ),
                ),
                // SizedBox(height: constraints.maxHeight * 0.03),
                // 5% of screen height
                Align(
                  alignment: const Alignment(0.9, 0.4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: constraints.maxHeight * 0.04),
                      Align(
                          alignment: Alignment(-0.4, 0.0),
                          child: Text(
                            'Company Name',
                            style: TextStyles.header4,
                          )),
                      const SizedBox(height: 10),
                      Align(
                        alignment: const Alignment(-0.08, 0.0),
                        child: SizedBox(
                          height: 40,
                          width: constraints.maxWidth * 0.45,
                          child: TextFormField(
                            controller: companyName,

                            style: GoogleFonts.inter(
                                color: Colors.black,
                                fontSize: 13),
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'Enter your company name',
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 8,
                              ),
                            ),
                            onFieldSubmitted: (value) async {
                              print('username');
                              String? role =
                              await checkLogin();
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
                      const SizedBox(height: 10),
                      Align(
                          alignment: Alignment(-0.42, 0.0),
                          child: Text(
                            'Email Address',
                            style: TextStyles.header4,
                          )),
                      const SizedBox(height: 10),
                      Align(
                        alignment: const Alignment(-0.08, 0.0),
                        child: SizedBox(
                          height: 40,
                          width: constraints.maxWidth * 0.45,
                          child: TextFormField(
                            controller: emailAddress,

                            style: GoogleFonts.inter(
                                color: Colors.black,
                                fontSize: 13),
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'Enter your email address',
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 8,
                              ),
                            ),
                            onFieldSubmitted: (value) async {
                              print('username');
                              String? role =
                              await checkLogin();
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
                      const SizedBox(height: 10),
                      Align(
                          alignment: Alignment(-0.42, 0.0),
                          child: Text(
                            'Mobile Number',
                            style: TextStyles.header4,
                          )),
                      const SizedBox(height: 10),
                      Align(
                        alignment: const Alignment(-0.08, 0.0),
                        child: SizedBox(
                          height: 40,
                          width: constraints.maxWidth * 0.45,
                          child: TextFormField(
                            controller: mobileNo,
                            style: GoogleFonts.inter(
                                color: Colors.black,
                                fontSize: 13),
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'Enter your mobile number',
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 8,
                              ),
                            ),
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(10),
                            ],
                            onFieldSubmitted: (value) async {
                              print('username');
                              String? role =
                              await checkLogin();
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
                      const SizedBox(height: 10),
                      Align(
                          alignment: Alignment(-0.43, 0.0),
                          child: Text(
                            'User Name',
                            style: TextStyles.header4,
                          )),
                      const SizedBox(height: 10),
                      Align(
                        alignment: const Alignment(-0.08, 0.0),
                        child: SizedBox(
                          height: 40,
                          width: constraints.maxWidth * 0.45,
                          child: TextFormField(
                            controller: userName,

                            style: GoogleFonts.inter(
                                color: Colors.black,
                                fontSize: 13),
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
                              await checkLogin();
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
                      const SizedBox(height: 10),
                      Align(
                          alignment: const Alignment(-0.44, 0.0),
                          child: Text(
                              'Password',
                              style: TextStyles.header4
                          )),
                      const SizedBox(height: 10),
                      Align(
                        alignment: const Alignment(-0.08, 0.0),
                        child: SizedBox(
                          height: 40,
                          width: constraints.maxWidth * 0.45,
                          child: TextFormField(
                            controller: Password,
                            style: GoogleFonts.inter(
                                color: Colors.black,
                                fontSize: 13),
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
                              await checkLogin();
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

                      const SizedBox(
                        height: 20,
                      ),
                      Align(
                        alignment: const Alignment(-0.08, 0.2),
                        child: SizedBox(
                          width:constraints.maxWidth * 0.45,
                          child: ElevatedButton(
                            onPressed: () async {
                              if (companyName.text.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Please enter companyname")),
                                );
                              }
                              else if (emailAddress.text.isEmpty || !RegExp(r'^[\w-]+(\.[\w-]+)*@[a-zA-Z0-9-]+\.(com|in|net)$').hasMatch(emailAddress.text) ) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Please enter valid emailaddress")),
                                );
                              }
                              else if (mobileNo.text.isEmpty|| mobileNo.text.length < 10) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Please enter valid mobile number")),
                                );
                              }
                              else if (userName.text.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Please enter username")),
                                );
                              }
                              else if (Password.text.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Please enter password")),
                                );
                              }
                              else{
                                await checkLogin();
                              }

                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[800],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            child:  Align(
                                alignment: Alignment(0.0, 0.0),
                                child: Text(
                                    'Sign Up',
                                    style: TextStyles.button1
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
        }
        else{
          return SingleChildScrollView(
            child:  Container(
              constraints: BoxConstraints(maxWidth: constraints.maxWidth * 0.8),
              // 80% of screen width
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: constraints.maxHeight * 0.1),
                  // 10% of screen height
                  Align(
                    alignment: Alignment(-0.14, 0.0),
                    child: Text(
                      'Sign Up to Get Started!',
                      // style: TextStyles.Login,
                      style: TextStyles.login1(context),
                    ),
                  ),
                  SizedBox(height: constraints.maxHeight * 0.03),
                  // 5% of screen height
                  Align(
                    alignment: Alignment(-0.05, 0.0),
                    child: Text(
                      'Simplify your orders and take control with ease.',
                      // style: TextStyles.,
                      style: TextStyles.loginSub(context),
                    ),
                  ),
                  // SizedBox(height: constraints.maxHeight * 0.03),
                  // 5% of screen height
                  Align(
                    alignment: const Alignment(0.9, 0.4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: constraints.maxHeight * 0.04),
                        Align(
                            alignment: Alignment(-0.4, 0.0),
                            child: Text(
                              'Company Name',
                              style: TextStyles.header4,
                            )),
                        const SizedBox(height: 10),
                        Align(
                          alignment: const Alignment(-0.08, 0.0),
                          child: SizedBox(
                            height: 40,
                            width: constraints.maxWidth * 0.45,
                            child: TextFormField(
                              controller: companyName,

                              style: GoogleFonts.inter(
                                  color: Colors.black,
                                  fontSize: 13),
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                hintText: 'Enter your company name',
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 8,
                                ),
                              ),
                              onFieldSubmitted: (value) async {
                                print('username');
                                String? role =
                                await checkLogin();
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
                        const SizedBox(height: 10),
                        Align(
                            alignment: Alignment(-0.42, 0.0),
                            child: Text(
                              'Email Address',
                              style: TextStyles.header4,
                            )),
                        const SizedBox(height: 10),
                        Align(
                          alignment: const Alignment(-0.08, 0.0),
                          child: SizedBox(
                            height: 40,
                            width: constraints.maxWidth * 0.45,
                            child: TextFormField(
                              controller: emailAddress,

                              style: GoogleFonts.inter(
                                  color: Colors.black,
                                  fontSize: 13),
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                hintText: 'Enter your email address',
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 8,
                                ),
                              ),
                              onFieldSubmitted: (value) async {
                                print('username');
                                String? role =
                                await checkLogin();
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
                        const SizedBox(height: 10),
                        Align(
                            alignment: Alignment(-0.42, 0.0),
                            child: Text(
                              'Mobile Number',
                              style: TextStyles.header4,
                            )),
                        const SizedBox(height: 10),
                        Align(
                          alignment: const Alignment(-0.08, 0.0),
                          child: SizedBox(
                            height: 40,
                            width: constraints.maxWidth * 0.45,
                            child: TextFormField(
                              controller: mobileNo,
                              style: GoogleFonts.inter(
                                  color: Colors.black,
                                  fontSize: 13),
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                hintText: 'Enter your mobile number',
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 8,
                                ),
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(10),
                              ],
                              onFieldSubmitted: (value) async {
                                print('username');
                                String? role =
                                await checkLogin();
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
                        const SizedBox(height: 10),
                        Align(
                            alignment: Alignment(-0.43, 0.0),
                            child: Text(
                              'User Name',
                              style: TextStyles.header4,
                            )),
                        const SizedBox(height: 10),
                        Align(
                          alignment: const Alignment(-0.08, 0.0),
                          child: SizedBox(
                            height: 40,
                            width: constraints.maxWidth * 0.45,
                            child: TextFormField(
                              controller: userName,

                              style: GoogleFonts.inter(
                                  color: Colors.black,
                                  fontSize: 13),
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
                                await checkLogin();
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
                        const SizedBox(height: 10),
                        Align(
                            alignment: const Alignment(-0.44, 0.0),
                            child: Text(
                                'Password',
                                style: TextStyles.header4
                            )),
                        const SizedBox(height: 10),
                        Align(
                          alignment: const Alignment(-0.08, 0.0),
                          child: SizedBox(
                            height: 40,
                            width: constraints.maxWidth * 0.45,
                            child: TextFormField(
                              controller: Password,
                              style: GoogleFonts.inter(
                                  color: Colors.black,
                                  fontSize: 13),
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
                                await checkLogin();
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

                        const SizedBox(
                          height: 20,
                        ),
                        Align(
                          alignment: const Alignment(-0.08, 0.2),
                          child: SizedBox(
                            width:constraints.maxWidth * 0.45,
                            child: ElevatedButton(
                              onPressed: () async {
                                if (companyName.text.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text("Please enter companyname")),
                                  );
                                }
                                else if (emailAddress.text.isEmpty || !RegExp(r'^[\w-]+(\.[\w-]+)*@[a-zA-Z0-9-]+\.(com|in|net)$').hasMatch(emailAddress.text) ) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text("Please enter valid emailaddress")),
                                  );
                                }
                                else if (mobileNo.text.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text("Please enter mobile number")),
                                  );
                                }
                                else if (userName.text.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text("Please enter username")),
                                  );
                                }
                                else if (Password.text.isEmpty || Password.text.length < 8 || Password.text.length > 12) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text("Password must be 8 to 12 characters")),
                                  );
                                }
                                else{
                                  await checkLogin();
                                }

                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue[800],
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              child:  Align(
                                  alignment: Alignment(0.0, 0.0),
                                  child: Text(
                                      'Sign Up',
                                      style: TextStyles.button1
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