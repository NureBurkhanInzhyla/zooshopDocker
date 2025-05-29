import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:developer';

class UserDTO {
  int? id;
  final String name;
  final String email;
  final String? password;
  String? googleId;
  String? address;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
      'googleId': googleId,
      'address': address,
    };
  }
  UserDTO copyWith({
    int? id,
    String? name,
    String? email,
    String? password,
    String? googleId,
    String? address,

  }) {
    return UserDTO(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      googleId: googleId ?? this.googleId,
      address: address ?? this.address
    );
  }

  UserDTO({this.id, required this.name, required this.email, required this.password,
  this.googleId, this.address});
}

Future<UserDTO> fetchUserByUserEmail(String email, String password) async {
  final response = await http.get(Uri.parse('https://zooshop-dnu7.onrender.com/api/User/$email, $password'));

  if (response.statusCode == 200) {
    var userData = json.decode(response.body);

    UserDTO user = UserDTO(
      id: userData['id'],
      name: userData['name'],
      email: userData['email'],
      password: userData['password'],
      googleId: userData['googleId'],
      address: userData['address'],
    );

    return user;
  } else {
    throw Exception('Не удалось загрузить пользователя');
  }
}

Future<UserDTO> fetchUserByUserEmailGoogle(String email) async {
  final response = await http.get(Uri.parse('https://zooshop-dnu7.onrender.com/api/User/$email'));

  if (response.statusCode == 200) {
    var userData = json.decode(response.body);

    UserDTO user = UserDTO(
      id: userData['id'],
      name: userData['name'],
      email: userData['email'],
      password: userData['password'],
      googleId: userData['googleId'],
      address: userData['address'],
    );

    return user;
  } else {
    throw Exception('Не удалось загрузить пользователя');
  }
}

Future<void> addUser(UserDTO user) async {
  final url = Uri.parse('https://zooshop-dnu7.onrender.com/api/User');

  final response = await http.post(
    url,
    headers: {
      'Content-Type': 'application/json', 
    },
    body: json.encode(user.toJson()),
  );

  if (response.statusCode == 200) {
    print('Юзер был успешно добавлен');
    print(response.body);
  } else {
    print('Не удалось добавить юзера. Статус: ${response.statusCode}');
  }
}

Future<void> updateUser(UserDTO user) async {
  final url = Uri.parse('https://zooshop-dnu7.onrender.com/api/User');

  final response = await http.put(
    url,
    headers: {
      'Content-Type': 'application/json', // Указываем тип данных, которые отправляем
    },
    body: json.encode(user.toJson()), // Преобразуем объект UserDTO в JSON
  );

  print(user.toJson());

  if (response.statusCode == 200) {
    print('Пользователь успешно обновлен');
    print(response.body);
  } else {
    print('Не удалось обновить пользователя. Статус: ${response.statusCode}');
    print(response.body);
  }
}