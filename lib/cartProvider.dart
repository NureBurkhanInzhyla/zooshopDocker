import 'package:flutter/material.dart';
import 'product.dart';
import 'auth_service.dart';
import 'package:zooshop/models/Cart.dart';
import 'package:zooshop/models/Product.dart';
import 'package:provider/provider.dart';

class CartProvider extends ChangeNotifier {
  int? userId;
  List<Cart> _items = [];

  List<Cart> get items => _items;

  void setUser(int id) {
    userId = id;
    loadCart();
  }

  Future<void> loadCart() async {
    if (userId == null) return;
    _items = await fetchCartsByUserId(userId!);
    notifyListeners();
  }

  Future<void> addOrUpdateCartItem(ProductDTO product, BuildContext context) async {
    int index = _items.indexWhere((item) => item.product.id == product.id);

    if (index != -1) {
      final oldItem = _items[index];
      final updatedItem = Cart(
        id: oldItem.id,
        userId: oldItem.userId,
        product: oldItem.product,
        count: oldItem.count + 1,
      );

      await updateCartItem(updatedItem);

      _items[index] = updatedItem;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Кількість товару оновлена у кошику')),
      );
    } else {
      final newCartItem = Cart(
        userId: userId!,
        product: product,
        count: 1,
      );

      await addToCart(newCartItem);

      _items.add(newCartItem);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Товар додано до кошика')),
      );
    }

    notifyListeners();
  }

  Future<void> changeQuantity(ProductDTO product, bool increase) async {
    int index = _items.indexWhere((item) => item.product.id == product.id);
    if (index == -1) return;

    int newCount = increase ? _items[index].count + 1 : _items[index].count - 1;
    if (newCount < 1) return;

    _items[index] = Cart(
      id: _items[index].id,
      userId: userId!,
      product: product,
      count: newCount,
    );

    await updateCartItem(_items[index]);
    notifyListeners();
  }

  Future<void> removeItem(ProductDTO product) async {
    _items.removeWhere((item) => item.product.id == product.id);
    await deleteProductFromCart(userId!, product.id);
    notifyListeners();
  }

  Future<void> clear() async {
    _items.clear();
    await clearCart(userId!);
    notifyListeners();
  }

  int get totalPrice =>
      _items.fold(0, (sum, item) => sum + item.product.price * item.count);

  int get totalCount => _items.fold(0, (sum, item) => sum + item.count);

}
