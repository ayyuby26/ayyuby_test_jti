import 'dart:convert';
import 'package:ayyuby_test_jti/const/google_sign_in.dart';
import 'package:ayyuby_test_jti/helper/route_helper.dart';
import 'package:ayyuby_test_jti/model/profile_model.dart';
import 'package:ayyuby_test_jti/view/dashboard_page.dart';
import 'package:ayyuby_test_jti/widgets/google_text_widgets.dart';
import 'package:ayyuby_test_jti/widgets/ripple_button_widget.dart';
import 'package:ayyuby_test_jti/widgets/unfocus_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  void saveProfileToLocal(GoogleSignInAccount account) async {
    final _prefs = await prefs;
    final _map = {
      "name": account.displayName,
      "photo": account.photoUrl,
      "email": account.email,
    };
    _prefs.setString("profile", json.encode(_map));
  }

  void getProfileFromLocal() async {
    final SharedPreferences _prefs = await prefs;
    final _get = _prefs.getString("profile");
    if (_get != null) {
      final _json = json.decode(_get);
      final _model = ProfileModel(
        email: _json['email'],
        name: _json['name'],
        photo: _json['photo'],
      );
      RouteHelper.off(
        context,
        DashboardPage(response: _model),
      );
    }
  }

  RichText get _descLogin => RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          text: "Masuk dengan mudah melalui akun ",
          style: GoogleFonts.sourceSansPro(
            fontSize: 22,
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
          children: googleText,
        ),
      );

  get _loginBtn => Container(
        height: 50,
        width: 270,
        // padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: const Color(0XFFE8E8E8),
          ),
        ),
        child: RippleButtonWidget(
          isBlackRipple: true,
          borderRadius: BorderRadius.circular(10),
          onTap: _handleSignIn,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                "assets/google_logo.svg",
                height: 25,
              ),
              const SizedBox(width: 15),
              Text(
                "Masuk dengan Google",
                style: GoogleFonts.sourceSansPro(
                  fontWeight: FontWeight.w700,
                ),
              )
            ],
          ),
        ),
      );

  get _imgLogin => SvgPicture.asset(
        "assets/login_image.svg",
        height: 175,
      );

  @override
  void initState() {
    super.initState();
    getProfileFromLocal();
  }

  Future<void> _handleSignIn() async {
    try {
      final response = await googleSignIn.signIn();
      if (response != null) {
        if (response.displayName != null) {
          saveProfileToLocal(response);
          final _model = ProfileModel(
            email: response.email,
            name: response.displayName,
            photo: response.photoUrl,
          );
          RouteHelper.off(
            context,
            DashboardPage(
              response: _model,
            ),
          );
        }
      }
    } catch (error) {
      print(error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: UnfocusWidget(
        child: Container(
          padding: const EdgeInsets.all(85),
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  _imgLogin,
                  const SizedBox(height: 20),
                  _descLogin,
                ],
              ),
              _loginBtn
            ],
          ),
        ),
      ),
    );
  }
}
