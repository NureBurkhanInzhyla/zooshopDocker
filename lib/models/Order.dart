import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:developer';
import 'Product.dart';

class OrderDTO {
  int? id;
  final int orderId;
  final int userId;
  final ProductDTO product;
  final String date;
  final String state;
  final int count;

  Map<String, dynamic> toJson() {
    return {
      'userId': userId
    };
  }

  OrderDTO({this.id, required this.orderId, required this.userId, required this.product,
  required this.date, required this.state, required this.count});
}

Future<List<OrderDTO>> fetchOrdersByOrderId(int userId) async {
  final response = await http.get(Uri.parse('https://localhost:7097/api/Order/$userId'));

  if (response.statusCode == 200) {
    // Если запрос успешный, парсим JSON
    List<dynamic> orderData = json.decode(response.body);

    // Для каждого товара из корзины получаем подробности о продукте
    List<OrderDTO> orders = [];
    for (var orderItem in orderData) {
      // Для каждого Cart получаем Product по ProductId
      var product = await fetchProductById(orderItem['productId']);
      orders.add(OrderDTO(
        id: orderItem['id'],
        orderId: orderItem['orderId'],
        userId: orderItem['userId'],
        product: product,
        date: orderItem['date'],
        state: orderItem['state'],
        count: orderItem['count']
      ));
    }

    return orders;
  } else {
    throw Exception('Не удалось загрузить товары из заказа');
  }
}

Future<List<OrderDTO>> fetchOrdersByUserId(int userId) async {
  final response = await http.get(Uri.parse('https://localhost:7097/api/Order/user$userId'));

  if (response.statusCode == 200) {
    // Если запрос успешный, парсим JSON
    List<dynamic> orderData = json.decode(response.body);

    // Для каждого товара из корзины получаем подробности о продукте
    List<OrderDTO> orders = [];
    for (var orderItem in orderData) {
      // Для каждого Cart получаем Product по ProductId
      var product = await fetchProductById(orderItem['productId']);
      orders.add(OrderDTO(
        id: orderItem['id'],
        orderId: orderItem['orderId'],
        userId: orderItem['userId'],
        product: product,
        date: orderItem['date'],
        state: orderItem['state'],
        count: orderItem['count']
      ));
    }

    return orders;
  } else {
    throw Exception('Не удалось загрузить товары из заказа');
  }
}

Future<void> createOrder(int userid) async {
  final url = Uri.parse('https://localhost:7097/api/Order'); // Укажите правильный URL для вашего API

  final response = await http.post(
    url,
    headers: {
      'Content-Type': 'application/json', // Указываем тип данных, которые отправляем
    },
    body: json.encode({'userId': userid}), // Преобразуем объект Cart в JSON
  );

  if (response.statusCode == 200) {
    print('Очередь была успешно создана из корзины');
    print(response.body);
  } else {
    print('Не удалось создать очередь. Статус: ${response.statusCode}');
  }
}

Future<void> updateOrderState(int orderId, String state) async {
  final url = Uri.parse('https://localhost:7097/api/Order'); // Укажите правильный URL для вашего API

  final response = await http.put(
    url,
    headers: {
      'Content-Type': 'application/json', // Указываем тип данных, которые отправляем
    },
    body: json.encode({
      'orderId': orderId,
      'state': state
    }),
  );

  if (response.statusCode == 200) {
    print('Заказ успешно обновлен');
    print(response.body);
  } else {
    print('Ошибка при обновлении заказа: ${response.statusCode}');
  }
}