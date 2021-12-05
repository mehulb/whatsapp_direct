import 'package:flutter/material.dart';
import 'package:whatsapp_plus/home.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    initialRoute: "/home",
    routes: {
      "/home": (context) => Home(),
    },
  ));
}