import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../config.dart';

class EditProductScreen extends StatefulWidget {
  final Map<String, dynamic> product;  // Pass the product data

  EditProductScreen({required this.product});

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Debugging: Check if product data is passed correctly
    print('Product data received: ${widget.product}');

    // Initialize the controllers with the product data
    nameController.text = widget.product['name'] ?? '';  // Fallback to empty string if null
    priceController.text = widget.product['price']?.toString() ?? '0';  // Fallback to '0' if null
  }

  Future<void> updateProduct() async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/edit-product/${widget.product['id']}'),
        body: json.encode({
          'name': nameController.text,
          'price': priceController.text,
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        Navigator.pop(context);  // Go back after successful update
        showSnackbar('Product updated successfully');
      } else {
        showSnackbar('Failed to update product');
      }
    } catch (e) {
      showSnackbar('Error updating product: $e');
    }
  }

  void showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit Product')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Product Name'),
            ),
            TextField(
              controller: priceController,
              decoration: InputDecoration(labelText: 'Price'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: updateProduct,  // Update product functionality
              child: Text('Update Product'),
            ),
          ],
        ),
      ),
    );
  }
}
