import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../Models/http_exception.dart';

class Auth with ChangeNotifier {
  late String token = '';
  late String userID = '';
  late DateTime expiryDate;
  var authTimer;

  get isAuth {
    if (token.isNotEmpty &&
        userID.isNotEmpty &&
        expiryDate.isAfter(DateTime.now())) {
      return true;
    }
    return false;
  }

  get authToken {
    if (token.isNotEmpty &&
        userID.isNotEmpty &&
        expiryDate.isAfter(DateTime.now())) {
      return token;
    }
    return '';
  }

  get authUserID {
    return userID;
  }

  Future<void> authentication(
      String? email, String? password, String authModeSegment) async {
    try {
      final url = Uri.parse(
          'https://identitytoolkit.googleapis.com/v1/$authModeSegment?key=AIzaSyAmngucBUxTdHpJvRP1ttp7I_jzAReDAqo');
      final response = await http.post(
        url,
        body: json.encode({
          'email': email,
          'password': password,
          'returnSecureToken': true,
        }),
      );
      final responseData = json.decode(response.body) as Map<String, dynamic>;
      if (responseData.keys.contains('error')) {
        throw HttpException(responseData['error']['message']);
      }
      final expDate = DateTime.now()
          .add(Duration(seconds: int.parse(responseData['expiresIn'])))
          .toIso8601String();
      token = responseData['idToken'];
      userID = responseData['localId'];
      expiryDate = DateTime.parse(expDate);
      autoLogout();
      notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      final prefsData = json.encode({
        'token': token,
        'userID': userID,
        'expiryDate': expiryDate.toIso8601String()
      });
      prefs.setString('userData', prefsData);
    } catch (_) {
      rethrow;
    }
  }

  Future<void> signup(String? email, String? password) async {
    return authentication(email, password, 'accounts:signUp');
  }

  Future<void> login(String? email, String? password) async {
    return authentication(email, password, 'accounts:signInWithPassword');
  }

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) {
      return false;
    }
    final extractedUserData = json.decode(prefs.getString('userData') as String)
        as Map<String, dynamic>;
    final expDate = DateTime.parse(extractedUserData['expiryDate']);
    if (expDate.isBefore(DateTime.now())) {
      return false;
    }
    token = extractedUserData['token'];
    userID = extractedUserData['userID'];
    expiryDate = expDate;
    autoLogout();
    notifyListeners();

    return true;
  }

  Future<void> logout() async {
    token = '';
    userID = '';
    if (authTimer != null) {
      authTimer.cancel();
      authTimer = null;
    }
    final prefs = await SharedPreferences.getInstance();
    // prefs.remove(('userData'));     to remove specific data
    prefs.clear(); // to remove all data
    notifyListeners();
  }

  void autoLogout() {
    if (authTimer != null) {
      authTimer.cancel();
    }
    final expiryTime = expiryDate.difference(DateTime.now()).inSeconds;
    authTimer = Timer(Duration(seconds: expiryTime), logout);
  }
}
