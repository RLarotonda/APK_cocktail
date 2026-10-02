import 'package:apk_cocktail/view/home_page.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    title: 'Choose your drink!',
    home: HomePage(),
    theme: ThemeData(
      brightness: Brightness.dark,
      colorSchemeSeed: Colors.blueAccent,
      useMaterial3: true,
    ),
    debugShowCheckedModeBanner: false,
  ));
}
