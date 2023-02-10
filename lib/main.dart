import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './screens/waiting_screen..dart';
import './Providers/auth.dart';
import './screens/auth_screen.dart';
import './screens/edit_add_product.dart';
import './screens/manage_products.dart';
import './screens/orders_screen.dart';
import './Providers/orders.dart';
import './screens/carts_screen.dart';
import './Providers/cart.dart';
import './screens/product_details.dart';
import './Providers/products.dart';
import './screens/products_overview.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (ctx) => Auth(),
        ),
        ChangeNotifierProxyProvider<Auth, Products>(
          create: (ctx) => Products(
            Auth().authToken,
            Auth().authUserID,
            [],
          ),
          update: (ctx, auth, previousProd) => Products(
            auth.authToken,
            auth.authUserID,
            previousProd == null ? [] : previousProd.products,
          ),
        ),
        ChangeNotifierProvider(
          create: (ctx) => Cart(),
        ),
        ChangeNotifierProxyProvider<Auth, Orders>(
          create: (ctx) => Orders(
            Auth().authToken,
            Auth().authUserID,
            [],
          ),
          update: (ctx, auth, previousProd) => Orders(
            auth.authToken,
            auth.authUserID,
            previousProd == null ? [] : previousProd.orders,
          ),
        ),
      ],
      child: Consumer<Auth> (
        builder: (ctx, auth, _) => MaterialApp(
          title: 'Flutter Demo',
          theme: ThemeData(
            primarySwatch: Colors.purple,
            accentColor: Colors.deepOrange,
            fontFamily: 'Lato',
          ),
          home: auth.isAuth
              ? const ProductsScreen()
              : FutureBuilder(
                  future: auth.tryAutoLogin(),
                  builder: (ctx, snapshot) =>
                      snapshot.connectionState == ConnectionState.waiting
                          ? const WaitingScreen()
                          : const AuthScreen(),
                ),
          routes: {
            ProductDetails.detailsRoute: (ctx) => const ProductDetails(),
            CartScreen.cartRoute: (ctx) => const CartScreen(),
            OrdersScreen.routeName: (ctx) => const OrdersScreen(),
            ManageProductsScreen.routeName: (ctx) =>
                const ManageProductsScreen(),
            EditAddProduct.routeName: (ctx) => const EditAddProduct(),
          },
        ),
      ),
    );
  }
}
