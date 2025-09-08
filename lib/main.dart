
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:voicenote/screens/homescreen.dart';

void main(){
  runApp(MainScreen());
}


class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {

  bool isDark = false;

  void toggleTheme() {
    setState(() {
      isDark = !isDark;
    });
  }



  /// 🎨 Light Theme
  final ThemeData _lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: Colors.white,

    // Card ka color same as FAB (dark purple)
    cardColor: const Color(0xFF4C1D95), // deep purple shade


    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFF4C1D95), // Dark Purple FAB
      foregroundColor: Colors.white, // Icon color white for contrast
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      elevation: 6,
    ),

    textTheme: const TextTheme(
      bodyLarge: TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.bold,
        fontSize: 20,
      ),
      bodyMedium: TextStyle(
        color: Colors.black87,
        fontSize: 16,
      ),
    ),

    iconTheme: const IconThemeData(color: Colors.black),
    dividerColor: Colors.grey,
  );




  /// 🌙 Dark Theme
  final ThemeData _darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF1E1B2E), // deep dark background
    cardColor: const Color(0xFF8B5CF6), // light purple for cards

    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFF8B5CF6), // Light purple FAB
      foregroundColor: Colors.white, // Icon white for contrast
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      elevation: 6,
    ),

    textTheme: const TextTheme(
      bodyLarge: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 20,
      ),
      bodyMedium: TextStyle(
        color: Colors.white70,
        fontSize: 16,
      ),
    ),

    iconTheme: const IconThemeData(color: Colors.white),
    dividerColor: Colors.white24,
  );

  @override
  Widget build(BuildContext context) {
    return   AnimatedTheme(
      data: isDark ? _darkTheme : _lightTheme,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: _lightTheme,
        darkTheme: _darkTheme,
        themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
        home: HomeScreen(
          onToggleTheme: toggleTheme,
        ),
      ),
    );
  }
}
