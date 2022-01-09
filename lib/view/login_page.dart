import 'package:ayyuby_test_jti/const/google_sign_in.dart';
import 'package:ayyuby_test_jti/widgets/unfocus_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:encrypt/encrypt.dart' as k;

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String _latlong = '';
  String _googleName = '';

  get _btnStyl {
    return ElevatedButton.styleFrom(
      elevation: 0,
      primary: Colors.blue[600],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  get _signInWithGoogle {
    return ElevatedButton(
      style: _btnStyl,
      onPressed: _googleName.isNotEmpty ? _handleSignOut : _handleSignIn,
      child: Text(_googleName.isNotEmpty ? "Logout" : "Login with Google"),
    );
  }

  get _encryptWidget {
    return Column(
      children: [
        _encryptForm,
        Text(
          "encrypt: " + encryptText,
          textAlign: TextAlign.center,
        ),
        Text(
          "decrypt: " + decrypted,
          textAlign: TextAlign.center,
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
            caption: "Text to Encrypt",
          ),
          TextFormFieldC(
            ctrl: _keyCtrl,
            isKey: true,
            caption: "key (panjang harus 16)",
          ),
          // const SizedBox(height: 15),
          ElevatedButton(
            onPressed: aesEncrypt,
            style: _btnStyl,
            child: const Text(
              "AES encrypt",
            ),
          ),
        ],
      ),
    );
  }

  get _userGoogleName {
    return (_googleName.isNotEmpty)
        ? Text("Welcome: " + _googleName)
        : const SizedBox();
  }

  Future<Position?> _determinePosition() async {
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
      const _deniedMsg = 'Location permissions are permanently denied.';
      return Future.error(_deniedMsg);
    }
    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      return Geolocator.getCurrentPosition();
    }
  }

  @override
  void initState() {
    _determinePosition().then((value) {
      setState(() {
        _latlong = value.toString();
      });
    }).onError((error, stackTrace) {
      setState(() {
        _latlong = "$error";
      });
    });
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

  final _formKey = GlobalKey<FormState>();
  final _textCtrl = TextEditingController(text: 'Halo Dunia');
  final _keyCtrl = TextEditingController(text: "rahasia--rahasia");
  String encryptText = '';
  String decrypted = '';

  final iv = k.IV.fromLength(16);

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: UnfocusWidget(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  _userGoogleName,
                  _signInWithGoogle,
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(25),
                child: _encryptWidget,
              ),
              Text(_latlong)
            ],
          ),
        ),
      ),
    );
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
      hintText: "",
      fillColor: Colors.white,
      filled: true,
      enabledBorder: _enabledBorder,
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: Colors.blue[700]!,
          width: 1,
        ),
        gapPadding: 0,
        borderRadius: BorderRadius.circular(10.0),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: Colors.red[700]!,
          width: 1,
        ),
        gapPadding: 0,
        borderRadius: BorderRadius.circular(10.0),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: Colors.red[700]!,
          width: 1,
        ),
        gapPadding: 0,
        borderRadius: BorderRadius.circular(10.0),
      ),
      contentPadding: const EdgeInsets.only(
        left: 15,
        bottom: 11,
        top: 11,
        right: 15,
      ),
    );
  }

  String? _validator(String? value) {
    if (value == null || value.isEmpty) {
      return "tidak boleh kosong";
    } else if (isKey) {
      if (ctrl.text.length != 16) {
        return "panjang key harus 16";
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 15),
        Text(caption),
        const SizedBox(height: 10),
        TextFormField(
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
