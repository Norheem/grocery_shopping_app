import 'package:flutter/material.dart';
import 'package:tumbi_shopping_app/models/cart_model.dart';
import 'package:tumbi_shopping_app/screen/home.dart';

class Cart extends StatefulWidget {
  final List<CartItem> cartItems;
  final Function(List<CartItem>) updateCart;

  const Cart({Key? key, required this.cartItems, required this.updateCart})
      : super(key: key);

  @override
  _CartState createState() => _CartState();
}

class _CartState extends State<Cart> {
  double get totalMoney =>
      widget.cartItems.fold(0, (sum, item) => sum + item.price * item.quantity);

  void incrementQuantity(int index) {
    setState(() {
      widget.cartItems[index].quantity++;
      widget.updateCart(widget.cartItems);
    });
  }

  void decrementQuantity(int index) {
    setState(() {
      if (widget.cartItems[index].quantity > 1) {
        widget.cartItems[index].quantity--;
        widget.updateCart(widget.cartItems);
      }
    });
  }

  void handleCheckout() {
    if (widget.cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cart is empty')),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Icon(Icons.check_circle, color: Colors.green, size: 60),
          content: const Text('Order Successful', textAlign: TextAlign.center),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  widget.cartItems.clear(); // Clear the cart items
                  widget.updateCart(widget.cartItems);
                });
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const Home()),
                  (Route<dynamic> route) => false,
                );
              },
              child: const Text('Close'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Cart',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.brown,
        centerTitle: true,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const Home()),
              (Route<dynamic> route) => false,
            );
          },
        ),
      ),
      backgroundColor: const Color(0xFFF5F5DC),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: widget.cartItems.length,
              itemBuilder: (context, index) {
                final cartItem = widget.cartItems[index];
                return Dismissible(
                  key: Key(cartItem.name),
                  direction: DismissDirection.horizontal,
                  onDismissed: (direction) {
                    setState(() {
                      widget.cartItems.removeAt(index);
                      widget.updateCart(widget.cartItems);
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${cartItem.name} removed')),
                    );
                  },
                  background: Container(color: Colors.red),
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 10),
                    decoration: BoxDecoration(
                      color: Colors.brown[100],
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          spreadRadius: 1,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ListTile(
                      leading: Image.network(cartItem.imageUrl,
                          width: 50, height: 50, fit: BoxFit.cover),
                      title: Text(cartItem.name),
                      subtitle: Text('\₦${cartItem.price.toStringAsFixed(2)}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove),
                            onPressed: () => decrementQuantity(index),
                          ),
                          Text('${cartItem.quantity}'),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () => incrementQuantity(index),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  'Total: \₦${totalMoney.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ElevatedButton(
                  onPressed: handleCheckout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.brown,
                  ),
                  child: const Text(
                    'Checkout',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
