import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:zooshop/models/User.dart';


Future<void> signInWithGoogleCustom(BuildContext context) async {
  final GoogleSignIn googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    serverClientId: '480483901810-8de4qeeqob9a4cgrl3j2112fq38b19kj.apps.googleusercontent.com',
  );

  try {
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
    if (googleUser == null) return; 

    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    final String? idToken = googleAuth.idToken;
    if (idToken == null) {
      print('Could not get idToken');
      return;
    }

    final UserDTO? user = await validateGoogleSignIn(idToken);
    if (user != null) {
      Provider.of<AuthProvider>(context, listen: false).login(user: user);
    } else {
      print('Error validating customer by Google');
    }
  } catch (error) {
    print('Error Google-sign in: $error');
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

