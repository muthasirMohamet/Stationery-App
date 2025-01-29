import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../config.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  final String url = '$baseUrl/login';

  Future<void> _loginUser() async {
    final String email = _emailController.text.trim();
    final String password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter email and password')),
        );
      }
      return;
    }

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      );

      if (!mounted) return; // Ensure widget is still active

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final String? role =
            data['user']?['role']; // Ensure the 'role' field exists

        if (role == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User role not found')),
          );
          return;
        }

        switch (role.toLowerCase()) {
          case 'admin':
            Navigator.pushNamed(context, '/adminPortal');
            break;
          case 'staff':
            Navigator.pushNamed(context, '/staffPortal');
            break;
          case 'patient':
            Navigator.pushNamed(context, '/patientPortal');
            break;
          default:
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Unknown user role')),
            );
        }
      } else if (response.statusCode == 401) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid email or password')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Server error: ${response.statusCode}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error connecting to server: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _loginUser,
              child: const Text('Login'),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/user/register');
              },
              child: const Text("Don't have an account? Register here"),
            ),
          ],
        ),
      ),
    );
  }
}
