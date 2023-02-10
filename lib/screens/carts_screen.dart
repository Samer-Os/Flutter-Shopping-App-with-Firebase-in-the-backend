import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Providers/orders.dart';
import '../Widgets/cart_item.dart';
import '../Providers/cart.dart' show Cart;

class CartScreen extends StatefulWidget {
  static String cartRoute = 'cartRoute';

  const CartScreen({Key? key}) : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('your Cart'),
      ),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 10,
            ),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const Spacer(),
                  Chip(
                    backgroundColor: Colors.purple,
                    label: Text(
                      '\$${cart.totalAmount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 15,
                  ),
                  TextButton(
                    onPressed: cart.totalAmount != 0
                        ? () async {
                            setState(() {
                              isLoading = true;
                            });
                            try {
                              await Provider.of<Orders>(context, listen: false)
                                  .addOrder(
                                cart.totalAmount,
                                cart.items.values.toList(),
                              );
                              cart.clearCart();
                            } catch (_) {
                              ScaffoldMessenger.of(context)
                                  .hideCurrentSnackBar();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                  'An error occurred, verify your internet',
                                  textAlign: TextAlign.center,
                                )),
                              );
                            }
                            setState(() {
                              isLoading = false;
                            });
                          }
                        : null,
                    child: isLoading
                        ? const CircularProgressIndicator()
                        : Text(
                            'Order Now',
                            style: TextStyle(
                              color: cart.totalAmount != 0
                                  ? Colors.purple
                                  : Colors.grey,
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: cart.cartAmount,
              itemBuilder: (ctx, i) => CartItem(
                id: cart.items.keys.toList()[i],
                title: cart.items.values.toList()[i].title,
                quantity: cart.items.values.toList()[i].quantity,
                price: cart.items.values.toList()[i].price,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
