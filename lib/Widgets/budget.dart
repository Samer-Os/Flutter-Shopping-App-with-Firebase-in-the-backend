import 'package:flutter/material.dart';
import '../screens/carts_screen.dart';

class Budget extends StatelessWidget {
  final int totalProduct;

  Budget(this.totalProduct);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        IconButton(
          onPressed: () {
            Navigator.of(context).pushNamed(CartScreen.cartRoute);
          },
          icon: const Icon(Icons.shopping_cart),
        ),
        if (totalProduct > 0)
          Positioned(
            height: 20,
            width: 20,
            top: 3,
            right: 6,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: FittedBox(
                child: Text(
                  '$totalProduct',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
