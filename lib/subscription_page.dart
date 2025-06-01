import 'package:flutter/material.dart';
import 'package:zooshop/account_layout.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter/gestures.dart';
import 'package:zooshop/models/Subscription.dart';
import 'auth_service.dart';
import 'package:intl/intl.dart';


class SubscriptionPage extends StatefulWidget {
  @override
  _SubscriptionPageState createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  List<SubscriptionDTO> subscriptions = [];
  bool isLoading = true;
  int _currentPage = 0;
  final int _itemsPerPage = 5;

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
        _currentPage = 0;
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
    final totalPages = (subscriptions.length / _itemsPerPage).ceil();

    final pagedSubscriptions = subscriptions.skip(_currentPage * _itemsPerPage).take(_itemsPerPage).toList();
    
    return AccountLayout(
      activeMenu: 'Підписки',
      child: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isLoading)
              Center(child: CircularProgressIndicator())
            else if (subscriptions.isEmpty)
              Center(child: Text('Підписок немає'))
            else
              ...pagedSubscriptions
                .asMap()
                .entries
                .map((entry) => _buildSubscriptionCard(entry.value, entry.key))
                .toList(),
            SizedBox(height: 50),
            if (totalPages >= 1) _buildPagination(totalPages),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPagination(int totalPages) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
    IconButton(
        icon: Icon(Icons.chevron_left),
        onPressed: _currentPage > 0
            ? () {
                setState(() {
                  _currentPage--;
                });
              }
            : null, 
      ),
    ...List.generate(totalPages, (index) {
      final isActive = index == _currentPage;
      return GestureDetector(
        onTap: () {
          setState(() {
            _currentPage = index;
          });
        },
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 6),
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isActive ? Color(0xFFC16AFF) : const Color.fromARGB(255, 255, 255, 255),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Text(
            '${index + 1}',
            style: TextStyle(
              color: isActive ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }),
    
    IconButton(
        icon: Icon(Icons.chevron_right),
        onPressed: _currentPage < totalPages - 1
            ? () {
                setState(() {
                  _currentPage++;
                });
              }
            : null, 
      ),
    ]
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
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 126,
              height: 126,
              child: Image.asset(subscription.product.image),
            ),

            SizedBox(width: 16),

            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subscription.product.name,
                    style: GoogleFonts.montserrat(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF333333),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    subscription.product.desc ?? '',
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      color: Colors.brown[300],
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Наступна доставка: ${DateFormat('dd.MM.yyyy').format(nextDelivery)}',
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      color: Color(0xFFC16AFF),
                    ),
                  ),
                  SizedBox(height: 30),
                  MouseRegion(
                    cursor: SystemMouseCursors.click, 
                    child: GestureDetector(
                    onTap: () => _confirmDelete(subscription),
                    
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Color(0xFFF54949), size: 20),
                        SizedBox(width: 4),
                        Text(
                          'Скасувати',
                          style: TextStyle(
                            color: Color(0xFFF54949),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ),
                ],
              ),
            ),

            SizedBox(width: 16),

            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${subscription.product.price.toStringAsFixed(0)} ₴',
                  style: GoogleFonts.montserrat(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
                SizedBox(height: 4),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: 'раз ',
                        style: GoogleFonts.montserrat(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF333333),
                        ),
                      ),
                      TextSpan(
                        text: 'на тиждень',
                        style: GoogleFonts.montserrat(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          decoration: TextDecoration.underline,
                          decorationColor: Color(0xFFC16AFF),
                          color: Color(0xFFC16AFF),
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            showSubscriptionDetails(context, subscription);
                          },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: 30),
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
                    title: Text(
                      'Раз в 10 днів',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
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
                onPressed: () => Navigator.pop(context),
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
                  'Ви впевнені, що бажаєте\nскасувати замовлення?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 31, left: 66, top: 17),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 168,
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
                        width: 145,
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

