import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:zooshop/models/User.dart';



final GoogleSignIn _googleSignIn = GoogleSignIn(
  clientId: kIsWeb
      ? '480483901810-8de4qeeqob9a4cgrl3j2112fq38b19kj.apps.googleusercontent.com'
      : null,
  scopes: ['email', 'profile'],
);

class SignInDemo extends StatefulWidget {
  const SignInDemo({super.key});

  @override
  State createState() => _SignInDemoState();

  static Future<GoogleSignInAccount?> signIn(BuildContext context) async {
      try {
        final user = await _googleSignIn.signIn();
        if (user != null) {
          final auth = await user.authentication;
          final idToken = auth.idToken;  
          print('ID Token: $idToken');

          // final response = await http.post(
          //   Uri.parse('https://localhost:7097/api/auth/google'),
          //   headers: {'Content-Type': 'application/json'},
          //   body: jsonEncode({'id_token': idToken}),

            
          // );
          
          // final authProvider = Provider.of<AuthProvider>(context, listen: false);
          // authProvider.login(userFromDb);


          // if (response.statusCode == 200) {
          //   final data = jsonDecode(response.body);
          //   Provider.of<AuthProvider>(context, listen: false).login(
          //     userName: data['userName'],
          //     email: data['email'],
          //   );
          // } else {
          //   print('Backend rejected token: ${response.body}');
          // }

          
          return user;
        }
      } catch (e) {
        print('Sign-in error: $e');
      }
      return null;
    }

}

class _SignInDemoState extends State<SignInDemo> {
  GoogleSignInAccount? _currentUser;

  @override
  void initState() {
    super.initState();
    _googleSignIn.signInSilently().then((user) {
      setState(() => _currentUser = user);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(); 
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

