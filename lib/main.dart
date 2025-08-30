import 'package:flutter/material.dart';
import 'views/user_list_view.dart';
import 'utils/constants.dart';

void main() {
  runApp(const BaggagieApp());
}

class BaggagieApp extends StatelessWidget {
  const BaggagieApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(AppConstants.primaryColorValue),
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(AppConstants.primaryColorValue),
          foregroundColor: Colors.white,
          elevation: 2,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(AppConstants.primaryColorValue),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppConstants.defaultPadding,
            vertical: AppConstants.defaultPadding,
          ),
        ),
      ),
      home: const UserListView(),
    );
  }
}
