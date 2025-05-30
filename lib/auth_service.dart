import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io' show Platform;
import 'package:zooshop/models/User.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

Future<void> signInWithGoogle(BuildContext context) async {
  final GoogleSignIn googleSignIn = GoogleSignIn();

  final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
  if (googleUser == null) return; 

  final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

  final credential = GoogleAuthProvider.credential(
    accessToken: googleAuth.accessToken,
    idToken: googleAuth.idToken,
  );

  final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
    final firebaseUser = userCredential.user;

    if (firebaseUser == null || firebaseUser.email == null) {
      print('Ошибка: не удалось получить пользователя Firebase');
      return;
    }

    UserDTO? user = await fetchUserByUserEmailGoogle(firebaseUser.email!);

    if (user == null) {
      user = UserDTO(
        name: firebaseUser.displayName ?? '',
        email: firebaseUser.email!,
        password: '',
        googleId: '',
        address:'',
      );
    }

    Provider.of<AuthProvider>(context, listen: false).login(user: user);
    print('Succes sign in: ${user.name}');
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

