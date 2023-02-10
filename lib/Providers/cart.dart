import 'package:flutter/foundation.dart';

class CartItem {
  final String id;
  final String title;
  final double price;
  final int quantity;

  CartItem({
    required this.id,
    required this.title,
    required this.price,
    required this.quantity,
  });
}

class Cart with ChangeNotifier {
  Map<String, CartItem> carts = {};

  Map<String, CartItem> get items {
    return {...carts};
  }

  void addCart(String productID, String title, double price) {
    if (carts.keys.contains(productID)) {
      carts.update(
        productID,
        (existingValue) => CartItem(
          id: existingValue.id,
          title: existingValue.title,
          price: existingValue.price,
          quantity: existingValue.quantity + 1,
        ),
      );
    } else {
      carts.putIfAbsent(
        productID,
        () => CartItem(
          id: DateTime.now().toString(),
          title: title,
          price: price,
          quantity: 1,
        ),
      );
    }
    notifyListeners();
  }

  void updateCartInfo(String id, String title, double price) {
    if (carts.keys.contains(id)) {
      carts.update(
        id,
        (existingValue) => CartItem(
          id: existingValue.id,
          title: title,
          price: price,
          quantity: existingValue.quantity,
        ),
      );
      notifyListeners();
    }
  }

  int get cartAmount {
    return carts.length;
  }

  double get totalAmount {
    double totalAmount = 0;
    for (var product in carts.values) {
      totalAmount += product.quantity * product.price;
    }
    return totalAmount;
  }

  void removeProduct(String id) {
    carts.remove(id);
    notifyListeners();
  }

  void removeSingleProduct(String id) {
    if (!carts.keys.contains(id)) {
      return;
    } else if (carts[id]!.quantity > 1) {
      carts.update(
        id,
        (existingValue) => CartItem(
          id: existingValue.id,
          title: existingValue.title,
          price: existingValue.price,
          quantity: existingValue.quantity - 1,
        ),
      );
    } else {
      carts.remove(id);
    }
    notifyListeners();
  }

  void clearCart() {
    carts = {};
    notifyListeners();
  }
}
