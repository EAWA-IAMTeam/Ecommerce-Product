import 'package:flutter/material.dart';
import 'link_product.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Link Product',
      theme: ThemeData(primarySwatch: Colors.purple),
      home: LinkProductPage(),
    );
  }
}
