import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../screens/drawer.dart';
import '../Providers/cart.dart';
import '../Widgets/budget.dart';
import '../Providers/product.dart';
import '../Providers/products.dart';
import '../Widgets/product_item.dart';

enum FilterOptions {
  all,
  favorites,
}

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({Key? key}) : super(key: key);
  static String productsScreenRoute = 'productsScreenRoute';

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  bool isLoading = false;

  @override
  void initState() {
    isLoading = true;
    // we can delete listen: false and use Future.delayed(Duration.zero).then((_) {})
    Provider.of<Products>(context, listen: false).fetchProducts().then((_) {
      setState(() {
        isLoading = false;
      });
    }).catchError((error) {
      print(error);
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
          'An error occurred',
          textAlign: TextAlign.center,
        )),
      );
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final products = Provider.of<Products>(context);
    List<Product> loadedProducts =
        products.showAll ? products.item : products.favoriteItem;
    return Scaffold(
      appBar: AppBar(
        title: const Text("My shop"),
        actions: [
          PopupMenuButton(
            icon: const Icon(Icons.more_vert),
            onSelected: (selectedValue) => [
              if (FilterOptions.all == selectedValue)
                products.showALL()
              else
                products.showFavorites()
            ],
            itemBuilder: (_) => [
              const PopupMenuItem(
                child: Text('Only Favorites'),
                value: FilterOptions.favorites,
              ),
              const PopupMenuItem(
                child: Text('Show All'),
                value: FilterOptions.all,
              ),
            ],
          ),
          Budget(Provider.of<Cart>(context).cartAmount),
        ],
      ),
      drawer: const Drawer(
        child: DrawerScreen(),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : loadedProducts.isEmpty
              ? Container(
                  alignment: Alignment.center,
                  child: Text(
                    products.favoriteItem.isEmpty
                        ? 'No Favorite Product Added!'
                        : 'No Product Added!',
                    textAlign: TextAlign.center,
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: loadedProducts.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 3 / 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemBuilder: (ctx, i) {
                    return ChangeNotifierProvider.value(
                      value: loadedProducts[i],
                      child: ProductItem(
                          // id: products.item[i].id,
                          // title: products.item[i].title,
                          // imageUrl: products.item[i].imageUrl,
                          ),
                    );
                  },
                ),
    );
  }
}
