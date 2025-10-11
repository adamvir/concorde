import 'package:flutter/material.dart';
import 'screens/main_navigation.dart';

void main() {
  runApp(const FigmaToCodeApp());
}

class FigmaToCodeApp extends StatelessWidget {
  const FigmaToCodeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
      ),
      // TODO: TEMPORARY - Change back to LoginEmailPw() for production
      home: MainNavigation(initialPage: 0), // 0 = Portfolio tab
      // home: LoginEmailPw(),
    );
  }
}
