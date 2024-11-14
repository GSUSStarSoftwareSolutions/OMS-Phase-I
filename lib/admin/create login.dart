import 'package:btb/admin/create%20account.dart';
import 'package:flutter/material.dart';
import '../login/login screen.dart';

void main(){
  runApp(MaterialApp(home: CreateLogin(),));
}
class CreateLogin extends StatefulWidget {

  CreateLogin({super.key,});

  @override
  State<CreateLogin> createState() => _CreateLoginState();
}

class _CreateLoginState extends State<CreateLogin> {
  @override
  Widget build(BuildContext context) {
    return
      const Scaffold(
        body: Row(
          children: [
            Expanded(
              flex: 3,
              child: ImageContainer1(),
            ),
            Expanded(
              flex: 3,
              child: createscr(),
            ),
          ],
        ),
      );
  }

}