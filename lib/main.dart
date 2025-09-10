
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
    cardColor: const Color(0xFF6750A4), // deep purple shade


    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFF6750A4), // Dark Purple FAB
      foregroundColor: Colors.white, // Icon color white for contrast
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      elevation: 6,
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor:Color(0xFF6750A4), // dark button in light mode
        foregroundColor: Colors.white, // text/icon color
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
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


  );




  /// 🌙 Dark Theme
  final ThemeData _darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF1E1B2E), // deep dark background
    cardColor: const Color(0xFFCDB9FB), // light purple for cards

    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFFCDB9FB), // Light purple FAB
      foregroundColor: Colors.black, // Icon white for contrast
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      elevation: 6,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor:Color(0xFFCDB9FB), // dark button in light mode
        foregroundColor: Colors.black, // text/icon color
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
    ),

    textTheme: const TextTheme(
      bodyLarge: TextStyle(
        color: Colors.white,
        fontSize: 20,
      ),
      bodyMedium: TextStyle(
        color: Colors.white70,
        fontSize: 16,
      ),
    ),

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
