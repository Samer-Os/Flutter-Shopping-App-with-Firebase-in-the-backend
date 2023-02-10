import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../Providers/cart.dart';

class OrderItem extends StatefulWidget {
  final String id;
  final DateTime date;
  final double totalAmount;
  final List<CartItem> carts;

  OrderItem({
    required this.id,
    required this.date,
    required this.totalAmount,
    required this.carts,
  });

  @override
  State<OrderItem> createState() => _OrderItemState();
}

class _OrderItemState extends State<OrderItem> {
  bool expand = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 10,
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            ListTile(
              leading: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '\$${widget.totalAmount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                  Text(
                    DateFormat('dd/MM/yyyy hh:mm aaa').format(widget.date),
                    style: const TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              trailing: IconButton(
                icon: Icon(expand ? Icons.expand_less : Icons.expand_more),
                onPressed: () {
                  setState(() {
                    expand = !expand;
                  });
                },
              ),
            ),
            if (expand)
              Container(
                height: min(widget.carts.length * 20.0 + 100, 200),
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                  border: Border.all(
                    color: Colors.purple,
                    width: 1,
                  ),
                ),
                margin: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 10,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: ListView.builder(
                    itemCount: widget.carts.length,
                    itemBuilder: (ctx, i) => Column(
                      children: [
                        ListTile(
                          leading: Text(
                            widget.carts[i].title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          trailing: Text(
                            '${widget.carts[i].quantity}X \$${widget.carts[i].price}',
                            style: const TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
