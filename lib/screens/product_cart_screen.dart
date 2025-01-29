// import 'package:flutter/material.dart';
// import '../services/api_service.dart';

// class ProductCartScreen extends StatefulWidget {
//   @override
//   _ProductCartScreenState createState() => _ProductCartScreenState();
// }

// class _ProductCartScreenState extends State<ProductCartScreen> {
//   List cart = [];

//   @override
//   void initState() {
//     super.initState();
//     fetchCart();
//   }

//   void fetchCart() async {
//     var response = await ApiService.getCart();
//     setState(() {
//       cart = response;
//     });
//   }

//   void removeFromCart(int id) async {
//     var response = await ApiService.removeFromCart(id);
//     if (response['status'] == 'success') {
//       fetchCart();
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Product Cart')),
//       body: ListView.builder(
//         itemCount: cart.length,
//         itemBuilder: (context, index) {
//           final cartItem = cart[index];
//           return ListTile(
//             title: Text(cartItem['product']['name']),
//             subtitle: Text('Quantity: ${cartItem['quantity']}'),
//             trailing: IconButton(
//               icon: Icon(Icons.remove_shopping_cart),
//               onPressed: () => removeFromCart(cartItem['id']),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
