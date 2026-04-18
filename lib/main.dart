import 'package:flutter/material.dart';
import 'screens/ngo/ngo_home_screen.dart';

void main() {
  runApp(const WasteToTasteApp());
}

class WasteToTasteApp extends StatelessWidget {
  const WasteToTasteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Waste to Taste',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF2E7D32), // green seed color
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const NgoHomeScreen(),
    );
  }
}
