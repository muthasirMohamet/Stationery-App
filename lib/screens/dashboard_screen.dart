import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../config.dart';
import 'add_product_screen.dart';
import 'edit_product.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  List products = [];
  bool isLoading = true;
  List cart = []; // Cart to hold selected products

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    setState(() {
      isLoading = true; // Start loading
    });

    try {
      final response = await http.get(Uri.parse('$baseUrl/products'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final List<dynamic> productsData = responseData['products'];

        setState(() {
          products =
              productsData; // Populate products list with data from the API
          isLoading = false; // Stop loading after data is fetched
        });
      } else {
        showSnackbar(
            'Failed to load products. Status code: ${response.statusCode}');
        setState(() => isLoading = false);
      }
    } catch (e) {
      showSnackbar('Error fetching products: $e');
      setState(() => isLoading = false);
    }
  }

  void addToCart(product) {
    setState(() {
      cart.add(product); // Add selected product to cart
    });
    showSnackbar('Product added to cart!');
  }

  Future<void> deleteProduct(int id) async {
    bool? shouldDelete = await showDeleteConfirmationDialog();
    if (shouldDelete == false) return;

    try {
      final response =
          await http.delete(Uri.parse('$baseUrl/delete-product/$id'));

      if (response.statusCode == 200) {
        showSnackbar('Product deleted successfully');
        fetchProducts(); // Refresh list after deletion
      } else {
        showSnackbar('Failed to delete product');
      }
    } catch (e) {
      showSnackbar('Error deleting product: $e');
    }
  }

  Future<bool?> showDeleteConfirmationDialog() async {
    return showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Confirm Deletion'),
              content: Text('Are you sure you want to delete this product?'),
              actions: <Widget>[
                TextButton(
                  child: Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                ),
                TextButton(
                  child: Text('Delete'),
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                ),
              ],
            );
          },
        ) ??
        false;
  }

  void showSnackbar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void navigateToAddProductScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddProductScreen()),
    ).then((_) => fetchProducts()); // Fetch products after returning
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (_selectedIndex == 1) {
      fetchProducts(); // Fetch products when "View All" is selected
    } else if (_selectedIndex == 2) {
      navigateToCartScreen(); // Navigate to cart when cart button is pressed
    }
  }

  void navigateToCartScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CartScreen(cart: cart)),
    );
  }

  Widget _buildProductList() {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    } else if (products.isEmpty) {
      return Center(child: Text("No products available."));
    } else {
      return ListView.builder(
  itemCount: products.length,
  itemBuilder: (context, index) {
    final product = products[index]; // Each item in the list
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      elevation: 3,
      child: ListTile(
        title: Text(
          product['name'], // Accessing product details
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('Price: ${product['price']}'),
        trailing: ElevatedButton.icon(
          icon: Icon(Icons.add_shopping_cart),
          label: Text('Add to Cart'),
          onPressed: () {
            addToCart(product); // Add the product to the cart
          },
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white, backgroundColor: Colors.green,
          ),
        ),
      ),
    );
  },
);

          );
        },
      );
    }
  }

  Widget _buildHomeContent() {
    return Center(child: Text('Welcome to the Dashboard!'));
  }

  Widget _buildAddProductContent() {
    return Center(child: Text('Add Product Screen'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Dashboard')),
      body: _selectedIndex == 1
          ? _buildProductList() // Show the product list when "View All" is selected
          : SingleChildScrollView(
              // Wrap the other content with SingleChildScrollView
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton(
                          onPressed: navigateToAddProductScreen,
                          child: Text("Add Product"),
                        ),
                      ],
                    ),
                  ),
                  _selectedIndex == 0
                      ? _buildHomeContent()
                      : _selectedIndex == 2
                          ? _buildAddProductContent()
                          : Container(),
                ],
              ),
            ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: "View All"),
          BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart), label: "Cart"),
        ],
      ),
    );
  }
}

class CartScreen extends StatelessWidget {
  final List cart;

  CartScreen({required this.cart});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Your Cart')),
      body: cart.isEmpty
          ? Center(child: Text('Your cart is empty'))
          : ListView.builder(
              itemCount: cart.length,
              itemBuilder: (context, index) {
                final product = cart[index];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                  elevation: 3,
                  child: ListTile(
                    title: Text(
                      product['name'],
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('Price: ${product['price']}'),
                  ),
                );
              },
            ),
    );
  }
}
