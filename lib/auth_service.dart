import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zooshop/models/User.dart';

Future<void> signInWithGoogleCustom(BuildContext context) async {
  final GoogleSignIn googleSignIn = GoogleSignIn(
  clientId:
      '722768150127-vouo6cv87hb9t7t610m2m6hef8hobnim.apps.googleusercontent.com',
  scopes: [
      'email',
      'https://www.googleapis.com/auth/contacts.readonly',
    ],
  );

   try {
    GoogleSignInAccount? googleUser = await googleSignIn.signInSilently();

      googleUser ??= await googleSignIn.signIn();

    if (googleUser == null) {
      print('User cancelled sign-in');
      return;
    }

    final googleAuth = await googleUser.authentication;

    print('idToken: ${googleAuth.idToken}');

    final String? idToken = googleAuth.idToken;
    if (idToken == null) {
      print('Could not get idToken');
      return;
    }

    final UserDTO? user = await validateGoogleSignIn(idToken);
    if (user != null) {
      try{
        user.address!.toString(); 
      }catch(error){
        print('Error address: $error');
        
      }
      try{
        user.password!.toString(); 
      }catch(error){
        print('Error pass: $error');
        
      }
      try{
        user.googleId!.toString(); 
      }catch(error){
        print('Error googleId: $error');
        
      }

      Provider.of<AuthProvider>(context, listen: false).login(user: user);

    } else {
      print('Error validating customer by Google');
    }
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

