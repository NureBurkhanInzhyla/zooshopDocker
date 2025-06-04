import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:zooshop/footer.dart';
import 'package:zooshop/header.dart';
import 'package:zooshop/main.dart';
import 'auth_service.dart';
import 'package:zooshop/cartProvider.dart';
import 'package:zooshop/models/Cart.dart';
import 'package:zooshop/models/Order.dart';
import 'package:zooshop/models/Monobank.dart';
import 'package:url_launcher/url_launcher.dart';

class CheckoutPage extends StatefulWidget {
  @override
  _CheckoutPageState createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  String selectedDelivery = 'courier';
  String selectedPayment = 'cash';
  bool agreedToTerms = true;

  final nameController = TextEditingController();
  final surnameController = TextEditingController();
  final emailController = TextEditingController();
  final commentController = TextEditingController();
  final addressController = TextEditingController();



  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;
    if (user != null) {
      final parts = user.name.split(' ');
      nameController.text = parts.isNotEmpty ? parts[0] : '';
      surnameController.text = parts.length > 1 ? parts.sublist(1).join(' ') : '';
      emailController.text = user.email;
      if (user.address != null) {
        addressController.text = user.address!;
      }
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    surnameController.dispose();
    emailController.dispose();
    commentController.dispose();
    addressController.dispose();
    super.dispose();
  }

 @override
Widget build(BuildContext context) {
  final screenWidth = MediaQuery.of(context).size.width;

  return Scaffold(
    backgroundColor: Colors.white,
    body: SingleChildScrollView(
      child: Column(
        children: [
          Center(
            child: SizedBox(
              width: screenWidth * 0.82,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  HeaderBlock(),
                  SizedBox(height: 20),
                  Text(
                    "Оформлення замовлення",
                    style: GoogleFonts.montserrat(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF95C74E),
                    ),
                  ),
                  SizedBox(height: 30),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionTitle('Покупець'),
                    _buildInput('Ім’я', controller: nameController),
                    _buildInput('Прізвище', controller: surnameController),
                    _buildInput('Email', controller: emailController),
                    SizedBox(height: 30),
                    _buildInput('Адреса доставки', controller: addressController),

                    SizedBox(height: 30),
                    _sectionTitle('Коментар до замовлення'),
                    _buildCommentField(),
                  ],
                ),
              ),

              SizedBox(width: 50),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionTitle('Спосіб доставки'),
                    _buildRadioOption('Доставка кур’єром\nпо м. Київ, от 500 грн - безкоштовно', 'courier'),
                    _buildRadioOption('Самовивіз\nвул. Полтавський шлях 6 А - магазин зоотоварів "Пухнастик"', 'pickup'),
                    _buildRadioOption('Нова Пошта\nвід 500 грн (за передплатою) - безкоштовно', 'nova'),
                    SizedBox(height: 30),
                    _sectionTitle('Спосіб оплати'),
                    DropdownButtonFormField<String>(
                      value: selectedPayment,
                      items: [
                        DropdownMenuItem(
                          value: 'cash',
                          child: Text('Готівкою при отриманні'),
                        ),
                        DropdownMenuItem(
                          value: 'card',
                          child: Text('Оплата картою'),
                        ),
                      ],
                      onChanged: (val) {
                        setState(() {
                          selectedPayment = val!;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 70),

          Row(
            children: [
              Text(
                'Сума замовлення: ',
                style: GoogleFonts.montserrat(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${Provider.of<CartProvider>(context, listen: false).totalPrice} ₴',
                style: GoogleFonts.montserrat(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF67AF45),
                ),
              ),
              Spacer(),
              Checkbox(
                value: agreedToTerms,
                onChanged: (val) => setState(() => agreedToTerms = val!),
                activeColor: Color(0xFFB460DC),
              ),
              Text('Я прочитав та згоден з '),
              TextButton(
                onPressed: () {},
                child: Text(
                  'Умовами згоди',
                  style: TextStyle(color: Color(0xFFB460DC)),
                ),
              ),
              SizedBox(width: 16),
              ElevatedButton(
                onPressed: isFormValid ? () async {
                  final authProvider = Provider.of<AuthProvider>(context, listen: false);
                  final user = authProvider.user;

                  if (user != null) {
                    if(selectedPayment == 'card')
                    {
                      try {
                        //int orderId = await createOrder(user.id!);
                        //await clearCart(user.id!);

                        final MonobankService _monobankService = MonobankService();
                        final url = await _monobankService.createInvoice(
                          amount: Provider.of<CartProvider>(context, listen: false).totalPrice * 100, // 42.00 UAH
                          currency: 980, // UAH (передаем как int, а не строку)
                          description: 'Test payment',
                          redirectUrl: 'https://zooshop-61f32.firebaseapp.com/',
                          webhookUrl: 'https://zooshop-dnu7.onrender.com/api/Webhook',
                          reference: user.id.toString()
                        );
                        final Uri _url = Uri.parse(url);
                        await launchUrl(_url);
                        Provider.of<CartProvider>(context, listen: false).clear();
                        Navigator.of(context).pop(); 
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (_) => MainPage()),
                          (route) => false,
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Помилка при створенні замовлення')),
                        );
                      }
                    }
                  } else {
                    await createOrder(user!.id!);
                    await clearCart(user.id!);
                    showOrderConfirmationDialog(context);
                  }
                } : null,

                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFB460DC),
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
                child: Text(
                  'Підтвердити замовлення',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ],
          ),

                  SizedBox(height: 80),
                ],
              ),
            ),
          ),

          FooterBlock(),
        ],
      ),
    ),
  );
}

  bool get isFormValid {
    return nameController.text.trim().isNotEmpty &&
        surnameController.text.trim().isNotEmpty &&
        emailController.text.trim().isNotEmpty &&
        addressController.text.trim().isNotEmpty &&
        agreedToTerms;
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.w600),
    );
  }

  Widget _buildInput(String label, {required TextEditingController controller}) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 12),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
        ),
      ),
    );
  }

  Widget _buildCommentField() {
    return TextField(
      controller: commentController,
      maxLines: 4,
      decoration: InputDecoration(
        hintText: 'Коментар',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
      ),
    );
  }

  Widget _buildRadioOption(String text, String value) {
    return RadioListTile<String>(
      value: value,
      groupValue: selectedDelivery,
      onChanged: (val) => setState(() => selectedDelivery = val!),
      title: Text(text),
      contentPadding: EdgeInsets.zero,
    );
  }

  void showOrderConfirmationDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false, 
    builder: (BuildContext context) {
      return Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/images/logo.png', 
                    height: 200,
                    width: 200,
                  ),

                  Text(
                    'Дякуємо за замовлення!',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF67AF45),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 12),

                  Text(
                    'Очікуйте лист із підтвердженням на вашу\nелектронну пошту найближчим часом',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 30),
                ],
              ),
            ),

            Positioned(
              top: 12,
              right: 12,
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).pop(); 
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => MainPage()),
                    (route) => false,
                  );
                },
                child: CircleAvatar(
                  radius: 14,
                  backgroundColor: Colors.green.shade100,
                  child: Icon(Icons.close, size: 18, color: Colors.green),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}



}
