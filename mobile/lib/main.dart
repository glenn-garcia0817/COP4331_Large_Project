import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme.dart';
import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const GarnishApp());
}

class GarnishApp extends StatelessWidget {
  const GarnishApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Garnish',
      debugShowCheckedModeBanner: false,
      theme: GarnishTheme.theme,
      home: const HomeScreen(),
    );
  }
}
