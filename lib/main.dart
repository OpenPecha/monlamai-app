import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Monlam AI App',
      themeMode: ThemeMode.system,
      home: Scaffold(
        backgroundColor: const Color.fromRGBO(245, 245, 245, 100),
        appBar: AppBar(
          title: const Text("Monlam AI"),
          backgroundColor: const Color.fromRGBO(245, 245, 245, 100),
          foregroundColor: const Color.fromRGBO(24, 24, 24, 100),
          leading: IconButton(
            icon: const Icon(Icons.list),
            onPressed: () {
              // do something
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.star),
              onPressed: () {
                // do something
              },
            ),
          ],
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const <Widget>[
              Text(
                'Home page',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
