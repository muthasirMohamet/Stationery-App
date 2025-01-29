import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../config.dart';
import 'add_product_screen.dart';
import 'edit_product.dart';

class ProductManagementScreen extends StatefulWidget {
  @override
  _ProductManagementScreenState createState() =>
      _ProductManagementScreenState();
}

class _ProductManagementScreenState extends State<ProductManagementScreen> {
  List products = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/products'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final List<dynamic> productsData = responseData['products'];

        setState(() {
          products = productsData;
          isLoading = false;
        });
      } else {
        showSnackbar('Failed to load products. Status code: ${response.statusCode}');
        setState(() => isLoading = false);
      }
    } catch (e) {
      showSnackbar('Error fetching products: $e');
      setState(() => isLoading = false);
    }
  }

  Future<void> deleteProduct(int id) async {
    // Show confirmation dialog before deletion
    bool? shouldDelete = await showDeleteConfirmationDialog();
    if (!shouldDelete!) return; // If user cancels, do not proceed with deletion

    try {
      final response = await http.delete(Uri.parse('$baseUrl/delete-product/$id'));

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
      barrierDismissible: false, // User must choose an option
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete this product?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(false); // User canceled
              },
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () {
                Navigator.of(context).pop(true); // User confirmed
              },
            ),
          ],
        );
      },
    ) ?? false; // Default to false if dialog is dismissed
  }

  void showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  // Button functionality for creating a product
  void navigateToAddProductScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddProductScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Product Management')),
      body: Column(
        children: [
          // Add buttons for managing products
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: navigateToAddProductScreen,
                  child: Text("Add Product"),
                ),
                // Add more buttons as needed
              ],
            ),
          ),
          // Display the product list below the buttons
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : products.isEmpty
                    ? Center(child: Text("No products available."))
                    : ListView.builder(
                        itemCount: products.length,
                        itemBuilder: (context, index) {
                          final product = products[index];
                          return ListTile(
                            title: Text(product['name']),
                            subtitle: Text('Price: ${product['price']}'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => EditProductScreen(product: product),
                                      ),
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => deleteProduct(product['id']),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
