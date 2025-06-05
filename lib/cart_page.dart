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

class CartPage extends StatefulWidget {
  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;

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
          body: SafeArea(
            child: Column(
              children: [
                HeaderBlock(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 12, 16, 0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Кошик",
                      style: TextStyle(
                        color: Color(0xFF95C74E),
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: cartItems.isEmpty
                      ? Center(child: Text('Кошик порожній'))
                      : ListView.builder(
                          padding: EdgeInsets.all(16),
                          itemCount: cartItems.length,
                          itemBuilder: (context, index) =>
                              _buildCartItem(cartItems[index]),
                        ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: _buildSummaryMobile(context, cartProvider),
                ),
              ],
            ),
          ),
          bottomNavigationBar:FooterBlock(), 
        );
      },
    );
  }

Widget _buildCartItem(Cart cartItem) {
  final item = cartItem.product;

  return Card(
    color: Colors.white,
    margin: EdgeInsets.only(bottom: 16),
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(5), 
      side: BorderSide(
        color: Colors.grey.withAlpha((0.3 * 255).round()),
        width: 1,
      ),
    ),
    child: Padding(
      padding: EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            height: 80,
            child: Image.asset(item.image, fit: BoxFit.contain),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.montserrat(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF333333),
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      '${item.price * cartItem.count} ₴',
                      style: GoogleFonts.montserrat(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.remove),
                    onPressed: () {
                      if (cartItem.count > 1) {
                        Provider.of<CartProvider>(context, listen: false)
                            .changeQuantity(item, false);
                      }
                    },
                  ),
                  Text('${cartItem.count}'),
                  IconButton(
                    icon: Icon(Icons.add),
                    onPressed: () {
                      Provider.of<CartProvider>(context, listen: false)
                          .changeQuantity(item, true);
                    },
                  ),
                  Spacer(),
                  IconButton(
                    icon: Icon(Icons.refresh, color: Color(0xFF8DD048)),
                    tooltip: 'Замовляти повторно',
                    onPressed: () {
                      makeSubscription(context, item);
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: const Color.fromARGB(255, 194, 67, 58)),
                    onPressed: () {
                      Provider.of<CartProvider>(context, listen: false)
                          .removeItem(item);
                    },
                  ),
                ],
              ),

              ],
            ),
          ),
        ],
      ),
    ),
  );
}



  Widget _buildSummaryMobile(BuildContext context, CartProvider cartProvider) {
    final price = cartProvider.totalPrice;

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color.fromARGB(172, 210, 243, 163),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(
          color: Color.fromARGB(160, 149, 199, 78), 
          width: 1
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "До сплати:",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              Text(
                "$price ₴",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
              ),
            ],
          ),
          SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 40,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFC16AFF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => CheckoutPage()),
                );
              },
              child: Text(
                "Оформити замовлення",
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
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
            contentPadding: EdgeInsets.fromLTRB(25, 0, 25, 8),
            backgroundColor: Colors.white,
            title: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Оформлення підписки',
                  style: TextStyle(
                    color: Color(0xFF95C74E),
                    fontWeight: FontWeight.bold,
                    fontSize: 23,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10,),
                Text(
                  'З якою періодичністю вам\nпривозити цей товар?',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                    fontWeight: FontWeight.w700
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),

            content: SizedBox(
              width: 420,
              height: 230,
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
                    title: Text('Раз в ${selectedPeriod == -1 ? 7 : selectedPeriod} днів', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),),
                    value: -1,
                    groupValue: selectedPeriod,
                    onChanged: (val) => setState(() => selectedPeriod = val!),
                  ),
                  SizedBox(height: 10),
                   Text(
                    "Ми зв'яжемося з вами за день до закінчення терміну та обговоримо час доставки.",
                    textAlign: TextAlign.justify,
                    style: TextStyle(fontSize: 12, color: Colors.black87),
                  ),
                ],
              ),
            ),
            actionsAlignment: MainAxisAlignment.center,
            actions: [
              OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Color(0xFFC16AFF),
                  side: BorderSide(color: Color(0xFFC16AFF)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5), 
                  ),
                ),
                child: Text('Скасувати', style: TextStyle(fontSize: 14)),
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

                  await createSubscription(subscription);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Підписка створена')),
                  );
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFC16AFF),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5), 
                  ),
                ),
                child: Text('Підтвердити', style: TextStyle(fontSize: 14),),
              ),

            ],
          );
        },
      );
    },
  );
}
