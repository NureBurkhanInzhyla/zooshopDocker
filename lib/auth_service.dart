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
    scopes: ['email'],
  );

  try {
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
    if (googleUser == null) return; 

    final String email = googleUser.email;
    final String name = googleUser.displayName!;

    UserDTO user;

    try {
      user = await fetchUserByUserEmailGoogle(email);
      print('Пользователь найден: ${user.name}');
    } catch (e) {
      print('Пользователь не найден. Создаём нового.');

      user = UserDTO(
        id: 0, 
        name: name,
        email: email,
        password: '',
        googleId: '',
        address: '',
      );

      await addUser(user);
    }

    Provider.of<AuthProvider>(context, listen: false).login(user: user);
  } catch (error) {
    print('Ошибка Google-входа: $error');
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

