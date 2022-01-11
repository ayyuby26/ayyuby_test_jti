import 'package:ayyuby_test_jti/const/google_sign_in.dart';
import 'package:ayyuby_test_jti/helper/route_helper.dart';
import 'package:ayyuby_test_jti/model/profile_model.dart';
import 'package:ayyuby_test_jti/view/login_page.dart';
import 'package:ayyuby_test_jti/widgets/unfocus_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:encrypt/encrypt.dart' as k;
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';

class DashboardPage extends StatefulWidget {
  final ProfileModel response;

  const DashboardPage({
    Key? key,
    required this.response,
  }) : super(key: key);

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String _latlong = '';

  final _formKey = GlobalKey<FormState>();
  final _textCtrl = TextEditingController(text: 'Halo Dunia');
  final _keyCtrl = TextEditingController(text: "rahasia--rahasia");

  final _encryptCtrl = TextEditingController();
  final _decryptCtrl = TextEditingController();
  String encryptText = '';
  String decrypted = '';

  final iv = k.IV.fromLength(16);

  List<String>? get _position {
    var _temp = <String>[];
    final _split = _latlong.split(",");
    if (_split.length > 1) {
      _temp.add(_split[0].split(":")[1]);
      _temp.add(_split[1].split(":")[1]);
      return _temp;
    }
  }

  get _profilePicture => Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.black12,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(99),
        ),
        child: Image.network(
          widget.response.photo ?? "https://s.id/RT84",
          height: 45,
        ),
      );

  void aesEncrypt() {
    final _formState = _formKey.currentState;
    if (_formState != null && _formState.validate()) {
      final key = k.Key.fromUtf8(_keyCtrl.text);
      final encrypter = k.Encrypter(k.AES(key));

      final encrypted = encrypter.encrypt(_textCtrl.text, iv: iv);
      debugPrint(encrypted.base64);
      setState(() {
        encryptText = encrypted.base64;
        decrypted = encrypter.decrypt(encrypted, iv: iv);
      });
    }
  }

  Future<Position?> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('gps dimatikan');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Ijin akses lokasi ditolak');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      const _deniedMsg = 'akses lokasi ditolak selamanya';
      return Future.error(_deniedMsg);
    }
    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      return Geolocator.getCurrentPosition();
    }
  }

  _handleSignOut() {
    googleSignIn.disconnect().then((value) async {
      final _prefs = await prefs;
      await _prefs.remove("profile");
      RouteHelper.off(context, const LoginPage());
    });
  }

  @override
  void initState() {
    super.initState();

    _determinePosition().then((value) {
      setState(() {
        _latlong = value.toString();
      });
    }).onError((error, stackTrace) {
      setState(() {
        _latlong = "$error";
      });
    });
  }

  TextStyle get _fontStyl => GoogleFonts.sourceSansPro(
        color: Colors.black,
        fontWeight: FontWeight.normal,
      );

  get _profile => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                _profilePicture,
                const SizedBox(width: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.response.name ?? "Pengguna",
                      style: _fontStyl.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      widget.response.email,
                      style: _fontStyl.copyWith(
                          color: const Color(0XFFAAAAAA),
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _handleSignOut,
            icon: const Icon(
              Icons.logout,
              color: Colors.red,
            ),
          )
        ],
      );

  Row get _latlongWidget => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            "assets/marker.svg",
            width: 20,
          ),
          const SizedBox(width: 7),
          _position == null
              ? Text(
                  _latlong,
                  style: _fontStyl,
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "lat",
                      style: _fontStyl,
                    ),
                    Text(
                      "long",
                      style: _fontStyl,
                    ),
                  ],
                ),
          const SizedBox(width: 7),
          if (_position != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ": ${_position != null ? _position![0] : ""}",
                  style: _fontStyl,
                ),
                Text(
                  ": ${_position != null ? _position![1] : ""}",
                  style: _fontStyl,
                ),
              ],
            ),
        ],
      );

  get _btnStyl {
    return ElevatedButton.styleFrom(
      elevation: 0,
      primary: const Color(0XFF1374F6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  get _encryptWidget {
    _encryptCtrl.text = encryptText;
    _decryptCtrl.text = decrypted;
    return Column(
      children: [
        _encryptForm,
        const SizedBox(height: 30),
        TextFormFieldC(
          ctrl: _encryptCtrl,
          caption: "Teks yang sudah dienkripsi",
        ),
        const SizedBox(height: 7),
        TextFormFieldC(
          ctrl: _decryptCtrl,
          caption: "Teks yang sudah didekripsi",
        ),
      ],
    );
  }

  get _encryptForm {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormFieldC(
            ctrl: _textCtrl,
            caption: "Teks untuk dienkripsi",
          ),
          const SizedBox(height: 7),
          TextFormFieldC(
            ctrl: _keyCtrl,
            isKey: true,
            caption: "kata Kunci",
          ),
          const SizedBox(height: 35),
          SizedBox(
            width: double.maxFinite,
            child: ElevatedButton(
              onPressed: aesEncrypt,
              style: _btnStyl,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  "ENKRIPSI",
                  style: GoogleFonts.sourceSansPro(
                      fontWeight: FontWeight.bold, letterSpacing: 1.5),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: UnfocusWidget(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(30),
              child: ListView(
                physics: const BouncingScrollPhysics(),
                children: [
                  _profile,
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 600,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _encryptWidget,
                        const SizedBox(height: 30),
                        _latlongWidget,
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ));
  }
}

class TextFormFieldC extends StatelessWidget {
  final String caption;
  final TextEditingController ctrl;
  final bool isKey;

  const TextFormFieldC({
    Key? key,
    required this.ctrl,
    this.isKey = false,
    required this.caption,
  }) : super(key: key);

  get _enabledBorder {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(10.0),
      borderSide: const BorderSide(
        color: Color(0xFFd2ddec),
        width: 1,
      ),
    );
  }

  get _inputDecor {
    return InputDecoration(
      counterText: isKey ? null : "",
      counterStyle: _fontStyl,
      hintText: "",
      fillColor: Colors.black.withOpacity(.03),
      filled: true,
      enabledBorder: _enabledBorder,
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: Colors.blue[700]!,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(10.0),
      ),
      errorStyle: GoogleFonts.sourceSansPro(),
      errorBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: Colors.red[700]!,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(10.0),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: Colors.red[700]!,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(10.0),
      ),
      contentPadding: const EdgeInsets.only(
        left: 15,
        right: 15,
      ),
    );
  }

  String? _validator(String? value) {
    if (value == null || value.isEmpty) {
      return "tidak boleh kosong";
    } else if (isKey) {
      if (ctrl.text.length != 16) {
        return "Panjang Kata Kunci Harus 16";
      }
    }
  }

  TextStyle get _fontStyl => GoogleFonts.sourceSansPro(
        color: Colors.black87,
        fontWeight: FontWeight.w600,
      );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 15),
        Text(
          caption,
          style: _fontStyl,
        ),
        const SizedBox(height: 10),
        TextFormField(
          style: _fontStyl,
          validator: _validator,
          maxLength: isKey ? 16 : null,
          maxLengthEnforcement: MaxLengthEnforcement.enforced,
          controller: ctrl,
          decoration: _inputDecor,
        ),
      ],
    );
  }
}
