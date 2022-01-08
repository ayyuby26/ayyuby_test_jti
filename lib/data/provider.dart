import 'package:flutter/foundation.dart';

class State1 extends ChangeNotifier {
  List<String> _phoneNumbers = [];
  List<String> get phoneNumbers => _phoneNumbers;

  void addNumber(String value) {
    _phoneNumbers.add(value);
    notifyListeners();
  }
}
