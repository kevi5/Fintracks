import 'package:flutter/material.dart';

const Color bluishClr = Color.fromARGB(255, 11, 111, 245);
const primaryColor = bluishClr;
const Color darkGreyClr = Color(0xFF121212);
const Color darkHeaderColor = Color(0xFF424242);

class Themes{
    static final light = ThemeData(
      primaryColor: primaryColor,
      primaryColorLight: Colors.white,
      primaryColorDark: Colors.black,
      brightness: Brightness.light,
      useMaterial3: true,
    );

    static final dark =  ThemeData(
      primaryColor: darkGreyClr,
      primaryColorLight: Colors.white,
      primaryColorDark: Colors.black,
      brightness: Brightness.dark,
      useMaterial3: true,
    );
}