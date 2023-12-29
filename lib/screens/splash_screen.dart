import 'dart:async';

import 'package:flutter/material.dart';
import 'package:giydir_mvp2/screens/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
//deneme
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // Use a local variable to store the context
    BuildContext? currentContext = context;

    // Check if the widget is still mounted before creating the Timer
    if (mounted) {
      Timer(
        const Duration(seconds: 3),
        () {
          // Check if the widget is still mounted before navigating
          if (mounted) {
            Navigator.of(currentContext).pushReplacement(
              MaterialPageRoute(
                builder: (BuildContext context) => const LoginScreen(),
              ),
            );
          }
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Giydir!',
              style: TextStyle(
                fontSize: 48,
                color: Colors.black,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
