import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:giydir_mvp2/providers/user_providers.dart';
import 'package:giydir_mvp2/responsive/mobile_screen_layout.dart';
import 'package:giydir_mvp2/responsive/responsive_layout.dart';
import 'package:giydir_mvp2/responsive/web_screen_layout.dart';
import 'package:giydir_mvp2/screens/splash_screen.dart';
import 'package:giydir_mvp2/utils/colors.dart';
import 'package:provider/provider.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // initialise app based on platform- web or mobile
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyBdwMAfVsyAJyrMs5n4vAXzv_6Pv79FBtE",
        appId: "1:175636124949:web:81fa749a2a6750a49dc51c",
        messagingSenderId: "175636124949",
        projectId: "giydir-mvp2",
        storageBucket: 'giydir-mvp2.appspot.com'
      ),
    );
  } else {
    await Firebase.initializeApp();
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider(),),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Giydir',
        theme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: mobileBackgroundColor,
        ),
        home: StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.active) {
              // Checking if the snapshot has any data or not
              if (snapshot.hasData) {
                // if snapshot has data which means user is logged in then we check the width of screen and accordingly display the screen layout
                return const ResponsiveLayout(
                  mobileScreenLayout: MobileScreenLayout(),
                  webScreenLayout: WebScreenLayout(),
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Text('${snapshot.error}'),
                );
              }
            }

            // means connection to future hasnt been made yet
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            return const SplashScreen();
          },
        ),
      ),
    );
  }
}