import 'package:flutter/material.dart';
import 'package:zooshop/account_page.dart';
import 'catalog.dart';
import 'auth_service.dart';
import 'main.dart';
import 'package:provider/provider.dart';
import 'package:zooshop/models/User.dart';
import 'cart_page.dart';
import 'package:go_router/go_router.dart';

class HeaderBlock extends StatelessWidget {
  const HeaderBlock({super.key});

  @override
  Widget build(BuildContext context) {
    
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Container(
                width: double.infinity,
                padding: EdgeInsets.only(top: 30),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 158,
                      height: 158,
                      child: GestureDetector(
                        onTap: () {
                          context.go('/');
                        },
                        child: Image.asset('assets/images/logo.png'),
                      ),
                    ),
                    SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Expanded(
                                  flex: 3, 
                                  child: SearchBar(
                                  onSearch: (query) {
                                    context.push('/catalog/search?query=$query');
                                  },
                                ),
                              ),
                              SizedBox(width: 20),
                              authProvider.isLoggedIn && authProvider.user != null
                                ? UserProfileButton(userName: authProvider.user!.name)
                                : LoginButton(),
                            ],
                          ),
                          SizedBox(height: 20),
                          MenuBottomNavigation(),
                        ],
                      ),
                    ),
                  ],
                ),
              );
      },
    );
  }
}



class MenuBottomNavigation extends StatelessWidget {
  const MenuBottomNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          spacing: 30.0,
          children: [
            Row(
              spacing: 15,
              children: [
                TextButton(
                  onPressed: () {
                   context.push('/catalog');

                  },
                  child: Text("Усі товари", style: TextStyle(color: Colors.black)),
                ),
                TextButton(
                  onPressed: () {
                    context.push('/catalog/animal?type=Кішки');

                  },
                  child: Text("Кішки", style: TextStyle(color: Colors.black)),
                ),
                TextButton(
                  onPressed: () {
                    context.push('/catalog/animal?type=Собаки');

                  },
                  child: Text("Собаки", style: TextStyle(color: Colors.black)),
                ),
                TextButton(
                  onPressed: () {
                    context.push('/catalog/animal?type=Гризуни');

                  },
                  child: Text("Гризуни", style: TextStyle(color: Colors.black)),
                ),
                TextButton(
                 onPressed: () {
                    context.push('/catalog/animal?type=Птахи');

                  },
                  child: Text("Птахи", style: TextStyle(color: Colors.black)),
                ),
                TextButton(
                  onPressed: () {
                    context.push('/catalog/animal?type=Риби');

                  },
                  child: Text("Риби", style: TextStyle(color: Colors.black)),
                ),
                TextButton(
                  onPressed: () {
                    context.push('/catalog/animal?type=Рептилії');

                  },
                  child: Text("Рептилії", style: TextStyle(color: Colors.black)),
                ),
                 TextButton(
                  onPressed: () {
                    context.push('/promotions');
                  },
                  child: Text("Акції %", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
           
          ],
        ),
      ],
    );
  }
}

class LoginButton extends StatelessWidget {
  const LoginButton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 165,
      height: 60,
      child: ElevatedButton.icon(
        onPressed: () {
          showRegisterDialog(context);
        },

        icon: Icon(
          Icons.person,
          color: Color(0xFF95C74E),
        ),
        label: Text(
          'Log In/Sign In',
          style: TextStyle(
            color: Colors.brown,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
            side: BorderSide(color: Colors.grey),
          ),
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
       
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
      mainAxisSize: MainAxisSize.min,  
      children: [
        SizedBox(
          height: 60,
          child: ElevatedButton.icon(
            onPressed: () {
              context.push('/account');

            },
            icon: Icon(Icons.person, color: Color(0xFF95C74E)),
            label: Text(
              userName,
              style: TextStyle(color: Colors.brown, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
                side: BorderSide(color: Colors.grey),
              ),
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
        ),

        SizedBox(width: 7),  

        SizedBox(
          height: 60,
          child: ElevatedButton(
            onPressed: () {
              context.push('/cart');

            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
                side: BorderSide(color: Colors.grey),
              ),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            child: Icon(Icons.shopping_cart, color: Colors.brown, size: 28),
          ),
        ),
      ],
    );
  }
}


class SearchBar extends StatefulWidget {
  final Function(String) onSearch;

  const SearchBar({Key? key, required this.onSearch}) : super(key: key);

  @override
  _SearchBarState createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  final TextEditingController _controller = TextEditingController();

  void _onSearchPressed() {
    final query = _controller.text.trim();
    if (query.isNotEmpty) {
      widget.onSearch(query);
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      decoration: InputDecoration(
        labelText: 'Пошук товарів',
        suffixIcon: IconButton(
          icon: Icon(Icons.search, color: Color(0xFF95C74E)),
          onPressed: _onSearchPressed,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: BorderSide(color: Colors.grey, width: 0.5),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      ),
      onSubmitted: (_) => _onSearchPressed(),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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

        context.pop();
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
        context.pop();

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
      contentPadding: EdgeInsets.symmetric(horizontal: 70, vertical: 30),
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
                  context.pop();
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

