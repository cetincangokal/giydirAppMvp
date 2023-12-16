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
    // TODO: implement initState
    super.initState();
     Timer(
      const  Duration(seconds: 3),
      () => Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (BuildContext context) => const LoginScreen()))
    );
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
                fontWeight: FontWeight.w500
              ),
              ),
          ],
        ),
      ),
    );
  }
}
