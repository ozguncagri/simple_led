import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';

import 'pages/main_page.dart';
import 'pages/settings_page.dart';

void main() {
  runApp(const MyApp());

  doWhenWindowReady(() {
    const initialSize = Size(300, 670);
    appWindow.minSize = initialSize;
    appWindow.size = initialSize;
    appWindow.alignment = Alignment.center;
    appWindow.title = "SimpleLED Controller";
    appWindow.maxSize = initialSize;
    appWindow.show();
  });
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const MainPage(),
        '/settings': (context) => const SettingsPage(),
      },
    );
  }
}
