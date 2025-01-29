import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../auth/login_screen.dart';

class UserRegisterScreen extends StatefulWidget {
  @override
  _UserRegisterScreenState createState() => _UserRegisterScreenState();
}

class _UserRegisterScreenState extends State<UserRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _email = '';
  String _phoneNumber = '';
  String _role = 'Patient'; // Default role
  String _password = '';

  // List of roles
  final List<String> _roles = ['Patient', 'Doctor', 'Staff' , 'Admin'];

  Future<void> _registerUser() async {
    // Replace '192.168.x.x' with your machine's IP address or deployed server address
    final String url = "http://192.168.43.149:3000/users";

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': _name,
          'email': _email,
          'phoneNumber': _phoneNumber,
          'role': _role,
          'password': _password,
        }),
      );
      print("Response: ${response.statusCode}");
      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User registered successfully!')),
        );

        // Redirect to the Login Page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${response.body}')),
        );
        print("Error response: ${response.body}");
      }
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: Unable to connect to the server')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Register User')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Name'),
                onSaved: (value) => _name = value!,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(labelText: 'Email'),
                onSaved: (value) => _email = value!,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(labelText: 'Phone Number'),
                onSaved: (value) => _phoneNumber = value!,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your phone number';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
                onSaved: (value) => _password = value!,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters long';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _role,
                decoration: InputDecoration(labelText: 'Role'),
                items: _roles.map((role) {
                  return DropdownMenuItem(
                    value: role,
                    child: Text(role),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _role = value!;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a role';
                  }
                  return null;
                },
              ),
              SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    _registerUser();
                  }
                },
                child: Text('Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
