import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zooshop/models/User.dart';
import 'package:google_sign_in/google_sign_in.dart';

Future<UserDTO?> signInWithGoogleCustom(BuildContext context) async {
  // final GoogleSignIn googleSignIn = GoogleSignIn(
  // clientId:
  //     '722768150127-vouo6cv87hb9t7t610m2m6hef8hobnim.apps.googleusercontent.com',
  // scopes: [
  //     'email'
  //   ],
  // );

   try {
     final GoogleSignInAccount? googleUser = await GoogleSignIn().signInSilently();

    if (googleUser == null) {
      print('User cancelled sign-in');
      return null;
    }
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;




    final String? idToken = googleAuth?.idToken;
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

