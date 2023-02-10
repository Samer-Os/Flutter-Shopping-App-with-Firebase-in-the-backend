import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Providers/cart.dart';

class CartItem extends StatelessWidget {
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

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(id),
      onDismissed: (direction) {
        Provider.of<Cart>(
          context,
          listen: false,
        ).removeProduct(id);
      },
      confirmDismiss: (direction) {
        return showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Are you sure?'),
            content: const Text('Do you want to remove the item from the cart'),
            actions: [
              TextButton(
                child: const Text('No'),
                onPressed: () {
                  Navigator.of(ctx).pop(false);
                },
              ),
              TextButton(
                child: const Text('Yes'),
                onPressed: () {
                  Navigator.of(ctx).pop(true);
                },
              ),
            ],
          ),
        );
      },
      direction: DismissDirection.endToStart,
      background: Container(
        padding: const EdgeInsets.only(right: 15),
        margin: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 5,
        ),
        alignment: Alignment.centerRight,
        color: Colors.redAccent,
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      child: Card(
        margin: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 5,
        ),
        child: ListTile(
          leading: CircleAvatar(
            radius: 25,
            backgroundColor: Colors.purple,
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: FittedBox(
                child: Text(
                  '\$$price',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          title: Text(
            title,
            style: const TextStyle(
              color: Colors.black,
            ),
          ),
          subtitle: Text(
            '\$${price * quantity}',
            style: const TextStyle(
              color: Colors.grey,
            ),
          ),
          trailing: Text(
            '${quantity}x',
            style: const TextStyle(
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}
