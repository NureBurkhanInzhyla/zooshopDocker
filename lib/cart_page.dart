import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zooshop/models/Product.dart';
import 'package:zooshop/models/Subscription.dart';
import 'header.dart';
import 'footer.dart';
import 'auth_service.dart';
import 'package:zooshop/models/Cart.dart';
import 'package:provider/provider.dart';
import 'package:zooshop/checkout_page.dart';
import 'package:zooshop/cartProvider.dart';
import 'package:intl/intl.dart';
import 'package:zooshop/models/Monobank.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:go_router/go_router.dart';

class CartPage extends StatefulWidget {
  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;
    final screenWidth = MediaQuery.of(context).size.width;

    if (user == null || user.id == null) {
      return Scaffold(
        body: Center(child: Text('Користувач не авторизований')),
      );
    }

    return Consumer<CartProvider>(
      builder: (context, cartProvider, _) {
        final cartItems = cartProvider.items;

          return Scaffold(
            backgroundColor: Colors.white,
            body: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: SizedBox(
                      width: screenWidth * 0.82,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          HeaderBlock(),
                          SizedBox(height: 10),
                          Padding(
                            padding: EdgeInsets.only(left: 20, top: 20),
                            child: Text(
                              "Кошик",
                              style: GoogleFonts.montserrat(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF95C74E),
                              ),
                            ),
                          ),
                          SizedBox(height: 50),
                          Padding(
                            padding: EdgeInsets.only(bottom: 50),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: cartItems.isNotEmpty
                                        ? cartItems
                                            .asMap()
                                            .entries
                                            .map((entry) => _buildCartItem(entry.value, entry.key))
                                            .toList()
                                        : [Text('Кошик порожній')],
                                  ),
                                ),
                                SizedBox(width: 50),
                                _buildSummaryBlock(context, cartProvider.totalPrice),
                              ],
                            ),
                          ),
                          SizedBox(height: 77),
                        ],
                      ),
                    ),
                  ),
                  FooterBlock(),
                ],
              ),
            ),
          );
        },
      );
    }


    
  Widget _buildCartItem(Cart cartItem, int index) {

  final item = cartItem.product;


  return Container(
    padding: EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                SizedBox(
                  width: 126,
                  height: 126,
                  child: Image.asset(item.image, fit: BoxFit.contain),
                ),
              ],
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.montserrat(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333333),
                    ),
                  ),
                  SizedBox(height: 25),

                
                  Row(
                    children: [
                      TextButton.icon(
                        onPressed: () {
                          setState(() {
                            Provider.of<CartProvider>(context, listen: false).removeItem(item);
                          });
                        },
                        icon: Icon(Icons.delete, color: Color(0xFFF54949)),
                        label: Text(
                          'Видалити',
                          style: TextStyle(
                              color: Color(0xFFF54949), fontSize: 16),
                        ),
                      ),
                      SizedBox(width: 8),
                      TextButton.icon(
                        onPressed: () {
                          makeSubscription(context, item);
                        },
                        icon: Icon(Icons.refresh, color: Color(0xFF8DD048)),
                        label: Text(
                          'Замовляти повторно',
                          style: TextStyle(
                              color: Color(0xFF8DD048), fontSize: 16),
                        ),
                      ),
                      Spacer(),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade400),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.remove),
                              onPressed: () {
                                setState(() {
                                  if (cartItem.count > 1) Provider.of<CartProvider>(context, listen: false).changeQuantity(item, false);
                                });
                              },
                              iconSize: 20,
                              constraints: BoxConstraints(),
                              padding: EdgeInsets.zero,
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text(
                                '${cartItem.count}',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.add),
                              onPressed: () {
                                setState(() {
                                  Provider.of<CartProvider>(context, listen: false).changeQuantity(item, true);
                                });
                              },
                              iconSize: 20,
                              constraints: BoxConstraints(),
                              padding: EdgeInsets.zero,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                ],
              ),
            ),
            SizedBox(width: 40),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${item.price * cartItem.count} ₴',
                  style: GoogleFonts.montserrat(
                      fontSize: 25,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF333333)),
                ),
             
              ],
            ),
          ],
        ),
        Divider(height: 32),
      ],
    ),
  );
}


}


