import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:developer';

class ProductDTO {
  final int id;
  final String name;
  final int price;
  final String image;
  final String desc;
  final String petCategory;
  final String productCategory;
  final int? discountPercent;

  ProductDTO({required this.id, required this.name, required this.price, 
  required this.image, required this.desc, required this.petCategory, required this.productCategory, this.discountPercent});

  factory ProductDTO.fromJson(Map<String, dynamic> json) {
    
    return ProductDTO(
      id: json['id'],
      name: json['name'],
      price: json['price'],
      image: json['image'],
      desc: json['desc'],
      petCategory: json['petCategory'],
      productCategory: json['productCategory'],
      discountPercent: json['discountPercent'],

    );
  }
}

Future<ProductDTO> fetchProductById(int id) async {
  final response = await http.get(Uri.parse('https://zooshop-dnu7.onrender.com/api/Product/$id'));
  if (response.statusCode == 200) {
    print(json.decode(response.body));
    return ProductDTO.fromJson(json.decode(response.body));
  } else {
    throw Exception('Не удалось загрузить продукт');
  }
}

Future<List<ProductDTO>> fetchProducts() async {
  final response = await http.get(Uri.parse('https://zooshop-dnu7.onrender.com/api/Product'));

  if (response.statusCode == 200) {
    List<dynamic> data = json.decode(response.body);
    return data.map((item) => ProductDTO.fromJson(item)).toList();
  } else {
    throw Exception('Не удалось загрузить товары');
  }
}

Future<List<ProductDTO>> fetchProductsByFiltration({
  String? name,
  int? startPrice,
  int? endPrice,
  String? petCategory,
  String? productCategory,
}) async {
  final queryParameters = {
    'name': name,
    'startPrice': startPrice?.toString(),
    'endPrice': endPrice?.toString(),
    'petCategory': petCategory,
    'productCategory': productCategory,
  };

  final url = Uri.https(
    'zooshop-dnu7.onrender.com', 
    '/api/Product/Filtration', 
    queryParameters
  );

  final response = await http.get(url);

  if (response.statusCode == 200) {
    
    List<dynamic> data = json.decode(response.body);
    return data.map((item) => ProductDTO.fromJson(item)).toList();
  } else {
    throw Exception('Не удалось загрузить товары');
  }

}

Future<Map<String, List<String>>> fetchCategories() async {
  final response = await http.get(Uri.parse('https://zooshop-dnu7.onrender.com/api/Product/Categories'));

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    return {
      "productCategories": List<String>.from(data["productCategories"]),
      "petCategories": List<String>.from(data["petCategories"]),
    };
  } else {
    throw Exception("Не вдалося завантажити категорії");
  }
}

Future<List<ProductDTO>> fetchSimilarProducts(ProductDTO product) async {
  final byPet = await fetchProductsByFiltration(
    petCategory: product.petCategory,
  );

  final byCategory = await fetchProductsByFiltration(
    productCategory: product.productCategory,
  );

  final all = [...byPet, ...byCategory];
  final unique = {
    for (var p in all) p.id: p
  }.values.toList();

  return unique.where((p) => p.id != product.id).toList();
}
