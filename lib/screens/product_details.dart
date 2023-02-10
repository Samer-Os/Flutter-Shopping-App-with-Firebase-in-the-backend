import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Providers/products.dart';

class ProductDetails extends StatelessWidget {
  const ProductDetails({Key? key}) : super(key: key);
  static String detailsRoute = 'detailsRoute';

  @override
  Widget build(BuildContext context) {
    final productId = ModalRoute.of(context)!.settings.arguments;
    final product = Provider.of<Products>(context, listen: false)
        .findById(productId as String);
    return Scaffold(
      appBar: AppBar(
        title: Text(product.title),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              height: 300,
              child: Image.network(
                product.imageUrl,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              '\$${product.price.toStringAsFixed(2)}',
              style: const TextStyle(
                color: Colors.black,
                fontSize: 20,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
              ),
              width: double.infinity,
              alignment: Alignment.center,
              child: Text(
                product.description,
                softWrap: true,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
