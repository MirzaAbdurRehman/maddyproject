import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'UserScreens/AuthenticationScreen/Splash.dart';
import 'cartProviderModel/GlobalCart.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(
        options: const FirebaseOptions(
            apiKey: "AIzaSyDisMRDdTt5sQfhv2BzUKtTF3zVLVsRm_k",
            authDomain: "citiguid-8c345.firebaseapp.com",
            projectId: "citiguid-8c345",
            storageBucket: "citiguid-8c345.appspot.com",
            messagingSenderId: "706675914030",
            appId: "1:706675914030:web:6363f83f355fc348dd76bf",
            measurementId: "G-JDLWPEV0YQ"));
  } else {
    await Firebase.initializeApp();
  }
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GlobalCartProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(useMaterial3: true),
      home: SplashScreen(),
    );
  }
}