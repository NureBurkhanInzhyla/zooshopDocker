import 'package:flutter/material.dart';
import 'package:zooshop/account_layout.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:zooshop/models/Subscription.dart';
import 'auth_service.dart';
import 'package:intl/intl.dart';
import 'footer.dart';

class SubscriptionPage extends StatefulWidget {
  @override
  _SubscriptionPageState createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  List<SubscriptionDTO> subscriptions = [];
  bool isLoading = true;


  @override
  void initState() {
    super.initState();
    loadSubscriptions();
  }

  Future<void> loadSubscriptions() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final user = authProvider.user;
      final fetched = await fetchSubscriptionsByUserId(user!.id!);
      setState(() {
        subscriptions = fetched;
        isLoading = false;
      });
    } catch (e) {
      print('Ошибка загрузки: $e');
      setState(() => isLoading = false);
    }
  }

  Future<void> updateFrequency(SubscriptionDTO subscription, int newPeriod) async {
    try {
      await updateSubscriptionFrequency(subscription.id!, newPeriod);
      await loadSubscriptions();
    } catch (e) {
      print('Ошибка обновления частоты: $e');
    }
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
          'Підписки',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF95C74E),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: subscriptions.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 50),
                    child: Text(
                      'Підписок немає',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isLoading)
                      Center(child: CircularProgressIndicator())
                    else
                      ...subscriptions
                          .asMap()
                          .entries
                          .map((entry) => _buildSubscriptionCard(entry.value, entry.key))
                          .toList(),
                  ],
                ),
        ),
      ),
      bottomNavigationBar:FooterBlock(),
    );
  }

  
Widget _buildSubscriptionCard(SubscriptionDTO subscription, int index) {
  final now = DateTime.now();
  final startDate = DateTime.parse(subscription.startDate);
  final weeksPassed = now.difference(startDate).inDays ~/ 7;
  final nextDelivery = startDate.add(Duration(days: (weeksPassed + 1) * 7));

  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 60,
              height: 60,
              child: Image.asset(subscription.product.image, fit: BoxFit.cover),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subscription.product.name,
                    style: GoogleFonts.montserrat(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF333333),
                    ),
                    
                  ),
                  SizedBox(height: 4),
                  Text(
                    subscription.product.desc ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      color: const Color.fromARGB(255, 63, 63, 63),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        SizedBox(height: 24),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () => showSubscriptionDetails(context, subscription),
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'раз ',
                      style: GoogleFonts.montserrat(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF333333),
                      ),
                    ),
                    TextSpan(
                      text: 'на тиждень',
                      style: GoogleFonts.montserrat(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFC16AFF),
                        decoration: TextDecoration.underline,
                         decorationColor: Color(0xFFC16AFF),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${subscription.product.price.toStringAsFixed(0)} ₴',
                  style: GoogleFonts.montserrat(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
                if (subscription.product.discountPercent != null)
                  Text(
                    '${(subscription.product.price / (1 - subscription.product.discountPercent! / 100)).round()} ₴',
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      color: Colors.grey,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
              ],
            ),
          ],
        ),

        SizedBox(height: 8),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
             Text(
              'Наступна доставка: ${DateFormat('dd.MM.yyyy').format(nextDelivery)}',
              style: GoogleFonts.montserrat(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF95C74E),
              ),
            ),
            
          ],
        ),
        SizedBox(height: 10),

        GestureDetector(
              onTap: () => _confirmDelete(subscription),
              child: Row(
                children: [
                  Icon(Icons.close, color: Color(0xFFF54949), size: 20),
                  SizedBox(width: 4),
                  Text(
                    'Скасувати підписку',
                    style: TextStyle(
                      color: Color(0xFFF54949),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

        SizedBox(height: 15),
        Divider(height: 1, color: Colors.grey[300]),
      ],
    ),
  );
}


void showSubscriptionDetails(BuildContext context, SubscriptionDTO subscription) {
  int selectedPeriod = subscription.deliveryFrequency;

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
                SizedBox(height: 21),
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
                    title: Text('Раз на тиждень', textAlign: TextAlign.center, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),),
                    value: 7,
                    groupValue: selectedPeriod,
                    onChanged: (val) => setState(() => selectedPeriod = val!),
                  ),
                  RadioListTile<int>(
                    activeColor: Color(0xFF95C74E),
                    title: Text('Раз на місяць', textAlign: TextAlign.center, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),),
                    value: 30,
                    groupValue: selectedPeriod,
                    onChanged: (val) => setState(() => selectedPeriod = val!),
                  ),
                  RadioListTile<int>(
                    activeColor: Color(0xFF95C74E),
                    title: Text(
                      'Раз в 10 днів',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                    ),
                    value: 10, 
                    groupValue: selectedPeriod,
                    onChanged: (val) => setState(() => selectedPeriod = val!),
                  ),
                  SizedBox(height: 10,),
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
                  try {
                    await updateSubscriptionFrequency(subscription.id!, selectedPeriod);
                    await loadSubscriptions();
                    ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Підписку оновлено')),
                  );;
                  }catch (e) {
                    print('Помилка оновлення: $e');
                  }
                  
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


void _confirmDelete(SubscriptionDTO subscription) {

   showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => Dialog(
      backgroundColor: Color(0xFFFFFFFF),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: SizedBox(
        width: 460,
        height: 370,
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 21),
                  child: Image.asset('assets/images/crying-cat-face.png'),
                ),
                Text(
                  'Ви впевнені, що бажаєте\nскасувати підписку?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 31, left: 25, top: 17),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 145,
                        height: 40,
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Color(0xFF67AF45),
                            side: BorderSide(color: Color(0xFF67AF45)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 0),
                          ),
                          child: Text(
                            'Не скасовувати',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      SizedBox(width: 15),
                      SizedBox(
                        width: 120,
                        height: 40,
                        child: ElevatedButton(
                          onPressed: () async {
                            try {
                              await deleteSubscriptionById(subscription.id!);
                              await loadSubscriptions();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Підписку скасовано')),
                              );
                            } catch (e) {
                              print('Помилка видалення: $e');
                            }
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFF74E4E),
                            foregroundColor: Color(0xFFFFFFFF),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 0),
                          ),
                          child: Text(
                            'Скасувати',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                icon: Icon(Icons.close, size: 28),
                onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}

// class Product {
//   final int id;
//   final String name;
//   final double price;
//   final Image image;

//   Product({
//     required this.id,
//     required this.name,
//     required this.price,
//     required this.image
//   });
// }

// class Subscription {
//   final Product product;
//   final int periodInDays;
//   final DateTime startDate;
//   bool cancelled;

//   Subscription({
//     required this.product,
//     this.periodInDays = 30,
//     DateTime? startDate,
//     this.cancelled = false
//   }) : startDate = startDate ?? DateTime.now();

//   DateTime get nextDeliveryDate => startDate.add(Duration(days: periodInDays));
// }

// class SubscriptionProvider extends ChangeNotifier {
//   final List<Subscription> _subscriptions = [];

//   List<Subscription> get subscriptions => List.unmodifiable(_subscriptions);

//   void addSubscription(Subscription sub) {
//     _subscriptions.add(sub);
//     notifyListeners();
//   }

//   void removeSubscription(Subscription sub) {
//     _subscriptions.remove(sub);
//     notifyListeners();
//   }

//   void loadFromDatabase(List<Subscription> loaded) {
//     _subscriptions.clear();
//     _subscriptions.addAll(loaded);
//     notifyListeners();
//   }
// }

