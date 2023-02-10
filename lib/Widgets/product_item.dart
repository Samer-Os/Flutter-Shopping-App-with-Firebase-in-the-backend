import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Providers/auth.dart';
import '../Providers/cart.dart';
import '../Providers/product.dart';
import '../screens/product_details.dart';

class ProductItem extends StatelessWidget {
  // final String id;
  // final String title;
  // final String imageUrl;
  //
  // ProductItem({
  //   required this.id,
  //   required this.title,
  //   required this.imageUrl,
  // });

  void pushDetailScreen(BuildContext ctx, String id) {
    Navigator.of(ctx).pushNamed(
      ProductDetails.detailsRoute,
      arguments: id,
    );
  }

  @override
  Widget build(BuildContext context) {
    final product = Provider.of<Product>(context, listen: false);
    final cart = Provider.of<Cart>(context, listen: false);
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: GridTile(
        child: GestureDetector(
          onTap: () => pushDetailScreen(context, product.id),
          child: Image.network(
            product.imageUrl,
            fit: BoxFit.cover,
          ),
        ),
        footer: GridTileBar(
          backgroundColor: Colors.black87,
          title: Text(
            product.title,
            textAlign: TextAlign.center,
          ),
          leading: Consumer<Product>(
            builder: (ctx, product, _) => IconButton(
              icon: product.isFavorite
                  ? const Icon(Icons.favorite)
                  : const Icon(Icons.favorite_border),
              onPressed: () async {
                try {
                  await product.toggleFavorite(
                    Provider.of<Auth>(context, listen: false).authUserID,
                    Provider.of<Auth>(context, listen: false).authToken,
                  );
                } catch (_) {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text(
                      'An error occurred',
                      textAlign: TextAlign.center,
                    )),
                  );
                }
              },
              color: Theme.of(context).accentColor,
            ),
          ),
          trailing: IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              cart.addCart(product.id, product.title, product.price);
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('an item is added!'),
                  duration: const Duration(seconds: 2),
                  action: SnackBarAction(
                    label: 'UNDO',
                    onPressed: () {
                      cart.removeSingleProduct(product.id);
                    },
                  ),
                ),
              );
            },
            color: Theme.of(context).accentColor,
          ),
        ),
      ),
    );
  }
}
