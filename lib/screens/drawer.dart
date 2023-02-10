import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Providers/auth.dart';
import '../screens/manage_products.dart';
import '../screens/orders_screen.dart';

class DrawerScreen extends StatelessWidget {
  const DrawerScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppBar(
          title: const Text('Hi Friend!'),
          automaticallyImplyLeading: false,
        ),
        const Divider(),
        ListTile(
          onTap: (){
            Navigator.of(context).pushReplacementNamed('/');
          },
          leading: const Icon(Icons.shopping_cart),
          title: const Text('Shop'),
        ),
        const Divider(),
        ListTile(
          onTap: (){
            Navigator.of(context).pushReplacementNamed(OrdersScreen.routeName);
          },
          leading: const Icon(Icons.payment),
          title: const Text('Orders'),
        ),
        const Divider(),
        ListTile(
          onTap: (){
            Navigator.of(context).pushReplacementNamed(ManageProductsScreen.routeName);
          },
          leading: const Icon(Icons.edit),
          title: const Text('Manage Products'),
        ),
        const Divider(),
        ListTile(
          onTap: (){
            Provider.of<Auth>(context, listen: false).logout();
            Navigator.of(context).pushReplacementNamed('/');
          },
          leading: const Icon(Icons.exit_to_app),
          title: const Text('Logout'),
        ),
        const Divider(),
      ],
    );
  }
}