Widget _buildSummaryBlock(BuildContext context, int totalCost) {
  final cartProvider = Provider.of<CartProvider>(context);
  int count = cartProvider.totalCount;

  return Container(
    width: 350,
    padding: EdgeInsets.all(24),
    decoration: BoxDecoration(
      border: Border.all(color: Colors.grey.shade300),
      borderRadius: BorderRadius.circular(5),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFFC16AFF),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
          ),
          onPressed: () {
           context.push('/checkout');

          },
          child: Center(
            child: Text(
              "Оформити замовлення",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),

        SizedBox(height: 20),
        

        Text(
          "$count ${pluralize(count, ['товар', 'товари', 'товарів'])}",
          style: TextStyle(fontSize: 14),
        ),

        Text("Доставка Новою Поштою: 50 ₴", style: TextStyle(fontSize: 14)),
        Divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Разом", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Text('${context.read<CartProvider>().totalPrice} ₴', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
          ],
        )
      ],
    ),
  );
}

String pluralize(int count, List<String> forms) {
  if (count % 10 == 1 && count % 100 != 11) return forms[0];    
  if (count % 10 >= 2 && count % 10 <= 4 && !(count % 100 >= 12 && count % 100 <= 14)) return forms[1]; 
  return forms[2];                                              
}



void makeSubscription(BuildContext context, ProductDTO product) {
  int selectedPeriod = 7;

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: Colors.white,
            title: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Оформлення підписки',
                  style: TextStyle(
                    color: Color(0xFF95C74E),
                    fontWeight: FontWeight.bold,
                    fontSize: 32,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 21),
                Text(
                  'З якою періодичністю вам\nпривозити цей товар?',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.black87,
                    fontWeight: FontWeight.w700
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),

            content: SizedBox(
              width: 420,
              height: 210,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  RadioListTile<int>(
                    activeColor: Color(0xFF95C74E),
                    title: Text('Раз на тиждень', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),),
                    value: 7,
                    groupValue: selectedPeriod,
                    onChanged: (val) => setState(() => selectedPeriod = val!),
                  ),
                  RadioListTile<int>(
                    activeColor: Color(0xFF95C74E),
                    title: Text('Раз на місяць', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),),
                    value: 30,
                    groupValue: selectedPeriod,
                    onChanged: (val) => setState(() => selectedPeriod = val!),
                  ),
                  RadioListTile<int>(
                    activeColor: Color(0xFF95C74E),
                    title: Text('Раз на 10 днів', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),),
                    value: 10,
                    groupValue: selectedPeriod,
                    onChanged: (val) => setState(() => selectedPeriod = val!),
                  ),
                  SizedBox(height: 20),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 35),
                    child: Text(
                    "Ми зв'яжемося з вами за день до закінчення терміну та обговоримо час доставки.",
                    textAlign: TextAlign.start,
                    style: TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                  )
                  
                ],
              ),
            ),
            actionsAlignment: MainAxisAlignment.center,
            actions: [
              OutlinedButton(
                onPressed: () => context.pop(),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Color(0xFFC16AFF),
                  side: BorderSide(color: Color(0xFFC16AFF)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5), 
                  ),
                ),
                child: Text('Скасувати', style: TextStyle(fontSize: 16)),
              ),
              ElevatedButton(
                onPressed: () async {
                  final authProvider =
                      Provider.of<AuthProvider>(context, listen: false);
                  final user = authProvider.user;

                  final subscription = SubscriptionDTO(
                    userId: user!.id!,
                    product: product,
                    deliveryFrequency: selectedPeriod,
                    startDate: DateFormat('yyyy-MM-dd').format(DateTime.now()),

                  );
                try {
                    final MonobankService monobankService = MonobankService();

                    final url = await monobankService.createInvoice(
                      amount: product.price * 100, 
                      currency: 980, 
                      description: 'Підписка на ${product.name}',
                      redirectUrl: 'https://zooshop-61f32.firebaseapp.com/',
                      webhookUrl: 'https://zooshop-dnu7.onrender.com/api/Webhook',
                      reference: '${user.id}-${product.id}',
                    );

                    final Uri _url = Uri.parse(url);
                    await launchUrl(_url);

                    await createSubscription(subscription);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Підписка створена')),
                    );
                     ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Підписка оформлена та знаходиться в розділі підписок!')),
                    );
                    context.pop();

                }
                catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Не вдалося оформити оплату: $e')),
                  );
                }
                
                 
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFC16AFF),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5), 
                  ),
                ),
                child: Text('Підтвердити', style: TextStyle(fontSize: 16),),
              ),
            SizedBox(height: 50)

            ],
          );
        },
      );
    },
  );
}
