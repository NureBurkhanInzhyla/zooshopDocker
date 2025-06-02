import 'package:flutter/material.dart';
import 'package:zooshop/account_layout.dart';
import 'package:provider/provider.dart';
import 'package:zooshop/models/User.dart';
import 'auth_service.dart';
import 'footer.dart';


class ChangePasswordPage extends StatefulWidget {
  @override
  _ChangePasswordPageState createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Користувач не знайдений')),
      );
      return;
    }

    final updatedUser = user.copyWith(
      password: newPasswordController.text,
    );

    try {
      await updateUser(updatedUser);

      authProvider.setUser(updatedUser);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Пароль успішно змінено')),
      );
      
      newPasswordController.clear();
      confirmPasswordController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Помилка при зміні пароля: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color(0xFF95C74E)),
          onPressed: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => SimpleAccountMenuPage()),
          ),
        ),
          title: Text(
          'Змінити пароль',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF95C74E),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Новий пароль",
                  style: TextStyle(
                    color: Color(0xFF848992),
                    fontSize: 12,
                  ),
                ),
                SizedBox(height: 8),
                TextFormField(
                  controller: newPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: "••••••••••",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return 'Введіть новий пароль';
                    if (value.length < 6)
                      return 'Пароль має містити щонайменше 6 символів';
                    return null;
                  },
                ),
                SizedBox(height: 16),
                Text(
                  "Повторіть пароль",
                  style: TextStyle(
                    color: Color(0xFF848992),
                    fontSize: 12,
                  ),
                ),
                SizedBox(height: 8),
                TextFormField(
                  controller: confirmPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: "••••••••••",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5)),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  ),
                  validator: (value) {
                    if (value != newPasswordController.text)
                      return 'Паролі не співпадають';
                    return null;
                  },
                ),
                SizedBox(height: 24),
                Center(
                  child: SizedBox(
                    width: 201,
                    height: 40,
                    child: ElevatedButton(
                      onPressed: _changePassword,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFC16AFF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      child: Text(
                        'Змінити пароль',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(bottom: 10),
        child: FooterBlock(),
      ),
    );
  }

}
