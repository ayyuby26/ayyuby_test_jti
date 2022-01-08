import 'package:ayyuby_test_jti/const/google_sign_in.dart';
import 'package:ayyuby_test_jti/data/provider.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mobile_number/mobile_number.dart';
import 'package:provider/provider.dart';

import 'dashboard_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String _latlong = '';
  String _googleName = '';
  void _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      Geolocator.getCurrentPosition().then((value) {
        setState(() {
          _latlong = value.toString();
        });
      });
    }
  }

  void getPhoneNumber() async {
    await MobileNumber.requestPhonePermission;
    final permission = await MobileNumber.hasPhonePermission;
    if (permission) {
      final singleSim = await MobileNumber.mobileNumber;
      if (singleSim != null) {
        context.read<State1>().addNumber(singleSim);
      }

      final dualSim = await MobileNumber.getSimCards;
      if (dualSim != null) {
        for (var e in dualSim) {
          if (e.number != null) {
            context.read<State1>().addNumber(e.number!);
          }
        }
      }
    }
  }

  @override
  void initState() {
    getPhoneNumber();
    _determinePosition();
    super.initState();

    googleSignIn.onCurrentUserChanged.listen((account) {
      if (account != null) {
        if (account.displayName != null) {
          setState(() {
            _googleName = account.displayName!;
          });
        }
      }
    });
    googleSignIn.signInSilently();
  }

  Future<void> _handleSignIn() async {
    try {
      final response = await googleSignIn.signIn();
      if (response != null) {
        if (response.displayName != null) {
          setState(() {
            _googleName = response.displayName!;
          });
        }
      }
    } catch (error) {
      print(error);
    }
  }

  _handleSignOut() {
    googleSignIn.disconnect().then((value) {
      setState(() {
        _googleName = "";
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            if (_googleName.isNotEmpty) Text("Welcome: " + _googleName),
            ElevatedButton(
              onPressed:
                  _googleName.isNotEmpty ? _handleSignOut : _handleSignIn,
              child:
                  Text(_googleName.isNotEmpty ? "Logout" : "Login with Google"),
            ),
            Text(_latlong)
          ],
        ),
      ),
    );
  }
}
