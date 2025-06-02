import 'package:flutter/material.dart';
import 'package:zooshop/account_layout.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'auth_service.dart';
import 'package:zooshop/models/Order.dart';
import 'package:zooshop/cartProvider.dart';
import 'cart_page.dart';
import 'footer.dart';


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

      final orders = snapshot.data ?? [];

      if (orders.isEmpty) {
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
              'Історія замовлень',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF95C74E),
              ),
            ),
          ),
          body: Center(
            child: Text(
              'Замовлень немає',
              style: TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ),
        );
      }

      final Map<int, List<OrderDTO>> groupedOrders = {};
      for (var order in orders) {
        groupedOrders.putIfAbsent(order.orderId, () => []).add(order);
      }
      final sortedOrderIds = groupedOrders.keys.toList()
        ..sort((a, b) => b.compareTo(a));

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
            'Історія замовлень',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF95C74E),
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.only(top: 30, right: 20, bottom: 20, left: 20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
               children: sortedOrderIds.map((orderId) {
                final orderItems = groupedOrders[orderId]!;
                return _buildOrderCard(orderId, orderItems);
              }).toList(),
            ),
          ),
        ),
        bottomNavigationBar: Padding(
          padding: EdgeInsets.only(bottom: 10),
          child: FooterBlock(),
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
                            await updateOrderState(orderId, 'Скасовано');
                            Navigator.pop(context);
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
  final isCancellable = firstOrder.state == 'В обробці' || firstOrder.state == 'Не оплачен';
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
        RichText(
          text: TextSpan(
            style: GoogleFonts.montserrat(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
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

        SizedBox(height: 13),

        Row(
          children: [
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

        SizedBox(height: 10),

        Text(
          firstOrder.state,
          style: TextStyle(
            color: statusColor,
            fontWeight: firstOrder.state == 'В обробці' ? FontWeight.w800 : FontWeight.w500,
            fontSize: 16,
          ),
        ),

        SizedBox(height: 4),

     if (isCancellable)
      Transform.translate(
        offset: Offset(-15, 0), 
        child: TextButton.icon(
          onPressed: () => _confirmDelete(orderId),
          icon: Icon(Icons.close, color: Color(0xFFF54949)),
          label: Text(
            'Скасувати замовлення',
            style: TextStyle(color: Color(0xFFF54949), fontSize: 16),
          ),
        ),
      ),
    if (canReorder)
      Transform.translate(
        offset: Offset(-15, 0),
        child: TextButton.icon(
          onPressed: () => _confirmReorder(firstOrder),
          icon: Icon(Icons.refresh, color: Color(0xFFFF8A00)),
          label: Text(
            'Замовити ще раз',
            style: TextStyle(color: Color(0xFFFF8A00), fontSize: 16),
          ),
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
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 130,
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
                  SizedBox(width: 20),
                  SizedBox(
                    width: 130,
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

                        Navigator.push(context, MaterialPageRoute(builder: (_) => CartPage()));
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

// class OrdersProvider with ChangeNotifier {
//   List<Order> _orders = [];

//   List<Order> get orders => _orders;

//   int get processingCount =>
//       _orders.where((o) => o.state == 'В обробці').length;

//   void setOrders(List<Order> orders) {
//     _orders = orders;
//     notifyListeners();
//   }

//   void cancelOrder(int index) {
//     _orders[index].state = 'Скасовано';
//     notifyListeners();
//   }
// }
