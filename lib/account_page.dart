import 'package:flutter/material.dart';
import 'package:zooshop/account_layout.dart';
import 'package:provider/provider.dart';
import 'package:zooshop/models/User.dart';
import 'auth_service.dart';


class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  late TextEditingController nameController;
  late TextEditingController surnameController;
  late TextEditingController phoneController;
  late TextEditingController emailController;

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController();
    surnameController = TextEditingController();
    phoneController = TextEditingController();
    emailController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;

    if(user != null){
      final fullName = user.name;

      final parts = fullName.split(' ');
      final firstName = parts.isNotEmpty ? parts[0] : '';
      final lastName = parts.length > 1 ? parts.sublist(1).join(' ') : '';

      nameController.text = firstName;
      surnameController.text = lastName;
      emailController.text = user.email;
    }
    
  }

  @override
  void dispose() {
    nameController.dispose();
    surnameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    super.dispose();
  }
  void _saveUser() {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final user = authProvider.user;

      if (user == null) {
        return;
      }

      UserDTO updatedUser = user.copyWith(
        name: '${nameController.text} ${surnameController.text}'.trim(),
        email: emailController.text,
      );

      authProvider.setUser(updatedUser);
      try{
        updateUser(updatedUser);
        ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Особисті дані успішно збережено')),
      );
      } 
      catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Помилка при зміні особистих даних: $e')),
      );
    }
  }



  @override
  Widget build(BuildContext context) {
    return AccountLayout(
      activeMenu: 'Обліковий запис',
      child: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _labeledField('Ім’я', nameController),
            _labeledField('Прізвище', surnameController),
            _labeledField('Телефон', phoneController),
            _labeledField('E-mail', emailController),
            SizedBox(height: 20),
            SizedBox(
              width: 140,
              height: 40,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(140, 40),
                  backgroundColor: const Color(0xFFC16AFF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                onPressed: () {
                  _saveUser();
                },
                child: Text(
                  'Зберегти',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _labeledField(String label, TextEditingController controller) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 14)),
        SizedBox(height: 6),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),  
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: Colors.grey.shade400),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: Color(0xFFC16AFF)),
            ),
          ),
        ),
      ],
    ),
  );
}

}
