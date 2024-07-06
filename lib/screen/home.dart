import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:tumbi_shopping_app/models/cart_model.dart';
import 'package:tumbi_shopping_app/screen/products.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final TextEditingController searchController = TextEditingController();
  List products = [];
  List<CartItem> cartItems = [];
  final String apiUrl =
      'https://api.timbu.cloud/products?organization_id=b755473cb3a44caaae6ecdbf728525a0&reverse_sort=false&page=1&size=25&Appid=APG6NEW601TH1S1&Apikey=82eaf351ef7d4179a7bc8883ad3532b920240705073315617101';

  final String imageUrl = 'https://api.timbu.cloud/images/';

  bool isLoading = true;
  List filteredProducts = [];

  @override
  void initState() {
    super.initState();
    fetchProducts();
    _loadCartItems();

    // Add a listener to the search field
    searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    super.dispose();
  }

  Future<void> fetchProducts() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          products = data['items'] ?? [];
          filteredProducts = products;
          products.shuffle();
          isLoading = false;
        });
      } else {
        print('Failed to load products: ${response.statusCode}');
        setState(() {
          isLoading = false;
        });
      }
    } on SocketException catch (e) {
      print('Network error: $e');
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching products: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void _onSearchChanged() {
    setState(() {
      filteredProducts = products
          .where((product) => product['name']
              .toLowerCase()
              .contains(searchController.text.toLowerCase()))
          .toList();
    });
  }

  // Load cart items from SharedPreferences
  Future<void> _loadCartItems() async {
    final prefs = await SharedPreferences.getInstance();
    final cartData = prefs.getString('cartItems');
    if (cartData != null) {
      final List decodedCartData = json.decode(cartData);
      final List<CartItem> loadedCartItems =
          decodedCartData.map((item) => CartItem.fromJson(item)).toList();
      setState(() {
        cartItems = loadedCartItems;
      });
    }
  }

  // Save cart items to SharedPreferences
  Future<void> _saveCartItems() async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedCartData = json.encode(cartItems);
    await prefs.setString('cartItems', encodedCartData);
  }

  void updateCart(List<CartItem> updatedCartItems) {
    setState(() {
      cartItems = updatedCartItems;
    });
    _saveCartItems(); // Save cart items whenever they are updated
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'HNG GROCERY SHOP',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        elevation: 0.1,
        backgroundColor: const Color(0xFF6D4C41),
      ),
      backgroundColor: const Color(0xFFF5F5DC),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Center(
                child: Container(
                  width: 300,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(148, 228, 228, 228),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: TextFormField(
                      controller: searchController,
                      style: const TextStyle(
                        color: Colors.black,
                      ), // Adjust text color
                      decoration: InputDecoration(
                        hintText: 'Search',
                        hintStyle: TextStyle(
                          color: Colors.black.withOpacity(0.6),
                          fontSize: 15,
                        ),
                        suffixIcon: const Icon(
                          Icons.search,
                          color: Colors.black,
                          size: 30,
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Colors.brown,
                        ),
                      )
                    : SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            children: filteredProducts.map((product) {
                              final image =
                                  imageUrl + product['photos'][0]['url'];
                              final name = product['name'];
                              final priceList = product['current_price'];
                              final price = priceList[0]['NGN'][0];
                              final description = product['description'];
                              return Container(
                                margin: const EdgeInsets.symmetric(vertical: 5),
                                decoration: BoxDecoration(
                                  color: Colors.brown,
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
                                  leading: Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      image: DecorationImage(
                                        image: NetworkImage(image),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    name,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Text(
                                    '\₦${price.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                  trailing: IconButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => Products(
                                            name: name,
                                            imageUrl: image,
                                            price: price,
                                            description: description,
                                            cartItems: cartItems,
                                            updateCart: updateCart,
                                          ),
                                        ),
                                      );
                                    },
                                    icon: const Icon(
                                      Icons.arrow_forward_ios,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
