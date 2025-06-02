import 'package:flutter/material.dart';
import 'package:zooshop/account_layout.dart';
import 'package:provider/provider.dart';
import 'auth_service.dart';
import 'package:zooshop/models/User.dart';
import 'footer.dart';

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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color(0xFF95C74E)),
          onPressed: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => SimpleAccountMenuPage()),
          ),
        ),
        title: Text(
          'Адреса доставки',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF95C74E),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: addressController,
                decoration: InputDecoration(
                  labelText: 'Адреса',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
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
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                child: Text(
                  'Зберегти',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
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



// void _confirmDelete(int index) {
//   showDialog(
//     context: context,
//     barrierDismissible: false,
//     builder: (context) => Dialog(
//       backgroundColor: Color(0xFFFFFFFF),
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(10),
//       ),
//       child: SizedBox(
//         width: 460,
//         height: 179,
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Padding(
//               padding: EdgeInsets.only(top: 24),
//               child: Text(
//                 'Ви впевнені, що бажаєте\nвидалити адресу?',
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                   color: Color(0xFF512A09),
//                 ),
//               ),
//             ),
//             Padding(
//               padding: EdgeInsets.only(bottom: 24, left: 94),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.start,
//                 children: [
//                   SizedBox(
//                     width: 131,
//                     height: 40,
//                     child: OutlinedButton(
//                           onPressed: () => Navigator.pop(context),
//                           style: OutlinedButton.styleFrom(
//                             foregroundColor: Color(0xFF67AF45),
//                             side: BorderSide(color: Color(0xFF67AF45)),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(5),
//                             ),
//                             padding: EdgeInsets.symmetric(horizontal: 0), 
//                           ),
//                           child: Text(
//                             'Скасувати',
//                             style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
//                             textAlign: TextAlign.center,
                            
//                           ),
//                         ),
//                   ),
//                   SizedBox(width: 15),
//                   SizedBox(
//                     width: 131,
//                     height: 40,
//                     child: ElevatedButton(
//                           onPressed: () {
//                             setState(() {
//                               addresses.removeAt(index);
//                             });
//                             Navigator.pop(context);
//                           },
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Color(0xFFF74E4E),
//                             foregroundColor: Color(0xFFFFFFFF),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(5),
//                             ),
//                             padding: EdgeInsets.symmetric(horizontal: 0),
//                           ),
//                           child: Text(
//                             'Видалити',
//                             style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
//                             textAlign: TextAlign.center,
//                           ),
//                         ),

//                   ),
//                 ],
//               ),
//             )
//           ],
//         ),
//       ),
//     ),
//   );
// }

// }
// class AddressForm {
//   String city = 'Харків';
//   String address = '';
// }

