import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'currency_converter_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Load the environment variables
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Currency Pro',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0F0C29),
        primaryColor: Colors.cyanAccent,
      ),
      home: const CurrencyConverterPage(),
    );
  }
}