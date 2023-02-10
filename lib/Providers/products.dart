import 'dart:convert';

import 'package:flutter/cupertino.dart';
import '../Models/http_exception.dart';
import '../Providers/product.dart';
import 'package:http/http.dart' as http;

class Products with ChangeNotifier {
  List<Product> products = [
    // Product(
    //   id: 'p1',
    //   title: 'Red Shirt',
    //   description: 'A red shirt - it is pretty red!',
    //   price: 29.99,
    //   imageUrl:
    //       'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    // ),
    // Product(
    //   id: 'p2',
    //   title: 'Trousers',
    //   description: 'A nice pair of trousers.',
    //   price: 59.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    // ),
    // Product(
    //   id: 'p3',
    //   title: 'Yellow Scarf',
    //   description: 'Warm and cozy - exactly what you need for the winter.',
    //   price: 19.99,
    //   imageUrl:
    //       'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    // ),
    // Product(
    //   id: 'p4',
    //   title: 'A Pan',
    //   description: 'Prepare any meal you want.',
    //   price: 49.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    // ),
  ];

  final String authToken;
  final String authUserId;

  Products(this.authToken, this.authUserId, this.products);

  List<Product> get item {
    return [...products];
  }

  Product findById(String id) {
    return products.firstWhere((product) => product.id == id);
  }

  List<Product> get favoriteItem {
    return products.where((product) => product.isFavorite).toList();
  }

  bool showAll = true;

  void showFavorites() {
    showAll = false;
    notifyListeners();
  }

  void showALL() {
    showAll = true;
    notifyListeners();
  }

  Future<void> fetchProducts([bool userFiltering = false]) async {
    var filteringSegment = '';
    if (userFiltering) {
      filteringSegment = 'orderBy="userId"&equalTo="$authUserId"';
    }
    var url = Uri.parse(
        'https://myshop-8b863-default-rtdb.firebaseio.com/products.json?auth=$authToken&$filteringSegment');
    var response = await http.get(url);
    final extractedDAta = json.decode(response.body) != null
        ? json.decode(response.body) as Map<String, dynamic>
        : null;
    if (extractedDAta == null) {
      return;
    }
    url = Uri.parse(
        'https://myshop-8b863-default-rtdb.firebaseio.com/favorites/$authUserId.json?auth=$authToken');
    response = await http.get(url);
    final favoritesDAta = json.decode(response.body) != null
        ? json.decode(response.body) as Map<String, dynamic>
        : null;
    List<Product> loadedProducts = [];
    extractedDAta.forEach((prodID, prodData) {
      loadedProducts.add(
        Product(
          id: prodID,
          title: prodData['title'],
          description: prodData['description'],
          price: prodData['price'],
          imageUrl: prodData['imageUrl'],
          isFavorite: favoritesDAta == null ? false : favoritesDAta[prodID] ?? false,
        ),
      );
    });
    products = loadedProducts;
    notifyListeners();
  }

  Future<void> addEditProduct(Product prod, String id) async {
    try {
      if (id.isEmpty) {
        final url = Uri.parse(
            'https://myshop-8b863-default-rtdb.firebaseio.com/products.json?auth=$authToken');
        final response = await http.post(
          url,
          body: json.encode({
            'title': prod.title,
            'price': prod.price,
            'isFavorite': prod.isFavorite,
            'description': prod.description,
            'imageUrl': prod.imageUrl,
            'userId': authUserId,
          }),
        );
        products.add(Product(
          title: prod.title,
          price: prod.price,
          imageUrl: prod.imageUrl,
          description: prod.description,
          id: json.decode(response.body)['name'],
        ));
      } else {
        final url = Uri.parse(
            'https://myshop-8b863-default-rtdb.firebaseio.com/products/$id.json?auth=$authToken');
        final response = await http.patch(url,
            body: json.encode({
              'title': prod.title,
              'price': prod.price,
              'description': prod.description,
              'imageUrl': prod.imageUrl,
            }));
        if (response.statusCode >= 400) {
          throw HttpException('an error');
        }
        for (var product in products) {
          if (product.id == id) {
            product.title = prod.title;
            product.description = prod.description;
            product.price = prod.price;
            product.imageUrl = prod.imageUrl;
            break;
          }
        }
      }
    } catch (error) {
      rethrow;
    }
    notifyListeners();
  }

  Future<void> removeProduct(String id) async {
    final prodIndex = products.indexWhere((product) => product.id == id);
    final product = products[prodIndex];
    products.removeWhere((product) => product.id == id);
    notifyListeners();
    final url = Uri.parse(
        'https://myshop-8b863-default-rtdb.firebaseio.com/products/$id.json?auth=$authToken');
    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      products.insert(prodIndex, product);
      notifyListeners();
      throw HttpException('an error');
    }
  }
}
