import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zooshop/models/User.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<UserDTO?> signInWithGoogleCustom(BuildContext context) async {
  final GoogleSignIn googleSignIn = GoogleSignIn(
  serverClientId:
      '722768150127-vouo6cv87hb9t7t610m2m6hef8hobnim.apps.googleusercontent.com',
  scopes: [
      'email'
    ],
  );

   try {
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

    if (googleUser == null) {
      print('User cancelled sign-in');
      return null;
    }
    // final googleAuth = await googleUser.authentication;

    final String? serverAuthCode = googleUser.serverAuthCode;
    if (serverAuthCode == null) {
      print('No server auth code received');
      return null;
    }
    final tokens = await exchangeServerAuthCodeForTokens(serverAuthCode);
    final idToken = tokens?['id_token'];
    if (idToken == null) {
      print('Could not get idToken');
      return null;
    }

    final UserDTO? user = await validateGoogleSignIn(idToken);
    if (user == null) {
      print('Error validating customer by Google');
      return null;
    }
    return user;

  } catch (error, stackTrace) {
    print('Error Google-sign in: $error');
    print('Stack trace: $stackTrace');
  }

}


class AuthProvider extends ChangeNotifier { 
  bool _isLoggedIn = false;
  UserDTO? _user;

  bool get isLoggedIn => _isLoggedIn;
  UserDTO? get user => _user;

void login({required UserDTO user}) {
  _isLoggedIn = true;
  _user = user;
  notifyListeners();
}

  void logout() {
    _isLoggedIn = false;
    _user = null;
    notifyListeners();
  }
  void setUser(UserDTO user) {
    _user = user;
    notifyListeners();
  }
}

Future<Map<String, dynamic>?> exchangeServerAuthCodeForTokens(
    String serverAuthCode) async {
  final response = await http.post(
    Uri.parse('https://oauth2.googleapis.com/token'),
    headers: {'Content-Type': 'application/x-www-form-urlencoded'},
    body: {
      'client_id': 'YOUR_WEB_CLIENT_ID.apps.googleusercontent.com',
      'client_secret': 'YOUR_CLIENT_SECRET',
      'code': serverAuthCode,
      'grant_type': 'authorization_code',
      'redirect_uri': '', // или 'postmessage'
    },
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    print('Tokens response: $data');
    return data;
  } else {
    print('Failed token exchange: ${response.body}');
    return null;
  }
}