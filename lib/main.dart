import 'package:flutter/material.dart';
import 'screens/home_screen.dart'; // Ana ekranı buradan çağırıyoruz

void main() {
  runApp(const SubscriptionApp());
}

class SubscriptionApp extends StatelessWidget {
  const SubscriptionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Abonelik Detoksu',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: Colors.green,
      ),
      home: const HomeScreen(),
    );
  }
}