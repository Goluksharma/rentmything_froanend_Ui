import 'package:flutter/material.dart';
import 'package:ui_rentmything/routes/app_routes.dart';
import 'layout/main_layout.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'RentMything',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const MainLayout(isLoggedIn: false),
      // start at home
      onGenerateRoute: AppRoutes
          .generateRoute, // start at home onGenerateRoute: AppRoutes.generateRoute, // ✅ direct root
    );
  }
}
