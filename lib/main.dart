import 'package:flutter/material.dart';

import 'package:borudaruma/core/router/app_router.dart';

void main() {
  runApp(const BorudarumaApp());
}

class BorudarumaApp extends StatelessWidget {
  const BorudarumaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'ボルダルマ',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.deepOrangeAccent,
        fontFamily: 'Murecho',
      ),
      routerConfig: appRouter,
    );
  }
}
