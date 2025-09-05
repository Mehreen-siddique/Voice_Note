
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
    cardColor: Colors.white,
    canvasColor: Colors.grey.shade300,

    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Colors.black, // FAB ka main color
      foregroundColor: Colors.white, // icon ka color
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)), // rounded button
      ),
      elevation: 6,
    ),

    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),
      bodyMedium: TextStyle(color: Colors.black87, fontSize: 16),
    ),




    iconTheme: const IconThemeData(color: Colors.black),
    dividerColor: Colors.grey.shade400,
  );



  /// 🌙 Dark Theme
  final ThemeData _darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Colors.black,
    cardColor: Colors.black ,
    canvasColor:Color(0xff3a3a3a),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
      bodyMedium: TextStyle(color: Colors.white70, fontSize: 16),
    ),

    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Colors.white, // FAB ka main color
      foregroundColor: Colors.black, // icon ka color
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)), // rounded button
      ),
      elevation: 6,
    ),

    iconTheme: const IconThemeData(color: Colors.white),
    dividerColor: Colors.white70,
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
