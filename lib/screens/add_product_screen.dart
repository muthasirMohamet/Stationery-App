import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../config.dart'; // Ensure you have your base URL here

class AddProductScreen extends StatefulWidget {
  @override
  _AddProductScreenState createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  TextEditingController nameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController quantityController = TextEditingController();

  Future<void> addProduct() async {
    String name = nameController.text.trim();
    String description = descriptionController.text.trim();
    double? price = double.tryParse(priceController.text);
    int? quantity = int.tryParse(quantityController.text);

    if (name.isEmpty || description.isEmpty || price == null || quantity == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all fields with valid data')),
      );
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/add-product'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': name,
          'description': description,
          'price': price,
          'quantity': quantity,
        }),
      );

      final Map<String, dynamic> responseData = json.decode(response.body);

      if (response.statusCode == 200 && responseData['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Product added successfully')));
        Navigator.pop(context); // Go back to the previous screen
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${responseData['message']}')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to add product: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add New Product')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: nameController, decoration: InputDecoration(labelText: 'Product Name')),
            TextField(controller: descriptionController, decoration: InputDecoration(labelText: 'Description')),
            TextField(controller: priceController, decoration: InputDecoration(labelText: 'Price'), keyboardType: TextInputType.number),
            TextField(controller: quantityController, decoration: InputDecoration(labelText: 'Quantity'), keyboardType: TextInputType.number),
            SizedBox(height: 20),
            ElevatedButton(onPressed: addProduct, child: Text('Add Product')),
          ],
        ),
      ),
    );
  }
}
