import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:developer';
import 'Product.dart';

class Cart {
  int? id;
  final int userId;
  final ProductDTO product;
  final int count;

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'productId': product.id,
      'count': count,
    };
  }

  Cart({this.id, required this.userId, required this.product, required this.count});
}

Future<List<Cart>> fetchCartsByUserId(int userId) async {
  final response = await http.get(Uri.parse('https://localhost:7097/api/Cart/$userId'));

  if (response.statusCode == 200) {
    List<dynamic> cartData = json.decode(response.body);

    List<Cart> carts = [];
    for (var cartItem in cartData) {
      var product = await fetchProductById(cartItem['productId']);
      carts.add(Cart(
        id: cartItem['id'],
        userId: cartItem['userId'],
        product: product,
        count: cartItem['count']
      ));
    }

    return carts;
  } else {
    throw Exception('Не удалось загрузить товары из корзины');
  }
}

Future<void> addToCart(Cart cart) async {
  final url = Uri.parse('https://localhost:7097/api/Cart'); 

  final response = await http.post(
    url,
    headers: {
      'Content-Type': 'application/json', 
    },
    body: json.encode(cart.toJson()),
  );

  if (response.statusCode == 200) {
    print('Товар успешно добавлен в корзину');
    print(response.body);
  } else {
    print('Не удалось добавить товар в корзину. Статус: ${response.statusCode}');
  }
}

Future<void> deleteProductFromCart(int userId, int productId) async {
  final url = Uri.parse('https://localhost:7097/api/Cart/DeleteProduct/$userId/$productId');

  final response = await http.delete(url);

  if (response.statusCode == 200) {
    print('Товар успешно удален из корзины');
  } else {
    print('Ошибка при удалении товара: ${response.statusCode}');
  }
}

Future<void> clearCart(int userId) async {
  final url = Uri.parse('https://localhost:7097/api/Cart/ClearCart/$userId');

  final response = await http.delete(url);

  if (response.statusCode == 200) {
    print('Корзина успешно очищена');
  } else {
    print('Ошибка при очистке корзины: ${response.statusCode}');
  }
}

Future<void> updateCartItem(Cart cart) async {
  final url = Uri.parse('https://localhost:7097/api/Cart');

  final response = await http.put(
    url,
    headers: {
      'Content-Type': 'application/json',
    },
    body: json.encode(cart.toJson()),
  );

  if (response.statusCode == 200) {
    print('Корзина успешно обновлена');
  } else {
    print('Ошибка при обновлении корзины: ${response.statusCode}');
  }
}
