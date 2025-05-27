import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'Product.dart';

class SubscriptionDTO {
  int? id;
  final int userId;
  final ProductDTO product;
  final int deliveryFrequency;
  final String startDate;

  SubscriptionDTO({
    this.id,
    required this.userId,
    required this.product,
    required this.deliveryFrequency,
    required this.startDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'productId': product.id,
      'deliveryFrequency': deliveryFrequency,
      'startDate': startDate,
    };
  }

  factory SubscriptionDTO.fromJson(Map<String, dynamic> json, ProductDTO product) {
    return SubscriptionDTO(
      id: json['id'],
      userId: json['userId'],
      product: product,
      deliveryFrequency: json['deliveryFrequency'],
      startDate: json['startDate'],
    );
  }
}

Future<List<SubscriptionDTO>> fetchSubscriptionsByUserId(int userId) async {
  final response = await http.get(
    Uri.parse('https://localhost:7097/api/Subscription/user$userId'),
  );

  if (response.statusCode == 200) {
    List<dynamic> data = json.decode(response.body);
    List<SubscriptionDTO> subscriptions = [];

    for (var jsonSub in data) {
      var product = await fetchProductById(jsonSub['productId']);
      subscriptions.add(SubscriptionDTO.fromJson(jsonSub, product));
    }

    return subscriptions;
  } else {
    throw Exception('Не вдалося отримати підписки');
  }
}


Future<void> createSubscription(SubscriptionDTO subscription) async {
  final url = Uri.parse('https://localhost:7097/api/Subscription');

  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: json.encode(subscription.toJson()),
  );

  if (response.statusCode == 200) {
    print('Підписка створена');
  } else {
    print('Помилка створення підписки: ${response.statusCode}');
  }
}

Future<void> updateSubscriptionFrequency(int subscriptionId, int newFrequency) async {
  final url = Uri.parse('https://localhost:7097/api/Subscription');

  final response = await http.put(
    url,
    headers: {'Content-Type': 'application/json'},
    body: json.encode({
      'subscriptionId': subscriptionId,
      'deliveryFrequency': newFrequency,
    }),
  );

  if (response.statusCode == 200) {
    print('Частоту оновлено');
  } else {
    print('Не вдалося оновити підписку: ${response.statusCode}');
  }
}

Future<void> deleteSubscriptionById(int subscriptionId) async {
  final url = Uri.parse('https://localhost:7097/api/Subscription/$subscriptionId');

  final response = await http.delete(url);

  if (response.statusCode == 200 || response.statusCode == 204) {
    print('Підписку успішно видалено');
  } else {
    print('Не вдалося видалити підписку: ${response.statusCode}');
    throw Exception('Помилка при видаленні підписки');
  }
}
