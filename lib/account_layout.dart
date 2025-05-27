import 'package:flutter/material.dart';
import 'package:zooshop/account_page.dart';
import 'package:zooshop/adress_page.dart';
import 'package:zooshop/change_password_page.dart';
import 'package:zooshop/main.dart';
import 'package:zooshop/orders_page.dart';
import 'package:zooshop/subscription_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'header.dart';
import 'footer.dart';
import 'auth_service.dart';
import 'package:zooshop/models/Order.dart';


class AccountLayout extends StatefulWidget {
  final Widget child;
  final String activeMenu;

  const AccountLayout({required this.child, required this.activeMenu, super.key});

  @override
  State<AccountLayout> createState() => _AccountLayoutState();
}

class _AccountLayoutState extends State<AccountLayout> {
  int ordersAmount = 0;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
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
        });
      } catch (e) {
        print("Error fetching orders: $e");
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final maxWidthForOrders = screenWidth * (1 - 0.18);

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
                        widget.activeMenu,
                        style: GoogleFonts.montserrat(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF95C74E),
                        ),
                      ),
                    ),
                    SizedBox(height: 50),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _menuItem(context, 'Обліковий запис', page: AccountPage(), isActive: widget.activeMenu == 'Обліковий запис'),
                              _menuItem(context, 'Адреса доставки', page: AddressPage(), isActive: widget.activeMenu == 'Адреса доставки'),
                              _menuItem(context, 'Історія замовлень', page: OrdersPage(), isActive: widget.activeMenu == 'Історія замовлень', ordersAmount: ordersAmount),
                              _menuItem(context, 'Підписки', page: SubscriptionPage(), isActive: widget.activeMenu == 'Підписки'),
                              _menuItem(context, 'Змінити пароль', page: ChangePasswordPage(), isActive: widget.activeMenu == 'Змінити пароль'),
                              _menuItem(context, 'Вийти', page: MainPage(), isActive: widget.activeMenu == 'Вийти'),
                            ],
                          ),
                        ),
                        SizedBox(width: 35),
                        Container(width: 1, height: 408, color: Color(0xFFC8CBD0)),
                        SizedBox(width: 55),
                        if (widget.activeMenu == 'Історія замовлень' || widget.activeMenu == 'Підписки')
                          Expanded(
                            child: ConstrainedBox(
                              constraints: BoxConstraints(maxWidth: maxWidthForOrders),
                              child: widget.child,
                            ),
                          )
                        else
                          SizedBox(width: screenWidth * 0.24, child: widget.child), // ✅
                      ],
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
  }


  Widget _menuItem( BuildContext context, String title, { Widget? page, bool isActive = false, int ordersAmount = 0,}) {
    bool isOrders = title == 'Історія замовлень';

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          if(title == 'Вийти'){
               Provider.of<AuthProvider>(context, listen: false).logout();
          }
          if (page != null && !isActive) {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (_) => page));
          }
        },
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isActive ? FontWeight.w800 : FontWeight.normal,
                  color: title == 'Вийти' 
                    ? Color(0xFFC16AFF)  
                    : (isActive ? Colors.black : const Color.fromARGB(255, 0, 0, 0)),
                ),
              ),
              if (isOrders && ordersAmount > 0) ...[
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
            ],
          ),
        ),
      ),
    );
  }

}

