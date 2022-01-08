import 'package:ayyuby_test_jti/const/google_sign_in.dart';
import 'package:ayyuby_test_jti/view/login_page.dart';
import 'package:flutter/material.dart';
import 'package:encrypt/encrypt.dart' as k;

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final plainText = 'Halo Dunia';
  String encryptText = '';

  final key = k.Key.fromUtf8('rahasia--rahasia');
  final iv = k.IV.fromLength(16);

  void aesEncrypt() {
    final encrypter = k.Encrypter(k.AES(key));

    final encrypted = encrypter.encrypt(plainText, iv: iv);
    // final decrypted = encrypter.decrypt(encrypted, iv: iv);

    setState(() {
      encryptText = encrypted.base64;
    });
  }

  _handleSignOut() {
    googleSignIn.disconnect().then((_) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const LoginPage(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: aesEncrypt,
              child: const Text(
                "AES encrypt",
              ),
            ),
            ElevatedButton(
              onPressed: _handleSignOut,
              child: const Text(
                "Logout",
              ),
            ),
            Text(plainText),
            Text(encryptText),
          ],
        ),
      ),
    );
  }
}
