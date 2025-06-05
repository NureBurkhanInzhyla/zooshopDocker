import 'package:flutter/material.dart';
import 'main.dart';
import 'auth_service.dart';
import 'package:provider/provider.dart';
import 'cart_page.dart';
import 'package:zooshop/models/User.dart';
import 'account_page.dart';
import 'account_layout.dart';
import 'chat_page.dart';

class FooterBlock extends StatelessWidget {
  const FooterBlock({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Container(
         
          child: Row(
            children: [
              IntrinsicWidth(
                child: SizedBox(
                  height: 60,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => MainPage()),
                        (route) => false,
                      );
                    },
                    child: const Icon(Icons.home, color: Color(0xFF95C74E), size: 24),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(0),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      backgroundColor: Colors.white,
                    ),
                  ),
                ),
              ),


              IntrinsicWidth(
                child: SizedBox(
                  height: 60,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => const ChatPage(), 
                      ));
                    },
                    child: const Icon(Icons.chat, color: Color(0xFF95C74E), size: 24),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(0),
                      ),
                      backgroundColor: Colors.white,
                    ),
                  ),
                ),
              ),


              Expanded(
                child: SizedBox(
                  height: 60,
                  child: authProvider.isLoggedIn && authProvider.user != null
                      ? UserProfileButton(userName: authProvider.user!.name)
                      : const LoginButton(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}



class LoginButton extends StatelessWidget {
  const LoginButton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: ElevatedButton.icon(
        onPressed: () {
          showRegisterDialog(context);
        },
        icon: const Icon(
          Icons.person,
          color: Color(0xFF95C74E),
        ),
        label: const Text(
          'Log In/Sign In',
          style: TextStyle(
            color: Color.fromARGB(153, 61, 61, 61),
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0), 
            side: const BorderSide(color: Color.fromARGB(153, 61, 61, 61)),
          ),
        ),
      ),
    );
  }
}


class UserProfileButton extends StatelessWidget {
  final String userName;

  const UserProfileButton({super.key, required this.userName});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
            height: 60,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SimpleAccountMenuPage(),
                  ),
                );
              },
              icon: const Icon(Icons.person, color: Color(0xFF95C74E)),
              label: Text(
                userName,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color.fromARGB(240, 61, 61, 61),
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(0), 

                  side: const BorderSide(color: Color.fromARGB(153, 61, 61, 61)),
                ),
              ),
            ),
          ),


        Expanded(
          child: SizedBox(
            height: 60,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CartPage(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(0),
                  side: const BorderSide(color: Color.fromARGB(153, 61, 61, 61)),
                ),
              ),
              child: const Icon(Icons.shopping_cart, color: Color(0xFF95C74E), size: 28),
            ),
          ),
        ),
      ],
    );
  }
}

class RegisterDialog extends StatefulWidget {
  const RegisterDialog({Key? key}) : super(key: key);

  @override
  State<RegisterDialog> createState() => _RegisterDialogState();
}

class _RegisterDialogState extends State<RegisterDialog> {
  bool _isLoginMode = false; 

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String? _error;
  bool _isLoading = false;
  Future<void> _register() async {
      final name = _nameController.text.trim();
      final email = _emailController.text.trim();
      final password = _passwordController.text;

      if (name.isEmpty || email.isEmpty || password.isEmpty) {
        setState(() {
          _error = 'Будь ласка, заповніть всі поля';
        });
        return;
      }
      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
        setState(() {
          _error = 'Введіть коректний email';
        });
        return;
      }
      if (password.length < 6) {
        setState(() {
          _error = 'Пароль повинен бути не менше 6 символів';
        });
        return;
      }

      setState(() {
        _isLoading = true;
        _error = null;
      });

      try {
        UserDTO newUser = UserDTO(
          id: 0,
          name: name,
          email: email,
          password: password,
        );

        await addUser(newUser); 

        final savedUser = await fetchUserByUserEmail(email, password); 

        Provider.of<AuthProvider>(context, listen: false).login(user: savedUser);

        Navigator.of(context).pop();
      } catch (e) {
        setState(() {
          _error = 'Помилка при реєстрації'; 
        });
      }


  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _toggleMode() {
    setState(() {
      _isLoginMode = !_isLoginMode;
      _error = null;
      _nameController.clear();
      _emailController.clear();
      _passwordController.clear();
    });
  }

  void _registerOrLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      if (_isLoginMode) {
        UserDTO loggedUser = await fetchUserByUserEmail(email, password);
        Provider.of<AuthProvider>(context, listen: false).login(user: loggedUser);
        Navigator.of(context).pop();

      } else {
        _register();
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/images/logo.png', height: 180, width: 180,),
            Text(
              _isLoginMode ? 'Вхід' : 'Реєстрація',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.brown,
              ),
            ),
            SizedBox(height: 20),

           if (!_isLoginMode)
                SizedBox(
                  width: 300, 
                  child: TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Ім`я та Прізвище',
                      hintText: 'Введіть ім`я та прізвище',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.text,
                  ),
                ),

              if (!_isLoginMode) SizedBox(height: 12),

              SizedBox(
                width: 300,
                child: TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'E-mail',
                    hintText: 'Введіть ваш email',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
              ),

              SizedBox(height: 12),

              SizedBox(
                width: 300,
                child: TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Пароль',
                    hintText: _isLoginMode ? 'Введіть пароль' : 'Створіть пароль',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                ),
              ),
            SizedBox(height: 20),
            if (_error != null)
              Text(
                _error!,
                style: TextStyle(color: Colors.red),
              ),
            SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _registerOrLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF95C74E),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text(
                        _isLoginMode ? 'Увійти' : 'Зареєструватися',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                children: [
                  Expanded(child: Divider(thickness: 1, color: Colors.brown)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text('Або', style: TextStyle(color: Colors.brown)),
                  ),
                  Expanded(child: Divider(thickness: 1, color: Colors.brown)),
                ],
              ),
            ),

            OutlinedButton.icon(
              onPressed: () async {
                final user = await signInWithGoogleCustom(context);
                if (!context.mounted) return;

                if (user != null) {
                  Provider.of<AuthProvider>(context, listen: false).login(user: user);
                  Navigator.of(context).pop();
                }

            },
              icon: Image.asset('assets/images/google_image.png', height: 24),
              label: Text(''),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                side: BorderSide(color: Colors.grey),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),

            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(_isLoginMode ? 'Немає аккаунта?' : 'Вже маєте аккаунт?'),
                TextButton(
                  onPressed: _toggleMode,
                  child: Text(
                    _isLoginMode ? 'Зареєструватися' : 'Увійти',
                    style: TextStyle(color: Color(0xFF95C74E)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


void showRegisterDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (_) => RegisterDialog(),
  );
}
