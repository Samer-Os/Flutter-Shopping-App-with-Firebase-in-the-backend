import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../screens/drawer.dart';
import '../Widgets/order_item.dart';
import '../Providers/orders.dart' show Orders;

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({Key? key}) : super(key: key);
  static const routeName = 'orderScreen';

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  // to avoid calling fetch orders method again when the state changes
  late Future ordersFuture;

  @override
  void initState() {
    ordersFuture = Provider.of<Orders>(context, listen: false).fetchOrders();
    super.initState();
  }

  // we can use this approach instead of using future builder like we did in products overview screen

  // bool isLoading = false;
  // @override
  // void initState() {
  //   isLoading = true;
  //   Provider.of<Orders>(context, listen: false).fetchOrders().then((_) {
  //     setState(() {
  //       isLoading = false;
  //     });
  //   });
  //   super.initState();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Orders'),
      ),
      drawer: const Drawer(
        child: DrawerScreen(),
      ),
      body: FutureBuilder(
        future: ordersFuture,
        builder: (ctx, data) {
          if (data.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (data.error != null) {
            return const Center(
              child: Text('An error occurred'),
            );
          } else {
            if (Provider.of<Orders>(context, listen: false).items.isEmpty) {
              return Container(
                alignment: Alignment.center,
                child: const Text(
                  'No Order Added!',
                  textAlign: TextAlign.center,
                ),
              );
            } else {
              return Consumer<Orders>(
                // we use consumer to avoid building all the state
                builder: (ctx, orders, _) => SingleChildScrollView(
                  child: Column(
                    children: [
                      ...orders.items
                          .map(
                            (order) => OrderItem(
                              id: order.id,
                              date: order.date,
                              totalAmount: order.totalAmount,
                              carts: order.cart,
                            ),
                          )
                          .toList()
                    ],
                  ),
                ),
              );
            }
          }
        },
      ),
    );
  }
}
