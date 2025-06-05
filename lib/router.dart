import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:zooshop/account_page.dart';
import 'package:zooshop/adress_page.dart';
import 'package:zooshop/cart_page.dart';
import 'package:zooshop/change_password_page.dart';
import 'package:zooshop/checkout_page.dart';
import 'package:zooshop/main.dart';
import 'package:zooshop/models/Cart.dart';
import 'package:zooshop/models/Product.dart';
import 'package:zooshop/orders_page.dart';
import 'package:zooshop/product.dart';
import 'package:zooshop/subscription_page.dart';
import 'catalog.dart';
import 'product.dart';

final GoRouter router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => MainPage()),
    GoRoute(path: '/account', builder: (context, state) => AccountPage()),
    GoRoute(path: '/catalog', builder: (context, state) => CatalogPage()),
    GoRoute(
      path: '/catalog',
      builder: (context, state) {
        final searchQuery = state.uri.queryParameters['searchQuery']; 
        return CatalogPage(searchQuery: searchQuery);
      },
    ),

    GoRoute(
      path: 'catalog/:animalType',
      builder:
          (context, state) =>
              CatalogPage(animalType: state.pathParameters['animalType']),
    ),
    GoRoute(
      path: '/promotions',
      builder: (context, state) => CatalogPage(isPromotional: true),
    ),
    GoRoute(path: '/address', builder: (context, state) => AddressPage()),
    GoRoute(
      path: '/change_password',
      builder: (context, state) => ChangePasswordPage(),
    ),
    GoRoute(path: '/orders', builder: (context, state) => OrdersPage()),
    GoRoute(
      path: '/subscriptions',
      builder: (context, state) => SubscriptionPage(),
    ),
    GoRoute(path: '/cart', builder: (context, state) => CartPage()),
    GoRoute(path: '/checkout', builder: (context, state) => CheckoutPage()),
    GoRoute(
      path: '/product/:productId',
      builder: (context, state) {
        final productIdString = state.pathParameters['productId']!;
        final int productId = int.tryParse(productIdString) ?? -1;

        return FutureBuilder<ProductDTO>(
          future: fetchProductById(productId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            if (snapshot.hasError || !snapshot.hasData) {
              return Scaffold(
                body: Center(child: Text('Error loading product')),
              );
            }
            return ProductPage(product: snapshot.data!);
          },
        );
      },
    ),
  ],
);
