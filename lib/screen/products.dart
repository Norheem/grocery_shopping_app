import 'package:flutter/material.dart';
import 'package:tumbi_shopping_app/models/cart_model.dart';
import 'package:tumbi_shopping_app/screen/cart.dart';

class Products extends StatelessWidget {
  final String name;
  final String imageUrl;
  final double price;
  final String description;
  final List<CartItem> cartItems;
  final Function(List<CartItem>) updateCart;

  const Products({
    Key? key,
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.description,
    required this.cartItems,
    required this.updateCart,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isInCart = cartItems.any((item) => item.name == name);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.brown,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            height: 250,
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              color: const Color(0xFFF5F5DC),
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Price: \₦${price.toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Description',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (isInCart) {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Item Already in Cart'),
                    content: const Text('This item is already in your cart.'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              } else {
                CartItem item = CartItem(
                  name: name,
                  imageUrl: imageUrl,
                  price: price,
                  quantity: 1,
                );
                cartItems.add(item);
                updateCart(cartItems);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('$name added to cart')),
                );
              }

              Future.delayed(Duration(seconds: 1), () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Cart(
                      cartItems: cartItems,
                      updateCart: (updatedCartItems) {
                        updateCart(updatedCartItems);
                      },
                    ),
                  ),
                );
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.brown,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
            ),
            child: const Text(
              'Add to Cart',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
