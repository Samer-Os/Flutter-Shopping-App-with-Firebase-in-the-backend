import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Providers/cart.dart';
import '../Providers/products.dart';
import '../screens/edit_add_product.dart';

class ManageProductItem extends StatelessWidget {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final String price;
  final bool isFavorite;

  ManageProductItem({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.description,
    required this.price,
    required this.isFavorite,
  });

  @override
  Widget build(BuildContext context) {
    final scaffold = ScaffoldMessenger.of(context);
    final cart = Provider.of<Cart>(context, listen: false);
    return Column(
      children: [
        ListTile(
          title: Text(title),
          leading: CircleAvatar(
            backgroundImage: NetworkImage(
              imageUrl,
            ),
          ),
          trailing: Container(
            width: 100,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    Navigator.of(context).pushNamed(
                      EditAddProduct.routeName,
                      arguments: {
                        'id': id,
                        'title': title,
                        'price': price,
                        'imageUrl': imageUrl,
                        'description': description,
                        'isFavorite': isFavorite,
                      },
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(
                    Icons.delete,
                    color: Colors.red,
                  ),
                  onPressed: () async {
                    try {
                      await Provider.of<Products>(context, listen: false)
                          .removeProduct(id);
                      cart.removeProduct(id);
                    } catch (error) {
                      scaffold.hideCurrentSnackBar();
                      scaffold.showSnackBar(
                        const SnackBar(
                            content: Text(
                          'An error occurred, verify your internet',
                          textAlign: TextAlign.center,
                        )),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
        const Divider(),
      ],
    );
  }
}
