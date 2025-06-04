import 'package:flutter/material.dart';
import 'package:zooshop/account_layout.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'auth_service.dart';
import 'package:zooshop/models/Order.dart';
import 'package:zooshop/cartProvider.dart';
import 'cart_page.dart';
import 'package:go_router/go_router.dart';

class OrdersPage extends StatefulWidget {
  @override
  _OrdersPageState createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  int _currentPage = 0;
  final int _ordersPerPage = 5;
  List<OrderDTO> orders = [];

  Map<int, List<OrderDTO>> _groupOrdersByOrderId(List<OrderDTO> orders) {
    orders.sort((a, b) => b.orderId.compareTo(a.orderId));

    Map<int, List<OrderDTO>> grouped = {};
    for (var order in orders) {
      grouped.putIfAbsent(order.orderId, () => []);
      grouped[order.orderId]!.add(order);
    }
    return grouped;
  }


  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;

    if (user == null || user.id == null) {
      return Scaffold(
        body: Center(child: Text('Користувач не авторизований')),
      );
    }

    return FutureBuilder<List<OrderDTO>>(
      future: fetchOrdersByUserId(user.id!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (snapshot.hasError) {
          return Scaffold(body: Center(child: Text('Помилка: ${snapshot.error}')));
        }

        orders = snapshot.data ?? [];

        if (orders.isEmpty) {
          return AccountLayout(
            activeMenu: 'Історія замовлень',
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Замовлень немає',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }

        final groupedOrders = _groupOrdersByOrderId(orders);

        final allOrderIds = groupedOrders.keys.toList();

        final totalPages = (allOrderIds.length / _ordersPerPage).ceil();
        final startIndex = _currentPage * _ordersPerPage;
        final endIndex = (_currentPage + 1) * _ordersPerPage;

        final currentOrderIds = allOrderIds.sublist(
          startIndex,
          endIndex > allOrderIds.length ? allOrderIds.length : endIndex,
        );

        return AccountLayout(
          activeMenu: 'Історія замовлень',
          child: Container(
            padding: EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  ...currentOrderIds.map((orderId) {
                    final orderItems = groupedOrders[orderId]!;
                    return _buildOrderCard(orderId, orderItems);
                  }).toList(),
                  SizedBox(height: 16),
                  _buildPagination(totalPages),  
                ],
              ),
            ),
          ),
        );

      },
    );
  }


  void _confirmDelete(int orderId) {

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
                          onPressed: () => context.pop(),
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
                            await updateOrderState(orderId, 'Скасовано');
                            context.pop();
                            await _refreshOrders();
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

  Future<void> _refreshOrders() async {
  final authProvider = Provider.of<AuthProvider>(context, listen: false);
  final user = authProvider.user;
  if (user != null && user.id != null) {
    final updatedOrders = await fetchOrdersByUserId(user.id!);
    setState(() {
      orders = updatedOrders;
    });
  }
}


  Widget _buildOrderCard(int orderId, List<OrderDTO> orderItems) {
      final firstOrder = orderItems[0]; 

      Color statusColor;
      final isCancellable = firstOrder.state == 'В обробці' || firstOrder.state == 'Не оплачен' || firstOrder.state == "Оплачено";
      final canReorder = firstOrder.state == 'Скасовано' || firstOrder.state == 'Доставлено';

      switch (firstOrder.state) {
        case 'В обробці':
        case 'Доставлено':
          statusColor = Color(0xFF67AF45);
          break;
        case 'Скасовано':
          statusColor = Color(0xFFF54949);
          break;
        default:
          statusColor = Colors.grey;
      }

      final totalCount = orderItems.fold(0, (sum, order) => sum + order.count);
      final totalCost = orderItems.fold(0, (sum, order) => sum + order.product.price * order.count);

      return Padding(
        padding: const EdgeInsets.only(bottom: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                RichText(
                  text: TextSpan(
                    style: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF333333)),
                    children: [
                      TextSpan(text: 'Замовлення від  ' + firstOrder.date + ' '),
                      TextSpan(
                        text: '№$orderId',
                        style: TextStyle(
                          fontWeight: FontWeight.normal,
                          color: Color(0xFF848992),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                Spacer(),
                Text(
                  firstOrder.state,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: firstOrder.state == 'В обробці' ? FontWeight.w800 : FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
                SizedBox(width: 24),
                Text(
                  '$totalCount товари',
                  style: TextStyle(fontSize: 14),
                ),
                SizedBox(width: 24),
                Text(
                  '$totalCost ₴',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20),
                ),
              ],
            ),
            SizedBox(height: 13),
            if (isCancellable)
              TextButton.icon(
                onPressed: () => _confirmDelete(orderId),
                icon: Icon(Icons.close, color: Color(0xFFF54949)),
                label: Text(
                  'Скасувати замовлення',
                  style: TextStyle(color: Color(0xFFF54949), fontSize: 16),
                ),
              ),
            if (canReorder)
              TextButton.icon(
                onPressed: () => _confirmReorder(firstOrder),
                icon: Icon(Icons.refresh, color: Color(0xFFFF8A00)),
                label: Text(
                  'Замовити ще раз',
                  style: TextStyle(color: Color(0xFFFF8A00), fontSize: 16),
                ),
              ),
            Divider(height: 32),
          ],
        ),
      );
    }


  int countItemsInOrder(int orderId) {
    return orders
        .where((order) => order.orderId == orderId)
        .fold(0, (sum, order) => sum + order.count);
  }


  int totalCost(int orderId) {
    int total = 0;

    for (var order in orders) {
      if (order.orderId == orderId) {
        total += order.product.price * order.count;
      }
    }

    return total;
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


  void _confirmReorder(OrderDTO order) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Color(0xFFFFFFFF),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: SizedBox(
          width: 460,
          height: 179,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 30),
              Text(
                'Додати товари від "Замовлення від ${order.date}" до кошика?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF333333), 
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 29),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 143,
                    height: 40,
                    child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Color(0xFF67AF45)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6)),
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    child: Text(
                      'Скасувати',
                      style: TextStyle(color: Color(0xFF67AF45), fontSize: 16),
                    ),
                  )
                  
                  ),
                  SizedBox(width: 16),
                  SizedBox(
                    width: 143,
                    height: 40,
                      child: ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(context);

                        final cartProvider = Provider.of<CartProvider>(context, listen: false);
                        final orderItems = orders.where((o) => o.orderId == order.orderId);

                        for (var orderItem in orderItems) {
                          for (int i = 0; i < orderItem.count; i++) {
                            await cartProvider.addOrUpdateCartItem(orderItem.product, context);
                          }
                        }

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Товари додано до кошика')),
                        );

                        context.push('/cart');
                      },

                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF8DC63F), 
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6)),
                        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      child: Text(
                        'Додати',
                        style: TextStyle(fontSize: 16, color: Color(0xFFFFFFFF), fontWeight: FontWeight.w600 ),
                      ),
                    ),
                  ),
                  
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

}

class Order {
  String name;
  String state;
  int quantity;
  int number;
  double sum;

  Order({
    String? name,
    this.state = "В обробці",
    this.quantity = 3,
    this.number = 10662,
    this.sum = 3651,
  }) : name = name ?? "Замовлення від ${DateTime.now().toIso8601String().split('T')[0]}";
}