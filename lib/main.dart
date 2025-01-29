import 'package:flutter/material.dart';
import 'Router/app_router.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Telemedicine App',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/login',
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}
