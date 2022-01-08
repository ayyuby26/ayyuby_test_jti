import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/provider.dart';
import 'view/login_page.dart';

void main() {
  Provider.debugCheckInvalidValueType = null;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Provider(
      create: (context) => State1(),
      child: const MaterialApp(
        home: LoginPage(),
      ),
    );
  }
}
