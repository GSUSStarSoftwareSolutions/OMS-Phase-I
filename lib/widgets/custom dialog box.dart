import 'package:flutter/material.dart';


void main() => MyApp();


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: (){}, child: null,
    ),
            // showDialog(context: context,
            // builder: (context) => CustomDialogBox(),

          //},
          //child: Text('On press'),
        ),
      );
   // );
  }
}


class CustomDialogBox extends StatelessWidget {
  const CustomDialogBox({super.key});

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
