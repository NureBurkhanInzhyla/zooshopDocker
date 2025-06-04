import 'package:flutter/material.dart';
import 'package:zooshop/account_layout.dart';
import 'package:provider/provider.dart';
import 'auth_service.dart';
import 'package:zooshop/models/User.dart';

class AddressPage extends StatefulWidget {
  @override
  _AddressPageState createState() => _AddressPageState();
}

class _AddressPageState extends State<AddressPage> {
  late TextEditingController addressController;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;

    addressController = TextEditingController(text: user?.address ?? '');
  }


  @override
  void dispose() {
    addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return AccountLayout(
      activeMenu: 'Адреса доставки',
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Text('Адреса доставки', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            TextFormField(
              controller: addressController,
              decoration: InputDecoration(
                labelText: 'Адреса',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
              ),
              maxLines: null, 
            ),
            SizedBox(height: 25),
            ElevatedButton(
              onPressed: () async {
                  final authProvider = Provider.of<AuthProvider>(context, listen: false);
                  final user = authProvider.user;

                  if (user == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Користувач не знайдений')),
                    );
                    return;
                  }

                  final updatedUser = user.copyWith(
                    address: addressController.text.trim(),
                  );

                  authProvider.setUser(updatedUser);

                  try {
                    await updateUser(updatedUser); 
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Особисті дані успішно збережено')),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Помилка при зміні особистих даних: $e')),
                    );
                  }
                },

              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFC16AFF),
                padding: EdgeInsets.symmetric(vertical: 20, horizontal: 70),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
              ),
              child: Text(
                'Зберегти',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

