import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TextStyles {
  static final TextStyle heading = GoogleFonts.poppins(
    fontSize: 20.0, // Font size in px
    fontWeight: FontWeight.w500, // Medium weight
    color: Colors.black, // Default text color
  );
  static final TextStyle subhead = GoogleFonts.jost(
    fontSize: 14.0, // Font size in px
    fontWeight: FontWeight.w500, // Medium weight
    color: Color.fromRGBO(0, 83, 176, 1), // Default text color
  );
  static final TextStyle header1 = GoogleFonts.jost(
    fontSize: 18.0, // Font size in px
    fontWeight: FontWeight.w500, // Medium weight
    color: Colors.black,
   // color: Color.fromRGBO(0, 83, 176, 1), // Default text color
  );
  static final TextStyle header3 = GoogleFonts.jost(
    fontSize: 15.0, // Font size in px
    fontWeight: FontWeight.w500, // Medium weight
    color: Colors.black,
    // color: Color.fromRGBO(0, 83, 176, 1), // Default text color
  );
  static final TextStyle body = GoogleFonts.jost(
    fontSize: 13.0, // Font size in px
    fontWeight: FontWeight.w500, // Medium weight
    color: Colors.grey,
    // color: Color.fromRGBO(0, 83, 176, 1), // Default text color
  );
  static final TextStyle body1 = GoogleFonts.jost(
    fontSize: 13.0, // Font size in px
    //fontWeight: FontWeight.w500, // Medium weight
    color: Colors.grey,
    // color: Color.fromRGBO(0, 83, 176, 1), // Default text color
  );
}
