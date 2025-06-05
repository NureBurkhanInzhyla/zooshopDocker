import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'auth_service.dart'; 
import 'account_page.dart';
import 'adress_page.dart';
import 'change_password_page.dart';
import 'main.dart';
import 'orders_page.dart';
import 'subscription_page.dart';
import 'package:zooshop/models/Order.dart';  
import 'header.dart';
import 'footer.dart';
import 'package:flutter_tawkto/flutter_tawk.dart';

class SimpleAccountMenuPage extends StatefulWidget {
  const SimpleAccountMenuPage({super.key});

  @override
  _SimpleAccountMenuPageState createState() => _SimpleAccountMenuPageState();
}

class _SimpleAccountMenuPageState extends State<SimpleAccountMenuPage> {
  int ordersAmount = 0;
  bool isLoading = true;
  

  @override
  void initState() {
    super.initState();
    _loadOrdersCount();
  }

  Future<void> _loadOrdersCount() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;

    if (user != null) {
      try {
        List<OrderDTO> orders = await fetchOrdersByUserId(user.id!);
        final Map<int, List<OrderDTO>> groupedOrders = {};
        for (var order in orders) {
          groupedOrders.putIfAbsent(order.orderId, () => []).add(order);
        }

        int activeOrdersCount = groupedOrders.entries.where((entry) {
          return entry.value.any((order) => order.state != 'Скасовано');
        }).length;

        setState(() {
          ordersAmount = activeOrdersCount;
          isLoading = false;
        });
      } catch (e) {
        print("Error fetching orders: $e");
        setState(() {
          isLoading = false;
        });
      }
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

@override
Widget build(BuildContext context) {
  final authProvider = Provider.of<AuthProvider>(context);
  final user = authProvider.user;
  String userName = user!.name;

  void navigateTo(Widget page) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
  }

  return Scaffold(
    backgroundColor: Colors.white,
    appBar: PreferredSize(
      preferredSize: Size.fromHeight(125),
      child: Padding(
        padding: EdgeInsets.only(top: 15),
        child: HeaderBlock(),
      ),
    ),
    body: SafeArea( 
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 20, left: 5),
            child: Text(
              'Привіт, $userName!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: Color(0xFF95C74E),
              ),
            ),
          ),
          _menuItem(context, 'Обліковий запис', () => navigateTo(AccountPage())),
          _menuItem(context, 'Адреса доставки', () => navigateTo(AddressPage())),
          _menuItem(
            context,
            'Історія замовлень',
            () => navigateTo(OrdersPage()),
            ordersAmount: ordersAmount,
            isLoading: isLoading,
          ),
          _menuItem(context, 'Підписки', () => navigateTo(SubscriptionPage())),
          _menuItem(context, 'Змінити пароль', () => navigateTo(ChangePasswordPage())),
          _menuItem(
            context,
            'Вийти',
            () {
              authProvider.logout();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => MainPage()),
              );
            },
            isLogout: true,
          ),
        ],
      ),
    ),
    bottomNavigationBar:  FooterBlock()
  );
}



  Widget _menuItem(BuildContext context, String title, VoidCallback onTap,
      {int ordersAmount = 0, bool isLogout = false, bool isLoading = false}) {
    return Card(
      color: isLogout ? const Color.fromARGB(255, 255, 231, 233) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isLogout ? Colors.red : Color.fromARGB(54, 149, 199, 78), 
          width: 1,
        ),
      ),
      child: ListTile(
        title: Row(
          children: [
            Text(
              title,
              style: TextStyle(
                color: isLogout ? Colors.red : Colors.black87,
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),
            if (title == 'Історія замовлень' && !isLoading && ordersAmount > 0) ...[
              SizedBox(width: 8),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Color(0xFFC16AFF),
                  borderRadius: BorderRadius.circular(23),
                ),
                child: Text(
                  '$ordersAmount',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
            if (title == 'Історія замовлень' && isLoading) ...[
              SizedBox(width: 8),
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ],
          ],
        ),
        trailing: Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
