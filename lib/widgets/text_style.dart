import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TextStyles {
  static double responsiveFontSize(BuildContext context, double factor) {
    double maxWidth = MediaQuery
        .of(context)
        .size
        .width;
    return maxWidth * factor;
  }

  static final TextStyle heading = GoogleFonts.inter(
    fontSize: 20.0, // Font size in px
    fontWeight: FontWeight.w500, // Medium weight
    color: Colors.black, // Default text color
  );

  static TextStyle login(BuildContext context) =>
      GoogleFonts.inter(
        fontSize: responsiveFontSize(context, 0.0117), // Adjust 0.033 as needed
        fontWeight: FontWeight.w500,
        color: Colors.blue,
      );
  static final TextStyle header4 = GoogleFonts.inter(
    fontSize: 13.0, fontWeight: FontWeight.w500, color: Colors.black,);

  static TextStyle login1(BuildContext context) =>
      GoogleFonts.inter(
        fontSize: responsiveFontSize(context, 0.018), // Adjust 0.033 as needed
        fontWeight: FontWeight.w500,
        color: Colors.blue,
      );

  static TextStyle pass(BuildContext context) =>
      GoogleFonts.inter(
        fontSize: responsiveFontSize(context, 0.0157), // Adjust 0.033 as needed
        fontWeight: FontWeight.w500,
        color: Colors.blue,
      );

  static TextStyle loginSub(BuildContext context) =>
      GoogleFonts.inter(
        fontSize: responsiveFontSize(context, 0.0097), // Adjust 0.033 as needed
        fontWeight: FontWeight.w500,
        color: Colors.black,
      );
  static final TextStyle subhead = GoogleFonts.inter(
    fontSize: 14.0, // Font size in px
    fontWeight: FontWeight.w500, // Medium weight
    color: Color.fromRGBO(0, 83, 176, 1), // Default text color
  );
  static final TextStyle header1 = GoogleFonts.inter(
    fontSize: 18.0, // Font size in px
    fontWeight: FontWeight.w500, // Medium weight
    color: Colors.black,
    // color: Color.fromRGBO(0, 83, 176, 1), // Default text color
  );
  static final TextStyle header3 = GoogleFonts.inter(
    fontSize: 16.0, // Font size in px
    fontWeight: FontWeight.w500, // Medium weight
    color: Colors.black,
    // color: Color.fromRGBO(0, 83, 176, 1), // Default text color
  );
  static final TextStyle body = GoogleFonts.inter(
    fontSize: 13.0, // Font size in px
    fontWeight: FontWeight.w500, // Medium weight
    color: Colors.grey,
    // color: Color.fromRGBO(0, 83, 176, 1), // Default text color
  );

  static final TextStyle button1 = GoogleFonts.inter(
    fontSize: 14.0,
    fontWeight: FontWeight.w500,
    color: Color.fromRGBO(255, 255, 255, 1),
  );
  static final TextStyle subhead1 = GoogleFonts.inter(
    fontSize: 14.0,
    fontWeight: FontWeight.w500,
    color: Colors.black,
  );
  static final TextStyle filter = GoogleFonts.inter(
    fontSize: 13.0, // Font size in px
    fontWeight: FontWeight.w500, // Medium weight
    color: Colors.grey,
    // color: Color.fromRGBO(0, 83, 176, 1), // Default text color
  );
  static final TextStyle sidebar = GoogleFonts.inter(
    fontSize: 13.0, // Font size in px
    fontWeight: FontWeight.w500, // Medium weight
    color: Colors.grey,
    // color: Color.fromRGBO(0, 83, 176, 1), // Default text color
  );
  static final TextStyle button = GoogleFonts.inter(
    fontSize: 13.0, // Font size in px
    fontWeight: FontWeight.w500, // Medium weight
    color: Colors.white,
    // color: Color.fromRGBO(0, 83, 176, 1), // Default text color
  );
  static final TextStyle forgot = GoogleFonts.inter(
    fontSize: 13.0, // Font size in px
    fontWeight: FontWeight.w500, // Medium weight
    color: Colors.blue, // Default text color
  );
  static final TextStyle body1 = GoogleFonts.inter(
    fontSize: 13.0, // Font size in px
    //fontWeight: FontWeight.w500, // Medium weight
    color: Colors.grey,
    // color: Color.fromRGBO(0, 83, 176, 1), // Default text color
  );
  static final TextStyle body2 = GoogleFonts.inter(
    fontSize: 15.0, // Font size in px
    //fontWeight: FontWeight.w500, // Medium weight
    color: Colors.black,
    // color: Color.fromRGBO(0, 83, 176, 1), // Default text color
  );
  static final TextStyle need = GoogleFonts.inter(
    fontSize: 14.0, // Font size in px
    fontWeight: FontWeight.w500,
    // Medium weight
    color: Colors.black,
// Default text color
  );
  static final TextStyle contact = GoogleFonts.inter(
    fontSize: 14.0, // Font size in px
    fontWeight: FontWeight.w500,
    // Medium weight
    color: Colors.blue,
// Default text color
  );
  static final TextStyle contact1 = GoogleFonts.inter(
    fontSize: 14.0, // Font size in px
    fontWeight: FontWeight.w500,
    // Medium weight
    color: Colors.black,
// Default text color
  );

  static TextStyle email(BuildContext context) =>
      GoogleFonts.inter(
        fontSize: responsiveFontSize(context, 0.0088), // Adjust 0.033 as needed
        fontWeight: FontWeight.w500,
        color: Colors.black,
      );

}


// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
//
// class TextStyles {
//
//
//   static final TextStyle heading = GoogleFonts.inter(
//     fontSize: 20.0, // Font size in px
//     fontWeight: FontWeight.w500, // Medium weight
//     color: Colors.black, // Default text color
//   );
//
//
//   static final TextStyle subhead = GoogleFonts.inter(
//     fontSize: 14.0, // Font size in px
//     fontWeight: FontWeight.w500,
//     // Medium weight
//     color: Color.fromRGBO(0, 83, 176, 1),
// // Default text color
//   );
//
//   static final TextStyle subhead1 = GoogleFonts.inter(
//     fontSize: 14.0,
//     fontWeight: FontWeight.w500,
//
//     color: Colors.black,
//
//   );
//   static final TextStyle button1 = GoogleFonts.inter(
//     fontSize: 14.0,
//     fontWeight: FontWeight.w500,
//     color: Color.fromRGBO(255, 255, 255, 1),   );
//   static final TextStyle header1 = GoogleFonts.inter(
//     fontSize: 18.0, // Font size in px
//     fontWeight: FontWeight.w500, // Medium weight
//     color: Colors.black,
//     // color: Color.fromRGBO(0, 83, 176, 1), // Default text color
//   );
//   static final TextStyle header3 = GoogleFonts.inter(
//     fontSize: 15.0, // Font size in px
//     fontWeight: FontWeight.w500, // Medium weight
//     color: Colors.black,
//     // color: Color.fromRGBO(0, 83, 176, 1), // Default text color
//   );
//
//   static final TextStyle body = GoogleFonts.inter(
//     fontSize: 13.0, // Font size in px
//     fontWeight: FontWeight.w500, // Medium weight
//     color: Colors.grey,
//     // color: Color.fromRGBO(0, 83, 176, 1), // Default text color
//   );
//   static final TextStyle body1 = GoogleFonts.inter(
//     fontSize: 13.0, // Font size in px
//     //fontWeight: FontWeight.w500, // Medium weight
//     color: Colors.grey,
//     // color: Color.fromRGBO(0, 83, 176, 1), // Default text color
//   );
// }