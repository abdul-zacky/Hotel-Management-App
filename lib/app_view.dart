import 'package:flutter/material.dart';
import 'package:wisma1/screens/home/views/home_screen.dart';

class AppView extends StatelessWidget {
  const AppView({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "WMS",
      theme: ThemeData(
        colorScheme: ColorScheme.light(
          background: Colors.grey.shade100,
          onBackground: Colors.black,
          primary: Color.fromARGB(255, 0, 71, 157),
          secondary: Color.fromARGB(255, 169, 194, 225),
          tertiary: Color(0xFFFF8D6C),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
