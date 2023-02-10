import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../Models/http_exception.dart';

class Product with ChangeNotifier {
  final String id;
  String title;
  String description;
  double price;
  String imageUrl;
  bool isFavorite;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.isFavorite = false,
  });

  Future<void> toggleFavorite(String authUserId, String authToken) async {
    final oldStatus = isFavorite;
    isFavorite = !isFavorite;
    notifyListeners();
    var url = Uri.parse(
        'https://myshop-8b863-default-rtdb.firebaseio.com/favorites/$authUserId/$id.json?auth=$authToken');
    final response;
    if (isFavorite) {
      response = await http.put(
        url,
        body: json.encode(true),
      );
    } else {
      url = Uri.parse(
          'https://myshop-8b863-default-rtdb.firebaseio.com/favorites/$authUserId/$id.json?auth=$authToken');
      response = await http.delete(url);
    }

    if (response.statusCode >= 400) {
      isFavorite = oldStatus;
      notifyListeners();
      throw HttpException('an error');
    }
  }
}
