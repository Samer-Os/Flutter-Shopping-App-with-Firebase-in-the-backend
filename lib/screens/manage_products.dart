import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../screens/edit_add_product.dart';
import '../Widgets/manage_product_item.dart';
import '../Providers/products.dart';
import '../screens/drawer.dart';

class ManageProductsScreen extends StatelessWidget {
  const ManageProductsScreen({Key? key}) : super(key: key);
  static const routeName = 'ManageProductsScreen';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Products'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context)
                  .pushNamed(EditAddProduct.routeName, arguments: null);
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      drawer: const Drawer(
        child: DrawerScreen(),
      ),
      body: FutureBuilder(
        future:
            Provider.of<Products>(context, listen: false).fetchProducts(true),
        builder: (ctx, snapshot) =>
            snapshot.connectionState == ConnectionState.waiting
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : Consumer<Products>(
                    builder: (ctx, products, _) => RefreshIndicator(
                      onRefresh: () async {
                        await Provider.of<Products>(context, listen: false)
                            .fetchProducts(true);
                      },
                      child: products.item.isEmpty
                          ? Container(
                              alignment: Alignment.center,
                              child: const Text(
                                'No Product Added!',
                                textAlign: TextAlign.center,
                              ),
                            )
                          : ListView.builder(
                              itemCount: products.item.length,
                              itemBuilder: (ctx, i) => ManageProductItem(
                                id: products.item[i].id,
                                title: products.item[i].title,
                                description: products.item[i].description,
                                imageUrl: products.item[i].imageUrl,
                                isFavorite: products.item[i].isFavorite,
                                price: products.item[i].price.toString(),
                              ),
                            ),
                    ),
                  ),
      ),
    );
  }
}
