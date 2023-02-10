import 'dart:convert';

import 'package:flutter/cupertino.dart';
import '../Providers/cart.dart';
import 'package:http/http.dart' as http;

class OrderItem {
  final String id;
  final DateTime date;
  final double totalAmount;
  final List<CartItem> cart;

  OrderItem({
    required this.id,
    required this.date,
    required this.totalAmount,
    required this.cart,
  });
}

class Orders with ChangeNotifier {
  List<OrderItem> orders = [];

  List<OrderItem> get items {
    return [...orders];
  }

  final String authToken;
  final String authUserId;

  Orders(this.authToken, this.authUserId, this.orders);

  Future<void> fetchOrders() async {
    final url = Uri.parse(
        'https://myshop-8b863-default-rtdb.firebaseio.com/orders/$authUserId.json?auth=$authToken');
    final response = await http.get(url);
    final extractedData = json.decode(response.body) != null
        ? json.decode(response.body) as Map<String, dynamic>
        : null;
    if (extractedData == null) {
      return;
    }
    List<OrderItem> loadedOrders = [];
    extractedData.forEach((orderId, orderData) {
      loadedOrders.add(OrderItem(
        id: orderId,
        cart: (orderData['cart'] as List<dynamic>)
            .map((item) => CartItem(
                  id: item['id'],
                  price: item['price'],
                  title: item['title'],
                  quantity: item['quantity'],
                ))
            .toList(),
        totalAmount: orderData['totalAmount'],
        date: DateTime.parse(orderData['date']),
      ));
    });
    orders = loadedOrders.reversed.toList();
    notifyListeners();
  }

  Future<void> addOrder(double totalAmount, List<CartItem> cart) async {
    final DateTime date = DateTime.now();
    final url = Uri.parse(
        'https://myshop-8b863-default-rtdb.firebaseio.com/orders/$authUserId.json?auth=$authToken');
    final response = await http.post(
      url,
      body: json.encode({
        'date': date.toIso8601String(),
        'totalAmount': totalAmount,
        'cart': cart
            .map((item) => {
                  'id': item.id,
                  'title': item.title,
                  'price': item.price,
                  'quantity': item.quantity,
                })
            .toList(),
      }),
    );
    orders.insert(
      0,
      OrderItem(
        id: json.decode(response.body)['name'],
        date: date,
        totalAmount: totalAmount,
        cart: cart,
      ),
    );

    notifyListeners();
  }
}
