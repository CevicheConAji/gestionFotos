import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'controllers/home_page_controller.dart';
import 'views/home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HomePageController(),
      child: MaterialApp(
        title: 'Gestor de Fotos',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(primarySwatch: Colors.deepPurple, useMaterial3: true),
        home: const HomePage(),
      ),
    );
  }
}
